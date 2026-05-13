#!/usr/bin/env node
// Reads ~/.claude/oracle/mcp-fleet/workspaces.json and renders a
// Claude-Code-compatible mcp-fleet.json with one stdio MCP server entry
// per workspace.
//
// Server-name convention: <service>__<label>. Underscore separator avoids
// collision with hyphens commonly used in workspace names. Each entry
// pins the upstream MCP server package version where reasonable; pinning
// is intentional -- unpinned npx versions are oracle's whole reason for
// existing.

import { writeFileSync, mkdirSync } from "node:fs";
import { join } from "node:path";
import { list } from "./lib/workspaces-store.mjs";
import { fleetHome } from "./lib/profile-dir.mjs";

// Per-kind upstream MCP server spec. Pinned versions verified 2026-05-13;
// bump deliberately when upstream releases something material. Each spec
// returns the stdio command + args + env-passthrough keys. The actual env
// values are the workspace's credentials object.

const SPECS = {
  "slack-cookie": (_creds, _label) => ({
    command: "npx",
    args: ["-y", "slack-mcp-server@latest"],
    envKeys: ["SLACK_MCP_XOXC_TOKEN", "SLACK_MCP_XOXD_TOKEN"],
  }),
  "linear-api-key": (_creds, label) => ({
    command: "npx",
    args: ["-y", "@dvcrn/mcp-server-linear@latest"],
    envKeys: ["LINEAR_API_KEY"],
    extraEnv: { TOOL_PREFIX: `linear_${label}_` },
  }),
  "notion-integration": (_creds, _label) => ({
    command: "npx",
    args: ["-y", "@notionhq/notion-mcp-server@latest"],
    envKeys: ["NOTION_TOKEN"],
  }),
  "github-pat": (_creds, _label) => ({
    command: "docker",
    args: [
      "run", "--rm", "-i",
      "-e", "GITHUB_PERSONAL_ACCESS_TOKEN",
      "ghcr.io/github/github-mcp-server:latest",
    ],
    envKeys: ["GITHUB_PERSONAL_ACCESS_TOKEN"],
  }),
  "atlassian-api-token": (_creds, _label) => ({
    command: "npx",
    args: ["-y", "mcp-atlassian@latest"],
    envKeys: [
      "CONFLUENCE_URL", "CONFLUENCE_USERNAME", "CONFLUENCE_API_TOKEN",
      "JIRA_URL", "JIRA_USERNAME", "JIRA_API_TOKEN",
    ],
  }),
};

function serverName(service, label) {
  return `${service}__${label}`.replace(/[^a-zA-Z0-9_]/g, "_");
}

export async function build() {
  const workspaces = list();
  const mcpServers = {};

  for (const w of workspaces) {
    const spec = SPECS[w.kind];
    if (!spec) {
      process.stderr.write(`warning: no upstream-server spec for kind ${w.kind}, skipping ${w.service}/${w.label}\n`);
      continue;
    }
    const s = spec(w.credentials, w.label);
    const env = {};
    for (const k of s.envKeys) {
      if (w.credentials[k] === undefined) {
        process.stderr.write(`warning: ${w.service}/${w.label} missing credential key ${k}, skipping\n`);
        env[k] = "";
      } else {
        env[k] = w.credentials[k];
      }
    }
    Object.assign(env, s.extraEnv || {});
    mcpServers[serverName(w.service, w.label)] = {
      type: "stdio",
      command: s.command,
      args: s.args,
      env,
    };
  }

  const out = {
    "$generated_by": "plugins/oracle/scripts/mcp-fleet/build-matrix.mjs",
    "$generated_at": new Date().toISOString(),
    "$source": join(fleetHome(), "workspaces.json"),
    mcpServers,
  };

  const home = fleetHome();
  mkdirSync(home, { recursive: true });
  const outPath = join(home, "mcp-fleet.json");
  writeFileSync(outPath, JSON.stringify(out, null, 2) + "\n", "utf8");
  return { path: outPath, count: Object.keys(mcpServers).length };
}

if (import.meta.url === `file://${process.argv[1]}`) {
  build().then(
    ({ path, count }) => { process.stdout.write(`Wrote ${count} server(s) to ${path}\n`); process.exit(0); },
    (e) => { process.stderr.write(`error: ${e.message}\n`); process.exit(1); },
  );
}
