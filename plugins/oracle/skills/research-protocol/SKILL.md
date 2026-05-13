---
name: research-protocol
description: This skill should be used whenever an agent is conducting oracle-style research -- surveying libraries, evaluating tools, ranking frameworks, assessing standards conformance, comparing component systems, finding niche-but-mature options, or producing a "what should I use for X" recommendation. Fire liberally. Triggers include "research", "survey", "evaluate", "shortlist", "compare libraries", "find the best", "best library for", "what library / crate / package / framework for", "what's the standard for", "alternatives to", "evaluate X", "vet X", any dispatch from /oracle:research or /oracle:vet, and any agent reading the /oracle:research or /oracle:vet slash-command body. This is reference material -- the protocol an agent follows when running an oracle research workflow. Three intensities (quick / standard / exhaustive), one dispatch discipline, one output contract per intensity.
---

# Oracle Research Protocol

This skill is reference material loaded by agents executing
oracle-style research. It defines the intensity ladder, the
dispatch discipline for the four research subagents, the output
contract per intensity, and the anti-hype ranking discipline that
governs every recommendation.

## The intensity ladder

Three intensities. Pick exactly one before dispatching. State the
chosen intensity at the top of the response.

- **quick** -- for a single concrete question with one obvious
  authoritative answer ("what's the current stable Next.js"; "any
  datagrid for Next.js after a Next.js discussion"). Spawn one
  subagent (`canon-reader`), single pass. Render as an inline,
  multi-ranked library list.
- **standard** (default) -- for comparison or shortlist questions
  with two-to-five candidates in the air. Spawn two subagents
  (`canon-reader` + `github-archivist`) in parallel. Render as a
  half-to-one-page report with cross-silo cross-validation.
- **exhaustive** -- for architectural decisions, spec-conformance
  questions, or anything that names a standard. Spawn all four
  subagents in parallel. Render as a multi-page decision matrix
  with anti-hype callouts and named risks.

If the calling slash command did not specify `--intensity`, infer
from the question shape using the table above. Do not silently
escalate during execution; finish at the chosen intensity and
recommend an explicit re-run at the next intensity if needed.

## Dispatch discipline

The four research subagents:

- **`canon-reader`** -- authoritative source material. RFC / W3C /
  IETF specs, official docs, official changelogs, maintainer's own
  writeups, package-registry pages. Spec-conformance verdicts come
  from this silo.
- **`github-archivist`** -- repository archaeology. README, license,
  releases, contributor signal, downstream-usage signal. Repository-
  health verdicts.
- **`issue-investigator`** -- the target repo's issues and PR tracker.
  Time-to-first-response, maintainer-voice quotes,
  stable-and-done-vs-abandoned classification. Maintenance verdicts.
- **`forum-anthropologist`** -- Reddit, Hacker News, Stack Overflow,
  Lobsters, dev.to, Discord mirrors. Lived experience, switching
  narratives, gotchas, user-named alternatives. Sentiment verdicts.

**Parallel dispatch is mandatory** when intensity is `standard` or
`exhaustive`. Follow this rule literally:

- `standard` intensity: the FIRST assistant turn after parsing
  arguments MUST contain exactly **two** `Agent` tool-call blocks
  in a single message -- one for `canon-reader`, one for
  `github-archivist`. Not one, not three, not chained.
- `exhaustive` intensity: the FIRST assistant turn after parsing
  arguments MUST contain exactly **four** `Agent` tool-call
  blocks in a single message -- `canon-reader`,
  `github-archivist`, `issue-investigator`,
  `forum-anthropologist`.
- Chained dispatch (`Agent` followed by waiting for the result,
  then another `Agent`) is a regression and must be corrected
  mid-flight if observed: kill the partial run and re-dispatch
  the full batch in one message.

This is the single most under-applied Opus 4.7 idiom in research
workflows. The default behaviour is to under-spawn; the rule above
exists because the default is wrong. Audit your first assistant
turn: it should contain N parallel tool-call blocks where N
matches the intensity (1 for quick, 2 for standard, 4 for
exhaustive).

## Output contracts

### quick

```
Topic: <inferred topic, with conversation-context note if the
        topic was abbreviated relative to prior conversation>
Intensity: quick

Popular default
1. <name> -- <one-line>. <url>
2. <name> -- <one-line>. <url>

Niche but mature  (MANDATORY: at least one entry; if none
                  genuinely applies, state "no niche-but-mature
                  option surfaced for this topic" explicitly)
1. <name> -- <one-line>. <url>

Spec-conforming
1. <name> -- <one-line>. <url>

Recently maintained
1. <name> -- <one-line>. <url>

Pick: <one-line verdict naming the grouping and the why>

Memory hook: <one-sentence plain-English summary the user can
absorb in a single scan: what the pick is, why, and what to
watch out for>.
```

Keep it under twenty lines total. The verdict and the memory
hook are mandatory.

### standard

```
Topic: <inferred>
Intensity: standard

Standards / specs in play
- <spec name>, <URL>, one-line on what conformance looks like.

Candidate landscape
- <name>. <one-line>. Canon signal: <verdict>. Archivist signal:
  <verdict>. Verdict: <strong / moderate / weak>.
(repeat per candidate, three to six total)

Anti-hype check
- One paragraph naming the niche-but-mature option(s) explicitly
  and explaining why they belong on the shortlist.

Pick
- <library>. <one-paragraph justification grounded in canon and
  archivist findings>.

Memory hook
- <one short paragraph, plain English, optimised for absorption.
  Names the pick, the one signal that settled it, the one risk
  to remember. The full report is above; this is what gets
  remembered.>

Sources
- <every URL cited, deduplicated>
```

### exhaustive

```
Topic: <inferred>
Intensity: exhaustive

Standards / specs / canonical sources
- <every standard and authoritative document the canon-reader
  identified, with URL>.

Decision matrix
| candidate | canon | archivist | issues | forum | verdict |
|-----------|-------|-----------|--------|-------|---------|
(one row per candidate; cells are one-line evidence note + + / o / -
grade; verdict column is synthesis + grade)

Per-candidate detail
- <candidate>: 3-6 sentences synthesising the four silos with
  citations. Name the strongest and weakest signal explicitly.
(repeat per candidate)

Anti-hype callout
- One paragraph naming any niche-but-mature option that the
  decision matrix surfaced. If the popular default is also the
  correct answer, say so explicitly.

Recommendation
- <library>. Full justification grounded in the matrix. Include
  a one-line "best for" framing.

Risks and watch-outs
- 3-5 risks the user should know before committing.

Memory hook
- <one short paragraph, plain English, optimised for absorption.
  Names the recommendation, the one decisive signal across the
  four silos, the one alternative the user should remember, and
  the top risk. The decision matrix is above; this is what gets
  remembered.>

Sources
- <every URL the four subagents cited, deduplicated, grouped by
  silo>.
```

## The anti-hype ranking discipline

The `anti-hype-ranking` skill is binding on every recommendation
this protocol produces. Headline rules:

- GitHub stars are weak signal. A library with 800 stars and a
  thoughtful maintainer can outrank one with 80,000 stars and a
  Discord-driven hype cycle.
- Recent commit cadence is weak signal. Two commits in 18 months
  is not abandonment if issues are getting timely responses.
- **Strong** signals: spec conformance, API stability statements,
  maintainer responsiveness on the tracker, named downstream
  usage by serious projects, quality (not volume) of forum
  reviews.
- **The niche-surfacing rule**: every `standard` and `exhaustive`
  output names at least one option outside the popularity default.
  If none genuinely applies, say so explicitly rather than
  fabricate one. The fmodel-rust / problem+json class of library
  must not be buried.

## Citation discipline

- Every claim traces back to a subagent finding.
- Every subagent finding traces back to a URL or a CLI output.
- Every URL was fetched in the same session that cites it.
- The `Sources` section at the end of every output is mandatory
  and deduplicated.

## Tooling discipline

Subagents prefer the plugin-scoped firecrawl MCP tools for web
retrieval because they return cited content with the URL preserved:

- `mcp__plugin_oracle_firecrawl__firecrawl_search` -- discovery
  with content extraction (set `scrapeOptions`).
- `mcp__plugin_oracle_firecrawl__firecrawl_scrape` -- single known
  URL.
- `mcp__plugin_oracle_firecrawl__firecrawl_map` -- URL discovery
  on a known site.
- `mcp__plugin_oracle_firecrawl__firecrawl_extract` -- structured
  extraction.
- `mcp__plugin_oracle_firecrawl__firecrawl_crawl` -- multi-page
  asynchronous crawl, paired with
  `firecrawl_check_crawl_status`.
- `mcp__plugin_oracle_firecrawl__firecrawl_batch_scrape` -- many
  known URLs at once, paired with `firecrawl_check_batch_status`.
- `mcp__plugin_oracle_firecrawl__firecrawl_agent` -- autonomous
  agent for open-ended research passes, paired with
  `firecrawl_agent_status`.

Fall back to the `firecrawl-search` / `firecrawl-scrape` /
`firecrawl-map` skills via the `Skill` tool if
`FIRECRAWL_API_KEY` is unset, then to `WebSearch` + `WebFetch`.

The `gh` CLI is preferred for structured GitHub repo / issues /
PR queries when present (detect with `command -v gh`).

## Filesystem convention

Subagents and orchestrators write to a single project-local
directory tree under `.oracle/`. Nothing else.

- `.oracle/research/<topic-slug>/canon.md` -- canon-reader silo
  output.
- `.oracle/research/<topic-slug>/github.md` -- github-archivist
  silo output.
- `.oracle/research/<topic-slug>/issues.md` -- issue-investigator
  silo output.
- `.oracle/research/<topic-slug>/forum.md` -- forum-anthropologist
  silo output.
- `.oracle/findings/<topic-slug>.md` -- the synthesized final
  report, written by the orchestrator (the slash command body).
  Idempotent overwrite per slug.
- `.oracle/findings/vet-<library-slug>.md` -- /oracle:vet output.

`<topic-slug>` is a kebab-case ASCII slug derived from the topic,
max 80 characters. Generate the slug from the topic text and
state it at the top of the response so the user can grep for it.

Recommend that the user add `.oracle/` to their project's
`.gitignore`, since research artefacts are session-specific
scratch unless the user explicitly elects to commit them.

## Context grounding

Short topics that omit a framework / language / runtime marker
must be grounded from prior conversation context before dispatch.
"datagrid" after a Next.js discussion means "Next.js-compatible
datagrid options". State the inferred grounding at the top of the
response so the user can correct it.

If grounding is impossible (no prior context, ambiguous topic),
ask one consolidated clarifying question and stop. Do not invent
context.

## Stop conditions

- Subagent returns with explicit "no results found" -> include
  that in the synthesis honestly. Do not paper over a gap.
- `FIRECRAWL_API_KEY` is unset and the firecrawl-* skills are
  also unavailable -> degrade to WebSearch + WebFetch and note
  the degradation in the output.
- Rate limits or paywalls -> stop, name the obstruction in the
  output, recommend the user retry with credentials configured.
