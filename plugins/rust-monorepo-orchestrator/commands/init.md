---
description: Context-aware init. Walks up from cwd to find the workspace root, discovers services and aggregates, asks for confirmation, then dispatches stack-detective and (optionally) reference-ingester. No scope argument needed -- the workspace is inferred. Outputs .refactor/stack.json and .refactor/standard.md. Invoke as `/rust-monorepo-orchestrator:init [--reference=<path>] [--shallow]` (no scope arg; cwd context is used).
argument-hint: "[--reference=<path>] [--shallow]"
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
  - Bash(bash:*)
  - Bash(ls:*)
  - Agent(stack-detective)
  - Agent(reference-ingester)
  - Write
model: claude-opus-4-7
---

# /rust-monorepo-orchestrator:init

Context-aware bootstrap. Discovers the workspace from cwd, surfaces what was found, asks if needed, then runs the two read-only subagents and writes `.refactor/stack.json` and `.refactor/standard.md`.

## Step 0 -- Discover context

```!
set -e
ARGS=$(printf '%s' "$ARGUMENTS")

REFERENCE=$(printf '%s' "$ARGS" | grep -oE -- '--reference=[^ ]+' | cut -d= -f2 || true)
if [ -n "${REFERENCE:-}" ]; then
  test -d "$REFERENCE" || { echo "ABORT: --reference=$REFERENCE is not a directory"; exit 0; }
  REFERENCE=$(cd "$REFERENCE" && pwd)
fi

MODE="deep"
case " $ARGS " in *" --shallow "*) MODE="shallow";; esac

PLUGIN_DIR="${CLAUDE_PLUGIN_DIR:-}"
if [ -z "$PLUGIN_DIR" ] || [ ! -d "$PLUGIN_DIR/scripts" ]; then
  CACHE="$HOME/.claude/plugins/cache/skunkworks/rust-monorepo-orchestrator"
  [ -d "$CACHE" ] && PLUGIN_DIR=$(ls -1d "$CACHE"/*/ 2>/dev/null | tail -1 | sed 's:/$::')
fi
test -d "$PLUGIN_DIR/scripts" || { echo "ABORT: cannot locate plugin dir; set CLAUDE_PLUGIN_DIR explicitly."; exit 0; }

DISCOVERY=$(bash "$PLUGIN_DIR/scripts/discover-workspace.sh" "$(pwd)" 2>/dev/null || true)
test -n "$DISCOVERY" || { echo "ABORT: workspace discovery failed."; exit 0; }

SCOPE=$(printf '%s' "$DISCOVERY" | jq -r '.workspace_root')
CURRENT_KIND=$(printf '%s' "$DISCOVERY" | jq -r '.current.kind')
SERVICE_COUNT=$(printf '%s' "$DISCOVERY" | jq -r '.services | length')

TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)
RUN_ID="init-${TIMESTAMP}"
REFACTOR="$SCOPE/.refactor"
HANDOFF_DIR="$REFACTOR/handoffs/$RUN_ID"
mkdir -p "$REFACTOR" "$HANDOFF_DIR"

DISCOVERY_FILE="$REFACTOR/.last-discovery.json"
printf '%s' "$DISCOVERY" > "$DISCOVERY_FILE"

cat <<EOF
BOOTSTRAP_OK=1
SCOPE=$SCOPE
REFERENCE=${REFERENCE:-(none)}
MODE=$MODE
REFACTOR=$REFACTOR
RUN_ID=$RUN_ID
HANDOFF_DIR=$HANDOFF_DIR
TIMESTAMP=$TIMESTAMP
CURRENT_KIND=$CURRENT_KIND
SERVICE_COUNT=$SERVICE_COUNT
DISCOVERY_FILE=$DISCOVERY_FILE
PLUGIN_DIR=$PLUGIN_DIR
EOF
```

If the bootstrap output begins with `ABORT:`, halt and print verbatim.

## Step 1 -- Reasoning gate

Read `$DISCOVERY_FILE` and open a short narrative in chat:

