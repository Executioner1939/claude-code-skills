---
description: Run a structured codebase archaeology and (optionally) a transformation plan against an existing codebase. Two-agent pipeline -- archaeologist excavates what IS, strategist plans what to DO. Read-only analysis. Every finding traces to file:line. Use when the user wants to understand inherited code, plan a migration / restructuring / decomposition, audit for risk, build documentation, derive a test strategy, or remediate technical debt.
argument-hint: "[path] [--objective=migration|architecture|decomposition|risk|documentation|test-strategy|debt|general]"
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(mkdir:*)
  - Bash(date:*)
  - Bash(pwd)
  - Bash(test:*)
  - Bash(echo:*)
  - Bash(awk:*)
  - Bash(sed:*)
  - Bash(grep:*)
  - Bash(cut:*)
  - Bash(jq:*)
  - Agent(codebase-archaeologist)
  - Agent(transformation-strategist)
model: claude-opus-4-7
---

# Codebase Archaeology Workflow

You are orchestrating a two-agent codebase analysis. Both subagents auto-load the `codebase-archaeology` skill (lens table, layer/phase models, template inventory). Do **not** restate that methodology in your envelopes -- the agents already have it. Your job is scope, dispatch, review, and synthesis.

The two agents are read-only. The whole workflow is read-only. No files under `<path>` are touched.

## Inputs

`$ARGUMENTS` is `[path] [--objective=<one-of-eight>]`.

Resolve at the top of the run:

```!
PATH_ARG=$(printf '%s' "$ARGUMENTS" | awk '{print $1}')
OBJECTIVE=$(printf '%s' "$ARGUMENTS" | grep -oE -- '--objective=[a-z-]+' | cut -d= -f2)
case "$PATH_ARG" in ''|--*) PATH_ARG="$(pwd)";; esac
test -d "$PATH_ARG" || { echo "ERROR: $PATH_ARG is not a directory"; exit 1; }
TIMESTAMP=$(date +%Y%m%dT%H%M%S)
OUTDIR="$PATH_ARG/.archaeology/$TIMESTAMP"
mkdir -p "$OUTDIR/archaeology" "$OUTDIR/strategy"
echo "PATH=$PATH_ARG"
echo "OBJECTIVE=${OBJECTIVE:-(unset, will ask user)}"
echo "OUTDIR=$OUTDIR"
echo "TIMESTAMP=$TIMESTAMP"
```

`OUTDIR` is the canonical run directory. All deliverables land under it.

## Phase 0 -- Determine objective

If `--objective` was passed, use it. Otherwise read the lens table in `${CLAUDE_PLUGIN_ROOT}/skills/codebase-archaeology/SKILL.md` and ask the user **one** clarifying question listing all eight options. Do not guess.

Multi-objective is allowed (e.g. "migrate AND assess debt"). If chosen, record both lens names; the archaeologist composes them.

Map objective to lens:

| Objective | Lens |
|---|---|
| `migration` | `migration-lens` |
| `architecture` | `architecture-lens` |
| `decomposition` | `decomposition-lens` |
| `risk` | `risk-lens` |
| `documentation` | `documentation-lens` |
| `test-strategy` | `test-strategy-lens` |
| `debt` | `debt-lens` |
| `general` | (none -- core templates only) |

**Acceptance for Phase 0:** scope path verified existing, single objective recorded (or composed list), lens(es) identified.

## Phase 1 -- Dispatch the codebase-archaeologist

Use the Task tool to dispatch agent `codebase-archaeologist` with the prompt below verbatim. Substitute the bracketed values from Phase 0. Do not edit the structure -- the envelope shape is the contract.

