/**
 * CLI for `@anvil/inspector`.
 *
 * Subcommands:
 *   anvil-inspect card    <path>       Render one ComponentCard.
 *   anvil-inspect json    <path>       Same card, JSON output.
 *   anvil-inspect inventory <root>     Full design-system inventory.
 *   anvil-inspect discover  <root>     File-discovery only (debug).
 *   anvil-inspect consumers <name> --root <root>  Who imports / renders X?
 *   anvil-inspect tokens    <path>     Token-usage report for one file.
 */

import { Command } from "commander";
import path from "node:path";
import { writeFileSync } from "node:fs";
import { discoverComponents } from "./discover.js";
import { buildCard, buildInventory } from "./build-card.js";
import { renderCardMarkdown } from "./render/markdown.js";
import { findConsumers } from "./find-consumers.js";
import { extractTokens } from "./extract-tokens.js";
import { renameStoryTitle } from "./mutate/rename-story-title.js";
import { renameJsxProp } from "./mutate/rename-jsx-prop.js";
import { renameComponent } from "./mutate/rename-component.js";
import { renameProp } from "./mutate/rename-prop.js";
import { removeImport } from "./mutate/remove-import.js";
import { safeDeleteCheck } from "./mutate/safe-delete-check.js";
import { verifyMdxRefs } from "./verify-mdx.js";
import { findOrphanExports } from "./orphan-exports.js";
import { parseBodyTree } from "./parse-body-tree.js";
import { walkTrees } from "./walk-trees.js";
import { hasStdinInput, readNdjson, writeNdjson } from "./ndjson.js";
import { findInTree, findInNode, type FilterPredicate } from "./archaeology/filter-engine.js";
import { findUntokenedClasses } from "./archaeology/find-untokened-classes.js";
import { listPresets, getPreset } from "./archaeology/preset-registry.js";
import { countMatches, renderFormat, renderPaths, renderTreePaths } from "./archaeology/sinks.js";
import type { ArchaeologyRecord, ComponentTree } from "./types.js";