```
Discovered workspace: <SCOPE>

  workspace marker: <Cargo workspace | moon.yml | pnpm-workspace | bare service>
  services:         <SERVICE_COUNT>
    <list services with aggregate counts>
  current cwd:      <CURRENT_KIND>
    <if service|aggregate, show which>

Plan:
  1. dispatch stack-detective (analyzes manifests + layers + .claude/)
  2. <if --reference supplied> dispatch reference-ingester (captures target standard)
  3. write .refactor/stack.json (and standard.md if reference)

Proceed?
```

If the workspace was unambiguous (cwd is at a workspace root OR inside one service of a multi-service workspace), proceed without explicit confirmation (the user can interrupt). If `CURRENT_KIND=outside`, ASK whether to continue (the user may have invoked from the wrong directory).

## Step 2 -- Dispatch stack-detective

Use the Task tool to dispatch the `stack-detective` subagent. **The stack-detective in v0.7.0+ also detects aggregates per service via the same heuristics as `discover-workspace.sh`** (decider files, then aggregate files, then domain subdirs). Pass the discovery file as a context hint:

```
## goal
Produce a structured stack.json describing the language, framework, workspace shape, layer naming, dependency graph, services, aggregates per service, and existing .claude/ configuration of the repo at <SCOPE>. Use <DISCOVERY_FILE> as a starting hypothesis (it was emitted by a deterministic walker); confirm or correct its findings via direct manifest reads.

## inputs
- scope: { type: path, value: <SCOPE> }
- discovery_hint: { type: path, value: <DISCOVERY_FILE> }
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
  - emit JSON in the schema your system prompt defines, INCLUDING the `services` array with per-service `aggregates`
  - cite file:line for every non-trivial detection
  - run independent reads / greps in parallel
  - read-only: no Write, no Edit, no Agent calls
  - write a HANDOFF.md to <HANDOFF_DIR>/phase-01-stack-detective-to-init.md and end your output with `HANDOFF: <abs path>`
must_not:
  - guess fields you cannot confirm; use null instead
  - recommend changes (detection only)
  - skip the .claude/ scan if the directory exists

## acceptance
- a single JSON block matching the stack.json schema
- an "Open questions" list of 1-5 bullets after the JSON
- HANDOFF.md written; final line is `HANDOFF: <path>`

## output_format
markdown_sections:
  - "(JSON code block in the schema described in your prompt)"
  - "Open questions"
  - "HANDOFF"

## handoff
write_to: <HANDOFF_DIR>/phase-01-stack-detective-to-init.md
final_line: HANDOFF: <absolute path>
```

When the agent returns:

1. Extract the JSON block. Validate it parses (Bash + jq).
2. Write to `<REFACTOR>/stack.json`.
3. If the stack.json's `services` array disagrees with the discovery hint's services, surface the diff to the user; ask which to trust before persisting.
4. Open questions: forward verbatim, pause for answers, merge into stack.json under a `clarifications:` key.

## Step 3 -- Dispatch reference-ingester (conditional)

Only if `--reference` was supplied. Envelope as in v0.6.0 -- copy verbatim from the previous `commands/init.md`.

When the agent returns: extract the standard.md block, write to `<REFACTOR>/standard.md`, forward open questions.

## Step 4 -- Print summary

```
==========================================
  /rust-monorepo-orchestrator:init complete
==========================================
  scope:      <SCOPE>
  reference:  <REFERENCE or none>

  services found: <N>
    <list each service with aggregate count and names>

  artefacts:
    stack:    <REFACTOR>/stack.json
    standard: <REFACTOR>/standard.md   (only if --reference)

  handoffs:   <HANDOFF_DIR>/

  next steps:
    1. Review stack.json -- correct any miscategorizations.
    2. Run /rust-monorepo-orchestrator:audit-domain <service-or-aggregate>
       OR /rust-monorepo-orchestrator:migrate <service> for the full pipeline.
==========================================
```

## Whole-workflow constraints

- Read-only on the target tree; writes only to `<REFACTOR>/stack.json`, `<REFACTOR>/standard.md`, `<REFACTOR>/.last-discovery.json`, and HANDOFF files.
- No `--scope` argument; cwd context is the source of truth.
- The discovery JSON is the starting hypothesis; stack-detective verifies via direct reads.
