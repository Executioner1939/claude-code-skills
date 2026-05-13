---
name: mcp-fleet
description: 'This skill should be used when the user explicitly invokes `/oracle:mcp-fleet` to set up, extend, or wire multi-workspace MCP server access from Claude Code. Drives a Chrome-profile-isolated OAuth/token discovery flow per workspace (Slack, Linear, Notion, GitHub orgs, Atlassian sites), persists credentials to a mode-600 store under ~/.claude/oracle/mcp-fleet/, builds a Claude-Code-native multi-server .mcp.json, and prints copy-pasteable wiring instructions. Sidesteps the OAuth-token-collision bugs in anthropics/claude-code#39952, microsoft/vscode#293533, and atlassian/atlassian-mcp-server#23 by giving every workspace its own Chromium --user-data-dir and per-instance API tokens. Triggers on the literal slash-command form. Subcommands: list, add <service> [label], remove <service> <label>, build, publish.'
argument-hint: '[list | add <service> [label] | remove <service> <label> | build | publish]'
allowed-tools: Bash, Read
---

# /oracle:mcp-fleet

Multi-workspace MCP plumbing for Claude Code. Discovers per-workspace
credentials in isolated Chrome profiles (so OAuth providers can't
collide them), generates a multi-server `.mcp.json`, and prints how to
wire it.

## Why this exists

Vendor remote MCP servers and Claude Code's OAuth handling both share a
documented limitation: OAuth tokens are keyed by server-name or by
URL-origin and **collapse across workspaces** -- authenticating into
the second Slack workspace overwrites the first. Filed bugs:
`anthropics/claude-code#39952`, `microsoft/vscode#293533`,
`atlassian/atlassian-mcp-server#23`. The official Atlassian workaround
is "use separate browser profiles per site".

This skill operationalises that workaround. Every workspace gets its
own Chromium `--user-data-dir` for the OAuth flow, and we extract
**per-instance API tokens** (xoxc/xoxd, `lin_api_*`, `secret_*`,
`github_pat_*`, Atlassian API token) so the resulting `.mcp.json`
stores credentials in `env` rather than relying on Claude Code's
collision-prone OAuth keyring.

## Inputs

`$ARGUMENTS` selects the subcommand. Default is `list`.

## What this skill does

Run the steps below in order. State what is happening at each step so
the user can interrupt if something looks wrong.

### Step 1 -- Resolve the plugin script root

```bash
SCRIPT_ROOT=""

if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -d "$CLAUDE_PLUGIN_ROOT/scripts/mcp-fleet" ]; then
  SCRIPT_ROOT="$CLAUDE_PLUGIN_ROOT/scripts/mcp-fleet"
fi

if [ -z "$SCRIPT_ROOT" ]; then
  PLUGIN_PATH=$(find "$HOME/.claude/plugins/cache" -maxdepth 3 -type d -path "*/oracle/*" 2>/dev/null | sort -V | tail -1)
  if [ -n "$PLUGIN_PATH" ] && [ -d "$PLUGIN_PATH/scripts/mcp-fleet" ]; then
    SCRIPT_ROOT="$PLUGIN_PATH/scripts/mcp-fleet"
  fi
fi

if [ -z "$SCRIPT_ROOT" ]; then
  echo "Could not resolve oracle plugin script root." >&2
  exit 1
fi
```

State the resolved path. Confirm Node is on PATH (`node --version`,
require >= 18).

### Step 2 -- Dispatch on the subcommand

Parse `$ARGUMENTS`. Recognised forms:

| Subcommand | Underlying call |
|------------|-----------------|
| `list` (or empty) | `node "$SCRIPT_ROOT/detect.mjs" --list` |
| `add <service> [label]` | `node "$SCRIPT_ROOT/detect.mjs" <service> [label]` |
| `remove <service> <label>` | `node "$SCRIPT_ROOT/detect.mjs" --remove <service> <label>` |
| `build` | `node "$SCRIPT_ROOT/build-matrix.mjs"` |
| `publish` | `node "$SCRIPT_ROOT/publish.mjs"` |

