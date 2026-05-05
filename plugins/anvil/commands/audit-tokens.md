---
name: audit-tokens
description: Audit design-token usage across the codebase. Source-tier audit (primitive vs semantic vs component layers, W3C-DTCG conformance, theming readiness, orphans, naming consistency). Hardcoded-value scan with HIGH / MEDIUM / LOW confidence token mapping. Per-component compliance grade. Refactor plan with auto-applicable exact matches and human-review near-matches. Tier-1 baseline (`<scope>/.anvil/baseline-tokens.md`) + Tier-2 dated history. Inter-agent HANDOFF contract. Invoke as `/anvil:audit-tokens`.
disable-model-invocation: true
argument-hint: "[scope-path]"
arguments: scope_path
allowed-tools: Read, Grep, Glob, Bash, Agent, Write
---

# Audit: Design tokens

Argument: `$scope_path` — defaults to `src/components/`.

## Step 0 — Load context + baseline

Read `design-tokens` (the taxonomy + heuristics this audit enforces) and the project's `.anvil.yml`. Check baseline at `<scope>/.anvil/baseline-tokens.md`.

## Step 1 — Source-tier audit

Spawn `design-token-enforcer` (mode `audit-source`). It reads:
- `tokens/`, `src/tokens/`, `*.tokens.json`
- `style-dictionary*` configs
- `tailwind.config.*` / `theme.{ts,tsx,js}` / `themes/`

Reports on:
- Layer presence (primitive / semantic / component).
- W3C-DTCG conformance (`$value`, `$type`).
- Naming consistency (case, scale, prefix).
- Orphans (primitives never referenced).
- Inline values in semantic tokens (should be primitive references).
- Theming readiness (light / dark mappings per semantic).

HANDOFF.md path: `<scope>/.anvil/handoffs/audit-tokens-<run>/phase-01-source-to-scan.md`.

## Step 2 — Hardcoded-value scan (parallel)

Spawn `design-token-enforcer` (mode `scan`) across `$scope_path`. Per the patterns in `design-tokens`:

- Color literals (`#xxx`, `rgb()`, `hsl()`, `oklch()` etc.).
- Spacing literals (bare `px` / `rem` / `em` in padding / margin / gap / inset / size).
- Font literals (family / weight / size / line / tracking).
- Radius literals.
- Shadow literals.
- Duration / easing literals.
- z-index literals.

For each hit: classify, look up closest token (HIGH = exact, MEDIUM = within tolerance, LOW = no match → propose new token).

HANDOFF.md path: `<scope>/.anvil/handoffs/audit-tokens-<run>/phase-02-scan-to-grade.md`.

## Step 3 — Per-component compliance grade

Spawn `design-token-enforcer` (mode `grade`) per component directory. Score 0–100:

- 100 baseline if zero hardcoded literals.
- −5 per literal with HIGH-confidence token mapping (under-applied policy).
- −10 per literal with only MEDIUM mapping (system gap).
- −15 per literal with no match (system incomplete).

HANDOFF.md path: `<scope>/.anvil/handoffs/audit-tokens-<run>/phase-03-grade-to-orchestrator.md`.

## Step 4 — Synthesis

