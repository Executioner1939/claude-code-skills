# oracle

Truth-verification harness with structured research, for Claude Code.
Stops the agent from asserting versions, library APIs, citations,
benchmarks, or forum references it has not actually verified, and
runs disciplined ecosystem research when you do need a recommendation.

The plugin name is sci-fi by intent. The pattern it implements is
older: *do not speak as if you know what you have not checked, and
when you do recommend, do not bury the niche-but-correct library
under the popularity default*.

## The model

Two hooks plus three slash commands plus four subagents plus three
auto-triggering knowledge skills, all driving one rule:

**Before any externally-verifiable claim leaves the assistant, run
the verification cascade. When the claim is a recommendation, run
the research protocol with the anti-hype ranking discipline.**

The cascade has three tiers, in order:

1. **Package-manager CLI** -- fastest, most authoritative for
   versions. `npm view`, `pnpm view`, `cargo search`,
   `pip index versions`, `uv pip index versions`, `gem info -r`,
   `go list -m -versions`, `brew info --json=v2`,
   `apt-cache madison`.
2. **Plugin-scoped firecrawl MCP** -- the bundled `firecrawl-mcp@3.2.1`
   server exposes ten tools (`firecrawl_search`, `firecrawl_scrape`,
   `firecrawl_map`, `firecrawl_crawl`, `firecrawl_batch_scrape`,
   `firecrawl_extract`, `firecrawl_agent`, plus their status pairs).
   Requires `FIRECRAWL_API_KEY` in the environment.
3. **WebSearch + WebFetch** -- fallback when firecrawl is
   unconfigured.

## Components

### Slash commands (three, namespace `/oracle:`)

`/oracle:verify <claim>`
: Single-claim verification through the three-tier cascade.
  Returns `verified / partially verified / unverified / refuted`
  with inline citations.

`/oracle:research <topic> [--intensity=quick|standard|exhaustive]`
: Structured ecosystem research. Quick = one subagent, inline
  multi-ranked library list. Standard = two subagents in parallel,
  half-to-one-page cross-validated report. Exhaustive = all four
  subagents in parallel, multi-page decision matrix with anti-hype
  callouts. Context-aware -- "datagrid" after a Next.js
  conversation grounds to "Next.js-compatible datagrid options".

`/oracle:vet <library>`
: Single-target exhaustive vetting. Dispatches all four subagents
  in parallel. Returns a `strong-yes / yes / conditional / no /
  strong-no` verdict with named alternatives and a license-risk
  check.

### Subagents (four, Opus-4.7-primed, effort high)

`canon-reader` (blue)
: Authoritative source material. RFC / W3C / IETF / ECMA specs,
  official docs sites, official changelogs, maintainer's own
  blog and rationale writeups. Returns spec-conformance verdict
  (`faithful / partial / divergent / unrelated`), documentation-
  quality verdict, and design-rationale signal.

`github-archivist` (cyan)
: Repository archaeology. Reads README, license, releases,
  contributor count, named downstream users. Distinguishes
  stable-and-done from abandoned. Anti-hype discipline binding.

`issue-investigator` (yellow)
: Target repo issues + PR tracker. Time-to-first-response,
  maintainer-voice quotes, oldest-open-issue analysis. The silo
  that defeats the commit-cadence heuristic -- low PR activity on
  a mature library is a positive signal when issues get timely
  thoughtful responses.

`forum-anthropologist` (magenta)
: Reddit, Hacker News, Stack Overflow, Lobsters, dev.to, Discord
  mirrors. Quotes lived experience verbatim with URLs. Surfaces
  switching narratives, gotchas, and user-named alternatives.

### Auto-triggering knowledge skills (three)

`verification-protocol`
: Loads whenever the assistant is about to assert anything
  externally-grounded. Triggers liberally -- including hedge
  phrases ("I think", "I believe", "as I recall"), framework
  feature-existence claims, and any standards reference.

`research-protocol`
: Loads whenever an agent is conducting oracle research. Defines
  the intensity ladder, the parallel-dispatch discipline, and the
  per-intensity output contracts.

`anti-hype-ranking`
: Loads whenever the assistant is ranking or comparing libraries.
  Encodes the discipline: GitHub stars are weak signal, commit
  cadence is weak signal, spec conformance / API stability /
  maintainer responsiveness / named downstream usage are strong
  signals. Requires a niche-but-mature option to be surfaced by
  name on every comparison output.

### Hooks (four)

`SessionStart` -> `hooks/inject-protocol.sh`
: Injects the verification protocol into every session as
  `additionalContext`. Reversible -- disabling the plugin removes
  it cleanly.

`PreToolUse` on the `Bash` tool -> `hooks/intercept-install.sh`
: Detects install / add subcommands across npm, pnpm, yarn, bun,
  cargo, pip, uv, poetry, brew, apt, apt-get, go, gem.
  Distinguishes pinned from unpinned. Soft-reminds the agent
  (non-blocking) when an unpinned install is about to run.

`PreToolUse` on `mcp__plugin_oracle_firecrawl__.*` ->
`hooks/rate-limit-guard.sh`
: Tiered budget-aware gating on every firecrawl MCP call. Reads
  the cost-table to estimate the call's credit consumption,
  reads the persisted usage state, and decides one of:
  silent allow (< 80% of monthly used), soft `additionalContext`
  reminder (80-95%), `permissionDecision: ask` (95-100%, or
  single-call >= 15% of monthly, or rolling-hour over 5000
  credits), hard `deny` (over 100%). Zero-cost status polls
  always pass.

