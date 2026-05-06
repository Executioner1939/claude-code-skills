/**
 * File discovery — locate component implementation files, story files, and
 * infer the atomic-design tier from the path.
 *
 * Component shapes recognised:
 *   <root>/<tier>/<Name>/<Name>.tsx
 *   <root>/<tier>/<Name>/index.tsx
 *   <root>/<tier>/<Name>.tsx          (flat layout)
 *
 * Tiers are inferred from any directory ancestor whose basename is one of:
 *   quarks/ atoms/ molecules/ organisms/ surfaces/ templates/ pages/
 *
 * Stories are matched as the sibling `<Name>.stories.{ts,tsx,jsx,js}` file.
 */

import path from "node:path";
import fg from "fast-glob";
import { existsSync, statSync } from "node:fs";
import type { Tier } from "./types.js";

const TIER_DIR: Record<string, Tier> = {
  quarks: "quark",
  atoms: "atom",
  molecules: "molecule",
  organisms: "organism",
  surfaces: "surface",
  templates: "template",
  pages: "page",
};

export interface DiscoveryHit {
  /** Component identifier — the basename without extension. */
  name: string;
  /** Atomic tier, inferred. `unknown` when the file lives outside a tiered tree. */
  tier: Tier;
  /** Absolute path to the implementation file. */
  filePath: string;
  /** Absolute path to the sibling stories file, if one exists. */
  storiesPath?: string;
  /** Absolute path to the component directory (containing the .tsx + .stories). */
  dir: string;
}

export interface DiscoverOptions {
  /** Project root to scan. Absolute path. */
  root: string;
  /**
   * Globs that limit the scan. Defaults to typical DS layouts.
   * Paths are interpreted relative to `root`.
   */
  include?: string[];
  /** Globs to exclude. Defaults exclude `node_modules`, build outputs, tests. */
  exclude?: string[];
}

const DEFAULT_INCLUDES = [
  // Scoped patterns first — match in typical project layouts.
  "src/components/**/*.{ts,tsx,jsx}",
  "packages/*/src/components/**/*.{ts,tsx,jsx}",
  "packages/*/src/{quarks,atoms,molecules,organisms,surfaces,templates,pages}/**/*.{ts,tsx,jsx}",
  // Generic atomic-tree fallback — catches fixtures, monorepos with custom roots,
  // and projects that put atoms outside of `src/`. Scoped enough that the tier
  // directory name itself anchors the match.
  "**/{quarks,atoms,molecules,organisms,surfaces,templates,pages}/**/*.{ts,tsx,jsx}",
];

const DEFAULT_EXCLUDES = [
  "**/node_modules/**",
  "**/dist/**",
  "**/build/**",
  "**/.next/**",
  "**/.storybook-static/**",
  "**/storybook-static/**",
  "**/*.test.{ts,tsx}",
  "**/*.spec.{ts,tsx}",
  "**/__tests__/**",
  "**/__mocks__/**",
];

/**
 * Walk the project, return one `DiscoveryHit` per implementation file.
 * Skips story files, index re-exports, type-only files, and tests.
 */
export async function discoverComponents(opts: DiscoverOptions): Promise<DiscoveryHit[]> {
  const { root } = opts;
  const include = opts.include ?? DEFAULT_INCLUDES;
  const exclude = opts.exclude ?? DEFAULT_EXCLUDES;

  const files = await fg(include, {
    cwd: root,
    absolute: true,
    onlyFiles: true,
    ignore: exclude,
    dot: false,
  });

  const hits: DiscoveryHit[] = [];
  const seenComponents = new Set<string>();

  for (const file of files) {
    const base = path.basename(file);
    if (base.includes(".stories.") || base.includes(".test.") || base.includes(".spec.")) continue;
    if (base.endsWith(".d.ts")) continue;

    // Index files only count when no sibling Name.tsx exists — we treat them as
    // legitimate component homes for the flat-layout case.
    const dir = path.dirname(file);
    const dirName = path.basename(dir);
    const fileStem = path.basename(file).replace(/\.(ts|tsx|jsx)$/, "");

    let name: string;
    if (fileStem === "index") {
      name = dirName;
      // Skip if there's a Name.tsx alongside — that's the canonical home.
      const sibling = ["tsx", "ts", "jsx"]
        .map((ext) => path.join(dir, `${dirName}.${ext}`))
        .find((p) => existsSync(p));
      if (sibling) continue;
    } else {
      name = fileStem;
    }

    // Component identifier convention: PascalCase.
    if (!/^[A-Z][A-Za-z0-9]*$/.test(name)) continue;

    const tier = inferTier(file);
    const storiesPath = findSiblingStories(dir, name);

    const id = `${tier}:${name}:${file}`;
    if (seenComponents.has(id)) continue;
    seenComponents.add(id);

    hits.push({ name, tier, filePath: file, storiesPath, dir });
  }

  hits.sort((a, b) => a.filePath.localeCompare(b.filePath));
  return hits;
}

function findSiblingStories(dir: string, name: string): string | undefined {
  for (const ext of ["stories.tsx", "stories.ts", "stories.jsx", "stories.js"]) {
    const candidate = path.join(dir, `${name}.${ext}`);
    if (existsSync(candidate) && statSync(candidate).isFile()) return candidate;
  }
  return undefined;
}

/**
 * Tier inference walks the path segments looking for a known atomic-design
 * directory name. The lowest (closest to file) match wins so a `templates/`
 * folder nested inside `organisms/` is read as the `template` tier — but in
 * practice atomic trees don't nest like that, so the order rarely matters.
 */
export function inferTier(filePath: string): Tier {
  const segments = filePath.split(path.sep);
  for (let i = segments.length - 1; i >= 0; i -= 1) {
    const segment = segments[i];
    if (segment !== undefined) {
      const tier = TIER_DIR[segment];
      if (tier) return tier;
    }
  }
  return "unknown";
}

/**
 * Build the canonical sidebar-sorted name from the file path when no story
 * meta title exists. Uses the tier name (Title Case) plus the component name.
 * Example: `src/components/atoms/Button/Button.tsx` → `Atoms/Button`.
 */
export function inferSortedName(hit: DiscoveryHit): string {
  const tierLabel = hit.tier === "unknown" ? "Components" : titleCase(`${hit.tier}s`);
  return `${tierLabel}/${hit.name}`;
}

function titleCase(s: string): string {
  return s.charAt(0).toUpperCase() + s.slice(1);
}
