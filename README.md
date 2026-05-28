# skunkworks

A personal Claude Code marketplace. Twelve plugins covering CI/CD, Rust, documentation, code analysis, design systems, infrastructure-as-code review, Solana indexing, multi-agent orchestration, and meta-tooling. Shared conventions, kept in sync.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE) (with bundled Apache-2.0 portions — see [Attribution](#attribution))
[![Marketplace version](https://img.shields.io/badge/marketplace-v5.38.0-green.svg)](.claude-plugin/marketplace.json)
[![Plugins](https://img.shields.io/badge/plugins-12-green.svg)](#plugins)

---

## Quick start

Add the marketplace once:

```
/plugin marketplace add Executioner1939/claude-code-skills
```

Install plugins individually as needed:

```
/plugin install carbon-solana@skunkworks
/plugin install ci-moonrepo@skunkworks
/plugin install rust-utoipa@skunkworks
/plugin install rust-fmodel@skunkworks
/plugin install docs-eventcatalog@skunkworks
/plugin install design-principles@skunkworks
/plugin install analysis-codebase-archaeology@skunkworks
/plugin install terraform-audit@skunkworks
/plugin install anvil@skunkworks
/plugin install rust-monorepo-orchestrator@skunkworks
/plugin install harness-tuner@skunkworks
/plugin install meta-skill-improver@skunkworks
```

Each plugin is independent. Pick what you need.

---

## Plugins

The marketplace splits along two shapes: **workflow plugins** drive multi-step processes through slash commands and subagents, and **knowledge plugins** auto-load reference material when a relevant prompt comes in.

### Workflow plugins

#### `analysis-codebase-archaeology` — v1.2.0

Two-agent system that reverse-engineers existing codebases. The `codebase-archaeologist` excavates what *is*; the `transformation-strategist` plans what to *do* with it. Seven analysis lenses (migration, architecture, decomposition, risk, documentation, test-strategy, debt). Every finding traces to `file:line`.

```
/analysis-codebase-archaeology:archaeology [path] [--objective=...]
```

Outputs a timestamped report under `<path>/.archaeology/<timestamp>/index.md`. Auto-triggers on phrases like "analyze codebase", "extract business rules", "plan migration", "technical debt".

#### `terraform-audit` — v1.1.0

Structured, opinionated audit of a Terraform / OpenTofu module repository. Detects cross-module composition smells (overlap, duplication, thin wrappers, scope-discriminator primitives, copy-pasted module blocks, tier misplacement), cross-project / cross-account linking flaws, missing validations, dead code, version-pinning drift, and provider-specific landing-zone gaps (GCP, AWS, Azure, OCI). Eight-section critique with per-module letter grades and a numbered defect list. Optional baseline diff for tracking debt over time.

```
/terraform-audit:audit [path-to-repo]
```

Bundles Anton Babenko's `terraform-skill` v1.6.0 (Apache-2.0) for canonical Terraform best-practices context. Auto-triggers on "audit terraform", "review terraform".

#### `anvil` — v4.0.0

The largest plugin in the marketplace. Atomic design (Brad Frost) plus Storybook 10. CSF Factories only. TanStack-ecosystem-centric (Query, DB, Form, Table, Virtual, Store, Pacer). Web (Tailwind 4) and native (NativeWind / Expo / Reanimated). Inter-agent `HANDOFF.md` contract. Tier-1 baseline diff plus Tier-2 dated audit history.

Ships `@anvil/inspector` — a structurally precise TypeScript toolkit (TypeScript Compiler API + ast-grep, never regex on `.ts` / `.tsx`) with 24 CLI verbs covering per-component cards, design-system inventory via the structural import graph, body-tree archaeology presets (raw HTML containers, hardcoded spacing/colour, inline styles, untokenised classes, image-no-alt, link-no-href, button-no-label, data-attr-without-testid), and structural mutations (rename / safe-delete / verify-mdx / orphan-exports — dry-run by default).

Nineteen slash commands (10 inspector commands plus the audit / add / merge suite), 11 specialized subagents, ~20 knowledge skills. Bundles 7 atomic-design references (Apache-2.0, adapted from `TheBushidoCollective/han`).

#### `rust-monorepo-orchestrator` — v0.4.0

Methodology-first multi-agent refactoring orchestrator for monorepos. Spawns parallel waves of Opus-orchestrated, Sonnet-implemented subagents that drill a domain top to bottom (HTTP commands → events → views → inter-service events), document architecture violations, author project-specific ast-grep rules, then run a wave of isolated-worktree workers with claim-lock concurrency, automerge on verifier-pass, and dead-letter on failure. Filesystem inbox; `HANDOFF.md` cross-phase contract; subagent memory.

Stack-agnostic: rules are authored per project, not shipped by the plugin. Seven slash commands (`/init`, `/audit-domain`, `/plan-refactor`, `/run-wave`, `/status`, `/replay`, `/sweep-rules`), nine subagents, three methodology skills.

#### `harness-tuner` — v0.4.0

Meta-plugin: optimize the Claude Code harness itself for a project. Reads session transcripts to digest recurring user friction, audits `CLAUDE.md` / skills / rules / commands / hooks / monitors across the user → project → subdirectory hierarchy, and recommends additions / edits / removals — never touching the root `CLAUDE.md`.

Hierarchy-aware (parent-but-not-root); uses `@` imports for cwd-relative content; for monorepos, can author a per-service summary `CLAUDE.md` that auto-loads when working in that subtree. Hard rules: never edits root `CLAUDE.md`, never edits `~/.claude/`, refuses `CLAUDE.md` changes that exceed 200 lines or path-scoped rule changes that exceed 150 lines, validates `@` imports resolve, appends one line to `.claude/CHANGELOG.md` per applied change.

Four-phase pipeline: `/digest` → `/audit` → `/plan` → `/tune`.

#### `meta-skill-improver` — v0.1.1

Evidence-grounded skill evolution. Mines Claude Code transcripts and git history across one or more repos for recurring user friction on a topic, clusters the friction into anonymized failure-mode reproducers, synthesizes a four-class prompt matrix per failure mode, runs a sandbox harness with and without the candidate skill loaded, and produces a mathematically-graded scorecard with a promote-or-block verdict. Treats the skill-under-test as a non-deterministic SUT and uses property-based-testing-with-N-runs methodology to separate signal from noise. Builds on the `_codify` pipeline and adds the missing executor-and-grader stages.

- Workflow: **`/meta-skill-improver:improve-skill <topic> --repos <paths> (--target <plugin:skill> | --new <plugin:skill>)`**
- Subagents: `transcript-miner`, `snapshot-builder`, `prompt-synthesizer`, `skill-author`, `skill-auditor`, `sandbox-runner`.
- Skills: `grading` (the math), `eval-methodology` (the design), `snapshot-anonymization` (the privacy rules).
- Scripts: `eval_score.py` -- pure deterministic grading library; ships with synthetic-fixture smoke tests.
- Output: `evals/<plugin--skill>/scorecards/<version>.json` plus a markdown report; the scorecard is the regression baseline future iterations replay against.

### Knowledge plugins

These have no commands or subagents — just `SKILL.md` files that auto-load when their description matches the user's prompt.

#### `carbon-solana` — v0.1.0

Reference for the [Carbon](https://github.com/sevenlabs-hq/carbon) Solana indexing framework. Top-level skill covers the pipeline, all 14 datasources (Yellowstone gRPC, Helius LaserStream / Atlas / GPA / GTFA, RPC block / program / transaction subscribers, Jito Shredstream, Jetstreamer, validator-snapshot), the five pipe types, the `Processor` trait, transaction schema matching, and the `carbon-cli` codegen.

Sixty-four per-protocol sub-skills (`carbon-raydium-amm-v4`, `carbon-pumpfun`, `carbon-meteora-dlmm`, `carbon-orca-whirlpool`, `carbon-drift-v2`, `carbon-jupiter-swap`, …) auto-load on protocol keywords and list every available instruction, account, CPI event, and shared type by name. For full struct fields, discriminators, and `ArrangeAccounts` variants, the bundled `scripts/carbon.py` extracts on demand from your local cargo registry cache (or `$CARBON_SRC`) using ast-grep with regex fallback. No stale snapshots.

Auto-triggers on: `carbon`, `carbon-core`, `Pipeline::builder`, `InstructionDecoder`, `ArrangeAccounts`, `decode_log_events`, `yellowstone grpc`, plus protocol-specific terms (Raydium, Pumpfun, Meteora, Orca, Jupiter, Drift, Kamino, Phoenix, etc.) when paired with "decode", "indexer", "instruction", "event", or "args".

#### `ci-moonrepo` — v3.2.0

[moonrepo](https://moonrepo.dev/) v2.2 expert. Workspace setup, task orchestration, CI/CD pipelines with sharding, Docker multi-stage builds, remote caching, code generation with Tera, WASM plugin toolchains, MQL queries, v1-to-v2 migration, and a curated catalogue of real-world gotchas.

Auto-triggers on: `moon.yml`, `.moon/`, `moon run`, `moon ci`, monorepo builds.

#### `rust-utoipa` — v2.0.2

[utoipa](https://github.com/juhaku/utoipa) v5.4 reference. Complete macro coverage (`ToSchema`, `OpenApi`, `IntoParams`, `IntoResponses`, `ToResponse`), `#[utoipa::path]` attributes, security schemes, enum handling, generics, validation, and integrations (Axum, Actix-web, Rocket; Swagger UI, Redoc, RapiDoc, Scalar).

Auto-triggers on: `utoipa`, OpenAPI in Rust, `ToSchema`, API documentation.

#### `rust-fmodel` — v1.0.3

[fmodel-rust](https://github.com/fraktalio/fmodel-rust) v0.9 (MSRV 1.75+, native async-fn-in-trait). Decider / View / Saga domain types; algebraic composition (`combine`, `merge`, `map`); application-layer wiring (`EventSourcedAggregate`, `StateStoredAggregate`, `MaterializedView`, `SagaManager`).

Auto-triggers on: `fmodel`, `Decider`, `View`, `Saga`, event sourcing in Rust, CQRS in Rust.

#### `docs-eventcatalog` — v2.2.0

[EventCatalog](https://www.eventcatalog.dev/) reference. All 13 resource types (including Data Products), the full SDK (snapshots, DSL builders, custom docs), 15+ generator integrations (OpenAPI, AsyncAPI, GraphQL, Confluent, AWS), MCP server, visualizations (NodeGraph, flows, Mermaid), and schema support (JSON Schema, Avro, Protobuf).

Auto-triggers on: EventCatalog, event documentation, AsyncAPI, service catalog, message flows.

#### `design-principles` — v1.0.1

Curated reference library of canonical design principles for UI, product, and crosscutting judgment: Joshua Porter's UI and product principles, Dieter Rams' ten, Bruce Tognazzini's first principles of interaction design, inclusive design tenets, and foundational laws (Postel's robustness, Pareto, DRY, principle of least surprise).

Auto-triggers on: UI/UX review, design critique, product tradeoff calls, microcopy, empty states, design feedback.

---

## Plugin layout

Two distinct shapes, applied consistently across the marketplace.

### Workflow plugins

```
<plugin>/
├── .claude-plugin/plugin.json
├── README.md
├── commands/                    # user-invokable slash commands (flat .md)
│   └── <workflow>.md            # disable-model-invocation: true, argument-hint, dispatches subagents
├── agents/                      # subagent definitions (Task-tool dispatched)
│   └── <agent>.md               # frontmatter declares loaded skills + tools
├── skills/                      # auto-loaded knowledge
│   └── <skill>/SKILL.md         # methodology, templates, references
└── hooks/                       # optional event handlers
    └── hooks.json
```

Each workflow command renders subagent prompts as a structured **invocation envelope** — `goal` / `inputs` / `context` / `constraints` / `out_of_scope` / `acceptance` / `output_format` — instead of free-form prose. Reduces non-determinism in agent dispatch.

### Knowledge plugins

```
<plugin>/
├── .claude-plugin/plugin.json
└── skills/<plugin-name>/
    ├── SKILL.md                 # auto-trigger via description match
    └── references/              # progressive disclosure, loaded on demand
```

No agents, no commands. The skill loads when its `description` triggers fire.

`carbon-solana` extends this shape: one main skill plus 64 thin per-protocol sub-skills under `skills/carbon-<slug>/SKILL.md`, plus a `scripts/` directory with the on-demand extraction tool.

---

## Conventions

These are not enforced by the spec — they're patterns that have proven useful and are propagated when new plugins are added.

- **Workflows in `commands/`, knowledge in `skills/`.** Workflows are flat `.md` files with `disable-model-invocation: true` plus `argument-hint`. Knowledge skills are directories with `SKILL.md` and sibling `references/`.
- **Agent ↔ skill linkage** declared via the agent's `skills:` frontmatter. The skill's content auto-loads into the subagent at dispatch.
- **Inter-agent HANDOFF contract** (used in `anvil`, `rust-monorepo-orchestrator`). Every agent in a chain ends its output with `HANDOFF: <path>` pointing to a phase-boundary file. The orchestrator halts if any agent skips the handoff.
- **Tier-1 baseline plus Tier-2 dated history.** Audit-style outputs write a static "current state" baseline alongside an append-only dated history directory. Diff-friendly, blame-friendly.
- **agent-memory activity logs.** Subagents declare a `Stop` hook that appends to `.claude/agent-memory/<agent>/activity.log`. Telemetry-by-default for cross-session continuity.
- **`file:line` discipline.** Every audit / archaeology finding traces to `file:line`. Unanchored claims are not allowed in output.
- **Always-current data over frozen snapshots.** `carbon-solana` reads decoder source from the local cargo cache; `harness-tuner` reads transcripts from disk; `anvil/inspector` walks the live AST. Avoid baking blockchain or framework versions into static markdown when source is queryable on demand.
- **No regex on `.ts` / `.tsx`** in any plugin tooling — use the TypeScript Compiler API or ast-grep. Encoded in `anvil`'s `safe-code-mutation` skill and applied across the marketplace.
- **No emojis** in any plugin output, command body, agent prompt, or skill content.

---

## Naming

Plugins are prefixed by category so the marketplace stays browsable as it grows:

| Prefix | Domain |
|---|---|
| `analysis-*` | code analysis, reverse engineering, auditing |
| `carbon-*` | Carbon Solana indexing framework references |
| `ci-*` | build systems, CI/CD, task runners |
| `design-*` | design principles, design systems, UI/UX |
| `docs-*` | documentation tooling and authoring |
| `meta-*` | marketplace meta-tooling — skills that produce, evaluate, or evolve other skills |
| `rust-*` | Rust ecosystem crates and patterns |
| `terraform-*` | Terraform / OpenTofu / IaC review |
| (other) | meta tooling — `anvil`, `harness-tuner` |

---

## Local development

```
# Test a plugin without installing
claude --plugin-dir ./plugins/<plugin-name>

# After edits, reload without restart
/reload-plugins
```

Plugin manifests live at `<plugin>/.claude-plugin/plugin.json`. Marketplace catalog at `.claude-plugin/marketplace.json`. The marketplace declares `metadata.pluginRoot: "./plugins"` so plugin sources are written `./plugins/<name>` (a Claude Code convenience that lets short forms work).

For repo-internal tooling that is **not** a published plugin, see [`_codify/`](_codify/README.md) — a personal `/codify` slash command that mirrors patterns observed in a session into remediation reports for this marketplace. User-scope only; intentionally not registered in `marketplace.json`.

---

## Notes

**TODO — merge custom Contactable design-system tooling into the harness as design-system sub-tools.**

Source repo: `~/Documents/Work/Personal/Contactable/skunkworks-kyc-ts` (the `@athena/ui` package and its root `CLAUDE.md`). The rebuild from scratch uses Chakra UI v3 + Chakra UI Pro on a TanStack stack (Form, Table, Virtual) with Keycloakify auth. Patterns worth extracting into the marketplace:

- atoms / molecules / organisms inventory convention with barrel exports per tier
- compound component pattern (`Card.Title` style via `Object.assign`)
- Form mode context pattern (view / edit with `EditableInput`)
- Chakra system + brand-token + semantic-token theme layout (`packages/ui/src/theme/system.ts`)
- component-creation hooks (barrel update + `CLAUDE.md` inventory update + story + pattern doc, all in the same commit)
- Chakra Pro block-preference rule (prefer Pro recipes over custom implementations)

Likely landing place: extend `plugins/anvil/` with a Chakra-specific sub-track (atoms/molecules/organisms scaffolds + Chakra Pro reference skill), or split into a new `design-system-chakra` knowledge plugin if the surface area justifies it. Decide once the Contactable rebuild stabilises.

---

## Attribution

The marketplace is **MIT** for original content. Two plugins bundle Apache-2.0 third-party content, fully attributed:

- **`terraform-audit`** bundles Anton Babenko's [terraform-skill](https://github.com/antonbabenko/terraform-skill) v1.6.0 (`terraform-best-practices.com`). Verbatim copy under `plugins/terraform-audit/skills/terraform-skill/`. License preserved at `plugins/terraform-audit/skills/_terraform-skill-license/LICENSE-Apache-2.0`. Frontmatter retains author and version metadata. No modifications.
- **`anvil`** bundles seven atomic-design methodology references adapted from [TheBushidoCollective/han](https://github.com/TheBushidoCollective/han). Apache-2.0 license preserved at `plugins/anvil/skills/_han-license/LICENSE-Apache-2.0`. Adapted to the plugin's structure; original content authorship credited.

`carbon-solana` references the [`sevenlabs-hq/carbon`](https://github.com/sevenlabs-hq/carbon) framework — neither bundled nor modified. The plugin reads decoder source on demand from the user's own cargo cache and does not ship Carbon code.

---

## License

[MIT](LICENSE) for original content (this README, the twelve plugin manifests, the original audit / archaeology / atomic-design / orchestration / Carbon-reference / meta-evaluation / knowledge skills, the slash commands, the subagents, `scripts/carbon.py`, and `eval_score.py`).

Apache-2.0 for the bundled portions noted in [Attribution](#attribution). Each bundled component preserves its license file in the appropriate `_<source>-license/` directory.
