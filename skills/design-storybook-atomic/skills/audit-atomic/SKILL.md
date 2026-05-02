---
name: audit-atomic
description: Systematically audit every atom in the design system for full Storybook documentation coverage, feature usage best practices, uniqueness (merging similar atoms when sound, deprecating old ones), design-token compliance, and accessibility. Produces a graded report per atom and a prioritized defect list. Invoke as `/design-storybook-atomic:audit-atomic` — optionally pass a path to scope the audit.
disable-model-invocation: true
argument-hint: "[path]"
arguments: scope_path
allowed-tools: Read, Grep, Glob, Bash, Agent
---

# Audit: Atomic Layer

You are running a systematic audit of every **atom** in the codebase. Atoms are the smallest indivisible UI building blocks — see the `atomic-design` skill for the level definition, and `story-coverage-checklist` for the rubric.

## Scope

Argument: `$scope_path` — defaults to `src/components/atoms/` if not provided. Other common paths: `packages/ui/src/atoms`, `app/components/atoms`.

If the project doesn't use a directory called `atoms/`, fall back to: any component directory containing components classified as atoms by the `component-cartographer` agent.

## Pipeline (run in this order)

### Phase 1 — Cartography (parallel-safe)

Spawn `component-cartographer` (one call) to inventory every atom. Output: a structured map of every atom with paths, props, exported variants, and any related stories / MDX files.

Don't proceed until you have the inventory. Print a one-line summary: "Inventoried N atoms across M directories."

### Phase 2 — Per-atom audit (parallel)

For each atom in the inventory, spawn `atomic-auditor` **in parallel** (multiple Agent calls in a single message). Each agent grades one atom against `story-coverage-checklist` and returns:

- coverage / quality / hygiene scores
- letter grade
- explicit list of missing stories
- explicit list of MDX gaps
- explicit list of token-compliance gaps
- explicit list of a11y defects
- recommended actions, ordered

Batch atom audits in groups of 6–8 to keep the parent context lean.

### Phase 3 — Cross-cutting analysis (parallel)

Three independent passes — spawn all three at once:

1. `component-deduplicator` (scoped to atoms only) — finds near-duplicates, scores similarity, proposes a canonical version + merge plan.
2. `design-token-enforcer` (scoped to atoms only) — finds hardcoded values across all atoms, groups by category (color/space/font/radius/shadow), proposes token refactors.
3. `accessibility-reviewer` (scoped to atoms only) — runs the manual-check matrix from the `accessibility-stories` skill, produces a defect list with WCAG references.

### Phase 4 — Synthesis

Produce the audit report. Use this exact structure:

```text
ATOMIC AUDIT — <scope path>
Date: <ISO date>

SUMMARY
  Atoms scanned        : <n>
  Ship-ready           : <n> (composite ≥ A and hygiene 100)
  Needs work (B/C)     : <n>
  Blocked (D/F or hygiene fail) : <n>
  Near-duplicate clusters       : <n>
  Hardcoded-value sites         : <n>
  A11y defects (Critical/High)  : <n>/<n>

PER-ATOM GRADES
  ✅ A   atoms/Button       coverage 95  quality 92  hygiene 100
  ✅ A   atoms/Icon         …
  ⚠️  C   atoms/Tag          coverage 82  quality 70  hygiene 100
  ❌ F   atoms/Avatar       coverage 60  quality 64  hygiene FAIL (hardcoded #3B82F6)
  …

DUPLICATE CLUSTERS
  Cluster 1 — "Tag-like atoms" (similarity 0.91)
    members: atoms/Tag, atoms/Pill, atoms/Chip
    proposed canonical: atoms/Tag with variant: 'tag' | 'pill' | 'chip'
    migration plan: …

DEPRECATED / UNUSED
  atoms/OldButton — last modified 2023, no imports found, marked @deprecated → propose deletion
  atoms/Spinner.legacy.tsx — duplicated by atoms/Spinner → propose deletion

TOKEN GAPS
  47 hardcoded color literals across 12 atoms
  18 hardcoded spacing literals across 9 atoms
  Top offenders: atoms/Avatar (12), atoms/Tag (9), atoms/Skeleton (7)
  Refactor plan in: design-token-enforcer report (see appendix)

ACCESSIBILITY DEFECTS
  Critical (block merge):
    - atoms/IconButton: missing accessible name (no aria-label, no children text)
    - atoms/Switch: aria-checked not synced with controlled value
  High:
    - atoms/Input: no visible focus ring at WCAG 2.2 contrast
  …

PRIORITIZED ACTION PLAN
  Block 1 — Hygiene blockers (must fix before any merge):
    1. Replace 47 hardcoded colors with semantic tokens (design-token-enforcer can apply)
    2. Fix critical a11y defects (accessibility-reviewer)
  Block 2 — Coverage / quality work:
    3. Add missing stories per atom (graded list above)
    4. Add MDX docs for atoms with quality < 80
  Block 3 — Consolidation:
    5. Merge Tag/Pill/Chip cluster
    6. Delete deprecated atoms (Block, OldButton, Spinner.legacy)

NEXT
  - Apply Block 1 automatically?  ask user
  - Run /design-storybook-atomic:merge-duplicates for Block 3?  ask user
```

## Operating rules

1. **Do not write or edit any source file in this skill.** Only read, grep, and delegate to subagents. Subagents may write only after explicit user approval at Phase 4.
2. **Be exhaustive on atoms.** Every atom in the inventory gets a grade — no sampling.
3. **Quote evidence.** Every defect cites `path:line` so the user can jump straight to it.
4. **Never silently downgrade rubrics.** If `.storybook-atomic.yml` exists, surface its overrides at the top of the report so the grade is reproducible.
5. **Stay parallel where safe.** Cartography is sequential; per-atom audits and the three cross-cutting passes are parallel.
6. **Ask before destructive actions.** Deletion of "deprecated" atoms requires explicit user OK with the file paths printed.

## Failure modes

- **Atoms folder doesn't exist.** Ask the user where atoms live. Don't guess.
- **No stories exist at all.** Report it loudly; the audit becomes a "what to start with" plan.
- **Cartographer can't classify a component.** List it under `UNCLASSIFIED` so the user can decide.
- **Subagent times out.** Retry the single atom with the same agent; if it fails twice, mark it `INCOMPLETE` and continue.

## Memory

After completing, append a one-line summary to `.claude/agent-memory/audit-atomic/history.log` with date, scope, counts, and composite-grade distribution. Subsequent audits can compare deltas.
