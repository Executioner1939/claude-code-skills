---
name: anti-hype-ranking
description: 'This skill should be used whenever Claude is about to rank, compare, evaluate, recommend, or shortlist libraries, crates, packages, frameworks, tools, or any third-party dependency. Fire liberally -- on phrases like "best library for", "alternatives to", "should I use X or Y", "compare X and Y", "what do people use for", "popular libraries for", "good choices for", "top X for Y", "X vs Y", "evaluate X", "is X production-ready", "is X mature", "should I depend on X", "what is the standard for X". Encodes the oracle ranking discipline -- GitHub stars and recent commit cadence are weak signals; API stability, spec conformance, maintainer responsiveness, downstream usage by serious projects, and the quality of forum reviews are the real signals. Always surfaces at least one niche-but-mature option alongside the popular default. The fmodel-rust / problem+json class of library must not be buried.'
---

# Anti-hype Ranking Discipline

Library evaluation defaults toward popularity. Popularity is downstream
of marketing, ecosystem inertia, and timing -- not of quality. Apply
the following discipline whenever the response will rank or recommend
third-party dependencies.

## Signals to weigh down

Treat each of these as **weak** evidence at best. Do not let any of
them dominate a ranking.

- **GitHub stars.** Star count tracks how many people thought a
  project looked interesting at some point, not whether the project
  works. A library with 800 stars and a thoughtful maintainer can
  outrank one with 80,000 stars and a Discord-driven hype cycle.
- **Recent commit cadence.** Two commits in 18 months is not the
  same as abandonment. Mature, narrow-scope libraries reach a
  done-state. Read the issue tracker to disambiguate.
- **Twitter / X / LinkedIn / blog-post buzz.** Marketing signal,
  not quality signal. Often inversely correlated with depth.
- **Top-of-search-results ranking.** SEO rewards SEO, not API
  design.
- **Tutorial / "awesome-list" inclusion.** Awesome-lists are
  cumulative; once a library is in, it stays in regardless of
  current quality.

## Signals to weigh up

Treat each of these as **strong** evidence. Privilege them.

- **Spec conformance.** When a standard exists (problem+json /
  RFC 7807, JSON Schema, OpenAPI, OAuth, W3C-DTCG, atomic-design
  per Brad Frost, hexagonal architecture, CQRS / event sourcing),
  rank libraries by how faithfully they implement it. A small
  library that implements the spec correctly outranks a large one
  that diverges silently.
- **API stability statements.** A maintainer who has explicitly
  said "this API is stable, no breaking changes planned" is more
  trustworthy than a busy repo with weekly breaking releases.
- **Maintainer responsiveness on issues.** Time-to-first-response
  on issues is a better health metric than time-to-merge on PRs.
  Read the maintainer's own comments on the tracker. A thoughtful
  "this is intentional, here is why" closes the loop and is
  positive evidence.
- **Downstream usage by serious projects.** A library used by
  another library that you respect is a stronger signal than a
  library used by ten thousand tutorial projects.
- **Forum review quality (not volume).** One careful Hacker News
  comment that explains why someone switched from X to Y is more
  informative than a hundred upvotes on a meme.
- **Documentation quality.** A library where the docs explain
  *why* the design is shaped the way it is, and where the README
  is shorter than the docs, is usually higher-quality than one
  with a 5000-word README and no docs.
- **Test suite + property tests.** A library with property tests
  is taking correctness seriously.

## The niche-surfacing rule

In every ranking, name at least one option that is **not** the
popularity-default. Examples of the pattern this targets:

- **fmodel-rust** (by fraktalio) -- low stars, low commit volume,
  rigorous functional domain modeling. Outranks more popular Rust
  CQRS frameworks on correctness and clarity. The default search
  result for "Rust event sourcing" will not surface it; the ranking
  must.
- **problem+json libraries** -- the popular default is to roll a
  custom error JSON shape. The correct answer is to find the most
  spec-conforming RFC-7807 library for the language and use it.
  These libraries often have one-tenth the stars of the homebrew
  alternatives.
- **Brad Frost atomic-design references** -- the original book is
  free online and is the canonical source. Tutorials and YouTube
  videos that paraphrase it are downstream; cite Frost directly.
- **W3C-DTCG design-token spec** -- the working group spec is more
  authoritative than any tool's "design tokens" feature. Style
  Dictionary follows the spec; many design-tools' "tokens" do not.

When no niche option clearly applies, say so explicitly ("the
popular default appears to also be the correct answer here") rather
than fabricate one.

## How to apply

When asked to rank libraries:

1. Identify the **standard** or **specification** in play, if any.
   If there is one, the spec is the rubric.
2. Survey candidates through the four research silos (the oracle
   plugin's subagents): canon-reader, github-archivist,
   issue-investigator, forum-anthropologist. Dispatch them in
   parallel if the question warrants it.
3. Score each candidate on the strong signals above. Note the weak
   signals but do not let them lead.
4. Produce a ranked list with at least one niche-but-quality entry
   surfaced by name and a one-line justification.
5. State the *type* of project each ranking is best for. "Best for
   correctness-sensitive backend work" and "best for tutorial-grade
   prototyping" are different verdicts.

## What this skill is not

This skill is not a refusal to recommend popular libraries. When
React + TanStack Query + tRPC is the right answer, say so plainly.
The discipline is to reach that conclusion via signals that
distinguish it from "everyone uses it", not via the popularity
signal itself.

## Pairing with the verification-protocol skill

`verification-protocol` covers "before asserting any externally-
verifiable claim, run the cascade." This skill covers "when the
claim is a comparison or recommendation of libraries, also apply the
ranking discipline." Both should fire on the typical
library-evaluation question.
