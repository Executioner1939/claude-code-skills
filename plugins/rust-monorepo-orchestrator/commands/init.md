---
description: Discover the current monorepo's stack and (optionally) ingest a reference repository to capture the target architectural standard. Outputs .refactor/stack.json and .refactor/standard.md. Read-only against both the target tree and the reference. Two-phase workflow with a HANDOFF chain. Invoke as `/rust-monorepo-orchestrator:init [<scope>] [--reference=<path>] [--shallow]`.
argument-hint: "[<scope>] [--reference=<path>] [--shallow]"
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
  - Bash(realpath:*)
  - Bash(cat:*)
  - Agent(stack-detective)
  - Agent(reference-ingester)
  - Write
model: claude-opus-4-7
---

# /rust-monorepo-orchestrator:init

Two-phase init workflow. You orchestrate two read-only subagents (`stack-detective`, `reference-ingester`) and write the two output artefacts (`.refactor/stack.json`, `.refactor/standard.md`). You do not analyze the code yourself -- the agents do; you scope, dispatch, review, and synthesize.

The agents auto-load `orchestration-protocol` and `opus-4-7-prompting`. Do not restate those in your envelopes.

## Step 0 -- Resolve arguments

```!
set -e
ARGS=$(printf '%s' "$ARGUMENTS")

# Parse positional scope (first non-flag token, defaults to pwd).
SCOPE=$(printf '%s' "$ARGS" | awk '{ for (i=1;i<=NF;i++) if ($i !~ /^--/) { print $i; exit } }')
case "$SCOPE" in '' | --*) SCOPE="$(pwd)";; esac
test -d "$SCOPE" || { echo "ABORT: scope $SCOPE is not a directory"; exit 0; }
SCOPE=$(cd "$SCOPE" && pwd)

# Parse flags.
REFERENCE=$(printf '%s' "$ARGS" | grep -oE -- '--reference=[^ ]+' | cut -d= -f2 || true)
if [ -n "${REFERENCE:-}" ]; then
  test -d "$REFERENCE" || { echo "ABORT: --reference=$REFERENCE is not a directory"; exit 0; }
  REFERENCE=$(cd "$REFERENCE" && pwd)
fi

MODE="deep"
case " $ARGS " in
  *" --shallow "*) MODE="shallow";;
esac

TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)
RUN_ID="init-${TIMESTAMP}"
REFACTOR="$SCOPE/.refactor"
HANDOFF_DIR="$REFACTOR/handoffs/$RUN_ID"
mkdir -p "$REFACTOR" "$HANDOFF_DIR"

cat <<EOF
BOOTSTRAP_OK=1
SCOPE=$SCOPE
REFERENCE=${REFERENCE:-(none)}
MODE=$MODE
REFACTOR=$REFACTOR
RUN_ID=$RUN_ID
HANDOFF_DIR=$HANDOFF_DIR
TIMESTAMP=$TIMESTAMP
EOF
```

If the bootstrap output begins with `ABORT:`, halt and print the message verbatim.

## Step 1 -- Dispatch stack-detective

Use the Task tool to dispatch the `stack-detective` subagent with this envelope verbatim. Substitute bracketed values from Step 0.

```
## goal
Produce a structured stack.json describing the language, framework, workspace shape, layer naming, dependency graph, and existing .claude/ configuration of the repo at <SCOPE>.

## inputs
- scope: { type: path, value: <SCOPE> }
- handoff_dir: { type: path, value: <HANDOFF_DIR> }
- run_id: { type: string, value: <RUN_ID> }

## context
- path: ${CLAUDE_PLUGIN_ROOT}/skills/orchestration-protocol/SKILL.md
  why: handoff contract; do not re-derive
  do_not_re_derive: true
- path: ${CLAUDE_PLUGIN_ROOT}/skills/opus-4-7-prompting/SKILL.md
  why: prompting discipline; do not re-derive
  do_not_re_derive: true

## constraints
must:
  - emit JSON in the exact schema defined in your system prompt
  - cite file:line for every non-trivial detection
  - run independent reads / greps in parallel
  - read-only: no Write, no Edit, no Agent calls
  - write a HANDOFF.md to <HANDOFF_DIR>/phase-01-stack-detective-to-init.md and end your output with `HANDOFF: <abs path>`
must_not:
  - guess fields you cannot confirm; use null instead
  - recommend changes (your job is detection, not prescription)
  - skip the .claude/ scan if the directory exists

## out_of_scope
- the reference repo (a separate agent handles that)
- proposing rules or refactors

## acceptance
- a single JSON block matching the stack.json schema
- an "Open questions" list of 1-5 bullets after the JSON
- HANDOFF.md written; final output line is `HANDOFF: <path>`

## output_format
markdown_sections:
  - "(JSON code block in the schema described in your prompt)"
  - "Open questions"
  - "HANDOFF"
schema_ref: ${CLAUDE_PLUGIN_ROOT}/agents/stack-detective.md

## handoff
write_to: <HANDOFF_DIR>/phase-01-stack-detective-to-init.md
final_line: HANDOFF: <absolute path>
```

