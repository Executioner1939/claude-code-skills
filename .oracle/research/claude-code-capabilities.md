# Claude Code Platform Capability Reference

Reference document mapping the public surface of the `claude` CLI for future Oracle skill design. Compiled from `claude` v2.1.140 observable CLI output and the installed `claude-plugins-official/plugin-dev` skill bank at `~/.claude/plugins/cache/claude-plugins-official/plugin-dev/45896c8f2fe6/`. All citations are either `claude … --help` output or that on-disk skill bank; where official documentation URLs apply they are noted.

Convention used below: **D** = officially documented (in `--help` or `docs.claude.com`), **U** = under-documented (present in shipped binary or shipped skill, no public doc page surfaced).

---

## 1. Hooks

### 1.1 Event types

Source: `skills/hook-development/SKILL.md` lines 122-276; quick-reference table lines 632-644.

| Event | Status | Trigger | When to use |
|-------|--------|---------|-------------|
| `PreToolUse` | D | Before any tool runs | Validate / modify / deny tool calls |
| `PostToolUse` | D | After tool completes | React to results, feedback, logging |
| `UserPromptSubmit` | D | User submits a prompt | Inject context, validate prompt |
| `Stop` | D | Main agent considers stopping | Completeness gate |
| `SubagentStop` | D | Subagent considers stopping | Per-subagent completion check |
| `SessionStart` | D | Session begins | Load context, persist env vars |
| `SessionEnd` | D | Session ends | Cleanup, telemetry |
| `PreCompact` | D | Before context compaction | Preserve critical context |
| `Notification` | D | User notification fires | React to system notifications |

All nine are enumerable in `plugin-structure/SKILL.md:229`. No undocumented event names were found in the v2.1.140 binary's shipped skill bank.

### 1.2 Hook type variants

Source: `skills/hook-development/SKILL.md:22-58`.

- `type: "prompt"` (U-ish, present in shipped skill bank, surfaced as "advanced API"): inline LLM-based decisioning. Variables interpolated into the prompt string: `$TOOL_INPUT`, `$TOOL_RESULT`, `$USER_PROMPT`, `$TRANSCRIPT_PATH`. Supported on `Stop`, `SubagentStop`, `UserPromptSubmit`, `PreToolUse` (line 34). Default timeout 30s.
- `type: "command"` (D): execute shell. Default timeout 60s. Reads stdin JSON; writes JSON to stdout, error JSON to stderr.

**When to use prompt:** complex contextual reasoning, security policy interpretation.
**When to use command:** deterministic, fast checks (path traversal, regex, file existence).

### 1.3 Stdin JSON shape

Source: lines 300-320.

Common fields on every hook invocation:
```json
{
  "session_id": "abc123",
  "transcript_path": "/path/to/transcript.txt",
  "cwd": "/current/working/dir",
  "permission_mode": "ask|allow",
  "hook_event_name": "PreToolUse"
}
```

Event-specific additions:
- `PreToolUse` / `PostToolUse`: `tool_name`, `tool_input`, `tool_result`.
- `UserPromptSubmit`: `user_prompt`.
- `Stop` / `SubagentStop`: `reason`.

### 1.4 Output shapes

Source: lines 144-209, 280-298.

Universal envelope:
```json
{ "continue": true, "suppressOutput": false, "systemMessage": "...", "additionalContext": "..." }
```

**PreToolUse-specific:**
```json
{
  "hookSpecificOutput": {
    "permissionDecision": "allow" | "deny" | "ask",
    "updatedInput": { "<field>": "<modified-value>" }
  },
  "systemMessage": "..."
}
```
`permissionDecision` is a tri-valued enum, not a boolean. `updatedInput` mutates the tool call before execution.

**Stop / SubagentStop-specific:**
```json
{ "decision": "approve" | "block", "reason": "...", "systemMessage": "..." }
```

**Exit codes** (lines 294-298):
- `0`: success, stdout shown in transcript
- `2`: blocking error, stderr fed back to Claude
- Other: non-blocking error

