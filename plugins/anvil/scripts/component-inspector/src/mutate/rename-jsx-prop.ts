/**
 * Structurally rename a prop on every JSX element of a given component.
 *
 *   <Button pip={count} />        →  <Button badge={count} />
 *   <Button pip="3">…</Button>    →  <Button badge="3">…</Button>
 *   <Button {...rest} pip={x} />  →  <Button {...rest} badge={x} />
 *
 * Only renames the named JSX attribute. Spread props (`{...rest}`) are left
 * untouched even if `rest` contains a `pip` field — this is a deliberate
 * trade-off; touching spread elements would require dataflow analysis.
 *
 * Does NOT modify the prop's TypeScript declaration. Pair with `renameTypeMember`
 * (or update the source file by hand) to rename the prop on the interface.
 */

import { readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import ts from "typescript";
import fg from "fast-glob";

export interface RenameJsxPropOptions {
  /** Component name whose JSX usages should be rewritten (e.g. `Button`). */
  component: string;
  /** Old prop name (e.g. `pip`). */
  oldProp: string;
  /** New prop name (e.g. `badge`). */
  newProp: string;
  /** Project root for the file scan. Absolute. */
  root: string;
  /** Optional include / exclude globs. */
  include?: string[];
  exclude?: string[];
  /** Apply changes. Defaults to dry-run. */
  apply?: boolean;
}

export interface RenameJsxPropHit {
  filePath: string;
  /** Line numbers (1-indexed) of the renamed attributes in this file. */
  lines: number[];
  /** The full updated source if `apply` is true; undefined otherwise. */
  newSource?: string;
}

export interface RenameJsxPropResult {
  hits: RenameJsxPropHit[];
  /** Total number of JSX attribute renames across all files. */
  totalRenames: number;
  written: boolean;
}

const DEFAULT_INCLUDES = [
  "src/**/*.{tsx,jsx}",
  "apps/*/src/**/*.{tsx,jsx}",
  "apps/*/app/**/*.{tsx,jsx}",
  "packages/*/src/**/*.{tsx,jsx}",
  "packages/*/.storybook/**/*.{tsx,jsx}",
  "**/{quarks,atoms,molecules,organisms,surfaces,templates,pages}/**/*.{tsx,jsx}",
  "**/*.stories.{tsx,jsx}",
];

const DEFAULT_EXCLUDES = [
  "**/node_modules/**",
  "**/dist/**",
  "**/build/**",
  "**/.next/**",
  "**/storybook-static/**",
];

export async function renameJsxProp(opts: RenameJsxPropOptions): Promise<RenameJsxPropResult> {
  const include = opts.include ?? DEFAULT_INCLUDES;
  const exclude = opts.exclude ?? DEFAULT_EXCLUDES;
  const files = await fg(include, {
    cwd: opts.root,
    absolute: true,
    onlyFiles: true,
    ignore: exclude,
  });

  const hits: RenameJsxPropHit[] = [];
  let totalRenames = 0;

  for (const file of files) {
    const source = await readFile(file, "utf8");
    if (!source.includes(`<${opts.component}`) || !source.includes(opts.oldProp)) continue;

    const result = renameInSource(source, file, opts.component, opts.oldProp, opts.newProp);
    if (result.lines.length === 0) continue;

    totalRenames += result.lines.length;
    const hit: RenameJsxPropHit = {
      filePath: path.relative(opts.root, file),
      lines: result.lines,
    };
    if (opts.apply) {
      await writeFile(file, result.newSource, "utf8");
      hit.newSource = result.newSource;
    }
    hits.push(hit);
  }

  return { hits: hits.sort((a, b) => a.filePath.localeCompare(b.filePath)), totalRenames, written: Boolean(opts.apply) };
}

interface SourceRewriteResult {
  newSource: string;
  lines: number[];
}

function renameInSource(
  source: string,
  filePath: string,
  componentName: string,
  oldProp: string,
  newProp: string,
): SourceRewriteResult {
  const sourceFile = ts.createSourceFile(filePath, source, ts.ScriptTarget.ES2022, true, scriptKindOf(filePath));

  // Collect target attribute name nodes — sorted by start position descending,
  // so we can splice from the end without invalidating earlier offsets.
  const targets: ts.Identifier[] = [];

  function visit(node: ts.Node): void {
    if (ts.isJsxOpeningElement(node) || ts.isJsxSelfClosingElement(node)) {
      const tagName = node.tagName;
      if (ts.isIdentifier(tagName) && tagName.text === componentName) {
        for (const attr of node.attributes.properties) {
          if (
            ts.isJsxAttribute(attr) &&
            ts.isIdentifier(attr.name) &&
            attr.name.text === oldProp
          ) {
            targets.push(attr.name);
          }
        }
      }
    }
    ts.forEachChild(node, visit);
  }
  visit(sourceFile);

  if (targets.length === 0) return { newSource: source, lines: [] };

  // Rewrite end → start so offsets remain valid.
  const sortedDesc = targets.slice().sort((a, b) => b.getStart(sourceFile) - a.getStart(sourceFile));
  let working = source;
  for (const ident of sortedDesc) {
    const start = ident.getStart(sourceFile);
    const end = ident.getEnd();
    working = `${working.slice(0, start)}${newProp}${working.slice(end)}`;
  }

  // Compute lines in the original source for reporting.
  const lines = targets.map((t) => {
    const { line } = sourceFile.getLineAndCharacterOfPosition(t.getStart(sourceFile));
    return line + 1;
  }).sort((a, b) => a - b);

  return { newSource: working, lines };
}

function scriptKindOf(filePath: string): ts.ScriptKind {
  if (filePath.endsWith(".tsx")) return ts.ScriptKind.TSX;
  if (filePath.endsWith(".jsx")) return ts.ScriptKind.JSX;
  if (filePath.endsWith(".ts")) return ts.ScriptKind.TS;
  return ts.ScriptKind.JS;
}
