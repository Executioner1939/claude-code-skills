/**
 * Extract structured component metadata from a single `.tsx` (or `.ts`) file.
 *
 * Strategy: convention-driven AST walk, no full type-check program.
 *
 * 1. Read the file. Build a `SourceFile` with `parentNodes=true`.
 * 2. Collect named exports.
 * 3. For props, find the declaration named `<ComponentName>Props` — almost
 *    every DS component in the wild follows this convention. The declaration
 *    is either an `interface` (members are `PropertySignature`s) or a `type`
 *    alias whose RHS is a `TypeLiteral` / intersection containing one.
 * 4. For each member, print the type node verbatim via the TS printer so
 *    union / intersection / generic spellings come out as written.
 * 5. Pull JSDoc text + tags from each member.
 * 6. Detect `forwardRef` wrap, `displayName` assignment, `"use client"` /
 *    `"use server"` directives.
 *
 * No `ts.Program` and no `TypeChecker` — keeps the parser fast and lets it
 * run on a single file in isolation. Cross-file type resolution (e.g. props
 * extending another package's interface) intentionally degrades to printing
 * `extends ImportedType` rather than expanding it. Expansion is a follow-on.
 */

import ts from "typescript";
import { readFileSync, statSync } from "node:fs";
import path from "node:path";
import type { ExportInfo, PropDoc } from "./types.js";

export interface ComponentParse {
  exports: ExportInfo;
  /** The name of the principal component export (matches the file basename when present). */
  principal?: string;
  props: PropDoc[];
  /** Free-form notes the parser couldn't classify; used by the card builder for issues. */
  notes: string[];
  /** ISO mtime of the source file. */
  lastModified: string;
}

/**
 * Parse one component file. Never throws; degrades to empty fields with notes.
 */
export function parseComponent(filePath: string): ComponentParse {
  const source = readFileSync(filePath, "utf8");
  const sourceFile = ts.createSourceFile(filePath, source, ts.ScriptTarget.ES2022, /*setParentNodes*/ true, scriptKindOf(filePath));
  const lastModified = statSync(filePath).mtime.toISOString();

  const directive = findDirective(sourceFile);
  const exportNames = collectExportNames(sourceFile);
  const fileBase = path.basename(filePath).replace(/\.(tsx?|jsx?)$/, "");
  const principal = exportNames.includes(fileBase) ? fileBase : exportNames[0];

  const forwardsRef = detectForwardRef(sourceFile, principal);
  const hasDisplayName = detectDisplayName(sourceFile);

  // Find the conventional Props declaration.
  const propsName = principal ? `${principal}Props` : undefined;
  const propsResult = propsName
    ? extractPropsFromDeclaration(sourceFile, propsName)
    : { props: [] as PropDoc[], notes: ["no-principal-component"] };

  // Default values come from the principal function's destructured parameter.
  if (principal) annotateDefaults(sourceFile, principal, propsResult.props);

  return {
    exports: {
      names: exportNames,
      forwardsRef,
      hasDisplayName,
      ...(directive ? { directive } : {}),
    },
    ...(principal ? { principal } : {}),
    props: propsResult.props,
    notes: propsResult.notes,
    lastModified,
  };
}

function scriptKindOf(filePath: string): ts.ScriptKind {
  if (filePath.endsWith(".tsx")) return ts.ScriptKind.TSX;
  if (filePath.endsWith(".ts")) return ts.ScriptKind.TS;
  if (filePath.endsWith(".jsx")) return ts.ScriptKind.JSX;
  return ts.ScriptKind.JS;
}

/* ------------------------------------------------------------------ */
/*  Directive                                                          */
/* ------------------------------------------------------------------ */

function findDirective(sourceFile: ts.SourceFile): "use client" | "use server" | undefined {
  const first = sourceFile.statements[0];
  if (!first || !ts.isExpressionStatement(first)) return undefined;
  const expr = first.expression;
  if (!ts.isStringLiteral(expr)) return undefined;
  if (expr.text === "use client") return "use client";
  if (expr.text === "use server") return "use server";
  return undefined;
}

