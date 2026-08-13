# Subagents

Snapshot date: 2026-05-14. Source of truth: <https://code.claude.com/docs/en/sub-agents>.

A subagent is a focused, single-purpose Claude instance the main session can delegate to. Each runs with its own system prompt, tool allow-list, model, and effort level, and returns a single result message to the parent.

As of Claude Code 2.1.63, the dispatch tool was renamed from `Task` to `Agent`. Existing `Task(...)` references in `settings.json` and component frontmatter work as aliases. Source: `anthropics/claude-code/main/CHANGELOG.md` (fetched 2026-05-14).

## Frontmatter

Only `name` and `description` are required. Full field table per <https://code.claude.com/docs/en/sub-agents#supported-frontmatter-fields>:

| Field | Required | Allowed values | Default | Notes |
|---|---|---|---|---|
| `name` | yes | lowercase letters and hyphens | — | Hooks receive this as `agent_type`. Filename need not match. |
| `description` | yes | free text | — | When Claude should delegate. Include phrases like "use proactively" to encourage automatic delegation. There is no separate `proactive:` key. |
| `tools` | no | comma-list or YAML list of tool names | inherits parent | To preload skills, use `skills:` not `Skill` in tools. |
| `disallowedTools` | no | tool list | — | Applied first; `tools` resolves against the remainder. |
| `model` | no | `sonnet`, `opus`, `haiku`, full ID (e.g. `claude-opus-4-7`), or `inherit` | `inherit` | Resolution order: `CLAUDE_CODE_SUBAGENT_MODEL` env → per-invocation `model` arg → frontmatter → main conversation. |
| `permissionMode` | no | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, `plan` | inherits | **Ignored for plugin subagents.** |
| `maxTurns` | no | integer | — | Agentic-turn cap. |
| `skills` | no | list of skill names | — | Full skill content injected at startup. Cannot preload `disable-model-invocation: true` skills. |
| `mcpServers` | no | string ref or inline def | — | **Ignored for plugin subagents.** |
| `hooks` | no | hooks map | — | **Ignored for plugin subagents.** When valid (project/user scope), `Stop` auto-converts to `SubagentStop` when this agent runs as a subagent. |
| `memory` | no | `user`, `project`, `local` | — | Mounts `~/.claude/agent-memory/<name>/` etc. First 200 lines or 25 KB of `MEMORY.md` loaded at startup. |
| `background` | no | bool | `false` | Always run in background. |
| `effort` | no | `low`, `medium`, `high`, `xhigh`, `max` | inherits | Available levels depend on the model. |
| `isolation` | no | `worktree` | — | Runs in temporary git worktree. Only valid value is `worktree`. |
| `color` | no | `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan` | — | UI only. |
| `initialPrompt` | no | string | — | Auto-submitted as the first user turn when this agent is the main-session agent via `--agent` or the `agent` setting. |

## Plugin subagent restrictions

Verbatim from <https://code.claude.com/docs/en/sub-agents#choose-the-subagent-scope>:

> For security reasons, plugin subagents do not support the `hooks`, `mcpServers`, or `permissionMode` frontmatter fields. These fields are ignored when loading agents from a plugin.

