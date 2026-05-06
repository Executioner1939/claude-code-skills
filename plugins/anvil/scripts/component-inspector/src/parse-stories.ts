/**
 * Parse a Storybook CSF3 file and extract structured metadata.
 *
 * The parser is **structurally precise** — it locates `meta.title` only
 * inside the `meta` object, never anywhere else. This is the same precision
 * that prevented the fixture-stomp class of bug. Same approach for argTypes
 * and per-export args.
 *
 * Recognised shapes:
 *
 *   const meta = { title: "...", component: X, args: {...}, tags: [...] } satisfies Meta<typeof X>
 *   const meta: Meta<typeof X> = { ... }
 *   export default meta
 *
 *   export const Default: Story = { args: {...}, play: ... }
 *   export const Variants: StoryObj<typeof meta> = { args: {...} }
 *   export const Composed = { ... } satisfies Story
 *
 * Variants whose values aren't object literals (e.g. `export const X = withFn(...)`)
 * are still recorded by name; the `args` field is omitted.
 */

import ts from "typescript";
import { readFileSync, statSync } from "node:fs";
import path from "node:path";
import type { ArgTypeEntry, StoriesInfo, StoryVariant } from "./types.js";

export interface StoriesParse extends StoriesInfo {
  /** Issues encountered while parsing — used by the card builder. */
  notes: string[];
  /** ISO mtime of the stories file. */
  lastModified: string;
}

const PRINTER = ts.createPrinter({ newLine: ts.NewLineKind.LineFeed, removeComments: true });

export function parseStories(filePath: string): StoriesParse {
  const source = readFileSync(filePath, "utf8");
  const sourceFile = ts.createSourceFile(filePath, source, ts.ScriptTarget.ES2022, true, scriptKindOf(filePath));
  const lastModified = statSync(filePath).mtime.toISOString();

  const meta = findMetaObject(sourceFile);
  const variants = findVariants(sourceFile, meta?.varName);
  const notes: string[] = [];

  const result: StoriesParse = {
    filePath,
    format: detectFormat(meta?.objectLiteral, sourceFile),
    variants,
    notes,
    lastModified,
  };

  if (meta) {
    const props = readMetaProps(meta.objectLiteral, sourceFile);
    if (props.title) result.metaTitle = props.title;
    if (props.tags) result.metaTags = props.tags;
    if (props.args) result.metaArgs = props.args;
    if (props.argTypes) result.argTypes = props.argTypes;
  } else {
    notes.push("no-meta-object-found");
  }

  return result;
}

function scriptKindOf(filePath: string): ts.ScriptKind {
  if (filePath.endsWith(".tsx")) return ts.ScriptKind.TSX;
  if (filePath.endsWith(".ts")) return ts.ScriptKind.TS;
  if (filePath.endsWith(".jsx")) return ts.ScriptKind.JSX;
  return ts.ScriptKind.JS;
}

/* ------------------------------------------------------------------ */
/*  Meta object location                                               */
/* ------------------------------------------------------------------ */

interface MetaLocation {
  varName: string;
  objectLiteral: ts.ObjectLiteralExpression;
}

/**
 * Find the meta object — the variable that is later `export default`-ed and
 * whose RHS is an `ObjectLiteralExpression`. Three shapes covered:
 *
 *   const meta = {...} satisfies Meta<typeof X>
 *   const meta: Meta<typeof X> = {...}
 *   const meta = {...} as Meta<typeof X>
 *
 * If `export default ...` points at an inline object literal we accept that
 * too (nameless meta).
 */
function findMetaObject(sourceFile: ts.SourceFile): MetaLocation | undefined {
  let defaultExportName: string | undefined;
  let defaultInlineLiteral: ts.ObjectLiteralExpression | undefined;
  for (const stmt of sourceFile.statements) {
    if (ts.isExportAssignment(stmt) && !stmt.isExportEquals) {
      const expr = stmt.expression;
      if (ts.isIdentifier(expr)) defaultExportName = expr.text;
      else if (ts.isObjectLiteralExpression(expr)) defaultInlineLiteral = expr;
      else if (ts.isAsExpression(expr) && ts.isObjectLiteralExpression(expr.expression)) defaultInlineLiteral = expr.expression;
      else if (ts.isSatisfiesExpression(expr) && ts.isObjectLiteralExpression(expr.expression)) defaultInlineLiteral = expr.expression;
    }
  }

  if (defaultInlineLiteral) {
    return { varName: "(default)", objectLiteral: defaultInlineLiteral };
  }
  if (!defaultExportName) return undefined;

  for (const stmt of sourceFile.statements) {
    if (!ts.isVariableStatement(stmt)) continue;
    for (const decl of stmt.declarationList.declarations) {
      if (!ts.isIdentifier(decl.name) || decl.name.text !== defaultExportName) continue;
      if (!decl.initializer) return undefined;
      const objectLiteral = unwrapToObjectLiteral(decl.initializer);
      if (!objectLiteral) return undefined;
      return { varName: defaultExportName, objectLiteral };
    }
  }
  return undefined;
}