`<service>` must be one of: `slack`, `linear`, `notion`, `github`,
`atlassian`. `<label>` is a user-chosen identifier used as the MCP
server-name suffix (e.g. `acme-prod` produces `slack__acme-prod`).

For `add`, the script will launch a headed Chrome window with an
isolated profile dir under
`~/.claude/oracle/mcp-fleet/chrome-profiles/<service>/<label>/`. The
user signs in to **the one workspace** they want to bind to that
label, then either pastes the resulting token at the prompt or, for
Slack, lets the script auto-extract the cookie. Tokens land in
`~/.claude/oracle/mcp-fleet/workspaces.json` (mode 600).

After every `add` and `remove`, `build-matrix.mjs` re-runs
automatically and rewrites `~/.claude/oracle/mcp-fleet/mcp-fleet.json`.

### Step 3 -- Run the requested subcommand and stream output

Run the resolved command. Do not buffer -- the discovery flow is
interactive and the user must see prompts in real time.

```bash
node "$SCRIPT_ROOT/<resolved-script>" <args>
```

If the command exits non-zero, surface the stderr message verbatim and
stop -- do not retry without user direction.

### Step 4 -- After a successful add or build, recommend `publish`

Tell the user:

> Discovery complete. Run `/oracle:mcp-fleet publish` to see the three
> ways to wire `mcp-fleet.json` into Claude Code.

For `publish` itself, just print the script's output -- it is the
wiring instructions.

## Per-service notes

**Slack.** Uses cookie extraction (`d` cookie + `boot_data.api_token`)
because Slack's MCP-eligible apps must be Marketplace-published.
Compatible with `slack-mcp-server` (korotovsky). No app registration
needed.

**Linear.** Personal API key per workspace. The Linear UI shows the
key value once at creation -- the script cannot re-extract a forgotten
key. Compatible with `@dvcrn/mcp-server-linear`, with `TOOL_PREFIX`
auto-set to `linear_<label>_` so concurrent workspaces don't collide
on tool names.

**Notion.** Internal integration token per workspace. The user must
share at least one page or database with the integration after creating
it, or the MCP server will see an empty workspace.

**GitHub.** One fine-grained PAT per org, scoped to that org's
resource owner. Multiple orgs = multiple tokens = multiple MCP server
instances. Recommended scopes: Contents R, Issues RW, Pull requests RW,
Metadata R. The matrix uses the official Docker image
`ghcr.io/github/github-mcp-server`; if Docker is unavailable, swap to
the Go binary install path manually.

**Atlassian.** API token + email + site URL per Cloud site. Uses
`mcp-atlassian` (sooperset) for per-instance auth, sidestepping
`atlassian/atlassian-mcp-server#23`.

## Storage layout

```
~/.claude/oracle/mcp-fleet/
├── workspaces.json              # source of truth, mode 600
├── mcp-fleet.json               # generated, .mcp.json-compatible
└── chrome-profiles/
    ├── slack/
    │   ├── acme-prod/           # one profile per (service, label)
    │   └── personal/
    ├── linear/
    │   └── acme/
    ...
```

## Failure modes and recovery

If a Chrome profile gets stuck (cookies expired, two-factor changed),
delete its directory under `chrome-profiles/<service>/<label>/` and
re-run `/oracle:mcp-fleet add <service> <label>` -- a fresh profile
will be created.

If `workspaces.json` becomes corrupt, the store will refuse to load
and detect.mjs will print the path. Fix the JSON or delete and
re-discover.

If `mcp-fleet.json` is missing keys after `build`, the matrix builder
emits warnings to stderr -- the most common cause is a partial `add`
that exited mid-flow. Re-run `add` for that workspace.

## Caveats

- Per-service token-extraction is best-effort. Vendors change DOM and
  flash-modal behaviour without notice. The scripts always fall back
  to manual paste at a prompt.
- Pinned upstream MCP server versions in `build-matrix.mjs` are
  verified at the date noted there; bump deliberately.
- v0 wires every workspace as its own stdio child process under Claude
  Code. With many workspaces this becomes a footprint cost. v1 will
  optionally route through a single MetaMCP container -- the
  experimental scaffold lives at
  `scripts/mcp-fleet/templates/docker-compose.yml.tmpl`.
