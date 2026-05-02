---
name: audit-tokens
description: Audit design-token usage across the codebase. Finds hardcoded colors, spacing, fonts, radii, shadows, durations; classifies them; proposes token refactors. Audits the token taxonomy itself (primitive vs semantic separation, theming readiness, naming consistency, W3C-DTCG conformance). Produces a refactor plan and can apply it via the `design-token-enforcer` subagent. Invoke as `/design-storybook-atomic:audit-tokens`.
disable-model-invocation: true
argument-hint: "[path]"
arguments: scope_path
allowed-tools: Read, Grep, Glob, Bash, Agent
---

# Audit: Design Tokens

You are auditing the design system's **token usage** — every component file in scope and the token-source files themselves. The `design-tokens` skill defines the taxonomy this audit enforces.

Argument: `$scope_path` — defaults to `src/components/`. Tokens themselves are read from `tokens/`, `src/tokens/`, `*.tokens.json`, `tailwind.config.*`, and `style-dictionary.config.*`.

## Pipeline

### Phase 1 — Token-source audit

Spawn `design-token-enforcer --mode=audit-source`. It reads the token files and reports:

- Are there at least two layers (primitive + semantic)? If only one, that's a top-finding.
- Does every semantic resolve to a primitive (vs. inlining a value)? Flag inline values in semantics.
- Are tokens W3C-DTCG-formatted (`$value`, `$type`)? If not, list the deltas.
- Is naming consistent? T-shirt sizes mixed with numeric? camelCase mixed with kebab-case? Flag.
- Are there orphan tokens (defined but never referenced)?
- Is theming wired (a `dark` mode mapping exists for every relevant semantic)?

### Phase 2 — Hardcoded-value scan (parallel)

Spawn `design-token-enforcer --mode=scan` to grep across `$scope_path`:

- **Color literals**: `#xxx`, `#xxxxxx`, `rgb()`, `rgba()`, `hsl()`, `hsla()`.
- **Spacing literals**: bare `px` / `rem` / `em` in `padding`, `margin`, `gap`, `inset`, `top/right/bottom/left`, `width`, `height`, `font-size`.
- **Font literals**: `font-family`, `font-weight`, `font-size`, `line-height`, `letter-spacing`.
- **Radius literals**: `border-radius` with px/rem/em.
- **Shadow literals**: any `box-shadow` not pulling from a token.
- **Duration / easing literals**: `transition`, `animation` with bare ms or named easings.
- **z-index literals**: bare integers.

For each hit:
- Classify (color/space/font/radius/shadow/motion/z).
- Look up the closest token by value.
- Propose: exact token (high confidence) | nearest token (with delta) | new token (with proposed name + value).

### Phase 3 — Per-component compliance grade (parallel)

Spawn `design-token-enforcer --mode=grade` per component directory. Each component gets a token-compliance score 0–100 based on:

- 100 if zero hardcoded values.
- –5 per literal in CSS / styled-components / Tailwind arbitrary values (`text-[#...]`).
- –10 per literal that has no obvious token mapping (means the token system is incomplete, not just under-applied).

### Phase 4 — Synthesis

```text
DESIGN-TOKENS AUDIT — <scope path>
Date: <ISO date>

TOKEN SOURCE
  Layers          : primitive ✅, semantic ✅, component ❌ (no component-scoped tokens)
  W3C-DTCG format : 78%  (missing $type on shadow.* and typography.*)
  Theming         : light ✅, dark ❌ (no dark mappings for color.surface.*)
  Orphans         : 14 primitives never referenced (color.gray.{50,100,200,…})
  Inline values in semantics : 3 (color.text.code = '#0F172A' should be {color.gray.900})

HARDCODED VALUE SUMMARY
  Color literals   : 142 across 38 files
  Spacing literals : 96 across 41 files
  Font literals    : 28 across 14 files
  Radius literals  : 19 across 12 files
  Shadow literals  : 8  across 4 files
  Motion literals  : 23 across 9 files
  z-index literals : 11 across 7 files

TOP OFFENDERS (by literal count)
  organisms/DataTable      : 18
  molecules/Card            : 14
  atoms/Avatar              : 12
  molecules/FormField       : 11
  organisms/Header          : 9

CLOSEST-TOKEN MAPPING SAMPLE (full list in appendix)
  src/.../Button.css:12  #3B82F6                  → color.action.primary    (exact)
  src/.../Card.tsx:34    padding: '14px'          → space.3 (12px) Δ 2px    (nearest)
  src/.../Tag.css:8      box-shadow: 0 1px 2px…   → no semantic match       (propose shadow.elevation.1)

PER-COMPONENT GRADES (worst 10)
  organisms/DataTable      compliance 42  (18 literals, 6 unmapped)
  …

PROPOSED NEW TOKENS
  shadow.elevation.0   none
  shadow.elevation.1   0 1px 2px 0 rgba(0,0,0,0.05)
  motion.feedback.fast 150ms cubic-bezier(0.4, 0, 0.2, 1)
  …

PRIORITIZED REFACTOR PLAN
  Block 1 — Add missing tokens:
    1. Add shadow.elevation.{0..3}
    2. Add motion.feedback.{instant,fast,moderate}
    3. Add color.surface.* dark-mode mappings
  Block 2 — Auto-refactor exact matches (high confidence):
    4. Replace 89 exact-match literals → tokens. 38 files. Diff reviewable.
  Block 3 — Manual-review nearest matches:
    5. 47 nearest-match cases (Δ ≥ 1px or Δ in shadow/easing). Show diff one-by-one for approval.
  Block 4 — Source cleanup:
    6. Add $type to shadow + typography tokens
    7. Move 3 inline values out of semantics into primitives
    8. Delete 14 orphan primitives (or document why they exist)

NEXT
  - Apply Block 1 + Block 2 (auto-refactor exact matches)?  ask user
  - Step through Block 3 with diffs?  ask user
```

## Operating rules

1. **Never apply refactors without explicit user approval.** The synthesis report ends with explicit prompts.
2. **High-confidence first, manual-review second.** Auto-replace exact matches; humans review nearest matches.
3. **Don't add tokens without a use case.** "Propose new token" lists only tokens that would replace ≥2 distinct literals.
4. **Preserve theme-readiness.** A refactor that hardcodes a primitive in a component is no improvement over an inline literal — replace with a *semantic*, never a primitive.
5. **Detect mixed token systems.** A repo that has both `tokens.json` and a Tailwind theme that drifts from it is a top-finding; report and recommend a single source of truth.

## Failure modes

- **No tokens exist.** Recommend bootstrapping (Style Dictionary + a starter `tokens.json`). Don't try to retrofit literals to non-existent tokens.
- **Tokens exist but are unused.** Most components import nothing from tokens. The system was set up but never adopted. Surface this loudly.
- **Tokens are CSS-only and components are CSS-in-JS** (or vice versa). Recommend a build step (Style Dictionary `javascript/module` format) to bridge.

## Memory

Append summary to `.claude/agent-memory/audit-tokens/history.log`.
