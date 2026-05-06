/**
 * Sinks — terminal verbs that consume archaeology NDJSON and produce
 * non-NDJSON output (text or numbers).
 *
 *   format  — pretty-print issues per file with line refs.
 *   count   — emit the total match count.
 *   paths   — emit `<file>:<line>:<col>  <ruleId>: <reason>` lines, suitable
 *             for piping into an editor / fzf / grep.
 */

import type { ArchaeologyRecord, ComponentTree } from "../types.js";

export function renderFormat(records: ArchaeologyRecord[]): string {
  if (records.length === 0) return "(no matches)\n";
  const lines: string[] = [];
  for (const rec of records) {
    if (rec.matches.length === 0) continue;
    lines.push(`${rec.file}${rec.componentName ? `  (${rec.componentName})` : ""}`);
    for (const m of rec.matches) {
      const loc = `${m.node.loc.line}:${m.node.loc.col}`;
      const tag = matchSummary(m.node);
      const rule = m.ruleId ? `[${m.ruleId}] ` : "";
      const reason = m.reason ?? "";
      lines.push(`  ${loc}  ${rule}${tag}${reason ? `  — ${reason}` : ""}`);
    }
    lines.push("");
  }
  return lines.join("\n");
}

export function countMatches(records: ArchaeologyRecord[]): number {
  let n = 0;
  for (const rec of records) n += rec.matches.length;
  return n;
}

export function renderPaths(records: ArchaeologyRecord[]): string {
  const lines: string[] = [];
  for (const rec of records) {
    for (const m of rec.matches) {
      const rule = m.ruleId ? `${m.ruleId}: ` : "";
      const reason = m.reason ?? matchSummary(m.node);
      lines.push(`${rec.file}:${m.node.loc.line}:${m.node.loc.col}  ${rule}${reason}`);
    }
  }
  return lines.join("\n") + (lines.length > 0 ? "\n" : "");
}

/**
 * For tree-only NDJSON (the producer's output before any filter), expose a
 * `paths`-equivalent that lists every file. Allows `trees | paths` to act as
 * a dry inventory of what the next pipeline stage will see.
 */
export function renderTreePaths(trees: ComponentTree[]): string {
  return trees.map((t) => `${t.file}\t${t.componentName}`).join("\n") + (trees.length > 0 ? "\n" : "");
}

function matchSummary(node: ArchaeologyRecord["matches"][number]["node"]): string {
  if (node.kind === "element") {
    const cls = node.className && node.className.tokens.length > 0 ? ` className="${node.className.tokens.join(" ")}"` : "";
    return `<${node.tag}${cls}>`;
  }
  if (node.kind === "fragment") return "<>…</>";
  if (node.kind === "expression") return `{${truncate(node.raw, 60)}}`;
  return `'${truncate(node.text, 60)}'`;
}

function truncate(s: string, n: number): string {
  return s.length > n ? `${s.slice(0, n - 1)}…` : s;
}
