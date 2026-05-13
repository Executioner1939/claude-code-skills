---
name: verify
description: This skill should be used when the user explicitly invokes `/oracle:verify <claim>` to verify an externally-grounded claim on demand -- a version, library, citation, article link, statistic, or forum reference. Triggers on the literal slash-command form. Runs the oracle three-tier verification cascade (package-manager CLI -> firecrawl-search -> WebSearch) against the supplied claim and reports the findings with source citations.
argument-hint: <claim or topic to verify>
allowed-tools: Bash, WebSearch, WebFetch, Skill, Read, mcp__plugin_oracle_firecrawl__firecrawl_search, mcp__plugin_oracle_firecrawl__firecrawl_scrape, mcp__plugin_oracle_firecrawl__firecrawl_map
---

# /oracle:verify

Run the oracle verification cascade against the claim supplied as
`$ARGUMENTS`. Report the findings with inline source citations.

## Preload

Before acting, ensure the `verification-protocol` auto-trigger
knowledge skill is loaded -- its body is the binding reference
for the three-tier cascade and the citation discipline applied
here. The skill auto-triggers on any oracle verification flow;
do not skip its load. The `anti-hype-ranking` skill is binding
when the claim is a library recommendation.

## Inputs

`$ARGUMENTS` is a free-form claim, question, or topic. Examples:

- `next.js latest stable version`
- `is fmodel-rust 0.9 the current release on crates.io`
- `does the tokio crate have a Builder::worker_threads method`
- `the Reddit thread about async-fn-in-trait stabilisation`
- `the p99 latency benchmark in the foo-bar 2024 paper`

If `$ARGUMENTS` is empty, ask the user a single consolidated question:
"What claim should I verify?" Stop and wait. Do not proceed without
content.

## Classification

Read the claim and classify it into one of the cascade entry points:

1. **Package / library / framework version or existence** -> enter at
   Tier 1 (package-manager CLI). Identify the ecosystem from the claim
   itself or from the surrounding project (read `package.json`,
   `Cargo.toml`, `pyproject.toml`, `go.mod`, `Gemfile` if needed to
   pick the right CLI).
2. **Article, blog post, paper, RFC, spec, documentation page** ->
   enter at Tier 2 (firecrawl-search) if a `firecrawl-search` skill is
   available; otherwise Tier 3 (WebSearch + WebFetch).
3. **Statistic or benchmark** -> enter at Tier 2; the source page is
   the authority.
4. **Reddit / Hacker News / Stack Overflow / GitHub issue reference**
   -> enter at Tier 2. Forum URLs almost always require fetching the
   page; never quote forum content without having fetched it.
5. **Author attribution or quote** -> enter at Tier 2.

If classification is ambiguous, start at Tier 1 (cheapest) and escalate.

## Execution

Run the chosen tier. Stop as soon as a tier gives an authoritative
answer. Honour the order; do not skip Tier 1 for a version claim just
because Tier 2 feels more thorough.

### Tier 1 commands

| Ecosystem | Lookup |
|---|---|
| npm / pnpm / yarn / bun | `npm view <pkg> version` |
| cargo | `cargo search <crate> --limit 1` |
| pip | `pip index versions <pkg>` |
| uv | `uv pip index versions <pkg>` |
| poetry | `pip index versions <pkg>` |
| go | `go list -m -versions <module>` |
| gem | `gem info -r <gem>` |
| homebrew | `brew info --json=v2 <formula>` |
| apt / apt-get | `apt-cache madison <pkg>` |

For existence-and-API-shape claims (does crate X have method Y), the
Tier 1 lookup confirms the crate exists and gives the current version;
fall through to Tier 2 to fetch the API docs page for the method.

### Tier 2

Invoke the firecrawl MCP tools directly. The oracle plugin bundles
firecrawl-mcp@3.2.1 as a plugin-scoped MCP server (config in
`.mcp.json`), so the following tools are first-class once
`FIRECRAWL_API_KEY` is set in the environment:

- `mcp__plugin_oracle_firecrawl__firecrawl_search` -- web search that
  returns URLs with optional scraped page content. Use with
  `scrapeOptions` set so the response includes content, not just
  result-list URLs. This is the canonical Tier 2 entry point for
  citation-backed retrieval.
- `mcp__plugin_oracle_firecrawl__firecrawl_scrape` -- single URL,
  returns clean markdown. Use when a specific page URL is already
  known.
- `mcp__plugin_oracle_firecrawl__firecrawl_map` -- discover URLs on
  a site. Use when looking for a specific page on a large docs site.
- `mcp__plugin_oracle_firecrawl__firecrawl_extract` -- LLM-driven
  structured extraction. Use for "find X across these pages" tasks.

Prefer the firecrawl MCP tools over the firecrawl-search skill;
the MCP tools return full page content with the URL preserved,
which makes citation trivial. If `FIRECRAWL_API_KEY` is unset, the
MCP tools will fail; the fallback in that case is the
firecrawl-search skill or Tier 3.

### Tier 3

Use `WebSearch` to discover candidate URLs. Use `WebFetch` to read the
most authoritative one. Authority order: official docs > maintainer
blog / changelog > release notes on the package registry > third-party
write-up > random forum post.

## Output

Report in this shape, every time:

```
Claim: <verbatim from $ARGUMENTS>
Classification: <one of: version, library-existence, article, statistic, forum, attribution, mixed>
Tier reached: <1 | 2 | 3 | failed>

Findings:
- <one line per fact, with the source>

Verdict: <verified | partially verified | unverified | refuted>
```

When the verdict is `unverified` or `refuted`, say so explicitly and
state what the cascade actually returned. Do not paper over a failure.

## Examples

### Example 1 -- version claim

`$ARGUMENTS = "what is the current next.js version"`

Run `npm view next version`. Output: `16.2.6`.

```
Claim: what is the current next.js version
Classification: version
Tier reached: 1

Findings:
- npm view next version -> 16.2.6

Verdict: verified
```

### Example 2 -- article reference

`$ARGUMENTS = "the Anthropic Opus 4.7 best-practices article"`

Invoke firecrawl-search. Fetch the canonical URL
(`https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-4-best-practices`).
Report a one-line summary and cite the URL.

### Example 3 -- forum reference where the URL turns out not to exist

```
Claim: <forum URL>
Classification: forum
Tier reached: 3

Findings:
- WebFetch <url> -> 404 not found
- WebSearch "<query terms>" returned no matching thread

Verdict: unverified. The referenced thread could not be located.
```

## Rules

- Never fabricate. If the cascade fails to verify, the verdict is
  `unverified` -- not "probably true".
- Always cite. Tier 1: paste the CLI output line. Tier 2 / 3: cite the
  URL.
- Stop at the first authoritative tier. Do not chase every tier when
  Tier 1 already settled the claim.
- Pass through a user-pinned version without re-verifying it; the pin
  is the verification decision.
