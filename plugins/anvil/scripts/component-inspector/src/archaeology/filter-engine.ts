/**
 * Declarative filter DSL over `BodyNode` trees.
 *
 * A filter is a JSON object describing a predicate. Filters compose via
 * `any-of`, `all-of`, and `not`. The engine walks every node in a tree
 * (including nested expression containers) and tests the predicate against
 * each. Matches are returned in document order, deduped by source location.
 *
 * Primitives:
 *
 *   { "tag": "section" }
 *   { "tagPattern": "^Card" }                 // regex on tag name
 *   { "tagKind": "html" }
 *   { "classPattern": "^m[lrtbxy]?-\\[" }     // any className token matches
 *   { "rawClassPattern": "clsx\\(" }          // raw className fragment
 *   { "attr": "data-testid" }
 *   { "attrValue": { "name": "role", "pattern": "^button$" } }
 *
 * Compositors:
 *
 *   { "anyOf": [predicate, predicate] }
 *   { "allOf": [predicate, predicate] }
 *   { "not": predicate }
 *
 * Optional metadata on any predicate:
 *
 *   { "tag": "section", "ruleId": "raw-section",
 *     "reason": "Compose <Section> instead of a raw <section>." }
 *
 * The reason / ruleId travel with the match into the NDJSON `ArchaeologyRecord`.
 */

import type { ArchaeologyMatch, BodyNode, ComponentTree, ElementNode } from "../types.js";
import { walkNodes } from "../parse-body-tree.js";

export type FilterPredicate =
  | TagPredicate
  | TagPatternPredicate
  | TagKindPredicate
  | ClassPatternPredicate
  | RawClassPatternPredicate
  | AttrPredicate
  | AttrPatternPredicate
  | AttrValuePredicate
  | AnyOfPredicate
  | AllOfPredicate
  | NotPredicate;

interface CommonAnnotations {
  ruleId?: string;
  reason?: string;
}

interface TagPredicate extends CommonAnnotations {
  tag: string;
}
interface TagPatternPredicate extends CommonAnnotations {
  tagPattern: string;
}
interface TagKindPredicate extends CommonAnnotations {
  tagKind: ElementNode["tagKind"];
}
interface ClassPatternPredicate extends CommonAnnotations {
  classPattern: string;
}
interface RawClassPatternPredicate extends CommonAnnotations {
  rawClassPattern: string;
}
interface AttrPredicate extends CommonAnnotations {
  attr: string;
}
interface AttrPatternPredicate extends CommonAnnotations {
  attrPattern: string;
}
interface AttrValuePredicate extends CommonAnnotations {
  attrValue: { name: string; pattern: string };
}
interface AnyOfPredicate extends CommonAnnotations {
  anyOf: FilterPredicate[];
}
interface AllOfPredicate extends CommonAnnotations {
  allOf: FilterPredicate[];
}
interface NotPredicate extends CommonAnnotations {
  not: FilterPredicate;
}

/**
 * Apply a predicate to every node in a tree. Returns matches in document
 * order. Matches preserve the predicate's `ruleId` / `reason` annotations
 * so downstream tools can report them.
 */
export function findInTree(tree: ComponentTree, predicate: FilterPredicate): ArchaeologyMatch[] {
  if (!tree.root) return [];
  return findInNode(tree.root, predicate);
}

export function findInNode(root: BodyNode, predicate: FilterPredicate): ArchaeologyMatch[] {
  const matches: ArchaeologyMatch[] = [];
  for (const node of walkNodes(root)) {
    const m = matchOne(node, predicate);
    if (m) matches.push(m);
  }
  return matches;
}

function matchOne(node: BodyNode, predicate: FilterPredicate): ArchaeologyMatch | undefined {
  const verdict = evaluate(node, predicate);
  if (!verdict) return undefined;
  const out: ArchaeologyMatch = { node };
  // Outer-predicate annotations win over inner-branch annotations only when
  // the outer predicate itself sets them. For `anyOf`/`allOf` whose outer
  // shell carries no `ruleId`, the inner branch's annotation propagates —
  // this is what lets a preset with one wrapping `anyOf` of branches each
  // carrying `ruleId` and `reason` show its branch metadata downstream.
  const outerAnn = predicate as Partial<CommonAnnotations>;
  const ruleId = outerAnn.ruleId ?? verdict.ruleId;
  const reason = outerAnn.reason ?? verdict.reason;
  if (ruleId) out.ruleId = ruleId;
  if (reason) out.reason = reason;
  return out;
}