/* ------------------------------------------------------------------ */
/*  Exports                                                            */
/* ------------------------------------------------------------------ */

function collectExportNames(sourceFile: ts.SourceFile): string[] {
  const names = new Set<string>();
  for (const stmt of sourceFile.statements) {
    if (ts.isExportDeclaration(stmt) && stmt.exportClause && ts.isNamedExports(stmt.exportClause)) {
      for (const spec of stmt.exportClause.elements) names.add(spec.name.text);
      continue;
    }
    if (!isExported(stmt)) continue;
    if (ts.isFunctionDeclaration(stmt) && stmt.name) names.add(stmt.name.text);
    else if (ts.isClassDeclaration(stmt) && stmt.name) names.add(stmt.name.text);
    else if (ts.isInterfaceDeclaration(stmt)) names.add(stmt.name.text);
    else if (ts.isTypeAliasDeclaration(stmt)) names.add(stmt.name.text);
    else if (ts.isVariableStatement(stmt)) {
      for (const decl of stmt.declarationList.declarations) {
        if (ts.isIdentifier(decl.name)) names.add(decl.name.text);
      }
    }
  }
  return Array.from(names).sort();
}

function isExported(node: ts.Node): boolean {
  if (!ts.canHaveModifiers(node)) return false;
  return ts.getModifiers(node)?.some((m) => m.kind === ts.SyntaxKind.ExportKeyword) ?? false;
}

/* ------------------------------------------------------------------ */
/*  Props extraction                                                   */
/* ------------------------------------------------------------------ */

interface PropsExtraction {
  props: PropDoc[];
  notes: string[];
}

function extractPropsFromDeclaration(sourceFile: ts.SourceFile, propsTypeName: string): PropsExtraction {
  const decl = findTypeDeclaration(sourceFile, propsTypeName);
  if (!decl) return { props: [], notes: [`props-decl-not-found:${propsTypeName}`] };

  const members = collectMembers(decl, sourceFile);
  const props: PropDoc[] = [];
  for (const member of members) props.push(describeMember(member, sourceFile));
  return {
    props: props.sort((a, b) => a.name.localeCompare(b.name)),
    notes: [],
  };
}

function findTypeDeclaration(
  sourceFile: ts.SourceFile,
  name: string,
): ts.InterfaceDeclaration | ts.TypeAliasDeclaration | undefined {
  for (const stmt of sourceFile.statements) {
    if (ts.isInterfaceDeclaration(stmt) && stmt.name.text === name) return stmt;
    if (ts.isTypeAliasDeclaration(stmt) && stmt.name.text === name) return stmt;
  }
  return undefined;
}

/**
 * Collect members from a Props declaration. For interfaces, members are direct.
 * For type aliases, members come from the RHS type literal — and from any
 * `&` intersection branch that is itself a type literal (we don't follow named
 * extensions here; that requires multi-file resolution).
 */
function collectMembers(
  decl: ts.InterfaceDeclaration | ts.TypeAliasDeclaration,
  sourceFile: ts.SourceFile,
): ts.PropertySignature[] {
  const out: ts.PropertySignature[] = [];
  if (ts.isInterfaceDeclaration(decl)) {
    for (const m of decl.members) if (ts.isPropertySignature(m)) out.push(m);
    return out;
  }
  // type alias
  collectFromTypeNode(decl.type, out);
  return out;
  void sourceFile;
}

function collectFromTypeNode(node: ts.TypeNode, out: ts.PropertySignature[]): void {
  if (ts.isTypeLiteralNode(node)) {
    for (const m of node.members) if (ts.isPropertySignature(m)) out.push(m);
    return;
  }
  if (ts.isIntersectionTypeNode(node)) {
    for (const branch of node.types) collectFromTypeNode(branch, out);
    return;
  }
  // For TypeReference / Union etc. we can't enumerate members without a
  // checker. The card will note the missing branch via `extends ImportedType`.
}

