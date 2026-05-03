---
name: audit-atomic
description: Systematically audit every atom in the design system for full Storybook (CSF Factories) coverage, uniqueness (merging similar atoms when sound, deprecating old ones), design-token compliance, approved-libraries policy, TanStack-integration prop-shape contract (value-first onChange, forwardRef, aria wiring), and accessibility (WCAG 2.2 AA + WAI-ARIA APG). Produces a graded report per atom and a prioritized defect list. Tier-1 baseline diff (`<scope>/.design-storybook-atomic/baseline-atoms.md`) + Tier-2 dated history. Inter-agent HANDOFF.md contract. Invoke as `/design-storybook-atomic:audit-atomic` — optionally pass a path to scope the audit.
disable-model-invocation: true
argument-hint: "[path]"
arguments: scope_path
allowed-tools: Read, Grep, Glob, Bash, Agent, Write
---

# Audit: Atomic Layer

You are running a systematic audit of every **atom** in the codebase — Storybook coverage, uniqueness, design-token compliance, approved-libraries policy, TanStack-integration contract, accessibility.

Argument: `$scope_path` — defaults to `src/components/atoms/` (fallback search if absent).

## Step 0 — Load context + baseline

### 0a — References
Load `atomic-design`, `storybook-authoring`, `storybook-atomic-integration`, `story-coverage-checklist`, `design-tokens`, `approved-libraries`, `tanstack-integration`, `accessibility-stories`. (These are auto-preloaded into invoked subagents via their `skills:` frontmatter.)

### 0b — Project overrides
Read `<scope>/.design-storybook-atomic.yml` if present — surface any rubric overrides at the top of the report so grading is reproducible.

### 0c — Baseline check (audit history)
```bash
test -f "$scope_path/.design-storybook-atomic/baseline-atoms.md" \
  && echo "BASELINE: present" \
  || echo "BASELINE: not present (first run)"
```

If baseline exists, the synthesis report ends with **Section 9 — Diff vs baseline**. Otherwise the current report becomes the baseline.

## Step 1 — Cartography (single agent, sequential)

Spawn `component-cartographer` to inventory every atom.

The agent writes a HANDOFF.md to:

```
<scope>/.design-storybook-atomic/handoffs/audit-atomic-<run>/phase-01-cartographer-to-auditors.md
```

**Validation contract**: do not proceed until the agent prints `HANDOFF: <abs path>`. If the line is missing, halt and surface the gap to the user.

Print: `Inventoried <n> atoms across <m> directories.`

## Step 2 — Per-atom audit (parallel, batched 6–8)

For each atom in the inventory, spawn `atomic-auditor` **in parallel** (multiple Agent calls in a single message). Each agent grades one atom against `story-coverage-checklist` and the new TanStack-integration contract. Returns:

- coverage / quality / hygiene scores (per `story-coverage-checklist` rubric).
- letter grade.
- explicit list of missing stories.
- explicit list of MDX gaps.
- explicit list of token-compliance gaps.
- explicit list of TanStack-contract gaps (atom must accept value + onChange(v) + onBlur + aria + forwardRef).
- explicit list of a11y defects.
- recommended actions, ordered.

Each auditor writes its own per-atom HANDOFF.md (when chained — for parallel batch this is consolidated):

```
<scope>/.design-storybook-atomic/handoffs/audit-atomic-<run>/phase-02-auditor-batch-<k>-to-cross-cutting.md
```

Print one progress line per batch: `Batch <k>/<total> graded.`

## Step 3 — Cross-cutting passes (parallel, four agents at once)

Spawn four agents in parallel — they share the inventory but score different axes:

1. **`component-deduplicator`** (scope: atoms only) — finds near-duplicates, scores similarity, proposes a canonical version + merge plan.
2. **`design-token-enforcer`** (mode `scan`, scope: atoms only) — finds hardcoded values, proposes token refactors with HIGH / MEDIUM / LOW confidence.
3. **`accessibility-reviewer`** (scope: atoms only) — runs the manual-check matrix from `accessibility-stories` (focus management, keyboard model, target size, color independence, prefers-reduced-motion).
4. **`library-policy-enforcer`** (mode `audit-imports + audit-integrations`, scope: atoms only) — verifies the field-friendly atom contract; flags forbidden imports.

Each writes a HANDOFF.md to:

```
<scope>/.design-storybook-atomic/handoffs/audit-atomic-<run>/phase-03-<agent>-to-orchestrator.md
```

Wait for all four to print `HANDOFF: <path>` before proceeding.

## Step 4 — Synthesis

Build the audit report. Use this exact 9-section structure (mirrors `terraform-audit`):

