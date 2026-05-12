---
name: verification-protocol
description: This skill should be used whenever Claude is about to assert, mention, recommend, compare, discuss, consider, or reference anything externally-grounded. False positives are acceptable; false negatives are the failure mode. Fire on any of these surfaces -- versions (current, latest, recent, stable, LTS, "X is at Y"), libraries / crates / packages / modules / frameworks / runtimes mentioned in a recommendation or comparison context ("use X", "X is good for", "alternatives to X", "best library for Y", "should I use X or Y"), citations and attributions ("according to X", "as discussed in", "X said Y", "from this article / blog / paper / RFC / spec / talk / podcast"), statistics and benchmarks (any percentile, throughput, latency, "X is N times faster", measured numbers), Reddit / Hacker News / Stack Overflow / Lobsters / GitHub-issue references, standards ("problem+json", "RFC 7807", "JSON Schema", "OpenAPI", "OAuth", "W3C-DTCG", any IETF / W3C / ISO / ECMA spec name), framework names in a feature-existence context ("Next.js supports", "Astro has", "Chakra v3 exposes"), component-system / design-system / design-token / atomic-design vocabulary, build-system or runtime version claims (Node, Bun, Deno, Cargo, Go, Python, Rust toolchain). Also trigger on hedge phrases that often hide unverified claims ("I believe", "I think", "as I recall", "if I remember correctly", "probably", "should be"). Encodes the three-tier verification cascade (package-manager CLI -> firecrawl-search -> WebSearch) that the oracle plugin enforces.
---

# Verification Protocol

Run the verification cascade before stating any externally-verifiable
claim. The cascade is the default; skipping it is a regression.

## What requires verification

Treat every one of these as a claim that must be grounded before it
leaves the response:

- Package, library, runtime, or framework versions.
- Library / crate / package / module existence and API shape.
- Citations to articles, blog posts, papers, RFCs, specs, documentation
  pages.
- Statistics, benchmarks, or measured numbers.
- References to Reddit threads, Hacker News posts, Stack Overflow
  answers, GitHub issues, any other forum content.
- Author attributions ("X said Y", "this is from Z").

When in doubt, verify. A verified claim is cheap; an unverified one is
a regression the user has to catch.

## The cascade

Run the tiers in order. Stop as soon as one tier gives an authoritative
answer. Do not skip a cheaper tier just because the next one feels more
familiar.

### Tier 1 -- Package-manager CLI

Fastest and most authoritative for version and existence claims. The
canonical lookups, by ecosystem:

| Ecosystem | Lookup |
|---|---|
| npm / pnpm / yarn / bun | `npm view <pkg> version` |
| cargo | `cargo search <crate> --limit 1` |
| pip | `pip index versions <pkg>` |
| uv | `uv pip index versions <pkg>` |
| poetry | `pip index versions <pkg>` (poetry uses PyPI) |
| go modules | `go list -m -versions <module>` |
| gem | `gem info -r <gem>` |
| homebrew | `brew info --json=v2 <formula>` |
| apt / apt-get | `apt-cache madison <pkg>` |

Run the CLI lookup in the same response that makes the claim. Cite the
output.

### Tier 2 -- firecrawl-search skill

Use the `firecrawl-search` skill (or the `/firecrawl:search` workflow)
when:

- The claim is not a package version (article, blog post, Reddit thread,
  Stack Overflow answer, changelog, release notes, benchmark, quote).
- The package-manager CLI for the ecosystem is unavailable in the
  current environment.
- The package CLI returns ambiguous results and a documentation page
  would disambiguate.

Prefer `firecrawl-search` over `WebFetch` + `WebSearch` when it is
available: firecrawl returns full page markdown rather than search-result
summaries, so the verification is grounded in the source rather than
in a snippet.

### Tier 3 -- WebSearch / WebFetch

Fallback when firecrawl is not installed or returns nothing usable. Use
`WebSearch` to discover candidate URLs, then `WebFetch` to read the
most authoritative one (official docs > maintainer blog > third-party
write-up > random forum post).

## Rules of engagement

- Never assert a version without having run a CLI lookup in the same
  response, or having fetched a changelog / release page.
- Never cite a URL without having fetched it. A URL the model has not
  read is a hallucination risk and should be treated as one.
- When verification fails (no network, package not found, firecrawl
  unavailable), state the failure explicitly: "I could not verify X via
  <tier>; the claim is unverified." Do not proceed as if verified.
- When a version is pinned by the user (for example,
  `cargo add tokio@1.40.0`), the pin itself is the verification
  decision. Pass it through; do not re-verify uninvited.
- Cite the verification source inline. For CLI lookups, paste the
  relevant output line. For fetched pages, cite the URL.

## What this looks like in practice

A correct interaction, before claiming "Next.js 15 is current":

1. `npm view next version` -> `16.2.6`.
2. State the claim grounded in that output: "Latest Next.js is 16.2.6
   (verified via `npm view next version`)."

A correct interaction, before citing a Reddit thread:

1. Invoke `firecrawl-search` with a targeted query.
2. Read the returned page.
3. State the claim grounded in the URL fetched, citing the URL.

An incorrect interaction:

1. State a version from memory.
2. (No verification step.)
3. Move on.

## When this protocol is in force

Always, for the duration of every Claude Code session where the oracle
plugin is loaded. The cascade is the default for any externally-
verifiable claim. There is no "small claim" exception; the same
hallucination failure mode that produces wrong version numbers also
produces wrong stat references and fabricated forum posts.

## Pairing with the install-interception hook

The oracle plugin also installs a PreToolUse hook on the `Bash` tool
that fires whenever an install / add subcommand is detected with at
least one unpinned package. When that hook fires, treat its
`additionalContext` message as a binding cue to run Tier 1 before
proceeding with the install. The hook is non-blocking; it is the
agent's job to honour it.
