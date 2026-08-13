# CLAUDE.md — skunkworks marketplace

Personal Claude Code plugin marketplace. Fourteen plugins covering CI/CD, Rust, documentation, code analysis, design systems, infrastructure-as-code review, Solana indexing, multi-agent orchestration, and meta-tooling.

## Repo conventions

- **Per-plugin `CHANGELOG.md` must move in lockstep with `plugin.json` version bumps.** Same commit, every time. Keep-a-Changelog 1.1.0 format.
- **Marketplace version in `.claude-plugin/marketplace.json`** is the source of truth for the badge in `README.md`. Bump it whenever any plugin version changes.
- **No emojis in any committed file** — code, docs, commit messages, manifests.
- **No personal or medical content** ever lands here. `~/.claude/EXPERIENCE.md` and `~/.claude/DIAGNOSIS.md` are local-only and must not be referenced in any committed artefact.
- **Plugin layout follows the post-merger convention.** Skills live under `plugins/<plugin>/skills/<name>/SKILL.md`; flat-file slash commands live under `plugins/<plugin>/commands/<name>.md`. Both are valid; Anthropic documents commands as a flat-file subset of skills.

## Authoring references

Per-component reference docs sit under `docs/claude-code/`. Each one enumerates every supported frontmatter field, registration surface, runtime behaviour, limitations Anthropic documents, and Anthropic's stated best practices. Source quotes are cited inline with their fetch date.

- [Slash commands](docs/claude-code/commands.md) — `.md` files under `commands/`. Now documented as a flat-file subset of skills.
- [Subagents](docs/claude-code/subagents.md) — `.md` files under `agents/`. Plugin subagents have a reduced frontmatter surface for security; the doc spells out which fields are silently ignored.
- [Skills](docs/claude-code/skills.md) — `SKILL.md` files under `skills/<name>/`. Includes the `hooks:` frontmatter key, lifecycle and budget rules, the 1,536-char listing cap.
- [Hooks](docs/claude-code/hooks.md) — all 29 events, five handler types (`command`, `http`, `mcp_tool`, `prompt`, `agent`), worked Stop-hook patterns, decision verbs per event.
- [References](docs/claude-code/references.md) — Anthropic canon URLs, community mastery repos verified to exist, known-defect issue numbers with current state.

## Plugin index

See [README.md](README.md) for the user-facing pitch and install commands. Manifest source-of-truth is `.claude-plugin/marketplace.json`.

## When updating a plugin

1. Edit the plugin under `plugins/<name>/`.
2. Bump `plugins/<name>/.claude-plugin/plugin.json` `version`.
3. Update `plugins/<name>/CHANGELOG.md` with the new version in Keep-a-Changelog format.
4. Bump `.claude-plugin/marketplace.json` `metadata.version` and the matching `plugins[].version` entry.
5. Commit all four changes together. `README.md`'s marketplace-version badge is best-effort; flag a stale badge but don't block on it.

## When authoring a new component

- **Slash command** — read [commands.md](docs/claude-code/commands.md) and [skills.md](docs/claude-code/skills.md) (commands are a skills subset). For commands that *do* something (deploy, send-message, commit), set `disable-model-invocation: true` so Claude cannot trigger them autonomously.
- **Subagent** — read [subagents.md](docs/claude-code/subagents.md). Plugin subagents cannot use `hooks`, `mcpServers`, or `permissionMode` in frontmatter — those fields are silently ignored. Use `Agent(<name>)` in `allowed-tools` to grant the dispatching command the right to spawn the agent.
- **Skill** — read [skills.md](docs/claude-code/skills.md). Target under 500 lines for the SKILL.md body; reference material goes in sibling files inside the skill directory. Keep the combined `description + when_to_use` under 1,536 characters or the skill listing truncates.
- **Hook** — read [hooks.md](docs/claude-code/hooks.md). Always check `stop_hook_active` in any Stop or SubagentStop hook — [references.md](docs/claude-code/references.md) documents the issue numbers that catalogue what happens when you skip it.

## Verifying claims

The marketplace ships an `oracle` plugin whose verification protocol is in force by default. External-referent claims (versions, package names, doc URLs, statistics, citations) must run through its three-tier cascade: package-manager CLI → `firecrawl-search` → `WebSearch` / `WebFetch`. Skipping the cascade is a regression, not an optimisation. See `plugins/oracle/skills/verification-protocol/SKILL.md` for the protocol body.
