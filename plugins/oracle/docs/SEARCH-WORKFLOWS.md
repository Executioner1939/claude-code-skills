# User Preferred Search and Research Workflows

This document is the canonical reference for how the user prefers
research and verification to be conducted. The oracle plugin imports
it into the user's root CLAUDE.md so that every Claude Code session
inherits the discipline. The plugin's own slash commands and
subagents implement the workflow; this document explains the
*preferences* that govern it.

## First principles

The user is a senior backend / systems / DevOps engineer with 12
years of shipping experience. The collaboration tax is paid for
*precision*, not for hedging. Research should be:

- **Grounded.** Every externally-verifiable claim cites a URL or a
  CLI lookup that was actually executed in the same response.
- **Parallel.** Independent silos run concurrently. Never serial
  when the calls do not depend on each other's results.
- **Anti-hype.** GitHub stars and recent commit cadence are weak
  signals. Spec conformance, API stability, maintainer
  responsiveness, and named downstream usage by serious projects
  are strong signals. A library with 800 stars and a thoughtful
  maintainer can outrank one with 80,000 stars and a Discord-
  driven hype cycle.
- **Niche-aware.** Every comparison surfaces at least one option
  outside the popularity default. The fmodel-rust /
  problem+json class of library must not be buried. Surface it
  by name with a one-line justification.
- **Spec-first.** When a standard exists (RFC 7807 problem+json,
  JSON Schema, OAuth, OpenAPI, W3C-DTCG design tokens, Brad
  Frost atomic design, hexagonal architecture, CQRS / event
  sourcing), the spec is the rubric, not the popular tutorial.
- **Honest about gaps.** When verification fails, the verdict is
  `unverified`, not "probably true". Papering over a gap is the
  primary failure mode this discipline exists to prevent.

## Cascade discipline

For any externally-verifiable claim, apply the three-tier cascade
in order. Stop as soon as a tier yields an authoritative answer.

1. **Package-manager CLI** -- `npm view`, `cargo search`,
   `pip index versions`, `uv pip index versions`, `gem info -r`,
   `go list -m -versions`, `brew info --json=v2`,
   `apt-cache madison`. Fastest, most authoritative for versions
   and package existence.
2. **Plugin-scoped firecrawl MCP** (when `FIRECRAWL_API_KEY` is
   set) -- the 10 active firecrawl tools return rendered-page
   markdown with the URL preserved, which is what makes citation
   reproducible.
3. **WebSearch + WebFetch** -- fallback when firecrawl is
   unconfigured or unavailable.

## Research intensity ladder

Three intensities. Pick exactly one. State it at the top of every
research response.

- **quick** -- one subagent (`canon-reader`), single pass.
  Inline multi-ranked library list. Under twenty lines total. Use
  when a single concrete question has one obvious authoritative
  answer.
- **standard** (default) -- two subagents in parallel
  (`canon-reader` + `github-archivist`). Half-to-one-page report
  with cross-silo cross-validation. Use for shortlist questions
  with two-to-five candidates in the air.
- **exhaustive** -- all four subagents in parallel. Multi-page
  decision matrix with anti-hype callouts and named risks. Use
  for architectural decisions, spec-conformance questions, or
  anything that names a standard.

Do not silently escalate during execution. Finish at the chosen
intensity. If a deeper pass is needed, recommend it explicitly at
the end.

## Output discipline

- **Memory hooks first.** Every research output ends with a
  one-paragraph plain-English summary the user can absorb in a
  single scan. The full structured findings are above; the memory
  hook is what gets remembered.
- **Cite every claim.** URL or CLI output, inline.
- **Quote forum opinions verbatim.** Never paraphrase a quote.
- **Score discretely.** Verdict tiers (strong / healthy / mixed
  / concerning / failed; faithful / partial / divergent /
  unrelated; strong-yes / yes / conditional / no / strong-no)
  use the listed values only. No intermediate grades.

## Behaviour gating preferences

- **Pin versions on install.** The PreToolUse hook reminds the
  agent to verify the latest version before any unpinned install.
  Pinned commands pass through silently.
- **Verify before asserting.** The verification-protocol skill
  fires liberally. False positives (extra cascade runs) are
  acceptable; false negatives (asserted but unverified claims)
  are the failure mode.
- **Surface alternatives.** Every recommendation names at least
  one alternative. A recommendation with no alternatives is doing
  half the work.

## What the plugin does for you

- Three slash commands: `/oracle:verify`, `/oracle:research`,
  `/oracle:vet`.
- Four research subagents: `canon-reader`, `github-archivist`,
  `issue-investigator`, `forum-anthropologist`.
- Three auto-trigger knowledge skills: `verification-protocol`,
  `research-protocol`, `anti-hype-ranking`. These fire whenever
  the trigger conditions match, loading the discipline
  automatically.
- One SessionStart hook injecting the verification protocol into
  every session.
- One PreToolUse hook intercepting unpinned installs across 13
  package managers.
- Bundled `firecrawl-mcp@3.2.1` MCP server giving every silo
  citation-backed retrieval.

## Shipped (recap of capabilities the workflow relies on)

- Rate-limit-aware gating on firecrawl MCP calls (v0.3.0).
  Tracks hourly / weekly / monthly quota at
  `~/.claude/plugins/oracle/usage.json`. Tiered decisions: silent
  allow under 80% used, soft remind 80-95%, ask 95-100% or
  single-call >= 15% of monthly or rolling-hour over 5000
  credits, deny over 100%. Dispatches the `cost-rethinker` agent
  for multi-angle cheaper alternatives when a single call gates.
- Cost-table at `scripts/cost-table.json` versioned with the
  plugin; project / user overrides at `.oracle/budget.json` or
  `~/.claude/plugins/oracle/budget.json`.
- `/oracle:budget` slash command for show / reset / set.

## Roadmap (visible to the user)

- **v0.4.0** -- corpus-wide discipline guards. PostToolUse
  parallel-tool-discipline hook + auto-trigger skill addressing
  the 0% parallel-batch rate observed in the user's session
  corpus. PreToolUse `safe-edit` hook addressing the
  Write-before-Read + stale-Edit class. Path / URL pre-flight
  auto-trigger skill addressing speculative-fetch errors.
- **v0.5.0** -- streaming-as-available subagent findings.
  Subagents post interim summaries to a shared artefact that the
  orchestrator surfaces in real time, so absorption can begin
  before full synthesis.
