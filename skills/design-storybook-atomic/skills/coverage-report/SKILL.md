---
name: coverage-report
description: Generate a comprehensive design-system coverage matrix — every component × every required story type × MDX sections × a11y artifacts. Produces a single Markdown report (and optionally an HTML visualization) graded by `story-coverage-checklist`. Use as the executive snapshot of the design system's health. Invoke as `/design-storybook-atomic:coverage-report`.
disable-model-invocation: true
argument-hint: "[--html] [path]"
arguments: flag scope_path
allowed-tools: Read, Grep, Glob, Bash, Agent, Write
---

# Coverage Report

You are producing the design system's **coverage report** — the bird's-eye view: every component, every required story, every MDX section, every a11y artifact, all graded.

Arguments:
- `$flag` — `--html` to also write an interactive HTML report; otherwise Markdown only.
- `$scope_path` — defaults to `src/components/`.

## Pipeline

### Phase 1 — Inventory

Spawn `component-cartographer`. Inventory every component, classified by atomic level.

### Phase 2 — Coverage analysis (parallel, batched 6–8)

Spawn `storybook-coverage-analyst` per atomic level. Each one:

- For every component at that level, builds the coverage matrix row:
  - Required stories present / missing (per `story-coverage-checklist`).
  - MDX sections present / missing.
  - A11y artifacts (Focus, Keyboard, RTL, etc.).
  - Token compliance score.
  - File-level / story-level / MDX / a11y quality scores.
- Returns a structured grade per component.

### Phase 3 — Synthesis

Build the matrix. Format:

```text
DESIGN SYSTEM COVERAGE — <scope path>
Generated: <ISO date>

OVERALL
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

ATOMS — coverage matrix
  Component   Default  Variants  Sizes  Disabled  Loading  WithIcon  LongText  RTL  Focus  MDX  A11y  Token  Composite
  Button         ✅       3/3      3/3     ✅       ✅        ✅        ❌      ✅    ✅    ✅    ✅    100        A (94)
  Icon           ✅       —        —       —        —         —          —      ✅    —     ✅    ✅    100        A (96)
  Avatar         ✅       2/3      —       ✅       ✅        ✅        ✅      ❌    ✅    ❌    ⚠️    72         C (74)
  Tag            ✅       3/4      —       —        —         ❌        ✅      ❌    —     ❌    ✅    100        C (76)
  …

MOLECULES — coverage matrix
  …

ORGANISMS — coverage matrix
  Component        Default  Empty  Loading  Error  Partial  LongData  Roles  Keyboard  MDX-Data  Token  Composite
  UserTable           ✅      ❌     ✅       ❌     ✅       ✅        ✅      ✅        ❌         85    F (54)
  CommentThread       ✅      ✅     ❌       ✅     —        ✅        —       ✅        ✅         100   B (86)
  …

TOP RISKS
  1. 16 components blocked (D/F). Half are organisms missing Empty/Loading/Error.
  2. 12 hygiene fails — 9 of those are hardcoded color literals. Run /design-storybook-atomic:audit-tokens.
  3. 4 candidate duplicate clusters detected. Run /design-storybook-atomic:merge-duplicates.
  4. 3 organisms call useNavigate() — domain coupling violation.

QUICK WINS (high coverage gain per hour)
  - Add Empty + Loading + Error stories to UserTable, OrderHistory, CommentList — gains 3 components from F→B.
  - Generate MDX for atoms/Avatar, atoms/Tag, atoms/Skeleton — gains 3 atoms from C→A.
  - Replace 47 hardcoded colors via design-token-enforcer — clears 9 hygiene fails.

NEXT
  - Run /design-storybook-atomic:audit-organisms to deep-dive the blocked organisms.
  - Run /design-storybook-atomic:audit-tokens to triage hygiene fails.
  - Run /design-storybook-atomic:merge-duplicates to surface duplicate clusters.
```

Write the report to `docs/design-system-coverage-<ISO date>.md`.

### Phase 4 — HTML visualization (optional, `--html`)

If `$flag` is `--html`, also generate `docs/design-system-coverage-<ISO date>.html` with:

- A header showing overall stats.
- A heatmap per atomic level (component × story-type, green / yellow / red cells).
- A sortable table per level.
- A treemap of "lines of risk" (blocked components by atomic level).
- Click-throughs to file paths via `vscode://file/...` links.

Use a single self-contained HTML (inline styles + vanilla JS, no build step). Pattern after `analysis-codebase-archaeology`'s HTML reports.

## Operating rules

1. **No writes outside `docs/`.** This is a report, not a refactor. Never edit components.
2. **Reproducibility.** Surface `.storybook-atomic.yml` overrides at the top of the report so the grade is reproducible.
3. **Time-snapshot the report.** Date in the filename, never overwrite. Diffing reports over time is the most useful coverage signal.
4. **Cross-link to the audit workflows.** Each "TOP RISK" should point to the specific workflow that triages it.
5. **Quick wins matter.** A coverage report that doesn't tell the team where to focus is just a wall of red. Always include a Quick Wins section.

## Failure modes

- **Inventory empty.** Either the scope path is wrong or no `*.stories.*` files exist. Report it loudly: "No stories found — the design system has zero Storybook coverage."
- **Massive variance** between expected and detected atomic levels (folder says `atoms/Button` but the cartographer thinks it's a molecule). Flag every mismatch in a TOP RISKS subsection.
- **Stale `.storybook-atomic.yml`.** A weights override that doesn't match current taxonomy (e.g. references a level that no longer exists). Warn but proceed with defaults for unknown keys.

## Memory

Append a summary line to `.claude/agent-memory/coverage-report/history.log` with date and overall grade distribution. Subsequent runs can show deltas.
