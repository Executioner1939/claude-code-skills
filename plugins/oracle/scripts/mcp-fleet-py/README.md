# mcp-fleet (Python TUI)

Textual full-screen wizard for binding multiple workspaces of Slack, Linear,
Notion, GitHub, and Atlassian to Claude Code as isolated MCP servers.

Each (service, label) pair gets its own Chrome `--user-data-dir`, sidesteps
provider OAuth-cache collisions, and lands as a stdio MCP server in
`~/.claude.json` via `claude mcp add`.

## Run

```bash
./mcp-fleet            # bootstraps uv if missing, syncs deps, launches TUI
```

Or directly:

```bash
uv run mcp-fleet
```

## State

- `~/.claude/oracle/mcp-fleet/workspaces.json` — bound credentials (mode 600).
- `~/.claude/oracle/mcp-fleet/mcp-fleet.json` — rendered MCP server matrix.
- `~/.claude/oracle/mcp-fleet/chrome-profiles/<service>/<label>/` — isolated
  browser profiles per workspace.

Backward-compatible with the Node-based `mcp-fleet/` sibling — same schema,
same paths.
