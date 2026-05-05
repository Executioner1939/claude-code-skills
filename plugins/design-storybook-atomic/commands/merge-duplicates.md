---
name: merge-duplicates
description: Find near-duplicate components across the codebase, score similarity, propose a single canonical version, produce a safe migration plan, and (after user approval) apply the merge. Handles the "we have three Tag-like atoms" / "two Card components" / "every team built their own Modal" situations. Inter-agent HANDOFF contract. Invoke as `/design-storybook-atomic:merge-duplicates`.
disable-model-invocation: true
argument-hint: "[level] [path]"
arguments: level scope_path
allowed-tools: Read, Grep, Glob, Bash, Agent, Write, Edit
---

# Merge Duplicates

Arguments:
- `$level` — `atoms` | `molecules` | `organisms` | `all` (default `all`)
- `$scope_path` — defaults to `src/components/`

## Step 0 — Load context

Read `atomic-design`, `component-composition`, `tanstack-integration`, `approved-libraries` (auto-preloaded into chained subagents). Read `<scope>/.design-storybook-atomic.yml` for any pre-deferred clusters (`merge.deferred[]`).

## Step 1 — Cartography

Spawn `component-cartographer`. HANDOFF: `<scope>/.design-storybook-atomic/handoffs/merge-duplicates-<run>/phase-01-cartography-to-dedup.md`.

## Step 2 — Cluster detection

Spawn `component-deduplicator` (mode `cluster`, scoped to `$level`). Computes pairwise similarity (prop signature 40% + render shape 25% + visual style 20% + name semantics 10% + story signature 5%); groups pairs with similarity ≥ 0.75 into clusters.

HANDOFF: `<scope>/.design-storybook-atomic/handoffs/merge-duplicates-<run>/phase-02-clusters-to-analysis.md`.

Print: `Found <n> clusters.`

## Step 3 — Per-cluster analysis (parallel, batched 4–6)

For each cluster, spawn `component-deduplicator` (mode `analyze --cluster=<n>`). Returns:

- Members (paths + prop signatures).
- Differences (prop renames, additive props, divergent state machines, divergent a11y, divergent token usage).
- Canonical proposal (highest test/story coverage; cleanest implementation; broadest API; most usage; most generic name).
- Unification API (resolved renames, new `variant` prop for visual differences, new slots for layout differences).
- Migration plan (additive change to canonical + codemod for non-canonical members + deprecation cycle).
- Risk (call sites count, public API impact, visual regression, semver impact).

Each cluster gets its own HANDOFF: `<scope>/.design-storybook-atomic/handoffs/merge-duplicates-<run>/phase-03-cluster-<n>-analysis.md`.

## Step 4 — User decision per cluster

For each cluster, ask the user one of:

1. **Apply** — run the codemod, write the unified component, mark deprecated.
2. **Defer** — skip, log to `<scope>/.design-storybook-atomic.yml` `merge.deferred[]` with reasoning.
3. **Override canonical** — user picks a different survivor; redo Step 3 for that cluster.

## Step 5 — Apply (per-cluster, after approval)

For each `Apply`-approved cluster:

### 5a — Merge implementation

Spawn `component-composer` (mode `merge`, cluster=`<n>`). Applies the unified API to the canonical (additive); writes deprecation markers + dev-only `console.warn` re-exports on non-canonical members; updates barrel exports.

HANDOFF: `<scope>/.design-storybook-atomic/handoffs/merge-duplicates-<run>/phase-05a-merge-cluster-<n>.md`.

### 5b — Codemod consumer sites

Spawn `component-composer` (mode `codemod`, cluster=`<n>`) to rewrite import + prop usages at every consumer site (paths from the cartographer's `importedBy` data). One file per pass; verify after each.

HANDOFF: `<scope>/.design-storybook-atomic/handoffs/merge-duplicates-<run>/phase-05b-codemod-cluster-<n>.md`.

### 5c — Story consolidation

Spawn `story-writer` (mode `merge-stories`) to consolidate the cluster's stories: keep every named state from every member, rename collisions to `<Variant><State>`, drop true duplicates.

HANDOFF: `<scope>/.design-storybook-atomic/handoffs/merge-duplicates-<run>/phase-05c-stories-cluster-<n>.md`.

### 5d — Verify

Spawn `accessibility-reviewer` against the unified component to ensure no a11y regressed during the merge. Spawn `library-policy-enforcer` to confirm the unified component satisfies the level's TanStack contract.

HANDOFF: `<scope>/.design-storybook-atomic/handoffs/merge-duplicates-<run>/phase-05d-verify-cluster-<n>.md`.

## Step 6 — Post-merge audit

Run a quick `audit-<level>` pass on the unified component to confirm coverage hasn't regressed. Print delta vs the pre-merge graded score.

## Step 7 — Synthesis

```text
MERGE REPORT — <scope> (level: <level>)
Date     : <ISO 8601>
Run-id   : <run-id>

CLUSTERS DETECTED   : <n>
APPLIED             : <n>
DEFERRED            : <n>
CANONICAL OVERRIDDEN: <n>

PER-APPLIED CLUSTER:
  Cluster 1 — "Tag-like atoms"
    Canonical: atoms/Tag
    Merged-out (deprecated): atoms/Pill, atoms/Chip
    Consumer sites updated: 20
    Files written: 4 (Tag.tsx, Tag.stories.tsx, Tag.mdx, atoms/index.ts)
    Risk: MEDIUM (visual diff expected; capture Chromatic baseline before pushing)

PUBLIC API IMPACT
  semver: MAJOR (Pill, Chip exported from packages/ui/index.ts)

VISUAL REGRESSION
  Recommend Chromatic baseline before merging this PR.

DEFERRED CLUSTERS (logged to .design-storybook-atomic.yml):
  Cluster N — "Modal vs Dialog vs Popup"
    reason: <user-provided>

NEXT
  - Capture Chromatic baseline.
  - Open PR with the merge commits.
  - Schedule deletion of deprecated members in next major release.
```

## Operating rules

1. **No silent merges.** Every cluster shown with members + diffs + canonical proposal + migration plan before any code is written.
2. **Additive first, breaking second.** Add the merged API to canonical (non-breaking); codemod consumers; deprecate; delete in a later release.
3. **Preserve the best stories.** Keep every named state from every member; rename collisions.
4. **Verify usage counts before deletion.** Every "delete" step requires a `grep` showing zero remaining imports.
5. **Public API impact** is mandatory in the report.
6. **One cluster at a time** unless the user opts in to batch.
7. **HANDOFF contract** — every subagent prints `HANDOFF: <path>`.

## Failure modes

- **The "duplicates" are intentional product variations.** Defer the cluster; log the rationale.
- **The "canonical" has worst test coverage.** Either pick a different canonical or first port the better tests over.
- **A member is in legacy code paths still being deprecated.** Defer — don't merge into a moving target.
- **Theming divergence.** Two members because two themes need different defaults. Solution is per-theme tokens, not duplicate components — recommend `/design-storybook-atomic:audit-tokens` first.

## Memory

`.claude/agent-memory/merge-duplicates/history.log`. Track deferred clusters so subsequent runs surface them again.
