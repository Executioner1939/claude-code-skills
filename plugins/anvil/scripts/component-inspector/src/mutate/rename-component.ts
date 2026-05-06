/**
 * Rename a component identifier across the project.
 *
 * Operates on three surfaces:
 *
 *   1. **JSX usages** — every `<OldName>`, `<OldName/>`, `</OldName>` in
 *      consumer files becomes `<NewName>` etc. JSX inside the declaration
 *      file (for self-references) is also renamed.
 *
 *   2. **Import specifiers** — `import { OldName }` becomes
 *      `import { NewName }`. With aliasing:
 *         `import { OldName }`              → `import { NewName }`
 *         `import { OldName as Local }`     → `import { NewName as Local }`
 *         `import { Foo as OldName }`       — left alone (local alias unrelated)
 *      Type-only imports follow the same rules. Re-export specifiers
 *      (`export { OldName } from "..."`) are also rewritten.
 *
 *   3. **`<OldName>Props` co-rename** (default on; pass `coRenameProps: false`
 *      to disable) — by convention DS components ship a sibling `<Name>Props`
 *      type. We rename it across the same surfaces in a second pass.
 *
 * The function does NOT rename:
 *   - The implementation file itself (`Drawer.tsx` → `ContextSheet.tsx`).
 *     File renames are a separate, deliberate step (and usually demand a
 *     directory rename too).
 *   - Identifiers inside string literals or comments.
 *   - Symbols whose foreign name is unrelated (`import { Foo as OldName }`
 *     — see above).
 *
 * Always dry-run unless `apply: true`.
 */

import { readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import ts from "typescript";
import fg from "fast-glob";

export interface RenameComponentOptions {
  /** Existing component identifier (e.g. `Drawer`). */
  oldName: string;
  /** New component identifier (e.g. `ContextSheet`). */
  newName: string;
  /** Project root. Absolute. */
  root: string;
  /** Co-rename `<OldName>Props` → `<NewName>Props`. Default true. */
  coRenameProps?: boolean;
  include?: string[];
  exclude?: string[];
  /** Apply changes. Defaults to dry-run. */
  apply?: boolean;
}

export interface RenameComponentHit {
  filePath: string;
  /** Counts of each rewrite class in this file. */
  jsxRenames: number;
  importRenames: number;
  exportRenames: number;
  /** Lines (1-indexed) where any rewrite happened. */
  lines: number[];
}

export interface RenameComponentResult {
  hits: RenameComponentHit[];
  totalEdits: number;
  written: boolean;
}

const DEFAULT_INCLUDES = [
  "src/**/*.{ts,tsx,jsx}",
  "apps/*/src/**/*.{ts,tsx,jsx}",
  "apps/*/app/**/*.{ts,tsx,jsx}",
  "packages/*/src/**/*.{ts,tsx,jsx}",
  "packages/*/.storybook/**/*.{ts,tsx,jsx}",
  "**/{quarks,atoms,molecules,organisms,surfaces,templates,pages}/**/*.{ts,tsx,jsx}",
];
const DEFAULT_EXCLUDES = ["**/node_modules/**", "**/dist/**", "**/build/**", "**/.next/**", "**/storybook-static/**"];

export async function renameComponent(opts: RenameComponentOptions): Promise<RenameComponentResult> {
  const include = opts.include ?? DEFAULT_INCLUDES;
  const exclude = opts.exclude ?? DEFAULT_EXCLUDES;
  const files = await fg(include, { cwd: opts.root, absolute: true, onlyFiles: true, ignore: exclude });

  const renames: Array<[string, string]> = [[opts.oldName, opts.newName]];
  if (opts.coRenameProps !== false) {
    renames.push([`${opts.oldName}Props`, `${opts.newName}Props`]);
  }

  const hits: RenameComponentHit[] = [];
  let totalEdits = 0;

  for (const file of files) {
    const source = await readFile(file, "utf8");
    if (!renamesMentioned(source, renames)) continue;

    const result = renameInFile(source, file, renames);
    if (result.totalEdits === 0) continue;

    totalEdits += result.totalEdits;
    if (opts.apply) await writeFile(file, result.newSource, "utf8");

    hits.push({
      filePath: path.relative(opts.root, file),
      jsxRenames: result.jsxRenames,
      importRenames: result.importRenames,
      exportRenames: result.exportRenames,
      lines: result.lines,
    });
  }

  return { hits: hits.sort((a, b) => a.filePath.localeCompare(b.filePath)), totalEdits, written: Boolean(opts.apply) };
}

function renamesMentioned(source: string, renames: Array<[string, string]>): boolean {
  return renames.some(([oldName]) => new RegExp(`\\b${escapeRegex(oldName)}\\b`).test(source));
}

interface FileRewriteResult {
  newSource: string;
  jsxRenames: number;
  importRenames: number;
  exportRenames: number;
  totalEdits: number;
  lines: number[];
}

type EditKind = "jsx" | "import" | "export";
type Edit = { start: number; end: number; replacement: string; line: number; kind: EditKind };

function renameInFile(source: string, filePath: string, renames: Array<[string, string]>): FileRewriteResult {
  const sourceFile = ts.createSourceFile(filePath, source, ts.ScriptTarget.ES2022, true, scriptKindOf(filePath));
  const edits: Edit[] = [];

  const renameMap = new Map(renames);

  function visit(node: ts.Node): void {
    // JSX tag identifiers — opening, self-closing, and closing.
    if (ts.isJsxOpeningElement(node) || ts.isJsxSelfClosingElement(node)) {
      collectJsxTagEdit(node.tagName, edits, renameMap, sourceFile);
    }
    if (ts.isJsxClosingElement(node)) {
      collectJsxTagEdit(node.tagName, edits, renameMap, sourceFile);
    }

    // Import declarations — named specifiers with optional alias.
    if (ts.isImportDeclaration(node) && node.importClause) {
      const bindings = node.importClause.namedBindings;
      if (bindings && ts.isNamedImports(bindings)) {
        for (const spec of bindings.elements) {
          collectImportSpecifierEdit(spec, edits, renameMap, sourceFile, "import");
        }
      }
    }

    // Export declarations with named specifiers.
    if (ts.isExportDeclaration(node) && node.exportClause && ts.isNamedExports(node.exportClause)) {
      for (const spec of node.exportClause.elements) {
        collectImportSpecifierEdit(spec, edits, renameMap, sourceFile, "export");
      }
    }

    // Type references — `const x: OldName = ...`, `function f(p: OldNameProps)`, `interface X extends OldNameProps`.
    if (ts.isTypeReferenceNode(node) && ts.isIdentifier(node.typeName)) {
      collectIdentifierEdit(node.typeName, edits, renameMap, sourceFile);
    }

    // ExpressionWithTypeArguments — used in `extends` / `implements`.
    if (ts.isExpressionWithTypeArguments(node) && ts.isIdentifier(node.expression)) {
      collectIdentifierEdit(node.expression, edits, renameMap, sourceFile);
    }

    // Declaration sites — interface / type-alias / function / variable.
    // Without these the declaration file's own identifier stays at the old
    // name while the rest of the project moves on, leaving consumers
    // broken. We only touch top-level (file-scope) declarations to avoid
    // accidentally renaming a local variable that happens to share a name.
    if (
      (ts.isInterfaceDeclaration(node) || ts.isTypeAliasDeclaration(node)) &&
      node.parent === sourceFile
    ) {
      collectIdentifierEdit(node.name, edits, renameMap, sourceFile);
    }
    if (ts.isFunctionDeclaration(node) && node.name && node.parent === sourceFile) {
      collectIdentifierEdit(node.name, edits, renameMap, sourceFile);
    }
    if (ts.isVariableDeclaration(node) && ts.isIdentifier(node.name)) {
      // Only rename top-level variable declarations (parent chain:
      // VariableDeclaration → VariableDeclarationList → VariableStatement → SourceFile).
      const stmt = node.parent?.parent;
      if (stmt && stmt.parent === sourceFile) {
        collectIdentifierEdit(node.name, edits, renameMap, sourceFile);
      }
    }

    // Function-name / variable identifier inside `forwardRef(function OldName(...) {})`
    // — this is the function-expression name. It isn't required for the
    // component to work, but renaming the export without renaming this
    // leaves a misleading devtools display name. Catch it.
    if (ts.isFunctionExpression(node) && node.name) {
      collectIdentifierEdit(node.name, edits, renameMap, sourceFile);
    }

    ts.forEachChild(node, visit);
  }
  visit(sourceFile);

  if (edits.length === 0) {
    return { newSource: source, jsxRenames: 0, importRenames: 0, exportRenames: 0, totalEdits: 0, lines: [] };
  }

  edits.sort((a, b) => b.start - a.start);
  let working = source;
  for (const edit of edits) {
    working = working.slice(0, edit.start) + edit.replacement + working.slice(edit.end);
  }

  let jsx = 0;
  let imp = 0;
  let exp = 0;
  for (const e of edits) {
    if (e.kind === "jsx") jsx += 1;
    else if (e.kind === "import") imp += 1;
    else if (e.kind === "export") exp += 1;
  }
  const lines = dedupe(edits.map((e) => e.line)).sort((a, b) => a - b);

  return {
    newSource: working,
    jsxRenames: jsx,
    importRenames: imp,
    exportRenames: exp,
    totalEdits: edits.length,
    lines,
  };
}

function collectJsxTagEdit(
  tagName: ts.JsxTagNameExpression,
  edits: Edit[],
  renames: Map<string, string>,
  sourceFile: ts.SourceFile,
): void {
  if (!ts.isIdentifier(tagName)) return;
  const newName = renames.get(tagName.text);
  if (!newName) return;
  edits.push({
    start: tagName.getStart(sourceFile),
    end: tagName.getEnd(),
    replacement: newName,
    line: lineOf(tagName, sourceFile),
    kind: "jsx",
  });
}

function collectImportSpecifierEdit(
  spec: ts.ImportSpecifier | ts.ExportSpecifier,
  edits: Edit[],
  renames: Map<string, string>,
  sourceFile: ts.SourceFile,
  kind: "import" | "export",
): void {
  // Two independent decisions per specifier:
  //   - The FOREIGN name (`spec.propertyName ?? spec.name`) — rename when the
  //     imported/exported symbol itself has been renamed at its source of truth.
  //   - The LOCAL binding (`spec.name`) — rename when our project-wide rename
  //     targets the local identifier that the rest of this file references.
  //
  // For the simple `import { Drawer }` case both nodes are the same; one edit.
  // For `import { Foo as Drawer }` (renaming Drawer → ContextSheet) we touch
  // only `spec.name` and leave `Foo` alone.
  // For `import { Drawer as Local }` (renaming Drawer → ContextSheet) we touch
  // only `spec.propertyName` and leave `Local` alone.

  const foreign = spec.propertyName ?? spec.name;
  const local = spec.name;

  if (!spec.propertyName) {
    // No alias — the single identifier serves as both foreign and local.
    if (renames.has(local.text)) {
      const newName = renames.get(local.text);
      if (newName === undefined) return;
      edits.push({
        start: local.getStart(sourceFile),
        end: local.getEnd(),
        replacement: newName,
        line: lineOf(local, sourceFile),
        kind,
      });
    }
    return;
  }

  // Aliased — check both sides independently.
  if (renames.has(foreign.text)) {
    const newName = renames.get(foreign.text);
    if (newName !== undefined) {
      edits.push({
        start: foreign.getStart(sourceFile),
        end: foreign.getEnd(),
        replacement: newName,
        line: lineOf(foreign, sourceFile),
        kind,
      });
    }
  }
  if (renames.has(local.text)) {
    const newName = renames.get(local.text);
    if (newName !== undefined) {
      edits.push({
        start: local.getStart(sourceFile),
        end: local.getEnd(),
        replacement: newName,
        line: lineOf(local, sourceFile),
        kind,
      });
    }
  }
}

function collectIdentifierEdit(
  ident: ts.Identifier,
  edits: Edit[],
  renames: Map<string, string>,
  sourceFile: ts.SourceFile,
): void {
  const newName = renames.get(ident.text);
  if (!newName) return;
  edits.push({
    start: ident.getStart(sourceFile),
    end: ident.getEnd(),
    replacement: newName,
    line: lineOf(ident, sourceFile),
    kind: "import",
  });
}

function lineOf(node: ts.Node, sourceFile: ts.SourceFile): number {
  return sourceFile.getLineAndCharacterOfPosition(node.getStart(sourceFile)).line + 1;
}

function escapeRegex(s: string): string {
  return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function dedupe<T>(arr: T[]): T[] {
  return Array.from(new Set(arr));
}

function scriptKindOf(filePath: string): ts.ScriptKind {
  if (filePath.endsWith(".tsx")) return ts.ScriptKind.TSX;
  if (filePath.endsWith(".jsx")) return ts.ScriptKind.JSX;
  if (filePath.endsWith(".ts")) return ts.ScriptKind.TS;
  return ts.ScriptKind.JS;
}
