---
name: audit-component
description: Audit one component end-to-end (coverage, quality, hygiene, genericness, a11y, tokens, library policy) AND surface every repeated occurrence of each finding elsewhere in the codebase, so the same fix can be applied uniformly. The premise is that one defect found in one component is almost always a pattern repeated across the codebase -- this command makes the propagation explicit. Tier-aware (atom / molecule / organism); reuses the per-tier audit machinery scoped to a single component, then sweeps the rest of the codebase for the same patterns. Output is a 6-section component report with a propagation matrix that names every other component exhibiting each pattern. Inter-agent HANDOFF.md contract. Invoke as `/anvil:audit-component <path-to-component>` -- optionally pass mode flags `--no-sweep` (skip cross-codebase pattern sweep), `--no-prompt` (run without interactive confirmations).
disable-model-invocation: true
argument-hint: "<component-path> [--no-sweep] [--no-prompt]"
arguments: component_path
allowed-tools: Read, Grep, Glob, Bash, Agent, Write
model: claude-opus-4-7
---

# Audit: Single component, with cross-codebase pattern propagation

The unit is one component; the value is propagation. When `Button.tsx` has a hardcoded `#FF6B6B`, the same literal probably appears elsewhere; when `WishlistButton` is a thin wrapper of `<Button>`, other domain-named wrappers probably exist; when this component lacks a `Focus` story, others at the same tier are likely missing one too. This command makes that explicit -- you fix the target, then propagate using the matrix it produces.

Argument: `$component_path` -- absolute or repo-relative path to the component's directory or its index file (e.g., `src/components/atoms/Button` or `src/components/atoms/Button/Button.tsx`).

Mode flags (parsed from `$component_path` if present, else defaulted):
- `--no-sweep` -- audit the target component only; skip the cross-codebase pattern sweep. Faster but loses the propagation matrix.
- `--no-prompt` -- run end-to-end without interactive confirmations.

## Step 0 -- Pre-flight

Same five sub-phases as `/anvil:audit-atoms` Step 0, scoped down. Run in order; each feeds the next.

### 0a -- Resolve and classify the target

Resolve the path:

```!
set -e
TARGET=$(printf '%s' "$ARGUMENTS" | awk '{print $1}')
case "$TARGET" in
  --*) TARGET="";;
esac
test -n "$TARGET" || { echo "ABORT: component path is required. Usage: /anvil:audit-component <path-to-component>"; exit 0; }
test -e "$TARGET" || { echo "ABORT: component not found at $TARGET"; exit 0; }

# If a single file was passed, escalate to its directory unless the dir has multiple components.
if test -f "$TARGET"; then
  TARGET_DIR=$(dirname "$TARGET")
else
  TARGET_DIR="$TARGET"
fi

# Tier inference from path (atoms / molecules / organisms / templates / pages).
TIER=$(printf '%s' "$TARGET_DIR" | sed -nE 's|.*/components/(atoms|molecules|organisms|templates|pages)/.*|\1|p')
[ -z "$TIER" ] && TIER="unknown"

# Component name from the directory (or filename if a singleton file).
COMPONENT_NAME=$(basename "$TARGET_DIR")

# Project root: walk up until we see package.json or .git/.
PROJECT_ROOT="$TARGET_DIR"
while [ "$PROJECT_ROOT" != "/" ] && [ ! -f "$PROJECT_ROOT/package.json" ] && [ ! -d "$PROJECT_ROOT/.git" ]; do
  PROJECT_ROOT=$(dirname "$PROJECT_ROOT")
done
[ "$PROJECT_ROOT" = "/" ] && PROJECT_ROOT=$(pwd)

# Inventory (refreshed by the plugin's PostToolUse hook).
INVENTORY="$PROJECT_ROOT/.anvil/inventory.json"
test -f "$INVENTORY" || INVENTORY=""

TIMESTAMP=$(date +%Y%m%dT%H%M%S)
RUN_ID="audit-component-${COMPONENT_NAME}-${TIMESTAMP}"
HANDOFF_DIR="$PROJECT_ROOT/.anvil/handoffs/$RUN_ID"
REPORT_PATH="$PROJECT_ROOT/.anvil/audits/component-${COMPONENT_NAME}-${TIMESTAMP}.md"
mkdir -p "$HANDOFF_DIR" "$(dirname "$REPORT_PATH")"

cat <<EOF
BOOTSTRAP_OK=1
TARGET=$TARGET
TARGET_DIR=$TARGET_DIR
COMPONENT_NAME=$COMPONENT_NAME
TIER=$TIER
PROJECT_ROOT=$PROJECT_ROOT
INVENTORY=${INVENTORY:-(absent)}
HANDOFF_DIR=$HANDOFF_DIR
REPORT_PATH=$REPORT_PATH
TIMESTAMP=$TIMESTAMP
RUN_ID=$RUN_ID
EOF
```

