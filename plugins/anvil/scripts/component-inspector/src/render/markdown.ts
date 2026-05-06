/**
 * Render a `ComponentCard` as a human-readable markdown card.
 *
 * Output is designed to be:
 *   - copy-pastable into a PR description
 *   - readable as plain text in a terminal (no exotic syntax)
 *   - re-parseable by the same renderer in reverse if needed
 */

import type { CardIssue, ComponentCard, PropDoc, StoryVariant } from "../types.js";

export function renderCardMarkdown(card: ComponentCard): string {
  const out: string[] = [];
  out.push(`# ${card.name} — ${card.fullSortedName}`);
  out.push("");
  out.push(headerLine(card));
  out.push("");
  out.push(propsSection(card.props));
  if (card.stories) {
    out.push(storiesSection(card.stories.metaTitle, card.stories.variants, card.stories.filePath));
  } else {
    out.push("## Stories\n\n_No stories file._\n");
  }
  out.push(consumersSection(card.consumers));
  out.push(tokensSection(card.tokens));
  out.push(issuesSection(card.issues));
  return out.join("\n").trim() + "\n";
}

/* ------------------------------------------------------------------ */

function headerLine(card: ComponentCard): string {
  const bits: string[] = [`tier: \`${card.tier}\``, `path: \`${card.filePath}\``];
  if (card.exports.forwardsRef) bits.push("`forwardRef`");
  if (card.exports.directive) bits.push(`\`${card.exports.directive}\``);
  bits.push(`mtime: ${card.lastModified.split("T")[0]}`);
  return bits.join(" · ");
}

function propsSection(props: PropDoc[]): string {
  if (props.length === 0) return "## Props\n\n_None._\n";
  const rows = ["| Prop | Type | Default | Required | Doc |", "| --- | --- | --- | --- | --- |"];
  for (const p of props) {
    rows.push(
      `| \`${p.name}\` | \`${escapeCell(p.type)}\` | ${p.default ? `\`${escapeCell(p.default)}\`` : "—"} | ${p.required ? "yes" : "no"} | ${p.doc ? escapeCell(p.doc) : ""} |`,
    );
  }
  return ["## Props", "", ...rows, ""].join("\n");
}

function storiesSection(metaTitle: string | undefined, variants: StoryVariant[], storiesPath: string): string {
  const lines: string[] = ["## Stories", ""];
  lines.push(`_File: \`${storiesPath}\`_${metaTitle ? ` · _Title: \`${metaTitle}\`_` : ""}`);
  lines.push("");
  if (variants.length === 0) {
    lines.push("_No named exports._");
    lines.push("");
    return lines.join("\n");
  }
  lines.push("| Export | Story Name | Shape | Play | Args |");
  lines.push("| --- | --- | --- | --- | --- |");
  for (const v of variants) {
    const args = v.args ? "`" + truncate(JSON.stringify(v.args), 80) + "`" : "—";
    lines.push(`| \`${v.exportName}\` | ${escapeCell(v.storyName)} | ${v.renderShape} | ${v.hasPlay ? "yes" : "no"} | ${args} |`);
  }
  lines.push("");
  return lines.join("\n");
}

function consumersSection(consumers: ComponentCard["consumers"]): string {
  if (consumers.length === 0) return "## Consumers\n\n_None — orphan or freshly built._\n";
  const lines = ["## Consumers", "", "| Path | Kind |", "| --- | --- |"];
  for (const c of consumers) lines.push(`| \`${c.path}\` | ${c.kind} |`);
  lines.push("");
  return lines.join("\n");
}

function tokensSection(tokens: ComponentCard["tokens"]): string {
  const lines = ["## Tokens", ""];
  if (tokens.cssVars.length > 0) {
    lines.push("**CSS variables:**");
    lines.push(tokens.cssVars.map((v) => `\`${v}\``).join(", "));
    lines.push("");
  }
  if (tokens.tailwindAliases.length > 0) {
    lines.push("**Tailwind aliases:**");
    lines.push(tokens.tailwindAliases.map((v) => `\`${v}\``).join(", "));
    lines.push("");
  }
  if (tokens.literals.length > 0) {
    lines.push("**Hard-coded literals:**");
    lines.push("");
    lines.push("| Path:Line | Kind | Value |");
    lines.push("| --- | --- | --- |");
    for (const lit of tokens.literals) {
      lines.push(`| \`${lit.path}:${lit.line}\` | ${lit.kind} | \`${escapeCell(lit.value)}\` |`);
    }
    lines.push("");
  }
  if (tokens.cssVars.length === 0 && tokens.tailwindAliases.length === 0 && tokens.literals.length === 0) {
    lines.push("_No token references found._");
    lines.push("");
  }
  return lines.join("\n");
}

function issuesSection(issues: CardIssue[]): string {
  if (issues.length === 0) return "## Issues\n\n_None._\n";
  const lines = ["## Issues", ""];
  for (const issue of issues) {
    const at = issue.at ? ` _(\`${issue.at.path}:${issue.at.line}\`)_` : "";
    lines.push(`- **${issue.level.toUpperCase()}** \`${issue.rule}\` — ${issue.message}${at}`);
  }
  lines.push("");
  return lines.join("\n");
}

function escapeCell(text: string): string {
  return text.replace(/\|/g, "\\|").replace(/\n/g, " ");
}

function truncate(text: string, n: number): string {
  return text.length <= n ? text : `${text.slice(0, n - 1)}…`;
}