```text
ATOMIC AUDIT — <scope path>
Date     : <ISO 8601>
Run-id   : <run-id>
Baseline : present | not present (first run)

SECTION 1 — SUMMARY
  Atoms scanned                  : <n>
  Ship-ready (A, hygiene 100)    : <n>
  Solid (B)                      : <n>
  Needs work (C)                 : <n>
  Blocked (D/F or hygiene fail)  : <n>
  Near-duplicate clusters        : <n>
  Hardcoded-value sites          : <n>
  TanStack-contract violations   : <n>
  Library-policy violations      : <n>
  A11y defects (Critical / High) : <n> / <n>

SECTION 2 — PER-ATOM GRADES (alphabetized)
  ✅ A   atoms/Button       coverage 95  quality 92  hygiene 100
  ⚠️  C   atoms/Tag          coverage 82  quality 70  hygiene 100
  ❌ F   atoms/Avatar       coverage 60  quality 64  hygiene FAIL (hardcoded #3B82F6)
  ❌ F   atoms/Switch       coverage 88  quality 85  hygiene FAIL (no forwardRef)
  …

SECTION 3 — DUPLICATE CLUSTERS
  (paste component-deduplicator output)

SECTION 4 — DEPRECATED / UNUSED
  atoms/OldButton — last modified 2023, no imports found, marked @deprecated
                    → propose deletion
  atoms/Spinner.legacy.tsx — duplicated by atoms/Spinner → propose deletion

SECTION 5 — TOKEN GAPS
  (paste design-token-enforcer output, summary + top offenders)

SECTION 6 — TANSTACK-CONTRACT VIOLATIONS
  Atom must accept value + onChange(value) + onBlur + aria-invalid + aria-describedby + forwardRef.
  Violations:
    [V1] atoms/Input/Input.tsx:18  — emits onChange(event) instead of onChange(value)
    [V2] atoms/Switch/Switch.tsx   — not forwarding refs
    [V3] atoms/Combobox/Combobox.tsx:34 — no aria-describedby plumbing
  (full list from library-policy-enforcer Section 3 above; cited verbatim here)

SECTION 7 — ACCESSIBILITY DEFECTS
  Critical (block merge):
    - atoms/IconButton: missing accessible name (no aria-label, no children text)
    - atoms/Switch: aria-checked not synced with controlled value
  High:
    - atoms/Input: visible focus indicator below 3:1 contrast
  Medium:
    - atoms/Toast: no prefers-reduced-motion guard
  …

SECTION 8 — PRIORITIZED ACTION PLAN
  Block 1 — Hygiene blockers (must fix before merge):
    1. Fix TanStack-contract violations (3 atoms — see Section 6).
    2. Replace 47 hardcoded colors with semantic tokens (design-token-enforcer can apply).
    3. Fix Critical a11y defects (accessibility-reviewer Block 1).
  Block 2 — Coverage / quality work:
    4. Add missing stories per atom (graded list in Section 2).
    5. Add MDX docs for atoms with quality < 80.
  Block 3 — Consolidation:
    6. Merge Tag/Pill/Chip cluster (Section 3).
    7. Delete deprecated atoms (Section 4).

SECTION 9 — DIFF VS BASELINE  (only if baseline existed)
  Δ overall                     : +5 atoms ship-ready (was 17, now 22)
  Improved since baseline:
    - atoms/Tag: C → A (added MDX, fixed token gap)
    - atoms/Avatar: F → B (replaced hardcoded color with token)
  Regressed:
    - atoms/Switch: A → F (forwardRef removed in commit abc123)
  New atoms since baseline:
    - atoms/Combobox (graded B; missing 2 stories)
  Removed atoms since baseline:
    - atoms/Spinner.legacy (deleted)

NEXT
  - Apply Block 1 auto-fixable items (token refactors)?  ask user
  - Walk through Block 2 (coverage gaps)?  ask user
  - Save this report as new baseline?  yes (default unless user opts out)
```

## Step 5 — Write outputs

After printing the report, **write** it to:

1. **Baseline (replaces previous)** — `<scope>/.design-storybook-atomic/baseline-atoms.md`
2. **Dated history (additive)** — `<scope>/.design-storybook-atomic/history/atoms-<YYYY-MM-DD>.md`

Both contain the synthesis report.

## Operating rules

1. **READ ONLY for source files; Write only for audit artifacts** (baseline + history + HANDOFF). No edits to component code.
2. **BE EXHAUSTIVE.** Every atom in the inventory gets a grade — no sampling.
3. **CITE EVERY DEFECT** — `path:line` in Sections 5, 6, 7.
4. **HONOR `.design-storybook-atomic.yml`** — surface overrides at the top so grading is reproducible.
5. **PARALLELIZE WHERE SAFE** — Step 1 sequential; Step 2 batched parallel; Step 3 four-way parallel.
6. **HANDOFF CONTRACT** — every subagent must write a HANDOFF.md and print `HANDOFF: <path>`. Halt if missing.
7. **NEVER SILENTLY OVERWRITE BASELINE** — ask the user before saving on second-and-later runs.
8. **DESTRUCTIVE ACTIONS** — deletion of "deprecated" atoms requires explicit user approval with file paths printed.

## Failure modes

- **Atoms folder doesn't exist.** Fall back: ask the cartographer to discover atoms by signal (folder + structure), or ask the user.
- **No stories at all.** Report it loudly; the audit becomes a "where to start" plan.
- **Cartographer can't classify a component.** List under UNCLASSIFIED in Section 2.
- **Subagent times out.** Retry once; if it fails twice, mark the affected atoms `INCOMPLETE` and continue.
- **Missing HANDOFF line.** Halt. Re-spawn the agent with explicit instruction to write the HANDOFF.

## Memory

Append a one-liner to `.claude/agent-memory/audit-atomic/history.log`:

```
2026-05-03T17:42 audit-atomic scope=src/components/atoms run=20260503-1742 graded=24 A=12 B=6 C=4 F=2 hygiene_fail=3
```

Subsequent runs can compare deltas without re-reading baselines.