### 1.5 Matcher syntax

Source: lines 386-425.

| Syntax | Meaning |
|--------|---------|
| `"Write"` | exact tool name |
| `"Read\|Write\|Edit"` | alternation |
| `"*"` | wildcard, all tools |
| `"mcp__.*__delete.*"` | regex |
| `"mcp__plugin_asana_.*"` | regex prefixing a plugin's MCP tools |

Case-sensitive. Matchers are regex with `|` alternation honoured.

### 1.6 Config format — plugin vs settings

**Plugin format** (`hooks/hooks.json`), wrapper required, lines 60-100:
```json
{ "description": "...", "hooks": { "PreToolUse": [...], "Stop": [...] } }
```

**Settings format** (`.claude/settings.json`), no wrapper, lines 102-117:
```json
{ "PreToolUse": [...], "Stop": [...] }
```

Plugin hooks merge with user hooks and run **in parallel** (line 383). Designs must be order-independent.

### 1.7 Environment variables hooks receive

Source: lines 322-338, plus `--bare` flag output.

| Var | When set | Use |
|-----|----------|-----|
| `$CLAUDE_PROJECT_DIR` | always | project root |
| `$CLAUDE_PLUGIN_ROOT` | plugin hooks | plugin directory; portable path anchor |
| `$CLAUDE_ENV_FILE` | `SessionStart` only | append `export FOO=bar` lines to persist into session env |
| `$CLAUDE_CODE_REMOTE` | remote-control / cloud-agent contexts | gate behaviour in remote runs |
| `$CLAUDE_CODE_SIMPLE` | when invoked under `--bare` | tells hook to short-circuit |

### 1.8 Lifecycle pitfalls

Source: lines 572-598.

Hooks load at session start. Editing `hooks.json` mid-session has no effect — restart `claude`. Use `/hooks` slash command to view loaded hooks. `claude --debug` shows hook registration and timing.

---

## 2. Agents

### 2.1 Frontmatter fields

Source: `skills/agent-development/SKILL.md:52-141`.

| Field | Required | Format | Notes |
|-------|----------|--------|-------|
| `name` | Yes | lowercase + hyphens, 3-50 chars, must start/end alphanumeric | identifier; no underscores |
| `description` | Yes | 10-5000 chars, prose with trigger scenarios | loaded into context for harness dispatch |
| `model` | Yes | `inherit \| sonnet \| opus \| haiku` | prefer `inherit` |
| `color` | Yes | `blue \| cyan \| green \| yellow \| magenta \| red` | UI marker only |
| `tools` | No | array of tool names | omit = all tools; least-privilege recommended |

No additional undocumented frontmatter fields surfaced in the shipped skill bank. The `--agents <json>` CLI flag accepts ad-hoc agent objects with the same shape minus `color`/`model`: `{"name": {"description": "...", "prompt": "..."}}` (citation: `claude --help` line for `--agents <json>`).

### 2.2 Model values

`inherit` (recommended), `sonnet`, `opus`, `haiku`. Full versioned IDs also accepted on `--model` (e.g. `claude-sonnet-4-6`) per top-level `--help`: *"Provide an alias for the latest model (e.g. 'sonnet' or 'opus') or a model's full name (e.g. 'claude-sonnet-4-6')."*

### 2.3 Color enum

Exactly six values: `blue cyan green yellow magenta red` (line 111).

### 2.4 `tools` array semantics

`["Read", "Write", "Grep"]`-style exact strings. Documented examples use bare tool names; no glob form documented at agent level (unlike command `allowed-tools` which supports `Bash(git:*)`). MCP-namespaced tool strings of shape `mcp__plugin_<plugin>_<server>__<tool>` are accepted (see §5.3). Omitting `tools` grants all tools.

### 2.5 Auto-discovery + namespacing

Source: lines 269-286.

- Plugin agents: every `agents/*.md` auto-discovered.
- Subdir nesting: `plugin:subdir:agent-name`.
- Top-level invocation: `plugin:agent-name`.
- User-level agents: `~/.claude/agents/`.

