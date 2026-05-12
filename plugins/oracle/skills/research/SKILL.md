---
name: research
description: This skill should be used when the user explicitly invokes `/oracle:research <topic>` (with optional `--intensity=quick|standard|exhaustive`). Thin entry point that triggers the oracle research workflow. The detailed protocol -- intensity ladder, subagent dispatch discipline, output contracts, anti-hype ranking -- lives in the auto-triggering `research-protocol` skill that loads when this command fires. Use for ecosystem surveys, "what library should I use for X" decisions, standards-conformance questions (problem+json, RFC 7807, JSON Schema, OAuth, W3C-DTCG, atomic design), and comparison questions across component systems, frameworks, runtimes, build tools, and data libraries.
argument-hint: <topic> [--intensity=quick|standard|exhaustive]
allowed-tools: Bash, WebSearch, WebFetch, Skill, Agent, Read, Grep, Glob, Write, Edit, mcp__plugin_oracle_firecrawl__firecrawl_search, mcp__plugin_oracle_firecrawl__firecrawl_scrape, mcp__plugin_oracle_firecrawl__firecrawl_map, mcp__plugin_oracle_firecrawl__firecrawl_extract, mcp__plugin_oracle_firecrawl__firecrawl_crawl, mcp__plugin_oracle_firecrawl__firecrawl_check_crawl_status, mcp__plugin_oracle_firecrawl__firecrawl_batch_scrape, mcp__plugin_oracle_firecrawl__firecrawl_check_batch_status, mcp__plugin_oracle_firecrawl__firecrawl_agent, mcp__plugin_oracle_firecrawl__firecrawl_agent_status
---

# /oracle:research

Run the oracle research workflow against `$ARGUMENTS`. The detailed
protocol -- intensity ladder, subagent dispatch, output contracts,
anti-hype discipline, citation rules -- is in the
`research-protocol` skill, which auto-loads when this command
fires. Read it before acting; it is the binding reference.

## Preload

Three oracle auto-trigger skills are binding on every run and
must be loaded before dispatch:

- `research-protocol` -- the intensity ladder, dispatch
  discipline, per-intensity output contracts. The body of this
  command is a thin dispatcher; the contracts live there.
- `anti-hype-ranking` -- ranking discipline; binding on every
  recommendation. Stars are weak signal; spec conformance is
  strong.
- `verification-protocol` -- citation discipline; binding on
  every URL or CLI fact cited in the final synthesis.

All three auto-trigger from their descriptions; do not skip the
load. Skill bodies are the contract, not the slash-command body.

## Parse arguments

`$ARGUMENTS` is `<topic> [--intensity=quick|standard|exhaustive]`.

- Empty arguments -> ask one consolidated question ("What topic
  should I research, and at what intensity?") and stop.
- No `--intensity` -> infer from question shape per the intensity
  ladder in `research-protocol`. State the chosen intensity at
  the top of the response.
- Short topic with no framework / runtime / language marker ->
  ground from prior conversation context before dispatching.
  State the inferred grounding so the user can correct it.

## Dispatch

Apply the dispatch discipline from `research-protocol`:

- `quick` -> spawn one subagent (`canon-reader`).
- `standard` -> spawn two subagents in parallel (`canon-reader`
  + `github-archivist`). Single message, two `Agent` tool-call
  blocks.
- `exhaustive` -> spawn all four subagents in parallel
  (`canon-reader`, `github-archivist`, `issue-investigator`,
  `forum-anthropologist`). Single message, four `Agent`
  tool-call blocks.

## Render

Follow the per-intensity output contract from `research-protocol`
exactly. The contracts are non-negotiable; do not paraphrase or
reshape them.

## Persist the final report

Write the synthesized final report to
`.oracle/findings/<topic-slug>.md` in the current project. The
slug is the same one passed to subagents (kebab-case, ASCII,
max 80 chars). Idempotent overwrite per slug -- running the same
research command twice replaces the prior report at the same
path rather than appending.

Ensure the `.oracle/findings/` directory exists (`mkdir -p`)
before writing.

After writing, print the absolute path of the persisted report
so the user can grep it, re-read it, or pin it to CLAUDE.md
later.

## Stop at the chosen intensity

Do not silently escalate. If during a `standard` run it becomes
obvious that an exhaustive pass is needed, finish the standard
report and explicitly recommend
`/oracle:research <topic> --intensity=exhaustive` at the end.
