/**
 * Parallel body-tree walker.
 *
 * Walks every component file discovered by `discoverComponents`, parses each
 * into a `ComponentTree`, and emits results as soon as they're ready (so the
 * NDJSON consumer downstream gets back-pressure / streaming semantics).
 *
 * Concurrency is bounded — body-tree parsing is CPU-bound (TS source-file
 * creation), so we don't want to spawn unbounded promises.
 *
 * No dependency on `p-limit` etc; the limiter is a 30-line semaphore.
 */

import path from "node:path";
import { discoverComponents } from "./discover.js";
import { parseBodyTree } from "./parse-body-tree.js";
import type { ComponentTree } from "./types.js";

export interface WalkTreesOptions {
  root: string;
  /** Number of files parsed in parallel. Defaults to 8. */
  concurrency?: number;
  /** Optional include / exclude globs. */
  include?: string[];
  exclude?: string[];
  /** Limit to a single tier. */
  tier?: string;
}

/**
 * Async-iterable producer of ComponentTree records. Caller pumps results
 * straight into NDJSON output, or collects into an array for one-shot use.
 */
export async function* walkTrees(opts: WalkTreesOptions): AsyncGenerator<ComponentTree> {
  const concurrency = Math.max(1, opts.concurrency ?? 8);
  const hits = await discoverComponents({
    root: opts.root,
    ...(opts.include ? { include: opts.include } : {}),
    ...(opts.exclude ? { exclude: opts.exclude } : {}),
  });
  const filtered = opts.tier ? hits.filter((h) => h.tier === opts.tier) : hits;

  // Bounded concurrency with a small ring of in-flight promises. As each
  // resolves, we yield its result and start the next one.
  let i = 0;
  const inflight = new Map<number, Promise<ComponentTree | null>>();

  function start(idx: number): void {
    const hit = filtered[idx];
    if (!hit) return;
    inflight.set(
      idx,
      (async (): Promise<ComponentTree | null> => {
        try {
          return parseBodyTree(hit.filePath, { projectRoot: opts.root });
        } catch (err) {
          return {
            file: path.relative(opts.root, hit.filePath),
            componentName: hit.name,
            root: null,
            notes: [`parser-threw: ${err instanceof Error ? err.message : String(err)}`],
          };
        }
      })(),
    );
  }

  // Prime the pump.
  while (i < filtered.length && inflight.size < concurrency) {
    start(i);
    i += 1;
  }

  while (inflight.size > 0) {
    // Race the in-flight set; resolve the next-completed and yield it.
    const [resolvedIdx, tree] = await Promise.race(
      Array.from(inflight.entries()).map(async ([idx, p]) => [idx, await p] as const),
    );
    inflight.delete(resolvedIdx);
    if (tree) yield tree;
    if (i < filtered.length) {
      start(i);
      i += 1;
    }
  }
}
