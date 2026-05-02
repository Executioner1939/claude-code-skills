---
name: merge-duplicates
description: Find near-duplicate components across the codebase, score their similarity, propose a single canonical version, and produce a safe migration plan to merge them. Handles the "we have three Tag-like atoms" / "two Card components" / "every team built their own Modal" situation. Invoke as `/design-storybook-atomic:merge-duplicates`.
disable-model-invocation: true
argument-hint: "[level] [path]"
arguments: level scope_path
allowed-tools: Read, Grep, Glob, Bash, Agent
---

# Merge Duplicates

You are finding and merging near-duplicate components — the most common drift in any non-trivial design system.

Arguments:
- `$level` — `atoms` | `molecules` | `organisms` | `all` (default `all`)
- `$scope_path` — defaults to `src/components/`

## Pipeline

### Phase 1 — Inventory + similarity scoring

Spawn `component-cartographer` to get the inventory, then spawn `component-deduplicator` to score similarity across the inventory.

Similarity dimensions (weighted):
- **Prop signature similarity** (40%) — overlapping prop names + types.
- **Render output similarity** (25%) — same root element + similar markup tree.
- **Visual similarity** (20%) — same / overlapping CSS / token usage.
- **Name semantic similarity** (10%) — `Tag` vs `Pill` vs `Chip`, `Modal` vs `Dialog` vs `Popup`.
- **Story signature similarity** (5%) — same variant names, same states.

Output: clusters of components with similarity ≥ 0.75 within each cluster.

### Phase 2 — Per-cluster analysis (parallel, batched 4–6)

For each cluster, spawn `component-deduplicator --mode=analyze --cluster=<n>`. It returns:

- **Members** — paths + prop signatures.
- **Differences** — every meaningful diff between members (different prop names for the same concept, different state machines, different a11y behavior, divergent token usage).
- **Canonical proposal** — which member should be the survivor (highest test coverage, broadest prop API, cleanest implementation, fewest hardcoded values, most usage sites). Ties broken by name preference (most generic name wins).
- **Unification API** — the merged prop surface (rename collisions, add `variant` for visual differences, add slots for layout differences).
- **Migration plan** — for each non-canonical member: usage sites grep, codemod plan (rename imports, rewrite props), a deprecation path.
- **Risk** — call sites count, public API surface impact, story / test impact, visual regression risk.

### Phase 3 — Synthesis + proposal

Print, per cluster:

```text
CLUSTER 1 — "Tag-like atoms" (similarity 0.91)
  Members:
    src/components/atoms/Tag/Tag.tsx        (canonical proposal, 47 usages)
    src/components/atoms/Pill/Pill.tsx      (12 usages)
    src/components/atoms/Chip/Chip.tsx      (8 usages)

  Key differences:
    - Tag uses `variant: 'default' | 'success' | 'danger'`; Pill uses `tone: 'neutral' | 'green' | 'red'` (rename)
    - Chip has a `removable` prop with `onRemove`; Tag does not (additive)
    - Pill has rounded edges by default; the others are square (variant)

  Proposed canonical: src/components/atoms/Tag/Tag.tsx
  Proposed merged API:
    variant: 'tag' | 'pill' | 'chip'
    color: 'default' | 'success' | 'danger' | 'warning' | 'info'  // rename 'tone' values to 'color'
    removable?: boolean
    onRemove?: () => void

  Migration plan:
    1. Extend Tag.tsx with `variant` and `removable` props (additive — no breaking change yet).
    2. Codemod 1: replace imports of Pill with Tag, mapping tone→color, adding variant='pill'.
    3. Codemod 2: replace imports of Chip with Tag, adding variant='chip', preserving removable.
    4. Mark Pill and Chip @deprecated in their files; add console.warn dev-only.
    5. Update stories: keep best existing stories from each, dedupe variants.
    6. Wait one release cycle; then delete Pill and Chip.

  Risk: MEDIUM
    - 20 usage sites need codemod
    - 3 places use `Pill` ref directly via querySelector — manual review
    - Visual diff expected — capture Chromatic baseline before merging

CLUSTER 2 — "Modal-like organisms" (similarity 0.83)
  …
```

### Phase 4 — Confirmation + execution

For each cluster, ask the user one of:

1. **Apply** — run the codemod, write the unified component, mark deprecated. (Spawn `component-composer --mode=merge --cluster=<n>` to do the writes; spawn `story-writer` to consolidate stories.)
2. **Defer** — skip this cluster, log to `.claude/agent-memory/merge-duplicates/deferred.md` with reasoning.
3. **Override canonical** — user picks a different survivor; redo Phase 3 for that cluster.

After applying: spawn `accessibility-reviewer` against the unified component to ensure no a11y regressed.

### Phase 5 — Post-merge audit

For each merged cluster, run a quick `audit-<level>` pass on the canonical component to confirm coverage hasn't regressed.

## Operating rules

1. **No silent merges.** Every cluster is shown with members, diffs, canonical proposal, and migration plan before any code is written.
2. **Additive first, breaking second.** Add the merged API to the canonical, codemod the others, deprecate, then delete in a later release.
3. **Preserve the best stories.** When merging stories, keep every named state from every member; rename collisions to `<Variant><State>`.
4. **Verify usage counts before deletion.** Every "delete" step requires a `grep` showing zero remaining imports.
5. **Public API impact** — if any member is exported from `package.json`, treat as a major version bump and surface that loudly.
6. **One cluster at a time** unless the user opts in to batch mode. Easier to review.

## Failure modes

- **The "duplicates" are intentional product variations.** Two `Card` components for two products. Defer the cluster; log the rationale.
- **The "canonical" has worst test coverage.** Either pick a different canonical or first port the better tests over before merging.
- **A member is in legacy code paths still being deprecated.** Defer until that path is gone; don't merge into a moving target.
- **Theming divergence.** Two members because two themes need different defaults. Solution is per-theme tokens, not duplicate components — recommend `/design-storybook-atomic:audit-tokens` first.

## Memory

Append summary to `.claude/agent-memory/merge-duplicates/history.log`. Track deferred clusters so subsequent runs surface them again.
