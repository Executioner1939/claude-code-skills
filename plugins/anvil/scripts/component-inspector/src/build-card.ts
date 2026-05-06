/**
 * Compose a `ComponentCard` from the per-file parsers.
 *
 *   parseComponent  →  exports + props + directive + lastModified
 *   parseStories    →  meta.title + variants + args
 *   findConsumers   →  who imports / renders this component
 *   extractTokens   →  CSS vars + Tailwind aliases + literal violations
 *
 * The composer also runs lint-style checks that need cross-cutting context
 * (the tier the file lives in vs the tokens it uses, etc.) and surfaces them
 * as `issues` on the card.
 */

import path from "node:path";
import { discoverComponents, inferSortedName, type DiscoveryHit } from "./discover.js";
import { parseComponent, readSource } from "./parse-component.js";
import { parseStories } from "./parse-stories.js";
import { findConsumers } from "./find-consumers.js";
import { extractTokens, RAW_LAYOUT_FRAGMENTS } from "./extract-tokens.js";
import { buildImportGraph, type ImportGraph } from "./import-graph.js";
import type { CardIssue, ComponentCard, ConsumerRef, Inventory, InventoryNode } from "./types.js";

export interface BuildCardOptions {
  /** Project root — used for relative paths and consumer scans. */
  projectRoot: string;
  /** Path to the component implementation file. Absolute. */
  componentPath: string;
  /** Skip the consumer scan (it walks the whole project — slow). */
  skipConsumers?: boolean;
}

export async function buildCard(opts: BuildCardOptions): Promise<ComponentCard> {
  const { projectRoot, componentPath } = opts;
  const hit = await locateHit(projectRoot, componentPath);

  const parsed = parseComponent(componentPath);
  const stories = hit.storiesPath ? parseStories(hit.storiesPath) : undefined;
  const tokens = extractTokens(componentPath, projectRoot);
  const consumers = opts.skipConsumers
    ? []
    : await findConsumers({
        name: parsed.principal ?? hit.name,
        root: projectRoot,
        selfPath: componentPath,
      });

  const fullSortedName = stories?.metaTitle ?? inferSortedName(hit);
  const issues: CardIssue[] = [];

  // ── Issue: stories missing entirely ──────────────────────────────
  if (!hit.storiesPath) {
    issues.push({
      level: "warn",
      rule: "missing-stories",
      message: `No \`${hit.name}.stories.{ts,tsx,jsx}\` found alongside the component.`,
    });
  } else if (stories?.format !== "csf3" && stories?.format !== "csf-factories") {
    issues.push({
      level: "warn",
      rule: "non-csf3-stories",
      message: `Stories file uses ${stories?.format ?? "unknown"} format. Expect CSF3 or CSF Factories.`,
      at: { path: path.relative(projectRoot, hit.storiesPath), line: 1 },
    });
  }

  // ── Issue: missing principal export ─────────────────────────────
  if (!parsed.principal) {
    issues.push({
      level: "error",
      rule: "no-principal-export",
      message: `No exported component matched the file name '${hit.name}'.`,
    });
  }

  // ── Issue: forwardRef without displayName ───────────────────────
  if (parsed.exports.forwardsRef && !parsed.exports.hasDisplayName) {
    issues.push({
      level: "info",
      rule: "forward-ref-no-display-name",
      message: `Component uses forwardRef but doesn't set displayName — devtools will show '$$forwardRef'.`,
    });
  }

  // ── Issue: raw Tailwind layout in DS code ───────────────────────
  const source = readSource(componentPath);
  const lines = source.split(/\r?\n/);
  for (let i = 0; i < lines.length; i += 1) {
    const line = lines[i] ?? "";
    for (const re of RAW_LAYOUT_FRAGMENTS) {
      if (re.test(line)) {
        issues.push({
          level: "warn",
          rule: "raw-tailwind-layout",
          message: `className uses raw layout utilities. Compose <Stack>/<Row>/<Grid> from atoms/Layout instead.`,
          at: { path: path.relative(projectRoot, componentPath), line: i + 1 },
        });
        break;
      }
    }
  }

  // ── Issue: process.env in browser code ──────────────────────────
  if (/\bprocess\.env\b/.test(source)) {
    const idx = lines.findIndex((line) => /\bprocess\.env\b/.test(line));
    issues.push({
      level: "warn",
      rule: "process-env-in-browser-code",
      message:
        "process.env is not defined in the browser. Use import.meta.env (Vite) or feature-detect via globalThis.",
      at: { path: path.relative(projectRoot, componentPath), line: idx >= 0 ? idx + 1 : 1 },
    });
  }

  // ── Issue: hardcoded colour / shadow / easing literals ───────────
  for (const lit of tokens.literals) {
    if (lit.kind === "color" || lit.kind === "shadow" || lit.kind === "easing") {
      issues.push({
        level: "warn",
        rule: "hardcoded-token-literal",
        message: `Hardcoded ${lit.kind} literal '${lit.value}'. Use a token instead.`,
        at: { path: lit.path, line: lit.line },
      });
    }
  }

  const card: ComponentCard = {
    name: parsed.principal ?? hit.name,
    tier: hit.tier,
    fullSortedName,
    filePath: path.relative(projectRoot, componentPath),
    exports: parsed.exports,
    props: parsed.props,
    consumers,
    tokens,
    issues,
    lastModified: parsed.lastModified,
  };
  if (stories) {
    const { notes: _ignored, lastModified: _ignored2, ...storiesPublic } = stories;
    void _ignored;
    void _ignored2;
    card.stories = { ...storiesPublic, filePath: path.relative(projectRoot, stories.filePath) };
  }
  return card;
}

