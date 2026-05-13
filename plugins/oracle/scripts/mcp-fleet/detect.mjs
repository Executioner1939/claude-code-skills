#!/usr/bin/env node
// Entry point for workspace discovery.
//
// Usage:
//   node detect.mjs <service> [label]    Run the OAuth probe for one workspace
//   node detect.mjs --list                List all stored workspaces
//   node detect.mjs --remove <service> <label>   Remove an entry
//   node detect.mjs --help
//
// After every successful probe, build-matrix is re-run automatically so
// ~/.claude/oracle/mcp-fleet/mcp-fleet.json stays in sync with the store.

import { list, remove } from "./lib/workspaces-store.mjs";
import { build as buildMatrix } from "./build-matrix.mjs";

const SERVICES = ["slack", "linear", "notion", "github", "atlassian"];

function usage() {
  process.stdout.write(
    `mcp-fleet detect -- workspace discovery for the oracle MCP fleet.\n\n` +
    `Usage:\n` +
    `  node detect.mjs <service> [label]\n` +
    `  node detect.mjs --list\n` +
    `  node detect.mjs --remove <service> <label>\n\n` +
    `Services: ${SERVICES.join(", ")}\n`,
  );
}

async function main() {
  const args = process.argv.slice(2);
  if (args.length === 0 || args[0] === "--help" || args[0] === "-h") {
    usage();
    return 0;
  }

  if (args[0] === "--list") {
    const all = list();
    if (all.length === 0) {
      process.stdout.write("No workspaces stored yet.\n");
      return 0;
    }
    for (const w of all) {
      process.stdout.write(`${w.service.padEnd(10)} ${w.label.padEnd(20)} ${w.kind}\n`);
    }
    return 0;
  }

  if (args[0] === "--remove") {
    if (args.length < 3) { usage(); return 2; }
    const removed = remove(args[1], args[2]);
    process.stdout.write(removed > 0
      ? `Removed ${args[1]}/${args[2]}\n`
      : `No matching entry for ${args[1]}/${args[2]}\n`);
    if (removed > 0) await buildMatrix();
    return 0;
  }

  const service = args[0];
  const label = args[1];
  if (!SERVICES.includes(service)) {
    process.stderr.write(`Unknown service: ${service}\n`);
    usage();
    return 2;
  }

  const mod = await import(`./services/${service}.mjs`);
  const entry = await mod.probe({ label });
  process.stdout.write(`Persisted ${entry.service}/${entry.label}\n`);
  await buildMatrix();
  process.stdout.write(
    `\nMatrix rebuilt. Next: node scripts/mcp-fleet/publish.mjs\n` +
    `to see how to wire this into Claude Code.\n`,
  );
  return 0;
}

main().then(
  (code) => process.exit(code || 0),
  (e) => { process.stderr.write(`error: ${e.message}\n`); process.exit(1); },
);