function unwrapToObjectLiteral(expr: ts.Expression): ts.ObjectLiteralExpression | undefined {
  if (ts.isObjectLiteralExpression(expr)) return expr;
  if (ts.isAsExpression(expr)) return unwrapToObjectLiteral(expr.expression);
  if (ts.isSatisfiesExpression(expr)) return unwrapToObjectLiteral(expr.expression);
  if (ts.isParenthesizedExpression(expr)) return unwrapToObjectLiteral(expr.expression);
  return undefined;
}

/* ------------------------------------------------------------------ */
/*  Meta props                                                         */
/* ------------------------------------------------------------------ */

interface MetaProps {
  title?: string;
  tags?: string[];
  args?: Record<string, unknown>;
  argTypes?: Record<string, ArgTypeEntry>;
}

/**
 * Read selected props from the meta object. We deliberately enumerate only
 * known keys (`title`, `tags`, `args`, `argTypes`) so unrelated keys never
 * leak into the card.
 */
function readMetaProps(obj: ts.ObjectLiteralExpression, sourceFile: ts.SourceFile): MetaProps {
  const out: MetaProps = {};
  for (const prop of obj.properties) {
    if (!ts.isPropertyAssignment(prop)) continue;
    const key = propertyKeyName(prop.name);
    if (!key) continue;
    if (key === "title") {
      const t = readStringLiteral(prop.initializer);
      if (t !== undefined) out.title = t;
    } else if (key === "tags") {
      out.tags = readStringArray(prop.initializer);
    } else if (key === "args") {
      out.args = readObjectAsRecord(prop.initializer, sourceFile);
    } else if (key === "argTypes") {
      out.argTypes = readArgTypes(prop.initializer, sourceFile);
    }
  }
  return out;
}

/* ------------------------------------------------------------------ */
/*  Story variants                                                     */
/* ------------------------------------------------------------------ */

function findVariants(sourceFile: ts.SourceFile, metaVarName: string | undefined): StoryVariant[] {
  const variants: StoryVariant[] = [];
  for (const stmt of sourceFile.statements) {
    if (!ts.isVariableStatement(stmt) || !isExported(stmt)) continue;
    for (const decl of stmt.declarationList.declarations) {
      if (!ts.isIdentifier(decl.name)) continue;
      const exportName = decl.name.text;
      if (exportName === metaVarName) continue;
      // Convention: `__FOO__` exports are private-fixture data, not stories.
      if (exportName.startsWith("__") && exportName.endsWith("__")) continue;
      if (!decl.initializer) {
        variants.push({ exportName, storyName: exportName, hasPlay: false, renderShape: "unknown" });
        continue;
      }
      const obj = unwrapToObjectLiteral(decl.initializer);
      if (!obj) {
        variants.push({ exportName, storyName: exportName, hasPlay: false, renderShape: "unknown" });
        continue;
      }
      const variant = readVariant(exportName, obj, sourceFile);
      variants.push(variant);
    }
  }
  // Stable order: exportName ascending.
  return variants.sort((a, b) => a.exportName.localeCompare(b.exportName));
}

function readVariant(exportName: string, obj: ts.ObjectLiteralExpression, sourceFile: ts.SourceFile): StoryVariant {
  let storyName = exportName;
  let args: Record<string, unknown> | undefined;
  let hasPlay = false;
  let renderShape: StoryVariant["renderShape"] = "single";

  for (const prop of obj.properties) {
    if (!ts.isPropertyAssignment(prop) && !ts.isMethodDeclaration(prop) && !ts.isShorthandPropertyAssignment(prop)) continue;
    const key = propertyKeyName(prop.name);
    if (!key) continue;

    if (ts.isPropertyAssignment(prop)) {
      if (key === "name") {
        const t = readStringLiteral(prop.initializer);
        if (t !== undefined) storyName = t;
      } else if (key === "args") {
        args = readObjectAsRecord(prop.initializer, sourceFile);
      } else if (key === "play") {
        hasPlay = true;
      } else if (key === "render") {
        renderShape = classifyRender(prop.initializer);
      }
    } else if (ts.isMethodDeclaration(prop) && key === "play") {
      hasPlay = true;
    }
  }

  const result: StoryVariant = { exportName, storyName, hasPlay, renderShape };
  if (args) result.args = args;
  return result;
}