### 2.6 The `agents` subcommand (U)

`claude agents --help` shows only:
```
Manage background and configured agents
Options:
  -h, --help
  --setting-sources <sources>  Comma-separated list of setting sources to load (user, project, local).
```

Subcommand drops the user into an interactive TUI for managing background agents (the cloud-routine / `claude.ai/code/routines` feature referenced in the auto-mode default rules: *"Claude Code Scheduling: …`RemoteTrigger` registers agents with cloud services (claude.ai/code/routines)"*). Read-only research did not exercise the TUI further.

---

## 3. Commands and skills

### 3.1 `commands/` vs `skills/`

Source: `command-development/SKILL.md:9`:
> *"The `.claude/commands/` directory is a legacy format. For new skills, use the `.claude/skills/<name>/SKILL.md` directory format. Both are loaded identically — the only difference is file layout."*

So both are alive; `skills/` is the preferred current layout because a skill directory carries supporting `references/`, `examples/`, `scripts/` subtrees.

Skill directory shape (`plugin-structure/SKILL.md:170-184`):
```
skills/
  skill-name/
    SKILL.md           # required
    scripts/           # optional
    references/        # optional
    examples/          # optional
```

### 3.2 Command frontmatter fields

Source: `command-development/references/frontmatter-reference.md`.

| Field | Type | Default | Notes |
|-------|------|---------|-------|
| `description` | string | first line of prompt | shown in `/help`; <60 chars |
| `allowed-tools` | string or array | inherits from session | restriction list |
| `model` | string | inherits | `sonnet \| opus \| haiku` |
| `argument-hint` | string | none | autocomplete + docs, `[arg1] [arg2]` style |
| `disable-model-invocation` | bool | `false` | when `true`, only user-typed `/cmd` invokes (not the `SlashCommand` tool) |
| `name` | string | filename | skill identifier (SKILL.md only) |
| `version` | string | none | SKILL.md only |

### 3.3 `argument-hint` syntax

Source: `frontmatter-reference.md:196-268`. Square-bracket positional hints, e.g. `[pr-number] [environment] [version]`. Used both for autocomplete in the harness and for inline docs in `/help`.

### 3.4 `allowed-tools` patterns

Source: same file lines 60-128.

- Exact: `Read, Write, Edit`
- Bash command filter: `Bash(git:*)`, `Bash(npm:*)`, `Bash(git status:*)` (fine-grained subcommand restriction)
- All: `*` (discouraged)
- Array form: YAML list of strings
- MCP-namespaced: `mcp__plugin_<plugin>_<server>__<tool>` exact, or `mcp__plugin_<plugin>_<server>__*` wildcard

### 3.5 Variables inside command/skill bodies

Source: `command-development/SKILL.md:212-285`, plus plugin-features-reference.

- `$ARGUMENTS` — entire argument string.
- `$1 $2 $3 …` — positional arguments.
- `@<path>` — file reference (`@$1`, `@${CLAUDE_PLUGIN_ROOT}/templates/foo.md`).
- `!`<bash>`` — inline bash execution (gated by `allowed-tools: Bash(...)`).
- `${CLAUDE_PLUGIN_ROOT}` — plugin directory env var, expanded in markdown body.

### 3.6 Invocation forms

- Bare `/skill-name` (when unambiguous).
- Plugin-namespaced `/plugin:skill-name`.
- Subdir-namespaced `/plugin:subdir:skill-name`.

---

## 4. CLI flags (`claude` binary)

Source: `claude --help`, v2.1.140. Roughly 50 top-level options. The under-documented ones grouped below; the obvious ones (`--model`, `--print`, `--continue`, `--resume`) omitted.

### 4.1 Session-shape flags

