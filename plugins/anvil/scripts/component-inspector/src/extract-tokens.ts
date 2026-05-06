/**
 * Token usage extraction.
 *
 * From a single component source file, surface:
 *   - Every `var(--*)` reference (CSS-in-JS, inline styles, template strings).
 *   - Every Tailwind class fragment that *looks* token-aliased (e.g.
 *     `bg-accent`, `text-text-muted`, `border-border-default`,
 *     `rounded-md`, `font-heading`). These are recognised by a curated set of
 *     prefixes — adding a new theme alias is one line below.
 *   - Every hard-coded literal that should be a token: `#hex`, `rgb(...)`,
 *     `rgba(...)`, `0px`/`16px`/`1.5rem`-style lengths, `0 0 8px ...`-style
 *     shadows, `cubic-bezier(...)` motion easing, `200ms`/`0.2s` durations.
 *
 * Limitations:
 *   - We don't load Tailwind config to resolve `bg-accent` → token name. That
 *     resolution happens in a follow-on; for now the alias name is recorded
 *     so the agent can map it.
 *   - Literals inside import statements, strings that look like file paths,
 *     and `0` / `1` numeric defaults are filtered out (high false-positive
 *     rate otherwise).
 */

import { readFileSync } from "node:fs";
import path from "node:path";
import type { TokenLiteral, TokenUsage } from "./types.js";

const TAILWIND_TOKEN_PREFIXES = [
  // Colour
  "text-",
  "bg-",
  "border-",
  "fill-",
  "stroke-",
  "ring-",
  "outline-",
  "decoration-",
  "divide-",
  "accent-",
  "caret-",
  "from-",
  "to-",
  "via-",
  // Spacing
  "p-",
  "px-",
  "py-",
  "pt-",
  "pr-",
  "pb-",
  "pl-",
  "m-",
  "mx-",
  "my-",
  "mt-",
  "mr-",
  "mb-",
  "ml-",
  "gap-",
  "space-x-",
  "space-y-",
  // Sizing — only when the value looks token-aliased rather than numeric.
  "w-",
  "h-",
  "min-w-",
  "min-h-",
  "max-w-",
  "max-h-",
  // Radius / shadow / motion
  "rounded-",
  "shadow-",
  "duration-",
  "ease-",
  // Type
  "font-",
  "leading-",
  "tracking-",
  "text-",
  // z-index
  "z-",
];

// Tailwind utilities that are *layout primitives* — agents should reach for
// <Stack> / <Row> / <Grid> instead of these in DS code. The card builder
// surfaces these as a `raw-tailwind-layout` issue.
export const RAW_LAYOUT_FRAGMENTS = [
  /\bflex\s+flex-col\b/,
  /\bflex\s+flex-row\b/,
  /\bgrid\s+grid-cols-\d+\b/,
  /\bgap-\d+\b/,
];

