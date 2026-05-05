# skunkworks — Claude Code marketplace

A personal marketplace of Claude Code plugins for CI/CD, Rust, documentation, code analysis, design systems, and infrastructure-as-code review. Eight plugins, sharing conventions, kept in sync.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE) (with bundled Apache-2.0 portions — see [Attribution](#attribution))
[![Marketplace version](https://img.shields.io/badge/marketplace-v5.9.0-green.svg)](.claude-plugin/marketplace.json)
[![Plugins](https://img.shields.io/badge/plugins-8-green.svg)](#plugins)

---

## Install the marketplace

```
/plugin marketplace add Executioner1939/claude-code-skills
```

Then install the plugins you want:

```
/plugin install ci-moonrepo@skunkworks
/plugin install rust-utoipa@skunkworks
/plugin install rust-fmodel@skunkworks
/plugin install docs-eventcatalog@skunkworks
/plugin install design-principles@skunkworks
/plugin install analysis-codebase-archaeology@skunkworks
/plugin install terraform-audit@skunkworks
/plugin install anvil@skunkworks
```

The plugins are independent. Install only what you need.

---

## Plugins

### Workflow plugins (slash commands, subagents, hooks)

#### `analysis-codebase-archaeology` — v1.2.0

Two-agent system that reverse-engineers existing codebases. Phase 1 excavates what IS via the `codebase-archaeologist` subagent; Phase 2 plans what to DO with it via the `transformation-strategist` subagent. 7 analysis lenses (migration, architecture, decomposition, risk, documentation, test-strategy, debt). Every finding traces to `file:line`.

- Workflow: **`/analysis-codebase-archaeology:archaeology [path] [--objective=...]`**
- Subagents: `codebase-archaeologist`, `transformation-strategist` — both read-only, plan-mode.
- Auto-triggers on natural language: "analyze codebase", "extract business rules", "plan migration", "technical debt", etc.
- Output: timestamped report under `<path>/.archaeology/<timestamp>/index.md` with linked archaeology + transformation artifacts.

#### `terraform-audit` — v1.1.0

Brutal, structured audit of a Terraform / OpenTofu module repository. Detects cross-module composition smells (overlap, duplication, thin wrappers, scope-discriminator primitives, copy-pasted module blocks, tier misplacement), cross-project / cross-account linking flaws, missing validations, dead code, version-pinning drift, and provider-specific landing-zone gaps (GCP / AWS / Azure / OCI). Produces an 8-section critique with per-module letter grades and a numbered defect list, with optional baseline diff.

- Workflow: **`/terraform-audit:audit [path-to-repo]`**
- Bundles Anton Babenko's `terraform-skill` v1.6.0 (Apache-2.0) for canonical Terraform best-practices. Auto-loaded during the audit.
- Auto-triggers on: "audit terraform", "review terraform", "tear apart terraform", "tech-debt audit terraform".
- Output: `<repo>/.terraform-audit/audit-<date>.md` plus optional baseline at `baseline.md`. Section 9 baseline-diff (Fixed / Regressed / New) when the baseline exists.

#### `anvil` — v3.0.0

The largest plugin in the marketplace. Atomic design (Brad Frost) + Storybook 10 expert toolkit. CSF Factories only. TanStack-ecosystem-centric (Query, DB, Form, Table, Virtual, Store, Pacer). Web (Tailwind 4) + native (NativeWind / Expo / Reanimated). Inter-agent HANDOFF.md contract. Tier-1 baseline diff + Tier-2 dated audit history.

- 8 slash-command workflows: `audit-atoms`, `audit-molecules`, `audit-organisms`, `audit-tokens`, `audit-libraries`, `add-component`, `merge-duplicates`, `coverage-report`.
- 11 specialized subagents: `accessibility-reviewer`, `atomic-auditor`, `component-cartographer`, `component-composer`, `component-deduplicator`, `design-token-enforcer`, `library-policy-enforcer`, `mdx-doc-writer`, `story-writer`, `storybook-coverage-analyst`, `ui-spec-interpreter`.
- ~20 knowledge skills + a static component-graph scanner (`scripts/inventory.py`) refreshed automatically by a `PostToolUse` hook on edits.
- Bundles 7 Apache-2.0 atomic-design methodology references adapted from `TheBushidoCollective/han`.

### Knowledge plugins (auto-loaded reference)

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

## How the plugins are organized

Two distinct shapes, applied consistently across the marketplace:

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

Each workflow command renders subagent prompts as a structured **invocation envelope** — `goal` / `inputs` / `context` / `constraints` / `out_of_scope` / `acceptance` / `output_format` — rather than free-form prose. Reduces non-determinism in agent dispatch.

### Knowledge plugins

```
<plugin>/
├── .claude-plugin/plugin.json
└── skills/<plugin-name>/
    ├── SKILL.md                 # auto-trigger via description match
    └── references/              # progressive disclosure, loaded on demand
```

No agents. No commands. The skill auto-loads when its `description` triggers match the user's prompt.

---

## Conventions used across plugins

These are not enforced by the spec — they're patterns that have proven useful and are propagated when new plugins are added.

- **Workflows in `commands/`**, knowledge in `skills/`. Workflows are flat `.md` files with `disable-model-invocation: true` + `argument-hint`. Knowledge skills are directories with `SKILL.md` + sibling `references/`.
- **Agent ↔ skill linkage** declared via the agent's `skills:` frontmatter. The skill's content auto-loads into the subagent at dispatch.
- **Inter-agent HANDOFF contract** (used in `anvil`). Every agent in a chain ends its output with `HANDOFF: <path>` pointing to a phase-boundary file. The orchestrator halts if any agent skips the handoff.
- **Tier-1 baseline + Tier-2 dated history.** Audit-style outputs write a static "current state" baseline plus an append-only dated history dir. Diff-friendly, blame-friendly.
- **agent-memory activity logs.** Subagents declare a `Stop` hook that appends to `.claude/agent-memory/<agent>/activity.log`. Telemetry-by-default for cross-session continuity.
- **`file:line` discipline.** Every audit / archaeology finding traces to `file:line`. Unanchored claims are not allowed in output.
- **No emojis** in any plugin output, command body, agent prompt, or skill content.

---

## Attribution

The marketplace is **MIT** for original content. Two plugins bundle Apache-2.0 third-party content with attribution:

### `terraform-audit` bundles `terraform-skill`

Anton Babenko's [terraform-skill](https://github.com/antonbabenko/terraform-skill) v1.6.0 — `terraform-best-practices.com`. Verbatim copy under `plugins/terraform-audit/skills/terraform-skill/`. License preserved at `plugins/terraform-audit/skills/_terraform-skill-license/LICENSE-Apache-2.0`. Frontmatter retains author + version metadata. No modifications.

### `anvil` bundles `han` atomic-design references

Seven atomic-design methodology references adapted from [TheBushidoCollective/han](https://github.com/TheBushidoCollective/han). Apache-2.0 license preserved at `plugins/anvil/skills/_han-license/LICENSE-Apache-2.0`. Adapted to the plugin's structure; original content authorship credited.

---

## Naming conventions

Plugins are prefixed by category so the marketplace stays browsable as it grows:

| Prefix | Domain |
|---|---|
| `analysis-*` | code analysis, reverse engineering, auditing |
| `ci-*` | build systems, CI/CD, task runners |
| `design-*` | design principles, design systems, UI/UX |
| `docs-*` | documentation tooling and authoring |
| `rust-*` | Rust ecosystem crates and patterns |
| `terraform-*` | Terraform / OpenTofu / IaC review |

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

## License

[MIT](LICENSE) for original content (this README, the eight plugin manifests, the original audit / archaeology / atomic-design / knowledge skills, the slash commands, and the subagents).

Apache-2.0 for the bundled portions — see [Attribution](#attribution) above. Each bundled component preserves its license file in the appropriate `_<source>-license/` directory.
