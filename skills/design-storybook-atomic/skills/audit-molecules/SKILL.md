---
name: audit-molecules
description: Systematically audit every molecule. Same rigor as the atomic audit, plus composition checks (atoms used correctly, no atom-importing-atom violations, no molecule-importing-molecule violations), domain-state-leak detection, mandatory primary-interaction `play` story, mandatory `KeyboardFlow` test, FormField-shaped molecules must accept a TanStack Form `field` as primary prop, and the same library-policy + token-compliance + a11y cross-cutting passes. Tier-1 baseline (`<scope>/.design-storybook-atomic/baseline-molecules.md`) + Tier-2 dated history. Inter-agent HANDOFF contract. Invoke as `/design-storybook-atomic:audit-molecules`.
disable-model-invocation: true
argument-hint: "[path]"
arguments: scope_path
allowed-tools: Read, Grep, Glob, Bash, Agent, Write
---

# Audit: Molecules

Same shape as `audit-atomic`. Differences are scoped to the molecule rubric and additional violation classes.

Argument: `$scope_path` — defaults to `src/components/molecules/`.

## Step 0 — Load context + baseline

Same as `audit-atomic`. Read references, project overrides, check baseline at `<scope>/.design-storybook-atomic/baseline-molecules.md`.

## Step 1 — Cartography

Spawn `component-cartographer`. Extra metadata for molecules: composed-atoms list, owned-state classification (controlled / uncontrolled / domain), interaction surface, FormField-shape detection (matches `*FormField`, `*Field`, `*LabelledInput`, etc.).

HANDOFF.md path: `<scope>/.design-storybook-atomic/handoffs/audit-molecules-<run>/phase-01-cartographer-to-auditors.md`.

## Step 2 — Per-molecule audit (parallel, batched 6–8)

Spawn `atomic-auditor` per molecule with the **molecule rubric**. Additional checks beyond atom rubric:

- **Composition correctness**: every atom in the molecule is imported from the `atoms/` directory. No molecule imports another molecule (level violation — flag).
- **No domain-state leakage**: molecules must not read from a global store (Redux / Zustand / Pinia / Recoil / TanStack Store). Grep store usage; flag with `path:line`. (Stores are organism / page concern.)
- **Required interaction story (`.test()` or `play`)**: at least one interaction story exercising the primary interaction (either form is accepted — they're functionally equivalent). Missing = quality penalty.
- **`KeyboardFlow` story**: mandatory for any molecule with > 1 focusable element.
- **Error UI a11y**: if molecule renders error state, must use `aria-invalid` + `aria-describedby` + `role="alert"` (or live region) correctly.
- **FormField-shape molecules** (detected by name pattern): must accept a TanStack Form `field` as primary prop. Scattered `label + value + onChange + error` props = TanStack-contract violation.

## Step 3 — Cross-cutting (parallel — four agents)

Same four agents as `audit-atomic`, scoped to molecules:

1. `component-deduplicator` — flag near-duplicate molecules.
2. `design-token-enforcer` (mode `scan`) — molecules must consume tokens.
3. `accessibility-reviewer` — keyboard flow + announcement audit.
4. `library-policy-enforcer` (mode `audit-imports + audit-integrations`) — composition + form-field shape.

All four write HANDOFF.md per the contract.

## Step 4 — Composition-up audit (sequential, after Step 3)

For every molecule, ask `atomic-auditor` (mode `composition`) to walk **upward** — find every organism / template / page that uses this molecule, and grade whether the molecule's API is sufficient (no smell of `style overrides`, `as any`, hidden data props, or composition workarounds).

HANDOFF.md path: `<scope>/.design-storybook-atomic/handoffs/audit-molecules-<run>/phase-04-composition-up.md`.

## Step 5 — Synthesis

9-section report (same shape as `audit-atomic`):

```text
MOLECULES AUDIT — <scope>
Date     : <ISO 8601>
Run-id   : <run-id>
Baseline : present | not present (first run)

SECTION 1 — SUMMARY
  Molecules scanned             : <n>
  Ship-ready / Solid / Needs work / Blocked counts.
  Composition violations        : <n>
  Domain-state leaks            : <n>
  Missing-interaction-test      : <n>
  FormField field-prop violations : <n>
  Token gaps                    : <n>
  A11y defects (Critical/High)  : <n>/<n>

SECTION 2 — PER-MOLECULE GRADES
  (alphabetized)

SECTION 3 — DUPLICATE CLUSTERS
SECTION 4 — DEPRECATED / UNUSED
SECTION 5 — TOKEN GAPS
SECTION 6 — COMPOSITION + TANSTACK-CONTRACT VIOLATIONS
  Composition violations:
    molecules/SearchBar/SearchBar.tsx:7 imports molecules/IconButton
      → fix: extract IconButton to atom OR compose SearchBar from atoms/Button + atoms/Icon.
    molecules/FormField/FormField.tsx:14 reads useUserStore()
      → fix: pass values + handlers as props (domain-state leak).

  TanStack-contract violations:
    molecules/FormField/FormField.tsx
      → currently takes label + value + onChange + error scattered
      → must accept TanStack Form `field` as primary prop.
    molecules/Combobox/Combobox.tsx:34
      → not forwarding aria-describedby from field.state.meta.

SECTION 7 — ACCESSIBILITY DEFECTS
SECTION 8 — PRIORITIZED ACTION PLAN
  Block 1 — Hygiene blockers (must fix):
    1. Resolve composition violations (3 molecules).
    2. Resolve domain-state leaks (2 molecules).
    3. Refactor FormField to accept `field`.
    4. Fix critical a11y defects.
  Block 2 — Coverage:
    5. Add missing primary-interaction `play` stories.
    6. Add `KeyboardFlow` stories where missing.
  Block 3 — Consolidation:
    7. Merge near-duplicate molecules.

SECTION 9 — DIFF VS BASELINE  (only if baseline existed)
NEXT
  - Apply Block 1?
  - Save as new baseline?
```

## Step 6 — Write outputs

- Baseline: `<scope>/.design-storybook-atomic/baseline-molecules.md`
- Dated history: `<scope>/.design-storybook-atomic/history/molecules-<YYYY-MM-DD>.md`

## Operating rules

Same as `audit-atomic`. Plus:

- **Composition violations and domain-state leaks are hygiene fails.** Don't soften these — atomic design depends on level discipline.
- **A "molecule" that owns domain state is misclassified** — flag for promotion to organism with the path move recommendation.
- **A "molecule" that's just one atom + a wrapper** — flag for inlining or atom-variant promotion.
- **HANDOFF contract** — every subagent prints `HANDOFF: <path>`.

## Memory

`.claude/agent-memory/audit-molecules/history.log` per the same convention as `audit-atomic`.
