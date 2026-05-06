/**
 * Build a recursive `BodyNode` tree describing what a component renders.
 *
 * Strategy:
 *   1. Re-parse the file (no checker; ScriptKind detection identical to
 *      `parse-component`).
 *   2. Find the principal export — same convention as `parse-component`:
 *      the variable / function whose name matches the file basename, or
 *      the first exported binding.
 *   3. Locate the principal's function body. For arrow / function
 *      expressions wrapped in `forwardRef(...)` or `memo(...)`, peel one
 *      layer.
 *   4. Walk every JSXElement / JSXFragment that is a `return` value of the
 *      function (including conditional returns inside if/else, switch, and
 *      ternary). If multiple returns produce JSX, combine under a synthetic
 *      fragment. The single-return case (overwhelmingly common) emits the
 *      one tree directly.
 *   5. Recurse: for every JSX child, build its sub-tree. Expression
 *      containers (`{cond && <X/>}`) become `ExpressionNode`s with their
 *      nested JSX as children, so archaeology queries still see the
 *      structural shape inside conditionals.
 *
 * The parser is read-only and never throws — degraded output is `null` root
 * with a non-empty `notes` array.
 */

import ts from "typescript";
import { readFileSync } from "node:fs";
import path from "node:path";
import type {
  AttrNode,
  BodyNode,
  ClassNameInfo,
  ComponentTree,
  ElementNode,
  ExpressionNode,
  FragmentNode,
  NodeLoc,
  TextNode,
} from "./types.js";

const PRINTER = ts.createPrinter({ newLine: ts.NewLineKind.LineFeed, removeComments: true });

const HTML_ELEMENTS = new Set([
  "a", "abbr", "address", "area", "article", "aside", "audio", "b", "bdi", "bdo", "blockquote", "body", "br",
  "button", "canvas", "caption", "cite", "code", "col", "colgroup", "data", "datalist", "dd", "del", "details",
  "dfn", "dialog", "div", "dl", "dt", "em", "embed", "fieldset", "figcaption", "figure", "footer", "form", "h1",
  "h2", "h3", "h4", "h5", "h6", "head", "header", "hgroup", "hr", "html", "i", "iframe", "img", "input", "ins",
  "kbd", "label", "legend", "li", "link", "main", "map", "mark", "menu", "meta", "meter", "nav", "noscript",
  "object", "ol", "optgroup", "option", "output", "p", "param", "picture", "pre", "progress", "q", "rp", "rt",
  "ruby", "s", "samp", "script", "search", "section", "select", "slot", "small", "source", "span", "strong",
  "style", "sub", "summary", "sup", "table", "tbody", "td", "template", "textarea", "tfoot", "th", "thead",
  "time", "title", "tr", "track", "u", "ul", "var", "video", "wbr",
]);

export interface ParseBodyTreeOptions {
  /** Project root for relative path normalisation in the output. Optional. */
  projectRoot?: string;
}

export function parseBodyTree(filePath: string, opts: ParseBodyTreeOptions = {}): ComponentTree {
  const source = readFileSync(filePath, "utf8");
  const sourceFile = ts.createSourceFile(filePath, source, ts.ScriptTarget.ES2022, true, scriptKindOf(filePath));
  const file = opts.projectRoot ? path.relative(opts.projectRoot, filePath) : filePath;
  const notes: string[] = [];

  const fileBase = path.basename(filePath).replace(/\.(tsx?|jsx?)$/, "");
  const principal = findPrincipal(sourceFile, fileBase);
  if (!principal) {
    notes.push("no-principal-export");
    return { file, componentName: fileBase, root: null, notes };
  }

  const body = principalBody(principal.expr);
  if (!body) {
    notes.push(`principal-${principal.name}-has-no-function-body`);
    return { file, componentName: principal.name, root: null, notes };
  }

  const returns = collectReturnExpressions(body);
  const jsxRoots = returns
    .map((expr) => unwrapToJsx(expr))
    .filter((n): n is ts.JsxElement | ts.JsxSelfClosingElement | ts.JsxFragment => Boolean(n));

  if (jsxRoots.length === 0) {
    notes.push(`principal-${principal.name}-returns-no-jsx`);
    return { file, componentName: principal.name, root: null, notes };
  }

  let root: BodyNode;
  if (jsxRoots.length === 1) {
    const single = jsxRoots[0];
    if (!single) {
      notes.push("principal-returns-empty-array");
      return { file, componentName: principal.name, root: null, notes };
    }
    root = buildNode(single, sourceFile);
  } else {
    notes.push(`principal-has-${jsxRoots.length}-returns-merged-into-fragment`);
    const first = jsxRoots[0]!;
    const fragment: FragmentNode = {
      kind: "fragment",
      loc: locOf(first, sourceFile),
      children: jsxRoots.map((j) => buildNode(j, sourceFile)),
    };
    root = fragment;
  }

  return { file, componentName: principal.name, root, notes };
}

