---
name: audit-atoms
description: Systematically audit every atom in the design system for full Storybook (CSF Factories) coverage, uniqueness (merging similar atoms when sound, deprecating old ones), design-token compliance, approved-libraries policy, TanStack-integration prop-shape contract (value-first onChange, forwardRef, aria wiring), and accessibility (WCAG 2.2 AA + WAI-ARIA APG). Produces a graded report per atom and a prioritized defect list. Tier-1 baseline diff (`<scope>/.anvil/baseline-atoms.md`) + Tier-2 dated history. Inter-agent HANDOFF.md contract. Invoke as `/anvil:audit-atoms` — optionally pass a path to scope the audit, plus mode flags `--auto-baseline=replace|history-only|prompt`, `--static-only`, `--no-prompt`.
disable-model-invocation: true
argument-hint: "[path] [--auto-baseline=replace|history-only|prompt] [--static-only] [--no-prompt]"
arguments: scope_path
allowed-tools: Read, Grep, Glob, Bash, Agent, Write
---

# Audit: Atomic Layer

Run a systematic audit of every **atom** in the codebase — Storybook coverage, uniqueness, design-token compliance, approved-libraries policy, TanStack-integration contract, accessibility.

Argument: `$scope_path` — defaults to `src/components/atoms/` (fallback search if absent).

Mode flags (parsed from `$scope_path` if present, else defaulted):
- `--auto-baseline=<replace|history-only|prompt>` — controls baseline overwrite on subsequent runs. Default `prompt`.
- `--static-only` — skip per-atom LLM auditor agents; rely on the static scanner output for grading. Defaults on when the scanner finds > 30 atoms.
- `--no-prompt` — run end-to-end without interactive prompts (chained workflows).

## Step 0 — Pre-flight

Phase 0 is the difference between a clean audit and a noisy one. Skipping it produces false-positive defects when the project's conventions differ from the skill's defaults. The five sub-phases (rubric / integrity / contracts / mode / cardinality) feed each other — run them in order.

### 0a — Project rubric detection

Read these files in parallel and fold the result into a `rubricOverrides` block at the top of the audit report:

| Source | What to detect |
|---|---|
| `CLAUDE.md` (project root) and `<scope>/CLAUDE.md` | Any documented project conventions — MDX layout, form contract, tier placement, lint exceptions. Treat what's documented as authoritative. |
| `package.json` | Framework (`react` / `react-native` / `vue`), styling (`tailwindcss` / `nativewind` / `styled-components`), form library (`@tanstack/react-form` vs `react-hook-form` vs neither). |
| `eslint.config.{js,mjs,ts}` | Any `no-restricted-syntax` / `no-restricted-imports` rules whose patterns will trip atom-tier code (e.g. flagging `bg-surface-raised border` as "Card surface re-implemented"). Surface them so the grading rubric exempts atoms or proposes scope inversion. |
| `tokens.css` / Tailwind config | Whether `prefers-reduced-motion` is gated globally (Tailwind `motion-safe:` defaults, or a top-level `@media (prefers-reduced-motion: reduce)` block in tokens). If it is, the a11y reviewer must NOT flag missing per-component motion guards. |
| `src/docs/` directory shape | MDX convention — per-component (sibling `Foo.mdx`) vs per-category (`src/docs/atoms/<Category>.mdx`) vs none. The grading rubric's "MDX present?" axis adapts accordingly. |
| `**/component-contracts/*.ts` | List of design-system contracts. Build the contract→implementing-tier map for Phase 0c. |

Emit a `Project rubric overrides` table at the top of the synthesis report:

```text
PROJECT RUBRIC OVERRIDES (detected)
  MDX convention   : per-category   (src/docs/atoms/Buttons.mdx)
  Form contract    : native-DOM     (no @tanstack/react-form in deps; TanStack-contract checks emit ADVISORY only)
  Tier placement   : Card→molecule, Toast→organism, Alert→atom, Progress→atom
  Token convention : css-vars       (var(--color-*) found in 89% of consumed tokens)
  Lint rules       : no-restricted-syntax flags atom-tier card-surface — exempted at audit time, propose rule inversion
  Motion guards    : globally gated via tokens.css @media (prefers-reduced-motion) — per-atom motion checks skipped
```

