# Skills

Snapshot date: 2026-05-14. Source of truth: <https://code.claude.com/docs/en/skills>.

A skill is a directory under `skills/<name>/` containing a `SKILL.md` plus optional supporting files (`scripts/`, `references/`, templates, etc.). The body is prose instructions; the frontmatter controls when and how Claude loads it.

Slash commands have been folded into skills as a flat-file subset (see [commands.md](commands.md) for the merger details).

## Frontmatter

Per <https://code.claude.com/docs/en/skills#frontmatter-reference>: all fields are optional. Only `description` is recommended, so Claude knows when to use the skill.

| Field | Required | Default | Allowed values | Notes |
|---|---|---|---|---|
| `name` | no | directory name | lowercase letters, digits, hyphens; max 64 chars | Display name. |
| `description` | recommended | first paragraph of body | free text | Combined with `when_to_use`, truncated at 1,536 chars in the skill listing. |
| `when_to_use` | no | — | free text | Appended to `description` in listing. Counts toward 1,536-char cap. |
| `argument-hint` | no | — | string (e.g. `[issue-number]`) | Autocomplete hint. |
| `arguments` | no | — | space-separated string or YAML list of names | Names map by position to `$<name>` substitution. |
| `disable-model-invocation` | no | `false` | bool | Hides from auto-invocation. Also blocks subagent preload. |
| `user-invocable` | no | `true` | bool | When `false`, hidden from `/` menu; Claude can still invoke. |
| `allowed-tools` | no | — | space-sep string or YAML list | Pre-approves tools while skill is active. Does NOT restrict; deny rules still apply. |
| `model` | no | inherits | same as `/model` values, or `inherit` | Override applies for current turn only; not saved. |
| `effort` | no | inherits | `low`, `medium`, `high`, `xhigh`, `max` | Available levels depend on model. |
| `context` | no | — | `fork` | Run in forked subagent context. |
| `agent` | no | `general-purpose` (when `context: fork`) | `Explore`, `Plan`, `general-purpose`, custom agent name | Used only when `context: fork`. |
| `hooks` | no | — | hooks map | Scoped to skill lifecycle. Schema same as `settings.json`. |
| `paths` | no | — | comma-sep string or YAML list of globs | Path-scoped auto-invocation. |
| `shell` | no | `bash` | `bash`, `powershell` | PowerShell requires `CLAUDE_CODE_USE_POWERSHELL_TOOL=1`. |

## The `hooks:` key

`hooks:` is a real top-level frontmatter key in `SKILL.md`. It uses the same shape as the `hooks` block in `settings.json` — event → matcher → handlers. The hooks are active only while the skill is loaded.

When a skill loaded via a subagent declares `Stop` hooks, they auto-convert to `SubagentStop`. See [hooks.md](hooks.md) for the full event catalogue, matcher patterns, decision verbs, and the five handler types (`command`, `http`, `mcp_tool`, `prompt`, `agent`).

Known defect: <https://github.com/anthropics/claude-code/issues/19225> — "Stop hooks in Skills never fire" — closed-as-stale 2026-02-27 after the reproducer remained unfixed for five weeks. If you need a Stop-class hook to reliably enforce a completeness check, declare it in `.claude/settings.json` rather than relying on `SKILL.md` frontmatter. See [references.md](references.md#documented-hazards) for the issue context.

## Skill content lifecycle

Verbatim from <https://code.claude.com/docs/en/skills>:

> When you or Claude invoke a skill, the rendered `SKILL.md` content enters the conversation as a single message and stays there for the rest of the session. Claude Code does not re-read the skill file on later turns.

Implication: edits to a `SKILL.md` during a session do not take effect until the next session. There is no hot-reload semantic for skill bodies.

### Compaction budget

> Claude Code re-attaches the most recent invocation of each skill after the summary, keeping the first 5,000 tokens of each. Re-attached skills share a combined budget of 25,000 tokens.

If a session loads many large skills and is then compacted, only the most recent invocation of each (capped at 5k tokens, total 25k) survives across the summary boundary. Older invocations are dropped.

## Listing budget

Two layers of truncation, both documented at <https://code.claude.com/docs/en/skills#skill-descriptions-are-cut-short>:

