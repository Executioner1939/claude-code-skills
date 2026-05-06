/**
 * Find exported names that no other file in the project imports.
 *
 * Approach:
 *   1. Build the project's import graph (single pass).
 *   2. For every TS/TSX file in the include set, collect the names it exports.
 *   3. From the inverted import graph, derive which of those names are
 *      imported by at least one other file.
 *   4. Anything exported but unimported is an orphan.
 *
 * Common false positives (acknowledged, surfaced as such):
 *   - Re-export barrels (`export * from "./X"`) — orphans are reported on
 *     the original file. Re-exports of orphaned names are also orphans.
 *   - Public package surfaces — a project's `src/index.ts` exports the
 *     public API, which is consumed externally. Pass the entry-point file
 *     via `--entry` to exclude its exports from the orphan check, OR mark
 *     the file with the include glob exclusion.
 *   - Default exports — covered. The graph records `default` as an
 *     imported name only if a consumer imports the default explicitly.
 *
 * The verb is read-only and emits a JSON report or human text.
 */

import path from "node:path";
import { readFile } from "node:fs/promises";
import ts from "typescript";
import fg from "fast-glob";
import { buildImportGraph, type ImportGraph } from "./import-graph.js";

export interface OrphanExportsOptions {
  root: string;
  /** Files whose exports are part of the public API and should be ignored. */
  entryPoints?: string[];
  include?: string[];
  exclude?: string[];
}

export interface OrphanExport {
  /** File that exports the name. */
  filePath: string;
  /** Exported identifier. `default` for default exports. */
  name: string;
  /** Source line of the export. */
  line: number;
  /** True when the name is exported via `export * from "./X"` (a re-export). */
  isReExport: boolean;
}

export interface OrphanExportsResult {
  orphans: OrphanExport[];
  filesScanned: number;
}

const DEFAULT_INCLUDES = [
  "src/**/*.{ts,tsx}",
  "apps/*/src/**/*.{ts,tsx}",
  "packages/*/src/**/*.{ts,tsx}",
  "**/{quarks,atoms,molecules,organisms,surfaces,templates,pages}/**/*.{ts,tsx}",
];
const DEFAULT_EXCLUDES = [
  "**/node_modules/**",
  "**/dist/**",
  "**/build/**",
  "**/.next/**",
  "**/storybook-static/**",
  "**/*.test.{ts,tsx}",
  "**/*.spec.{ts,tsx}",
  "**/*.stories.{ts,tsx}",
  "**/*.d.ts",
];

export async function findOrphanExports(opts: OrphanExportsOptions): Promise<OrphanExportsResult> {
  const include = opts.include ?? DEFAULT_INCLUDES;
  const exclude = opts.exclude ?? DEFAULT_EXCLUDES;

  const files = await fg(include, { cwd: opts.root, absolute: true, onlyFiles: true, ignore: exclude });
  const graph = await buildImportGraph({ root: opts.root });

  const entrySet = new Set((opts.entryPoints ?? []).map((p) => path.normalize(path.resolve(p))));

  const orphans: OrphanExport[] = [];

  for (const file of files) {
    if (entrySet.has(path.normalize(file))) continue;
    const exports = await collectExports(file);
    if (exports.length === 0) continue;

    const importedNames = collectImportedNamesFor(file, graph);

    for (const exp of exports) {
      // `default` exports are usually for routes / pages — not always orphans
      // even when no one imports the default explicitly (Next.js routes are
      // discovered by file-system convention, not imports). Skip default
      // here unless the file is clearly a library file (under a /components/
      // tier directory). The default heuristic: only flag default exports
      // for files inside a tier directory.
      if (exp.name === "default" && !isInTierTree(file)) continue;

      if (!importedNames.has(exp.name)) {
        orphans.push({
          filePath: path.relative(opts.root, file),
          name: exp.name,
          line: exp.line,
          isReExport: exp.isReExport,
        });
      }
    }
  }

  return {
    orphans: orphans.sort((a, b) =>
      a.filePath.localeCompare(b.filePath) || a.name.localeCompare(b.name),
    ),
    filesScanned: files.length,
  };
}

/* ------------------------------------------------------------------ */
/*  Per-file export collection                                         */
/* ------------------------------------------------------------------ */

interface ExportEntry {
  name: string;
  line: number;
  isReExport: boolean;
}

async function collectExports(file: string): Promise<ExportEntry[]> {
  const source = await readFile(file, "utf8");
  const sourceFile = ts.createSourceFile(file, source, ts.ScriptTarget.ES2022, true, scriptKindOf(file));
  const out: ExportEntry[] = [];

  for (const stmt of sourceFile.statements) {
    if (ts.isExportDeclaration(stmt) && stmt.exportClause && ts.isNamedExports(stmt.exportClause)) {
      const isRe = Boolean(stmt.moduleSpecifier);
      for (const spec of stmt.exportClause.elements) {
        out.push({ name: spec.name.text, line: lineOf(spec.name, sourceFile), isReExport: isRe });
      }
      continue;
    }
    if (ts.isExportAssignment(stmt) && !stmt.isExportEquals) {
      out.push({ name: "default", line: lineOf(stmt, sourceFile), isReExport: false });
      continue;
    }
    if (!isExported(stmt)) continue;
    if (ts.isFunctionDeclaration(stmt) && stmt.name) {
      out.push({ name: stmt.name.text, line: lineOf(stmt.name, sourceFile), isReExport: false });
    } else if (ts.isClassDeclaration(stmt) && stmt.name) {
      out.push({ name: stmt.name.text, line: lineOf(stmt.name, sourceFile), isReExport: false });
    } else if (ts.isInterfaceDeclaration(stmt)) {
      out.push({ name: stmt.name.text, line: lineOf(stmt.name, sourceFile), isReExport: false });
    } else if (ts.isTypeAliasDeclaration(stmt)) {
      out.push({ name: stmt.name.text, line: lineOf(stmt.name, sourceFile), isReExport: false });
    } else if (ts.isVariableStatement(stmt)) {
      for (const decl of stmt.declarationList.declarations) {
        if (ts.isIdentifier(decl.name)) {
          out.push({ name: decl.name.text, line: lineOf(decl.name, sourceFile), isReExport: false });
        }
      }
    }
  }
  return out;
}

function collectImportedNamesFor(file: string, graph: ImportGraph): Set<string> {
  const names = new Set<string>();
  const incoming = graph.byImported.get(path.normalize(file)) ?? [];
  for (const edge of incoming) {
    for (const name of edge.names) names.add(name);
  }
  return names;
}

function isExported(node: ts.Node): boolean {
  if (!ts.canHaveModifiers(node)) return false;
  return ts.getModifiers(node)?.some((m) => m.kind === ts.SyntaxKind.ExportKeyword) ?? false;
}

function isInTierTree(filePath: string): boolean {
  return /\/(quarks|atoms|molecules|organisms|surfaces|templates|pages)\//.test(filePath);
}

function lineOf(node: ts.Node, sourceFile: ts.SourceFile): number {
  return sourceFile.getLineAndCharacterOfPosition(node.getStart(sourceFile)).line + 1;
}

function scriptKindOf(filePath: string): ts.ScriptKind {
  if (filePath.endsWith(".tsx")) return ts.ScriptKind.TSX;
  if (filePath.endsWith(".jsx")) return ts.ScriptKind.JSX;
  if (filePath.endsWith(".ts")) return ts.ScriptKind.TS;
  return ts.ScriptKind.JS;
}