This block is the **single source of truth** for grading. Every downstream agent reads it before scoring.

### 0b — Baseline integrity probe

Run a fast smoke probe to quarantine pre-existing breakage from the audit's defect counts:

```bash
( cd "$scope_path" && pnpm typecheck 2>&1 | tail -5 ) || true
( cd "$scope_path" && pnpm lint 2>&1     | tail -5 ) || true
( cd "$scope_path" && pnpm test:stories --run --reporter=basic 2>&1 | tail -10 ) || true
```

Classify each failure into:
1. **Import-time errors** — root causes; one broken import cascades into many failed test files.
2. **Assertion-time failures** — real test bugs.
3. **A11y violations** — axe defects, group by rule.

If any probe fails, surface in the report:

```text
BASELINE INTEGRITY
  typecheck  : FAIL (3 import-time errors — see below)
  lint       : PASS
  test:stories: FAIL (1 import-time → 47 cascade failures)

  Pre-existing failures (NOT counted against atom-audit defects):
    - src/showcase/booking.tsx:4 — imports deleted molecules/BookingSummary
    - src/showcase/feature.tsx:2 — imports deleted organisms/FeatureCard
    - lib/auth/middleware.ts:18 — type error from in-progress refactor

  These must be fixed independently. Audit will proceed with caveats.
```

The probe runs in < 60s typically. If a project has no `pnpm` script, fall through silently and log the gap in Section 7 of the report.

### 0c — Tier-aware contract resolution

For each contract found in Phase 0a, scan every consumer package across all tiers (atoms, molecules, organisms) for a same-name implementation. A contract is **satisfied** if any tier implements it — it does NOT need to live at the atom tier.

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/inventory.py" \
  query "$scope_path/.anvil/inventory.json" \
  contract <contract-name>
```

Build a satisfaction map and emit it as part of `rubricOverrides.tierPlacement`. The audit report's "missing contract implementation" list MUST cross-check this map — never report `atoms/Toast missing` when `organisms/Toast` exists.

### 0d — Mode flag resolution

Parse mode flags from the argument string; defaults are:
- `--auto-baseline=prompt` for human-driven runs
- `--static-only=auto` (on if Phase 0e cardinality > 30)
- `--no-prompt=false`

If the user passed `--no-prompt` in a chained workflow (e.g. inside `/coverage-report`), do NOT interrupt for baseline-overwrite confirmation. Use the `--auto-baseline` value instead.

### 0e — Cardinality estimate + scanner refresh

Refresh the static inventory before any LLM agents are spawned:

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/scripts/inventory.py" \
  scan --root "$scope_path" --tier atom \
  --out "$scope_path/.anvil/inventory.json"

python3 "${CLAUDE_PLUGIN_ROOT}/scripts/inventory.py" \
  stats "$scope_path/.anvil/inventory.json"
```

The inventory is also refreshed automatically by the `refresh-inventory` PostToolUse hook whenever the user edits component files — this scan is a final guarantee.

If atom count > 30 and the user did not pass `--static-only=false`, switch to **static-scan grading mode** for Phase 2. The scanner already computed: `forwardsRef`, `hardcodedLiterals`, `stories.format`, `stories.count`, `mdx.present/mode`, `consumers`, `composes`, `tierViolations`, `tokenCompliance.score` — these are the deterministic axes of the rubric. The LLM auditor then only contributes the *narrative* (story-quality judgement, action-plan ordering).

For atom count ≤ 30, run the LLM-per-atom auditor as before — the token cost is acceptable.

### 0f — References

Load `atomic-design`, `storybook-authoring`, `storybook-atomic-integration`, `story-coverage-checklist`, `design-tokens`, `approved-libraries`, `tanstack-integration`, `accessibility-stories`. (Auto-preloaded into invoked subagents via their `skills:` frontmatter.)

### 0g — Baseline presence check

```bash
test -f "$scope_path/.anvil/baseline-atoms.md" \
  && echo "BASELINE: present" \
  || echo "BASELINE: not present (first run)"
```

