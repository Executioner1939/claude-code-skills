---
name: codebase-archaeology
description: >
  Methodology and templates for systematic codebase archaeology -- the
  reverse-engineering reference loaded by the codebase-archaeologist and
  transformation-strategist agents. Provides the lens-selection table, the
  five-layer analysis model, the five-phase planning framework, and the
  template inventory. Auto-loaded into the two agents via their `skills:`
  frontmatter. The procedural workflow that drives these agents lives in the
  /analysis-codebase-archaeology:archaeology slash command -- read this skill
  alongside the agent system prompt; do not invoke this skill directly to
  start an analysis.
---

# Codebase Archaeology -- Methodology Reference

This skill is **methodology and templates only**. Three audiences read it:

1. The `codebase-archaeologist` agent (auto-loaded via its `skills:` frontmatter).
2. The `transformation-strategist` agent (same).
3. The `analysis-codebase-archaeology:archaeology` slash command, which reads this file to look up lens names and template paths when constructing agent envelopes.

If you are a human trying to run an analysis, run the slash command -- not this skill.

## Lens selection

Every archaeology run picks one or more lenses. The lens determines which template the archaeologist reads in addition to `core.md`. Multiple lenses compose; they add fields without conflicting.

| Objective | Lens name | Trigger phrases |
|---|---|---|
| Language or framework migration | `migration-lens` | "rewrite in", "port to", "migrate from X to Y", "convert to" |
| Architectural restructuring | `architecture-lens` | "hexagonal", "CQRS", "clean architecture", "ports and adapters", "event sourcing", "modular monolith" |
| Service decomposition | `decomposition-lens` | "microservices", "break apart", "extract services", "service boundaries", "split the monolith" |
| Risk or due diligence | `risk-lens` | "due diligence", "audit", "risk assessment", "acquisition review", "compliance", "health check" |
| Documentation generation | `documentation-lens` | "document this", "onboarding guide", "explain this codebase", "architecture docs" |
| Test strategy | `test-strategy-lens` | "test plan", "test strategy", "what should I test", "characterization tests", "coverage" |
| Technical debt remediation | `debt-lens` | "technical debt", "code quality", "cleanup", "anti-patterns", "pay down debt" |
| General understanding | (none -- core only) | "what does this do", "analyze this", "understand this code" |

When the calling envelope does not pass a `lenses_to_apply` value, ask the calling user once with these eight options. Do not guess.

## Five-layer analysis model (codebase-archaeologist)

The archaeologist's system prompt details each layer. This table is the canonical naming so the strategist and the index command can refer to layer numbers unambiguously.

| Layer | Name | Output |
|---|---|---|
| 1 | Structural Cartography | entry points, call graph, module boundaries, dead code, shared mutable state |
| 2 | Data Flow Tracing | sources, transformations, intermediate state, sinks, lineage |
| 3 | Business Rule Extraction | catalog of `BUSINESS RULE` template instances |
| 4 | Dependency Mapping | `DEPENDENCY` template instances with HARD / SOFT / CONVENTIONAL coupling |
| 5 | Risk and Complexity Assessment | risk scores, debt patterns, hotspots |

## Five-phase planning framework (transformation-strategist)

| Phase | Name | Output |
|---|---|---|
| 1 | Gap Analysis | validates the archaeology is sufficient for the objective; halts if not |
| 2 | Mapping Analysis | classifies elements: `NATURAL_FIT`, `FORCED_FIT`, `RESISTS_MAPPING`, `INVARIANT`, `ELIMINATED` |
| 3 | Sequencing | execution order with stable, deployable interim states per phase |
| 4 | Verification Strategy | behavioral parity tests derived from archaeology `RULE_ID`s |
| 5 | Risk Register | per-risk: trigger, impact, mitigation, detection, contingency |

## Template inventory

All templates live at `${CLAUDE_PLUGIN_ROOT}/skills/codebase-archaeology/references/templates/`. Read on demand -- do not preload the full set.

| File | Purpose | Loaded when |
|---|---|---|
| `core.md` | `BUSINESS RULE`, `DATA FLOW`, `DEPENDENCY`, `COMPONENT SUMMARY`, `ARCHAEOLOGY REPORT` | every archaeology run |
| `migration-lens.md` | `TYPE_MAPPING`, `ECOSYSTEM_MAPPING`, `PRECISION_AUDIT` | language / framework migration |
| `architecture-lens.md` | `BOUNDED_CONTEXTS`, `SEAM_ANALYSIS`, `DOMAIN_EVENT_CANDIDATES` | architectural restructuring |
| `decomposition-lens.md` | `SERVICE_CANDIDATES`, `DATA_OWNERSHIP`, `DISTRIBUTED_TRANSACTIONS` | service decomposition |
| `risk-lens.md` | `LIABILITY_REGISTER`, `MAINTAINABILITY_SCORECARD`, `KEY_PERSON_RISK` | due diligence / audit / compliance |
| `documentation-lens.md` | `SYSTEM_NARRATIVES`, `DECISION_RECORDS`, `ONBOARDING_PATHS` | documentation objective |
| `test-strategy-lens.md` | `TEST_CASE_SPECS`, `COVERAGE_MAPS`, `EXECUTION_PLANS` | test strategy objective |
| `debt-lens.md` | `DEBT_ITEMS`, `DEBT_INVENTORY`, `REMEDIATION_ROADMAP` | technical debt objective |
| `transformation-plan.md` | `GAP_ANALYSIS`, `MAPPING_ANALYSIS`, `SEQUENCING`, `VERIFICATION_STRATEGY`, `RISK_REGISTER` | every transformation-strategist run |

## Output discipline (shared across both agents)

- Every claim cites `file:line`. Unanchored claims are unreliable.
- Every finding has `CONFIDENCE: HIGH | MEDIUM | LOW` with justification.
- `KNOWN_UNKNOWNS` is first-class output, never hidden.
- `LOW_CONFIDENCE` findings cluster into their own sub-section so the human can scan them.
- `"N/A -- [reason]"` is preferred over silent omission of a layer or section.
- `DECISIONS_REQUIRED` are surfaced to the human; agents never choose on the user's behalf.

## Memory hooks

Both agents declare a `Stop` hook that appends an activity line to `.claude/agent-memory/<agent-name>/activity.log`. Useful for cross-session continuity and for the slash command's final index to cite recent runs.
