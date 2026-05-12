---
name: vet
description: 'This skill should be used when the user explicitly invokes `/oracle:vet <library-or-tool>` to evaluate one named library, crate, package, framework, or tool in depth before committing to depend on it. Triggers on the literal slash-command form. Runs an exhaustive single-target vetting across spec conformance, repository health, issue-tracker health, forum sentiment, peer alternatives, license, and maintainer record. Returns a structured "should I depend on this" verdict with anti-hype ranking and named alternatives.'
argument-hint: <library or tool name, optionally with ecosystem prefix (e.g. npm:lodash, crates:tokio, pypi:requests)>
allowed-tools: Bash, WebSearch, WebFetch, Skill, Agent, Read, Grep, Glob, Write, Edit, mcp__plugin_oracle_firecrawl__firecrawl_search, mcp__plugin_oracle_firecrawl__firecrawl_scrape, mcp__plugin_oracle_firecrawl__firecrawl_map, mcp__plugin_oracle_firecrawl__firecrawl_extract, mcp__plugin_oracle_firecrawl__firecrawl_crawl, mcp__plugin_oracle_firecrawl__firecrawl_check_crawl_status, mcp__plugin_oracle_firecrawl__firecrawl_batch_scrape, mcp__plugin_oracle_firecrawl__firecrawl_check_batch_status, mcp__plugin_oracle_firecrawl__firecrawl_agent, mcp__plugin_oracle_firecrawl__firecrawl_agent_status
---

# /oracle:vet

Run the oracle vetting protocol against `$ARGUMENTS`. The intent is
to answer one question end-to-end: **should the user depend on this
library or tool, and what are the alternatives?**

## Preload

Three oracle auto-trigger skills are binding on every vet run
and must be loaded before dispatch:

- `research-protocol` -- the parallel-dispatch discipline,
  citation rules, and tooling discipline are inherited from here.
- `anti-hype-ranking` -- the discipline that distinguishes a
  vet from a popularity-poll. Binding on the verdict.
- `verification-protocol` -- citation discipline; binding on
  every URL and CLI fact in the final report.

All three auto-trigger from their descriptions; do not skip the
load.

## Parse `$ARGUMENTS`

`$ARGUMENTS` is `<library-or-tool>`, optionally prefixed with an
ecosystem (`npm:`, `pnpm:`, `crates:`, `pypi:`, `go:`, `gem:`,
`brew:`, `apt:`). If no prefix is given, infer the ecosystem from
the surrounding project context (presence of `package.json`,
`Cargo.toml`, `pyproject.toml`, `go.mod`, `Gemfile`) or from prior
conversation. State the inferred ecosystem at the top of the
response.

If `$ARGUMENTS` is empty, ask the user a single consolidated
question: "Which library should I vet, and in which ecosystem if
ambiguous?" Stop and wait.

## Run the cascade

This is always an **exhaustive-intensity** run scoped to one target.
Dispatch the four subagents in parallel via the Agent tool, in a
single message with four tool-call blocks. Do not chain them.

The subagents and their assignments:

- **`canon-reader`** -- official docs, the package registry page,
  the maintainer's own writeups, any standard or spec the library
  claims to implement. Returns: spec-conformance verdict,
  documentation quality, design-rationale signal.
- **`github-archivist`** -- the repository: README, license,
  CONTRIBUTING, releases, contributor count, downstream-usage
  signal (who depends on it). Returns: repository health verdict,
  named downstream users.
- **`issue-investigator`** -- the issue tracker and PR tracker.
  Returns: maintainer-responsiveness verdict, time-to-first-
  response, stable-and-done vs abandoned vs crisis classification.
- **`forum-anthropologist`** -- Reddit, Hacker News, Stack
  Overflow, Lobsters, Discord mirrors. Returns: forum-sentiment
  verdict, quoted reviews with URLs, named alternatives that
  forum commenters point to.

## Synthesise

When all four return, produce the vetting report.

```
Library: <name>
Ecosystem: <inferred or stated>
Latest version: <from canon-reader>

Verdict: <strong-yes | yes | conditional | no | strong-no>
One-line: <ten-word summary>

Spec / standard conformance
- <which standard, if any, the library claims to implement>
- <how faithful the implementation is, per canon-reader>

Repository health (github-archivist)
- <license, contributor count, release cadence>
- <named downstream users, if any>

Maintainer signal (issue-investigator)
- <stable-and-done | actively-maintained | slowing | abandoned | crisis>
- <evidence: time-to-first-response, oldest open issue age, etc.>

Forum sentiment (forum-anthropologist)
- <one paragraph synthesising honest opinions; quote at least one
  representative comment with URL>
- <named alternatives forum commenters point to>

Anti-hype check
- <one paragraph: is this the popular default? are there niche
  alternatives worth knowing? does the anti-hype-ranking skill's
  discipline change the verdict?>

Alternatives
- <2-4 named alternatives>, each with one-line on when to prefer
  it over the vetted library.

Risks and watch-outs
- 3-5 bullet items the user must know before depending on this.

Sources
- <every URL the four subagents cited, grouped by silo>
```

## Rules of engagement

- **Parallel dispatch is mandatory** for the four subagents.
  Single message, four Agent tool-call blocks.
- **Verdict tier** must be one of the five listed values. Do not
  invent intermediate grades.
- **Quote a real forum comment** in the forum-sentiment section
  with a URL. A vetting report with no quoted lived-experience is
  incomplete.
- **Apply the anti-hype-ranking skill.** Star count and recent
  commit cadence are weak signals. If the verdict differs from
  what the surface metrics suggest, say so explicitly.
- **Always name alternatives.** A vetting that recommends a
  library without naming what it competes against is doing half
  the work.
- **License risk.** If the library uses a non-permissive license
  (AGPL, SSPL, commercial source-available, BUSL with conditions),
  surface that risk in the watch-outs section.

## Persist the vetting report

Write the synthesized vetting report to
`.oracle/findings/vet-<library-slug>.md` in the current project.
Idempotent overwrite per slug -- running the same vet twice
replaces the prior report at the same path rather than
appending.

Ensure the `.oracle/findings/` directory exists (`mkdir -p`)
before writing.

After writing, print the absolute path of the persisted report
so the user can grep it, re-read it, or pin it to CLAUDE.md
later.

## When to escalate to a full /oracle:research run

If the vetting reveals that the library is *not* the right choice
but the user clearly wants something in that category, recommend
`/oracle:research <category> --intensity=standard` at the end.
Vetting answers "should I use this one"; research answers "what
should I use".

## Pairing with the install-interception hook

This skill produces a recommendation; it does not install. If the
verdict is yes and the user proceeds to install, the PreToolUse
hook will fire on the install command. Respect it; verify the
latest version once more via the package-manager CLI before the
install proceeds.