```
## goal
Produce a complete archaeology of <PATH_ARG>, structured per the codebase-archaeology skill's templates, with the <LENS> lens applied.

## inputs
- path: { type: path, value: <PATH_ARG> }
- objective: { type: enum<migration|architecture|decomposition|risk|documentation|test-strategy|debt|general>, value: <OBJECTIVE> }
- lenses_to_apply: { type: list<string>, value: [<LENS>] }
- output_dir: { type: path, value: <OUTDIR>/archaeology }

## context
- path: ${CLAUDE_PLUGIN_ROOT}/skills/codebase-archaeology/SKILL.md
  why: lens table + template inventory; do not re-derive
  do_not_re_derive: true
- path: ${CLAUDE_PLUGIN_ROOT}/skills/codebase-archaeology/references/templates/core.md
  why: base output templates (read on demand)
  do_not_re_derive: true
- path: ${CLAUDE_PLUGIN_ROOT}/skills/codebase-archaeology/references/templates/<LENS>.md
  why: lens-specific output templates (read on demand; skip for objective=general)
  do_not_re_derive: true

## constraints
must:
  - read every business rule from actual source, not from filenames
  - cite file:line for every finding
  - rate confidence HIGH | MEDIUM | LOW with justification
  - work iteratively: report Layer 1, then Layer 2, etc. -- do not produce a single-shot report
  - declare KNOWN_UNKNOWNS prominently
  - cluster LOW_CONFIDENCE findings into their own sub-section
must_not:
  - call Write or Edit (read-only mode)
  - prescribe target architecture
  - silently omit a layer that does not apply -- write "N/A -- [reason]" instead

## out_of_scope
- writing tests, fixes, or any code
- renaming, refactoring, or reformatting
- benchmarking the code
- modifying anything under <PATH_ARG>

## acceptance
- Layer 1 through Layer 5 sections each present (with findings or "N/A -- [reason]")
- ARCHAEOLOGY REPORT template populated and saved at <OUTDIR>/archaeology/archaeology-report.md
- Lens-specific section populated when a lens was applied
- KNOWN_UNKNOWNS section listed prominently
- LOW_CONFIDENCE rules separated into their own sub-section

## output_format
markdown_sections:
  - ARCHAEOLOGY REPORT
  - BUSINESS RULES (by RULE_ID)
  - DATA FLOWS (by FLOW_ID)
  - DEPENDENCIES (by DEP_ID)
  - RISK SCORES
  - KNOWN_UNKNOWNS
  - LOW_CONFIDENCE
  - (lens-specific sections per the chosen lens)
schema_ref: ${CLAUDE_PLUGIN_ROOT}/skills/codebase-archaeology/references/templates/core.md

## handoff
write_to: <OUTDIR>/archaeology/archaeology-report.md
```

The agent works iteratively. If it pauses for scope clarification, forward the question to the user verbatim and pass the answer back. Do not answer on the user's behalf.

## Phase 2 -- Review the archaeology output

Validate the deliverable mechanically against the Phase 1 acceptance list (file exists, all sections present, every finding has file:line + confidence). If anything is missing, kick back to the agent with a targeted re-dispatch.

Then run a deeper review. Take time to think through:

1. Are there `KNOWN_UNKNOWNS` that are *load-bearing for the objective*? (External services for a migration. Unqueryable database state for a decomposition. These matter; for a `documentation` objective they may not.)
2. Are `LOW_CONFIDENCE` rules clustered in modules that are *critical-path for the objective*? Two LOW_CONFIDENCE rules in dead code is fine; two in the billing engine during a migration is not.
3. Does the lens-specific section answer the question the user actually asked?

If gaps are significant, dispatch a **targeted re-analysis** -- a new envelope whose `path` is the narrower scope, whose `goal` references the specific gap, and whose `output_dir` is `<OUTDIR>/archaeology/followup-<n>`. Cap targeted re-analyses at 2 iterations to avoid loops.

If gaps are manageable, proceed to Phase 3 with the gaps recorded for the index's "Caveats" section.

**Acceptance for Phase 2:** every load-bearing question for the objective is answered or explicitly flagged as KNOWN_UNKNOWN with reason.

## Phase 3 -- Plan the transformation (conditional)

Skip Phase 3 entirely if `OBJECTIVE` is `documentation`, `test-strategy`, or `general` without follow-up request. The archaeology output is the deliverable in those cases.

For `migration`, `architecture`, `decomposition`, `risk`, or `debt`, dispatch agent `transformation-strategist` with this envelope:

```
## goal
Produce an actionable <OBJECTIVE> plan for <PATH_ARG>, derived from the archaeology artifacts at <OUTDIR>/archaeology/archaeology-report.md.

## inputs
- archaeology_report: { type: path, value: <OUTDIR>/archaeology/archaeology-report.md }
- objective: { type: enum<migration|architecture|decomposition|risk|debt>, value: <OBJECTIVE> }
- target_state: { type: string?, value: <user-stated target, or null> }
- output_dir: { type: path, value: <OUTDIR>/strategy }

## context
- path: ${CLAUDE_PLUGIN_ROOT}/skills/codebase-archaeology/SKILL.md
  why: methodology shared with archaeologist; do not re-derive
  do_not_re_derive: true
- path: ${CLAUDE_PLUGIN_ROOT}/skills/codebase-archaeology/references/templates/transformation-plan.md
  why: planning output templates
  do_not_re_derive: true

## constraints
must:
  - take archaeology as source of truth; do not re-analyze source
  - classify every relevant element: NATURAL_FIT | FORCED_FIT | RESISTS_MAPPING | INVARIANT | ELIMINATED
  - define a stable, deployable interim state per phase
  - derive verification tests from archaeology business rules (cite RULE_IDs)
  - surface DECISIONS_REQUIRED -- do not choose for the user
must_not:
  - read source files directly (the archaeology is your truth)
  - prescribe architectures the user did not request
  - minimize complexity ("simply", "just", "straightforward") -- HARD_TRUTHS exists for a reason

## out_of_scope
- executing the plan
- writing code
- recommending tools or libraries unless directly required by the target state

## acceptance
- GAP_ANALYSIS section present (validates archaeology is sufficient)
- MAPPING_ANALYSIS classifies every relevant archaeology element
- SEQUENCING with explicit interim states per phase
- VERIFICATION_STRATEGY tied to archaeology RULE_IDs
- RISK_REGISTER with mitigation and detection per risk
- HARD_TRUTHS section closing the document
- DECISIONS_REQUIRED listed prominently for the human

## output_format
markdown_sections:
  - GAP ANALYSIS
  - MAPPING ANALYSIS
  - SEQUENCING
  - VERIFICATION STRATEGY
  - RISK REGISTER
  - HARD TRUTHS
  - DECISIONS REQUIRED
schema_ref: ${CLAUDE_PLUGIN_ROOT}/skills/codebase-archaeology/references/templates/transformation-plan.md

## handoff
write_to: <OUTDIR>/strategy/transformation-plan.md
```

If the strategist surfaces `DECISIONS_REQUIRED`, forward them to the user verbatim as soon as they appear. Do not let the agent invent answers.

**Acceptance for Phase 3:** `<OUTDIR>/strategy/transformation-plan.md` exists, all 7 sections present, every NATURAL_FIT / FORCED_FIT / RESISTS_MAPPING claim cites the archaeology element it derives from.

## Phase 4 -- Final deliverable

Write a top-level index at `<OUTDIR>/index.md` with this shape:

```markdown
# Codebase Archaeology -- <TIMESTAMP>

**Path analyzed:** <PATH_ARG>
**Objective:** <OBJECTIVE>
**Lenses applied:** <LENS list>

## Executive summary

<= 200 words: what was found, what's recommended, what blocks the user>

## Artifacts

- [Archaeology report](archaeology/archaeology-report.md)
- [Transformation plan](strategy/transformation-plan.md)   <!-- omit if Phase 3 was skipped -->

## Headline findings

- <3-7 bullets, each citing a RULE_ID, FLOW_ID, or DEP_ID>

## What the human must decide

<DECISIONS_REQUIRED, copied verbatim from the strategy plan if Phase 3 ran>

## Caveats

<KNOWN_UNKNOWNS that mattered + any Phase-2 gap-analysis notes>
```

Print to chat:
- The path to `<OUTDIR>/index.md`
- Counts: rules / flows / dependencies / risks
- The decision queue

Do **not** re-paste the full reports in chat -- the user opens the files.

**Acceptance for the whole run:**
- `<OUTDIR>/index.md` exists and links resolve
- `<OUTDIR>/archaeology/archaeology-report.md` exists
- If Phase 3 ran: `<OUTDIR>/strategy/transformation-plan.md` exists
- DECISIONS_REQUIRED surfaced to the user (not buried in a file)
- Every section in this command's output spec appears in the index

## Whole-workflow constraints

- Both agents are read-only. The command is read-only.
- Every claim cites file:line.
- KNOWN_UNKNOWNS are first-class output.
- "Stop the world and rewrite" is never the answer; phases must define stable interim states.
- `<OUTDIR>` is the only writable area, and only the agents (via their `handoff.write_to`) plus this command's index file write to it.
