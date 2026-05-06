/**
 * Strip a named identifier from every `import` statement that mentions it.
 *
 * Cases:
 *
 *   import { Foo } from "x"          →  (statement removed)
 *   import { Foo, Bar } from "x"     →  import { Bar } from "x"
 *   import { Bar, Foo } from "x"     →  import { Bar } from "x"
 *   import { Foo as F } from "x"     →  (statement removed; F was a local alias)
 *   import Foo from "x"              →  (statement removed)
 *   import Foo, { Bar } from "x"     →  import { Bar } from "x"
 *
 * Type-only imports follow the same rules. The `module` field of the import
 * statement is preserved verbatim.
 *
 * Use this when a component is being deleted and the consumer files need
 * their imports cleaned up before the delete lands.
 */

import { readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import ts from "typescript";
import fg from "fast-glob";

export interface RemoveImportOptions {
  /** Identifier to strip from imports (e.g. `Drawer`, `pip`). */
  name: string;
  /** Project root. Absolute. */
  root: string;
  include?: string[];
  exclude?: string[];
  apply?: boolean;
}

export interface RemoveImportHit {
  filePath: string;
  /** Lines (1-indexed) where the rewrite happened. */
  lines: number[];
  /** True if the entire import statement was removed (no other names remained). */
  removedEntireStatement: boolean;
}

export interface RemoveImportResult {
  hits: RemoveImportHit[];
  totalEdits: number;
  written: boolean;
}

const DEFAULT_INCLUDES = [
  "src/**/*.{ts,tsx,jsx}",
  "apps/*/src/**/*.{ts,tsx,jsx}",
  "packages/*/src/**/*.{ts,tsx,jsx}",
  "**/{quarks,atoms,molecules,organisms,surfaces,templates,pages}/**/*.{ts,tsx,jsx}",
];
const DEFAULT_EXCLUDES = ["**/node_modules/**", "**/dist/**", "**/build/**", "**/.next/**", "**/storybook-static/**"];

export async function removeImport(opts: RemoveImportOptions): Promise<RemoveImportResult> {
  const include = opts.include ?? DEFAULT_INCLUDES;
  const exclude = opts.exclude ?? DEFAULT_EXCLUDES;
  const files = await fg(include, { cwd: opts.root, absolute: true, onlyFiles: true, ignore: exclude });

  const hits: RemoveImportHit[] = [];
  let totalEdits = 0;

  for (const file of files) {
    const source = await readFile(file, "utf8");
    if (!source.includes(opts.name)) continue;
    const result = stripFromSource(source, file, opts.name);
    if (result.lines.length === 0) continue;
    totalEdits += result.lines.length;
    const rel = path.relative(opts.root, file);
    if (opts.apply) await writeFile(file, result.newSource, "utf8");
    hits.push({ filePath: rel, lines: result.lines, removedEntireStatement: result.removedEntireStatement });
  }

  return { hits: hits.sort((a, b) => a.filePath.localeCompare(b.filePath)), totalEdits, written: Boolean(opts.apply) };
}

interface SourceRewriteResult {
  newSource: string;
  lines: number[];
  removedEntireStatement: boolean;
}

function stripFromSource(source: string, filePath: string, name: string): SourceRewriteResult {
  const sourceFile = ts.createSourceFile(filePath, source, ts.ScriptTarget.ES2022, true, scriptKindOf(filePath));

  type Edit =
    | { kind: "removeStatement"; start: number; end: number; line: number }
    | { kind: "rewriteClause"; start: number; end: number; line: number; replacement: string };

  const edits: Edit[] = [];

  for (const stmt of sourceFile.statements) {
    if (!ts.isImportDeclaration(stmt)) continue;
    const clause = stmt.importClause;
    if (!clause) continue;

    const moduleSpecifier = stmt.moduleSpecifier;
    const isStringLiteralModule = ts.isStringLiteral(moduleSpecifier);
    if (!isStringLiteralModule) continue;

    let matchedDefault = clause.name?.text === name;
    let matchedNamed: string | undefined;

    let remainingNamedSpecifiers: ts.ImportSpecifier[] = [];
    if (clause.namedBindings && ts.isNamedImports(clause.namedBindings)) {
      for (const spec of clause.namedBindings.elements) {
        // The local binding is `spec.name.text`; `spec.propertyName?.text` is the
        // imported (foreign) name when an alias is present. Either matching
        // qualifies as "this statement imports `name`".
        const localName = spec.name.text;
        const importedName = spec.propertyName?.text ?? localName;
        if (importedName === name || localName === name) {
          matchedNamed = localName;
        } else {
          remainingNamedSpecifiers.push(spec);
        }
      }
    } else if (clause.namedBindings && ts.isNamespaceImport(clause.namedBindings)) {
      // `import * as Foo from "x"` — only matches if the namespace is exactly the target.
      if (clause.namedBindings.name.text === name) matchedDefault = matchedDefault || true;
    }

    if (!matchedDefault && !matchedNamed) continue;

    const remainingDefault = clause.name && !matchedDefault ? clause.name.text : undefined;
    const remainingNamed = remainingNamedSpecifiers
      .map((s) => printSpecifier(s, sourceFile))
      .join(", ");

    const start = stmt.getFullStart();
    const end = stmt.getEnd();
    const lineFromStart = sourceFile.getLineAndCharacterOfPosition(stmt.getStart(sourceFile)).line + 1;

    if (!remainingDefault && remainingNamedSpecifiers.length === 0) {
      // Nothing left — drop the statement entirely (preserving leading whitespace).
      edits.push({ kind: "removeStatement", start, end, line: lineFromStart });
    } else {
      // Reconstruct the clause.
      const typeKw = clause.isTypeOnly ? "type " : "";
      let rebuilt = "import ";
      if (remainingDefault && remainingNamedSpecifiers.length > 0) {
        rebuilt += `${typeKw}${remainingDefault}, { ${remainingNamed} }`;
      } else if (remainingDefault) {
        rebuilt += `${typeKw}${remainingDefault}`;
      } else {
        rebuilt += `${typeKw}{ ${remainingNamed} }`;
      }
      rebuilt += ` from ${moduleSpecifier.getText(sourceFile)};`;
      edits.push({ kind: "rewriteClause", start: stmt.getStart(sourceFile), end, line: lineFromStart, replacement: rebuilt });
    }
  }

  if (edits.length === 0) return { newSource: source, lines: [], removedEntireStatement: false };

  // Apply edits end → start.
  edits.sort((a, b) => b.start - a.start);
  let working = source;
  let removedEntire = false;
  const lines: number[] = [];
  for (const edit of edits) {
    if (edit.kind === "removeStatement") {
      working = working.slice(0, edit.start) + working.slice(edit.end);
      removedEntire = true;
    } else {
      working = working.slice(0, edit.start) + edit.replacement + working.slice(edit.end);
    }
    lines.push(edit.line);
  }
  return { newSource: working, lines: lines.sort((a, b) => a - b), removedEntireStatement: removedEntire };
}

function printSpecifier(spec: ts.ImportSpecifier, sourceFile: ts.SourceFile): string {
  return spec.getText(sourceFile);
}

function scriptKindOf(filePath: string): ts.ScriptKind {
  if (filePath.endsWith(".tsx")) return ts.ScriptKind.TSX;
  if (filePath.endsWith(".jsx")) return ts.ScriptKind.JSX;
  if (filePath.endsWith(".ts")) return ts.ScriptKind.TS;
  return ts.ScriptKind.JS;
}
