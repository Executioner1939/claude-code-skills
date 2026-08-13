# References

Snapshot date: 2026-05-14. Every URL below was fetched on the date noted alongside it. Treat the dates as expiry markers — Anthropic re-organised the docs hierarchy at least once in the past year, and community repos shift cadence quickly.

## Anthropic canon

Authoritative source for every claim about Claude Code components, frontmatter, runtime behaviour, and limitations. The docs were migrated from `docs.claude.com/en/docs/claude-code/*` to `code.claude.com/docs/en/*` at some point during the past year; the old URLs 301-redirect.

| Topic | URL |
|---|---|
| Skills (canonical for skills AND flat-file commands) | <https://code.claude.com/docs/en/skills> |
| Subagents | <https://code.claude.com/docs/en/sub-agents> |
| Hooks (reference) | <https://code.claude.com/docs/en/hooks> |
| Hooks (guide) | <https://code.claude.com/docs/en/hooks-guide> |
| Plugins (guide) | <https://code.claude.com/docs/en/plugins> |
| Plugins (reference) | <https://code.claude.com/docs/en/plugins-reference> |
| Settings | <https://code.claude.com/docs/en/settings> |
| Memory / `CLAUDE.md` | <https://code.claude.com/docs/en/memory> |
| Changelog (preserves 2.1.x; 2.0.x history not retained) | <https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md> |

All fetched 2026-05-14.

## Community mastery repos

Worked reference implementations across component types. Inclusion criterion: actively maintained at fetch time and either author-recognised in the space or top-of-niche by star count. Each entry carries fetch date and last-commit date so freshness is visible.

### Hooks

- **[disler/claude-code-hooks-mastery](https://github.com/disler/claude-code-hooks-mastery)** — Worked implementations of all 13 (now 29) hook lifecycle events with JSON payloads, plus a meta-agent and team-based validation example.
  - Last push: 2026-03-04. Repo created 2025-07-05. Stars: 3,664 at fetch time.
  - **License: none declared.** No `LICENSE` file. Reference-only — do not vendor the code.
  - Fetched 2026-05-14.

### Skills

- **[anthropics/skills](https://github.com/anthropics/skills)** — Anthropic's own public catalogue of skill patterns. Closest thing to a canonical Skills-mastery repo.
  - Last push: 2026-05-09. Repo created 2025-09-22.
  - **License: mixed and per-skill.** README states "many skills in this repo are open source (Apache 2.0)" and the four document skills (`docx`, `pdf`, `pptx`, `xlsx`) are "source-available, not open source". Per-skill LICENSE files exist; no top-level LICENSE. Check each before vendoring.
  - Fetched 2026-05-14.

A `disler/claude-code-skills-mastery` repo does not exist (confirmed 404, 2026-05-14).

### Subagents

- **[wshobson/agents](https://github.com/wshobson/agents)** — Opinionated subagent catalogue plus orchestration primitives. Same author as `wshobson/commands` below.
  - Last push: 2026-05-14 (active daily). Repo created 2025-07-24.
  - License: MIT.
  - Fetched 2026-05-14.

- **[VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents)** — 100+ specialised subagent recipes covering a wide range of development use cases. Breadth catalogue complement to `wshobson/agents`'s orchestration shape.
  - Last push: 2026-04-20. Repo created 2025-07-30.
  - License: MIT.
  - Fetched 2026-05-14.

A `disler/claude-code-subagents-mastery` repo does not exist; subagents are demonstrated inside `claude-code-hooks-mastery`'s Sub-Agents section.

### Slash commands

- **[wshobson/commands](https://github.com/wshobson/commands)** — Production-ready slash commands. Companion to `wshobson/agents`.
  - Last push: 2025-10-12 (slipped to maintenance mode). Repo created 2025-06-14.
  - License: MIT.
  - Fetched 2026-05-14.

- **[hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)** — Curated awesome-list across all four component types. Not a shape demonstrator; use as a discovery index.
  - Last push: 2026-04-27. Repo created 2025-04-19.
  - **License: Other / NOASSERTION.** Treat as source-available with attribution. Check each linked repo's licence before vendoring.
  - Fetched 2026-05-14.

A `disler/claude-code-commands-mastery` repo does not exist.

## Documented hazards

GitHub issues that catalogue reproducible defects in component behaviour. All three are now closed, but each carries a reproducer that survives the closed state — treat them as "documented hazard with repro" rather than "live open bug".

- **[anthropics/claude-code#19225](https://github.com/anthropics/claude-code/issues/19225)** — "Stop hooks in Skills never fire". Closed-as-stale 2026-02-27 after 5 weeks of inactivity, not closed-as-fixed. macOS only. Reproducer in thread. For reliable Stop enforcement, declare hooks in `.claude/settings.json` rather than `SKILL.md` frontmatter.
- **[anthropics/claude-code#10412](https://github.com/anthropics/claude-code/issues/10412)** — "Stop hooks with exit code 2 fail to continue when installed via plugins". Closed 2025-11-02 within a week of opening. Likely fixed in product (no commit reference surfaces from `gh`), so verify against the changelog before claiming "fixed in vX.Y".
- **[anthropics/claude-code#55754](https://github.com/anthropics/claude-code/issues/55754)** — Stop hook returning `{"ok": false}` infinite loop, consumed full session quota (~50 min). Closed as duplicate 2026-05-06. Root cause: missing `stop_hook_active` check.

## Notable open issues for marketplace authors

Selected by recency and labels (`area:hooks`, `area:skills`, `area:plugins`, `area:model`). Watch these.

- **[anthropics/claude-code#57661](https://github.com/anthropics/claude-code/issues/57661)** — "opus Skill rewrites: ignored own /verify skill, made unverified claims, regressed to prose summaries". 11 comments at fetch time. Directly relevant: Opus 4.7 observed ignoring its own auto-trigger verification skill — the failure mode the oracle plugin exists to mitigate.
- **[anthropics/claude-code#58637](https://github.com/anthropics/claude-code/issues/58637)** — "Background subagent state sync — zombie 'running' agents cause stop hook infinite loop after all subagents have terminated". 11 comments. Second class of Stop-loop pathology, this one from subagent state desync. Pairs with #55754.
- **[anthropics/claude-code#55008](https://github.com/anthropics/claude-code/issues/55008)** — "`/reload-plugins` does not reload hook scripts — stale hooks persist until session restart". 4 comments. Iterate on hooks in `.claude/hooks/` during development; switch to plugin layout only after the script stabilises.
- **[anthropics/claude-code#57570](https://github.com/anthropics/claude-code/issues/57570)** — "v2.1.136 regression: marketplace entry `skills: [\"./\"]` rejected with `Path escapes plugin directory` for plugins without `plugin.json`". 3 comments. Direct marketplace-author bug.
- **[anthropics/claude-code#49990](https://github.com/anthropics/claude-code/issues/49990)** — "Bare hook entry `{type, command}` silently breaks entire hooks config — no error, no warning". 3 comments. Always nest hooks inside `hooks: [{matcher, hooks: [...]}]`.

## Methodology note

These references are verified, not curated. Every URL was fetched on its tagged date. Anthropic doc URLs were validated against the post-2026 `code.claude.com` host (the older `docs.claude.com` paths 301-redirect). Community repos were validated via `gh repo view` for existence and last-push date. GitHub issues were validated via `gh api repos/anthropics/claude-code/issues/<n>` for title, state, and close date. If a fact has drifted, the date stamp is your signal to re-verify.
