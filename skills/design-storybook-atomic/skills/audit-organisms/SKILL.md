---
name: audit-organisms
description: Systematically audit every organism. Same rigor as molecule audit, plus mandatory empty/loading/error coverage, data-contract documentation, role/permission stories, and end-to-end keyboard-flow tests. Produces a graded report with refactor / split / merge recommendations. Invoke as `/design-storybook-atomic:audit-organisms`.
disable-model-invocation: true
argument-hint: "[path]"
arguments: scope_path
allowed-tools: Read, Grep, Glob, Bash, Agent
---

# Audit: Organisms

You are auditing every **organism**. Organisms are recognizable, standalone sections of an interface composed of molecules and/or atoms. See `atomic-design` for the level boundaries.

Argument: `$scope_path` — defaults to `src/components/organisms/`.

## Pipeline

Same shape as `audit-molecules`, with additions:

### Phase 2 — Per-organism audit (parallel, batched 4–6)

`atomic-auditor` per organism, using the **organism rubric**:

**Mandatory stories** (all three are blockers):
- `Empty` — must render gracefully with no data and announce emptiness to screen readers.
- `Loading` — must render with `aria-busy="true"` or live-region "Loading…" announcement.
- `Error` — must render with `role="alert"` or equivalent and a recovery affordance.

**Required additional stories**:
- `Default` (with realistic data, ideally fixture-driven not Lorem)
- `Partial` (some data missing — robustness)
- `LongData` / `ManyItems` (stress test)
- One per state-machine state (if applicable)
- One per role / permission (if applicable)
- `KeyboardOperated` `play` — performs the primary task with keyboard only.

**Additional structural checks**:
- **Data contract documented**: organism's MDX must include a "Data contract" table listing required props, shape, required-ness.
- **State management discipline**: organism may own UI state and may call hooks/services, but should expose state-management boundaries clearly. No prop-drilling artifacts (e.g. props named `setX` reaching deep into atoms).
- **Error boundaries**: any organism that fetches data should be wrappable in an error boundary; verify by looking at usage.
- **Routing decoupled**: organisms should not call `useNavigate` / `useRouter` directly. They emit events; pages route. Flag violations.

### Phase 3 — Cross-cutting

Same three subagents as atom/molecule audits.

Additional pass: `storybook-coverage-analyst` runs the **full coverage matrix** for organisms (component × story-type) and reports cells that are missing at the organism layer specifically.

### Phase 4 — Composition-down audit

For every organism, list the molecules and atoms it composes. Verify:
- No level-skipping (organism going straight to atoms when a molecule wrapper exists).
- No duplicate logic vs another organism (e.g. two table-like organisms both building their own pagination).

### Phase 5 — Synthesis

```text
ORGANISMS AUDIT — <scope path>
Date: <ISO date>

SUMMARY
  Organisms scanned             : <n>
  Ship-ready                    : <n>
  Needs work                    : <n>
  Blocked (missing E/L/E)       : <n>
  Routing-coupled               : <n>
  Direct-atom-imports (skipped molecule layer) : <n>

PER-ORGANISM GRADES
  ❌ F   organisms/UserTable        no Empty story, no Error story, calls useNavigate()
  ⚠️  C   organisms/CommentThread   missing Loading story, hardcoded #1F2937 in 3 places
  ✅ A   organisms/Header           …

EMPTY/LOADING/ERROR COMPLETENESS MATRIX
  Component         Empty  Loading  Error
  UserTable         ❌     ✅      ❌
  CommentThread     ✅     ❌      ✅
  Header            n/a    n/a     n/a
  ProductCard       ✅     ✅      ✅

DATA CONTRACTS
  Documented (MDX): UserTable, ProductCard
  Missing         : CommentThread, Header, FilterPanel, …

ROUTING / DOMAIN VIOLATIONS
  organisms/UserTable calls useNavigate() at line 47
  organisms/CommentThread imports `@/api/comments`  ← should receive data via props
  …

KEYBOARD-FLOW TESTS
  Present: UserTable, CommentThread, Header
  Missing: ProductCard, FilterPanel, OrderSummary, …

PRIORITIZED ACTION PLAN
  Block 1 — Block-merge fixes (E/L/E + routing coupling):
    1. Add Empty + Error stories to UserTable
    2. Decouple useNavigate from UserTable; emit onSelect event
  Block 2 — Coverage:
    3. Add KeyboardOperated play stories to ProductCard, FilterPanel
  Block 3 — Documentation:
    4. Add Data contract MDX for 5 organisms
```

## Operating rules

- **Empty/Loading/Error are non-negotiable.** Any organism missing one is `BLOCKED`.
- **Routing in organisms is forbidden.** Organisms emit events; pages route.
- **Data fetching is allowed only at the organism level, not below.** Grep for fetch usage in atoms/molecules separately and flag.
- Subagents may write only with explicit approval.

## Failure modes

- **No organism directory exists** — common when teams skip this level. Report it as a finding: the codebase has no organism layer; everything jumped from molecules to pages, which means pages are doing organism work. Recommend extracting organisms.

## Memory

Append summary to `.claude/agent-memory/audit-organisms/history.log`.