If baseline exists, the synthesis report ends with **Section 9 — Diff vs baseline**. Otherwise the current report becomes the baseline.

## Step 1 — Cartography (single agent, sequential)

Spawn `component-cartographer` to inventory every atom **using the static scanner output as its starting point** (never re-discover from scratch).

The agent writes a HANDOFF.md to:

```text
<scope>/.anvil/handoffs/audit-atoms-<run>/phase-01-cartographer-to-auditors.md
```

**Validation contract**: do not proceed until the agent prints `HANDOFF: <abs path>`. If the line is missing within 90s, fall through to the inline-cartography fallback:

```bash
# Inline fallback when the dispatched agent stalls. Source of truth is
# inventory.json — write a minimal HANDOFF that references it.
cat > "<handoff-path>" <<EOF
# HANDOFF (inline fallback) — cartographer stalled, using inventory.json directly
- Inventory: $scope_path/.anvil/inventory.json
- Atoms: $(jq '[.components[]|select(.tier=="atom")]|length' inventory.json)
- Tier violations: $(jq '[.components[]|.tierViolations[]?]|length' inventory.json)
- Hardcoded sites: $(jq '[.components[]|select((.hardcodedLiterals|length)>0)]|length' inventory.json)
EOF
```

Print: `Inventoried <n> atoms across <m> directories.`

## Step 2 — Per-atom audit

**If `--static-only` is on (atom count > 30 or user-forced)**: skip per-atom LLM auditors entirely. The static scanner has already computed every deterministic axis. Read `inventory.json` and produce per-atom `COMPONENT` blocks directly; reserve LLM calls for the narrative pass and the cross-cutting Phase 3 agents.

**Otherwise**: spawn `atomic-auditor` **in parallel** (multiple Agent calls in a single message), batched 6–8 atoms per call. Each agent grades one atom against `story-coverage-checklist` and the TanStack-integration contract — but reads `inventory.json` instead of re-walking the file system. Returns:

- coverage / quality / hygiene scores (per `story-coverage-checklist` rubric).
- letter grade.
- explicit list of missing stories.
- explicit list of MDX gaps.
- explicit list of token-compliance gaps.
- explicit list of TanStack-contract gaps (atom must accept value + onChange(v) + onBlur + aria + forwardRef).
- explicit list of a11y defects.
- recommended actions, ordered.

Each auditor writes its own per-atom HANDOFF.md (when chained — for parallel batch this is consolidated):

```text
<scope>/.anvil/handoffs/audit-atoms-<run>/phase-02-auditor-batch-<k>-to-cross-cutting.md
```

Print one progress line per batch: `Batch <k>/<total> graded.`

## Step 3 — Cross-cutting passes (parallel, five agents at once)

Spawn five agents in parallel — they share the inventory but score different axes:

1. **`component-deduplicator`** (scope: atoms only) — finds near-duplicates, scores similarity, proposes a canonical version + merge plan. Its output is also the input to the genericness pass's `MERGE-INTO-PRIMITIVE` subsection in Step 4.
2. **`design-token-enforcer`** (mode `scan`, scope: atoms only) — finds hardcoded values, proposes token refactors with HIGH / MEDIUM / LOW confidence.
3. **`accessibility-reviewer`** (scope: atoms only) — runs the manual-check matrix from `accessibility-stories` (focus management, keyboard model, target size, color independence, prefers-reduced-motion).
4. **`library-policy-enforcer`** (mode `audit-imports + audit-integrations`, scope: atoms only) — verifies the field-friendly atom contract; flags forbidden imports.
5. **`atomic-auditor`** (mode `genericness-only`, scope: atoms only) — emits a per-atom genericness verdict in batch (KEEP / DELETE-wrapper-of-primitive / RENAME-AND-SLOT / MERGE-INTO-PRIMITIVE / PROMOTE-TO-PRIMITIVE) with the canonical replacement expression for DELETE / RENAME / MERGE verdicts. Reads `inventory.json` and the deduplicator's HANDOFF (when available — otherwise emits its verdicts independently and the synthesizer joins).