/* ------------------------------------------------------------------ */
/*  Evaluation                                                         */
/* ------------------------------------------------------------------ */

interface Verdict {
  matched: true;
  /** Annotations from the actual matching branch (innermost). */
  ruleId?: string;
  reason?: string;
}

function evaluate(node: BodyNode, predicate: FilterPredicate): Verdict | undefined {
  // Compositors carry their own optional annotations. If the wrapper sets
  // ruleId / reason, the wrapper wins; otherwise we fall through to whatever
  // the matched branch annotated.
  const wrapperAnn = predicate as Partial<CommonAnnotations>;
  const annotateWith = (inner: Verdict | undefined): Verdict | undefined => {
    if (!inner) return undefined;
    return {
      matched: true,
      ...(wrapperAnn.ruleId ? { ruleId: wrapperAnn.ruleId } : inner.ruleId ? { ruleId: inner.ruleId } : {}),
      ...(wrapperAnn.reason ? { reason: wrapperAnn.reason } : inner.reason ? { reason: inner.reason } : {}),
    };
  };

  if ("anyOf" in predicate) {
    for (const branch of predicate.anyOf) {
      const v = evaluate(node, branch);
      if (v) return annotateWith(v);
    }
    return undefined;
  }
  if ("allOf" in predicate) {
    let lastVerdict: Verdict | undefined;
    for (const branch of predicate.allOf) {
      const v = evaluate(node, branch);
      if (!v) return undefined;
      lastVerdict = v;
    }
    return annotateWith(lastVerdict ?? { matched: true });
  }
  if ("not" in predicate) {
    const inner = evaluate(node, predicate.not);
    return inner ? undefined : annotateWith({ matched: true });
  }

  // Leaf predicates — propagate the branch's own annotations.
  const ann = predicate as CommonAnnotations;
  const annotate = (matched: boolean): Verdict | undefined =>
    matched
      ? {
          matched: true,
          ...(ann.ruleId ? { ruleId: ann.ruleId } : {}),
          ...(ann.reason ? { reason: ann.reason } : {}),
        }
      : undefined;

  if ("tag" in predicate) return annotate(node.kind === "element" && node.tag === predicate.tag);
  if ("tagPattern" in predicate) {
    if (node.kind !== "element") return undefined;
    return annotate(new RegExp(predicate.tagPattern).test(node.tag));
  }
  if ("tagKind" in predicate) return annotate(node.kind === "element" && node.tagKind === predicate.tagKind);

  if ("classPattern" in predicate) {
    if (node.kind !== "element" || !node.className) return undefined;
    const re = new RegExp(predicate.classPattern);
    return annotate(node.className.tokens.some((t) => re.test(t)));
  }
  if ("rawClassPattern" in predicate) {
    if (node.kind !== "element" || !node.className) return undefined;
    const re = new RegExp(predicate.rawClassPattern);
    return annotate(node.className.raw.some((r) => re.test(r)));
  }
  if ("attr" in predicate) {
    if (node.kind !== "element") return undefined;
    return annotate(node.attrs.some((a) => a.name === predicate.attr));
  }
  if ("attrPattern" in predicate) {
    if (node.kind !== "element") return undefined;
    const re = new RegExp(predicate.attrPattern);
    return annotate(node.attrs.some((a) => re.test(a.name)));
  }
  if ("attrValue" in predicate) {
    if (node.kind !== "element") return undefined;
    const target = predicate.attrValue;
    const re = new RegExp(target.pattern);
    return annotate(node.attrs.some((a) => a.name === target.name && a.value !== undefined && re.test(a.value)));
  }
  return undefined;
}