/**
 * Classify a render function's shape. Heuristic:
 *   - returns a single JSX element wrapping <ComponentX> → `single`
 *   - returns a fragment / array containing multiple JSX elements → `matrix`
 *   - declares `useState` / `useReducer` inside the render → `interactive`
 *
 * Falls back to `single` because that's the typical shape.
 */
function classifyRender(expr: ts.Expression): StoryVariant["renderShape"] {
  if (!ts.isArrowFunction(expr) && !ts.isFunctionExpression(expr)) return "unknown";
  const text = expr.getText();
  if (/\buseState\b|\buseReducer\b/.test(text)) return "interactive";
  if (/\.map\s*\(/.test(text) || /<>\s*[\s\S]*<\/>/.test(text)) return "matrix";
  return "single";
}

/* ------------------------------------------------------------------ */
/*  argTypes                                                           */
/* ------------------------------------------------------------------ */

function readArgTypes(expr: ts.Expression, sourceFile: ts.SourceFile): Record<string, ArgTypeEntry> | undefined {
  if (!ts.isObjectLiteralExpression(expr)) return undefined;
  const out: Record<string, ArgTypeEntry> = {};
  for (const prop of expr.properties) {
    if (!ts.isPropertyAssignment(prop)) continue;
    const key = propertyKeyName(prop.name);
    if (!key) continue;
    if (!ts.isObjectLiteralExpression(prop.initializer)) {
      out[key] = {};
      continue;
    }
    out[key] = readArgTypeEntry(prop.initializer, sourceFile);
  }
  return Object.keys(out).length === 0 ? undefined : out;
}

function readArgTypeEntry(obj: ts.ObjectLiteralExpression, sourceFile: ts.SourceFile): ArgTypeEntry {
  const entry: ArgTypeEntry = {};
  for (const prop of obj.properties) {
    if (!ts.isPropertyAssignment(prop)) continue;
    const key = propertyKeyName(prop.name);
    if (key === "control") {
      const v = prop.initializer;
      if (ts.isStringLiteral(v)) entry.control = v.text;
      else if (ts.isObjectLiteralExpression(v)) {
        // { type: "select" }
        const inner = v.properties.find(
          (p) => ts.isPropertyAssignment(p) && propertyKeyName(p.name) === "type",
        ) as ts.PropertyAssignment | undefined;
        if (inner && ts.isStringLiteral(inner.initializer)) entry.control = inner.initializer.text;
      }
    } else if (key === "options") {
      entry.options = readStringArray(prop.initializer) ?? undefined;
    } else if (key === "table") {
      // table.disable
      if (ts.isObjectLiteralExpression(prop.initializer)) {
        for (const t of prop.initializer.properties) {
          if (ts.isPropertyAssignment(t) && propertyKeyName(t.name) === "disable") {
            if (t.initializer.kind === ts.SyntaxKind.TrueKeyword) entry.hidden = true;
          }
        }
      }
    }
  }
  void sourceFile;
  return entry;
}

/* ------------------------------------------------------------------ */
/*  Format detection                                                   */
/* ------------------------------------------------------------------ */

function detectFormat(_obj: ts.ObjectLiteralExpression | undefined, sourceFile: ts.SourceFile): StoriesInfo["format"] {
  const text = sourceFile.text;
  // Storybook 10 CSF Factories: `import { defineMeta } from ...` or `meta.story(...)`
  if (/\bdefineMeta\s*\(/.test(text) || /\bmeta\.story\s*\(/.test(text)) return "csf-factories";
  // CSF3: `satisfies Meta<...>` or `: Meta<...>` plus named story exports as objects
  if (/\bsatisfies\s+Meta\b/.test(text) || /:\s*Meta<[^>]+>/.test(text)) return "csf3";
  // CSF2: `storiesOf(...)` or `Story.args = {...}` pattern
  if (/\bstoriesOf\s*\(/.test(text) || /\.args\s*=\s*\{/.test(text)) return "csf2";
  if (sourceFile.fileName.endsWith(".mdx")) return "mdx";
  return "unknown";
}

/* ------------------------------------------------------------------ */
/*  Helpers                                                            */
/* ------------------------------------------------------------------ */

function propertyKeyName(name: ts.PropertyName): string | undefined {
  if (ts.isIdentifier(name)) return name.text;
  if (ts.isStringLiteral(name)) return name.text;
  if (ts.isNumericLiteral(name)) return name.text;
  return undefined;
}

function readStringLiteral(expr: ts.Expression): string | undefined {
  if (ts.isStringLiteral(expr)) return expr.text;
  if (ts.isNoSubstitutionTemplateLiteral(expr)) return expr.text;
  return undefined;
}

function readStringArray(expr: ts.Expression): string[] | undefined {
  if (!ts.isArrayLiteralExpression(expr)) return undefined;
  const out: string[] = [];
  for (const el of expr.elements) {
    const s = readStringLiteral(el);
    if (s !== undefined) out.push(s);
  }
  return out;
}

function readObjectAsRecord(expr: ts.Expression, sourceFile: ts.SourceFile): Record<string, unknown> | undefined {
  if (!ts.isObjectLiteralExpression(expr)) return undefined;
  const out: Record<string, unknown> = {};
  for (const prop of expr.properties) {
    if (!ts.isPropertyAssignment(prop)) continue;
    const key = propertyKeyName(prop.name);
    if (!key) continue;
    out[key] = literalValue(prop.initializer, sourceFile);
  }
  return out;
}

/**
 * Best-effort literal evaluation. Strings, numbers, booleans, null, arrays,
 * and nested objects come out as their JS equivalents. Anything that requires
 * runtime evaluation (function refs, JSX, identifier references) is preserved
 * as a `{ __raw: "<source>" }` marker so callers can show it without
 * pretending it's a value.
 */
function literalValue(expr: ts.Expression, sourceFile: ts.SourceFile): unknown {
  if (ts.isStringLiteral(expr) || ts.isNoSubstitutionTemplateLiteral(expr)) return expr.text;
  if (ts.isNumericLiteral(expr)) return Number(expr.text);
  if (expr.kind === ts.SyntaxKind.TrueKeyword) return true;
  if (expr.kind === ts.SyntaxKind.FalseKeyword) return false;
  if (expr.kind === ts.SyntaxKind.NullKeyword) return null;
  if (ts.isArrayLiteralExpression(expr)) return expr.elements.map((e) => literalValue(e, sourceFile));
  if (ts.isObjectLiteralExpression(expr)) return readObjectAsRecord(expr, sourceFile);
  if (ts.isPrefixUnaryExpression(expr) && expr.operator === ts.SyntaxKind.MinusToken && ts.isNumericLiteral(expr.operand)) {
    return -Number(expr.operand.text);
  }
  return { __raw: PRINTER.printNode(ts.EmitHint.Unspecified, expr, sourceFile).replace(/\s+/g, " ").trim() };
}

function isExported(node: ts.Node): boolean {
  if (!ts.canHaveModifiers(node)) return false;
  return ts.getModifiers(node)?.some((m) => m.kind === ts.SyntaxKind.ExportKeyword) ?? false;
}

/**
 * Locate the meta object's `title:` property *node* — exposed for the
 * structural rename API. Returns the property's text-range so callers can
 * splice a new value in place without re-printing the file.
 */
export function locateMetaTitleNode(filePath: string): { start: number; end: number; current: string } | undefined {
  const source = readFileSync(filePath, "utf8");
  const sourceFile = ts.createSourceFile(filePath, source, ts.ScriptTarget.ES2022, true, scriptKindOf(filePath));
  const meta = findMetaObject(sourceFile);
  if (!meta) return undefined;
  for (const prop of meta.objectLiteral.properties) {
    if (!ts.isPropertyAssignment(prop)) continue;
    if (propertyKeyName(prop.name) !== "title") continue;
    const init = prop.initializer;
    if (!ts.isStringLiteral(init) && !ts.isNoSubstitutionTemplateLiteral(init)) return undefined;
    return { start: init.getStart(sourceFile), end: init.getEnd(), current: init.text };
  }
  return undefined;
  void path;
}