Each writes a HANDOFF.md to:

```text
<scope>/.anvil/handoffs/audit-atoms-<run>/phase-03-<agent>-to-orchestrator.md
```

Wait for all five to print `HANDOFF: <path>` before proceeding.

## Step 4 — Synthesis

Build the audit report. Use this exact 9-section structure (mirrors `terraform-audit`):

```text
ATOMIC AUDIT — <scope path>
Date     : <ISO 8601>
Run-id   : <run-id>
Baseline : present | not present (first run)

SECTION 0 — PROJECT RUBRIC OVERRIDES (from Phase 0a)
  MDX convention   : <per-component | per-category | none>
  Form contract    : <tanstack-form | native-DOM | other>      (TanStack-contract checks ADVISORY when not tanstack-form)
  Tier placement   : <contract-name>→<tier>, …                 (drives Section 6 + the contract-coverage check)
  Token convention : <css-vars | ts-objects | tailwind-theme | hybrid>
  Lint rules       : <list of rules that affect atom-tier code, with exemption status>
  Motion guards    : <project-global | per-component | none>   (a11y reviewer skips per-atom motion checks when project-global)

SECTION 0b — BASELINE INTEGRITY (from Phase 0b)
  typecheck   : PASS | FAIL (n import-time errors)
  lint        : PASS | FAIL (n errors)
  test:stories: PASS | FAIL (n root-cause failures, m cascade)
  Pre-existing failures (NOT counted against atom-audit defects): <list or none>

SECTION 1 — SUMMARY
  Atoms scanned                  : <n>
  Ship-ready (A, hygiene 100)    : <n>
  Solid (B)                      : <n>
  Needs work (C)                 : <n>
  Blocked (D/F or hygiene fail)  : <n>
  Near-duplicate clusters        : <n>
  Domain-named shells            : <n>
  Wrapper-of-primitive (DELETE)  : <n>
  Structural-duplicate clusters  : <n>
  Hardcoded-value sites          : <n>
  TanStack-contract violations   : <n>
  Library-policy violations      : <n>
  A11y defects (Critical / High) : <n> / <n>
  Reconciliation entries         : <n> (unfoldered <n>, misnamed <n>, mismatch <n>, stray <n>, tier-mismatch <n>)
  Tier-placement contracts       : <n>/<n> satisfied across all tiers (per Section 0)

SECTION 2 — PER-ATOM GRADES (alphabetized)
  ✅ A   atoms/Button       coverage 95  quality 92  hygiene 100
  ⚠️  C   atoms/Tag          coverage 82  quality 70  hygiene 100
  ❌ F   atoms/Avatar       coverage 60  quality 64  hygiene FAIL (hardcoded #3B82F6)
  ❌ F   atoms/Switch       coverage 88  quality 85  hygiene FAIL (no forwardRef)
  …

SECTION 3 — DOMAIN-COUPLING / GENERICNESS DEFECTS
  (from atomic-auditor mode=genericness-only HANDOFF, joined with component-deduplicator output for MERGE rows)

  DELETE candidates (pure wrappers; component is just <Primitive ... /> with no behavior of its own):
    - atoms/<Name>  →  use <Primitive ... />  directly. Canonical replacement expression cited verbatim.

  RENAME-AND-SLOT (domain-named shells whose body is a primitive shape):
    - atoms/<DomainName>  →  rename to <Primitive><Slot>; required slots: <list>; canonical name: <Name>.

  MERGE-INTO-PRIMITIVE (cross-reference component-deduplicator structural clusters):
    - cluster <id>: { atoms/A, atoms/B, atoms/C, atoms/D, atoms/E }
        canonical primitive: <Primitive>
        merge plan: collapse all five into <Primitive> with variant prop <propName>.

  PROMOTE-TO-PRIMITIVE (right shape, wrong name):
    - atoms/<DomainName>  →  promote to atoms/<Primitive>; rename consumers.

SECTION 4 — DUPLICATE CLUSTERS
  (paste component-deduplicator output)

SECTION 5 — DEPRECATED / UNUSED
  atoms/OldButton — last modified 2023, no imports found, marked @deprecated
                    → propose deletion
  atoms/Spinner.legacy.tsx — duplicated by atoms/Spinner → propose deletion

SECTION 5b — RECONCILIATION QUEUE (file/folder convention violations)
  Read directly from inventory.json `reconciliation` array. Group by `kind`.
  Each entry must include path, current vs expected, and the mechanical fix.

  unfoldered (atoms at tier root without enclosing folder):
    - src/components/atoms/Tag.tsx
        expected: atoms/Tag/Tag.tsx
        fix: mkdir atoms/Tag && git mv ...

  misnamed-folder (lowercase / kebab-case folder name):
    - src/components/atoms/searchbar
        expected: PascalCase folder name (SearchBar)
        fix: git mv atoms/searchbar atoms/SearchBar

  misnamed-file (file name does not match expected casing):
    - src/components/atoms/searchbar/searchbar.tsx → SearchBar.tsx

  folder-name-mismatch (Foo/Bar.tsx — folder and primary export disagree):
    - src/components/molecules/Card/CardHeader.tsx
        decision required: rename to Card.tsx, or split into molecules/CardHeader/

  stray-component (looks like a component but lives outside any tier folder):
    - src/components/Stray/Stray.tsx
        decision required: classify and move into the correct tier folder

  tier-mismatch-by-signal (atom imports molecule/organism, etc.):
    - src/components/atoms/BadAtom/BadAtom.tsx
        signal: imports molecules/Card
        fix: reclassify as molecule OR remove the higher-tier imports

  Severity rule: misnamed-* and unfoldered are `warn` (block ship-ready
  status); folder-name-mismatch is `info` (recommendation); tier-mismatch
  and stray are `block` once promoted to action plan.

SECTION 6 — TOKEN GAPS
  (paste design-token-enforcer output, summary + top offenders)

SECTION 7 — TANSTACK-CONTRACT VIOLATIONS
  Atom must accept value + onChange(value) + onBlur + aria-invalid + aria-describedby + forwardRef.
  Violations:
    [V1] atoms/Input/Input.tsx:18  — emits onChange(event) instead of onChange(value)
    [V2] atoms/Switch/Switch.tsx   — not forwarding refs
    [V3] atoms/Combobox/Combobox.tsx:34 — no aria-describedby plumbing
  (full list from library-policy-enforcer Section 3 above; cited verbatim here)

SECTION 8 — ACCESSIBILITY DEFECTS
  Critical (block merge):
    - atoms/IconButton: missing accessible name (no aria-label, no children text)
    - atoms/Switch: aria-checked not synced with controlled value
  High:
    - atoms/Input: visible focus indicator below 3:1 contrast
  Medium:
    - atoms/Toast: no prefers-reduced-motion guard
  …

SECTION 9 — PRIORITIZED ACTION PLAN
  Block 0 — Surface reduction (do these FIRST; they moot a lot of Block 1 work):
    0a. DELETE wrapper components (Section 3 DELETE candidates) — replace usages with the primitive expression cited.
    0b. RENAME-AND-SLOT domain shells (Section 3 RENAME-AND-SLOT) — rename component, expose slot props, update consumers.
  Block 1 — Hygiene blockers (must fix before merge):
    1. Fix TanStack-contract violations (3 atoms — see Section 7).
    2. Replace 47 hardcoded colors with semantic tokens (design-token-enforcer can apply).
    3. Fix Critical a11y defects (accessibility-reviewer Block 1).
    4. Reconcile tier-mismatch atoms (Section 5b — atom imports molecule).
    5. Reconcile stray-component files (Section 5b — classify and move).
  Block 2 — Coverage / quality work:
    6. Add missing stories per atom (graded list in Section 2).
    7. Add MDX docs for atoms with quality < 80.
  Block 3 — Consolidation + naming:
    8. Merge structural-duplicate clusters into canonical primitive (Section 3 MERGE-INTO-PRIMITIVE).
    9. Merge near-duplicate atoms (Section 4).
   10. Delete deprecated atoms (Section 5).
   11. Fold unfoldered atoms into Name/Name.tsx layout (Section 5b — unfoldered).
   12. Rename misnamed files/folders to PascalCase (Section 5b — misnamed-*).
   13. Resolve folder-name-mismatch entries (Section 5b — folder-name-mismatch).

SECTION 10 — DIFF VS BASELINE  (only if baseline existed)
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

1. **Baseline** — `<scope>/.anvil/baseline-atoms.md`
   - **First run** (Step 0g reported `BASELINE: not present`): write without prompting.
   - **Subsequent runs** with `--auto-baseline=replace`: silently overwrite.
   - **Subsequent runs** with `--auto-baseline=history-only`: skip baseline write; only update history.
   - **Subsequent runs** with `--auto-baseline=prompt` (default): prompt — *"Replace baseline-atoms.md? (y / n / save-as-history-only)"*. If `--no-prompt` is also set, treat as `replace` when this run is strictly better than baseline (more A grades, fewer hygiene fails, fewer hardcoded sites, fewer reconciliation entries) and `history-only` otherwise.
2. **Dated history (additive, never overwritten)** — `<scope>/.anvil/history/atoms-<YYYY-MM-DD>.md`. Always written, even when the user declined to update the baseline.

Both contain the synthesis report.

## Operating rules

1. **READ ONLY for source files; Write only for audit artifacts** (baseline + history + HANDOFF + inventory.json). No edits to component code.
2. **BE EXHAUSTIVE.** Every atom in the inventory gets a grade — no sampling. Every reconciliation entry surfaces in Section 5b — no quiet drops.
2a. **GENERICNESS IS A HYGIENE AXIS.** A domain-named shell that exposes no slot props is a hygiene fail. A pure wrapper-of-primitive (DELETE verdict from atomic-auditor mode=genericness-only) is a hygiene fail. Both force the affected atom to BLOCKED status regardless of coverage / token / a11y scores.
3. **CITE EVERY DEFECT** — `path:line` in Sections 5, 6, 7. Section 4b cites `path` (and folder) for every reconciliation entry.
4. **HONOR `rubricOverrides`** — surface Phase 0a detections at Section 0; grade against them, not the skill defaults.
5. **DON'T DOUBLE-COUNT BASELINE BREAKAGE** — Phase 0b's pre-existing failures stay in their own block; never roll them into atom-defect counts.
6. **PARALLELIZE WHERE SAFE** — Step 1 sequential; Step 2 batched parallel (or skipped under `--static-only`); Step 3 four-way parallel.
7. **HANDOFF CONTRACT** — every subagent must write a HANDOFF.md and print `HANDOFF: <path>`. If missing within 90s, fall through to inline-fallback (Step 1) instead of halting outright.
8. **HONOR --auto-baseline** — only prompt when the flag is `prompt` AND `--no-prompt` is unset.
9. **DESTRUCTIVE ACTIONS** — deletion of "deprecated" atoms requires explicit user approval with file paths printed.

## Failure modes

- **Atoms folder doesn't exist.** Phase 0e's scanner returns 0 atoms; fall back to the cartographer's discover-by-signal flow.
- **No stories at all.** Report it loudly; the audit becomes a "where to start" plan.
- **Cartographer stalls.** After 90s without HANDOFF, run the inline-cartography fallback (Step 1) — never let a stalled agent block the rest of the audit.
- **Subagent times out.** Retry once; if it fails twice, mark the affected atoms `INCOMPLETE` and continue.
- **Pre-existing typecheck/lint/test failure.** Surface in Section 0b with explicit "NOT counted against atom defects" caveat.
- **Inventory.json missing.** Phase 0e regenerates it; if even that fails, halt with the scanner's stderr.

## Memory

Append a one-liner to `.claude/agent-memory/audit-atoms/history.log` using a generated timestamp (e.g. `date -Iseconds` via Bash) and the actual counts from this run. The shape:

```text
<timestamp> audit-atoms scope=<scope> run=<run-id> graded=<n> A=<n> B=<n> C=<n> D=<n> F=<n> hygiene_fail=<n>
```

The values must be computed from the run, not copied from this template. Subsequent runs can compare deltas without re-reading baselines.
