---
name: harness-anatomy
description: >
  Reference for every kind of artefact in the Claude Code harness:
  CLAUDE.md, skills, subagents, slash commands, hooks, monitors,
  settings. What each looks like, what frontmatter fields exist, what
  triggers loading, how the hierarchy resolves. Auto-loaded by every
  agent in harness-tuner. The "what's possible" reference.
---

# Harness anatomy

Every audit and proposal this plugin makes is grounded in the harness's actual capabilities. This skill is the canonical reference.

Sources cited inline. Primary: <https://code.claude.com/docs/en/memory>, <https://code.claude.com/docs/en/best-practices>, <https://code.claude.com/docs/en/sub-agents>, <https://code.claude.com/docs/en/skills>, <https://code.claude.com/docs/en/hooks>, <https://code.claude.com/docs/en/plugins-reference>, <https://code.claude.com/docs/en/tools-reference>.

---

## The artefact landscape

| Artefact | Lives at | Loads when | Owns | Best at |
|---|---|---|---|---|
| **CLAUDE.md** (root) | `./CLAUDE.md` | always | binding repo-wide invariants | architecture rules, output discipline, the 5 commands you actually use |
| **CLAUDE.md** (path-scoped) | `./.claude/rules/*.md` with `paths:` | only when matching files are touched | layer-specific or filetype-specific rules | "when editing `domain/**`, do X" |
| **CLAUDE.md** (subdirectory) | `services/<svc>/CLAUDE.md` | when Claude reads files in that subtree | service-local conventions | bounded contexts, streams, schemas, service-specific quirks |
| **CLAUDE.md** (user) | `~/.claude/CLAUDE.md` | always, across all projects | personal prefs | terseness, output style, "always cite file:line" |
| **CLAUDE.md** (local) | `./CLAUDE.local.md` (gitignored) | always | personal sandbox | local DB DSNs, sandbox URLs |
| **Skill** | `.claude/skills/<name>/SKILL.md` (or plugin-shipped) | description match, manual invocation, or autoload via agent `skills:` frontmatter | reusable knowledge | methodology references, snippet banks, cookbooks |
| **Subagent** | `.claude/agents/<name>.md` (or plugin-shipped) | Task tool invocation (or @-mention) | encapsulated work | parallel fan-out, isolated context, role-specific prompts |
| **Slash command** | `.claude/commands/<name>.md` (or plugin-shipped) | user invocation (`/<name>`) or auto-invocation when allowed | workflow orchestration | multi-step, multi-agent dispatch |
| **Hook** | `~/.claude/settings.json` or `.claude/settings.json` or plugin `hooks/hooks.json` | lifecycle event (SessionStart, PreToolUse, etc.) | side-effects + context injection | context loading, registry refresh, telemetry |
| **Monitor** (`Monitor` tool) | runtime; not a file artefact | called by agents | streaming a long-running command | tailing logs, watching test runs |
| **Plugin** | `.claude-plugin/plugin.json` | install via marketplace | bundled commands/agents/skills/hooks | distribution unit |
| **Settings** | `.claude/settings.json` | always at session start | permissions, env vars, hooks | repo-wide harness config |

---

## CLAUDE.md anatomy

### The 200-line ceiling

> Target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence.
>
> -- <https://code.claude.com/docs/en/memory> ("Write effective instructions")

The litmus test for every line:

> For each line, ask: 'Would removing this cause Claude to make mistakes?' If not, cut it. Bloated CLAUDE.md files cause Claude to ignore your actual instructions.
>
> -- <https://code.claude.com/docs/en/best-practices>

### Hierarchy and loading order (verbatim)

> Files load from the filesystem root down to your working directory. CLAUDE.local.md is appended after CLAUDE.md.

Practical order for a session opened in `monorepo/services/orders/src/domain/`:

1. `~/.claude/CLAUDE.md` (user-global)
2. `monorepo/CLAUDE.md` (repo root)
3. `monorepo/CLAUDE.local.md` (if present)
4. `monorepo/services/orders/CLAUDE.md` (service-level, if present)
5. `monorepo/services/orders/src/CLAUDE.md` (subdirectory, if present)
6. `monorepo/services/orders/src/domain/CLAUDE.md` (cwd, if present)
7. Plus: any `monorepo/.claude/rules/*.md` whose `paths:` matches files Claude touches.

### Path-scoped rules

`./.claude/rules/<name>.md` with frontmatter `paths: ["**/domain/**/*.rs"]` only enters context when Claude reads or writes files matching the pattern. **They don't count against the 200-line ceiling of any CLAUDE.md** -- they live separately.

