<div align="center">

# Skunkworks

**A curated collection of Claude Code skills for modern development workflows.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Skills](https://img.shields.io/badge/Skills-6-green.svg)](#skills)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Compatible-blueviolet.svg)](https://docs.anthropic.com/en/docs/claude-code)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/Executioner1939/claude-code-skills/pulls)

Drop-in skills that give Claude Code deep domain expertise — complete API references, configuration guides, and analysis frameworks, so Claude can help you build faster without hallucinating outdated docs.

</div>

## Naming Convention

Plugins are prefixed by category so the marketplace stays browsable as it grows:

- `ci-*` — build systems, CI/CD, task runners
- `rust-*` — Rust ecosystem crates and patterns
- `docs-*` — documentation tooling and authoring
- `analysis-*` — code analysis, reverse engineering, auditing
- `design-*` — design principles and UI/UX references

## Quick Start

```bash
# Add the marketplace
/plugin marketplace add Executioner1939/claude-code-skills

# Install the skills you need
/plugin install ci-moonrepo@skunkworks
/plugin install rust-utoipa@skunkworks
/plugin install docs-eventcatalog@skunkworks
/plugin install rust-fmodel@skunkworks
/plugin install analysis-codebase-archaeology@skunkworks
/plugin install design-principles@skunkworks
```

## Skills

### ci-moonrepo `v3.0.1`
> Monorepo Task Runner & Build System — covers moon v2.1.0

Comprehensive [moonrepo](https://moonrepo.dev/) reference: all CLI commands, workspace/toolchain/task configuration, CI/CD pipelines with sharding, Docker multi-stage builds, code generation with Tera, WASM plugin toolchains, MQL queries, remote caching, and v1-to-v2 migration.

**Triggers on:** `moon.yml` · `.moon/` configs · `moon run` · `moon ci` · monorepo builds

---

### rust-utoipa `v2.0.1`
> Rust OpenAPI Documentation Generator — covers utoipa 5.4.0

Complete [utoipa](https://github.com/juhaku/utoipa) reference: all 5 derive macros (`ToSchema`, `OpenApi`, `IntoParams`, `IntoResponses`, `ToResponse`), `#[utoipa::path]` attributes, framework integrations (Axum, Actix, Rocket), UI integrations (Swagger UI, Redoc, RapiDoc, Scalar), security schemes, enum handling, generics, validation, and 25+ cargo features.

**Triggers on:** `utoipa` · OpenAPI in Rust · `ToSchema` · Swagger UI setup · API documentation

---

### docs-eventcatalog `v2.0.1`
> Event-Driven Architecture Documentation

Complete [EventCatalog](https://www.eventcatalog.dev/) reference: all 12 resource types, 184+ SDK functions, 15+ generator integrations (OpenAPI, AsyncAPI, GraphQL, Confluent, AWS), MCP server with 15 tools, visualizations (NodeGraph, flows, Mermaid), schema support (JSON Schema, Avro, Protobuf), and authentication.

**Triggers on:** EventCatalog · event documentation · AsyncAPI · service catalog · message flows

---

### rust-fmodel `v1.0.1`
> Functional Domain Modeling in Rust — covers fmodel-rust 0.9.2

Complete [fmodel-rust](https://github.com/fraktalio/fmodel-rust) reference: Decider, View, and Saga domain types; algebraic composition via `combine`/`merge`/`map`; the `decide`/`evolve`/`initial_state` pattern; and application-layer wiring for `EventSourcedAggregate`, `StateStoredAggregate`, orchestrating aggregates, `MaterializedView`, and `SagaManager`.

**Triggers on:** fmodel · `Decider` · `View` · `Saga` · event sourcing in Rust · CQRS in Rust · functional domain modeling

---

### analysis-codebase-archaeology `v1.1.1`
> Deep Codebase Analysis & Transformation Planning

Two-agent system that systematically reverse-engineers existing codebases: extracts business rules, maps data flows, traces dependencies, and produces transformation plans. Supports 7 analysis lenses (migration, architecture, decomposition, risk, documentation, testing, debt) with structured output templates.

**Triggers on:** analyze codebase · reverse engineer · extract business rules · plan migration · due diligence · technical debt

---

### design-principles `v1.0.0`
> Canonical Design Principles Reference

Curated reference library of design principles for UI, product, and crosscutting judgment: Joshua Porter's UI and product principles, Dieter Rams' ten, Bruce Tognazzini's first principles of interaction design, inclusive design tenets, and foundational laws (Postel's robustness, Pareto, DRY, principle of least surprise). Use as a checklist and vocabulary when building, reviewing, or critiquing any user-facing surface.

**Triggers on:** UI/UX review · design critique · product tradeoff calls · microcopy · empty states · design feedback

## How Skills Work

Skills give Claude Code domain-specific knowledge through structured reference files. When you ask about a topic covered by an installed skill, Claude automatically loads the relevant documentation — accurate, version-pinned, and comprehensive — instead of relying on training data that may be outdated.

Each skill follows Anthropic's [official skill design guide](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf) with progressive disclosure: a concise SKILL.md for common tasks, and detailed reference files loaded on demand for deep dives.

## License

[MIT](LICENSE)