`PostToolUse` on `mcp__plugin_oracle_firecrawl__.*` ->
`hooks/rate-limit-track.sh`
: Increments monthly / weekly / daily / rolling-hour counters by
  the estimated cost of the just-executed call. Caps the
  recent-calls audit list at 50.

## Installation

```
/plugin install oracle@skunkworks
```

Hooks load at session start; restart Claude Code after installing.

## Configuration

### Required

Set `FIRECRAWL_API_KEY` in your environment for the bundled MCP
server. Get a key at <https://firecrawl.dev>. Free-tier keys work
(10 scrapes/min, 5 searches/min, 1 crawl/min); Pro-tier keys lift
the quotas substantially. Add to your shell profile:

```sh
export FIRECRAWL_API_KEY=fc-...
```

If `FIRECRAWL_API_KEY` is unset, the firecrawl MCP tools fail at
invocation. The cascade degrades to WebSearch + WebFetch
automatically.

### Optional

Firecrawl-MCP also reads:

- `FIRECRAWL_API_URL` for self-hosted firecrawl instances.
- `FIRECRAWL_RETRY_MAX_ATTEMPTS`, `FIRECRAWL_RETRY_INITIAL_DELAY`,
  `FIRECRAWL_RETRY_MAX_DELAY`, `FIRECRAWL_RETRY_BACKOFF_FACTOR`
  for retry tuning.
- `FIRECRAWL_CREDIT_WARNING_THRESHOLD`,
  `FIRECRAWL_CREDIT_CRITICAL_THRESHOLD` for credit alerts.

## On-disk artefacts

The plugin writes only under `.oracle/` in your current project:

- `.oracle/research/<topic-slug>/{canon,github,issues,forum}.md`
  -- per-silo scratch findings as subagents run.
- `.oracle/findings/<topic-slug>.md` -- the synthesized final
  report from `/oracle:research`. Idempotent overwrite per slug.
- `.oracle/findings/vet-<library-slug>.md` -- the synthesized
  report from `/oracle:vet`. Idempotent per slug.

Subagents are forbidden from writing anywhere else by their
system prompts. The orchestrator's slash commands write only to
`.oracle/findings/`. To make this durable, add this line to your
project's `.gitignore`:

```
.oracle/
```

If you decide a particular finding is worth keeping, copy it to a
permanent location (e.g. `docs/decisions/`) or pin it to your
CLAUDE.md via an `@-import`.

## First-time setup

Run `/oracle:setup` once after installing the plugin. It
idempotently adds a one-line `@-import` to your `~/.claude/CLAUDE.md`
pointing at the plugin's `docs/SEARCH-WORKFLOWS.md` -- the
canonical reference for the research discipline this plugin
implements. The command is safe to re-run; it appends only if
the line is not already present.

## Allow-list discipline

Every skill's `allowed-tools` and every agent's `tools` field is
explicit and denied-unless-specified. The plugin grants only the
ten active firecrawl MCP tools to the silos that need them; the
four deprecated `firecrawl_browser_*` tools are excluded from
every allow-list intentionally.

## Why this exists

The default LLM failure mode for technical recommendations is to
assert Next.js 15 is current when 16.x has shipped, recommend a
library that does not exist, cite a Reddit thread it has
fabricated, and rank libraries by remembered hype rather than
fit-for-purpose. `oracle` makes grounding the default, and applies
the anti-hype discipline that surfaces the right library even
when it is not the popular one.

## Budget tracking

The rate-limit hooks persist usage state at
`~/.claude/plugins/oracle/usage.json`. The default monthly budget
is 100,000 credits (Standard / Pro plan); override via either:

- Project-scoped: `.oracle/budget.json` -- wins over user-scoped.
- User-scoped: `~/.claude/plugins/oracle/budget.json`.

Override shape (any subset):

```json
{
  "monthly_credits": 100000,
  "thresholds": {
    "soft_warning_pct": 80,
    "ask_threshold_pct": 95,
    "deny_threshold_pct": 100,
    "single_call_hard_gate_pct": 15,
    "rolling_hour_max_credits": 5000
  }
}
```

Use `/oracle:budget show` to view current usage, recent calls,
and projected month-end. Use `/oracle:budget set <key>=<value>`
to override individual thresholds without hand-editing JSON. Use
`/oracle:budget reset` (with typed `RESET-ORACLE-BUDGET`
confirmation) at the start of a new firecrawl billing month or
after a key rotation.

When the rate-limit-guard hook flags a single call as expensive
(>= 15% of monthly budget), the orchestrator should dispatch the
`cost-rethinker` agent to surface 2-4 cheaper alternatives with
credit estimates before approving.

## Tests

A shellcheck-clean test suite ships with the plugin. Run it from
the plugin root:

```sh
bash tests/run-tests.sh
```

It runs three stages: shellcheck on every `.sh` file (with `-x`
source-following), `jq empty` on every `.json` / `.mcp.json`, and
four test files exercising the budget library and the three
shell hooks (intercept-install, rate-limit-guard,
rate-limit-track). Tests use isolated `HOME` and project
directories; they do not touch the user's real config.

Install `shellcheck` first: `brew install shellcheck` (macOS) or
`apt install shellcheck` (Debian).

## Limitations

- The PreToolUse install-interception hook is intentionally
  non-blocking. A blocking hook would make sandboxed and
  air-gapped use impossible.
- The rate-limit-guard hook estimates credits from the cost
  table; firecrawl does not return actual credits consumed in
  the tool_result, so the persisted total is an estimate. For
  accounting purposes, the authoritative source is firecrawl's
  dashboard, not the local usage file.
- `apt-cache madison` and similar Debian-family lookups require
  apt metadata to be present; they fail silently on systems
  without apt.
