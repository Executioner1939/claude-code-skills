# Slash commands

Snapshot date: 2026-05-14. Source of truth: <https://code.claude.com/docs/en/skills>.

## The merger

Anthropic merged custom slash commands into skills. The two file layouts both create the same `/<name>` invocation and share the same frontmatter:

- **Flat-file** — `.claude/commands/<name>.md`. Single markdown file. Backwards-compatible legacy layout.
- **Directory** — `.claude/skills/<name>/SKILL.md`. Directory with optional supporting files (`scripts/`, `references/`, templates) and the ability for Claude to auto-load when relevant.

Anthropic, verbatim (`code.claude.com/docs/en/skills`):

> A file at `.claude/commands/deploy.md` and a skill at `.claude/skills/deploy/SKILL.md` both create `/deploy` and work the same way. Your existing `.claude/commands/` files keep working. Skills add optional features: a directory for supporting files, frontmatter to control whether you or Claude invokes them, and the ability for Claude to load them automatically when relevant.

For new authoring in this marketplace, prefer the directory form when the command has supporting scripts, templates, or extended reference material. Prefer the flat-file form for one-shot commands that fit cleanly in a single body.

## Frontmatter

The full table is documented under [skills.md](skills.md#frontmatter). Fields most commands use:

| Field | Type | Default | Purpose |
|---|---|---|---|
| `description` | string | first paragraph of body | When to use the command. Combined with `when_to_use`, truncated at 1,536 characters in the slash-command listing. |
| `argument-hint` | string | — | Autocomplete hint shown after `/<name>` in the prompt UI. |
| `arguments` | string \| list | — | Named positional arguments. With `arguments: [issue_number, repo]`, the substitutions `$issue_number` and `$repo` resolve in the body. |
| `allowed-tools` | string \| list | — | Pre-approves these tools while the command is active. Does not override deny rules from `settings.json`. |
| `disable-model-invocation` | bool | `false` | When `true`, Claude cannot trigger the command autonomously — only the user typing `/<name>` invokes it. |
| `model` | string | inherits | Override model for this command. `inherit`, `sonnet`, `opus`, `haiku`, or a full ID like `claude-opus-4-7`. |
| `effort` | string | inherits | `low`, `medium`, `high`, `xhigh`, `max`. Available levels depend on the model. |
| `user-invocable` | bool | `true` | When `false`, the command is hidden from the `/` menu. Claude can still invoke it. |
| `hooks` | object | — | Hooks scoped to the command's lifecycle. Same schema as `settings.json`. |

`name` defaults to the filename without `.md`. `paths` (glob list) and `context: fork` are also valid; see [skills.md](skills.md#frontmatter) for the complete 16-field table.

## Argument and string substitutions

The body is preprocessed before Claude sees it:

| Substitution | Resolves to |
|---|---|
| `$ARGUMENTS` | All args, verbatim. |
| `$ARGUMENTS[N]` or `$N` | Positional, 0-based, shell-style quoted. |
| `$<name>` | Named argument from `arguments:` frontmatter. |
| `${CLAUDE_SESSION_ID}`, `${CLAUDE_EFFORT}`, `${CLAUDE_SKILL_DIR}` | Environment substitutions. |
| `` !`<command>` `` | Single-line shell injection. Output replaces the backticked block. |
| ` ```! ` fenced block | Multi-line shell injection. Output replaces the fenced block. |
| `@path/to/file` | File inclusion. Path resolves relative to the command file. |

Source: <https://code.claude.com/docs/en/skills#available-string-substitutions> and `#inject-dynamic-context`. Fetched 2026-05-14.

## Registration surface

| Scope | Path | Invocation |
|---|---|---|
| Personal | `~/.claude/commands/<name>.md` or `~/.claude/skills/<name>/SKILL.md` | `/<name>` |
| Project | `.claude/commands/<name>.md` or `.claude/skills/<name>/SKILL.md` | `/<name>` |
| Plugin (flat) | `<plugin>/commands/<name>.md` | `/<plugin>:<name>` |
| Plugin (directory) | `<plugin>/skills/<name>/SKILL.md` | `/<plugin>:<name>` |

If a skill and a command share the same name within a scope, the skill takes precedence (`code.claude.com/docs/en/skills#where-skills-live`).

Plugin manifest paths behave differently per component. From <https://code.claude.com/docs/en/plugins-reference>, verbatim: "Replaces the default: `commands`, `agents`, `outputStyles`, `experimental.themes`, `experimental.monitors`. Adds to the default: `skills`." So setting `commands: ["./custom-commands"]` in `plugin.json` removes the default `commands/` directory from the scan, while `skills:` augments it.

## Best practices (Anthropic, verbatim)

- "Keep `SKILL.md` under 500 lines. Move detailed reference material to separate files."
- "Put the key use case first: the combined `description` and `when_to_use` text is truncated at 1,536 characters in the skill listing to reduce context usage."
- For side-effecting workflows (deploy, commit, send-slack-message): "You don't want Claude deciding to deploy because your code looks ready. Add `disable-model-invocation: true`."

Source: <https://code.claude.com/docs/en/skills>. Fetched 2026-05-14.

## Marketplace examples

The marketplace ships flat-file commands at `plugins/<plugin>/commands/<name>.md` and directory-form skills at `plugins/<plugin>/skills/<name>/SKILL.md`. Representative examples:

- `plugins/meta-skill-improver/commands/improve-skill.md` — Long-form orchestrator with shell injection in Phase 0 bootstrap, agents pre-approved via `Agent(...)` entries in `allowed-tools`, `disable-model-invocation: true` so the eval pipeline only fires when the user explicitly types `/meta-skill-improver:improve-skill`.
- `plugins/oracle/commands/oracle-research.md` (and siblings) — Research orchestrators that dispatch silos.
- `plugins/anvil/skills/inspect/SKILL.md` — Directory-form skill bundling supporting scripts under `scripts/`.

## Limitations and footguns

- Commands invoked from a subagent context inherit the subagent's tool allow-list, not the main session's. If your command uses `allowed-tools: [Bash(npm:*)]`, that pre-approval only applies in sessions that can call `Bash` at all.
- Argument substitutions are textual — they do not validate or sanitize. `$ARGUMENTS` injected directly into a `` !`<command>` `` block is a shell-injection surface. Treat user input as untrusted and quote it (`printf %q`).
- `disable-model-invocation: true` does not stop a subagent loaded via `skills:` frontmatter from triggering the command. It blocks the auto-trigger mechanism, not direct invocation.
- The plugin manifest's `commands:` field **replaces** the default `commands/` directory rather than adding to it. If you set `commands: ["./custom-commands"]`, the default `commands/` is no longer scanned.
- Argument-hint phrasing is cosmetic. The autocomplete does not enforce that the user actually supplies arguments matching the hint; the body's substitutions just resolve to empty strings.

## Sources

- [Skills (canonical for both flat-file commands and directory skills)](https://code.claude.com/docs/en/skills) — fetched 2026-05-14.
- [Plugins reference](https://code.claude.com/docs/en/plugins-reference) — fetched 2026-05-14.