/* ------------------------------------------------------------------ */
/*  Principal lookup                                                   */
/* ------------------------------------------------------------------ */

interface PrincipalRef {
  name: string;
  /** The expression that *is* the component (function / arrow / forwardRef call / etc.). */
  expr: ts.Node;
}

function findPrincipal(sourceFile: ts.SourceFile, fileBase: string): PrincipalRef | undefined {
  // Pass 1: variable named like the file basename.
  for (const stmt of sourceFile.statements) {
    if (!ts.isVariableStatement(stmt) || !isExported(stmt)) continue;
    for (const decl of stmt.declarationList.declarations) {
      if (ts.isIdentifier(decl.name) && decl.name.text === fileBase && decl.initializer) {
        return { name: fileBase, expr: decl.initializer };
      }
    }
  }
  // Pass 2: function declaration named like the file basename.
  for (const stmt of sourceFile.statements) {
    if (ts.isFunctionDeclaration(stmt) && isExported(stmt) && stmt.name?.text === fileBase) {
      return { name: fileBase, expr: stmt };
    }
  }
  // Pass 3: first exported binding that has an initializer / function body.
  for (const stmt of sourceFile.statements) {
    if (ts.isVariableStatement(stmt) && isExported(stmt)) {
      for (const decl of stmt.declarationList.declarations) {
        if (ts.isIdentifier(decl.name) && decl.initializer) {
          return { name: decl.name.text, expr: decl.initializer };
        }
      }
    }
    if (ts.isFunctionDeclaration(stmt) && isExported(stmt) && stmt.name) {
      return { name: stmt.name.text, expr: stmt };
    }
  }
  return undefined;
}

function isExported(node: ts.Node): boolean {
  if (!ts.canHaveModifiers(node)) return false;
  return ts.getModifiers(node)?.some((m) => m.kind === ts.SyntaxKind.ExportKeyword) ?? false;
}

function principalBody(expr: ts.Node): ts.Block | undefined {
  if (ts.isFunctionDeclaration(expr) && expr.body) return expr.body;
  if (ts.isFunctionExpression(expr) && expr.body) return expr.body;
  if (ts.isArrowFunction(expr)) {
    if (ts.isBlock(expr.body)) return expr.body;
    // Arrow with concise body — wrap into a synthetic single return so the
    // collector below picks up the JSX expression.
    return ts.factory.createBlock([ts.factory.createReturnStatement(expr.body)]);
  }
  if (ts.isCallExpression(expr)) {
    // forwardRef(fn), memo(fn), forwardRef(memo(fn))
    const inner = expr.arguments[0];
    if (inner && ts.isExpression(inner)) return principalBody(inner);
  }
  return undefined;
}

/* ------------------------------------------------------------------ */
/*  Return-expression collection                                       */
/* ------------------------------------------------------------------ */

function collectReturnExpressions(body: ts.Block): ts.Expression[] {
  const out: ts.Expression[] = [];
  function visit(node: ts.Node): void {
    if (ts.isReturnStatement(node) && node.expression) {
      out.push(node.expression);
      return;
    }
    // Don't descend into nested function bodies — those are helpers, not the
    // component's own return value.
    if (
      ts.isFunctionDeclaration(node) ||
      ts.isFunctionExpression(node) ||
      ts.isArrowFunction(node) ||
      ts.isMethodDeclaration(node)
    ) {
      return;
    }
    ts.forEachChild(node, visit);
  }
  ts.forEachChild(body, visit);
  return out;
}

