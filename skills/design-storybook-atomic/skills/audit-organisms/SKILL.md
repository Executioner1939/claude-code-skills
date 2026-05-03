---
name: audit-organisms
description: Systematically audit every organism. Same rigor as molecule audit, plus mandatory Empty/Loading/Error story coverage, mandatory data-contract MDX section, organism-table-must-accept-Table-instance enforcement, organism-list-must-consume-DB-collection-or-Query enforcement, no-routing-coupling rule (organisms emit events; pages route), domain-state-management discipline (organisms may own state but cleanly), end-to-end keyboard-flow `play` test. Library-policy + token + a11y cross-cutting passes. Tier-1 baseline (`<scope>/.design-storybook-atomic/baseline-organisms.md`) + Tier-2 dated history. Inter-agent HANDOFF contract. Invoke as `/design-storybook-atomic:audit-organisms`.
disable-model-invocation: true
argument-hint: "[path]"
arguments: scope_path
allowed-tools: Read, Grep, Glob, Bash, Agent, Write
---

# Audit: Organisms

Same shape as `audit-molecules`. Differences are scoped to the organism rubric.

Argument: `$scope_path` — defaults to `src/components/organisms/`.

## Step 0 — Load context + baseline

Same. Baseline at `<scope>/.design-storybook-atomic/baseline-organisms.md`.

## Step 1 — Cartography

Spawn `component-cartographer`. Extra metadata: composed-molecules list, data-fetching detection (any `useQuery` / `useLiveQuery` / `useEffect + fetch`), routing coupling (any `useNavigate` / `useRouter` / `useLocation`), table-shape detection (renders `<table>` or wraps `<DataTable>`), list-shape detection (renders mapped collection).

HANDOFF.md: `<scope>/.design-storybook-atomic/handoffs/audit-organisms-<run>/phase-01-cartographer-to-auditors.md`.

## Step 2 — Per-organism audit (parallel, batched 4–6)

`atomic-auditor` with **organism rubric**.

**Mandatory stories (each missing = blocker):**
- `Empty` — gracefully renders no-data; announces emptiness to screen readers.
- `Loading` — `aria-busy="true"` or live-region "Loading…" announcement.
- `Error` — `role="alert"` or equivalent + recovery affordance.

**Required additional stories:**
- `Default` (with realistic data — fixtures preferred over Lorem)
- `Partial` (some-but-not-all data — robustness)
- `LongData` / `ManyItems` (stress test)
- One per state-machine state (if applicable)
- One per role / permission (if applicable)
- `KeyboardOperated` `play` — primary task with keyboard only.

**Additional structural checks:**
- **Data contract documented**: organism's MDX has a "Data contract" table (props × shape × required × notes).
- **State management discipline**: organism owns state cleanly; no prop-drilling artifacts (`setX` reaching into atoms).
- **No routing**: organisms must not call `useNavigate` / `useRouter`. They emit events; pages route. Flag violations (hygiene fail).
- **TanStack-Table contract** (table-shaped organisms only): accepts a `Table` instance, not raw `data + columns`.
- **TanStack-DB / Query contract** (list-shaped organisms with fetched data): consumes a DB collection (preferred) or a Query result. No `useState([])` for fetched data (hygiene fail).

## Step 3 — Cross-cutting (parallel — four agents)

Same four as `audit-atomic`/`audit-molecules`:

1. `component-deduplicator` (scoped to organisms)
2. `design-token-enforcer` (mode `scan`, scoped to organisms)
3. `accessibility-reviewer` (scoped to organisms)
4. `library-policy-enforcer` (mode `audit-imports + audit-integrations`)

All four write HANDOFF.md.

Additional pass: spawn `storybook-coverage-analyst` for the organism-specific coverage matrix (component × story-type × MDX section).

## Step 4 — Composition-down audit

For every organism, list the molecules and atoms it composes. Verify:
- No level-skipping (organism going straight to atoms when a molecule wrapper exists).
- No duplicated logic vs another organism (e.g. two table-like organisms each building their own pagination).

HANDOFF.md: `<scope>/.design-storybook-atomic/handoffs/audit-organisms-<run>/phase-04-composition-down.md`.

## Step 5 — Synthesis

9-section report:

```text
ORGANISMS AUDIT — <scope>
Date     : <ISO 8601>
Run-id   : <run-id>
Baseline : present | not present

SECTION 1 — SUMMARY
  Organisms scanned             : <n>
  Ship-ready / Solid / Needs work / Blocked.
  Missing E/L/E story sets      : <n>  (block-merge per organism)
  Routing-coupled organisms     : <n>
  Direct-atom-imports (skipped molecule layer) : <n>
  Data-contract MDX missing     : <n>
  TanStack Table violations     : <n>
  TanStack DB/Query violations  : <n>
  A11y defects (Critical/High)  : <n>/<n>

SECTION 2 — PER-ORGANISM GRADES
  ❌ F   organisms/UserTable        no Empty story, no Error story, calls useNavigate()
  ⚠️  C   organisms/CommentThread   missing Loading story, hardcoded #1F2937 in 3 places
  ✅ A   organisms/Header
  …

SECTION 3 — EMPTY/LOADING/ERROR COMPLETENESS MATRIX
  Component         Empty  Loading  Error
  UserTable         ❌     ✅      ❌
  CommentThread     ✅     ❌      ✅
  ProductCard       ✅     ✅      ✅
  …

SECTION 4 — DATA CONTRACTS
  Documented (MDX): UserTable, ProductCard
  Missing         : CommentThread, Header, FilterPanel, …

SECTION 5 — ROUTING / DOMAIN VIOLATIONS
  organisms/UserTable/UserTable.tsx:47 calls useNavigate()
    → fix: emit onSelect event; lift navigation to caller (page).
  organisms/CommentThread/CommentThread.tsx:12 imports `@/api/comments`
    → fix: receive data via props (or via a TanStack DB collection / Query result).

SECTION 6 — TANSTACK-CONTRACT VIOLATIONS
  Table-shape:
    organisms/UserTable/UserTable.tsx
      currently: takes data: User[] + columns: ColumnDef<User>[]
      → fix: accept a TanStack Table `table` instance; lift useReactTable to caller.

  List-shape:
    organisms/CommentThread/CommentThread.tsx
      uses useState([]) + useEffect + fetch
      → fix: consume a TanStack DB collection (preferred) or a useQuery result.

SECTION 7 — ACCESSIBILITY DEFECTS
  Critical:
    UserTable: no Empty announcement (aria-busy or role="status").
    CommentThread: focus management on new-message scroll-into-view incorrect.
  High:
    Modal: focus trap escapes on Tab from last focusable.
  …

SECTION 8 — PRIORITIZED ACTION PLAN
  Block 1 — Block-merge fixes:
    1. Add Empty + Error stories to UserTable.
    2. Decouple useNavigate from UserTable; emit onSelect event.
    3. Refactor UserTable to accept Table instance.
    4. Refactor CommentThread to consume TanStack DB / Query.
  Block 2 — Coverage:
    5. Add KeyboardOperated play stories to ProductCard, FilterPanel.
  Block 3 — Documentation:
    6. Add Data contract MDX section for 5 organisms.

SECTION 9 — DIFF VS BASELINE  (only if baseline existed)

NEXT
  - Apply Block 1 auto-fixes (where unambiguous)?
  - Save as new baseline?
```

## Step 6 — Write outputs

- Baseline: `<scope>/.design-storybook-atomic/baseline-organisms.md`
- Dated history: `<scope>/.design-storybook-atomic/history/organisms-<YYYY-MM-DD>.md`

## Operating rules

Same as `audit-molecules`. Plus:

- **Empty/Loading/Error are non-negotiable.** Any organism missing one is BLOCKED.
- **Routing in organisms is forbidden.** Hygiene fail.
- **Data fetching is allowed only at the organism level, not below.** Grep for fetch usage in atoms/molecules separately and flag.
- **Direct-atom imports** (skipping the molecule layer): flag, recommend extracting molecules.
- **HANDOFF contract** — every subagent prints `HANDOFF: <path>`.

## Failure modes

- **No organism directory exists** — common when teams skip this level. Surface as a top finding: codebase has no organism layer; pages do organism work; recommend extracting organisms.

## Memory

`.claude/agent-memory/audit-organisms/history.log`.