- **Per-entry cap.** `description` + `when_to_use` combined is truncated at 1,536 characters in the skill listing. Tunable via the `maxSkillDescriptionChars` setting.
- **Global budget.** Total skill-listing payload scales at 1% of the model context window by default. Tunable with `skillListingBudgetFraction` setting or `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var.

If a skill's description trails into the truncation zone with critical trigger phrasing, the auto-trigger silently misses it. Put the key use case first.

## Registration surface

| Location | Path | Override semantic |
|---|---|---|
| Enterprise (managed) | managed-settings.json | Highest priority; cannot be overridden. |
| Personal | `~/.claude/skills/<skill-name>/SKILL.md` | All your projects. Beats project. |
| Project | `.claude/skills/<skill-name>/SKILL.md` | This project. Beats plugin only by namespace. |
| Plugin | `<plugin>/skills/<skill-name>/SKILL.md` | Where plugin is enabled. Namespaced as `<plugin>:<skill>`, so cannot conflict. |

Auto-discovery: project skills load from `.claude/skills/` walking up from cwd to repo root, and from nested `.claude/skills/` directories on-demand when working with files in subdirectories.

If a skill and a command share the same name within a scope, the skill takes precedence (`code.claude.com/docs/en/skills#where-skills-live`).

## Best practices (Anthropic, verbatim)

- "Keep `SKILL.md` under 500 lines. Move detailed reference material to separate files."
- "Keep the body itself concise. Once a skill loads, its content stays in context across turns, so every line is a recurring token cost. State what to do rather than narrating how or why."
- "Put the key use case first: the combined `description` and `when_to_use` text is truncated at 1,536 characters in the skill listing."
- For skills with side effects: "Add `disable-model-invocation: true` to prevent Claude from triggering it automatically."

Source: <https://code.claude.com/docs/en/skills>. Fetched 2026-05-14.

## Limitations and footguns

- **Skill body is not re-read mid-session.** Edits land at next session-start. There is no hot-reload.
- **`disable-model-invocation: true` blocks subagent preload.** A subagent that lists a side-effecting skill in its `skills:` frontmatter will fail to preload it. Workaround: invoke explicitly from the main conversation, not from agent frontmatter.
- **Listing truncates at 1,536 chars.** Trigger phrasing buried past that point is invisible to auto-trigger.
- **Path globs in `paths:` are evaluated against cwd, not the file actually being touched.** A skill with `paths: ["**/*.tsx"]` only auto-loads when cwd is at or above a `.tsx` file, not when Claude opens one in an unrelated directory.
- **`hooks:` Stop variant doesn't fire on macOS** (bug #19225, closed-stale). For reliable Stop-class enforcement, declare in `.claude/settings.json`.
- **`allowed-tools` pre-approves but does not restrict.** A skill with `allowed-tools: [Read]` does not block `Bash` — it just pre-approves `Read`. Deny rules from `settings.json` still apply.
- **Combined description+when_to_use cap is per-skill, not per-listing.** The 1% global budget is separate; large repos can starve later-listed skills even when each is well under 1,536 chars.

## Marketplace examples

- `plugins/oracle/skills/verification-protocol/SKILL.md` — Auto-trigger knowledge skill; seeded into every session by the oracle `SessionStart` hook.
- `plugins/meta-skill-improver/skills/eval-methodology/SKILL.md` — Reference knowledge bundled alongside `grading.py`; loaded by the orchestrator command's preprocess phase.
- `plugins/anvil/skills/inspect/SKILL.md` — Workflow skill with bundled scripts under `scripts/`, invoked as `/anvil:inspect <path>`.
- `plugins/harness-tuner/skills/claude-md-authoring/SKILL.md` — Knowledge skill auto-loaded by every agent in the harness-tuner pipeline.

## Sources

- [Skills (docs)](https://code.claude.com/docs/en/skills) — fetched 2026-05-14.
- [Subagents, hooks-in-frontmatter section](https://code.claude.com/docs/en/sub-agents#hooks-in-subagent-frontmatter) — fetched 2026-05-14.
- [anthropics/claude-code#19225 — Stop hooks in Skills never fire](https://github.com/anthropics/claude-code/issues/19225) — fetched 2026-05-14, state: closed (stale).