function unwrapToJsx(expr: ts.Expression): ts.JsxElement | ts.JsxSelfClosingElement | ts.JsxFragment | undefined {
  if (ts.isJsxElement(expr) || ts.isJsxSelfClosingElement(expr) || ts.isJsxFragment(expr)) return expr;
  if (ts.isParenthesizedExpression(expr)) return unwrapToJsx(expr.expression);
  if (ts.isAsExpression(expr)) return unwrapToJsx(expr.expression);
  if (ts.isSatisfiesExpression(expr)) return unwrapToJsx(expr.expression);
  if (ts.isConditionalExpression(expr)) {
    // `cond ? <A/> : <B/>` — pick the first JSX branch we find. Both branches
    // contribute to "what the component renders" so we treat them as siblings
    // when merged at the synthetic-fragment level above.
    return unwrapToJsx(expr.whenTrue) ?? unwrapToJsx(expr.whenFalse);
  }
  return undefined;
}

/* ------------------------------------------------------------------ */
/*  JSX → BodyNode                                                     */
/* ------------------------------------------------------------------ */

function buildNode(node: ts.Node, sourceFile: ts.SourceFile): BodyNode {
  if (ts.isJsxElement(node)) return buildElement(node.openingElement, node.children, sourceFile);
  if (ts.isJsxSelfClosingElement(node)) return buildElement(node, [], sourceFile);
  if (ts.isJsxFragment(node)) {
    const fragment: FragmentNode = {
      kind: "fragment",
      loc: locOf(node, sourceFile),
      children: buildChildren(node.children, sourceFile),
    };
    return fragment;
  }
  if (ts.isJsxText(node)) {
    const text = node.text.replace(/\s+/g, " ").trim();
    return { kind: "text", loc: locOf(node, sourceFile), text };
  }
  if (ts.isJsxExpression(node)) {
    const raw = node.expression ? printNode(node.expression, sourceFile) : "";
    const nested: BodyNode[] = [];
    if (node.expression) collectNestedJsx(node.expression, sourceFile, nested);
    const expr: ExpressionNode = { kind: "expression", loc: locOf(node, sourceFile), raw, children: nested };
    return expr;
  }
  // Anything else: treat as text holding the source slice.
  return { kind: "text", loc: locOf(node, sourceFile), text: printNode(node, sourceFile) };
}

function buildElement(
  opening: ts.JsxOpeningElement | ts.JsxSelfClosingElement,
  children: ts.NodeArray<ts.JsxChild> | ts.JsxChild[],
  sourceFile: ts.SourceFile,
): ElementNode {
  const tag = printTagName(opening.tagName, sourceFile);
  const tagKind = classifyTag(opening.tagName);
  const attrs = readAttributes(opening, sourceFile);
  const className = extractClassName(attrs);
  return {
    kind: "element",
    tag,
    tagKind,
    loc: locOf(opening, sourceFile),
    attrs,
    className,
    children: buildChildren(children, sourceFile),
  };
}

function buildChildren(children: ts.NodeArray<ts.JsxChild> | ts.JsxChild[], sourceFile: ts.SourceFile): BodyNode[] {
  const out: BodyNode[] = [];
  for (const child of children) {
    if (ts.isJsxText(child)) {
      const trimmed = child.text.replace(/\s+/g, " ").trim();
      if (!trimmed) continue;
      out.push({ kind: "text", loc: locOf(child, sourceFile), text: trimmed });
      continue;
    }
    out.push(buildNode(child, sourceFile));
  }
  return out;
}