```markdown
---
paths:
  - "**/domain/**/*.rs"
  - "**/application/**/*.rs"
---

# Rules for domain and application layers

- No async fn here.
- Return Result<_, DomainError>.
```

### `@` imports

`@path/to/file.md` at the start of a line imports that file's content into the current CLAUDE.md at load time. Resolution is **relative to the file containing the `@` directive**, not cwd.

So in `services/orders/CLAUDE.md`, write `@../../docs/conventions/event-versioning.md` to reach `monorepo/docs/conventions/event-versioning.md`.

Imports load **at session launch**, so they DO consume context budget. Use sparingly; prefer path-scoped rules for content that should only sometimes appear.

---

## Skill anatomy

### Storage

```
<plugin or .claude>/skills/<skill-name>/
├── SKILL.md                # frontmatter + body; the entry point
└── references/             # progressive disclosure; loaded on demand
    ├── deep-dive.md
    └── cookbook.md
```

### SKILL.md frontmatter (every supported field)

| Field | Type | Purpose |
|---|---|---|
| `name` | string | display name; lowercase/numbers/hyphens; ≤64 chars |
| `description` | string | when-to-use; drives autoload matching; appears in `/skills` list |
| `when_to_use` | string | additional autoload trigger context (≤1536 chars combined with description) |
| `argument-hint` | string | shown during `/<skill>` autocomplete |
| `arguments` | list / string | named positional arguments for `$name` substitution |
| `disable-model-invocation` | bool | true = user-only invocation, no autoload |
| `user-invocable` | bool | false = Claude-only, hidden from `/` menu |
| `allowed-tools` | string / list | pre-approve tools while skill is active |
| `model` | string / `inherit` | override session model while skill is active |
| `effort` | enum | override session effort: `low`, `medium`, `high`, `xhigh`, `max` |
| `paths` | string / list | glob patterns limiting autoload to matching files |
| `shell` | enum | shell for `` !`...` `` blocks: `bash` (default) or `powershell` |

### Autoload triggers

A skill loads when:

1. **User explicitly invokes** via `/<skill-name>`.
2. **Claude decides it's relevant** (description match against the user prompt).
3. **A subagent declares it** in its `skills:` frontmatter (full content injected at agent start).
4. **`paths:` glob matches** when Claude touches a matching file.

Loaded skill content stays for the rest of the session, preserved through compaction.

---

## Subagent anatomy

### Storage

`.claude/agents/<name>.md` (or `<plugin>/agents/<name>.md`).

### Frontmatter (every supported field, verified against existing skunkworks plugins)

| Field | Type | Purpose |
|---|---|---|
| `name` | string | identifier; ≤64 chars; lowercase/numbers/hyphens |
| `description` | string (multiline) | what the agent does; drives auto-delegation |
| `tools` | comma-list | allowlist of tools; omit to inherit all |
| `disallowedTools` | comma-list | explicit deny list |
| `model` | string / `inherit` | model to use; commonly `claude-opus-4-7`, `claude-sonnet-4-6`, `inherit` |
| `effort` | enum | `low` / `medium` / `high` / `xhigh` / `max` |
| `color` | string | UI tag color |
| `permissionMode` | enum | `acceptEdits` / `plan` / `bypassPermissions` |
| `mcpServers` | list | MCP servers scoped to this agent |
| `hooks` | object | lifecycle hooks scoped to this agent (PreToolUse, PostToolUse, Stop, etc.) |
| `maxTurns` | int | max turns before auto-stop |
| `skills` | comma-list | skills to autoload at startup (full content injected) |
| `memory` | enum / path | `user` (cross-project) / `project` (project-scoped) / `local` |
| `background` | bool | true = always run as background task |
| `isolation` | enum | `none` / `worktree` (separate git worktree for parallel-safe edits) |

### Memory mechanics (verified against skunkworks plugins)

- `memory: project` enables a per-project `MEMORY.md` that auto-injects (first ~200 lines) into the agent's system prompt at dispatch.
- Live at `.claude/agent-memory/<agent>/MEMORY.md`.
- Append-only `.claude/agent-memory/<agent>/activity.log` on `Stop` hook is a skunkworks convention, not a harness feature.

### `skills:` autoload

```yaml
skills:
  - orchestration-protocol
  - opus-4-7-prompting
```

The named skills' SKILL.md content is injected into the agent's system prompt at dispatch. Skill name resolution: any installed plugin or local `.claude/skills/<name>/SKILL.md`.

---

## Slash command anatomy

### Storage

`.claude/commands/<name>.md` (or `<plugin>/commands/<name>.md`).

### Frontmatter