If the bootstrap output begins with `ABORT:`, halt and print the message verbatim.

If `TIER=unknown`, ask the user once which tier to treat the component as. Don't guess -- some checks are tier-conditional (organisms must have Empty/Loading/Error; molecules must accept TanStack `field`; atoms must use `forwardRef`).

### 0b -- Project rubric detection

Read these in parallel and emit a `Project rubric overrides` block at the top of the synthesis report:

| Source | What to detect |
|---|---|
| `<PROJECT_ROOT>/CLAUDE.md` and `<TARGET_DIR>/CLAUDE.md` | Documented conventions -- MDX layout, form contract, tier placement, lint exceptions. Authoritative. |
| `<PROJECT_ROOT>/package.json` | Framework, styling, form library. |
| `<PROJECT_ROOT>/eslint.config.{js,mjs,ts}` | `no-restricted-syntax` / `no-restricted-imports` rules that may trip this tier's code. |
| `<PROJECT_ROOT>/tokens.css` / Tailwind config | Globally-gated `prefers-reduced-motion`, semantic-token availability. |
| `<PROJECT_ROOT>/src/docs/` shape | MDX convention -- per-component vs per-category vs none. |
| `<PROJECT_ROOT>/**/component-contracts/*.ts` | Contract-implementing tier map. |

This block is the **single source of truth** for grading. Every dispatched agent reads it before scoring.

### 0c -- Baseline integrity probe

Same probe as `audit-atoms` Step 0b. Quarantine pre-existing breakage so it doesn't count against this component's defect totals:

```bash
( cd "$PROJECT_ROOT" && pnpm typecheck 2>&1 | tail -5 ) || true
( cd "$PROJECT_ROOT" && pnpm lint 2>&1 | tail -5 ) || true
( cd "$PROJECT_ROOT" && pnpm test:stories --run --reporter=basic 2>&1 | tail -10 ) || true
```

Surface failures in a `BASELINE INTEGRITY` block. Pre-existing failures are NOT counted against this component's defects.

## Step 1 -- Deep audit of the target component (parallel dispatch)

Dispatch six agents in parallel via the Task tool. Each receives this envelope, with `target_path` set to `<TARGET_DIR>` and `tier` set to the resolved tier:

```
## goal
Audit the single component at <TARGET_DIR> from your axis. Produce findings scoped to this component only -- do not survey the codebase yet (that is Step 3's job).

## inputs
- target_path: { type: path, value: <TARGET_DIR> }
- tier: { type: enum<atom|molecule|organism|template|page>, value: <TIER> }
- component_name: { type: string, value: <COMPONENT_NAME> }
- inventory_path: { type: path?, value: <INVENTORY or null> }
- rubric_overrides: { type: file_contents, value: <Project rubric overrides block from Step 0b> }
- handoff_dir: { type: path, value: <HANDOFF_DIR> }

## context
- path: ${CLAUDE_PLUGIN_ROOT}/skills/<your auto-loaded skills>
  why: methodology you already have via your skills: frontmatter
  do_not_re_derive: true
- path: <PROJECT_ROOT>/CLAUDE.md
  why: project-specific overrides
  do_not_re_derive: true

## constraints
must:
  - cite file:line for every finding
  - flag findings as PATTERN-ELIGIBLE when the same shape could exist elsewhere (literal, import, render-shape, naming-prefix, missing-artifact, coupling)
  - rate severity (BLOCKING / NEEDS-WORK / NIT)
  - write a HANDOFF.md to <handoff_dir>/phase-1-<your-name>-to-synthesis.md and end your output with `HANDOFF: <path>`
must_not:
  - audit other components (single-component scope)
  - prescribe fixes outside this component (the synthesis step does propagation)

## out_of_scope
- proposing migrations across the codebase (Step 4 does that)
- refactoring this component (read-only audit)

## acceptance
- output covers your axis end-to-end against this component
- every finding has file:line + severity + pattern-eligibility flag
- HANDOFF.md written; final line is `HANDOFF: <path>`

## output_format
markdown_sections:
  - "AXIS: <your-name>"
  - "FINDINGS"
  - "PATTERN-ELIGIBLE FINDINGS"
  - "HANDOFF"
```