function readAttributes(
  opening: ts.JsxOpeningElement | ts.JsxSelfClosingElement,
  sourceFile: ts.SourceFile,
): AttrNode[] {
  const out: AttrNode[] = [];
  for (const attr of opening.attributes.properties) {
    if (ts.isJsxSpreadAttribute(attr)) {
      out.push({
        name: "...rest",
        kind: "spread",
        raw: printNode(attr, sourceFile),
      });
      continue;
    }
    if (!ts.isJsxAttribute(attr)) continue;
    const name = ts.isIdentifier(attr.name) ? attr.name.text : attr.name.getText(sourceFile);
    if (!attr.initializer) {
      out.push({ name, kind: "boolean", raw: name });
      continue;
    }
    if (ts.isStringLiteral(attr.initializer)) {
      out.push({
        name,
        kind: "static",
        raw: `${name}=${attr.initializer.getText(sourceFile)}`,
        value: attr.initializer.text,
      });
      continue;
    }
    if (ts.isJsxExpression(attr.initializer)) {
      const raw = `${name}=${attr.initializer.getText(sourceFile)}`;
      const expr = attr.initializer.expression;
      const node: AttrNode = { name, kind: "expression", raw };
      if (expr && ts.isStringLiteral(expr)) {
        node.kind = "static";
        node.value = expr.text;
      } else if (expr && ts.isNoSubstitutionTemplateLiteral(expr)) {
        node.kind = "static";
        node.value = expr.text;
      }
      out.push(node);
    }
  }
  return out;
}

/**
 * Resolve the className value when statically derivable. Splits string
 * literals on whitespace; collects clsx/cn/cx/twMerge args if recognisable;
 * otherwise records the whole expression as a single `raw` fragment.
 */
function extractClassName(attrs: AttrNode[]): ClassNameInfo | null {
  const attr = attrs.find((a) => a.name === "className" || a.name === "class");
  if (!attr) return null;

  const tokens: string[] = [];
  const raw: string[] = [];

  if (attr.kind === "static" && attr.value !== undefined) {
    pushTokens(attr.value, tokens);
  } else if (attr.kind === "expression") {
    // Strip the leading `className=` and trailing braces from `raw` to leave
    // the inner expression text. We then look for clsx/cn-style calls and
    // pluck out string-literal args; any other content goes to `raw`.
    const inner = stripExpressionWrapper(attr.raw);
    const inspected = tryClassExpression(inner, tokens, raw);
    if (!inspected) raw.push(inner);
  }

  return { tokens: dedupe(tokens), raw };
}

function stripExpressionWrapper(text: string): string {
  // text looks like `className={ ... }` or `className="..."`. Take the part
  // after the first `=` and strip surrounding `{...}` or `"..."`.
  const eq = text.indexOf("=");
  let inner = eq === -1 ? text : text.slice(eq + 1).trim();
  if (inner.startsWith("{") && inner.endsWith("}")) inner = inner.slice(1, -1).trim();
  else if (inner.startsWith('"') && inner.endsWith('"')) inner = inner.slice(1, -1);
  else if (inner.startsWith("'") && inner.endsWith("'")) inner = inner.slice(1, -1);
  else if (inner.startsWith("`") && inner.endsWith("`")) inner = inner.slice(1, -1);
  return inner;
}

const CLSX_CALL = /^(?:clsx|cn|cx|classNames|twMerge)\s*\((.*)\)$/s;

