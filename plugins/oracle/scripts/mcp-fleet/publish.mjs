#!/usr/bin/env node
// Tells the user how to wire ~/.claude/oracle/mcp-fleet/mcp-fleet.json
// into Claude Code. Three modes, in order of recommendation:
//
//   1. Project-scoped: copy the mcpServers block into the target project's
//      .mcp.json. Other contributors get the SAME server names but no
//      credentials -- they run their own discovery to populate.
//
//   2. User-scoped: `claude mcp add` per server. One-shot per workspace,
//      lands in ~/.claude.json under your user, available everywhere.
//
//   3. Direct merge: `jq -s '.[0] * .[1]' ~/.claude.json mcp-fleet.json`
//      for power-users who prefer to manage ~/.claude.json by hand.

import { readFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import { fleetHome } from "./lib/profile-dir.mjs";

function main() {
  const fleetPath = join(fleetHome(), "mcp-fleet.json");
  if (!existsSync(fleetPath)) {
    process.stderr.write(
      `No mcp-fleet.json yet. Run discovery first:\n` +
      `  node scripts/mcp-fleet/detect.mjs <service> <label>\n`,
    );
    process.exit(1);
  }
  const config = JSON.parse(readFileSync(fleetPath, "utf8"));
  const names = Object.keys(config.mcpServers);
  if (names.length === 0) {
    process.stdout.write("No servers configured. Run detect.mjs to add some.\n");
    return;
  }

  process.stdout.write(`mcp-fleet.json contains ${names.length} server(s):\n`);
  for (const n of names) process.stdout.write(`  ${n}\n`);
  process.stdout.write(`\n`);

  process.stdout.write(`Mode 1 -- project-scoped (recommended):\n`);
  process.stdout.write(`  Open your project's .mcp.json and merge the mcpServers block from:\n`);
  process.stdout.write(`    ${fleetPath}\n\n`);

  process.stdout.write(`Mode 2 -- user-scoped via the CLI:\n`);
  for (const n of names) {
    const s = config.mcpServers[n];
    // claude mcp add: -e accepts KEY=VALUE pairs (variadic). stdio is
    // the default transport so we omit --transport. The -- separates
    // the server command from claude's own flags. Verified against
    // `claude mcp add --help` on 2026-05-13.
    const envFlags = Object.entries(s.env)
      .filter(([, v]) => v !== "")
      .map(([k, v]) => `-e ${k}='${String(v).replace(/'/g, "'\\''")}'`)
      .join(" ");
    const argFlags = s.args.map((a) => `'${a.replace(/'/g, "'\\''")}'`).join(" ");
    process.stdout.write(
      `  claude mcp add -s user ${envFlags} ${n} -- ${s.command} ${argFlags}\n`,
    );
  }
  process.stdout.write(`\n`);

  process.stdout.write(`Mode 3 -- direct merge into ~/.claude.json:\n`);
  process.stdout.write(`  jq -s '.[0] * {mcpServers: (.[0].mcpServers // {} * .[1].mcpServers)}' ~/.claude.json ${fleetPath} > ~/.claude.json.tmp && mv ~/.claude.json.tmp ~/.claude.json\n\n`);

  process.stdout.write(
    `Reminder: tokens are real credentials. mcp-fleet.json is mode-600 and\n` +
    `must not be committed. Project .mcp.json is committed -- prefer Mode 2\n` +
    `or strip env values before committing if you use Mode 1.\n`,
  );
}

main();
