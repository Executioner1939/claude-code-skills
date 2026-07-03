# Changelog

All notable changes to the `oracle` plugin will be documented in this file.

The format is based on [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.10.0] - 2026-07-03

### Added

- `/oracle:bugfix` — a diagnose-then-fix workflow distilled from real
  bug-fix sessions, generalized to any language/stack/host. Explicit
  slash-command invocation, plus fires on messages that read as an
  unambiguous bug report paired with a request to fix and ship it.
  - **Ground before touching code**: confirm the actual repo/subtree
    (`git remote -v` — monorepo subtrees can look standalone), check for
    a concurrent session already working the same code path (`gh pr
    list --state open` + sibling dirty-tree check) before implementing
    and again before pushing, then read the git history of the touched
    lines and classify what's there — an accidental regression, a
    deliberate decision that's now wrong for a changed requirement (cite
    the commit, say the reversal out loud), or someone else's legitimate
    in-flight work (surface it, don't revert it).
  - **Fix the root cause with scoped Boy Scout cleanup**: fix what you
    diagnosed, fix a provably-identical gap in a sibling code path you're
    already reading, and say so explicitly — nothing beyond that.
  - **Test per detected stack**: reads the project's own documented
    commands (package.json scripts, Makefile, CI workflow files) rather
    than assuming a fixed toolchain; always adds or extends a test that
    pins the specific bug scenario, not just "the build passes."
  - **Hotfix is the default ship path**: branch off the repo's actual
    default branch, PR with a structured root-cause body, merge using
    whatever convention the repo's own merge history already shows
    (never assumed), review-bypass only on explicit authorization.
  - Ships `references/known-gotchas.md` — generic gotcha *classes*
    (not project-specific facts): concurrent-work races, reverting
    others' commits, build-mode config divergence, stale-state markers,
    immutable declarative-infra fields, deploy-pipeline health-check
    wedges, workspace/monorepo lockfile divergence, sandboxed-shell
    permission limits, and squash-merge ancestry damage.
  - Preloads `path-preflight` and `parallel-tools` as binding during
    diagnosis; routes externally-grounded claims through the existing
    verification cascade rather than asserting from memory.

## [0.9.0] - 2026-06-02

### Changed
- Converted the two slash commands from the flat `commands/` form to the
  `skills/` directory form: `commands/init.md` -> `skills/init/SKILL.md` and
  `commands/narrator.md` -> `skills/narrator/SKILL.md`. Frontmatter and content
  are unchanged, so `/oracle:init` and `/oracle:narrator` behave exactly as
  before. This follows the current Claude Code guidance to use `skills/` for new
  work and unifies the plugin on a single component shape. The `commands/`
  directory is removed.

## [0.8.0] - 2026-05-16

### Added

- Four cherry-picked Firecrawl **research workflow** skills repackaged from
  `firecrawl/firecrawl-workflows@main`:
  - `firecrawl-deep-research` — multi-source autonomous research with
    citations.
  - `firecrawl-research-papers` — academic paper discovery and synthesis.
  - `firecrawl-market-research` — market intelligence: sizing,
    competitive landscape, trends.
  - `firecrawl-competitive-intel` — focused competitor analysis from
    public web data.
- These complement the 14 foundational firecrawl skills from 0.7.0 and the
  twelve original oracle skills. Total: 30 auto-triggering knowledge skills.
- The DevOps-flavoured workflow skills (`firecrawl-knowledge-base`,
  `firecrawl-knowledge-ingest`, `firecrawl-qa`,
  `firecrawl-website-design-clone`) live in the sibling `oracle-devops`
  plugin, alongside Anton Babenko's `terraform-skill`.

## [0.7.0] - 2026-05-16

### Added

- **Firecrawl skills baked in.** Fourteen skills repackaged verbatim from
  `firecrawl/cli@main` (CLI-side: firecrawl-cli + firecrawl-agent,
  firecrawl-search, firecrawl-scrape, firecrawl-map, firecrawl-crawl,
  firecrawl-interact, firecrawl-parse, firecrawl-download) and
  `firecrawl/skills@main` (build-side: firecrawl-build + four
  firecrawl-build-* skills for integrating Firecrawl into product code).
  Installing oracle now gives Claude Code full Firecrawl coverage in a
  single `claude plugin install` call — no separate `npx skills add` step.
- Note: the heavier outcome-focused workflow skills
  (`firecrawl-deep-research`, `firecrawl-seo-audit`,
  `firecrawl-competitive-intel`, etc.) live at the upstream
  `firecrawl/firecrawl-workflows` marketplace and are opt-in via
  `claude plugin marketplace add firecrawl/firecrawl-workflows` +
  `claude plugin install firecrawl-workflows@firecrawl-workflows`.

### Changed

- `firecrawl-mcp` version pinned in `.mcp.json` bumped from `3.2.1` to
  `3.16.0` — picks up the v2 API surface (firecrawl_agent, browser sessions,
  firecrawl_interact, firecrawl_parse) that the new skills assume.

## [0.6.0] - 2026-05-14

### Added

- **Session-summary checkpoint loop.** A CodeRabbit-style periodic summary mechanism with active-vs-idle time accounting. Three new hooks (`UserPromptSubmit` -> `session-tick-start.sh`, `Stop` -> `session-tick-end.sh`, `SessionEnd` -> `session-cleanup.sh`) plus the emitter at `scripts/session-summary.sh`. Per-session state persists at `~/.claude/plugins/oracle/sessions/<session_id>/` and survives across hook fires within the session.

  - **Active-vs-idle time accounting.** Cumulative agent-active milliseconds (`active-ms`) is incremented only by the `Stop` hook, computed as `now - turn-start.ts` where `turn-start.ts` is written by the preceding `UserPromptSubmit`. The interval between `Stop` and the next `UserPromptSubmit` (i.e. user-AFK time) is structurally excluded -- a user who leaves the keyboard for three hours does not register three hours of work. Clock-skew negatives are clamped to zero.

  - **Trigger thresholds.** The `UserPromptSubmit` hook fires `session-summary.sh` when `(active_ms_delta >= 30 min)` OR `(turn_count_delta >= 50)` since the last summary, whichever lands first. Both thresholds are overridable via env vars `ORACLE_SUMMARY_ACTIVE_MS` and `ORACLE_SUMMARY_TURNS`. The very first turn never fires a summary even at degenerate threshold values.

  - **Tier 1 -- deterministic ship-receipt block.** Always emitted. Reads the `transcript_path` JSONL slice since the last summary's recorded line index, counts tool-use blocks by name (`Edit` + `Write` + `MultiEdit` -> file edits, `Read` -> reads, `Bash` -> command invocations, `TaskCreate` / `TaskUpdate`, `Agent` -> subagent dispatches, `Grep` + `Glob`, `WebFetch` + `WebSearch`), formats as a bordered ASCII checkpoint showing timing (active / wall / idle minutes), activity counts, top-10 files touched, and top-10 bash verbs.

  - **Tier 2 -- LLM narrative.** When the narrator is not `off`, shells out to `claude --model "$NARRATOR" -p` (60s timeout) with a structured prompt that includes the deterministic counts and a tail of the agent's own text output (last 8 KB). Returns a CodeRabbit-style review with four fixed sections: "What was accomplished", "Notable decisions", "Quality concerns and friction", "Three review questions for the agent". Silently falls back to Tier 1 if `claude` is unavailable or the call times out.

- **`/oracle:narrator` slash command.** Modelled on the Claude Code `/model` UX. Persists the narrator choice at `~/.claude/plugins/oracle/narrator.conf` (per-machine, not per-project, not per-session). Forms:

  ```
  /oracle:narrator                     # show current
  /oracle:narrator show                # show current
  /oracle:narrator sonnet              # alias for claude-sonnet-4-6 (default)
  /oracle:narrator opus                # alias for claude-opus-4-7
  /oracle:narrator haiku               # alias for claude-haiku-4-5-20251001
  /oracle:narrator <claude-model-id>   # literal model ID
  /oracle:narrator off                 # disable LLM tier (Tier 1 only)
  ```

  Marked `disable-model-invocation: true` so Claude cannot trigger it autonomously (per the marketplace command-with-side-effects convention).

- **`SessionEnd` cleanup.** `session-cleanup.sh` prunes session state dirs under `~/.claude/plugins/oracle/sessions/` last touched more than 30 days ago, plus legacy `reads-<session>.tsv` files from the 0.5.0 safe-edit-guard. Best-effort; never blocks session termination.

### Design notes

- **Why the slash command instead of a static `prompt` handler.** The hooks-doc `prompt` handler type accepts a `model` field, but it is statically declared at hook-registration time in `hooks.json` -- it cannot read user runtime state. Using a `command` handler that shells out to `claude --model "$MODEL" -p` gives full dynamic control; the slash command writes the state file, the hook reads it at fire time.

- **Why `UserPromptSubmit` rather than `Stop` for the summary trigger.** `UserPromptSubmit` fires exactly once per user prompt with clean turn semantics. `Stop` fires once per agent stop but can overfire when subagents stop, and the `stop_hook_active` loop-breaker contract adds ceremony. The turn-start anchor lands cleanly on `UserPromptSubmit`; the active-interval close lands cleanly on `Stop`. Each event does the thing it is structurally good at.

- **Hook timeout.** `session-tick-start.sh` is tagged with a 90s timeout in `hooks.json` to accommodate the narrator's 60s ceiling plus deterministic-tier work plus state-file I/O. The Tier 1 path alone is ~5 ms; the cost is paid only when a threshold is crossed (every 30 min or 50 turns).

- **Global install.** Oracle is already a marketplace plugin; to make the session-summary loop fire across every project, add `oracle` to `~/.claude/settings.json` under the plugins block (or enable the marketplace globally). The state directory under `~/.claude/plugins/oracle/sessions/` is per-machine, so it accumulates across projects naturally and is pruned by `session-cleanup.sh`.

### Why this exists (corpus evidence)

The 0.5.0 transcript-corpus audit surfaced **676 long-session interrupts** across 1,186 sessions on this machine: pattern is user gets lost in a long Claude Code session, loses track of what was decided, asks Claude to summarise but the summary is generic, or aborts the session and starts over. The session-summary loop targets this directly: structured checkpoints at 30-minute active intervals so the user (and the agent) never has more than 30 minutes of work to back-track over.

## [0.5.0] - 2026-05-13

### Added

- **`safe-edit-guard` PreToolUse hook on Edit / Write / MultiEdit /
  NotebookEdit.** Cross-session transcript audit of 1,186 sessions on
  this machine surfaced ~1,128 failures of the form `File has not been
  read yet`, `File has been modified since read`, and `String to
  replace not found in file` -- the single largest preventable
  tool-error class. The guard consults a per-session reads state file
  (`~/.claude/plugins/oracle/reads-<session>.tsv`) and emits a
  non-blocking reminder when the target path has not been Read within
  a 30-minute freshness window. Silent on Write-to-nonexistent-path
  (new file creation), silent on jq/json-parse failures (fail-silent
  policy). Companion `track-reads.sh` PostToolUse hook records the
  state.
- **`parallel-tools` auto-trigger skill.** Same audit found 0 parallel
  tool batches across 3,340 tool-bearing assistant messages in the ten
  most recent sessions. Reverses Opus 4.7's documented under-spawning
  bias at the point of dispatch; encodes when to parallelise, when not
  to, and how the dispatch is phrased.
- **`path-preflight` auto-trigger skill.** Same audit found ~300
  events per recent-ten sessions of `File does not exist` plus HTTP
  404 plus HTTP 403 -- almost all from speculative paths and URLs.
  Encodes the list-before-read discipline with a tool-by-surface
  reference table.
- **`session-checkpoint` auto-trigger skill.** Same audit found 676
  user interrupts across 221 sessions, concentrated in long Rust and
  TS monorepo sessions (one RedactedCo session received 24 interrupts).
  Encodes the mirror-back-progress habit at phase boundaries and at
  twenty-tool-call intervals.
- **YAML frontmatter validation (`tests/run-tests.sh` Stage 2b).**
  Catches the class of skill-frontmatter parse error that previously
  silently disabled the `anti-hype-ranking` and `vet` skills in
  0.2.0. Uses `python3 -c yaml.safe_load`.
- **POSIX `[ ... == ... ]` lint (`tests/run-tests.sh` Stage 2c).**
  Catches `==` inside single-bracket tests, which explodes under zsh
  with `(eval):1: == not found`. Cross-session audit: 17 hits.
- **`tests/test-safe-edit-guard.sh`** -- ten integration cases against
  the new hook pair, using an isolated `$HOME` so the production
  state file is untouched.

### Changed

- `hooks/hooks.json` now wires two additional hooks: a PreToolUse
  matcher `Edit|Write|MultiEdit|NotebookEdit` for the safe-edit
  guard, and a PostToolUse matcher `Read` for the reads tracker.

### Rationale

This release acts on findings from a structural audit of every Claude
Code transcript on this machine. The three new skills + one new
hook + two new test stages target the highest-frequency preventable
failure modes surfaced by that audit, in descending order of
recurrence x severity:

1. Write-before-Read errors (~1,128 events) -> `safe-edit-guard` hook.
2. Zero parallel-tool dispatch -> `parallel-tools` skill.
3. Speculative paths / URLs (~300 events) -> `path-preflight` skill.
4. Long-session drift / interrupts (676 events) -> `session-checkpoint`
   skill.
5. YAML frontmatter parse errors (2 events in this codebase) -> Stage
   2b YAML validation.
6. zsh-vs-bash `==` inside `[ ]` (17 events) -> Stage 2c lint.

## [0.4.0] - 2026-05-13

### Added

- **`mcp-fleet` -- multi-workspace MCP onboarding utility.** Bundled
  out-of-band per user request; out of theme with the verification
  harness but kept here as a convenience while it stabilises. Lives at
  `scripts/mcp-fleet/` (Node ESM) plus `skills/mcp-fleet/SKILL.md` (the
  user-facing `/oracle:mcp-fleet` entry).
  - **Per-workspace Chromium profile isolation.** Each (service,
    workspace) pair gets its own `--user-data-dir` under
    `~/.claude/oracle/mcp-fleet/chrome-profiles/<service>/<label>/`.
    Sidesteps `anthropics/claude-code#39952`,
    `microsoft/vscode#293533`, and `atlassian/atlassian-mcp-server#23`
    -- all three collapse OAuth tokens across workspaces by keying on
    server-name or URL-origin. Mirrors Atlassian's official
    "use-separate-browser-profiles-per-site" recommendation.
  - **Five service probes.** `services/{slack,linear,notion,github,
    atlassian}.mjs`. Slack uses cookie-extraction (the `d` cookie is
    the xoxd token, the xoxc token is read from
    `localStorage.localConfig_v2.teams.<TEAM_ID>.token`) since Slack
    restricts MCP-eligible apps to the Marketplace and internal apps.
    Linear, Notion, GitHub, and Atlassian use API-token paste-prompts
    because their UIs reveal secrets via flash modals or one-time
    displays that can't be re-extracted reliably. Every probe always
    falls back to a manual paste prompt if auto-extraction fails.
  - **Source-of-truth store.** `~/.claude/oracle/mcp-fleet/workspaces.json`
    (mode 600), schema versioned at `1`. Service-specific `credentials`
    object so the matrix builder drops fields straight into env.
  - **Matrix builder.** `build-matrix.mjs` reads the store and writes
    a Claude-Code-native `.mcp.json` to
    `~/.claude/oracle/mcp-fleet/mcp-fleet.json`, one stdio MCP server
    per workspace, named `<service>__<label>`. Pinned upstream
    server packages (registry-verified 2026-05-13):
    `slack-mcp-server@1.2.3` (korotovsky),
    `mcp-server-linear@1.6.0` (dvcrn -- unscoped on npm, with
    auto-set `TOOL_PREFIX` for tool-name disambiguation across
    workspaces), `@notionhq/notion-mcp-server@2.2.1`,
    `ghcr.io/github/github-mcp-server` (official Docker image), and
    `mcp-atlassian==0.21.1` (sooperset, run via `uvx` -- the
    PyPI/Python canonical port; the npm package of the same name is
    by a different author).
  - **Three publish modes.** `publish.mjs` prints copy-pasteable
    instructions for project-scoped merge, user-scoped
    `claude mcp add` per server, or direct `jq`-based merge into
    `~/.claude.json`.
  - **Cross-platform.** Pure Node ESM (no bash/PowerShell split).
    `lib/profile-dir.mjs` resolves the isolated profile root per OS;
    `lib/playwright-launcher.mjs` lazy-installs `playwright-core`
    via `npx` on first use (~300MB Chromium download, one-time).
- **`/oracle:mcp-fleet` slash command.** Subcommands: `list`, `add
  <service> [label]`, `remove <service> <label>`, `build`, `publish`.
  Stream-mode output -- the discovery flow is interactive and prompts
  must reach the user in real time.
- **Experimental MetaMCP scaffold** at
  `scripts/mcp-fleet/templates/docker-compose.yml.tmpl`. Not wired by
  v0; preserved for v1 footprint optimisation when N concurrent stdio
  MCP children become a real cost.

### Notes

- v0 deliberately uses Claude Code's native multi-server `.mcp.json`
  rather than a router. We're handing per-instance API tokens via env,
  so Claude Code's OAuth-keyring-collision bug is irrelevant. The
  router (MetaMCP) is a v1 footprint optimisation, not a correctness
  fix.
- `mcp-fleet` is structurally orthogonal to the truth-verification
  harness. Future maintainers should consider extracting it to its own
  plugin (`mcp-fleet`) once it stabilises.

## [0.3.1] - 2026-05-13

### Fixed

- `agents/cost-rethinker.md` referenced `firecrawl_interact` which
  was missing from `scripts/cost-table.json`. Added the tool with
  the canonical 2-credit-per-call estimate. The rate-limit hook
  was silently treating unknown tools as cost 0, masking the
  inconsistency.
- `scripts/budget-lib.sh` `get_monthly_budget` could return an
  empty string when a config file existed but lacked a
  `monthly_credits` key, leaving the rate-limit hook's `BUDGET`
  variable empty and masking misconfiguration. Now explicitly
  validates non-empty and positive before returning.
- `skills/setup/SKILL.md` hardcoded the `skunkworks` marketplace
  alias in the docs-path resolution. Now prefers
  `$CLAUDE_PLUGIN_ROOT` (marketplace-agnostic) and falls back to
  `cache/*/oracle/*` so any marketplace alias resolves.
- `agents/cost-rethinker.md` had `Bash` in its tool list despite
  the body declaring it a pure-reasoning silo. Dropped `Bash`
  from the allow-list to match the declared posture.
- `hooks/rate-limit-track.sh` `rolling_hour` array had no
  length safety net. Added a `.[-500:]` cap; the time-based
  filter remains the primary trim mechanism.
- `skills/budget/SKILL.md` `set` subcommand showed `--argjson`
  and `--arg` jq invocations without a numeric-vs-string guard.
  Wrapped both in a `case` statement that detects numeric values
  and dispatches accordingly.
- `README.md` claimed "three slash commands" and "Hooks (two)";
  actual counts at v0.3.0 are five slash commands and four
  hooks. Updated the section headers and added missing entries
  for `/oracle:setup`, `/oracle:budget`, and the cost-rethinker
  agent.
- `docs/SEARCH-WORKFLOWS.md` roadmap advertised v0.3.0 as
  upcoming. Moved to a "Shipped" recap, advanced the roadmap to
  v0.4.0 (corpus-wide discipline guards) and v0.5.0 (streaming-
  as-available findings).

### Changed

- `skills/research-protocol/SKILL.md` parallel-dispatch language
  hardened from prose to imperative. Explicit "FIRST assistant
  turn MUST contain N parallel `Agent` tool-call blocks" where N
  matches the chosen intensity. Pass-2 corpus audit found 0
  parallel batches across 10 newest sessions of 3,340 tool-
  bearing assistant messages -- the previous "Run independent
  lookups in parallel" prose was too soft for Opus 4.7's
  under-spawn default.
- `skills/research-protocol/SKILL.md` quick-intensity output
  contract now mandates filling the `Niche but mature` slot or
  explicitly stating "no niche-but-mature option surfaced".
  Previously the niche-surfacing rule was only binding on
  `standard` and `exhaustive`.
- Every research subagent's `tools` allow-list narrowed to the
  firecrawl MCP tools each silo actually uses.
  `canon-reader` keeps search / scrape / map / extract / crawl /
  batch_scrape + status pairs (drops `firecrawl_agent`,
  `firecrawl_interact`). `github-archivist` keeps search /
  scrape / extract / batch_scrape (drops map / crawl / agent /
  interact). `issue-investigator` keeps search / scrape (drops
  everything else). `forum-anthropologist` keeps search / scrape
  / batch_scrape (drops the rest). The `firecrawl_agent` tool
  (50 credits per run) is no longer in any subagent's allow-list
  by default; re-add per-silo if a workflow needs it.
- `skills/verify/SKILL.md` allow-list dropped the expensive
  firecrawl tools (`firecrawl_crawl`, `firecrawl_extract`,
  `firecrawl_agent`, `firecrawl_batch_scrape` and their status
  pairs). A `/oracle:verify` call should be cheap; complex
  retrieval belongs in `/oracle:research`.
- Every research subagent body now correctly states that the
  oracle plugin's auto-trigger skills (`verification-protocol`,
  `anti-hype-ranking`) load automatically when their trigger
  phrases match -- not via explicit `Skill` invocation. The
  previous "do not skip the load" language read as a no-op
  invocation directive.
- Every research subagent body now distinguishes `WebSearch`
  (returns snippets) from `WebFetch` (returns page content) on
  the citation discipline. A URL appearing in a WebSearch result
  is not a citable source until `WebFetch` has read the page in
  the same invocation.
- `agents/cost-rethinker.md` cost-table reference replaced with
  a directive to `Read` the source-of-truth
  `scripts/cost-table.json` at the start of every invocation.
  The previous inline table was already drifting from the JSON.

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