const HEX_COLOR = /(?<![A-Za-z0-9])#(?:[0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})\b/g;
const RGB_COLOR = /\b(?:rgba?|hsla?|hwb|lab|lch|oklab|oklch)\s*\([^)]+\)/g;
const LENGTH_LITERAL = /\b\d+(?:\.\d+)?(?:px|rem|em|vw|vh|svh|svw|dvh|dvw|%|ch|ex|fr)\b/g;
const DURATION_LITERAL = /\b\d+(?:\.\d+)?(?:ms|s)\b/g;
const SHADOW_LITERAL = /\b(?:0|\d+px)\s+\d+px\s+\d+px(?:\s+\d+px)?\s+(?:rgba?|#)/g;
const CSS_VAR = /var\(\s*(--[A-Za-z0-9-_]+)/g;
const EASING_LITERAL = /cubic-bezier\s*\([^)]+\)/g;

export function extractTokens(filePath: string, projectRoot: string): TokenUsage {
  const source = readFileSync(filePath, "utf8");
  const stripped = stripComments(source);
  const relPath = path.relative(projectRoot, filePath);

  return {
    cssVars: collectCssVars(stripped),
    tailwindAliases: collectTailwindAliases(stripped),
    literals: collectLiterals(stripped, relPath),
  };
}

/* ------------------------------------------------------------------ */
/*  CSS variables                                                      */
/* ------------------------------------------------------------------ */

function collectCssVars(source: string): string[] {
  const out = new Set<string>();
  let match: RegExpExecArray | null;
  CSS_VAR.lastIndex = 0;
  while ((match = CSS_VAR.exec(source))) {
    if (match[1]) out.add(match[1]);
  }
  return Array.from(out).sort();
}

/* ------------------------------------------------------------------ */
/*  Tailwind aliases                                                   */
/* ------------------------------------------------------------------ */

const CLASS_STRING = /(?:className|class)\s*=\s*(?:["'`]([^"'`]+)["'`]|\{[^{}]*?["'`]([^"'`]+)["'`])/g;
const CLSX_STRING = /(?:clsx|cn|cx|twMerge)\s*\(([^()]*(?:\([^()]*\)[^()]*)*)\)/g;

function collectTailwindAliases(source: string): string[] {
  const candidates = new Set<string>();
  for (const match of source.matchAll(CLASS_STRING)) {
    const text = match[1] ?? match[2];
    if (text) collectClassFragments(text, candidates);
  }
  for (const match of source.matchAll(CLSX_STRING)) {
    const inner = match[1] ?? "";
    for (const lit of inner.matchAll(/["'`]([^"'`]+)["'`]/g)) {
      if (lit[1]) collectClassFragments(lit[1], candidates);
    }
  }
  return Array.from(candidates).sort();
}

function collectClassFragments(classString: string, out: Set<string>): void {
  for (const cls of classString.split(/\s+/)) {
    if (!cls) continue;
    // Skip arbitrary-value classes — `bg-[#fff]` is a literal, not a token.
    if (cls.includes("[") && cls.includes("]")) continue;
    // Strip variant prefix (hover:, md:, dark:, etc.) for the token check.
    const bare = cls.split(":").pop() ?? cls;
    for (const prefix of TAILWIND_TOKEN_PREFIXES) {
      if (!bare.startsWith(prefix)) continue;
      const value = bare.slice(prefix.length);
      // Plain integer values like `gap-4` are spacing tokens — keep.
      // Pure numbers without suffix (e.g. `w-4`) aren't aliases per se but they
      // do reference the spacing scale, so we still record them.
      if (!value) continue;
      out.add(bare);
      break;
    }
  }
}

/* ------------------------------------------------------------------ */
/*  Hard-coded literals                                                */
/* ------------------------------------------------------------------ */

function collectLiterals(source: string, relPath: string): TokenLiteral[] {
  const out: TokenLiteral[] = [];
  const lines = source.split(/\r?\n/);

  const checks: Array<{ kind: string; pattern: RegExp; predicate?: (text: string, lineText: string) => boolean }> = [
    { kind: "color", pattern: HEX_COLOR, predicate: notInImport },
    { kind: "color", pattern: RGB_COLOR, predicate: notInImport },
    { kind: "shadow", pattern: SHADOW_LITERAL },
    { kind: "easing", pattern: EASING_LITERAL },
    {
      kind: "length",
      pattern: LENGTH_LITERAL,
      predicate: (text, lineText) => notInImport(text, lineText) && notTrivialLength(text, lineText),
    },
    {
      kind: "duration",
      pattern: DURATION_LITERAL,
      predicate: (text, lineText) => notInImport(text, lineText) && notTrivialDuration(text),
    },
  ];

  for (let i = 0; i < lines.length; i += 1) {
    const lineText = lines[i] ?? "";
    for (const check of checks) {
      check.pattern.lastIndex = 0;
      let m: RegExpExecArray | null;
      while ((m = check.pattern.exec(lineText))) {
        const value = m[0];
        if (check.predicate && !check.predicate(value, lineText)) continue;
        out.push({ path: relPath, line: i + 1, kind: check.kind, value });
      }
    }
  }
  return out;
}

function notInImport(_value: string, lineText: string): boolean {
  return !/^\s*(?:import|export)\s/.test(lineText);
}

function notTrivialLength(value: string, lineText: string): boolean {
  // `0px`, `1px` are usually borders/dividers — still flag.
  // Skip sourcemap / data-uri values inside string literals where the line
  // already contains `data:` or `http://`.
  if (/data:|https?:\/\//.test(lineText)) return false;
  void value;
  return true;
}

function notTrivialDuration(value: string): boolean {
  // `0s` and `0ms` are used as initial-state animation values; skip.
  if (/^0(?:ms|s)$/.test(value)) return false;
  return true;
}

/* ------------------------------------------------------------------ */
/*  Comment stripping                                                  */
/* ------------------------------------------------------------------ */

/**
 * Strip line + block comments without a full parse. We retain newlines so
 * the line numbers line up with the original source.
 */
function stripComments(source: string): string {
  let out = "";
  let i = 0;
  while (i < source.length) {
    const c = source[i];
    const next = source[i + 1];
    if (c === "/" && next === "/") {
      while (i < source.length && source[i] !== "\n") i += 1;
      continue;
    }
    if (c === "/" && next === "*") {
      i += 2;
      while (i < source.length && !(source[i] === "*" && source[i + 1] === "/")) {
        out += source[i] === "\n" ? "\n" : " ";
        i += 1;
      }
      i += 2;
      continue;
    }
    out += c ?? "";
    i += 1;
  }
  return out;
}
