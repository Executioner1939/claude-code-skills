/**
 * Find every file that consumes a given component.
 *
 * "Consumes" means one of:
 *   - import-and-jsx — imports the name AND renders it as JSX
 *   - import-only    — imports the name but never renders it (might be using
 *                       the type, or re-exporting)
 *   - type-only      — only `import type { Foo }` references
 *
 * Implementation uses `@ast-grep/napi` directly so we get structural matches
 * (no false positives on string literals or comments). Falls back to text
 * search if napi isn't installed yet (typical CI / cold-clone environments).
 */

import { readFile } from "node:fs/promises";
import path from "node:path";
import fg from "fast-glob";
import type { ConsumerRef } from "./types.js";

export interface FindConsumersOptions {
  /** Component identifier — the named export (e.g. `Button`). */
  name: string;
  /** Project root the scan covers. Absolute. */
  root: string;
  /** Path of the component being searched for — used to skip self-references. */
  selfPath: string;
  /** Globs to scan; defaults to typical TS/TSX trees. */
  include?: string[];
  /** Globs to skip. */
  exclude?: string[];
  /** Override the discovery mechanism — `auto` (try napi, fall back), `napi`, or `text`. */
  mode?: "auto" | "napi" | "text";
}

const DEFAULT_INCLUDES = [
  "src/**/*.{ts,tsx,jsx}",
  "apps/*/src/**/*.{ts,tsx,jsx}",
  "apps/*/app/**/*.{ts,tsx,jsx}",
  "packages/*/src/**/*.{ts,tsx,jsx}",
];

const DEFAULT_EXCLUDES = [
  "**/node_modules/**",
  "**/dist/**",
  "**/build/**",
  "**/.next/**",
  "**/storybook-static/**",
  "**/__tests__/**",
  "**/*.test.{ts,tsx}",
  "**/*.spec.{ts,tsx}",
  "**/*.stories.{ts,tsx,jsx}",
];

export async function findConsumers(opts: FindConsumersOptions): Promise<ConsumerRef[]> {
  const include = opts.include ?? DEFAULT_INCLUDES;
  const exclude = opts.exclude ?? DEFAULT_EXCLUDES;
  const files = await fg(include, {
    cwd: opts.root,
    absolute: true,
    onlyFiles: true,
    ignore: exclude,
  });

  const mode = opts.mode ?? "auto";
  const useNapi = mode === "napi" || (mode === "auto" && (await hasAstGrepNapi()));
  const consumers: ConsumerRef[] = [];

  for (const file of files) {
    if (path.resolve(file) === path.resolve(opts.selfPath)) continue;
    const ref = useNapi
      ? await classifyConsumerWithNapi(file, opts.name)
      : await classifyConsumerWithText(file, opts.name);
    if (ref) consumers.push({ path: path.relative(opts.root, file), kind: ref });
  }

  return consumers.sort((a, b) => a.path.localeCompare(b.path));
}

/* ------------------------------------------------------------------ */
/*  napi backend                                                       */
/* ------------------------------------------------------------------ */

let napiAvailable: boolean | undefined;

async function hasAstGrepNapi(): Promise<boolean> {
  if (napiAvailable !== undefined) return napiAvailable;
  try {
    await import("@ast-grep/napi");
    napiAvailable = true;
  } catch {
    napiAvailable = false;
  }
  return napiAvailable;
}

async function classifyConsumerWithNapi(file: string, name: string): Promise<ConsumerRef["kind"] | undefined> {
  // Lazy-import so the text fallback path doesn't need napi installed.
  const mod = await import("@ast-grep/napi");
  const napi = mod as unknown as {
    parse: (lang: unknown, source: string) => { root: () => { findAll: (q: { rule: object } | string) => unknown[] } };
    Lang: { Tsx: unknown; TypeScript: unknown };
  };
  const source = await readFile(file, "utf8");
  const lang = file.endsWith(".tsx") || file.endsWith(".jsx") ? napi.Lang.Tsx : napi.Lang.TypeScript;
  const root = napi.parse(lang, source).root();

  // 1. Type-only import? `import type { Name } from "..."` or `import { type Name } from "..."`
  const typeOnlyImports = root.findAll({
    rule: { pattern: `import type { $$$NAMES } from $SRC` },
  });
  let hasTypeOnlyImport = false;
  for (const m of typeOnlyImports) {
    if (matchHasIdentifier(m, name)) {
      hasTypeOnlyImport = true;
      break;
    }
  }

  // 2. Value import? `import { Name } from "..."`
  const valueImports = root.findAll({
    rule: { pattern: `import { $$$NAMES } from $SRC` },
  });
  let hasValueImport = false;
  for (const m of valueImports) {
    if (matchHasIdentifier(m, name)) {
      hasValueImport = true;
      break;
    }
  }

  if (!hasValueImport && !hasTypeOnlyImport) return undefined;

  // 3. JSX usage? <Name ... /> or <Name>
  if (hasValueImport) {
    const jsxOpen = root.findAll({ rule: { pattern: `<${name} $$$ />` } });
    const jsxBlock = root.findAll({ rule: { pattern: `<${name} $$$>$$$</${name}>` } });
    if (jsxOpen.length > 0 || jsxBlock.length > 0) return "import-and-jsx";
    return "import-only";
  }

  return "type-only";
}

function matchHasIdentifier(match: unknown, name: string): boolean {
  // The ast-grep napi match has `text()` for the matched range and `getMultipleMatches` /
  // `getMatch` for metavariables. We bail out to a text check on the matched range
  // because the napi binding's metavariable typing varies between versions.
  const m = match as { text?: () => string };
  if (typeof m.text === "function") {
    const text = m.text();
    return new RegExp(`(^|[^A-Za-z0-9_])${escapeRegex(name)}([^A-Za-z0-9_]|$)`).test(text);
  }
  return false;
}

/* ------------------------------------------------------------------ */
/*  text fallback                                                      */
/* ------------------------------------------------------------------ */

async function classifyConsumerWithText(file: string, name: string): Promise<ConsumerRef["kind"] | undefined> {
  const source = await readFile(file, "utf8");
  // Strip line + block comments to avoid false positives on doc references.
  const stripped = source
    .replace(/\/\*[\s\S]*?\*\//g, " ")
    .replace(/(^|\s)\/\/.*$/gm, "$1");

  const importRegex = new RegExp(
    `import\\s+(type\\s+)?\\{[^}]*\\b${escapeRegex(name)}\\b[^}]*\\}\\s+from\\s+["'][^"']+["']`,
  );
  const importMatch = stripped.match(importRegex);
  if (!importMatch) return undefined;
  const isTypeOnly = Boolean(importMatch[1]);

  if (isTypeOnly) return "type-only";

  // JSX usage: <Name ... or <Name> or <Name/
  const jsxRegex = new RegExp(`<${escapeRegex(name)}(\\s|/|>)`);
  if (jsxRegex.test(stripped)) return "import-and-jsx";
  return "import-only";
}

function escapeRegex(s: string): string {
  return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}
