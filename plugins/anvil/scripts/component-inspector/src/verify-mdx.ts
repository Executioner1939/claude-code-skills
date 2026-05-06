/**
 * Verify that every `<Canvas of={Stories.X} />` (and `<Meta of={…}>`,
 * `<ArgTypes of={…}>`, etc.) reference in MDX docs resolves against the
 * actual exports of the stories file the MDX imports.
 *
 * Catches the "PaymentMethodItem stale Stories.EachBrand" class of bug —
 * after renaming story exports (often via a taxonomy pass), MDX docs that
 * reference the old export names silently render empty Canvas blocks. Vite
 * logs them as warnings; users see blanks.
 *
 * Approach:
 *
 *   1. Find every `*.mdx` file under the project (or under `--include` globs).
 *   2. For each MDX, parse `import * as <Alias> from "<path>"` directives —
 *      typical pattern is `import * as Stories from "../../components/.../X.stories"`.
 *      Resolve `<path>` against the MDX file location.
 *   3. Also pick up direct `import { Default } from "..."` named imports for
 *      completeness.
 *   4. For each imported alias, scan the MDX body for `<Tag of={Alias.<Name>} />`
 *      / `of={Alias.<Name>}` references.
 *   5. Parse the resolved stories file and collect its exported names.
 *   6. Diff the references against the exports; report missing names.
 *
 * Only validates references — does not write anything. Pair with
 * `renameStoryTitle` / `renameJsxProp` runs and call this immediately after
 * to catch drift.
 */

import { readFile } from "node:fs/promises";
import path from "node:path";
import ts from "typescript";
import fg from "fast-glob";

export interface VerifyMdxOptions {
  root: string;
  include?: string[];
  exclude?: string[];
}

export interface VerifyMdxIssue {
  /** MDX file containing the broken reference. */
  mdxPath: string;
  /** Stories file the alias resolves to (if resolution succeeded). */
  storiesPath?: string;
  /** Alias namespace the reference came from (e.g. `Stories`). */
  alias: string;
  /** The export name referenced from MDX that does not exist in the stories file. */
  missingExport: string;
  /** Sorted list of exports that DO exist — useful for a "did you mean" hint. */
  available: string[];
}

export interface VerifyMdxResult {
  issues: VerifyMdxIssue[];
  /** All MDX files scanned. */
  mdxFiles: string[];
  /** All stories files referenced. */
  storiesFiles: string[];
}

const DEFAULT_INCLUDES = [
  "src/**/*.mdx",
  "apps/*/src/**/*.mdx",
  "packages/*/src/**/*.mdx",
  "packages/*/.storybook/**/*.mdx",
  "**/.storybook/**/*.mdx",
  // Generic atomic-tree fallback — catches docs colocated under tier folders
  // and fixtures used by the inspector's own tests.
  "**/{atoms,molecules,organisms,surfaces,templates,pages,docs}/**/*.mdx",
];
const DEFAULT_EXCLUDES = ["**/node_modules/**", "**/dist/**", "**/build/**", "**/.next/**", "**/storybook-static/**"];

export async function verifyMdxRefs(opts: VerifyMdxOptions): Promise<VerifyMdxResult> {
  const include = opts.include ?? DEFAULT_INCLUDES;
  const exclude = opts.exclude ?? DEFAULT_EXCLUDES;
  const mdxFiles = await fg(include, { cwd: opts.root, absolute: true, onlyFiles: true, ignore: exclude });

  const issues: VerifyMdxIssue[] = [];
  const storiesFiles = new Set<string>();

  for (const mdx of mdxFiles) {
    const source = await readFile(mdx, "utf8");
    const namespaceImports = collectNamespaceImports(source);
    const namedImports = collectNamedImports(source);
    const aliasToFile = new Map<string, string>();

    // Resolve each namespace alias to a real stories file.
    for (const ns of namespaceImports) {
      const resolved = await resolveImport(ns.specifier, mdx);
      if (!resolved) continue;
      aliasToFile.set(ns.alias, resolved);
      storiesFiles.add(resolved);
    }

    // Validate `Alias.Name` references against each resolved file's exports.
    if (aliasToFile.size > 0) {
      for (const [alias, storiesPath] of aliasToFile) {
        const exportNames = await collectStoryExports(storiesPath);
        const refs = collectAliasReferences(source, alias);
        for (const ref of refs) {
          if (!exportNames.has(ref)) {
            issues.push({
              mdxPath: path.relative(opts.root, mdx),
              storiesPath: path.relative(opts.root, storiesPath),
              alias,
              missingExport: ref,
              available: Array.from(exportNames).sort(),
            });
          }
        }
      }
    }

    // Validate direct named imports — `import { Default } from "../X.stories"`.
    for (const named of namedImports) {
      const resolved = await resolveImport(named.specifier, mdx);
      if (!resolved) continue;
      storiesFiles.add(resolved);
      const exportNames = await collectStoryExports(resolved);
      for (const importedName of named.names) {
        if (!exportNames.has(importedName)) {
          issues.push({
            mdxPath: path.relative(opts.root, mdx),
            storiesPath: path.relative(opts.root, resolved),
            alias: importedName,
            missingExport: importedName,
            available: Array.from(exportNames).sort(),
          });
        }
      }
    }
  }

  return {
    issues: issues.sort(
      (a, b) =>
        a.mdxPath.localeCompare(b.mdxPath) ||
        a.alias.localeCompare(b.alias) ||
        a.missingExport.localeCompare(b.missingExport),
    ),
    mdxFiles: mdxFiles.map((f) => path.relative(opts.root, f)).sort(),
    storiesFiles: Array.from(storiesFiles).map((f) => path.relative(opts.root, f)).sort(),
  };
}