function tryClassExpression(text: string, tokens: string[], raw: string[]): boolean {
  const trimmed = text.trim();
  // Plain string literal
  if (/^["'`].*["'`]$/.test(trimmed)) {
    const inner = trimmed.slice(1, -1);
    pushTokens(inner, tokens);
    return true;
  }
  const m = trimmed.match(CLSX_CALL);
  if (!m || !m[1]) return false;
  // Walk the args: pull string-literal args, push the rest verbatim.
  const args = splitTopLevelArgs(m[1]);
  for (const arg of args) {
    const a = arg.trim();
    if (/^["'`].*["'`]$/.test(a)) {
      pushTokens(a.slice(1, -1), tokens);
    } else {
      raw.push(a);
    }
  }
  return true;
}

function pushTokens(value: string, tokens: string[]): void {
  for (const t of value.split(/\s+/)) {
    if (t) tokens.push(t);
  }
}

function splitTopLevelArgs(text: string): string[] {
  // Split on commas that are at depth 0 outside of strings.
  const out: string[] = [];
  let buf = "";
  let depth = 0;
  let str: '"' | "'" | "`" | null = null;
  for (let i = 0; i < text.length; i += 1) {
    const c = text[i];
    if (str) {
      buf += c;
      if (c === str && text[i - 1] !== "\\") str = null;
      continue;
    }
    if (c === '"' || c === "'" || c === "`") {
      str = c as '"' | "'" | "`";
      buf += c;
      continue;
    }
    if (c === "(" || c === "{" || c === "[") depth += 1;
    else if (c === ")" || c === "}" || c === "]") depth -= 1;
    if (c === "," && depth === 0) {
      out.push(buf);
      buf = "";
      continue;
    }
    buf += c ?? "";
  }
  if (buf.trim().length > 0) out.push(buf);
  return out;
}

/* ------------------------------------------------------------------ */
/*  Tag classification + formatting                                    */
/* ------------------------------------------------------------------ */

function printTagName(name: ts.JsxTagNameExpression, sourceFile: ts.SourceFile): string {
  return name.getText(sourceFile);
}

function classifyTag(name: ts.JsxTagNameExpression): ElementNode["tagKind"] {
  if (ts.isIdentifier(name)) {
    const text = name.text;
    if (HTML_ELEMENTS.has(text)) return "html";
    // Lowercase identifiers that aren't in the HTML list are still rendered
    // as raw HTML by React (e.g. custom elements like `<my-thing>`). Treat
    // them as `html` so archaeology queries that look for "raw HTML" catch
    // them.
    if (text[0] && text[0] === text[0].toLowerCase()) return "html";
    return "component";
  }
  if (ts.isPropertyAccessExpression(name)) return "member";
  return "dynamic";
}

/* ------------------------------------------------------------------ */
/*  Helpers                                                            */
/* ------------------------------------------------------------------ */

function locOf(node: ts.Node, sourceFile: ts.SourceFile): NodeLoc {
  const { line, character } = sourceFile.getLineAndCharacterOfPosition(node.getStart(sourceFile));
  return { line: line + 1, col: character + 1 };
}

function printNode(node: ts.Node, sourceFile: ts.SourceFile): string {
  return PRINTER.printNode(ts.EmitHint.Unspecified, node, sourceFile).replace(/\s+/g, " ").trim();
}

function collectNestedJsx(node: ts.Node, sourceFile: ts.SourceFile, out: BodyNode[]): void {
  if (
    ts.isJsxElement(node) ||
    ts.isJsxSelfClosingElement(node) ||
    ts.isJsxFragment(node)
  ) {
    out.push(buildNode(node, sourceFile));
    return;
  }
  // Don't descend into nested function expressions — they're not part of
  // *this* component's render.
  if (ts.isArrowFunction(node) || ts.isFunctionExpression(node)) {
    if (ts.isArrowFunction(node) && !ts.isBlock(node.body)) {
      // Concise-body arrow (`x => <Foo/>`) — inspect the body for JSX.
      collectNestedJsx(node.body, sourceFile, out);
    }
    return;
  }
  ts.forEachChild(node, (child) => collectNestedJsx(child, sourceFile, out));
}

function dedupe<T>(arr: T[]): T[] {
  return Array.from(new Set(arr));
}

function scriptKindOf(filePath: string): ts.ScriptKind {
  if (filePath.endsWith(".tsx")) return ts.ScriptKind.TSX;
  if (filePath.endsWith(".ts")) return ts.ScriptKind.TS;
  if (filePath.endsWith(".jsx")) return ts.ScriptKind.JSX;
  return ts.ScriptKind.JS;
}

/* ------------------------------------------------------------------ */
/*  Recursive iterators                                                */
/* ------------------------------------------------------------------ */

/**
 * Yield every node in a tree (depth-first, including the root). Useful for
 * archaeology filters that test a predicate against each node.
 */
export function* walkNodes(node: BodyNode): Iterable<BodyNode> {
  yield node;
  if (node.kind === "element" || node.kind === "fragment" || node.kind === "expression") {
    for (const child of node.children) yield* walkNodes(child);
  }
}

/**
 * Yield only `ElementNode`s in a tree.
 */
export function* walkElements(node: BodyNode): Iterable<ElementNode> {
  for (const n of walkNodes(node)) {
    if (n.kind === "element") yield n;
  }
}
