# Eval 4 — Full, Advanced, and Under-Documented Capabilities of Claude Code

Sources are cited inline as `URL` for public docs (canonical host `code.claude.com` — note that `docs.claude.com/en/docs/claude-code/*` 301-redirects to `code.claude.com/docs/en/*`) and `path:line` for local cache reads. CLI introspection was run on Claude Code `2.1.140` (build hash `45896c8f2fe6`).

## Executive summary

Claude Code in 2.1.140 is no longer just an interactive REPL plus a hooks file. It is a layered runtime with a typed event bus (29 hook events, not 9; `code.claude.com/docs/en/hooks`), a configurable agent system with worktree-level isolation and persistent agent memory, a skills runtime with progressive disclosure plus dynamic shell injection in YAML, an experimental multi-Claude orchestration mode (`agent-teams`) using a shared task list and inter-agent `SendMessage`, an LSP/Monitor/Theme/Channel plugin model, an auto-mode classifier that runs as a server-side guardrail layered on top of permission rules, and full Python and TypeScript SDKs that share the same agent loop. Most of the underdocumented surface area lives in three places: (1) hook events beyond the legacy nine (`TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `InstructionsLoaded`, `CwdChanged`, `FileChanged`, `Elicitation`, `PermissionRequest`, `PermissionDenied`, `PostToolBatch`, `StopFailure`, `TeammateIdle`, `Setup`); (2) plugin manifest extensions (`userConfig`, `channels`, `experimental.monitors`, `experimental.themes`, `bin/` PATH injection, `${CLAUDE_PLUGIN_DATA}`); (3) flags absent from `claude --help` (`--init-only`, `--maintenance`, `--max-turns`, `--bg`, `--channels`, `--dangerously-load-development-channels`, `--teleport`, `--teammate-mode`, `--system-prompt-file`, `--append-system-prompt-file`, `--permission-prompt-tool`, `--remote`). For an oracle-class plugin the four highest-leverage surfaces are: prompt hooks on the new `PostToolBatch` and `PermissionDenied` events, `${CLAUDE_PLUGIN_DATA}` for persistent state across plugin updates, `agent: <type>` plus `skills:` preloading for subagent specialization, and the SDK's callback-based `HookCallback` for in-process verification.

---

## A. Hooks

The hook system in 2.1.140 is far larger than the public quickstart guide implies. The reference page enumerates **29** events, not the 9 commonly cited in tutorials.

### A.1 All hook events

Source: `code.claude.com/docs/en/hooks`. Cross-checked against plugin reference at `code.claude.com/docs/en/plugins-reference` and local cache at `/Users/skunkworks/.claude/plugins/cache/claude-plugins-official/plugin-dev/45896c8f2fe6/skills/hook-development/SKILL.md:7-712`.

| Event | Matcher type | Can block? | Primary use |
|---|---|---|---|
| `SessionStart` | `startup` \| `resume` \| `clear` \| `compact` | No (stderr to user only) | Load context, write `CLAUDE_ENV_FILE` |
| `Setup` | `init` \| `maintenance` | No | One-time CI/script setup (triggered by `--init`, `--maintenance`, `--init-only`) |
| `UserPromptSubmit` | none | Yes (`decision: "block"` or exit 2) | Add context, validate prompts |
| `UserPromptExpansion` | command name | Yes | Intercept slash command expansion before model sees it |
| `PreToolUse` | tool name, pipe, regex, `mcp__*` | Yes (`permissionDecision: allow\|deny\|ask\|defer`) | Validate or rewrite tool calls |
| `PermissionRequest` | tool name | Yes (`decision.behavior: allow\|deny`) | Custom permission UI |
| `PermissionDenied` | tool name | No (use JSON `retry: true`) | Tell model it may retry after auto-mode denial |
| `PostToolUse` | tool name | Stops loop (`decision: "block"`) | React to tool output |
| `PostToolUseFailure` | tool name | Stops loop | React to tool error |
| `PostToolBatch` | none | Stops loop | Fires once per full batch of parallel tool calls, before next model call |
| `Notification` | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_*` | No | Observability |
| `SubagentStart` | agent type | No | Inject context into subagent start |
| `SubagentStop` | agent type | Yes (`decision: "block"`) | Validate subagent completion |
| `TaskCreated` | none | Yes (`continue: false` or exit 2) | Veto task list entries |
| `TaskCompleted` | none | Yes | Prevent premature completion |
| `Stop` | none | Yes | Prevent agent from stopping (test-run-enforcement pattern) |
| `StopFailure` | `rate_limit`, `authentication_failed`, `oauth_org_not_allowed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` | No | Observe API errors |
| `TeammateIdle` | none | Yes (`continue: false`) | Force agent-team teammate to keep working |
| `InstructionsLoaded` | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` | No | Observe CLAUDE.md / `.claude/rules/*.md` loading |
| `ConfigChange` | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` | Yes (except `policy_settings`) | Veto config changes |
| `CwdChanged` | none | No (writes `CLAUDE_ENV_FILE`) | direnv-style env updates on `cd` |
| `FileChanged` | literal filenames (`.envrc\|.env`) | No (writes `CLAUDE_ENV_FILE`) | Reactive env reload |
| `WorktreeCreate` | none | Yes (any non-zero exit fails) | Override default git worktree creation; write `worktreePath` to stdout |
| `WorktreeRemove` | none | No | Custom cleanup |
| `PreCompact` | `manual` \| `auto` | Yes | Inject must-preserve content before compaction |
| `PostCompact` | `manual` \| `auto` | No | Observe compaction |
| `Elicitation` | MCP server name | Yes (`action: accept\|decline\|cancel`) | Auto-fill MCP form prompts |
| `ElicitationResult` | MCP server name | Yes | Modify response before it returns to MCP server |
| `SessionEnd` | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` | No | Cleanup, logging |

Citation: `code.claude.com/docs/en/hooks` (event list). The legacy 9 events documented in plugin-dev `SKILL.md` are a subset; events 10–29 are post-2.1 additions.

### A.2 Common input fields (stdin JSON)

All events receive at minimum:

```json
{
  "session_id": "string",
  "transcript_path": "string",
  "cwd": "string",
  "hook_event_name": "string",
  "permission_mode": "default|plan|acceptEdits|auto|dontAsk|bypassPermissions",
  "effort": { "level": "low|medium|high|xhigh|max" }
}
```

In subagent contexts also: `agent_id`, `agent_type`. Source: `code.claude.com/docs/en/hooks` (Common Input Fields section).

### A.3 Output JSON schema — universal fields

Every event accepts the universal envelope:

```json
{
  "continue": true,
  "stopReason": "shown when continue=false",
  "suppressOutput": false,
  "systemMessage": "warning shown to user",
  "decision": "block",
  "reason": "explanation",
  "hookSpecificOutput": {
    "hookEventName": "<event>",
    "<event-specific fields>": "..."
  }
}
```

Per-event `hookSpecificOutput` fields:

| Event | Per-event hookSpecificOutput keys |
|---|---|
| `SessionStart`, `Setup`, `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `SubagentStart`, `SubagentStop` | `additionalContext` |
| `UserPromptSubmit` (only) | also `sessionTitle` |
| `PreToolUse` | `permissionDecision: allow\|deny\|ask\|defer`, `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| `PermissionRequest` | `decision: { behavior: allow\|deny, updatedInput }` |
| `PermissionDenied` | `retry: true` |
| `WorktreeCreate` | `worktreePath` |
| `Elicitation`, `ElicitationResult` | `action: accept\|decline\|cancel`, `content: {...}` |

The `permissionDecision: "defer"` value is undocumented in most tutorials — it explicitly hands the decision to the auto-mode classifier rather than blocking or allowing. Source: `code.claude.com/docs/en/hooks` (PreToolUse Output section).

### A.4 Hook types

Five hook types beyond `command` (most tutorials only mention `command` + `prompt`):

| Type | Description | Required fields |
|---|---|---|
| `command` | Shell command with JSON on stdin | `command`, optional `args` (exec form), `shell: bash\|powershell`, `async`, `asyncRewake` |
| `http` | HTTP POST with JSON body | `url`, optional `headers` (with `$VAR` interpolation), `allowedEnvVars` |
| `mcp_tool` | Call a tool on a configured MCP server | `server`, `tool`, optional `input` |
| `prompt` | Single-turn LLM yes/no | `prompt` (with `$ARGUMENTS` for full JSON input), optional `model` |
| `agent` | Experimental: spawn subagent with tools for verification | (schema not stable) |

Source: `code.claude.com/docs/en/hooks` (Hook Type Values table). The `async` and `asyncRewake` fields on command hooks are nearly undocumented — `async` fires the command in background without blocking the model loop; `asyncRewake` additionally wakes the model on exit code 2 with stderr.

### A.5 Matcher syntax

Three styles, distinguished at the parser level:

- `"*"` or `""` or omitted: wildcard, fires on every value.
- Letters, digits, `_`, `|` only: exact match or pipe-separated alternatives (`"Edit|Write"`).
- Any other character: JavaScript regex (`"mcp__.*"`, `"^Notebook"`).

MCP tools match the format `mcp__<server>__<tool>`. Plugin MCP tools are prefixed `mcp__plugin_<plugin>_<server>__<tool>` (e.g. `mcp__plugin_asana_asana__asana_create_task`). Source: `code.claude.com/docs/en/hooks` (Matcher Syntax section) and local `/Users/skunkworks/.claude/plugins/cache/claude-plugins-official/plugin-dev/45896c8f2fe6/skills/mcp-integration/SKILL.md:192-201`.

### A.6 Timeouts and parallelism

| Hook type | Default timeout |
|---|---|
| `command` | **600 seconds** (not 60s as plugin-dev cache claims at `hook-development/SKILL.md:491`) |
| `http` | 30 seconds |
| `prompt` | 30 seconds |
| `agent` | 60 seconds |

All matching hooks for an event run in parallel; identical handlers are deduplicated (command hooks by `command` + `args`, HTTP by `url`). Source: `code.claude.com/docs/en/hooks` (Timeouts and Parallelism section).

### A.7 The `if` field — conditional hook execution

Largely absent from the plugin-dev cache. The `if` field uses permission-rule syntax to short-circuit before evaluation, only on tool events (`PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied`):

```json
{ "if": "Bash(git *)" }
{ "if": "Edit(*.ts)" }
{ "if": "WebSearch(*OpenAI*)" }
```

A hook runs if the rule matches OR if Claude Code cannot parse the command (Bash). Source: `code.claude.com/docs/en/hooks` (Conditional Hook Execution section).

### A.8 Exit codes and `decision: "block"` semantics

- `0`: success, stdout parsed as JSON.
- `2`: blocking error, stderr fed to Claude, JSON ignored.
- Other: non-blocking error, stderr in transcript first line + full stderr to debug log.

Exit-2 effect varies per event (see A.1 column "Can block?"). Notably: `PermissionDenied` ignores exit codes entirely — only the JSON `retry: true` field has effect. Source: `code.claude.com/docs/en/hooks` (Exit Code 2 Effects Per Event table).

### A.9 Environment variables

| Variable | Scope | Description |
|---|---|---|
| `CLAUDE_PROJECT_DIR` | All hook processes | Project root |
| `CLAUDE_PLUGIN_ROOT` | All plugin hooks | Plugin install dir (changes on update; do not write state here) |
| `CLAUDE_PLUGIN_DATA` | All plugin hooks | **Persistent** dir surviving updates at `~/.claude/plugins/data/{id}/` |
| `CLAUDE_CODE_REMOTE` | All hooks | `"true"` only in remote web environment |
| `CLAUDE_EFFORT` | All hooks | Current effort level |
| `CLAUDE_ENV_FILE` | `SessionStart`, `Setup`, `CwdChanged`, `FileChanged` only | Write `export VAR=val` lines here; persist into all subsequent Bash tool calls |

Source: `code.claude.com/docs/en/hooks` (Environment Variables section); `code.claude.com/docs/en/plugins-reference` (Environment Variables section confirming `${CLAUDE_PLUGIN_DATA}` resolves to `~/.claude/plugins/data/{id}/`).

### A.10 Context-injection size limit

`additionalContext`, `systemMessage`, and plain stdout from a command hook are capped at **10,000 characters**. Exceeding this writes the content to a file and passes the preview + file path to Claude (same pattern as oversize tool results). Source: `code.claude.com/docs/en/hooks` (Context Injection Size Limits section).

### A.11 `/hooks` introspection menu

Type `/hooks` in an interactive session to browse all registered hooks with source attribution (User, Project, Local, Plugin, Session, Built-in) and per-event handler details. Read-only; edits go to settings JSON or via Claude. Source: `code.claude.com/docs/en/hooks` (Debugging & Inspection section).

---

## B. Agents (subagents)

Source: `code.claude.com/docs/en/sub-agents` (persisted at `/Users/skunkworks/.claude/projects/.../tool-results/toolu_01Ra9CJSeJH6QicZxumEJtej.txt:1-1037`).

### B.1 Full frontmatter field list

Only `name` and `description` are required. The complete supported list:

| Field | Type | Description |
|---|---|---|
| `name` | string | lowercase + hyphens; received as `agent_type` in hooks; filename need not match |
| `description` | string | Selection criterion for delegation |
| `tools` | string\|array | Allowlist (inherits all if omitted). Use `Skill` only via `skills:` preload |
| `disallowedTools` | string\|array | Denylist applied first |
| `model` | string | `sonnet` \| `opus` \| `haiku` \| full ID (`claude-opus-4-7`) \| `inherit` (default) |
| `permissionMode` | string | `default` \| `acceptEdits` \| `auto` \| `dontAsk` \| `bypassPermissions` \| `plan`. **Ignored for plugin subagents** |
| `maxTurns` | number | Cap agentic turns |
| `skills` | array | **Preload** skill content into context at startup (full body, not just description) |
| `mcpServers` | array | Inline server defs or string refs to configured servers. **Ignored for plugin subagents** |
| `hooks` | object | Lifecycle hooks scoped to this agent. **Ignored for plugin subagents** |
| `memory` | string | `user` \| `project` \| `local` — persistent agent-memory dir, auto-enables Read/Write/Edit |
| `background` | boolean | Always run as background task (auto-deny prompts) |
| `effort` | string | Per-agent effort level (`low` … `max`) |
| `isolation` | string | Only legal value: `"worktree"` — run in temp git worktree, auto-clean if no changes |
| `color` | string | `red` \| `blue` \| `green` \| `yellow` \| `purple` \| `orange` \| `pink` \| `cyan` |
| `initialPrompt` | string | Auto-submitted as first user turn when this agent is the **main** session via `--agent` |

Plugin agents support only `name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `isolation`. The `hooks`, `mcpServers`, and `permissionMode` fields are silently dropped for plugin-shipped agents (security). Source: `code.claude.com/docs/en/plugins-reference` (Agents section).

Note: the plugin-dev cache at `/Users/skunkworks/.claude/plugins/cache/claude-plugins-official/plugin-dev/45896c8f2fe6/skills/agent-development/SKILL.md:96-141` documents only `name`, `description`, `model`, `color`, `tools` — it is significantly behind the public reference.

### B.2 Built-in subagents

| Name | Model | Tools |
|---|---|---|
| `Explore` | Haiku | Read-only |
| `Plan` | Inherit | Read-only (used in `plan` mode) |
| `general-purpose` | Inherit | All tools |
| `statusline-setup` | Sonnet | (invoked by `/statusline`) |
| `claude-code-guide` | Haiku | (invoked when asking about CC features) |

### B.3 Tool resolution and the `Agent(...)` syntax

The Task tool was renamed to **Agent** in 2.1.63; `Task(...)` aliases still work. To restrict which subagent types a `--agent`-as-main session can spawn:

```yaml
tools: Agent(worker, researcher), Read, Bash
```

Allowlist semantics. `Agent` without parens allows any. Omitting `Agent` entirely blocks spawning. Subagents themselves cannot spawn subagents — `Agent(...)` is a no-op in a subagent definition. Source: `code.claude.com/docs/en/sub-agents` (Restrict which subagents can be spawned section).

### B.4 `--agent` and the main-session-as-agent pattern

`claude --agent <name>` replaces the default Claude Code system prompt with the agent's body. The agent name appears in the startup header. Plugin-provided agents use `<plugin-name>:<agent-name>` scoping. The `initialPrompt` field then auto-submits as the first user turn. The choice persists across `/resume`. The setting `agent` in `.claude/settings.json` makes it project-wide.

### B.5 Subagent transcripts and resumption

Subagent transcripts persist at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`, independent of main-conversation compaction. They are cleaned per `cleanupPeriodDays` (default 30). To resume a subagent across sessions, ask Claude to continue — Claude uses `SendMessage` with the agent ID. `SendMessage` requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`. A stopped subagent receiving `SendMessage` auto-resumes in the background.

### B.6 Forked subagents (experimental)

Enabled by `CLAUDE_CODE_FORK_SUBAGENT=1`. A fork inherits full conversation history, system prompt, tools, model, and prompt cache. Effects:

- Replaces `general-purpose` spawns with forks (named subagents unchanged).
- Every subagent spawn runs in background.
- `/fork <directive>` spawns a fork from the current conversation.

Forks cannot spawn further forks. Source: `code.claude.com/docs/en/sub-agents` (Fork the current conversation section).

### B.7 Background agents and `--bg`

`claude --bg "task"` (combined with `--agent`) launches as a background session, prints the session ID, and exits immediately. The CLI manages background sessions via `claude attach <id>`, `claude logs <id>`, `claude respawn <id>`, `claude stop <id>`, `claude rm <id>`. Source: `code.claude.com/docs/en/cli-reference`.

---

## C. Commands and Skills

Source: `code.claude.com/docs/en/skills` (the canonical doc), `code.claude.com/docs/en/slash-commands`, local cache at `/Users/skunkworks/.claude/plugins/cache/claude-plugins-official/plugin-dev/45896c8f2fe6/skills/skill-development/SKILL.md` and `command-development/SKILL.md`.

### C.1 Commands have been merged into skills

The headline change: `.claude/commands/deploy.md` and `.claude/skills/deploy/SKILL.md` both produce `/deploy` with identical runtime behavior. Files in `commands/` still work and accept the same frontmatter, but **skills are the recommended format**. The local `command-development/SKILL.md:9` reflects this with a deprecation note. Source: `code.claude.com/docs/en/skills` (intro paragraph).

### C.2 Complete skill frontmatter (12 fields)

| Field | Required | Notes |
|---|---|---|
| `name` | No (defaults to directory name) | lowercase + hyphens, max 64 chars |
| `description` | Recommended | Selection criterion. Combined with `when_to_use`, truncated at 1,536 chars |
| `when_to_use` | No | Appended to description; counts toward 1,536 cap |
| `argument-hint` | No | `[issue-number]` for autocomplete |
| `arguments` | No | Named positional args (space-separated string or YAML list) for `$name` substitution |
| `disable-model-invocation` | No | Hides skill from Claude's auto-invocation pool |
| `user-invocable` | No | `false` hides skill from `/` menu (Claude-only) |
| `allowed-tools` | No | Pre-approves tools while skill is active |
| `model` | No | Per-skill model override for current turn only |
| `effort` | No | Per-skill effort override |
| `context` | No | `fork` runs skill in a forked subagent |
| `agent` | No | Subagent type for `context: fork` (`Explore`, `Plan`, `general-purpose`, custom) |
| `hooks` | No | Skill-scoped hook lifecycle |
| `paths` | No | Glob patterns limiting when skill activates (uses memory path-rule format) |
| `shell` | No | `bash` (default) or `powershell` (requires `CLAUDE_CODE_USE_POWERSHELL_TOOL=1`) |

The local cache documentation at `/Users/skunkworks/.claude/plugins/cache/claude-plugins-official/plugin-dev/45896c8f2fe6/skills/skill-development/SKILL.md:163-180` only covers `name`, `description`, `version` — the public doc has surpassed it substantially.

### C.3 String substitutions in skill content

| Variable | Expansion |
|---|---|
| `$ARGUMENTS` | Full arg string |
| `$ARGUMENTS[N]` | 0-indexed positional |
| `$N` | Shorthand for `$ARGUMENTS[N]` |
| `$name` | Named arg from `arguments:` frontmatter |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_EFFORT}` | Current effort level |
| `${CLAUDE_SKILL_DIR}` | Skill's directory (plugin-scoped, not plugin root) |

Indexed args use shell-style quoting. Source: `code.claude.com/docs/en/skills` (Available string substitutions table).

### C.4 Dynamic context injection: backtick-bang syntax

This is the most under-publicised feature on the public page. Within a skill body:

````markdown
## Current changes
!`git diff HEAD`

## Multi-line
```!
node --version
npm --version
git status --short
```
````

The shell command runs **before** the skill content reaches Claude. The output replaces the placeholder. Disable via `disableSkillShellExecution: true` in settings (most useful in managed settings). Bundled and managed skills are exempt. Source: `code.claude.com/docs/en/skills` (Inject dynamic context section).

### C.5 Skill content lifecycle (critical for token cost reasoning)

When invoked, the rendered SKILL.md enters the conversation as one message and stays for the session — Claude does NOT re-read the file. Auto-compaction re-attaches each invoked skill's most recent invocation with a per-skill cap of 5,000 tokens and a combined cap of 25,000 tokens. Older skills can be dropped after compaction. Re-invoke a skill after compaction to restore full content. Source: `code.claude.com/docs/en/skills` (Skill content lifecycle section).

### C.6 Skill description budget

Skill descriptions are loaded into context so Claude can choose. The budget is **1% of model context window** by default. Override with `skillListingBudgetFraction` setting or `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var. Per-entry cap of 1,536 chars is configurable via `maxSkillDescriptionChars`. Overflow drops least-used skills first. Run `/doctor` to see if the budget is overflowing. Source: `code.claude.com/docs/en/skills` (Troubleshooting → Skill descriptions are cut short).

### C.7 Skill scope and precedence

| Location | Scope | Priority |
|---|---|---|
| Enterprise/managed | Org-wide | Highest |
| `~/.claude/skills/` | Personal, all projects | High |
| `.claude/skills/` | Project | Lower |
| `<plugin>/skills/` | Per-plugin | Namespaced as `plugin-name:skill-name` (cannot conflict) |

Skills from `--add-dir` directories ARE loaded (special case — other `.claude/` config is NOT). Skills hot-reload within a session if the parent skills directory existed at session start. Source: `code.claude.com/docs/en/skills` (Where skills live, Live change detection).

### C.8 `skillOverrides` setting

Per-skill visibility control without editing SKILL.md. Four states: `on` | `name-only` | `user-invocable-only` | `off`. The `/skills` menu can edit this — press `Space` to cycle, `Enter` to save to `.claude/settings.local.json`. Plugin skills are exempt; use `/plugin` instead. Source: `code.claude.com/docs/en/skills` (Override skill visibility from settings section).

### C.9 Slash command legacy format

`.claude/commands/*.md` still supported. Frontmatter fields: `description`, `allowed-tools`, `model`, `argument-hint`, `disable-model-invocation`. Argument syntax (`$1`, `$2`, `$ARGUMENTS`) and `@<file>` references and `!`<bash>`` inline shell are the same as skills. Local cache at `/Users/skunkworks/.claude/plugins/cache/claude-plugins-official/plugin-dev/45896c8f2fe6/skills/command-development/SKILL.md:131-209` covers this.

### C.10 `--bare` mode precisely

`claude --bare` disables: hooks, LSP, plugin sync, attribution, auto-memory, background prefetches, keychain reads, CLAUDE.md auto-discovery. Sets `CLAUDE_CODE_SIMPLE=1`. Anthropic auth restricted to `ANTHROPIC_API_KEY` or `apiKeyHelper` via `--settings`; OAuth and keychain are never read. Third-party providers (Bedrock/Vertex/Foundry) use their own credentials. Skills still resolve via `/skill-name`. Source: `claude --help` output (`--bare` flag) and `code.claude.com/docs/en/cli-reference` (Bare mode section).

### C.11 `--exclude-dynamic-system-prompt-sections`

Moves per-machine sections (cwd, env info, memory paths, git-repo flag) from the system prompt into the first user message. Improves prompt-cache reuse across users running the same task with `-p`. Only applies with the default system prompt — ignored when `--system-prompt` or `--system-prompt-file` is set. Source: `code.claude.com/docs/en/cli-reference`.

The dynamic sections moved are: **cwd, env info, memory paths, git-repo flag** (4 sections). Other sections of the default system prompt remain in place.

---

## D. CLI flags and subcommands

Source: `code.claude.com/docs/en/cli-reference` (full content at persisted output file), augmented by `claude --help` (run on 2.1.140).

The public docs explicitly state: "claude --help does not list every flag, so a flag's absence from --help does not mean it is unavailable."

### D.1 Subcommands (full)

| Subcommand | Purpose | Notable options |
|---|---|---|
| `claude` | Interactive session | All flags |
| `claude -p` / `--print` | Headless one-shot via SDK | All flags including `--max-turns`, `--max-budget-usd`, `--json-schema`, `--no-session-persistence` |
| `claude agents` | Open agent view (TTY) or list configured subagents (piped) | `--setting-sources` |
| `claude attach <id>` | Attach to background session | — |
| `claude auth login` | Sign in | `--email`, `--sso`, `--console` |
| `claude auth logout` | Sign out | — |
| `claude auth status` | Print auth status JSON | `--text` for human output; exits 0/1 |
| `claude auto-mode defaults` | Print built-in classifier rules | — |
| `claude auto-mode config` | Print effective config (settings overrides + defaults) | — |
| `claude auto-mode critique` | Get AI feedback on custom rules | — |
| `claude doctor` | Check auto-updater health | — |
| `claude install [version]` | Install native binary | `--force`, accepts `stable`/`latest`/version |
| `claude logs <id>` | Print recent output of background session | — |
| `claude mcp` | MCP server CRUD | See D.2 |
| `claude plugin` | Plugin CRUD | See plugin reference section in E |
| `claude project purge [path]` | Delete all CC state for a project | `--dry-run`, `-y`, `-i`, `--all` |
| `claude remote-control` | Start Remote Control server (no interactive) | `--name`, `--permission-mode`, `--remote-control-session-name-prefix` |
| `claude respawn <id>` | Restart stopped background session | `--all` |
| `claude rm <id>` | Remove background session | — |
| `claude setup-token` | Generate long-lived OAuth token (Claude subscription only) | — |
| `claude stop <id>` / `claude kill <id>` | Stop background session | — |
| `claude ultrareview [target]` | Cloud-hosted multi-agent code review | `--json`, `--timeout <minutes>` |
| `claude update` / `upgrade` | Self-update | — |

### D.2 `claude mcp` subcommands

| Subcommand | Notes |
|---|---|
| `add <name> <commandOrUrl> [args...]` | `--transport http\|sse\|stdio`, `-e KEY=VALUE`, `--header` |
| `add-from-claude-desktop` | Mac/WSL only |
| `add-json <name> <json>` | stdio or SSE |
| `get <name>` | Note: spawns stdio servers from `.mcp.json` for health check |
| `list` | Same caveat |
| `remove <name>` | — |
| `reset-project-choices` | Reset approved/rejected `.mcp.json` servers in this project |
| `serve` | Start Claude Code as an MCP server |

### D.3 Flags absent from `claude --help` but documented in cli-reference

| Flag | Effect |
|---|---|
| `--init` | Run `Setup` hooks with `init` matcher before session (`-p` only) |
| `--init-only` | Run `Setup` + `SessionStart` hooks then exit |
| `--maintenance` | Run `Setup` hooks with `maintenance` matcher (`-p` only) |
| `--max-turns N` | Cap agentic turns (`-p` only) |
| `--bg "task"` | Start as background agent, print session ID, exit |
| `--channels plugin:<name>@<marketplace>` | Listen for channel notifications (research preview) |
| `--dangerously-load-development-channels` | Bypass channel allowlist for dev |
| `--remote "task"` | Create new claude.ai web session |
| `--teleport` | Resume web session locally |
| `--teammate-mode auto\|in-process\|tmux` | Agent-teams display mode |
| `--system-prompt-file <path>` | Replace default with file contents |
| `--append-system-prompt-file <path>` | Append file contents to default |
| `--permission-prompt-tool` | MCP tool to handle permission prompts in `-p` |
| `--debug-file <path>` | Write debug logs to specific file (takes precedence over `CLAUDE_CODE_DEBUG_LOGS_DIR`) |

### D.4 Key flag semantics worth tightening

- `--setting-sources user,project,local`: comma-separated; resolution is highest-priority-first when conflicts occur. Source: `code.claude.com/docs/en/cli-reference`.
- `--settings <file-or-json>`: accepts either path or inline JSON string. Values override `settings.json` for the session; omitted keys keep file values. Precedence runs CLI > project > user > default.
- `--strict-mcp-config`: ignore all MCP config except what `--mcp-config` provides — useful for hermetic CI runs.
- `--include-partial-messages`: requires `-p` + `--output-format stream-json`. Emits partial streaming events.
- `--replay-user-messages`: requires both `--input-format stream-json` AND `--output-format stream-json`. Re-emits user messages on stdout for acknowledgment.
- `--from-pr <num-or-url>`: resumes sessions linked to a GitHub PR (or GitHub Enterprise / GitLab MR / Bitbucket PR URL). Sessions auto-link when Claude creates a PR.
- `--fork-session`: when resuming with `--resume` or `--continue`, creates a new session ID instead of reusing.
- `--worktree [name]`: starts in isolated git worktree at `<repo>/.claude/worktrees/<name>`. Accepts `#<num>` or GitHub PR URL to fetch+branch. Combine with `--tmux` for native iTerm2 panes or `--tmux=classic` for traditional tmux.
- `--remote-control [name]`: interactive session with Remote Control enabled — controllable from claude.ai or the Claude app. Pair with `--remote-control-session-name-prefix` (defaults to hostname) for auto-naming.
- `--brief`: enables the `SendUserMessage` tool. From `claude --help`: "Enable SendUserMessage tool for agent-to-user communication". This is the tool that lets a background agent reach back to the user mid-run.
- `--betas <name...>`: API beta headers (e.g. `interleaved-thinking`). API-key users only.

### D.5 Permission modes (full)

Source: `code.claude.com/docs/en/permission-modes`.

| Mode | Auto-approves | When |
|---|---|---|
| `default` | Reads only | Sensitive work |
| `acceptEdits` | Reads + edits in cwd + safe filesystem Bash (`mkdir`, `touch`, `mv`, `cp`, `sed`, with `LANG=C`/`timeout`/`nice`/`nohup` prefix support) | Reviewing edits via diff after |
| `plan` | Reads only (research mode) | Codebase exploration |
| `auto` | Everything subject to classifier check | Long tasks (research preview; requires Max/Team/Enterprise/API + Sonnet 4.6 or Opus 4.6/4.7) |
| `dontAsk` | Only `permissions.allow` rules + read-only Bash | Locked-down CI |
| `bypassPermissions` | Everything (still circuit-breaks on `rm -rf /` and `rm -rf ~`) | Containers/VMs only |

Auto-mode has a separate server-side classifier model that re-reads the transcript on each check. Boundaries stated in conversation ("don't push to main") become block signals — but can be lost on compaction. Hard guarantees require `deny` rules. The classifier strips tool results before scanning (prompt-injection defence). Subagents inherit parent's auto-mode, ignoring their own `permissionMode`. Three-strikes pause: 3 consecutive or 20 total blocks pause auto-mode. Source: `code.claude.com/docs/en/permission-modes` (Eliminate prompts with auto mode section).

### D.6 Protected paths (write-always-prompts)

In every mode except `bypassPermissions`: `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `.claude/commands`, `.claude/agents`, `.claude/skills`, `.claude/worktrees`), `.gitconfig`, `.gitmodules`, shell rc files (`.bashrc`, `.bash_profile`, `.zshrc`, `.zprofile`, `.profile`), `.ripgreprc`, `.mcp.json`, `.claude.json`. As of v2.1.126 even `bypassPermissions` no longer prompts for these — they are simply allowed.

---

## E. Agent SDK

Source: `code.claude.com/docs/en/agent-sdk/overview`.

### E.1 Package shape

- TypeScript: `@anthropic-ai/claude-agent-sdk` (bundles native Claude Code binary as optional dependency — no separate install).
- Python: `claude-agent-sdk` (renamed from the original Claude Code SDK).

Min Opus 4.7 support requires v0.2.111+.

### E.2 Core API

Both SDKs expose a `query()` async iterator:

```python
from claude_agent_sdk import query, ClaudeAgentOptions
async for message in query(
    prompt="Find and fix the bug in auth.py",
    options=ClaudeAgentOptions(allowed_tools=["Read", "Edit", "Bash"]),
):
    print(message)
```

```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";
for await (const message of query({ prompt: "...", options: { allowedTools: [...] } })) {}
```

### E.3 Hooks via callback functions

Hooks are in-process Python or TypeScript functions, not external scripts:

```python
async def log_file_change(input_data, tool_use_id, context):
    return {}

options = ClaudeAgentOptions(
    hooks={"PostToolUse": [HookMatcher(matcher="Edit|Write", hooks=[log_file_change])]}
)
```

TypeScript uses the `HookCallback` type. Available events match the CLI's hook events.

### E.4 Subagents via JSON

```python
options = ClaudeAgentOptions(
    allowed_tools=["Read", "Glob", "Grep", "Agent"],
    agents={
        "code-reviewer": AgentDefinition(
            description="...",
            prompt="...",
            tools=["Read", "Glob", "Grep"],
        )
    },
)
```

Messages from subagent context include `parent_tool_use_id` so callers can correlate.

### E.5 Sessions

Capture `message.data["session_id"]` from the first `SystemMessage(subtype="init")`. Pass `resume=session_id` to a later `query()` call to continue with full context.

### E.6 Filesystem configuration loading

By default the SDK loads `.claude/` config (skills, commands, CLAUDE.md, plugins) from cwd and `~/.claude/`. Restrict with `setting_sources` (Python) / `settingSources` (TS).

### E.7 Third-party providers

Env-var gated: `CLAUDE_CODE_USE_BEDROCK=1`, `CLAUDE_CODE_USE_VERTEX=1`, `CLAUDE_CODE_USE_FOUNDRY=1`, `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` (Claude Platform on AWS).

---

## F. Under-documented / advanced features

These are the surfaces that don't appear prominently in the headline guides but exist in canonical refs, cached SDK examples, or CLI help.

### F.1 Plugin manifest fields beyond name/version/description

Source: `code.claude.com/docs/en/plugins-reference`.

| Field | Purpose |
|---|---|
| `skills` | Custom skill dirs (**adds** to default `skills/`) |
| `commands` | Custom command dirs (**replaces** default `commands/`) |
| `agents` | Custom agent files (**replaces** default `agents/`) |
| `hooks` | Path to hooks JSON or inline object |
| `mcpServers` | Path or inline MCP config |
| `outputStyles` | Output style files/dirs (replaces default `output-styles/`) |
| `lspServers` | LSP server configs (path or inline) |
| `experimental.themes` | Color theme files |
| `experimental.monitors` | Background monitor configs |
| `userConfig` | User-prompted config values at install time (see below) |
| `channels` | Message-injection channels bound to MCP servers (Telegram/Slack-style) |
| `dependencies` | Other plugins with optional semver constraints |
| `$schema` | JSON Schema URL for editor validation (ignored at runtime) |

### F.2 `userConfig` — typed prompts at plugin enable time

```json
{
  "userConfig": {
    "api_endpoint": { "type": "string", "title": "...", "description": "..." },
    "api_token":   { "type": "string", "sensitive": true, "title": "...", "description": "..." }
  }
}
```

Types: `string`, `number`, `boolean`, `directory`, `file`. Values are substitutable as `${user_config.KEY}` in MCP/LSP/hook/monitor commands, and as `CLAUDE_PLUGIN_OPTION_<KEY>` env vars in subprocesses. Sensitive values go to system keychain (≈2KB total cap shared with OAuth tokens). Non-sensitive values land in `settings.json` under `pluginConfigs[<plugin-id>].options`. This is the canonical way to make a plugin configurable without users hand-editing `settings.json`.

### F.3 `${CLAUDE_PLUGIN_DATA}` — persistent state across plugin updates

Resolves to `~/.claude/plugins/data/{id}/` where `{id}` is the plugin identifier with non-`[A-Za-z0-9_-]` replaced by `-`. Survives updates and uninstalls (unless `--keep-data` is omitted from the last uninstall). Created on first reference. Canonical pattern: install `node_modules` once, reuse across versions:

```json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "diff -q \"${CLAUDE_PLUGIN_ROOT}/package.json\" \"${CLAUDE_PLUGIN_DATA}/package.json\" >/dev/null 2>&1 || (cd \"${CLAUDE_PLUGIN_DATA}\" && cp \"${CLAUDE_PLUGIN_ROOT}/package.json\" . && npm install) || rm -f \"${CLAUDE_PLUGIN_DATA}/package.json\""
      }]
    }]
  }
}
```

This pattern is in the plugins reference but almost nowhere else.

### F.4 `bin/` PATH injection

Files in a plugin's `bin/` directory are added to the Bash tool's `PATH` while the plugin is enabled. This means a plugin can ship a CLI tool invokable as a bare command — no `${CLAUDE_PLUGIN_ROOT}/bin/foo` needed. Source: `code.claude.com/docs/en/plugins-reference` (File locations reference table).

### F.5 `plugin/settings.json`

A plugin can ship a `settings.json` at its root. Currently only two keys take effect: `agent` (auto-set the main-thread agent when plugin is enabled) and `subagentStatusLine`. Source: `code.claude.com/docs/en/plugins`.

### F.6 Channels — MCP-server-driven message injection

A plugin can declare `channels` in its manifest. Each channel binds to an MCP server (must match a key in `mcpServers`) and supports per-channel `userConfig`. The MCP server can then inject messages into the conversation (Telegram/Slack/Discord style). Activate at runtime with `claude --channels plugin:<name>@<marketplace>`. Research preview. Source: `code.claude.com/docs/en/plugins-reference` (Channels section) and `claude --help` shows `--channels` and `--dangerously-load-development-channels` flags.

### F.7 Monitors — background watchers without an MCP server

A plugin can ship `monitors/monitors.json` declaring background commands that stream stdout to Claude as notifications. Each `command` line becomes a notification. Schema:

```json
[{ "name": "error-log", "command": "tail -F ./logs/error.log", "description": "Error log", "when": "always|on-skill-invoke:<skill-name>" }]
```

Supports `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_DATA}`, `${CLAUDE_PROJECT_DIR}`, `${user_config.*}`. Stops at session end. Disabling a plugin mid-session does NOT stop already-running monitors. Source: `code.claude.com/docs/en/plugins-reference` (Monitors section).

### F.8 Agent teams (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`)

Source: `code.claude.com/docs/en/agent-teams`.

- Architecture: lead session + N teammates + shared task list (file-locked) + mailbox.
- Storage: `~/.claude/teams/{team-name}/config.json` (do not hand-edit), `~/.claude/tasks/{team-name}/`.
- Communication: `SendMessage` tool (named-recipient delivery, no broadcast).
- Display: `--teammate-mode auto|in-process|tmux`. `tmux` requires either `tmux` binary or iTerm2 with the `it2` CLI installed and the Python API enabled.
- Lifecycle hooks: `TeammateIdle`, `TaskCreated`, `TaskCompleted` (each can exit 2 to feedback-loop the teammate).
- Subagent definitions can be referenced when spawning teammates — the definition's body is **appended** (not replacing) the teammate's system prompt; `tools` and `model` apply; `skills` and `mcpServers` fields are dropped.
- Limits: one team per lead, no nested teams, no teammate promotion, `/resume` does not restore in-process teammates.

### F.9 Background-session CLI surface

`claude --bg` + `claude attach`, `logs`, `respawn`, `stop`, `rm` form a complete background-job manager built into Claude Code. Combined with `--agent` this lets a plugin orchestrate genuine background work without user-facing UI.

### F.10 `claude auto-mode critique`

Asks an AI to review your custom auto-mode rules in `autoMode.environment` and tell you whether they're tight enough. Mentioned only in `claude auto-mode --help` output.

### F.11 Path traversal and marketplace symlinks

Plugin caches at `~/.claude/plugins/cache` are versioned per-install. Symlinks inside a plugin are preserved if they resolve within the plugin's own dir, dereferenced if they resolve within the same marketplace, and skipped if they resolve outside the marketplace. This is the supported mechanism for sharing files between plugins in one marketplace. Source: `code.claude.com/docs/en/plugins-reference` (Path traversal limitations / Share files within a marketplace with symlinks).

### F.12 Glob/Grep skip orphaned plugin versions

Cached plugin versions marked orphaned (typically after 7 days post-update) are excluded from Claude's Glob and Grep results — so stale plugin code doesn't pollute searches. Confirmed at `code.claude.com/docs/en/plugins-reference` (Plugin caching and file resolution section).

### F.13 Live skill / agent / hook reload

Skills hot-reload within a session if the parent skills directory existed at session start. Hooks do NOT hot-reload — they bind at session start. Subagents created through `/agents` take effect immediately; subagents created by editing files on disk require session restart. Source: `code.claude.com/docs/en/skills` (Live change detection) and `code.claude.com/docs/en/sub-agents` (Note about session restart).

### F.14 `claude plugin details` token cost preview

`claude plugin details <name>` prints "always-on" (description-only token cost on every session) and "on-invoke" (per-skill token cost when triggered) estimates, computed via `count_tokens` API for the active model. This is the only way short of `/doctor` to quantify a plugin's context bloat before installing.

### F.15 `ultrathink` keyword

Including the literal word `ultrathink` anywhere in a skill body requests deeper reasoning. Documented as a single-line tip on the skills page. Source: `code.claude.com/docs/en/skills` (Tip in Inject dynamic context section).

---

## Surprises and high-value advanced features for oracle-class plugins

Ranked by usefulness for a verification/oracle plugin that wants to be authoritative and minimally invasive:

1. **`${CLAUDE_PLUGIN_DATA}` for vector indexes, model cache, and oracle ground truth.** Survives updates; can store gigabytes of pre-computed truth without re-shipping. The `diff -q package.json` pattern (F.3) generalizes to any artifact: re-run expensive work only when the bundled source-of-truth changes.
2. **`PostToolBatch` hook with `type: prompt`.** Fires once per parallel batch of tool calls, before the next model decision. An oracle can read every batch's tool outputs together and inject a single `additionalContext` warning — minimal token cost, maximum signal. No tutorial mentions this event.
3. **`PreToolUse` with `permissionDecision: "defer"`.** Hands the decision to the auto-mode classifier. An oracle that has soft confidence ("looks fine, but I'd like the classifier to double-check") gets the right outcome without forcing a hard allow/deny.
4. **`PermissionDenied` + `retry: true`.** When auto-mode blocks something, an oracle can inspect why, repair the tool input (or instruct the model), and grant retry — bypassing the three-strikes pause that would otherwise terminate auto-mode. Almost zero documentation outside the hooks reference.
5. **`skills:` preload on a subagent.** Drop the full body of an oracle-policies skill into a subagent's context at startup. Cheaper than the subagent discovering and loading it during execution, and prevents the subagent from "forgetting" the policy under context pressure.
6. **`isolation: "worktree"` for write-then-verify oracles.** An oracle agent that wants to "try the change in a sandbox" gets a clean git worktree per invocation, auto-cleaned if it makes no changes. No manual checkout dance.
7. **`hooks:` field inside a skill's frontmatter.** Scopes hooks to a skill's lifecycle — they bind only when the skill is invoked. An oracle skill can ship its own `PreToolUse` validator that exists only during oracle runs.
8. **`Monitor` declarations.** Tail a verification log, an LSP diagnostics socket, or a build-status endpoint — every line becomes a Claude notification. A pure read path with zero polling code.
9. **`--bare` mode for hermetic invocations.** A meta-orchestrator that wants to invoke Claude Code as a sub-process from a hook gets fast startup and no plugin recursion. Combine with `--system-prompt-file` + `--mcp-config` for fully reproducible runs.
10. **`disable-model-invocation: true` on oracle skills.** Prevents Claude from invoking the oracle when it shouldn't, and (per F.2 in `code.claude.com/docs/en/skills`) drops the description from context entirely — saving tokens until the user explicitly types `/oracle`.
11. **`UserPromptExpansion` hook.** Fires when a user-typed `/skill` expands. An oracle can intercept, reject, or rewrite the expansion before Claude sees it.
12. **`InstructionsLoaded` hook.** Observe every CLAUDE.md and `.claude/rules/*.md` load. An oracle that wants to verify policy consistency across multiple memory files gets a free notification stream.
13. **`Agent(specific-name)` allowlist syntax.** A `--agent oracle-lead` main session can be locked to spawn only `Agent(verifier)` and `Agent(reporter)` — preventing accidental general-purpose escapes.
14. **`SendMessage` + agent teams.** Direct teammate-to-teammate messaging means an oracle teammate can challenge a "developer" teammate's claim in-context, rather than reporting to a coordinator and waiting for routing.
15. **The Agent SDK's `HookCallback` type.** For oracle work where shell-out latency matters, in-process Python or TypeScript callbacks are 1–2 orders of magnitude faster than `type: command`. The same JSON schema applies, so logic is portable.

---

End of report.