| Flag | Status | Purpose |
|------|--------|---------|
| `--bare` | U | Minimal mode: skips hooks, LSP, plugin sync, attribution, auto-memory, background prefetches, keychain reads, CLAUDE.md auto-discovery. Sets `CLAUDE_CODE_SIMPLE=1`. Anthropic auth restricted to `ANTHROPIC_API_KEY` or `apiKeyHelper`. Skills still resolve via `/skill-name`. Use for reproducible, low-state agent runs. |
| `--exclude-dynamic-system-prompt-sections` | U | Move per-machine sections (cwd, env, memory paths, git status) from the system prompt into the first user message. Lets prompt-cache hit across users/machines. Only with default system prompt. |
| `--system-prompt <prompt>` / `--append-system-prompt <prompt>` | D | Replace or append the system prompt. `--bare` requires you to provide context explicitly. |
| `--setting-sources <list>` | U | Comma-separated subset of `user,project,local` to load. Default loads all. Use to bypass user settings in scripted invocations. |
| `--strict-mcp-config` | U | Only use MCP servers from `--mcp-config`, ignoring `.mcp.json` and user MCP config. Use for hermetic agent runs. |
| `--mcp-config <files-or-json>` | D | Load MCP servers from JSON files or inline JSON strings (space-separated). |
| `--agents <json>` | U | Inline ad-hoc agent definitions: `'{"reviewer": {"description": "...", "prompt": "..."}}'`. |
| `--agent <name>` | D | Set agent for current session. |
| `--plugin-dir <path>` / `--plugin-url <url>` | U | Session-only plugin loading from local dir, `.zip`, or URL. Repeatable. |
| `--settings <file-or-json>` | U | Path to settings JSON file or inline JSON string. |
| `--tools <list>` | D | Restrict built-in tools. `""` = none, `"default"` = all, `"Bash,Edit"` = explicit. |
| `--allowedTools` / `--disallowedTools` | D | Allow / deny list with the `Bash(git *)` pattern syntax. |
| `--permission-mode <m>` | D | `acceptEdits \| auto \| bypassPermissions \| default \| dontAsk \| plan`. |
| `--dangerously-skip-permissions` / `--allow-dangerously-skip-permissions` | D | Bypass all permission checks (sandbox-only). |
| `--effort <level>` | U | `low \| medium \| high \| xhigh \| max`. Used by orchestrators; the user's `~/.claude/CLAUDE.md` recommends `xhigh` for planners, `high` for intelligence-heavy work. |

### 4.2 Output and streaming

| Flag | Status | Purpose |
|------|--------|---------|
| `--output-format <fmt>` | D | `text \| json \| stream-json`. Only with `--print`. |
| `--input-format <fmt>` | D | `text \| stream-json`. Only with `--print`. |
| `--include-hook-events` | U | Include hook lifecycle events in stream-json output. Use to build observability for hook execution. |
| `--include-partial-messages` | U | Include partial message chunks in stream-json. For UI consumers wanting token-level streaming. |
| `--replay-user-messages` | U | Re-emit user messages on stdout for ack (`--input-format=stream-json` + `--output-format=stream-json`). Useful for harness wrappers. |
| `--json-schema <schema>` | U | JSON Schema for structured output validation. Forces the model to match a schema. |
| `--max-budget-usd <amt>` | U | USD ceiling for the run (`--print` only). |
| `--fallback-model <model>` | U | Auto-fallback when default overloaded (`--print` only). |

### 4.3 Session continuity

| Flag | Status | Purpose |
|------|--------|---------|
| `--continue` / `-c` | D | Resume most recent conversation in cwd. |
| `--resume [value]` / `-r` | D | Resume by session ID or interactive picker. |
| `--fork-session` | U | When resuming, create a new session ID instead of reusing. Lets you branch a session non-destructively. |
| `--from-pr [num-or-url]` | U | Resume a session linked to a PR. Bridge between PR review and Claude Code. |
| `--session-id <uuid>` | D | Use a specific UUID for the session. |
| `--no-session-persistence` | D | Don't save session (`--print` only). |
| `--name <name>` | D | Display name for picker, terminal title. |

### 4.4 Worktrees / tmux / IDE / remote