Six agents to dispatch (skip storybook-coverage-analyst for tier=atom unless atom-tier coverage matters in this project):

| Agent | Axis |
|---|---|
| `atomic-auditor` mode=default | Coverage / Quality / Hygiene / Composite |
| `atomic-auditor` mode=genericness-only | Genericness (domain-prefix, wrapper-of-primitive, slot-acceptance, boil-down) |
| `accessibility-reviewer` | WCAG 2.2 AA + WAI-ARIA APG; focus / keyboard / contrast / screen-reader |
| `design-token-enforcer` | Hardcoded values; token-mapping refactor candidates |
| `library-policy-enforcer` | Approved-libraries policy; TanStack-integration prop-shape contract |
| `component-cartographer` | Inventory facts (consumers, dependencies, props signature, render-shape signature) |

Wait for all six to return. If any agent fails or returns an empty HANDOFF, retry once with a tighter prompt; if the retry also fails, log to `<HANDOFF_DIR>/_failures.log` and proceed with reduced coverage (note in the final report).

## Step 2 -- Pattern extraction

From the per-agent `PATTERN-ELIGIBLE FINDINGS` sections, extract a list of repeatable patterns. Each pattern is one of these types:

| Type | Examples |
|---|---|
| `LITERAL` | Hardcoded color hex (`#FF6B6B`), hardcoded spacing (`16px`), magic number (`maxAttempts: 3`), hardcoded font-family. |
| `IMPORT` | Forbidden library import (`import _ from 'lodash'`), off-policy form library (`react-hook-form` when project uses TanStack Form), legacy package (`@storybook/addon-essentials`). |
| `STRUCTURAL` | Render-shape signature (e.g., `<Card><CardHeader/><CardBody/><CardFooter/></Card>` — same shape across multiple components suggests a primitive-cluster). |
| `DOMAIN` | Domain-prefix in component name (`BookingShell`, `KYCStatus`) — pattern: `<Domain><Suffix>` shells. |
| `WRAPPER` | Thin wrapper of a primitive (component body is `<Button>{children}</Button>` with no added value). |
| `MISSING` | Missing required artifact (no `Focus` story; no `Empty/Loading/Error` for organisms; no MDX page). |
| `COUPLING` | Tight coupling to a specific data shape, route, or singleton (e.g., reads `useCurrentUser()` directly inside an atom). |

For each finding flagged `PATTERN-ELIGIBLE` in Step 1, abstract its concrete instance into a pattern. Worked example:

```
Finding (from design-token-enforcer):
  src/components/atoms/Button/Button.tsx:42 — hardcoded color #FF6B6B in shadow declaration

Pattern:
  type: LITERAL
  signature: hardcoded color literal
  concrete_value: "#FF6B6B"
  search_method: grep -rn '#FF6B6B' src/
  remediation: replace with var(--color-accent-warm-60) (nearest match)
```

Build a list `PATTERNS = [{type, signature, concrete_value, search_method, remediation}, ...]`.

If `--no-sweep` is set, skip Step 3 and move to Step 4 (the report includes Section 3 with "(skipped per --no-sweep)" placeholder).

## Step 3 -- Cross-codebase pattern sweep

For each pattern in `PATTERNS`, find every other location in the codebase that exhibits the same pattern. Dispatch by pattern type:

### LITERAL patterns (Bash tool, parallel)

```bash
grep -rn --include='*.{ts,tsx,js,jsx,css,scss}' -- "<concrete_value>" "$PROJECT_ROOT/src/" | grep -v "$TARGET_DIR"
```

Record the file:line of each occurrence. Group by file. Exclude the target component (it is the source).

### IMPORT patterns (Bash tool, parallel)

```bash
grep -rn --include='*.{ts,tsx,js,jsx}' -- "<import statement signature>" "$PROJECT_ROOT/src/" | grep -v "$TARGET_DIR"
```

### STRUCTURAL patterns (component-deduplicator, single dispatch with all structural patterns batched)

