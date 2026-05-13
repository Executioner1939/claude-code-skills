// Cross-platform isolated Chrome --user-data-dir resolver.
//
// Each (service, workspace) pair gets its own profile dir under
// ~/.claude/oracle/chrome-profiles/<service>/<workspace-id>/.
// Profile isolation is the load-bearing primitive that sidesteps the
// OAuth-token-collision bugs documented in:
//   - anthropics/claude-code#39952 (CC stores OAuth under one global key)
//   - microsoft/vscode#293533       (VS Code keys OAuth by URL origin only)
//   - atlassian/atlassian-mcp-server#23 (server-side OAuth cache collision)
//
// Chrome >=136 forbids CDP automation against its default user-data-dir,
// so we never reuse the user's main profile. Always a fresh dir under
// our own root, with 700 perms.

import { homedir, platform } from "node:os";
import { mkdirSync, chmodSync, existsSync } from "node:fs";
import { join, resolve } from "node:path";

const ROOT_ENV = "ORACLE_MCP_FLEET_HOME";

export function fleetHome() {
  const override = process.env[ROOT_ENV];
  if (override) return resolve(override);
  return join(homedir(), ".claude", "oracle", "mcp-fleet");
}

export function profilesRoot() {
  return join(fleetHome(), "chrome-profiles");
}

// Lower-case alnum + dash only. Anything else -> '-'. Avoids path traversal
// and Windows reserved-name collisions (CON, PRN, etc. won't survive the
// filter because they get suffixed with the workspace identity in the call site).
function sanitize(component) {
  return String(component)
    .toLowerCase()
    .replace(/[^a-z0-9-]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 64) || "default";
}

export function profileDir(service, workspaceId) {
  const dir = join(profilesRoot(), sanitize(service), sanitize(workspaceId));
  if (!existsSync(dir)) {
    mkdirSync(dir, { recursive: true });
    // chmod is a no-op on Windows; harmless.
    if (platform() !== "win32") {
      try { chmodSync(dir, 0o700); } catch { /* perms best-effort */ }
    }
  }
  return dir;
}

export function ensureFleetHome() {
  const root = fleetHome();
  if (!existsSync(root)) {
    mkdirSync(root, { recursive: true });
    if (platform() !== "win32") {
      try { chmodSync(root, 0o700); } catch { /* perms best-effort */ }
    }
  }
  return root;
}