export async function run(argv: string[]): Promise<number> {
  const program = new Command();
  program
    .name("anvil-inspect")
    .description("Inspector for atomic-design component libraries.")
    .version("0.1.0");

  program
    .command("card")
    .description("Render a markdown card for one component.")
    .argument("<path>", "Component implementation file (.tsx).")
    .option("--root <dir>", "Project root. Defaults to cwd.")
    .option("--no-consumers", "Skip the consumer scan (faster).")
    .option("--out <file>", "Write to file instead of stdout.")
    .action(async (filePath: string, opts: { root?: string; consumers?: boolean; out?: string }) => {
      const root = path.resolve(opts.root ?? process.cwd());
      const componentPath = path.resolve(filePath);
      const card = await buildCard({
        projectRoot: root,
        componentPath,
        skipConsumers: opts.consumers === false,
      });
      const md = renderCardMarkdown(card);
      if (opts.out) writeFileSync(opts.out, md);
      else process.stdout.write(md);
    });

  program
    .command("json")
    .description("Render a JSON card for one component.")
    .argument("<path>", "Component implementation file (.tsx).")
    .option("--root <dir>", "Project root. Defaults to cwd.")
    .option("--no-consumers", "Skip the consumer scan (faster).")
    .option("--out <file>", "Write to file instead of stdout.")
    .action(async (filePath: string, opts: { root?: string; consumers?: boolean; out?: string }) => {
      const root = path.resolve(opts.root ?? process.cwd());
      const componentPath = path.resolve(filePath);
      const card = await buildCard({
        projectRoot: root,
        componentPath,
        skipConsumers: opts.consumers === false,
      });
      const json = JSON.stringify(card, null, 2);
      if (opts.out) writeFileSync(opts.out, json + "\n");
      else process.stdout.write(json + "\n");
    });

  program
    .command("inventory")
    .description("Build a full design-system inventory.")
    .argument("[root]", "Project root. Defaults to cwd.")
    .option("--tier <tier>", "Limit to one tier (atom | molecule | organism | surface | template).")
    .option("--no-consumers", "Skip the consumer scan per node.")
    .option("--out <file>", "Write JSON to this path.")
    .action(async (root: string | undefined, opts: { tier?: string; consumers?: boolean; out?: string }) => {
      const projectRoot = path.resolve(root ?? process.cwd());
      const inventory = await buildInventory({
        projectRoot,
        ...(opts.tier ? { tier: opts.tier } : {}),
        skipConsumers: opts.consumers === false,
      });
      const json = JSON.stringify(inventory, null, 2);
      if (opts.out) writeFileSync(opts.out, json + "\n");
      else process.stdout.write(json + "\n");
    });

  program
    .command("discover")
    .description("Print the discovered component list (debug).")
    .argument("[root]", "Project root. Defaults to cwd.")
    .action(async (root: string | undefined) => {
      const projectRoot = path.resolve(root ?? process.cwd());
      const hits = await discoverComponents({ root: projectRoot });
      for (const h of hits) {
        const stories = h.storiesPath ? "  ✓" : "  ·";
        process.stdout.write(`${h.tier.padEnd(10)} ${h.name.padEnd(28)}${stories}  ${path.relative(projectRoot, h.filePath)}\n`);
      }
      process.stdout.write(`\n${hits.length} components found.\n`);
    });

  program
    .command("consumers")
    .description("List every file that imports / renders a component.")
    .argument("<name>", "Component identifier (the named export).")
    .option("--root <dir>", "Project root. Defaults to cwd.")
    .option("--self <path>", "Path of the component to exclude from results.")
    .action(async (name: string, opts: { root?: string; self?: string }) => {
      const root = path.resolve(opts.root ?? process.cwd());
      const refs = await findConsumers({
        name,
        root,
        selfPath: opts.self ? path.resolve(opts.self) : path.join(root, "__self_unknown__"),
      });
      for (const ref of refs) {
        process.stdout.write(`${ref.kind.padEnd(16)}  ${ref.path}\n`);
      }
      process.stdout.write(`\n${refs.length} consumers.\n`);
    });

  program
    .command("tokens")
    .description("Token-usage report for a single component file.")
    .argument("<path>", "Component file.")
    .option("--root <dir>", "Project root. Defaults to cwd.")
    .action(async (filePath: string, opts: { root?: string }) => {
      const root = path.resolve(opts.root ?? process.cwd());
      const tokens = extractTokens(path.resolve(filePath), root);
      process.stdout.write(JSON.stringify(tokens, null, 2) + "\n");
    });

  program
    .command("rename-story-title")
    .description("Structurally rename meta.title in a CSF3 stories file. Dry-run by default.")
    .argument("<storyPath>", "Path to <Component>.stories.tsx.")
    .argument("<newTitle>", "New title (e.g. 'Atoms/Actions/Button').")
    .option("--apply", "Write the change. Default is dry-run.")
    .action(async (storyPath: string, newTitle: string, opts: { apply?: boolean }) => {
      const result = await renameStoryTitle(path.resolve(storyPath), newTitle, { apply: Boolean(opts.apply) });
      if (!result) {
        process.stderr.write(`anvil-inspect: no meta.title found in ${storyPath}\n`);
        process.exit(2);
      }
      const verb = result.written ? "wrote" : "would write";
      process.stdout.write(
        `${verb}: ${result.filePath}\n  ${JSON.stringify(result.before)} → ${JSON.stringify(result.after)}\n  range [${result.range.start}, ${result.range.end}]\n`,
      );
    });

  program
    .command("rename-jsx-prop")
    .description("Rename a JSX attribute on every usage of a component. Dry-run by default.")
    .requiredOption("--component <name>", "Component name (e.g. Button).")
    .requiredOption("--from <oldProp>", "Old prop name.")
    .requiredOption("--to <newProp>", "New prop name.")
    .option("--root <dir>", "Project root. Defaults to cwd.")
    .option("--apply", "Write changes. Default is dry-run.")
    .action(async (opts: { component: string; from: string; to: string; root?: string; apply?: boolean }) => {
      const result = await renameJsxProp({
        component: opts.component,
        oldProp: opts.from,
        newProp: opts.to,
        root: path.resolve(opts.root ?? process.cwd()),
        apply: Boolean(opts.apply),
      });
      const verb = result.written ? "Rewrote" : "Would rewrite";
      process.stdout.write(`${verb} ${result.totalRenames} attribute(s) across ${result.hits.length} file(s):\n`);
      for (const hit of result.hits) {
        process.stdout.write(`  ${hit.filePath}  (lines: ${hit.lines.join(", ")})\n`);
      }
    });

  program
    .command("remove-import")
    .description("Strip a name from every import statement. Dry-run by default.")
    .requiredOption("--name <id>", "Identifier to remove.")
    .option("--root <dir>", "Project root. Defaults to cwd.")
    .option("--apply", "Write changes. Default is dry-run.")
    .action(async (opts: { name: string; root?: string; apply?: boolean }) => {
      const result = await removeImport({
        name: opts.name,
        root: path.resolve(opts.root ?? process.cwd()),
        apply: Boolean(opts.apply),
      });
      const verb = result.written ? "Rewrote" : "Would rewrite";
      process.stdout.write(`${verb} ${result.totalEdits} import(s) across ${result.hits.length} file(s):\n`);
      for (const hit of result.hits) {
        const tag = hit.removedEntireStatement ? "[removed-statement]" : "[stripped-specifier]";
        process.stdout.write(`  ${tag} ${hit.filePath}  (lines: ${hit.lines.join(", ")})\n`);
      }
    });

  program
    .command("orphan-exports")
    .description("Find exported names that no other file in the project imports.")
    .argument("[root]", "Project root. Defaults to cwd.")
    .option("--entry <paths>", "Comma-separated list of public-API entry files whose exports should be ignored.", (v) => v.split(",").map((s) => s.trim()).filter(Boolean))
    .option("--out <file>", "Write JSON report to this path.")
    .action(async (root: string | undefined, opts: { entry?: string[]; out?: string }) => {
      const projectRoot = path.resolve(root ?? process.cwd());
      const findOpts: Parameters<typeof findOrphanExports>[0] = { root: projectRoot };
      if (opts.entry) findOpts.entryPoints = opts.entry.map((p) => path.resolve(p));
      const result = await findOrphanExports(findOpts);
      if (opts.out) {
        writeFileSync(opts.out, JSON.stringify(result, null, 2) + "\n");
      }
      if (result.orphans.length === 0) {
        process.stdout.write(`orphan-exports: clean (${result.filesScanned} files scanned).\n`);
        return;
      }
      process.stdout.write(`orphan-exports: ${result.orphans.length} orphan name(s) across ${new Set(result.orphans.map((o) => o.filePath)).size} file(s):\n`);
      for (const o of result.orphans) {
        const tag = o.isReExport ? "[re-export]" : "          ";
        process.stdout.write(`  ${tag} ${o.filePath}:${o.line}  ${o.name}\n`);
      }
    });

  program
    .command("verify-mdx")
    .description("Verify every <Canvas of={Stories.X}>-style reference in MDX docs resolves against the imported stories file's actual exports.")
    .argument("[root]", "Project root. Defaults to cwd.")
    .option("--out <file>", "Write JSON report to this path.")
    .action(async (root: string | undefined, opts: { out?: string }) => {
      const projectRoot = path.resolve(root ?? process.cwd());
      const result = await verifyMdxRefs({ root: projectRoot });
      if (opts.out) {
        writeFileSync(opts.out, JSON.stringify(result, null, 2) + "\n");
      }
      if (result.issues.length === 0) {
        process.stdout.write(
          `verify-mdx: clean. ${result.mdxFiles.length} MDX file(s) scanned, ${result.storiesFiles.length} stories file(s) referenced.\n`,
        );
        return;
      }
      process.stdout.write(
        `verify-mdx: ${result.issues.length} broken reference(s) across ${new Set(result.issues.map((i) => i.mdxPath)).size} MDX file(s):\n`,
      );
      for (const issue of result.issues) {
        const hint = issue.available.length > 0 ? `  available: ${issue.available.slice(0, 6).join(", ")}${issue.available.length > 6 ? ", …" : ""}` : "";
        process.stdout.write(
          `  ${issue.mdxPath}\n    ${issue.alias}.${issue.missingExport} → not exported by ${issue.storiesPath}\n${hint}\n`,
        );
      }
      process.exit(2);
    });

  /* ──────────────────────────────────────────────────────────────── *
   *  Archaeology pipeline                                              *
   * ──────────────────────────────────────────────────────────────── */

  program
    .command("tree")
    .description("Emit the body-tree of one component as NDJSON (one record).")
    .argument("<path>", "Component implementation file (.tsx).")
    .option("--root <dir>", "Project root. Defaults to cwd.")
    .action((filePath: string, opts: { root?: string }) => {
      const root = path.resolve(opts.root ?? process.cwd());
      const tree = parseBodyTree(path.resolve(filePath), { projectRoot: root });
      writeNdjson(tree);
    });

  program
    .command("trees")
    .description("Emit the body-tree of every component in the project as NDJSON, one tree per line.")
    .argument("[root]", "Project root. Defaults to cwd.")
    .option("--concurrency <n>", "Parallel parser count (default 8).", (v) => Number(v))
    .option("--tier <tier>", "Limit to one tier (atom | molecule | organism | …).")
    .action(async (root: string | undefined, opts: { concurrency?: number; tier?: string }) => {
      const projectRoot = path.resolve(root ?? process.cwd());
      const walkOpts: { root: string; concurrency?: number; tier?: string } = { root: projectRoot };
      if (typeof opts.concurrency === "number" && !Number.isNaN(opts.concurrency)) walkOpts.concurrency = opts.concurrency;
      if (opts.tier) walkOpts.tier = opts.tier;
      for await (const tree of walkTrees(walkOpts)) {
        writeNdjson(tree);
      }
    });

  program
    .command("find-jsx")
    .description("Filter NDJSON trees: keep matches whose tag matches.")
    .option("--tag <name>", "Exact tag name (e.g. section).")
    .option("--tag-pattern <regex>", "Regex on tag name.")
    .option("--tag-kind <kind>", "html | component | member | dynamic.")
    .action(async (opts: { tag?: string; tagPattern?: string; tagKind?: string }) => {
      if (!opts.tag && !opts.tagPattern && !opts.tagKind) {
        process.stderr.write("find-jsx: pass --tag, --tag-pattern, or --tag-kind.\n");
        process.exit(1);
      }
      const predicate = buildPredicateFromTag(opts);
      await runFilterPipeline(predicate);
    });

  program
    .command("find-class")
    .description("Filter NDJSON trees: keep elements whose className matches a regex.")
    .requiredOption("--pattern <regex>", "Regex tested against each className token.")
    .option("--raw", "Match against unresolved className expressions (clsx args, etc.) instead of static tokens.")
    .action(async (opts: { pattern: string; raw?: boolean }) => {
      const predicate: FilterPredicate = opts.raw
        ? { rawClassPattern: opts.pattern, ruleId: "class-raw-match", reason: `raw className matches /${opts.pattern}/` }
        : { classPattern: opts.pattern, ruleId: "class-match", reason: `className token matches /${opts.pattern}/` };
      await runFilterPipeline(predicate);
    });

  program
    .command("find-attr")
    .description("Filter NDJSON trees: keep elements with a given attribute (and optional value pattern).")
    .requiredOption("--name <attr>", "Attribute name (e.g. data-testid, aria-label, style).")
    .option("--value <regex>", "Optional regex tested against the static value.")
    .action(async (opts: { name: string; value?: string }) => {
      const predicate: FilterPredicate = opts.value
        ? { attrValue: { name: opts.name, pattern: opts.value }, ruleId: "attr-value-match", reason: `${opts.name} matches /${opts.value}/` }
        : { attr: opts.name, ruleId: "attr-match", reason: `has attribute ${opts.name}` };
      await runFilterPipeline(predicate);
    });

  program
    .command("find-untokened-classes")
    .description("Filter NDJSON trees: surface className tokens that aren't recognised utilities or arbitrary-value classes.")
    .option("--allow <list>", "Comma-separated allow-list of class names (e.g. 'prose,markdown-body').", (v) => v.split(",").map((s) => s.trim()).filter(Boolean))
    .option("--ignore-arbitrary", "Skip the arbitrary-value (m-[3px]) check.")
    .action(async (opts: { allow?: string[]; ignoreArbitrary?: boolean }) => {
      if (!hasStdinInput()) {
        process.stderr.write("find-untokened-classes expects NDJSON trees on stdin. Pipe `trees`/`tree` into it.\n");
        process.exit(1);
      }
      for await (const record of readNdjson<ComponentTree>(process.stdin)) {
        if (!record || !record.root) continue;
        const findOpts: { allow?: string[]; ignoreArbitrary?: boolean } = {};
        if (opts.allow) findOpts.allow = opts.allow;
        if (opts.ignoreArbitrary) findOpts.ignoreArbitrary = true;
        const matches = findUntokenedClasses(record, findOpts);
        if (matches.length === 0) continue;
        const out: ArchaeologyRecord = { file: record.file, componentName: record.componentName, matches };
        writeNdjson(out);
      }
    });

  program
    .command("archaeology")
    .description("Run a named preset (raw-html-containers, raw-list-containers, hardcoded-spacing, hardcoded-color, inline-style, raw-flex-layout, …).")
    .argument("[name]", "Preset name. Omit to list available presets.")
    .option("--root <dir>", "Project root for overlay lookup. Defaults to cwd.")
    .action(async (name: string | undefined, opts: { root?: string }) => {
      const projectRoot = path.resolve(opts.root ?? process.cwd());
      if (!name) {
        for (const p of listPresets({ projectRoot })) {
          process.stdout.write(`${p.name.padEnd(28)}  ${p.description}\n  source: ${p.source}\n\n`);
        }
        return;
      }
      const preset = getPreset({ projectRoot }, name);
      if (!preset) {
        process.stderr.write(`archaeology: preset '${name}' not found. Run \`anvil-inspect archaeology\` (no args) to list available presets.\n`);
        process.exit(2);
      }
      await runFilterPipeline(preset.filter);
    });

  program
    .command("format")
    .description("Sink: pretty-print archaeology NDJSON records.")
    .action(async () => {
      const records = await collectArchaeology();
      process.stdout.write(renderFormat(records));
    });

  program
    .command("count")
    .description("Sink: print the total match count.")
    .action(async () => {
      const records = await collectArchaeology();
      process.stdout.write(`${countMatches(records)}\n`);
    });

  program
    .command("paths")
    .description("Sink: emit `path:line:col  rule: reason` lines (grep-friendly). Accepts archaeology records OR raw trees.")
    .action(async () => {
      if (!hasStdinInput()) {
        process.stderr.write("paths: expects NDJSON on stdin.\n");
        process.exit(1);
      }
      const records: ArchaeologyRecord[] = [];
      const trees: ComponentTree[] = [];
      for await (const record of readNdjson<ArchaeologyRecord | ComponentTree>(process.stdin)) {
        if (record && typeof record === "object" && "matches" in record) {
          records.push(record as ArchaeologyRecord);
        } else if (record && typeof record === "object" && "root" in record) {
          trees.push(record as ComponentTree);
        }
      }
      if (records.length > 0) process.stdout.write(renderPaths(records));
      if (trees.length > 0) process.stdout.write(renderTreePaths(trees));
    });

  program
    .command("rename-component")
    .description("Rename a component identifier across the project — JSX usages, imports, exports, type refs. Co-renames `<Name>Props` by default. Dry-run unless --apply.")
    .requiredOption("--from <oldName>", "Existing component identifier.")
    .requiredOption("--to <newName>", "New component identifier.")
    .option("--root <dir>", "Project root. Defaults to cwd.")
    .option("--no-rename-props", "Do NOT co-rename `<Name>Props`.")
    .option("--apply", "Write changes.")
    .action(async (opts: { from: string; to: string; root?: string; renameProps?: boolean; apply?: boolean }) => {
      const root = path.resolve(opts.root ?? process.cwd());
      const result = await renameComponent({
        oldName: opts.from,
        newName: opts.to,
        root,
        coRenameProps: opts.renameProps !== false,
        apply: Boolean(opts.apply),
      });
      const verb = result.written ? "Rewrote" : "Would rewrite";
      process.stdout.write(`${verb} ${result.totalEdits} edit(s) across ${result.hits.length} file(s):\n`);
      for (const hit of result.hits) {
        const counts = `jsx:${hit.jsxRenames}  imports:${hit.importRenames}  exports:${hit.exportRenames}`;
        process.stdout.write(`  ${hit.filePath}  [${counts}]  lines: ${hit.lines.join(", ")}\n`);
      }
    });

  program
    .command("rename-prop")
    .description("Rename a prop on a component — declaration interface, destructure, body references, every consumer JSX usage. Dry-run unless --apply.")
    .requiredOption("--component <name>", "Component name.")
    .requiredOption("--declaration <path>", "Path to the component's implementation file.")
    .requiredOption("--from <oldProp>", "Existing prop name.")
    .requiredOption("--to <newProp>", "New prop name.")
    .option("--root <dir>", "Project root. Defaults to cwd.")
    .option("--apply", "Write changes.")
    .action(async (opts: { component: string; declaration: string; from: string; to: string; root?: string; apply?: boolean }) => {
      const root = path.resolve(opts.root ?? process.cwd());
      const declarationPath = path.resolve(opts.declaration);
      const result = await renameProp({
        component: opts.component,
        declarationPath,
        oldProp: opts.from,
        newProp: opts.to,
        root,
        apply: Boolean(opts.apply),
      });
      const verb = result.written ? "Rewrote" : "Would rewrite";

      if (result.declaration) {
        const counts = `interface:${result.declaration.edits.interface}  destructure:${result.declaration.edits.destructure}  bodyRefs:${result.declaration.edits.bodyReference}`;
        process.stdout.write(`${verb} declaration ${result.declaration.filePath}  [${counts}]  lines: ${result.declaration.lines.join(", ")}\n`);
      } else {
        process.stdout.write(`No edits in declaration ${path.relative(root, declarationPath)}.\n`);
      }
      process.stdout.write(`${verb} ${result.consumers.totalRenames} JSX attribute(s) across ${result.consumers.hits.length} consumer file(s):\n`);
      for (const hit of result.consumers.hits) {
        process.stdout.write(`  ${hit.filePath}  (lines: ${hit.lines.join(", ")})\n`);
      }
      if (result.notes.length > 0) {
        process.stdout.write("\nNotes:\n");
        for (const note of result.notes) process.stdout.write(`  - ${note}\n`);
      }
    });

  program
    .command("safe-delete")
    .description("Check whether a file is safe to delete (no remaining consumers).")
    .argument("<target>", "Path of the file proposed for deletion.")
    .option("--root <dir>", "Project root. Defaults to cwd.")
    .option("--export <name>", "Filter consumers to those importing this exported name.")
    .action(async (target: string, opts: { root?: string; export?: string }) => {
      const root = path.resolve(opts.root ?? process.cwd());
      const result = await safeDeleteCheck({
        root,
        target: path.resolve(target),
        ...(opts.export ? { exportName: opts.export } : {}),
      });
      process.stdout.write(`${result.summary}\n`);
      for (const c of result.consumers) {
        const ty = c.typeOnly ? " [type-only]" : "";
        process.stdout.write(`  ${c.path}${ty}   uses: ${c.names.join(", ")}\n`);
      }
      if (!result.safe) process.exit(2);
    });

  await program.parseAsync(argv);
  return 0;
}

