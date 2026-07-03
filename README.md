# skunkworks-marketplace

A private Claude Code marketplace. Five plugins that carry my working conventions
into every repo I open: research that refuses to guess, DevOps and Rust tooling,
a Chakra frontend track, and a Solana decoder reference. One marketplace, kept in
sync, installed per-repo as needed.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Marketplace](https://img.shields.io/badge/marketplace-v5.43.0-green.svg)](.claude-plugin/marketplace.json)
[![Plugins](https://img.shields.io/badge/plugins-5-green.svg)](#plugins)
[![Status](https://img.shields.io/badge/status-work%20in%20progress-orange.svg)](#status)

> **Status.** Work in progress. The plugin surface is consolidating, versions move
> often, and some descriptions here run ahead of or behind the code. When the two
> disagree, the plugin manifest under `plugins/<name>/.claude-plugin/plugin.json`
> is the source of truth. Pin nothing you are not prepared to re-pin.

---

## Contents

- [What this is](#what-this-is)
- [Quick start](#quick-start)
- [Plugins](#plugins)
  - [oracle](#oracle) — research, verification, and harness discipline
  - [oracle-devops](#oracle-devops) — moonrepo, Terraform, Firecrawl, codegen
  - [oracle-frontend](#oracle-frontend) — Chakra UI v3 and TypeScript intelligence
  - [oracle-rust](#oracle-rust) — utoipa and Rust intelligence
  - [carbon-solana](#carbon-solana) — Carbon decoder reference, 64 protocols
- [Repository layout](#repository-layout)
- [Conventions](#conventions)
- [Local development](#local-development)
- [Attribution](#attribution)
- [License](#license)

---

## What this is

Most of these plugins began as a sprawl of single-purpose tools and have since
been folded into a smaller set of `oracle-*` plugins organised by where you
install them rather than by what topic they cover. The idea is that you drop
`oracle-devops` into a DevOps repo, `oracle-rust` into a Rust service, and
`oracle-frontend` into a frontend subdirectory, and each one brings the skills,
language-server wiring, and MCP servers that belong there — nothing more.

Two shapes recur. Some plugins are **knowledge**: a `SKILL.md` (or a tree of them)
that loads itself when your prompt matches its triggers, then gets out of the way.
Others are **workflow**: slash commands and subagents that drive a multi-step
process. `oracle` is mostly workflow; the rest are mostly knowledge with a little
language-server and onboarding glue attached.

Everything is independent. Add the marketplace once, then install only what a given
repository needs.

---

## Quick start

Add the marketplace:

```
/plugin marketplace add Executioner1939/skunkworks-marketplace
```

Install per repository:

```
/plugin install oracle@skunkworks-marketplace
/plugin install oracle-devops@skunkworks-marketplace
/plugin install oracle-frontend@skunkworks-marketplace --scope local
/plugin install oracle-rust@skunkworks-marketplace
/plugin install carbon-solana@skunkworks-marketplace
```

`oracle-frontend` is meant to be installed at `--scope local` from a frontend
subdirectory; the others are fine at user or project scope. After installing,
`/plugin marketplace update skunkworks-marketplace` pulls newer versions.

---

## Plugins

### oracle

The big one, and the only pure workflow plugin. `oracle` exists to stop Claude
guessing about anything externally verifiable — versions, library choices,
citations, release notes — and to keep long sessions honest.

It exposes its surface as slash commands backed by
[skills](plugins/oracle/skills/) — [`/oracle:init`](plugins/oracle/skills/init/SKILL.md)
and [`/oracle:narrator`](plugins/oracle/skills/narrator/SKILL.md) alongside `setup`,
`research`, `verify`, `vet`, `budget`, `mcp-fleet`, and `bugfix`. Behind the research command sits a panel of
[research subagents](plugins/oracle/agents/) — a canon reader for specs and
official docs, a GitHub archivist, a forum anthropologist for lived experience, an
issue investigator for maturity signals, and a cost rethinker that proposes cheaper
search paths when a call gets expensive.

Capabilities worth knowing about:

- **Structured research** — [`/oracle:research`](plugins/oracle/skills/research/SKILL.md)
  with `--intensity quick|standard|exhaustive`, fanned out across the subagent panel
  and bound by a [verification protocol](plugins/oracle/skills/verification-protocol/SKILL.md)
  that traces claims to sources.
- **On-demand checks** — [`/oracle:verify`](plugins/oracle/skills/verify/SKILL.md) for a
  single claim, [`/oracle:vet`](plugins/oracle/skills/vet/SKILL.md) for a deep look at
  one dependency before you commit to it.
- **Anti-hype ranking** — [`anti-hype-ranking`](plugins/oracle/skills/anti-hype-ranking/SKILL.md)
  fires whenever Claude is about to recommend or shortlist a dependency, and forces
  the comparison onto evidence rather than popularity.
- **A large Firecrawl skill family** — eighteen [`firecrawl-*` skills](plugins/oracle/skills/)
  (scrape, crawl, map, search, deep-research, market and competitive intel, paper
  research, plus build/onboarding helpers) over a bundled `firecrawl` MCP server,
  gated by a budget tracker you can inspect with
  [`/oracle:budget`](plugins/oracle/skills/budget/SKILL.md).
- **Multi-workspace MCP onboarding** — [`mcp-fleet`](plugins/oracle/skills/mcp-fleet/SKILL.md)
  wires Chrome-profile-isolated OAuth/token access for several workspaces at once.
- **Diagnose-then-fix a bug** — [`/oracle:bugfix`](plugins/oracle/skills/bugfix/SKILL.md)
  grounds in git history before touching code (regression vs. a deliberate decision
  that's now wrong vs. someone else's in-flight work), fixes the root cause with
  scoped Boy Scout cleanup, adds regression tests, and ships as a hotfix — branch,
  PR, merge — by default. Ships a
  [known-gotchas reference](plugins/oracle/skills/bugfix/references/known-gotchas.md)
  of recurring trap classes (concurrent-work races, build-mode config divergence,
  immutable infra fields, squash-merge ancestry damage, and more).
- **Session discipline** — a [session-checkpoint](plugins/oracle/skills/session-checkpoint/SKILL.md)
  loop summarises work at intervals, and [path-preflight](plugins/oracle/skills/path-preflight/SKILL.md)
  and [parallel-tools](plugins/oracle/skills/parallel-tools/SKILL.md) cut the
  read-before-edit and under-parallelised-tool-call mistakes seen across my
  transcript corpus.

Design notes live under [`plugins/oracle/docs/`](plugins/oracle/docs/) — see the
[search-workflows](plugins/oracle/docs/SEARCH-WORKFLOWS.md) and
[Helm template system](plugins/oracle/docs/HELM-TEMPLATE-SYSTEM.md) writeups. Full
detail is in the [plugin README](plugins/oracle/README.md). Requires a
`FIRECRAWL_API_KEY`.

### oracle-devops

Install in a DevOps or infrastructure repo. Eight [skills](plugins/oracle-devops/skills/)
covering the tools I actually reach for:

- [`ci-moonrepo`](plugins/oracle-devops/skills/ci-moonrepo/) and
  [`ci-moonrepo-workspace`](plugins/oracle-devops/skills/ci-moonrepo-workspace/) —
  a moonrepo v2 expert: workspace and task setup, sharded CI pipelines, Docker
  multi-stage builds, remote caching, and a catalogue of symptom-keyed gotchas
  (affected-detection no-ops, runInCI inheritance traps, name drift, cache flakiness,
  binary collisions).
- [`terraform-skill`](plugins/oracle-devops/skills/terraform-skill/) — Terraform /
  OpenTofu modules, tests, CI, scanning, and state operations, diagnosed by failure
  mode. Bundled from Anton Babenko's work; see [Attribution](#attribution).
- [`openapi-rust-gen`](plugins/oracle-devops/skills/openapi-rust-gen/) — generate or
  refresh a Rust client crate from an OpenAPI spec via the pinned generator image,
  wired into a moon task.
- Four Firecrawl workflow skills —
  [knowledge-base](plugins/oracle-devops/skills/firecrawl-knowledge-base/),
  [knowledge-ingest](plugins/oracle-devops/skills/firecrawl-knowledge-ingest/),
  [QA](plugins/oracle-devops/skills/firecrawl-qa/), and
  [website-design-clone](plugins/oracle-devops/skills/firecrawl-website-design-clone/).

Details in the [plugin README](plugins/oracle-devops/README.md).

### oracle-frontend

Install at `--scope local` from a frontend root. Three Chakra UI v3
[skills](plugins/oracle-frontend/skills/) —
[builder](plugins/oracle-frontend/skills/chakra-ui-builder/),
[migrate](plugins/oracle-frontend/skills/chakra-ui-migrate/), and
[refactor](plugins/oracle-frontend/skills/chakra-ui-refactor/) — over the official
`@chakra-ui/react-mcp` server (Chakra Pro opt-in via `CHAKRA_PRO_API_KEY`).

It also wires [`typescript-language-server`](plugins/oracle-frontend/.lsp.json) as
the LSP for `.ts`/`.tsx`/`.js`/`.jsx`, which covers React, Next.js, Storybook, and
Node — none of which ship a language server of their own. A SessionStart
[onboarding hook](plugins/oracle-frontend/hooks/hooks.json) offers to install the
server (via mise, npm, or pnpm, or the official route) when it is missing from a
TypeScript project, and remembers your answer. See the
[plugin README](plugins/oracle-frontend/README.md).

### oracle-rust

Install in a Rust repo. Bundles the
[`rust-utoipa`](plugins/oracle-rust/skills/rust-utoipa/) skill — full utoipa v5.4
macro coverage (`ToSchema`, `OpenApi`, `IntoParams`, `IntoResponses`), security
schemes, generics, and the Axum / Actix-web / Rocket integrations with Swagger UI,
Redoc, RapiDoc, and Scalar.

It wires [`rust-analyzer`](plugins/oracle-rust/.lsp.json) as the LSP for `.rs`, with
the same SessionStart [onboarding hook](plugins/oracle-rust/hooks/hooks.json) that
offers to install it (mise / rustup / cargo / brew or official) when it is missing.
See the [plugin README](plugins/oracle-rust/README.md).

### carbon-solana

A knowledge plugin for the [Carbon](https://github.com/sevenlabs-hq/carbon) Solana
indexing framework. The main [`carbon-solana`](plugins/carbon-solana/skills/carbon-solana/)
skill covers the pipeline, datasources, the five pipe types, the `Processor` trait,
transaction schema matching, and the CLI codegen.

Beneath it sit 64 per-protocol [sub-skills](plugins/carbon-solana/skills/) — Raydium,
Pumpfun, Meteora, Orca, Phoenix, OpenBook, Jupiter, Drift, Kamino, Marginfi, SPL
Token, MPL, and more — each of which loads on its protocol's keywords and lists every
instruction, account, CPI event, and shared type by name. For full struct fields,
discriminators, and `ArrangeAccounts` variants, the bundled
[`scripts/carbon.py`](plugins/carbon-solana/scripts/carbon.py) extracts them on demand
from your local cargo registry cache (or `$CARBON_SRC`) using ast-grep with a regex
fallback, so the reference never goes stale against a pinned snapshot. Rust files get
[`rust-analyzer`](plugins/carbon-solana/.lsp.json) wiring and the shared onboarding
hook.

---

## Repository layout

```
.claude-plugin/marketplace.json   # the catalogue every plugin is registered in
plugins/
├── oracle/                       # workflow: agents/ skills/ docs/ + firecrawl MCP
├── oracle-devops/                # knowledge: 8 skills (moon, terraform, firecrawl, codegen)
├── oracle-frontend/              # knowledge: 3 Chakra skills + chakra MCP + TS LSP + hook
├── oracle-rust/                  # knowledge: rust-utoipa + rust-analyzer LSP + hook
└── carbon-solana/                # knowledge: 1 main + 64 sub-skills + carbon.py + LSP + hook
```

A workflow plugin keeps its subagent definitions in `agents/` and all of its
skills — both the user-invokable slash commands and the auto-loaded knowledge —
in `skills/<name>/SKILL.md`. A knowledge plugin is just the `skills/` tree,
optionally with a `.lsp.json`, an `.mcp.json`, and a `hooks/` directory. Each
plugin carries its own `README.md` and `CHANGELOG.md`.

---

## Conventions

Not enforced by the spec — patterns that have earned their place and get carried
forward when a new plugin is added.

- **Everything is a skill.** Both user-invokable slash commands and auto-loaded
  knowledge live under `skills/<name>/SKILL.md` (the form the current docs steer new
  work toward). A slash-command skill sets `disable-model-invocation: true` and an
  `argument-hint`; a knowledge skill relies on its `description` triggers and keeps
  sibling `references/`.
- **LSP via `.lsp.json`.** Language servers are declared in a plugin-root `.lsp.json`
  (the documented mechanism), never inline in the marketplace entry. The binary must
  be on PATH; a SessionStart hook offers to install it and records the decision under
  `${CLAUDE_PLUGIN_DATA}` so it never re-prompts.
- **`file:line` discipline.** Audit and research findings trace to `file:line`.
  Unanchored claims do not ship.
- **Current data over frozen snapshots.** `carbon-solana` reads decoder source from
  the cargo cache; `oracle` reads transcripts and live sources. Versions are not baked
  into static markdown when the source is queryable on demand.
- **No regex on `.ts`/`.tsx`** in plugin tooling — TypeScript Compiler API or ast-grep.
- **No emojis** in any plugin output, command body, agent prompt, or skill content.

Every plugin version bump updates that plugin's `CHANGELOG.md` (Keep a Changelog
format) in the same commit.

---

## Local development

```
# Run a plugin without installing it
claude --plugin-dir ./plugins/<name>

# Pick up edits without restarting
/reload-plugins
```

Plugin manifests live at `plugins/<name>/.claude-plugin/plugin.json`; the catalogue
is [`.claude-plugin/marketplace.json`](.claude-plugin/marketplace.json), which sets
`metadata.pluginRoot: "./plugins"` so sources are written `./plugins/<name>`. Run
`claude plugin validate ./plugins/<name>` before committing.

---

## Attribution

MIT for original content. One bundled dependency carries its own license:

- [`oracle-devops`](plugins/oracle-devops/) bundles Anton Babenko's
  [terraform-skill](https://github.com/antonbabenko/terraform-skill)
  (`terraform-best-practices.com`), Apache-2.0. The upstream license is preserved at
  [`UPSTREAM-LICENSE-terraform-skill`](plugins/oracle-devops/UPSTREAM-LICENSE-terraform-skill).

`carbon-solana` references the [`sevenlabs-hq/carbon`](https://github.com/sevenlabs-hq/carbon)
framework but neither bundles nor modifies it — it reads decoder source on demand from
your own cargo cache.

---

## License

[MIT](LICENSE) for original content. Apache-2.0 for the bundled terraform-skill noted
above, whose license file is preserved in the plugin.