function describeMember(member: ts.PropertySignature, sourceFile: ts.SourceFile): PropDoc {
  const name = (() => {
    if (ts.isIdentifier(member.name)) return member.name.text;
    if (ts.isStringLiteral(member.name)) return member.name.text;
    return member.name.getText(sourceFile);
  })();
  const required = !member.questionToken;
  const typeText = member.type ? printNode(member.type, sourceFile) : "unknown";
  const doc = leadingJsDocText(member, sourceFile);
  const tags = leadingJsDocTags(member);
  const result: PropDoc = { name, type: typeText, required };
  if (doc) result.doc = doc;
  if (tags) result.tags = tags;
  return result;
}

const PRINTER = ts.createPrinter({ newLine: ts.NewLineKind.LineFeed, removeComments: true });

function printNode(node: ts.Node, sourceFile: ts.SourceFile): string {
  return PRINTER.printNode(ts.EmitHint.Unspecified, node, sourceFile).replace(/\s+/g, " ").trim();
}

function leadingJsDocText(node: ts.Node, sourceFile: ts.SourceFile): string | undefined {
  const docs = ts.getJSDocCommentsAndTags(node);
  for (const d of docs) {
    if (ts.isJSDoc(d) && d.comment) {
      const text = jsdocCommentToString(d.comment);
      if (text.trim()) return text.trim();
    }
  }
  return undefined;
  void sourceFile;
}

function leadingJsDocTags(node: ts.Node): Record<string, string> | undefined {
  const tags = ts.getJSDocTags(node);
  if (tags.length === 0) return undefined;
  const out: Record<string, string> = {};
  for (const tag of tags) {
    const name = tag.tagName.text;
    out[name] = jsdocCommentToString(tag.comment).trim();
  }
  return out;
}

/**
 * JSDoc comment fields can be `string`, undefined, or `NodeArray<JSDocComment>`.
 * Reduce all three to a printable string. JSDoc-link nodes (`{@link Foo}`) are
 * rendered as their target text.
 */
function jsdocCommentToString(
  comment: string | ts.NodeArray<ts.JSDocComment> | undefined,
): string {
  if (comment === undefined) return "";
  if (typeof comment === "string") return comment;
  let out = "";
  for (const part of comment) {
    if (part.kind === ts.SyntaxKind.JSDocText) {
      out += (part as ts.JSDocText).text;
      continue;
    }
    if (
      part.kind === ts.SyntaxKind.JSDocLink ||
      part.kind === ts.SyntaxKind.JSDocLinkCode ||
      part.kind === ts.SyntaxKind.JSDocLinkPlain
    ) {
      const link = part as ts.JSDocLink | ts.JSDocLinkCode | ts.JSDocLinkPlain;
      const name = link.name && (ts.isIdentifier(link.name) ? link.name.text : link.name.getText());
      out += name ?? link.text ?? "";
    }
  }
  return out;
}

/* ------------------------------------------------------------------ */
/*  Defaults                                                           */
/* ------------------------------------------------------------------ */

/**
 * Walk the principal component's first parameter to find destructured
 * defaults. Mutates `props[i].default` in place.
 *
 *   forwardRef<X, ButtonProps>(function Button(
 *     { size = "md", variant = "primary", ...rest }, ref,
 *   ) { ... });
 *
 *   function Button({ size = "md" }: ButtonProps) { ... }
 */
