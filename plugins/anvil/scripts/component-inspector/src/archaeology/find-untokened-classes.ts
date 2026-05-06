/**
 * Surface className tokens that don't map to a recognised design-token alias.
 *
 * Two suspicion levels:
 *
 *   1. **Arbitrary value classes** — `m-[3px]`, `bg-[#ffaa00]`, `text-[14px]`,
 *      `gap-[7px]`, etc. These deliberately bypass the token system. Always
 *      flagged.
 *
 *   2. **Custom-named classes** — anything that isn't a Tailwind utility we
 *      recognise (no known prefix) and isn't a project-allowed CSS class
 *      (passed via `allow`). These are typically project-local CSS module
 *      class names that the agent should review — they may be deliberate,
 *      but they're invisible to the token system.
 *
 * Layout-utility usage (`flex flex-col gap-4`) is intentionally NOT flagged
 * here — that's `find-raw-html`'s domain (recommend `<Stack>` instead).
 *
 * The known prefix list mirrors `extract-tokens.ts` so additions there
 * propagate here automatically.
 */

import type { ArchaeologyMatch, BodyNode, ComponentTree } from "../types.js";
import { walkElements } from "../parse-body-tree.js";

const KNOWN_PREFIXES = [
  // Colour
  "text-", "bg-", "border-", "fill-", "stroke-", "ring-", "outline-", "decoration-", "divide-", "accent-", "caret-",
  "from-", "to-", "via-",
  // Spacing
  "p-", "px-", "py-", "pt-", "pr-", "pb-", "pl-", "m-", "mx-", "my-", "mt-", "mr-", "mb-", "ml-",
  "gap-", "space-x-", "space-y-",
  "inset-", "top-", "right-", "bottom-", "left-",
  // Sizing
  "w-", "h-", "min-w-", "min-h-", "max-w-", "max-h-", "size-",
  // Radius / shadow / motion
  "rounded-", "shadow-", "duration-", "ease-", "delay-",
  // Type
  "font-", "leading-", "tracking-", "indent-", "align-", "whitespace-",
  // z-index
  "z-",
  // Layout (flex / grid)
  "flex-", "grid-", "col-", "row-", "items-", "justify-", "place-", "content-", "self-",
  "basis-", "grow-", "shrink-", "order-",
  // Position / display / overflow
  "object-", "overflow-", "overscroll-", "translate-", "rotate-", "scale-", "skew-", "origin-",
  "transform-", "transition-", "animate-", "opacity-",
  // Misc
  "cursor-", "pointer-events-", "select-", "list-", "appearance-", "scroll-",
];

// Single-word utilities that are always allowed (display, position, etc.).
const KNOWN_BARE = new Set([
  "flex", "block", "inline", "inline-block", "inline-flex", "grid", "inline-grid", "hidden", "table", "flow-root",
  "static", "relative", "absolute", "fixed", "sticky",
  "visible", "invisible", "collapse",
  "italic", "not-italic", "uppercase", "lowercase", "capitalize", "normal-case", "underline", "overline",
  "line-through", "no-underline", "antialiased", "subpixel-antialiased",
  "truncate", "break-words", "break-all", "break-keep", "break-normal",
  "container",
  "isolate", "isolation-auto",
  "rounded", "shadow", "border", "outline",
  "transition", "transform", "filter", "backdrop-filter",
  "sr-only", "not-sr-only",
  "first", "last", "even", "odd",
  "row", "col",
]);

const ARBITRARY_VALUE = /^[a-z][a-z0-9-]*-\[[^\]]+\]$/;

export interface FindUntokenedOptions {
  /**
   * Project-specific allow list. Class names appearing here are not flagged.
   * Useful for global CSS classes a project expects to see (e.g. `prose`).
   */
  allow?: string[];
  /** Skip the arbitrary-value check (rare). */
  ignoreArbitrary?: boolean;
}

export function findUntokenedClasses(tree: ComponentTree, opts: FindUntokenedOptions = {}): ArchaeologyMatch[] {
  if (!tree.root) return [];
  const allow = new Set(opts.allow ?? []);
  const matches: ArchaeologyMatch[] = [];
  for (const el of walkElements(tree.root)) {
    if (!el.className) continue;
    for (const token of el.className.tokens) {
      const verdict = classify(token, allow, opts.ignoreArbitrary === true);
      if (!verdict) continue;
      matches.push({
        node: el,
        ruleId: verdict.ruleId,
        reason: `${verdict.reason}: '${token}'`,
      });
    }
    // Raw className fragments — e.g. clsx args we couldn't statically split.
    // Surface as low-severity hint so the agent knows there's hidden state.
    for (const raw of el.className.raw) {
      matches.push({
        node: el,
        ruleId: "untokened-raw-class",
        reason: `className contains an unresolved expression: ${truncate(raw, 100)}`,
      });
    }
  }
  return dedupeByLoc(matches);
}

function classify(
  token: string,
  allow: Set<string>,
  ignoreArbitrary: boolean,
): { ruleId: string; reason: string } | undefined {
  if (allow.has(token)) return undefined;
  // Strip variant prefix (hover:, md:, dark:, ...).
  const bare = token.split(":").pop() ?? token;
  if (allow.has(bare)) return undefined;

  if (!ignoreArbitrary && ARBITRARY_VALUE.test(bare)) {
    return { ruleId: "arbitrary-value-class", reason: "Arbitrary value bypasses the design token system" };
  }
  if (KNOWN_BARE.has(bare)) return undefined;
  for (const prefix of KNOWN_PREFIXES) {
    if (bare.startsWith(prefix)) return undefined;
  }
  return { ruleId: "untokened-class", reason: "Class is neither a known utility nor in the project allow-list" };
}

function dedupeByLoc(matches: ArchaeologyMatch[]): ArchaeologyMatch[] {
  const seen = new Set<string>();
  const out: ArchaeologyMatch[] = [];
  for (const m of matches) {
    const key = `${m.ruleId}:${nodeLocKey(m.node)}:${m.reason ?? ""}`;
    if (seen.has(key)) continue;
    seen.add(key);
    out.push(m);
  }
  return out;
}

function nodeLocKey(node: BodyNode): string {
  return `${node.loc.line}:${node.loc.col}`;
}

function truncate(s: string, n: number): string {
  return s.length > n ? `${s.slice(0, n - 1)}…` : s;
}