/**
 * Resolve a single component file to its `DiscoveryHit`. We discover the full
 * tree because that's how we find the sibling stories file reliably.
 */
async function locateHit(projectRoot: string, componentPath: string): Promise<DiscoveryHit> {
  const all = await discoverComponents({ root: projectRoot });
  const hit = all.find((h) => path.resolve(h.filePath) === path.resolve(componentPath));
  if (hit) return hit;
  // Fall back to a synthetic hit so we can still render a card for files
  // outside the standard tree.
  const dir = path.dirname(componentPath);
  const fileBase = path.basename(componentPath).replace(/\.(tsx?|jsx?)$/, "");
  return {
    name: fileBase,
    tier: "unknown",
    filePath: componentPath,
    dir,
  };
}

/* ------------------------------------------------------------------ */
/*  Inventory                                                          */
/* ------------------------------------------------------------------ */

export interface BuildInventoryOptions {
  projectRoot: string;
  /** Skip the consumer scan per node — produces the bare graph faster. */
  skipConsumers?: boolean;
  /** Limit to one tier (`atom`, `molecule`, etc.) — useful for partial audits. */
  tier?: string;
}

export async function buildInventory(opts: BuildInventoryOptions): Promise<Inventory> {
  const hits = await discoverComponents({ root: opts.projectRoot });
  const filtered = opts.tier ? hits.filter((h) => h.tier === opts.tier) : hits;

  // Build the full import graph in one pass, then derive consumers/composes
  // by inverting it. O(files) instead of O(components * files).
  const graph = await buildImportGraph({ root: opts.projectRoot });

  // Map every component file → component name (so we know which imports we
  // care about — imports of non-component files don't count as composition).
  const componentFileToName = new Map<string, string>();
  for (const h of hits) componentFileToName.set(path.normalize(h.filePath), h.name);

  const composes = collectComposesFromGraph(graph, componentFileToName);

  const nodes: InventoryNode[] = [];
  for (const hit of filtered) {
    const key = path.normalize(hit.filePath);
    const consumers = (composes.consumersByPath.get(key) ?? []).map((p) =>
      path.relative(opts.projectRoot, p),
    );
    const composedPaths = composes.composesByPath.get(key) ?? [];
    const composed = composedPaths
      .map((p) => componentFileToName.get(p))
      .filter((n): n is string => Boolean(n));
    nodes.push({
      id: `${hit.tier}:${hit.name}`,
      tier: hit.tier,
      path: path.relative(opts.projectRoot, hit.filePath),
      ...(hit.storiesPath ? { storiesPath: path.relative(opts.projectRoot, hit.storiesPath) } : {}),
      composes: dedupe(composed).sort(),
      consumers: dedupe(consumers).sort(),
    });
  }

  return {
    root: opts.projectRoot,
    generatedAt: new Date().toISOString(),
    componentRoots: dedupeRoots(filtered.map((h) => h.dir)),
    nodes,
    orphans: hits.filter((h) => h.tier === "unknown").map((h) => path.relative(opts.projectRoot, h.filePath)),
  };
}

interface ComposesIndex {
  /** componentFile → list of files that import it. */
  consumersByPath: Map<string, string[]>;
  /** componentFile → list of *other* component files it imports. */
  composesByPath: Map<string, string[]>;
}

/**
 * From the full import graph, derive the per-component consumer + composes
 * lists. Pure inversion — no filesystem access here.
 */
function collectComposesFromGraph(graph: ImportGraph, componentFileToName: Map<string, string>): ComposesIndex {
  const consumersByPath = new Map<string, string[]>();
  const composesByPath = new Map<string, string[]>();

  for (const edge of graph.edges) {
    if (!componentFileToName.has(edge.imported)) continue;
    const importerKey = path.normalize(edge.importer);
    const importedKey = path.normalize(edge.imported);

    // Consumers: the imported component is consumed by the importer.
    const consumers = consumersByPath.get(importedKey) ?? [];
    consumers.push(importerKey);
    consumersByPath.set(importedKey, consumers);

    // Composes: only when the importer is itself a component file.
    if (componentFileToName.has(importerKey)) {
      const composes = composesByPath.get(importerKey) ?? [];
      composes.push(importedKey);
      composesByPath.set(importerKey, composes);
    }
  }

  return { consumersByPath, composesByPath };
}

function dedupeRoots(dirs: string[]): string[] {
  const set = new Set<string>();
  for (const dir of dirs) {
    const parent = path.dirname(dir);
    set.add(parent);
  }
  return Array.from(set).sort();
}

function dedupe<T>(arr: T[]): T[] {
  return Array.from(new Set(arr));
}
