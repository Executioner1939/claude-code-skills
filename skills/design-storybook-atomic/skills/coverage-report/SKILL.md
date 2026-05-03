---
name: coverage-report
description: Generate the design system's coverage matrix — every component × every required story type × MDX sections × a11y artifacts × token compliance × TanStack-integration contract × library-policy compliance. Per `story-coverage-checklist` rubric. Markdown report; optional `--html` for an interactive heat-map. Tier-1 baseline (`<scope>/.design-storybook-atomic/baseline-coverage.md`) + Tier-2 dated history. Inter-agent HANDOFF contract. Invoke as `/design-storybook-atomic:coverage-report`.
disable-model-invocation: true
argument-hint: "[--html] [path]"
arguments: flag scope_path
allowed-tools: Read, Grep, Glob, Bash, Agent, Write
---

# Coverage Report

Bird's-eye snapshot. Every component, every required story, every MDX section, every a11y artifact, every TanStack contract, every library-policy check — all graded.

Arguments:
- `$flag` — `--html` to additionally write an interactive HTML report.
- `$scope_path` — defaults to `src/components/`.

## Step 0 — Load context + baseline

Read `story-coverage-checklist` (rubric), `tanstack-integration` (contract), `approved-libraries` (policy), `<scope>/.design-storybook-atomic.yml`. Check baseline at `<scope>/.design-storybook-atomic/baseline-coverage.md`.

## Step 1 — Inventory

Spawn `component-cartographer`. HANDOFF: `<scope>/.design-storybook-atomic/handoffs/coverage-report-<run>/phase-01-cartography-to-analysts.md`.

## Step 2 — Per-level coverage analysis (parallel)

Spawn `storybook-coverage-analyst` per atomic level. Each one:

- Builds the coverage matrix row per component (required stories present / missing per `story-coverage-checklist`; MDX sections present / missing; a11y artifacts).
- Derives the file-level / story-level / MDX / a11y quality scores.
- Grades the TanStack-integration compliance per the level's contract.
- Calculates the token-compliance score.
- Combines the above into a composite + letter grade.

HANDOFF: `<scope>/.design-storybook-atomic/handoffs/coverage-report-<run>/phase-02-analysts-to-orchestrator.md`.

## Step 3 — Library-policy snapshot (parallel with Step 2)

Spawn `library-policy-enforcer` (mode `default`) for the dependency + import + integration overview. Provides the project-wide policy compliance score.

HANDOFF: `<scope>/.design-storybook-atomic/handoffs/coverage-report-<run>/phase-03-policy-to-orchestrator.md`.

## Step 4 — Synthesis

Build the report:

```text
DESIGN SYSTEM COVERAGE — <scope>
Date     : <ISO 8601>
Run-id   : <run-id>
Baseline : present | not present

SECTION 1 — OVERALL
  Components       : 87 (24 atoms, 31 molecules, 22 organisms, 7 templates, 3 pages)
  Ship-ready (A)   : 19 (22%)
  Solid (B)        : 28 (32%)
  Needs work (C)   : 24 (28%)
  Blocked (D/F)    : 16 (18%)
  Hygiene fails    : 12

  Composite distribution:
    A ████████████ 19
    B ████████████████████████████ 28
    C █████████████████████████ 24
    D ██████ 8
    F ████████ 8

SECTION 2 — ATOMS COVERAGE MATRIX
  Component   Default  Variants  Sizes  Disabled  Loading  WithIcon  LongText  RTL  Focus  Field-Friendly  forwardRef  MDX  A11y  Token  Composite
  Button         ✅       3/3      3/3     ✅       ✅        ✅        ❌      ✅    ✅       ✅              ✅          ✅    ✅    100        A (94)
  Icon           ✅       —        —       —        —         —          —      ✅    —        n/a             ✅          ✅    ✅    100        A (96)
  Avatar         ✅       2/3      —       ✅       ✅        ✅        ✅      ❌    ✅       n/a             ✅          ❌    ⚠️    72         C (74)
  Switch         ✅       —        —       ✅       —         —          —      ✅    ✅       ✅              ❌          ✅    ✅    100        F (88, hygiene FAIL — no forwardRef)
  …

SECTION 3 — MOLECULES COVERAGE MATRIX
  Component   Default  States  Interaction  KeyboardFlow  Field-Wraps  Composition-Clean  No-Domain-State  …  Composite
  …

SECTION 4 — ORGANISMS COVERAGE MATRIX
  Component        Default  Empty  Loading  Error  Partial  LongData  Roles  Keyboard  MDX-Data  Table-Instance  DB-Collection  Token  Composite
  UserTable           ✅      ❌     ✅       ❌     ✅       ✅        ✅      ✅        ❌         ❌              n/a             85    F (54, missing E/L/E)
  CommentThread       ✅      ✅     ❌       ✅     —        ✅        —       ✅        ✅         n/a             ❌              100   B (86)
  …

SECTION 5 — TEMPLATES + PAGES COVERAGE MATRIX
  …

SECTION 6 — TANSTACK ADOPTION HEATMAP
  Form integration       : 12/15 forms ✅ TanStack Form ; 3 RHF ❌
  Table integration      : 4/4 tables  ✅ TanStack Table
  Server-state           : 100% TanStack Query ✅
  DB collections (lists) : 5/16 ✅
  UI store               : TanStack Store ✅
  Pacer (debounce)       : 0/3 ❌ (3 lodash sites)
  Day.js                 : 0/17 ❌ (17 moment.js sites)

SECTION 7 — TOP RISKS
  1. 16 components blocked (D/F). Half are organisms missing Empty/Loading/Error.
  2. 12 hygiene fails — 9 are hardcoded color literals. → /design-storybook-atomic:audit-tokens
  3. 4 candidate duplicate clusters detected. → /design-storybook-atomic:merge-duplicates
  4. 3 organisms call useNavigate() — domain coupling violation.
  5. Library-policy compliance: 71/100 (BLOCKED). → /design-storybook-atomic:audit-libraries

SECTION 8 — QUICK WINS (high coverage gain per hour)
  - Add Empty + Loading + Error stories to UserTable, OrderHistory, CommentList — 3 components from F → B.
  - Generate MDX for atoms/Avatar, atoms/Tag, atoms/Skeleton — 3 atoms from C → A.
  - Replace 47 hardcoded colors via design-token-enforcer — clears 9 hygiene fails.
  - Codemod 17 moment imports → dayjs.
  - Refactor Switch atom to add forwardRef — clears hygiene fail.

SECTION 9 — DIFF VS BASELINE  (only if baseline existed)
  Δ ship-ready : +2
  Δ blocked    : −3
  Improved since baseline:
    - atoms/Avatar: F → B (token cleanup)
    - organisms/UserTable: F → C (added Loading story)
  Regressed:
    - molecules/SearchBar: B → C (lost MDX during refactor)
  New components: 4
  Removed: 1 (deprecated atoms/Spinner.legacy deleted)

NEXT
  - /design-storybook-atomic:audit-organisms (deep-dive blocked organisms)
  - /design-storybook-atomic:audit-tokens (clear hygiene fails)
  - /design-storybook-atomic:audit-libraries (clear policy gaps)
  - /design-storybook-atomic:merge-duplicates (consolidate 4 clusters)
  - Save this report as new baseline?  yes (default)
```

Write the report to `<scope>/docs/design-system-coverage-<YYYY-MM-DD>.md`.

## Step 5 — HTML visualization (optional, `--html`)

If `$flag` is `--html`, also write `<scope>/docs/design-system-coverage-<YYYY-MM-DD>.html`:
- Header with overall stats.
- Heatmap per atomic level (component × story-type × hygiene cell, green / yellow / red).
- Sortable table per level with click-throughs to file paths via `vscode://file/...` links.
- Treemap of "lines of risk" — blocked components by atomic level.

Pattern after `analysis-codebase-archaeology`'s self-contained HTML reports — inline styles + vanilla JS, no build step.

## Step 6 — Write outputs

- Baseline (replaces previous): `<scope>/.design-storybook-atomic/baseline-coverage.md`
- Dated history: `<scope>/.design-storybook-atomic/history/coverage-<YYYY-MM-DD>.md`
- Markdown report: `<scope>/docs/design-system-coverage-<YYYY-MM-DD>.md`
- HTML report (if `--html`): `<scope>/docs/design-system-coverage-<YYYY-MM-DD>.html`

## Operating rules

1. **No edits to component code.** This is a report.
2. **Reproducibility.** Surface `.design-storybook-atomic.yml` overrides at the top of the report.
3. **Time-snapshot the report.** Date in filenames; never overwrite. Diffing reports over time is the most useful coverage signal.
4. **Cross-link to triage workflows.** Each TOP RISK points to the workflow that addresses it.
5. **Quick Wins matter.** A coverage report that doesn't tell the team where to focus is just a wall of red.
6. **HANDOFF contract** — every subagent prints `HANDOFF: <path>`.

## Failure modes

- **Inventory empty.** Either scope path wrong or no `*.stories.*` files exist. Report it loudly: "No stories found — the design system has zero Storybook coverage."
- **Massive variance** between expected and detected atomic levels (folder says `atoms/Button` but cartographer thinks it's a molecule). Flag every mismatch in TOP RISKS.
- **Stale `.design-storybook-atomic.yml`** (override references a level that no longer exists). Warn but proceed with defaults for unknown keys.

## Memory

`.claude/agent-memory/coverage-report/history.log`.
