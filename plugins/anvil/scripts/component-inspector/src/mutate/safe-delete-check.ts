/**
 * Safety check before deleting a component.
 *
 * Re-uses the import graph to ask "if I delete this file (or this exported
 * identifier), what consumers break?"
 *
 * Returns the consumer list and a recommendation. The actual deletion is the
 * caller's job — this module never removes files.
 */

import path from "node:path";
import { buildImportGraph } from "../import-graph.js";

export interface SafeDeleteOptions {
  /** Project root. Absolute. */
  root: string;
  /** Path of the file slated for deletion. Absolute. */
  target: string;
  /**
   * Optional name filter — when set, only consumers that import this specific
   * name are flagged. Used for "the component is being renamed, not deleted"
   * cases where other exports of the file survive.
   */
  exportName?: string;
}

export interface SafeDeleteResult {
  target: string;
  consumers: { path: string; names: string[]; typeOnly: boolean }[];
  /** True when no consumers were found — safe to delete. */
  safe: boolean;
  /** Human summary the CLI prints. */
  summary: string;
}

export async function safeDeleteCheck(opts: SafeDeleteOptions): Promise<SafeDeleteResult> {
  const graph = await buildImportGraph({ root: opts.root });
  const targetNorm = path.normalize(path.resolve(opts.target));
  const incoming = graph.byImported.get(targetNorm) ?? [];

  const consumers = incoming
    .filter((edge) => {
      if (!opts.exportName) return true;
      return edge.names.includes(opts.exportName);
    })
    .map((edge) => ({
      path: path.relative(opts.root, edge.importer),
      names: edge.names,
      typeOnly: edge.typeOnly,
    }))
    .sort((a, b) => a.path.localeCompare(b.path));

  const safe = consumers.length === 0;
  const rel = path.relative(opts.root, targetNorm);
  const filterNote = opts.exportName ? ` (filter: ${opts.exportName})` : "";
  const summary = safe
    ? `safe-delete-check: no consumers found for ${rel}${filterNote}. Safe to delete.`
    : `safe-delete-check: ${consumers.length} consumer(s) of ${rel}${filterNote}. DO NOT delete without migration.`;

  return { target: targetNorm, consumers, safe, summary };
}
