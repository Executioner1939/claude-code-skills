---
name: audit-molecules
description: Systematically audit every molecule in the design system. Same rigor as the atomic audit, plus composition checks (atoms used correctly, no atom-importing-atom violations), interaction-test coverage, and state-transition coverage. Produces a graded report per molecule with merge / refactor / deprecation recommendations. Invoke as `/design-storybook-atomic:audit-molecules`.
disable-model-invocation: true
argument-hint: "[path]"
arguments: scope_path
allowed-tools: Read, Grep, Glob, Bash, Agent
---

# Audit: Molecules

You are auditing every **molecule** in the design system. Molecules are small, purposeful groupings of atoms — see `atomic-design` and `storybook-atomic-integration` for the rubric.

Argument: `$scope_path` — defaults to `src/components/molecules/`.

## Pipeline

Same shape as `audit-atomic`, with additions:

### Phase 1 — Cartography
Spawn `component-cartographer`. Inventory every molecule with: composed atoms, owned state (controlled / uncontrolled), interaction surface, related stories / MDX.

### Phase 2 — Per-molecule audit (parallel, batched 6–8)
Spawn `atomic-auditor` per molecule. The auditor uses the **molecule rubric** (different weights, including required `play` stories and `KeyboardFlow`).

Additional checks for molecules:
- **Composition correctness**: every atom in the molecule is imported from the `atoms/` directory. No molecule imports another molecule (composition violation — flag it).
- **No domain state**: molecules must not read from a global store (Redux / Zustand / Pinia / Recoil). Grep for store usage; flag.
- **At least one interaction `play` story**: required.
- **Error-state announcements**: if the molecule renders error UI, it must use `aria-invalid` / `aria-describedby` / `role="alert"` correctly.

### Phase 3 — Cross-cutting (parallel)
Same three passes as atomic audit, scoped to molecules:
1. `component-deduplicator` — flag near-duplicate molecules (e.g. `FormField` + `FieldGroup` doing the same job).
2. `design-token-enforcer` — molecules must consume only tokens.
3. `accessibility-reviewer` — full keyboard-flow + announcement audit.

### Phase 4 — Composition-up audit (sequential, after per-molecule)

For every molecule, ask `atomic-auditor` (with `--mode=composition`) to walk *up* — find every organism / template / page that uses this molecule, and grade whether the molecule's API is sufficient (no smell of `style overrides`, `as any`, or hidden data props).

### Phase 5 — Synthesis

```text
MOLECULES AUDIT — <scope path>
Date: <ISO date>

SUMMARY
  Molecules scanned             : <n>
  Ship-ready                    : <n>
  Needs work                    : <n>
  Blocked                       : <n>
  Composition violations        : <n>
  Missing-interaction-test      : <n>
  Domain-state leaks            : <n>
  Near-duplicate clusters       : <n>

PER-MOLECULE GRADES
  …

COMPOSITION VIOLATIONS
  molecules/SearchBar imports molecules/IconButton  ← molecule importing molecule
    fix: move IconButton to atoms/, or compose SearchBar from atoms/Button + atoms/Icon
  molecules/FormField reads useUserStore()  ← domain-state leak
    fix: pass values + handlers as props

INTERACTION-TEST GAPS
  molecules/Combobox has no play story for typing+selecting
  molecules/Pagination has no play story for clicking page
  …

DUPLICATES, DEPRECATED, TOKEN GAPS, A11Y DEFECTS
  (same shape as atomic audit)

PRIORITIZED ACTION PLAN
  …
```

## Operating rules

Same as `audit-atomic`. Plus:

- **Composition violations are hygiene fails.** Don't soften this — atomic design depends on level discipline.
- **Domain-state leaks are hygiene fails.** A molecule that reads global state cannot be moved to another product or theme without change.

## Failure modes

Same as `audit-atomic`. Plus:

- **A "molecule" is actually an organism** (owns domain state, fetches data). Flag for promotion to organism, suggest path move.
- **A "molecule" is actually an atom-with-wrapper** (one atom + a `<div>`). Flag for inlining or variant.

## Memory

Append summary to `.claude/agent-memory/audit-molecules/history.log`.
