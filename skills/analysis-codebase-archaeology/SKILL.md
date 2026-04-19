---
name: codebase-archaeology
description: >
  Systematically reverse-engineers and analyzes existing codebases to extract
  business rules, map data flows, trace dependencies, assess risk, and produce
  transformation plans. MUST use this skill when the user asks to understand,
  analyze, or reverse-engineer code they inherited or didn't write, plan a
  migration or architectural change to an existing system, perform due diligence
  or technical audit, extract business logic or document how code works,
  decompose a monolith, assess technical debt, or build a test strategy for
  legacy code. Triggers on: analyze codebase, extract business rules, map data
  flows, trace dependencies, code archaeology, reverse engineer, plan migration,
  rewrite in, port to, move to hexagonal, CQRS, technical debt, due diligence,
  onboarding guide, split monolith, what does this code do, hidden complexity,
  blast radius, coupling analysis, or data lineage questions.
---

# Codebase Archaeology

A two-phase system for understanding existing codebases and planning their transformation. Phase 1 excavates what exists using structured templates. Phase 2 plans what to do with it. Every finding is traceable to a file:line reference.

## How It Works

This skill orchestrates two agents with purpose-specific output templates:

1. **codebase-archaeologist** — Reads code systematically through five analysis layers. Produces structured findings using core templates plus a lens selected based on the objective.
2. **transformation-strategist** — Consumes archaeology output. Produces actionable transformation plans with sequencing, verification strategies, and risk registers.

The skill selects the right lens and templates automatically based on what the user wants to accomplish.

## Step 1: Determine the Objective

Identify the user's objective from their request. This determines which lens to apply — the lens selection dramatically changes the output format and focus areas.

| Objective | Lens | User Signals |
|-----------|------|-------------|
| Language or framework migration | `migration-lens` | "rewrite in", "port to", "migrate from X to Y", "convert to" |
| Architectural restructuring | `architecture-lens` | "hexagonal", "CQRS", "clean architecture", "ports and adapters", "event sourcing", "modular monolith" |
| Service decomposition | `decomposition-lens` | "microservices", "break apart", "extract services", "service boundaries", "split the monolith" |
| Risk or due diligence | `risk-lens` | "due diligence", "audit", "risk assessment", "acquisition review", "compliance", "health check" |
| Documentation generation | `documentation-lens` | "document this", "onboarding guide", "explain this codebase", "architecture docs" |
| Test strategy | `test-strategy-lens` | "test plan", "test strategy", "what should I test", "characterization tests", "coverage" |
| Technical debt remediation | `debt-lens` | "technical debt", "code quality", "cleanup", "anti-patterns", "pay down debt" |
| General understanding | No additional lens | "what does this do", "analyze this", "understand this code" |

If the objective is ambiguous, ask the user — don't guess. Multiple objectives can use multiple lenses; they add fields without conflicting.

## Step 2: Run Archaeology

Invoke the **codebase-archaeologist** agent with:

1. **Core templates** — Always loaded. Read `references/templates/core.md`
2. **Lens templates** — Based on objective. Read `references/templates/{lens}-lens.md`
3. **Scope** — Which files, modules, or entry points to analyze

The archaeologist works iteratively through five layers, reporting each before moving to the next:

- **Layer 1: Structural Cartography** — entry points, call graph, module boundaries, dead code, shared state
- **Layer 2: Data Flow Tracing** — sources, transformations, sinks, lineage
- **Layer 3: Business Rule Extraction** — the critical layer; domain decisions encoded as logic
- **Layer 4: Dependency Mapping** — explicit, implicit, temporal, environmental
- **Layer 5: Risk and Complexity Assessment** — debt patterns, hidden complexity hotspots

The agent surfaces surprises immediately and asks for human input on low-confidence, high-blast-radius findings.

## Step 3: Review Archaeology Output