/* ------------------------------------------------------------------ */
/*  MDX import scanning                                                */
/* ------------------------------------------------------------------ */

interface NamespaceImport {
  alias: string;
  specifier: string;
}

interface NamedImport {
  names: string[];
  specifier: string;
}

/**
 * MDX is markdown + JSX, but the `import` directives at the top of the file
 * follow ES module syntax. Rather than parsing the whole MDX (different lib
 * surface, AST shape varies between MDX 1/2/3), we recognise the import
 * statements with a focused regex over the file head — they're always at
 * the top, never inline.
 */
function collectNamespaceImports(source: string): NamespaceImport[] {
  const out: NamespaceImport[] = [];
  const re = /^\s*import\s+\*\s+as\s+(\w+)\s+from\s+["']([^"']+)["']/gm;
  let m: RegExpExecArray | null;
  while ((m = re.exec(source))) {
    const alias = m[1];
    const specifier = m[2];
    if (alias && specifier) out.push({ alias, specifier });
  }
  return out;
}

function collectNamedImports(source: string): NamedImport[] {
  const out: NamedImport[] = [];
  const re = /^\s*import\s+\{([^}]+)\}\s+from\s+["']([^"']+)["']/gm;
  let m: RegExpExecArray | null;
  while ((m = re.exec(source))) {
    const namesText = m[1];
    const specifier = m[2];
    if (!namesText || !specifier) continue;
    const names = namesText
      .split(",")
      .map((n) => n.trim().replace(/^type\s+/, "").split(/\s+as\s+/)[0])
      .filter((n): n is string => Boolean(n));
    if (names.length > 0) out.push({ names, specifier });
  }
  return out;
}

/**
 * Find every `Alias.X` reference in the MDX body. We deliberately scan the
 * whole source — references can appear inside `<Canvas of={Alias.X}>`,
 * inside `<Meta of={Alias.X}>`, or inside JSX expressions in prose.
 */
function collectAliasReferences(source: string, alias: string): string[] {
  const out = new Set<string>();
  const re = new RegExp(`\\b${escapeRegex(alias)}\\.([A-Za-z_$][A-Za-z0-9_$]*)`, "g");
  let m: RegExpExecArray | null;
  while ((m = re.exec(source))) {
    if (m[1]) out.add(m[1]);
  }
  return Array.from(out);
}

/* ------------------------------------------------------------------ */
/*  Path resolution                                                    */
/* ------------------------------------------------------------------ */

/**
 * Resolve a relative `./X.stories` specifier from an MDX file. Supports the
 * common stories extensions and an extensionless reference.
 */
async function resolveImport(specifier: string, fromFile: string): Promise<string | undefined> {
  if (!specifier.startsWith(".")) {
    // Non-relative: skip — package imports don't point at stories files we can verify.
    return undefined;
  }
  const dir = path.dirname(fromFile);
  const base = path.resolve(dir, specifier);
  const candidates = [
    base,
    `${base}.stories.tsx`,
    `${base}.stories.ts`,
    `${base}.stories.jsx`,
    `${base}.stories.js`,
    `${base}.tsx`,
    `${base}.ts`,
    path.join(base, "index.tsx"),
    path.join(base, "index.ts"),
  ];
  for (const c of candidates) {
    try {
      const buf = await readFile(c, "utf8").catch(() => null);
      if (buf !== null) return c;
    } catch {
      /* try next */
    }
  }
  return undefined;
}

async function collectStoryExports(filePath: string): Promise<Set<string>> {
  const source = await readFile(filePath, "utf8");
  const sourceFile = ts.createSourceFile(filePath, source, ts.ScriptTarget.ES2022, true, scriptKindOf(filePath));
  const out = new Set<string>();
  for (const stmt of sourceFile.statements) {
    if (ts.isVariableStatement(stmt) && hasExport(stmt)) {
      for (const decl of stmt.declarationList.declarations) {
        if (ts.isIdentifier(decl.name)) out.add(decl.name.text);
      }
    } else if (ts.isFunctionDeclaration(stmt) && hasExport(stmt) && stmt.name) {
      out.add(stmt.name.text);
    } else if (ts.isClassDeclaration(stmt) && hasExport(stmt) && stmt.name) {
      out.add(stmt.name.text);
    } else if (ts.isExportDeclaration(stmt) && stmt.exportClause && ts.isNamedExports(stmt.exportClause)) {
      for (const spec of stmt.exportClause.elements) out.add(spec.name.text);
    } else if (ts.isExportAssignment(stmt) && !stmt.isExportEquals) {
      // `export default …` — story files always have one of these for the meta.
      out.add("default");
    }
  }
  return out;
}

function hasExport(node: ts.Node): boolean {
  if (!ts.canHaveModifiers(node)) return false;
  return ts.getModifiers(node)?.some((m) => m.kind === ts.SyntaxKind.ExportKeyword) ?? false;
}

function scriptKindOf(filePath: string): ts.ScriptKind {
  if (filePath.endsWith(".tsx")) return ts.ScriptKind.TSX;
  if (filePath.endsWith(".jsx")) return ts.ScriptKind.JSX;
  if (filePath.endsWith(".ts")) return ts.ScriptKind.TS;
  return ts.ScriptKind.JS;
}

function escapeRegex(s: string): string {
  return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}
