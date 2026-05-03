---
name: audit-libraries
description: Audit a project against the approved-libraries policy and the tanstack-integration patterns. Reads package.json + lockfile + import graph; finds forbidden dependencies, competing-Primary coexistence, atoms that emit events instead of values, molecules that don't accept a `field`, organism tables that take raw data + columns, organism lists that bypass TanStack DB / Query, animations without `prefers-reduced-motion`. Produces a graded report with per-defect canonical fixes. Tier-1 baseline diff (`<scope>/.design-storybook-atomic/baseline-libraries.md`) + Tier-2 dated history. Invoke as `/design-storybook-atomic:audit-libraries`.
disable-model-invocation: true
argument-hint: "[scope-path]"
arguments: scope_path
allowed-tools: Read, Grep, Glob, Bash, Agent, Write
---

# Audit: Libraries

You are running a systematic audit of the project's third-party library usage and TanStack-integration compliance. The reference is the `approved-libraries` skill (Primary / approved-alternate / forbidden matrix) and the `tanstack-integration` skill (per-atomic-level prop shapes).

Argument: `$scope_path` — defaults to the current working directory.

## Step 0 — Load context + check baseline

### 0a — Acceptance criteria

Read `approved-libraries` and `tanstack-integration` from this plugin's `skills/` directory. They contain the policy and the integration contracts.

### 0b — Project context

Read `<scope>/.design-storybook-atomic.yml` if present. Honor:
- `library_policy.exemptions[]` — documented exemptions with `reason` + `sunset`.
- `library_policy.allow_alternates_as_primary[]` — projects that have decided e.g. Zustand is the in-house Primary instead of TanStack Store.
- `migration.csf_factories_required` — false in projects mid-migration; surfaces as info, not blocker.

### 0c — Baseline check (audit history)

```bash
test -f "$scope_path/.design-storybook-atomic/baseline-libraries.md" \
  && echo "BASELINE: present" \
  || echo "BASELINE: not present (first run)"
```

If a baseline exists, the report ends with a "Section 9 — Diff vs baseline" block. Otherwise, the current report becomes the baseline.

## Step 1 — Inventory (Cartography)

If `.claude/agent-memory/component-cartographer/last-inventory.md` exists and is fresh (< 24h), read it. Otherwise, spawn `component-cartographer` to inventory the project.

Print: `Inventoried <n> components (<a> atoms, <m> molecules, <o> organisms, <t> templates, <p> pages).`

## Step 2 — Policy enforcement

Spawn `library-policy-enforcer` in `default` mode. It runs:

- **Step 2a — Dependency audit** — package.json forbidden / competing-Primary detection.
- **Step 2b — Import-graph audit** — grep for forbidden imports.
- **Step 2c — Atomic-level integration audit** — atom contract, molecule field-wrapping, organism table / collection, animation reduced-motion.

The agent writes a HANDOFF.md to:

```text
<scope>/.design-storybook-atomic/handoffs/audit-libraries-<run>/phase-01-cartographer-to-policy.md
<scope>/.design-storybook-atomic/handoffs/audit-libraries-<run>/phase-02-policy-to-orchestrator.md
```

Don't proceed until the policy enforcer prints `HANDOFF: <path>` for phase-02.

## Step 3 — Synthesis

Build the report. Use this exact structure:

```text
LIBRARY AUDIT — <scope>
Date     : <ISO 8601>
Run-id   : <run-id>
Baseline : present | not present (first run)

SECTION 1 — DEPENDENCY HEALTH
  Total deps           : <n>
  Forbidden (deps)     : <n>
  Forbidden (devDeps)  : <n>
  Competing Primaries  : <n>
  Active exemptions    : <n>
  Compliance subtotal  : <n>/100

SECTION 2 — IMPORT GRAPH
  Forbidden import sites : <n>
  Top offenders by lib   :
    react-hook-form  : 14 sites
    lodash/debounce  : 7 sites
    moment           : 3 sites
  Compliance subtotal    : <n>/100

SECTION 3 — ATOMIC-LEVEL INTEGRATIONS
  Atom contract violations    : <n> / <total atoms>
  Molecule field violations   : <n> / <total form-shaped molecules>
  Organism table violations   : <n> / <total table-shaped organisms>
  Organism collection violations : <n> / <total list-shaped organisms>
  Animation reduced-motion gaps  : <n> / <total animated>
  Compliance subtotal            : <n>/100

SECTION 4 — PER-DEFECT LIST
  (paste the full library-policy-enforcer output)

SECTION 5 — COMPETING-PRIMARY DECISIONS
  (when two Primary picks coexist, recommend a chosen one based on usage count
   and write the recommendation here so the team can ratify in
   .design-storybook-atomic.yml)

SECTION 6 — TANSTACK-ADOPTION HEATMAP
  Form integration       : 12/15 forms ✅ TanStack Form ; 3 RHF ❌
  Table integration      : 4/4 tables  ✅ TanStack Table
  Server-state           : 100% TanStack Query ✅
  Local-store / DB       : 30% TanStack DB (5/16 organisms feeding from collections)
                          → 11 list-shaped organisms still on useState([]) + useEffect
  UI store               : TanStack Store ✅
  Pacer (debounce)       : 3 lodash sites ❌
  Day.js                 : 17 moment.js sites ❌

SECTION 7 — REMEDIATION PLAN
  Block 1 (block merge):
    1. Replace 14 RHF imports → TanStack Form (track migration in #ISSUE).
    2. Refactor 5 organism tables to accept Table instance.
    3. Replace lodash debounce → @tanstack/react-pacer (3 files).
  Block 2 (high priority):
    4. Migrate 11 organism lists to TanStack DB collections.
    5. Add prefers-reduced-motion guards (4 components).
  Block 3 (medium):
    6. Replace moment → dayjs (17 files; codemod feasible).
    7. Migrate Cypress component tests → Vitest browser-mode.

SECTION 8 — OVERALL
  Compliance score : <n>/100
  Status           : PASS | NEEDS-WORK | BLOCKED
  Threshold        : ≥ 80 = pass

SECTION 9 — DIFF VS BASELINE  (only if baseline existed)
  Δ overall score  : +5
  Improved (since baseline):
    - 7 RHF sites removed (now 14, was 21)
    - moment dependency dropped from peerDeps
  Regressed:
    - 2 new lodash/debounce sites in src/admin/
  New defects since baseline:
    - [I12] src/admin/Search.tsx:34 imports lodash/debounce
    - [I13] src/admin/UserPicker.tsx:18 imports lodash/debounce

NEXT
  - Apply Block 1 (auto-fixable items)?  ask user
  - Walk through Block 2 with diffs?  ask user
  - Save this report as new baseline?  yes (default unless user opts out)
```

## Step 4 — Write outputs

After printing the report, **write** it to:

1. **Baseline (replaces previous)** — `<scope>/.design-storybook-atomic/baseline-libraries.md`
2. **Dated history (additive)** — `<scope>/.design-storybook-atomic/history/libraries-<YYYY-MM-DD>.md`

Both files use the synthesis report as their content. The baseline is the most recent; the history accumulates.

This mirrors the audit-history pattern from `terraform-audit`'s `$repo_path/.terraform-audit/baseline.md` plus a Tier-2 dated history log.

## Operating rules

1. **READ ONLY for code changes; Write only for the audit artifacts** (baseline + history). Never edit project source files in this skill.
2. **EVERY DEFECT GETS `path:line`** — the per-defect list in Section 4 must trace each finding.
3. **HONOR `.design-storybook-atomic.yml`** — exemptions with valid sunsets are not defects.
4. **DIFFS REQUIRE BASELINE.** Section 9 only renders when a prior baseline exists.
5. **COMPETING PRIMARIES** require explicit user decision — flagged as Section 5, not auto-resolved.
6. **NEVER LOWER THE BAR.** A score below 80 = BLOCKED. The threshold is fixed.
7. **HANDOFF CONTRACT** — every subagent invoked here must write a HANDOFF.md per `_handoff/HANDOFF-template.md` and print `HANDOFF: <path>`. The orchestrator halts if the line is missing.

## Failure modes

- **No `package.json` at scope.** Halt with explicit instruction: "Library audits require a JS package manifest at the scope root."
- **Mixed package managers** (both `pnpm-lock.yaml` and `package-lock.json` present) — surface as a finding (a build hazard) and proceed using whichever is newest.
- **Cartographer can't classify components.** Run library audit at the dependency + import-graph level only; flag the integration audit as `INCOMPLETE — cartographer failed`.
- **`.design-storybook-atomic.yml` malformed.** Warn loudly, parse what's parseable, treat unknown keys as ignored, NEVER apply policies that aren't in the explicit policy doc.

## Memory

Append a one-line summary to `.claude/agent-memory/audit-libraries/history.log`:

```
2026-05-03T17:42 audit-libraries scope=. score=71 status=BLOCKED defects={deps:3,imports:24,atoms:5,molecules:1,organisms:9,motion:4}
```

Subsequent runs can chart drift over time without re-reading every baseline.