Before transformation planning, check:
- **KNOWN_UNKNOWNS** — are there gaps that matter for the objective?
- **LOW_CONFIDENCE** rules — are these clustered in critical areas?
- **LENS_SPECIFIC** section — does it answer the objective's questions?

If gaps are significant, run targeted re-analysis on specific areas rather than re-analyzing everything.

## Step 4: Plan the Transformation

If the objective requires changing the codebase (migration, restructuring, decomposition, debt remediation), invoke the **transformation-strategist** agent with:

1. **Transformation plan templates** — Read `references/templates/transformation-plan.md`
2. **Archaeology output** — All artifacts from Step 2
3. **Stated objective** — The user's target state

The strategist works through five phases:
1. Gap Analysis — validates archaeology completeness
2. Mapping Analysis — classifies every element (NATURAL_FIT, FORCED_FIT, RESISTS_MAPPING, INVARIANT, ELIMINATED)
3. Sequencing — determines execution order with stable interim states
4. Verification Strategy — behavioral parity tests derived from business rules
5. Risk Register — everything that could go wrong, with mitigations

For documentation or test strategy objectives, the archaeology output is often sufficient without a transformation plan.

## Template Reference

All templates are in `references/templates/`. Read the relevant template files before producing output.

| File | Purpose | When Used |
|------|---------|-----------|
| `core.md` | Business Rule, Data Flow, Dependency, Component Summary, Archaeology Report | Always |
| `migration-lens.md` | Type mapping, ecosystem mapping, precision audit | Language/framework migrations |
| `architecture-lens.md` | Bounded contexts, seam analysis, domain events | Architectural restructuring |
| `decomposition-lens.md` | Service candidates, distributed transactions, data ownership | Service extraction |
| `risk-lens.md` | Liability register, maintainability scorecard, key-person risk | Due diligence and audits |
| `documentation-lens.md` | System narratives, decision records, onboarding paths | Documentation generation |
| `test-strategy-lens.md` | Test case specs, coverage maps, execution plans | Test strategy development |
| `debt-lens.md` | Debt items, debt inventory, remediation roadmap | Technical debt remediation |
| `transformation-plan.md` | Gap analysis, element mapping, sequencing, verification, risk | Any transformation objective |

## Examples

### Language Migration
User: "We need to migrate this Python 2.7 service to Python 3.12"

1. Objective: **Language migration** → load `core.md` + `migration-lens.md`
2. Run codebase-archaeologist with migration lens
3. Review — focus on TYPE_MAPPING and PRECISION_AUDIT sections
4. Run transformation-strategist with migration objective
5. Deliver: Archaeology report + Transformation plan

### CQRS Restructuring
User: "We want to move our order service to CQRS with event sourcing"

1. Objective: **Architecture (CQRS-ES)** → load `core.md` + `architecture-lens.md`
2. Run codebase-archaeologist with architecture lens
3. Review — focus on READ_WRITE ratio, EVENT_CANDIDATES, SEAM_ANALYSIS
4. Run transformation-strategist with CQRS-ES objective
5. Deliver: Archaeology report + Transformation plan

### General Understanding
User: "I just inherited this codebase, help me understand it"

1. Objective: **General understanding** → load `core.md` + `documentation-lens.md`
2. Run codebase-archaeologist with documentation lens
3. Deliver: Archaeology report with narratives and onboarding path
4. No transformation plan needed unless user requests one

## Troubleshooting

**Archaeology taking too long:** Reduce scope. Analyze one module or entry point at a time rather than the entire codebase.

**Low confidence on critical rules:** Ask the user for domain context. Some rules cannot be understood from code alone — they require business knowledge.

**Lens doesn't fit:** If the objective evolves mid-analysis, switch lenses. Core templates are always present; only the additional lens fields change.

**Transformation plan has too many RESISTS_MAPPING:** This is information, not failure. High resistance means the target architecture requires significant redesign in those areas. Surface it honestly.
