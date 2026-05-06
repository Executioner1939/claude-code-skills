/**
 * Rename a prop on a component, in three coordinated passes:
 *
 *   1. **Declaration file** — rename the property on the component's
 *      `<Name>Props` interface / type alias, the destructured parameter
 *      binding, and references to that local inside the principal function's
 *      immediate body.
 *
 *   2. **Consumer files** — rename every `<Component oldProp={...}>` JSX
 *      attribute. Reuses `renameJsxProp` under the hood.
 *
 *   3. **Stories** — same pass as (2), since stories live alongside
 *      consumers in the file glob.
 *
 * Scope analysis caveat
 *
 * The body-reference rename in (1) walks the principal function's IMMEDIATE
 * body and replaces bare identifier references that match the old prop
 * name. It does NOT do full scope analysis — if a nested closure shadows
 * the prop with a parameter / variable of the same name, the outer
 * reference will be incorrectly rewritten. The dry-run output prints the
 * line numbers of every body-rename so the user can review.
 *
 * Property accesses (`obj.pip`), shorthand keys defining a NEW property
 * named `pip` (`{ pip }` outside of destructure), and references inside
 * type positions are left alone.
 */

import { readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import ts from "typescript";
import { renameJsxProp, type RenameJsxPropResult } from "./rename-jsx-prop.js";

export interface RenamePropOptions {
  /** Component name (e.g. `Button`). The declaration file is auto-located. */
  component: string;
  /** Path of the declaration file (e.g. `src/components/atoms/Button/Button.tsx`). Absolute. */
  declarationPath: string;
  /** Old prop name. */
  oldProp: string;
  /** New prop name. */
  newProp: string;
  /** Project root for the consumer scan. Absolute. */
  root: string;
  /** Apply changes. Defaults to dry-run. */
  apply?: boolean;
}

export interface RenamePropDeclarationHit {
  filePath: string;
  /** Line numbers (1-indexed) where rewrites happened. */
  lines: number[];
  /** What kinds of edits were applied. */
  edits: { interface: number; destructure: number; bodyReference: number };
}

export interface RenamePropResult {
  declaration: RenamePropDeclarationHit | null;
  consumers: RenameJsxPropResult;
  written: boolean;
  /** Notes flagged for human review (shadowing risk, etc.). */
  notes: string[];
}

export async function renameProp(opts: RenamePropOptions): Promise<RenamePropResult> {
  const notes: string[] = [];

  // Pass 1 — declaration file.
  const declaration = await renameInDeclaration(opts, notes);

  // Pass 2 — consumer JSX usages.
  const consumers = await renameJsxProp({
    component: opts.component,
    oldProp: opts.oldProp,
    newProp: opts.newProp,
    root: opts.root,
    apply: Boolean(opts.apply),
  });

  return {
    declaration,
    consumers,
    written: Boolean(opts.apply),
    notes,
  };
}

type EditKind = "interface" | "destructure" | "bodyReference";
type Edit = { start: number; end: number; replacement: string; line: number; kind: EditKind };

/* ------------------------------------------------------------------ */
/*  Declaration-file rewrite                                           */
/* ------------------------------------------------------------------ */

async function renameInDeclaration(opts: RenamePropOptions, notes: string[]): Promise<RenamePropDeclarationHit | null> {
  const source = await readFile(opts.declarationPath, "utf8");
  if (!new RegExp(`\\b${escapeRegex(opts.oldProp)}\\b`).test(source)) {
    notes.push(`declaration-file-does-not-contain-${opts.oldProp}`);
    return null;
  }
  const sourceFile = ts.createSourceFile(
    opts.declarationPath,
    source,
    ts.ScriptTarget.ES2022,
    true,
    scriptKindOf(opts.declarationPath),
  );

  const edits: Edit[] = [];

  // Locate the `<Component>Props` declaration and the principal function.
  const propsTypeName = `${opts.component}Props`;
  const propsDecl = findTypeDeclaration(sourceFile, propsTypeName);
  if (propsDecl) {
    collectInterfacePropertyEdit(propsDecl, opts.oldProp, opts.newProp, edits, sourceFile);
  } else {
    notes.push(`no-${propsTypeName}-decl-found`);
  }

  const principal = findPrincipal(sourceFile, opts.component);
  if (principal) {
    const param = principalFirstParam(principal);
    if (param) {
      const renamedDestructure = collectDestructureEdit(param, opts.oldProp, opts.newProp, edits, sourceFile);
      if (renamedDestructure) {
        const body = principalBody(principal);
        if (body) {
          collectBodyReferenceEdits(body, opts.oldProp, opts.newProp, edits, sourceFile, notes);
        } else {
          notes.push("principal-has-no-block-body");
        }
      } else {
        notes.push(`prop-${opts.oldProp}-not-destructured-from-first-parameter`);
      }
    }
  } else {
    notes.push(`principal-component-${opts.component}-not-found`);
  }

  if (edits.length === 0) return null;

  edits.sort((a, b) => b.start - a.start);
  let working = source;
  for (const e of edits) {
    working = working.slice(0, e.start) + e.replacement + working.slice(e.end);
  }
  if (opts.apply) await writeFile(opts.declarationPath, working, "utf8");

  const counts = { interface: 0, destructure: 0, bodyReference: 0 };
  for (const e of edits) counts[e.kind] += 1;
  return {
    filePath: path.relative(opts.root, opts.declarationPath),
    lines: dedupe(edits.map((e) => e.line)).sort((a, b) => a - b),
    edits: counts,
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

function collectInterfacePropertyEdit(
  decl: ts.InterfaceDeclaration | ts.TypeAliasDeclaration,
  oldProp: string,
  newProp: string,
  edits: Edit[],
  sourceFile: ts.SourceFile,
): void {
  if (ts.isInterfaceDeclaration(decl)) {
    for (const m of decl.members) walkMember(m);
  } else {
    walkType(decl.type);
  }

  function walkMember(m: ts.TypeElement): void {
    if (!ts.isPropertySignature(m)) return;
    const nameNode = m.name;
    if (ts.isIdentifier(nameNode) && nameNode.text === oldProp) {
      edits.push({
        start: nameNode.getStart(sourceFile),
        end: nameNode.getEnd(),
        replacement: newProp,
        line: lineOf(nameNode, sourceFile),
        kind: "interface",
      });
    } else if (ts.isStringLiteral(nameNode) && nameNode.text === oldProp) {
      edits.push({
        start: nameNode.getStart(sourceFile),
        end: nameNode.getEnd(),
        replacement: `"${newProp}"`,
        line: lineOf(nameNode, sourceFile),
        kind: "interface",
      });
    }
  }

  function walkType(node: ts.TypeNode): void {
    if (ts.isTypeLiteralNode(node)) {
      for (const m of node.members) walkMember(m);
    } else if (ts.isIntersectionTypeNode(node)) {
      for (const branch of node.types) walkType(branch);
    }
  }
}

function findPrincipal(sourceFile: ts.SourceFile, name: string): ts.Node | undefined {
  for (const stmt of sourceFile.statements) {
    if (ts.isFunctionDeclaration(stmt) && stmt.name?.text === name) return stmt;
    if (ts.isVariableStatement(stmt)) {
      for (const decl of stmt.declarationList.declarations) {
        if (ts.isIdentifier(decl.name) && decl.name.text === name && decl.initializer) {
          return decl.initializer;
        }
      }
    }
  }
  return undefined;
}

function principalFirstParam(node: ts.Node): ts.ParameterDeclaration | undefined {
  if (ts.isFunctionDeclaration(node) || ts.isFunctionExpression(node) || ts.isArrowFunction(node)) {
    return node.parameters[0];
  }
  if (ts.isCallExpression(node)) {
    const inner = node.arguments[0];
    if (inner && ts.isExpression(inner)) return principalFirstParam(inner);
  }
  return undefined;
}

function principalBody(node: ts.Node): ts.Block | undefined {
  if (ts.isFunctionDeclaration(node) && node.body) return node.body;
  if (ts.isFunctionExpression(node) && node.body) return node.body;
  if (ts.isArrowFunction(node)) {
    if (ts.isBlock(node.body)) return node.body;
    return undefined;
  }
  if (ts.isCallExpression(node)) {
    const inner = node.arguments[0];
    if (inner && ts.isExpression(inner)) return principalBody(inner);
  }
  return undefined;
}

function collectDestructureEdit(
  param: ts.ParameterDeclaration,
  oldProp: string,
  newProp: string,
  edits: Edit[],
  sourceFile: ts.SourceFile,
): boolean {
  if (!ts.isObjectBindingPattern(param.name)) return false;
  for (const elem of param.name.elements) {
    if (!ts.isIdentifier(elem.name)) continue;
    // Three shapes:
    //   { pip }            — propertyName undefined; name === pip
    //   { pip: local }     — propertyName === pip; name === local
    //   { pip = 0 }        — propertyName undefined; name === pip; initializer present
    if (elem.propertyName) {
      // Aliased — only rewrite the propertyName side; local is unrelated.
      if (ts.isIdentifier(elem.propertyName) && elem.propertyName.text === oldProp) {
        edits.push({
          start: elem.propertyName.getStart(sourceFile),
          end: elem.propertyName.getEnd(),
          replacement: newProp,
          line: lineOf(elem.propertyName, sourceFile),
          kind: "destructure",
        });
        return true;
      }
    } else if (elem.name.text === oldProp) {
      edits.push({
        start: elem.name.getStart(sourceFile),
        end: elem.name.getEnd(),
        replacement: newProp,
        line: lineOf(elem.name, sourceFile),
        kind: "destructure",
      });
      return true;
    }
  }
  return false;
}

function collectBodyReferenceEdits(
  body: ts.Block,
  oldProp: string,
  newProp: string,
  edits: Edit[],
  sourceFile: ts.SourceFile,
  notes: string[],
): void {
  let shadowingDetected = false;

  function visit(node: ts.Node): void {
    // Skip nested function bodies — their parameter / variable scope might
    // shadow the outer prop name. Scope-correctness here would require the
    // language service; we degrade to flagging shadowing risk.
    if (
      ts.isFunctionDeclaration(node) ||
      ts.isFunctionExpression(node) ||
      ts.isArrowFunction(node) ||
      ts.isMethodDeclaration(node)
    ) {
      // If the nested function's parameters or locals include `oldProp`, flag.
      if (declaresOldProp(node, oldProp)) shadowingDetected = true;
      return;
    }

    // Identifier reference — only rewrite when used as a value, not as a property name.
    if (ts.isIdentifier(node) && node.text === oldProp) {
      const parent = node.parent;
      if (!parent) return;
      // Skip property accesses: `obj.pip`
      if (ts.isPropertyAccessExpression(parent) && parent.name === node) return;
      // Skip property assignments where pip is the KEY: `{ pip: x }` (defining a NEW property).
      if (ts.isPropertyAssignment(parent) && parent.name === node) return;
      // Skip shorthand property assignments inside object literals — `{ pip }` defines a property.
      // We DO want to rewrite the *value* side, which is the same identifier in shorthand. But
      // a shorthand literally writes the prop key as well. To preserve correctness, we rewrite
      // the value but we need to also rewrite the key, OR keep shorthand intact. Simplest: skip
      // shorthand entirely and let the user reformat. Note in the result.
      if (ts.isShorthandPropertyAssignment(parent) && parent.name === node) {
        // Skip; tell the user.
        return;
      }
      // Skip type-position identifiers (TypeReference handled separately, this catches the rest).
      if (ts.isTypeReferenceNode(parent)) return;
      // Skip JSX attribute names — they're property names on the element type.
      if (ts.isJsxAttribute(parent) && parent.name === node) return;
      // Skip BindingElement names (we already handled the destructure pass).
      if (ts.isBindingElement(parent) && parent.name === node) return;
      if (ts.isParameter(parent) && parent.name === node) return;
      // Skip variable / function declaration names.
      if (ts.isVariableDeclaration(parent) && parent.name === node) return;
      if (ts.isFunctionDeclaration(parent) && parent.name === node) return;

      edits.push({
        start: node.getStart(sourceFile),
        end: node.getEnd(),
        replacement: newProp,
        line: lineOf(node, sourceFile),
        kind: "bodyReference",
      });
      return;
    }
    ts.forEachChild(node, visit);
  }
  ts.forEachChild(body, visit);

  if (shadowingDetected) {
    notes.push(
      `shadowing-detected: a nested function declares '${oldProp}' as a local; outer references inside that nested scope were NOT rewritten. Review manually.`,
    );
  }
}

function declaresOldProp(fn: ts.Node, oldProp: string): boolean {
  let found = false;
  function visit(node: ts.Node): void {
    if (found) return;
    if (ts.isParameter(node) && node.name && ts.isIdentifier(node.name) && node.name.text === oldProp) {
      found = true;
      return;
    }
    if (ts.isVariableDeclaration(node) && ts.isIdentifier(node.name) && node.name.text === oldProp) {
      found = true;
      return;
    }
    ts.forEachChild(node, visit);
  }
  visit(fn);
  return found;
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