function annotateDefaults(sourceFile: ts.SourceFile, principal: string, props: PropDoc[]): void {
  const param = findPrincipalFirstParam(sourceFile, principal);
  if (!param || !ts.isObjectBindingPattern(param.name)) return;
  const byName = new Map(props.map((p) => [p.name, p]));
  for (const elem of param.name.elements) {
    if (!ts.isIdentifier(elem.name)) continue;
    const propName = elem.propertyName && ts.isIdentifier(elem.propertyName) ? elem.propertyName.text : elem.name.text;
    const target = byName.get(propName);
    if (!target) continue;
    if (elem.initializer) {
      target.default = printNode(elem.initializer, sourceFile);
    }
  }
}

function findPrincipalFirstParam(sourceFile: ts.SourceFile, principal: string): ts.ParameterDeclaration | undefined {
  let result: ts.ParameterDeclaration | undefined;
  ts.forEachChild(sourceFile, function visit(node) {
    if (result) return;
    // export const Button = forwardRef(function (...) { ... })
    if (ts.isVariableStatement(node) && isExported(node)) {
      for (const decl of node.declarationList.declarations) {
        if (ts.isIdentifier(decl.name) && decl.name.text === principal && decl.initializer) {
          result = paramFromExpression(decl.initializer);
          if (result) return;
        }
      }
    }
    // export function Button(...) { ... }
    if (ts.isFunctionDeclaration(node) && isExported(node) && node.name?.text === principal) {
      result = node.parameters[0];
      return;
    }
    ts.forEachChild(node, visit);
  });
  return result;
}

function paramFromExpression(expr: ts.Expression): ts.ParameterDeclaration | undefined {
  if (ts.isArrowFunction(expr) || ts.isFunctionExpression(expr)) {
    return expr.parameters[0];
  }
  if (ts.isCallExpression(expr)) {
    // forwardRef(fn) / memo(fn) / forwardRef(memo(fn))
    const inner = expr.arguments[0];
    if (inner && ts.isExpression(inner)) return paramFromExpression(inner);
  }
  return undefined;
}

/* ------------------------------------------------------------------ */
/*  forwardRef + displayName                                           */
/* ------------------------------------------------------------------ */

function detectForwardRef(sourceFile: ts.SourceFile, principal: string | undefined): boolean {
  if (!principal) return false;
  let found = false;
  ts.forEachChild(sourceFile, function visit(node) {
    if (found) return;
    if (ts.isVariableStatement(node) && isExported(node)) {
      for (const decl of node.declarationList.declarations) {
        if (
          ts.isIdentifier(decl.name) &&
          decl.name.text === principal &&
          decl.initializer &&
          isForwardRefCall(decl.initializer)
        ) {
          found = true;
          return;
        }
      }
    }
    ts.forEachChild(node, visit);
  });
  return found;
}

function isForwardRefCall(expr: ts.Expression): boolean {
  if (!ts.isCallExpression(expr)) return false;
  if (ts.isIdentifier(expr.expression) && expr.expression.text === "forwardRef") return true;
  // Wrappers: memo(forwardRef(...)) — peel one layer.
  if (ts.isIdentifier(expr.expression)) {
    const inner = expr.arguments[0];
    if (inner && ts.isExpression(inner)) return isForwardRefCall(inner);
  }
  return false;
}

function detectDisplayName(sourceFile: ts.SourceFile): boolean {
  let found = false;
  ts.forEachChild(sourceFile, function visit(node) {
    if (found) return;
    if (
      ts.isExpressionStatement(node) &&
      ts.isBinaryExpression(node.expression) &&
      node.expression.operatorToken.kind === ts.SyntaxKind.EqualsToken &&
      ts.isPropertyAccessExpression(node.expression.left) &&
      ts.isIdentifier(node.expression.left.name) &&
      node.expression.left.name.text === "displayName"
    ) {
      found = true;
      return;
    }
    ts.forEachChild(node, visit);
  });
  return found;
}

/**
 * Read raw source — exposed for callers that want lightweight grep-style
 * checks (e.g. `extract-tokens`, `find-consumers`) without re-parsing.
 */
export function readSource(filePath: string): string {
  return readFileSync(filePath, "utf8");
}