The plugins-reference page restates this and adds: plugin agents support `name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, and `isolation`. The only valid `isolation` value is `worktree`.

## Registration surface and precedence

| Priority (1 = highest) | Location | Scope |
|---|---|---|
| 1 | Managed settings | Org-wide |
| 2 | `--agents` CLI flag (JSON) | Current session |
| 3 | `.claude/agents/` | Project |
| 4 | `~/.claude/agents/` | All your projects |
| 5 | Plugin `agents/` | Where plugin is enabled |

Loading semantics, verbatim:

> Subagents are loaded at session start. If you add or edit a subagent file directly on disk, restart your session to load it. Subagents created through the `/agents` interface take effect immediately without a restart.

Source: <https://code.claude.com/docs/en/sub-agents#choose-the-subagent-scope>. Fetched 2026-05-14.

## Hooks in agent frontmatter

Project and user-scope agents can declare lifecycle hooks. The shape mirrors the `hooks` block in `settings.json` (event → matcher → handlers). Example from <https://code.claude.com/docs/en/sub-agents#hooks-in-subagent-frontmatter>:

```yaml
---
name: code-reviewer
description: Review code changes with automatic linting
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/validate-command.sh $TOOL_INPUT"
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "./scripts/run-linter.sh"
---
```

When the agent runs as a subagent, `Stop` hooks auto-convert to `SubagentStop`. See [hooks.md](hooks.md) for handler-type and decision-verb details.

## "Use proactively" phrasing

Verbatim from <https://code.claude.com/docs/en/sub-agents#understand-automatic-delegation>:

> To encourage proactive delegation, include phrases like "use proactively" in your subagent's description field.

There is no separate boolean frontmatter key. The trigger language lives inside `description`. Marketplace examples: see `plugins/oracle/agents/canon-reader.md` (`Use this agent when the orchestrator needs authoritative source material...`) and `plugins/plugin-dev/agents/plugin-validator.md` (`...trigger proactively after user creates or modifies plugin components`).

## Best practices (Anthropic, verbatim)

- "Design focused subagents: each subagent should excel at one specific task."
- "Write detailed descriptions: Claude uses the description to decide when to delegate."
- "Limit tool access: grant only necessary permissions for security and focus."
- "Check into version control: share project subagents with your team."

Source: <https://code.claude.com/docs/en/sub-agents> (Tip box at top of "Example subagents"). Fetched 2026-05-14.

## Limitations and footguns

- **Subagents cannot spawn other subagents.** Verbatim: "If your workflow requires nested delegation, use Skills or chain subagents from the main conversation." (`code.claude.com/docs/en/sub-agents`).
- **Plugin subagents silently ignore three security-sensitive fields** (`hooks`, `mcpServers`, `permissionMode`). The YAML parses, the agent loads, the fields do nothing. Audit your plugin agent frontmatter.
- **`skills:` in subagent frontmatter cannot preload `disable-model-invocation: true` skills.** Side-effecting skills are explicitly excluded from auto-preload.
- **The Task → Agent rename (2.1.63) means new agent definitions should use `Agent(<name>)` in `allowed-tools`.** Old `Task(<name>)` references still alias; mixing forms in a single command body is legal but inconsistent.
- **`isolation: worktree` only.** Any other value fails validation.
- **`initialPrompt` only fires for main-session agents (`--agent`).** It is not auto-submitted when the agent runs as a subagent via `Agent(...)`.

## Marketplace examples

- `plugins/oracle/agents/canon-reader.md`, `github-archivist.md`, `forum-anthropologist.md`, `issue-investigator.md`, `cost-rethinker.md` — Research silos used by `/oracle:research` and `/oracle:vet`. Each declares a narrow `tools:` list and is dispatched in parallel.
- `plugins/rust-monorepo-orchestrator/agents/ticket-implementer.md` — Worker pattern with `isolation: worktree`, declared `skills:` preload (`orchestration-protocol`, `opus-4-7-prompting`), and Sonnet 4.6 model.
- `plugins/harness-tuner/agents/hierarchy-architect.md` — Opus 4.7 with effort `xhigh` for long-form architectural reasoning.
- `plugins/meta-skill-improver/agents/sandbox-runner.md` — Worker dispatched per eval cell with `isolation: worktree` for hermetic trial execution.

## Sources

- [Subagents (docs)](https://code.claude.com/docs/en/sub-agents) — fetched 2026-05-14.
- [Plugins reference, agents section](https://code.claude.com/docs/en/plugins-reference#agents) — fetched 2026-05-14.
- [Settings (precedence)](https://code.claude.com/docs/en/settings) — fetched 2026-05-14.
- [anthropics/claude-code CHANGELOG (Task → Agent rename, 2.1.63)](https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md) — fetched 2026-05-14.