| Flag | Status | Purpose |
|------|--------|---------|
| `--worktree [name]` / `-w` | U | Create new git worktree for session. |
| `--tmux[=classic]` | U | Wrap worktree in tmux (or iTerm2 native panes). |
| `--ide` | D | Auto-connect to IDE if exactly one is available. |
| `--chrome` / `--no-chrome` | D | Toggle Claude-in-Chrome integration. |
| `--remote-control [name]` | U | Start interactive session with Remote Control. |
| `--remote-control-session-name-prefix <p>` | U | Prefix for auto-generated remote-control session names. |
| `--brief` | U | Enable `SendUserMessage` tool — agent-to-user comms. Used for background-agent notification flow. |
| `--betas <list>` | U | Beta headers in API requests (API-key users only). |
| `--file <specs>` | U | Download file resources at startup: `file_id:relative_path`. |
| `--add-dir <dirs>` | D | Additional dirs allowed for tool access. |
| `--debug [filter]` / `-d` | D | Debug mode with category filter (`api,hooks`, `!1p,!file`). |
| `--debug-file <path>` | U | Write debug logs to a specific file. |

### 4.5 Subcommand `--help` summaries

| Subcommand | Key flags / commands |
|------------|----------------------|
| `claude agents` | `--setting-sources`; interactive TUI for background/configured agents |
| `claude auto-mode` | `config`, `defaults`, `critique [--model <m>]` — inspect and critique the auto-mode classifier (the ALLOW/SOFT_DENY/HARD_DENY/ENVIRONMENT ruleset shown by `claude auto-mode defaults`) |
| `claude doctor` | health-check the auto-updater |
| `claude install [target] [--force]` | install native build; target = `stable \| latest \| <version>` |
| `claude mcp` | `add`, `add-json`, `add-from-claude-desktop`, `get`, `list`, `remove`, `reset-project-choices`, `serve` |
| `claude plugin` | `details`, `disable`, `enable`, `install [-s scope]`, `list`, `marketplace`, `prune`, `tag`, `uninstall`, `update`, `validate` |
| `claude plugin marketplace` | `add [--scope] [--sparse <paths>]`, `list`, `remove`, `update` |
| `claude project purge [path]` | delete all Claude state for a project |
| `claude setup-token` | long-lived auth token (subscription users) |
| `claude ultrareview [target] [--json] [--timeout <min>]` | cloud-hosted multi-agent code review; target = branch / PR number / base branch |
| `claude update` | check for updates and install |

### 4.6 `claude mcp add` flags

Source: `claude mcp add --help`.

```
--transport <stdio|sse|http>
--callback-port <port>          # OAuth callback (fixed port for pre-registered redirects)
--client-id <id>                # OAuth client ID
--client-secret                 # prompt; or MCP_CLIENT_SECRET env
-e, --env <KEY=val>             # stdio only
-H, --header <Header: val>      # HTTP/SSE headers
-s, --scope <local|user|project>
```

`claude mcp serve` exposes Claude Code itself as an MCP server (so other clients can talk to it).

### 4.7 Auto-mode rule machinery (U)

`claude auto-mode defaults` emits a JSON document with four arrays — `allow`, `soft_deny`, `hard_deny`, `environment` — describing the harness's autonomous-execution classifier. Each entry is a free-text rule name + paragraph. Users can override via `~/.claude/settings.json` under `autoMode` (inferred from `auto-mode config` semantics: *"the effective auto mode config: your settings where set, defaults otherwise"*). The HARD_DENY list (Data Exfiltration, Safety-Check Bypass) is the absolute ceiling. SOFT_DENY rules become permission-prompts; ALLOW rules silently pass. `auto-mode critique --model opus` runs an LLM critique against custom rules.

---

## 5. Plugin manifests

### 5.1 `plugin.json` fields

Source: `plugin-structure/SKILL.md:50-108`.

Required:
- `name` — kebab-case, unique.

Recommended:
- `version` — semver
- `description`
- `author` — object: `{ name, email, url }` or string
- `homepage`, `repository`, `license`, `keywords[]`

