// Single source of truth for discovered workspaces. Lives at
// $ORACLE_MCP_FLEET_HOME/workspaces.json (default
// ~/.claude/oracle/mcp-fleet/workspaces.json). Never committed.
//
// Schema:
// {
//   "version": 1,
//   "workspaces": [
//     {
//       "service": "slack" | "linear" | "notion" | "github" | "atlassian",
//       "label": "<user-chosen identifier, used as namespace name>",
//       "kind":  "slack-cookie" | "linear-api-key" | "notion-integration"
//              | "github-pat" | "atlassian-api-token",
//       "credentials": { ...service-specific token fields },
//       "profileDir": "<path to chrome user-data-dir for this workspace>",
//       "createdAt": "<ISO 8601>"
//     }
//   ]
// }
//
// The credentials object is service-specific so consuming MCP servers can
// drop their fields into env without re-shaping. Persistence is mode-600.

import { readFileSync, writeFileSync, existsSync, chmodSync } from "node:fs";
import { join } from "node:path";
import { platform } from "node:os";
import { ensureFleetHome, profileDir } from "./profile-dir.mjs";

function storePath() {
  return join(ensureFleetHome(), "workspaces.json");
}

export function readStore() {
  const path = storePath();
  if (!existsSync(path)) {
    return { version: 1, workspaces: [] };
  }
  const text = readFileSync(path, "utf8");
  try {
    const parsed = JSON.parse(text);
    if (!Array.isArray(parsed.workspaces)) {
      throw new Error("workspaces field must be an array");
    }
    return parsed;
  } catch (e) {
    throw new Error(`workspaces.json is corrupt (${e.message}). Fix or delete: ${path}`);
  }
}

export function writeStore(store) {
  const path = storePath();
  writeFileSync(path, JSON.stringify(store, null, 2) + "\n", "utf8");
  if (platform() !== "win32") {
    try { chmodSync(path, 0o600); } catch { /* perms best-effort */ }
  }
}

// Insert or replace a workspace entry. (service, label) is the unique key.
// profileDir is auto-derived from (service, label) via profile-dir.mjs so
// callers don't need to know the path layout.
export function upsert(entry) {
  const required = ["service", "label", "kind", "credentials"];
  for (const k of required) {
    if (!entry[k]) throw new Error(`workspace entry missing required field: ${k}`);
  }
  const store = readStore();
  const idx = store.workspaces.findIndex(
    (w) => w.service === entry.service && w.label === entry.label,
  );
  const enriched = {
    ...entry,
    profileDir: entry.profileDir || profileDir(entry.service, entry.label),
    createdAt: entry.createdAt || new Date().toISOString(),
  };
  if (idx >= 0) {
    store.workspaces[idx] = enriched;
  } else {
    store.workspaces.push(enriched);
  }
  writeStore(store);
  return enriched;
}

export function remove(service, label) {
  const store = readStore();
  const before = store.workspaces.length;
  store.workspaces = store.workspaces.filter(
    (w) => !(w.service === service && w.label === label),
  );
  writeStore(store);
  return before - store.workspaces.length;
}

export function list({ service } = {}) {
  const store = readStore();
  return service
    ? store.workspaces.filter((w) => w.service === service)
    : store.workspaces;
}

export function get(service, label) {
  return readStore().workspaces.find(
    (w) => w.service === service && w.label === label,
  );
}