```
## goal
Find every component in <PROJECT_ROOT> whose render-shape signature matches one of the supplied target shapes (≥ 0.95 similarity by structural-cluster threshold; ≥ 0.65 if family-suffix match per the genericness-rubric skill).

## inputs
- mode: { type: enum<structural|composite>, value: structural }
- project_root: { type: path, value: <PROJECT_ROOT> }
- target_shapes: { type: list<{component, shape_signature, family_suffix?}>, value: <list from PATTERNS where type=STRUCTURAL> }
- exclude_target: { type: path, value: <TARGET_DIR> }

## context
- path: ${CLAUDE_PLUGIN_ROOT}/skills/genericness-rubric/SKILL.md
  why: structural-cluster detection threshold + family-suffix list
  do_not_re_derive: true

## acceptance
- output is a JSON list of { pattern_id, matching_components: [{path, similarity_score, family_suffix_match}] }
- every match has similarity_score >= threshold
- target component is not in matching_components for any pattern

## output_format
json
```

### DOMAIN / WRAPPER patterns (component-cartographer, single dispatch)

```
## goal
Scan <PROJECT_ROOT>'s component inventory for components matching the supplied DOMAIN-prefix patterns and WRAPPER-of-primitive patterns (per the genericness-rubric skill's domain-prefix regex and wrapper-of-primitive heuristics).

## inputs
- project_root: { type: path, value: <PROJECT_ROOT> }
- inventory_path: { type: path?, value: <INVENTORY or null> }
- domain_patterns: { type: list<string>, value: <list from PATTERNS where type=DOMAIN> }
- wrapper_patterns: { type: list<{wrapped_primitive, signature}>, value: <list from PATTERNS where type=WRAPPER> }
- exclude_target: { type: path, value: <TARGET_DIR> }

## context
- path: ${CLAUDE_PLUGIN_ROOT}/skills/genericness-rubric/SKILL.md
  do_not_re_derive: true

## acceptance
- output JSON: per-pattern matching components with file:line and which probe (domain-prefix / wrapper-of-primitive) triggered
- excludes the target component
```

### MISSING patterns (storybook-coverage-analyst, single dispatch)

```
## goal
Find every component at the same tier as <COMPONENT_NAME> that is missing the artifact(s) the target was missing.

## inputs
- tier: { type: enum<atom|molecule|organism|template|page>, value: <TIER> }
- missing_artifacts: { type: list<string>, value: <list from PATTERNS where type=MISSING; e.g., ["Focus story", "MDX page", "Empty state"]> }
- project_root: { type: path, value: <PROJECT_ROOT> }
- exclude_target: { type: path, value: <TARGET_DIR> }

## acceptance
- output JSON: per missing-artifact, list of components also missing it
```

### COUPLING patterns (Grep tool, ad-hoc)

For each coupling pattern (e.g., "reads `useCurrentUser()` inside an atom"), grep for the coupling signature across the codebase. Group results by tier so the report can flag tier-violation cases.

Wait for all sweep dispatches to return. Aggregate into a single `OCCURRENCES` map keyed by pattern.

## Step 4 -- Synthesis

Use the Write tool to create the report at `<REPORT_PATH>`. Six sections, exactly:

```markdown
# Component audit: <COMPONENT_NAME>

**Tier:** <TIER>
**Path:** `<TARGET_DIR>`
**Project:** `<PROJECT_ROOT>`
**Run:** <RUN_ID>

<Project rubric overrides block from Step 0b>

<BASELINE INTEGRITY block from Step 0c -- if any failures, else omit>

## 1. Component summary

- **Props:** <signature, from cartographer>
- **Consumers:** <count + first 5 with file:line, from inventory>
- **Dependencies:** <list of imported components, from cartographer>
- **Render shape:** <signature, from cartographer>
- **Current grades by axis:**
  - Coverage: <A-F>
  - Quality: <A-F>
  - Hygiene: <A-F>
  - Genericness: <PASS / RENAME-AND-SLOT / DELETE / MERGE-INTO-PRIMITIVE / PROMOTE-TO-PRIMITIVE>
  - Composite: <PASS / NEEDS-WORK / BLOCKED>

## 2. Component defects

Per-axis findings, ordered by severity (BLOCKING first). Each item:
`- [SEVERITY] <axis> -- <description> (<file>:<line>)`

Group by axis with a sub-heading per axis.

## 3. Repeated patterns and where they occur elsewhere

For each pattern in `PATTERNS`, a sub-section:

```
### Pattern: <one-line description>