Component overrides (supplement defaults, do not replace):
- `commands` — string or string[] of `./relative/dir`
- `agents` — string or string[]
- `hooks` — path to `hooks.json`
- `mcpServers` — path to MCP JSON or inline object

All paths must start with `./`.

### 5.2 `marketplace.json` fields

Source: working example at `/Users/skunkworks/Documents/Work/Personal/claude-code-skills/.claude-plugin/marketplace.json`.

Top-level:
```json
{
  "name": "<marketplace-name>",
  "owner": { "name": "...", "email": "..." },
  "metadata": { "description": "...", "version": "...", "pluginRoot": "./plugins" },
  "plugins": [ ... ]
}
```

Per-plugin entry:
- `name`, `source` (relative path), `description`, `version`, `category`, `keywords[]`, `author`, `homepage`, `repository`, `license`.

`claude plugin marketplace add --sparse <paths>` does git sparse-checkout for monorepo marketplaces.

`claude plugin tag` creates a `{name}--v{version}` tag and validates that `plugin.json` and the marketplace entry agree on version — the user's own CHANGELOG-in-same-commit convention dovetails with this.

### 5.3 `.mcp.json` (and inline `mcpServers`)

Source: `mcp-integration/SKILL.md`.

Transport types:

| Type | Discriminator | Fields |
|------|---------------|--------|
| stdio (default) | omit `type` or `"stdio"` | `command`, `args[]`, `env{}` |
| SSE | `"type": "sse"` | `url`, optional `headers{}` |
| HTTP | `"type": "http"` | `url`, `headers{}` |
| WebSocket | `"type": "ws"` | `url`, `headers{}` |

Env interpolation: `${CLAUDE_PLUGIN_ROOT}` (plugin dir) and `${USER_ENV_VAR}` (from shell). Use the former for portable paths, the latter for secrets.

MCP tool name shape: `mcp__plugin_<plugin>_<server>__<tool>`. Pre-allowing with `allowed-tools` accepts exact names or `mcp__plugin_<plugin>_<server>__*` wildcards.

---

## 6. Less-obvious capabilities

### 6.1 `--bare` mode

What `--bare` switches **off**: hooks, LSP, plugin sync, attribution, auto-memory, background prefetches, keychain reads, CLAUDE.md auto-discovery. What it **preserves**: skills resolved via `/skill-name`. What it **constrains**: Anthropic auth is strictly `ANTHROPIC_API_KEY` or `apiKeyHelper`; never OAuth or keychain.

When to use: hermetic / reproducible agent runs, CI invocations, parent-orchestrator subprocess calls. Pair with explicit `--system-prompt[-file]`, `--add-dir`, `--mcp-config`, `--settings`, `--agents`, `--plugin-dir`.

### 6.2 `--agents <json>` inline definitions

Shape (citation: `claude --help`):
```json
{ "reviewer": { "description": "Reviews code", "prompt": "You are a code reviewer" } }
```

Use to spin up ephemeral agents inside a `--print` invocation without writing files. The harness still namespaces them so `Task` tool calls can address them.

### 6.3 `--mcp-config` vs `.mcp.json`

`.mcp.json` is project- or plugin-scoped, loaded automatically. `--mcp-config` is per-invocation; combined with `--strict-mcp-config`, it suppresses all other MCP sources. Use the strict combination for hermetic agent runs that must not pull in user-configured servers.

### 6.4 `--include-partial-messages`

Token-level streaming via `--output-format=stream-json`. For consumers building progress bars or live transcripts. No effect outside `--print`.

### 6.5 `--effort` levels

Five levels: `low medium high xhigh max`. From the user's `~/.claude/CLAUDE.md`: *"effort defaults: xhigh for orchestrators and planners, high for most intelligence-sensitive work."* `max` exists for the heaviest synthesis tasks.

### 6.6 `--exclude-dynamic-system-prompt-sections`

