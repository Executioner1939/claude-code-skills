/**
 * Preset registry — load archaeology recipes from disk with project overlay
 * support.
 *
 * Search order (later wins by `name`):
 *
 *   1. Bundled defaults at `<inspector pkg>/archaeology/queries/*.json`.
 *   2. Project overlays at `<projectRoot>/.anvil/archaeology/queries/*.json`.
 *
 * A preset overlay can fully replace a default with the same `name`, or
 * introduce new presets the defaults don't ship.
 *
 * Each preset is a JSON document of shape:
 *
 *   {
 *     "name": "raw-html-containers",
 *     "description": "...",
 *     "filter": <FilterPredicate>
 *   }
 *
 * `filter` is fed straight into `findInTree` from `filter-engine.ts`.
 */

import path from "node:path";
import { fileURLToPath } from "node:url";
import { existsSync, readFileSync, readdirSync, statSync } from "node:fs";
import type { FilterPredicate } from "./filter-engine.js";

export interface Preset {
  name: string;
  description: string;
  filter: FilterPredicate;
  /** Where the preset was loaded from. Useful for "why did this rule run". */
  source: string;
}

export interface LoadPresetsOptions {
  /** Project root — overlays at `<projectRoot>/.anvil/archaeology/queries/` are merged. */
  projectRoot: string;
  /**
   * Override the bundled-defaults directory. Defaults to the package's own
   * `archaeology/queries/` directory.
   */
  bundledDir?: string;
}

export function loadPresets(opts: LoadPresetsOptions): Map<string, Preset> {
  const presets = new Map<string, Preset>();
  const bundled = opts.bundledDir ?? defaultBundledDir();
  loadFromDir(bundled, presets);
  const projectDir = path.join(opts.projectRoot, ".anvil", "archaeology", "queries");
  if (existsSync(projectDir) && statSync(projectDir).isDirectory()) {
    loadFromDir(projectDir, presets);
  }
  return presets;
}

export function getPreset(opts: LoadPresetsOptions, name: string): Preset | undefined {
  return loadPresets(opts).get(name);
}

export function listPresets(opts: LoadPresetsOptions): Preset[] {
  return Array.from(loadPresets(opts).values()).sort((a, b) => a.name.localeCompare(b.name));
}

/* ------------------------------------------------------------------ */

function loadFromDir(dir: string, into: Map<string, Preset>): void {
  if (!existsSync(dir)) return;
  const entries = readdirSync(dir);
  for (const entry of entries) {
    if (!entry.endsWith(".json")) continue;
    const full = path.join(dir, entry);
    let parsed: unknown;
    try {
      parsed = JSON.parse(readFileSync(full, "utf8"));
    } catch (err) {
      throw new Error(`Failed to parse preset ${full}: ${err instanceof Error ? err.message : String(err)}`);
    }
    if (!isPreset(parsed)) {
      throw new Error(`Preset at ${full} is missing a name / description / filter.`);
    }
    into.set(parsed.name, { ...parsed, source: full });
  }
}

function isPreset(value: unknown): value is Omit<Preset, "source"> {
  if (typeof value !== "object" || value === null) return false;
  const v = value as Record<string, unknown>;
  return typeof v.name === "string" && typeof v.description === "string" && typeof v.filter === "object" && v.filter !== null;
}

function defaultBundledDir(): string {
  // From src/ → ../../archaeology/queries (when running via tsx) or
  // dist/ → ../archaeology/queries (when running compiled).
  const here = path.dirname(fileURLToPath(import.meta.url));
  // Walk up looking for an `archaeology/queries` directory.
  let dir = here;
  for (let i = 0; i < 5; i += 1) {
    const candidate = path.join(dir, "archaeology", "queries");
    if (existsSync(candidate)) return candidate;
    dir = path.dirname(dir);
  }
  // Last resort — assume installed alongside the package root.
  return path.resolve(here, "..", "..", "archaeology", "queries");
}