| Field | Type | Purpose |
|---|---|---|
| `description` | string | shown in `/help`; drives autoload |
| `argument-hint` | string | autocomplete hint, e.g. `[issue-number]` |
| `model` | string | force a specific model for this command |
| `disable-model-invocation` | bool | true = user-only |
| `user-invocable` | bool | false = Claude-only |
| `allowed-tools` | string / list | pre-approve tools |
| `arguments` | string / list | named positional arguments for `$name` |
| `when_to_use` | string | additional autoload trigger |

### Argument injection

| Token | Resolves to |
|---|---|
| `$ARGUMENTS` | full argument string |
| `$ARGUMENTS[N]` | Nth (0-based) argument |
| `$0`, `$1`, ... | shorthand for `$ARGUMENTS[N]` |
| `$<name>` | named argument from `arguments:` frontmatter |
| `` !`<cmd>` `` | inline shell execution (runs before Claude sees the command) |
| ` ```! ` (fenced block) | multi-line shell |
| `@/path/to/file` | file inclusion (contents inserted) |

### Plugin namespacing

Plugin commands resolve as `<plugin-name>:<command-name>`. `/anvil:audit-component` runs `plugins/anvil/commands/audit-component.md`.

---

## Hook anatomy

### Storage

`~/.claude/settings.json`, `.claude/settings.json`, `.claude/settings.local.json`, plugin `hooks/hooks.json`, or skill / agent frontmatter.

### Events

| Event | Fires | Decision fields |
|---|---|---|
| `SessionStart` | session start / resume; per-session per-subagent | `additionalContext` (inject), `continue` |
| `UserPromptSubmit` | before each user prompt | `block`, `additionalContext` |
| `PreToolUse` | before each tool call | `permissionDecision` (`allow`/`deny`), `modify` |
| `PostToolUse` | after successful tool call | `additionalContext`, `continue` |
| `Stop` | before agent stop | `continue` |
| `SubagentStop` | before subagent stop | `continue` |
| `Notification` | when showing notifications | `additionalContext` |
| `PreCompact` | before context compaction | `additionalContext` (save to summary) |

### JSON output protocol (stdout from hook command)

```json
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Project standard: ...\n"
  }
}
```

### Configuration shape

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/refresh.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

`matcher` is regex (or comma-list) over tool name. `${CLAUDE_PLUGIN_ROOT}` is set when the hook is plugin-shipped.

---

## Monitor anatomy

The `Monitor` tool streams output from a long-running shell command line-by-line into the agent's conversation, asynchronously. Unlike `run_in_background`, it pushes events to the agent on every new stdout line.

| | `Monitor` | `run_in_background` |
|---|---|---|
| Streaming | yes | no |
| Use case | tail logs, watch test runs, poll health checks | silent slow async work |
| Best practice | always pipe through `grep --line-buffered` | n/a |

`Monitor` is not declared as a frontmatter field; it's a tool that agents have if their `tools:` list includes `Monitor`.

---

## Settings anatomy

| File | Scope | Owns |
|---|---|---|
| `~/.claude/settings.json` | user-global | personal env vars, model overrides, global hooks |
| `.claude/settings.json` | project (committed) | project-wide hooks, allowed tools, env vars |
| `.claude/settings.local.json` | project (gitignored) | personal local overrides |
| plugin `hooks/hooks.json` | plugin-shipped | hooks the plugin requires |

Permissions, model defaults, env vars, and hooks live here. Loaded once at session start.

---

## Detection signals (where the harness-tuner agents look)

| Looking for | Walk |
|---|---|
| Root CLAUDE.md | `<repo-root>/CLAUDE.md` |
| Subdirectory CLAUDE.md files | `find <repo-root> -name CLAUDE.md -not -path '*/node_modules/*' -not -path '*/target/*' -not -path '*/.git/*'` |
| Path-scoped rules | `<repo-root>/.claude/rules/*.md` (frontmatter `paths:`) |
| Skills | `<repo-root>/.claude/skills/*/SKILL.md` and installed plugin skills |
| Agents | `<repo-root>/.claude/agents/*.md` |
| Commands | `<repo-root>/.claude/commands/*.md` |
| Hooks | `<repo-root>/.claude/settings.json` (`.hooks` key), plugin `hooks/hooks.json` |
| Settings | `<repo-root>/.claude/settings.json`, `<repo-root>/.claude/settings.local.json`, `~/.claude/settings.json` |
| Monitors | runtime only; cannot be discovered statically |
| User-global | `~/.claude/CLAUDE.md`, `~/.claude/settings.json`, `~/.claude/skills/`, `~/.claude/agents/`, `~/.claude/commands/` |

The `harness-mapper` agent walks all of these in parallel.

---

## When to use this skill

Auto-loaded by every agent in `harness-tuner`. The "what's possible" reference; agents consult it when proposing additions / edits / removals.