Moves per-machine sections (cwd, env info, memory paths, git status) into the first user message. Result: the static system prompt becomes identical across users → prompt-cache reuse across teams / CI runs. Only applies when not using `--system-prompt`. Use for: shared marketplace skills, CI agents where the system prompt is otherwise volatile.

### 6.7 `--brief` and background-agent comms

Enables the `SendUserMessage` tool, the channel agents use to surface progress to the user while running in the background. Pairs with `claude agents` TUI and the `claude.ai/code/routines` cloud-routine endpoint (referenced in `auto-mode defaults` under "Claude Code Scheduling"). When to use: any long-running background agent that needs to notify mid-run.

### 6.8 `--from-pr` and `--fork-session`

`--from-pr` opens a session linked to a PR (number or URL) — the harness pre-loads PR context (diff, comments, CI status). `--fork-session` lets you resume a transcript without overwriting it; the new session gets a fresh UUID. Use the pair for parallel hypothesis exploration over a single transcript.

### 6.9 `--worktree` + `--tmux`

`--worktree [name]` creates a git worktree at session start; `--tmux` wraps it in tmux (or iTerm2 native panes with `--tmux=classic` for traditional tmux). The combination is the standard pattern for the user's `rust-monorepo-orchestrator` plugin's per-session sandbox approach.

### 6.10 `--remote-control`

Starts an interactive session with Remote Control — observable in `$CLAUDE_CODE_REMOTE` inside hooks (line 329 of hook-development skill). `--remote-control-session-name-prefix` lets you tag sessions for fleet management.

### 6.11 `claude auto-mode critique`

Validates a user's custom auto-mode rules against an LLM (default model, override with `--model`). Use to sanity-check a `~/.claude/settings.json` `autoMode` override before committing it.

### 6.12 `claude plugin details <name>`

Prints a plugin's component inventory and projected token cost. Use for cost auditing before enabling a heavy plugin. (Citation: `claude plugin --help`.)

### 6.13 `claude plugin tag`

Creates `{name}--v{version}` git tag, validating that `plugin.json` and any enclosing marketplace entry agree on the version. The marketplace repo convention in the user's `~/.claude/CLAUDE.md` — *"every plugin version bump in `plugin.json` must update `CHANGELOG.md` in the same commit"* — composes with this: tag after the bump+changelog commit.

### 6.14 `claude ultrareview`

Cloud-hosted multi-agent code review. Targets: current branch (no arg), a base branch name, or a PR number. `--json` for machine-consumable bugs payload, `--timeout <min>` for runaway protection (default 30 minutes).

---

## Appendix A — Verification commands used

| Output | Command |
|--------|---------|
| Top-level flags | `claude --help` |
| Subcommand inventory | `claude {agents,auto-mode,plugin,mcp,project,doctor,install,ultrareview} --help` |
| Plugin commands | `claude plugin {marketplace,install,validate,details} --help` |
| MCP add | `claude mcp {add,add-json,serve} --help` |
| Marketplace add | `claude plugin marketplace add --help` |
| Auto-mode defaults | `claude auto-mode defaults` |
| Hook event canon | `~/.claude/plugins/cache/claude-plugins-official/plugin-dev/45896c8f2fe6/skills/hook-development/SKILL.md` |
| Agent frontmatter canon | `…/plugin-dev/.../skills/agent-development/SKILL.md` |
| Command frontmatter canon | `…/plugin-dev/.../skills/command-development/references/frontmatter-reference.md` |
| Plugin structure canon | `…/plugin-dev/.../skills/plugin-structure/SKILL.md` |
| MCP canon | `…/plugin-dev/.../skills/mcp-integration/SKILL.md` |

## Appendix B — External authoritative sources

- Official docs: `https://docs.claude.com/en/docs/claude-code/`
- Hooks page: `https://docs.claude.com/en/docs/claude-code/hooks`
- MCP page: `https://docs.claude.com/en/docs/claude-code/mcp`
- Opus 4.7 best practices: `https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-4-best-practices`
- MCP spec: `https://modelcontextprotocol.io/`