/* ---------------------------------------------------------------- *
 *  Pipeline helpers                                                  *
 * ---------------------------------------------------------------- */

function buildPredicateFromTag(opts: { tag?: string; tagPattern?: string; tagKind?: string }): FilterPredicate {
  if (opts.tag) return { tag: opts.tag, ruleId: "tag-match", reason: `tag is <${opts.tag}>` };
  if (opts.tagPattern) return { tagPattern: opts.tagPattern, ruleId: "tag-pattern-match", reason: `tag matches /${opts.tagPattern}/` };
  if (opts.tagKind) {
    const kind = opts.tagKind as "html" | "component" | "member" | "dynamic";
    return { tagKind: kind, ruleId: "tag-kind-match", reason: `tag-kind is ${kind}` };
  }
  throw new Error("buildPredicateFromTag: no flag set");
}

/**
 * Read NDJSON from stdin — accepts either raw trees (producer output) or
 * archaeology records (filter output). Apply the predicate and emit
 * archaeology records. Filters compose by reading the previous filter's
 * output and looking inside each existing match for further matches.
 */
async function runFilterPipeline(predicate: FilterPredicate): Promise<void> {
  if (!hasStdinInput()) {
    process.stderr.write("filter: expected NDJSON on stdin (pipe `trees` or another filter into this).\n");
    process.exit(1);
  }
  for await (const record of readNdjson<ComponentTree | ArchaeologyRecord>(process.stdin)) {
    if (!record || typeof record !== "object") continue;
    if ("root" in record && record.root) {
      const tree = record as ComponentTree;
      const matches = findInTree(tree, predicate);
      if (matches.length === 0) continue;
      const out: ArchaeologyRecord = { file: tree.file, componentName: tree.componentName, matches };
      writeNdjson(out);
      continue;
    }
    if ("matches" in record) {
      const arc = record as ArchaeologyRecord;
      const next: ArchaeologyRecord["matches"] = [];
      for (const prior of arc.matches) {
        const inner = findInNodeArray(prior.node, predicate);
        next.push(...inner);
      }
      if (next.length === 0) continue;
      const out: ArchaeologyRecord = { ...arc, matches: next };
      writeNdjson(out);
    }
  }
}

/**
 * Walk a single sub-tree and apply the predicate (used when chaining
 * filters: the second filter searches inside the first filter's matches).
 */
function findInNodeArray(node: import("./types.js").BodyNode, predicate: FilterPredicate): ArchaeologyRecord["matches"] {
  return findInNode(node, predicate);
}

async function collectArchaeology(): Promise<ArchaeologyRecord[]> {
  if (!hasStdinInput()) {
    process.stderr.write("sink: expected NDJSON on stdin.\n");
    process.exit(1);
  }
  const records: ArchaeologyRecord[] = [];
  for await (const record of readNdjson<ArchaeologyRecord>(process.stdin)) {
    if (record && typeof record === "object" && "matches" in record) records.push(record);
  }
  return records;
}

// Direct invocation: `tsx src/cli.ts ...` or `node dist/cli.js ...`
const entry = process.argv[1];
if (entry && (entry.endsWith("cli.ts") || entry.endsWith("cli.js"))) {
  run(process.argv).catch((err: unknown) => {
    process.stderr.write(`anvil-inspect: ${err instanceof Error ? err.stack ?? err.message : String(err)}\n`);
    process.exit(1);
  });
}