```text
DESIGN-TOKENS AUDIT — <scope>
Date     : <ISO 8601>
Run-id   : <run-id>
Baseline : present | not present

SECTION 1 — TOKEN SOURCE
  Layers          : primitive ✅, semantic ✅, component ❌ (no component-scoped tokens)
  W3C-DTCG format : 78%  (missing $type on shadow.* and typography.*)
  Theming         : light ✅, dark ❌ (no dark mappings for color.surface.*)
  Orphans         : 14 primitives never referenced
  Inline values in semantics : 3
  Naming hygiene  : kebab-case consistent ✅, t-shirt scale only ✅

SECTION 2 — HARDCODED VALUE SUMMARY
  Color literals   : 142 across 38 files
  Spacing literals : 96 across 41 files
  Font literals    : 28 across 14 files
  Radius literals  : 19 across 12 files
  Shadow literals  : 8  across 4 files
  Motion literals  : 23 across 9 files
  z-index literals : 11 across 7 files

SECTION 3 — TOP OFFENDERS
  organisms/DataTable      : 18 literals
  molecules/Card           : 14
  atoms/Avatar             : 12
  molecules/FormField      : 11
  organisms/Header         : 9

SECTION 4 — CLOSEST-TOKEN MAPPING SAMPLE
  src/.../Button.css:12  #3B82F6                  → color.action.primary    (exact)
  src/.../Card.tsx:34    padding: '14px'          → space.3 (12px) Δ 2px    (nearest)
  src/.../Tag.css:8      box-shadow: 0 1px 2px…   → no semantic match       (propose shadow.elevation.1)
  (full list in artifact)

SECTION 5 — PER-COMPONENT GRADES (worst 10)
  organisms/DataTable      compliance 42  (18 literals, 6 unmapped)
  organisms/Header         compliance 56
  …

SECTION 6 — PROPOSED NEW TOKENS
  shadow.elevation.0   none
  shadow.elevation.1   0 1px 2px 0 rgba(0,0,0,0.05)
  motion.feedback.fast 150ms cubic-bezier(0.4, 0, 0.2, 1)
  …

SECTION 7 — REFACTOR PLAN
  Block 1 — Add missing tokens (manual):
    1. Add shadow.elevation.{0..3}
    2. Add motion.feedback.{instant, fast, moderate}
    3. Add color.surface.* dark-mode mappings
  Block 2 — Auto-refactor exact matches (HIGH confidence):
    4. Replace 89 exact-match literals → tokens. 38 files. Diff reviewable.
  Block 3 — Manual-review nearest matches:
    5. 47 nearest-match cases (Δ ≥ 1px or Δ in shadow / easing). Step through one-by-one.
  Block 4 — Source cleanup:
    6. Add $type to shadow + typography tokens.
    7. Move 3 inline values out of semantics into primitives.
    8. Delete 14 orphan primitives (or document why they exist).

SECTION 8 — OVERALL
  Compliance score       : <n>/100
  Status                 : PASS | NEEDS-WORK | BLOCKED
  Hardcoded-value debt   : <n> sites
  Threshold              : ≥ 80 = pass

SECTION 9 — DIFF VS BASELINE  (only if baseline existed)
  Δ literals             : −89 (auto-refactor applied since baseline)
  Δ tokens               : +5 (new shadow.elevation.* + motion.*)
  New offenders          : 2 sites in src/admin/
  Resolved               : 12 atom-level literals replaced

NEXT
  - Apply Block 1 + Block 2 (auto-refactor exact matches)?  ask user
  - Step through Block 3 with diffs?  ask user
  - Save as new baseline?  yes (default)
```

## Step 5 — Write outputs

- Baseline: `<scope>/.anvil/baseline-tokens.md`
- Dated history: `<scope>/.anvil/history/tokens-<YYYY-MM-DD>.md`

## Operating rules

1. **READ ONLY for source files; Write only for audit artifacts.** Refactors happen only with explicit user approval.
2. **HIGH-confidence first, manual-review second.** Auto-replace exact matches; humans review nearest matches.
3. **DON'T ADD TOKENS WITHOUT A USE CASE.** Propose new tokens only when they would replace ≥ 2 distinct literals.
4. **PRESERVE THEME-READINESS.** Replacing a literal with a primitive is no improvement — replace with a *semantic*.
5. **DETECT MIXED TOKEN SYSTEMS.** A repo with both `tokens.json` and a Tailwind theme that drifts from it is a top finding.
6. **HANDOFF CONTRACT** — every subagent prints `HANDOFF: <path>`.

## Failure modes

- **No tokens exist.** Recommend bootstrapping (Style Dictionary + a starter `tokens.json`). Don't try to retrofit literals against non-existent tokens.
- **Tokens exist but are unused.** Most components import nothing from tokens — surface this as the top finding.
- **CSS-only tokens with CSS-in-JS components** (or vice versa). Recommend a build step (Style Dictionary `javascript/module` format) to bridge.

## Memory

`.claude/agent-memory/audit-tokens/history.log`.
