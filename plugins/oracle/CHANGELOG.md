# Changelog

All notable changes to the `oracle` plugin will be documented in this file.

The format is based on [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2026-05-13

### Added

- **Rate-limit-aware gating on the firecrawl MCP surface.** Two
  new hooks wired in `hooks/hooks.json`:
  - `hooks/rate-limit-guard.sh` (PreToolUse on
    `mcp__plugin_oracle_firecrawl__.*`). Tiered decisions per the
    cost-table thresholds: silent allow under 80% used, soft
    reminder at 80-95%, `permissionDecision: ask` at 95-100% or
    when a single call would consume >= 15% of monthly quota or
    when rolling-hour spend exceeds 5000 credits, hard `deny`
    above 100%. Zero-cost status polls always pass silently.
  - `hooks/rate-limit-track.sh` (PostToolUse on the same).
    Increments monthly / weekly / daily / rolling-hour counters
    by the estimated cost. Caps the recent-calls list at 50.
- **`scripts/cost-table.json`** -- per-tool credit estimates
  sourced from firecrawl.dev/pricing (verified 2026-05-13). Free
  / Hobby / Standard / Growth / Scale plan defaults. Configurable
  thresholds.
- **`scripts/budget-lib.sh`** -- shared budget helpers
  (`read_state`, `write_state`, `estimate_cost`,
  `get_monthly_budget`, `get_threshold`). Project-scoped overrides
  read from `.oracle/budget.json`, user-scoped from
  `~/.claude/plugins/oracle/budget.json`.
- **`agents/cost-rethinker.md`** (Opus 4.7, red) -- read-only
  multi-angle rethinker. When the rate-limit-guard hook flags a
  call as expensive, the orchestrator dispatches this agent to
  return 2-4 cheaper alternatives with credit estimates and
  trade-offs. Goal-restatement first; cache-check before
  alternatives. Recommends approval when no cheaper path exists.
- **`/oracle:budget`** slash command. Subcommands: `show`
  (default, with month-end projection + recent calls), `reset`
  (typed `RESET-ORACLE-BUDGET` confirmation, archives prior
  state to a `.bak` file), `set <key>=<value>` (override
  thresholds or monthly cap).
- **Test suite at `tests/`.** Top-level `tests/run-tests.sh`
  runs shellcheck (with `-x` source-following) on every `.sh`
  file, JSON syntax on every `.json` + `.mcp.json`, and four
  test files: `test-budget-lib.sh` (unit tests for the budget
  library, 24 assertions), `test-intercept-install.sh`
  (integration tests for the v0.1.x install interceptor, 23
  assertions including all the flag-with-arg cases from the
  0.1.1 fix), `test-rate-limit-guard.sh` (13 assertions
  covering each tier), `test-rate-limit-track.sh` (7 assertions
  covering accumulation + caps + non-firecrawl exclusion).
  Current state: 19 file-level pass, 0 fail; 69 individual
  assertions all green.

### Changed

- Every research subagent's body now explicitly directs:
  (1) the plugin-scoped firecrawl MCP tools as the primary
  retrieval surface; (2) the user-installed firecrawl-* skills
  (`firecrawl-search`, `firecrawl-scrape`, `firecrawl-map`,
  `firecrawl-crawl`, `firecrawl-extract`) as the `Skill`-tool
  fallback when `FIRECRAWL_API_KEY` is unset; (3) the oracle
  auto-trigger skills (`verification-protocol`,
  `anti-hype-ranking`) as binding context. The same
  preload-discipline statement was added to the
  `/oracle:verify`, `/oracle:research`, `/oracle:vet`
  slash-command bodies.

### Requires

- `shellcheck` (optional) for running the local test suite.
  `brew install shellcheck` on macOS.

## [0.2.0] - 2026-05-13

### Added

- **Two new slash commands.**
  - `/oracle:research <topic> [--intensity=quick|standard|exhaustive]`
    -- structured research workflow. Quick = one subagent, inline
    multi-ranked library list. Standard = two subagents in parallel
    (canon-reader + github-archivist), half-to-one-page report.
    Exhaustive = all four subagents in parallel, multi-page decision
    matrix.
  - `/oracle:vet <library>` -- single-target exhaustive vetting.
    Dispatches all four subagents in parallel and returns a "should
    I depend on this" verdict with named alternatives.
- **Four specialised Opus-4.7-primed research subagents** in
  `agents/`:
  - `canon-reader` (blue) -- authoritative source material: RFC /
    W3C / IETF specs, official docs, official changelogs,
    maintainer writeups. Spec-conformance verdicts.
  - `github-archivist` (cyan) -- repository archaeology: README,
    license, releases, contributor signal, named downstream
    usage. Repository-health verdicts.
  - `issue-investigator` (yellow) -- target repo issue + PR
    tracker. Time-to-first-response, maintainer voice,
    stable-and-done-vs-abandoned classification. Defeats the
    commit-cadence heuristic.
  - `forum-anthropologist` (magenta) -- Reddit, Hacker News,
    Stack Overflow, Lobsters, dev.to, Discord mirrors. Quoted
    lived-experience reviews.
- **Two new auto-triggering knowledge skills** in `skills/`:
  - `research-protocol` -- the intensity ladder, dispatch
    discipline, per-intensity output contracts, citation rules.
    Auto-loads when an agent is doing oracle research.
  - `anti-hype-ranking` -- encodes the ranking discipline. Stars
    and commit cadence are weak signals; spec conformance,
    maintainer responsiveness, and named downstream usage are
    strong. The fmodel-rust / problem+json class of library must
    not be buried under the popularity default.
- **Plugin-scoped firecrawl MCP server.** New `.mcp.json` pins
  `firecrawl-mcp@3.2.1`. All ten active firecrawl tools
  (`firecrawl_scrape`, `firecrawl_batch_scrape`,
  `firecrawl_check_batch_status`, `firecrawl_map`,
  `firecrawl_search`, `firecrawl_crawl`,
  `firecrawl_check_crawl_status`, `firecrawl_extract`,
  `firecrawl_agent`, `firecrawl_agent_status`) are namespaced as
  `mcp__plugin_oracle_firecrawl__*` and explicitly allow-listed
  on every relevant skill and agent. Deprecated `browser_*` tools
  are intentionally excluded. The four deprecated browser tools
  in firecrawl-mcp are NOT in any allow-list.

### Changed

- `verification-protocol` skill triggers broadened substantially.
  Now fires on hedge phrases ("I think", "I believe", "as I
  recall"), framework feature-existence claims, standards
  references (problem+json, RFC 7807, JSON Schema, OAuth,
  W3C-DTCG, atomic design), and component-system / design-token
  vocabulary. False positives are acceptable; false negatives are
  the failure mode.
- All skill `allowed-tools` and agent `tools` fields are now
  explicit and denied-unless-specified. No implicit access.
- The `/oracle:research` and `/oracle:vet` slash-command bodies
  are thin dispatchers; the detailed protocol moved into the
  auto-triggering `research-protocol` skill, following the
  Anthropic skill analogy (skills = company docs, agents =
  runtime engines).

- **`/oracle:setup` slash command.** Idempotent one-time helper
  that appends a single `@-import` line to `~/.claude/CLAUDE.md`
  pointing at `docs/SEARCH-WORKFLOWS.md`. Reports
  `FIRECRAWL_API_KEY` presence. Safe to re-run.
- **`docs/SEARCH-WORKFLOWS.md`.** Canonical reference for the
  user's preferred research discipline (cascade, intensities,
  anti-hype ranking, niche-surfacing rule). The file the
  `@-import` points at.
- **Scoped Write / Edit for research subagents.** All four
  subagents now write under `.oracle/research/<topic-slug>/`
  (one file per silo: `canon.md`, `github.md`, `issues.md`,
  `forum.md`). System prompts refuse writes outside `.oracle/`.
- **Auto-persisted findings.** `/oracle:research` writes its
  synthesized final report to
  `.oracle/findings/<topic-slug>.md`; `/oracle:vet` writes to
  `.oracle/findings/vet-<library-slug>.md`. Idempotent overwrite
  per slug. The absolute path is printed after every run so the
  user can grep / re-read / pin to CLAUDE.md.
- **Memory-hooks summary section** appended to every per-intensity
  output contract in `research-protocol`. Single short paragraph,
  plain English, optimised for absorption -- the part that gets
  remembered after the full report fades.

### Requires

- `FIRECRAWL_API_KEY` in the environment for the bundled MCP
  server to function. Free-tier keys work; Pro-tier keys unlock
  higher quotas. See README.
- Recommend adding `.oracle/` to project `.gitignore` since
  research artefacts are session-scoped scratch unless explicitly
  promoted.

## [0.1.1] - 2026-05-12

### Fixed

- `hooks/intercept-install.sh`: long-form flags that take an argument
  (`--prefix`, `--cwd`, `--workspace`, `--registry`, `--tag`, `--target`,
  `--target-dir`, `--manifest-path`, `--features`, `--bin`, `--example`,
  `--git`, `--branch`, `--rev`, `--path`, `--root`, `--index`,
  `--index-url`, `--extra-index-url`, `--find-links`, `--constraint`,
  `--no-binary`, `--only-binary`, `--platform`, `--python-version`,
  `--implementation`, `--abi`, `--python`, `--source`, `--group`,
  `--extras`, `--target-release`, `--option`, `--config-file`) now
  correctly consume the following token instead of treating it as a
  package arg. The `--flag=value` form is recognised by token shape.
  Short flags `-w`, `-C`, `-t`, `-G`, `-E` also consume the next token.
  Verified against five edge cases including
  `npm install lodash --prefix /tmp/sandbox` (previously misreported
  the path as a package).

## [0.1.0] - 2026-05-12

### Added

- Initial release.
- SessionStart hook (`hooks/inject-protocol.sh`) that injects the verification
  protocol into every session via `hookSpecificOutput.additionalContext`. The
  protocol mandates a three-tier cascade for every claim about versions,
  libraries, citations, articles, statistics, and forum links:
  package-manager CLI first, then firecrawl-search, then WebSearch.
- PreToolUse hook on the `Bash` tool (`hooks/intercept-install.sh`) that
  inspects install / add subcommands across npm, pnpm, yarn, bun, cargo,
  pip, uv, poetry, brew, apt, apt-get, go, and gem. Distinguishes pinned
  from unpinned installs and emits a soft reminder (non-blocking) when an
  unpinned install is about to run.
- Auto-triggering knowledge skill `verification-protocol` with strong
  trigger phrases for assertions about versions, libraries, citations,
  articles, statistics, and Reddit / Stack Overflow / blog references.
- User-invocable skill `/oracle:verify <claim>` that runs the verification
  cascade explicitly against a stated claim and reports findings with
  source citations.