**Type:** <LITERAL | IMPORT | STRUCTURAL | DOMAIN | WRAPPER | MISSING | COUPLING>
**Signature:** <concrete signature>
**Source in target:** <file:line>
**Recommended remediation:** <fix description>

**Other occurrences (<N>):**
- <path>:<line>  <one-line context>
- <path>:<line>  <one-line context>
- ...

**Propagation effort:** <S | M | L | XL> (S = mechanical / sed-able; M = mostly mechanical with manual review; L = case-by-case; XL = redesign)
```

If `--no-sweep` was set: emit a single placeholder `(cross-codebase sweep skipped per --no-sweep)`.

## 4. Action plan

Sequenced. The target component is fixed first; propagation follows.

```
1. Fix <COMPONENT_NAME> in target order:
   1.1 <BLOCKING defect 1> at <file:line> -- <fix>
   1.2 <BLOCKING defect 2> at <file:line> -- <fix>
   1.3 <NEEDS-WORK defects ...>

2. Propagate <Pattern P1> to <N> other components (effort: <S|M|L|XL>):
   2.1 Apply <fix> at <file:line> in <component A>
   2.2 Apply <fix> at <file:line> in <component B>
   ...

3. Propagate <Pattern P2> to ...

4. Re-run /anvil:audit-component <COMPONENT_NAME> after fixes; verify all defects gone, all patterns no longer eligible.
```

Order patterns within Section 4 by `(occurrences_count * effort_inverse)` -- the highest-leverage propagation first.

## 5. Cross-references

- **Near-duplicate clusters this component participates in:** <from component-deduplicator structural mode, if any>
- **Composes (this -> deps):** <list>
- **Composed-by (this <- consumers):** <list>
- **Tier neighbors with similar shape:** <from cartographer>

## 6. Decisions required

Surface every place the human must choose, derived from agent output (DECISIONS_REQUIRED in atomic-auditor and component-deduplicator outputs):

- **<decision 1>:** <options + tradeoffs>
- **<decision 2>:** <options + tradeoffs>
```

## Step 5 -- Save and summarize

Print to chat:

```
============================================================
  /anvil:audit-component complete
============================================================
  component:    <COMPONENT_NAME> (<TIER>)
  defects:      <count> total; BLOCKING: <n>, NEEDS-WORK: <n>, NIT: <n>
  patterns:     <count> repeatable
  occurrences:  <total cross-codebase occurrences> across <N distinct other components>
  decisions:    <count> require human input

  report:       <REPORT_PATH>
  handoffs:     <HANDOFF_DIR>/

  Recommended next step:
    Apply Section 4 actions in order. Re-run this command after to verify.
============================================================
```

Do **not** auto-update any baseline. Per-component audits are point-in-time; the repo-wide baseline is owned by `/anvil:audit-atoms`, `/anvil:audit-molecules`, `/anvil:audit-organisms`.

If `--no-prompt` was not set and the report contains `BLOCKING` defects, ask the user (in plain text) whether to chain into `/anvil:merge-duplicates` or a tier-level audit. Don't execute without explicit confirmation.

## Whole-workflow constraints

- Read-only on the project tree. Write only to `<PROJECT_ROOT>/.anvil/`.
- The cross-codebase sweep is excludes the target component itself in every pattern's occurrence list.
- Every claim cites `file:line`. Unanchored claims are not allowed.
- HANDOFF.md per dispatched agent. Halt on any agent that fails to print `HANDOFF: <path>` (with one retry).
- One report per run.

## Acceptance for the whole run

- `<REPORT_PATH>` exists with all 6 sections.
- Section 2 covers all six audit axes (or notes `N/A -- [reason]` per axis).
- Section 3 has one sub-section per `PATTERN-ELIGIBLE` finding from Step 1 (or the `--no-sweep` placeholder).
- Section 4 is sequenced and verifiable -- every step references a `file:line`.
- Section 6 is non-empty when DECISIONS_REQUIRED was emitted by any dispatched agent.
- All HANDOFF.md files exist under `<HANDOFF_DIR>/`.
- The summary printed to chat names `<REPORT_PATH>` literally.