When the agent returns:

1. Extract the JSON block. Validate it parses (Bash + jq).
2. Write it to `<REFACTOR>/stack.json` via the Write tool.
3. If the agent surfaced Open questions, forward them to the user verbatim and pause for answers. Update `stack.json` with the answers (write a new file with the answers merged in).

**Acceptance for Step 1:** `<REFACTOR>/stack.json` exists, parses, and the Open questions (if any) are resolved.

## Step 2 -- Dispatch reference-ingester (conditional)

Only run this step if `--reference` was supplied. If not, skip to Step 3.

```
## goal
Produce a structured standard.md capturing the target architectural standard from the reference repo at <REFERENCE>, applied conceptually to the user's monorepo at <SCOPE>.

## inputs
- reference_path: { type: path, value: <REFERENCE> }
- target_scope: { type: path, value: <SCOPE> }
- mode: { type: enum<deep|shallow>, value: <MODE> }
- handoff_dir: { type: path, value: <HANDOFF_DIR> }
- run_id: { type: string, value: <RUN_ID> }

## context
- path: ${CLAUDE_PLUGIN_ROOT}/skills/orchestration-protocol/SKILL.md
  why: handoff contract; do not re-derive
  do_not_re_derive: true
- path: ${CLAUDE_PLUGIN_ROOT}/skills/opus-4-7-prompting/SKILL.md
  why: prompting discipline; do not re-derive
  do_not_re_derive: true
- path: <REFACTOR>/stack.json
  why: stack info detected from the user's monorepo; lets you flag mismatches
  do_not_re_derive: true

## constraints
must:
  - emit a Markdown standard in the exact 11-section schema defined in your system prompt
  - cite reference path:line for every binding rule
  - in deep mode, read every source file under the reference (small-repo assumption)
  - run reads / greps in parallel
  - read-only: no Write, no Edit, no Agent calls
  - write a HANDOFF.md to <HANDOFF_DIR>/phase-02-reference-ingester-to-init.md and end your output with `HANDOFF: <abs path>`
must_not:
  - prescribe changes to the user's monorepo (the planner does that later)
  - hallucinate "best practices" not present in the reference

## out_of_scope
- the user's monorepo (you only read its stack.json)
- writing rules; that is /audit-domain's job

## acceptance
- standard.md fenced block populated with all 11 sections
- Open questions surfaced for any reference ambiguity
- Coverage notes paragraph after the fenced block
- HANDOFF.md written; final line is `HANDOFF: <path>`

## output_format
markdown_sections:
  - "(fenced markdown block: the standard.md)"
  - "Coverage notes"
  - "HANDOFF"
schema_ref: ${CLAUDE_PLUGIN_ROOT}/agents/reference-ingester.md

## handoff
write_to: <HANDOFF_DIR>/phase-02-reference-ingester-to-init.md
final_line: HANDOFF: <absolute path>
```

When the agent returns:

1. Extract the fenced standard.md block.
2. Write it to `<REFACTOR>/standard.md` via the Write tool.
3. If the agent surfaced Open questions, forward them to the user verbatim and pause for answers. Append the resolved answers to `standard.md` under a `## 11. Open questions (resolved)` sub-section.

**Acceptance for Step 2:** `<REFACTOR>/standard.md` exists with all 11 sections; reference-repo citations resolve.

## Step 3 -- Synthesize

Print to chat (do not write a separate file):

```
==========================================
  /rust-monorepo-orchestrator:init complete
==========================================
  scope:       <SCOPE>
  reference:   <REFERENCE or none>
  mode:        <deep|shallow>

  artefacts:
    stack:    <REFACTOR>/stack.json
    standard: <REFACTOR>/standard.md   (only if --reference was supplied)

  handoffs:   <HANDOFF_DIR>/

  next steps:
    1. Review stack.json -- correct any miscategorizations.
    2. (if standard.md exists) Read it; flag anything that does not match
       your monorepo's intent. Edit in place.
    3. Run /rust-monorepo-orchestrator:audit-domain <name> for the first
       domain you want to drill.
==========================================
```

If any Open questions remain unresolved, list them prominently above the summary so the user does not miss them.

**Acceptance for the whole run:**

- `<REFACTOR>/stack.json` exists and is valid JSON.
- If `--reference` was supplied, `<REFACTOR>/standard.md` exists with all 11 sections.
- HANDOFF.md exists for every dispatched agent under `<HANDOFF_DIR>/`.
- Open questions, if any, are surfaced to chat (not buried in files).
- The summary block above is printed verbatim with the resolved values.

## Whole-workflow constraints

- Read-only on both the target tree and the reference. Only writes are to `<REFACTOR>/stack.json`, `<REFACTOR>/standard.md`, and the HANDOFF files.
- Every agent in the chain prints `HANDOFF: <abs path>` as its final line. The orchestrator halts on missing handoffs (per orchestration-protocol).
- This command does not run if `--reference` points to a path that doesn't exist.
- Do not run `/audit-domain` from within `/init`; the user runs that explicitly after reviewing the artefacts.
