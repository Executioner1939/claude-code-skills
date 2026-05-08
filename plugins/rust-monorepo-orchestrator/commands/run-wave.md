---
description: Run a parallel implementation wave for one domain. Dispatches the wave-orchestrator (Opus 4.7, effort xhigh) which loops over the inbox, dispatches up to wave_width ticket-implementer workers in parallel (each with isolation: worktree), runs the verifier per result, automerges on PASS (calls scripts/automerge.sh), retries-or-dead-letters on FAIL, and terminates on queue-drained. Pre-flight requires .refactor/domains/<domain>/PLAN.md and at least one ticket in .refactor/inbox/<domain>/pending/. Invoke as `/rust-monorepo-orchestrator:run-wave <domain> [--scope=<path>] [--wave-width=<n>] [--max-iterations=<n>]`.
argument-hint: "<domain> [--scope=<path>] [--wave-width=<n>] [--max-iterations=<n>]"
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
  - Bash(find:*)
  - Bash(ls:*)
  - Bash(git:*)
  - Agent(wave-orchestrator)
  - Write
model: claude-opus-4-7
---

# /rust-monorepo-orchestrator:run-wave

The implementation wave. Single dispatch -- the wave-orchestrator runs the entire wave inside one Task call, looping internally over dispatch / wait / verify / automerge / iterate. The command below is the thin wrapper: pre-flight, dispatch, post-flight.

## Step 0 -- Resolve arguments and pre-flight

```!
set -e
ARGS=$(printf '%s' "$ARGUMENTS")

DOMAIN=$(printf '%s' "$ARGS" | awk '{ for (i=1;i<=NF;i++) if ($i !~ /^--/) { print $i; exit } }')
test -n "$DOMAIN" || { echo "ABORT: domain is required."; exit 0; }

SCOPE=$(printf '%s' "$ARGS" | grep -oE -- '--scope=[^ ]+' | cut -d= -f2 || true)
[ -z "${SCOPE:-}" ] && SCOPE="$(pwd)"
test -d "$SCOPE" || { echo "ABORT: scope $SCOPE is not a directory"; exit 0; }
SCOPE=$(cd "$SCOPE" && pwd)

WAVE_WIDTH=$(printf '%s' "$ARGS" | grep -oE -- '--wave-width=[0-9]+' | cut -d= -f2 || true)
[ -z "${WAVE_WIDTH:-}" ] && WAVE_WIDTH=5

MAX_ITERATIONS=$(printf '%s' "$ARGS" | grep -oE -- '--max-iterations=[0-9]+' | cut -d= -f2 || true)
[ -z "${MAX_ITERATIONS:-}" ] && MAX_ITERATIONS=50

# Pre-flight.
DOMAIN_DIR="$SCOPE/.refactor/domains/$DOMAIN"
INBOX_DIR="$SCOPE/.refactor/inbox/$DOMAIN"
PLAN_MD="$DOMAIN_DIR/PLAN.md"
TESTS_JSON="$DOMAIN_DIR/tests.json"
SGCONFIG="$SCOPE/sgconfig.yml"

test -f "$PLAN_MD"        || { echo "ABORT: $PLAN_MD missing. Run /rust-monorepo-orchestrator:plan-refactor $DOMAIN first."; exit 0; }
test -f "$TESTS_JSON"     || { echo "ABORT: $TESTS_JSON missing."; exit 0; }
test -d "$INBOX_DIR/pending" || { echo "ABORT: $INBOX_DIR/pending missing."; exit 0; }
test -f "$SGCONFIG"       || { echo "ABORT: $SGCONFIG missing. Run /rust-monorepo-orchestrator:audit-domain $DOMAIN first."; exit 0; }

# Ensure inbox state subdirs exist.
mkdir -p "$INBOX_DIR/claimed" "$INBOX_DIR/done" "$INBOX_DIR/failed" "$SCOPE/.refactor/dead-letter"

# Pending count -- refuse if zero.
PENDING_COUNT=$(find "$INBOX_DIR/pending" -maxdepth 1 -name 'T-*.md' 2>/dev/null | wc -l | tr -d ' ')
[ "$PENDING_COUNT" -gt 0 ] || { echo "ABORT: $INBOX_DIR/pending has 0 tickets. Run /rust-monorepo-orchestrator:plan-refactor $DOMAIN first."; exit 0; }

# Resolve orchestrator branch.
ORCH_BRANCH=$(git -C "$SCOPE" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
[ -n "$ORCH_BRANCH" ] || { echo "ABORT: $SCOPE is not a git repo (or detached HEAD)"; exit 0; }
[ "$ORCH_BRANCH" = "main" ] && {
  echo "WARNING: orchestrator branch is 'main'. Automerges will land directly on main."
  echo "         Strongly recommended: switch to a feature branch first (git checkout -b refactor/$DOMAIN)."
  echo "         Continue anyway? (the workflow will proceed; abort here with Ctrl+C if not)."
}

TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)
RUN_ID="run-wave-${DOMAIN}-${TIMESTAMP}"
HANDOFF_DIR="$SCOPE/.refactor/handoffs/$RUN_ID"
mkdir -p "$HANDOFF_DIR"

# Make sure the worktrees parent dir exists.
mkdir -p "$SCOPE/.worktrees"

cat <<EOF
BOOTSTRAP_OK=1
DOMAIN=$DOMAIN
SCOPE=$SCOPE
WAVE_WIDTH=$WAVE_WIDTH
MAX_ITERATIONS=$MAX_ITERATIONS
INBOX_DIR=$INBOX_DIR
DOMAIN_DIR=$DOMAIN_DIR
PLAN_MD=$PLAN_MD
TESTS_JSON=$TESTS_JSON
SGCONFIG=$SGCONFIG
ORCH_BRANCH=$ORCH_BRANCH
PENDING_COUNT=$PENDING_COUNT
HANDOFF_DIR=$HANDOFF_DIR
RUN_ID=$RUN_ID
TIMESTAMP=$TIMESTAMP
EOF
```

If the bootstrap output begins with `ABORT:`, halt and print verbatim.

If the warning about main appears, surface it to chat and ask the user once to confirm. If the user wants a feature branch, halt and instruct them to switch.

## Step 1 -- Dispatch wave-orchestrator (single Task)

```
## goal
Drive the implementation wave for the <DOMAIN> domain to completion. Loop over the inbox: compute ready tickets (deps satisfied + path-lock clear), dispatch up to <WAVE_WIDTH> ticket-implementer workers in parallel per iteration, dispatch verifier per yielded RESULT.md, on PASS run scripts/automerge.sh and move ticket to done/, on FAIL retry up to ticket.max_attempts then dead-letter, terminate on queue-drained or <MAX_ITERATIONS> iterations.

## inputs
- scope: { type: path, value: <SCOPE> }
- domain: { type: string, value: <DOMAIN> }
- inbox_dir: { type: path, value: <INBOX_DIR> }
- plan_md: { type: path, value: <PLAN_MD> }
- tests_json: { type: path, value: <TESTS_JSON> }
- sgconfig_path: { type: path, value: <SGCONFIG> }
- orchestrator_branch: { type: string, value: <ORCH_BRANCH> }
- wave_width: { type: int, value: <WAVE_WIDTH> }
- wave_max_iterations: { type: int, value: <MAX_ITERATIONS> }
- handoff_dir: { type: path, value: <HANDOFF_DIR> }

## context
- path: ${CLAUDE_PLUGIN_ROOT}/skills/orchestration-protocol/SKILL.md
  why: ticket lifecycle, claim semantics, path-locking, automerge, dead-letter
  do_not_re_derive: true
- path: ${CLAUDE_PLUGIN_ROOT}/skills/opus-4-7-prompting/SKILL.md
  why: prompting discipline (parallel-tool-calls, 4.7-spawning-encourager, effort_scaling, context_budget_persist, commit-to-an-approach, reversibility-gate)
  do_not_re_derive: true
- path: <PLAN_MD>
  why: mission paragraph (inherited verbatim into every wave HANDOFF), DAG, decisions
  do_not_re_derive: true
- path: <TESTS_JSON>
  why: must_not_be_removed: true entries the verifier enforces
  do_not_re_derive: true

## constraints
must:
  - dispatch parallel workers in the same response per iteration
  - enforce path-locking (no two in-flight tickets share allowed_paths)
  - call scripts/claim.sh from each worker (atomic claim)
  - call scripts/automerge.sh on every PASS
  - call scripts/registry-refresh.sh after every state transition
  - move FAIL tickets back to pending/ until max_attempts exhausted, then dead-letter
  - leave failed worktrees in place for human inspection (only PASS removes worktree via automerge.sh)
  - persist progress to memory (.claude/agent-memory/wave-orchestrator/MEMORY.md) as you approach context limits
  - terminate at queue-drained or wave_max_iterations
  - write a HANDOFF.md to <HANDOFF_DIR>/phase-NN-wave-orchestrator-to-run-wave.md and end your output with `HANDOFF: <abs path>`
must_not:
  - dispatch a worker for a ticket whose deps are not done
  - dispatch two workers whose allowed_paths intersect
  - automerge on FAIL or RETRY
  - clean up failed worktrees (the user inspects them)
  - exceed wave_max_iterations

## out_of_scope
- editing source files directly (workers do that)
- adding new tickets (the planner does that)
- modifying ticket frontmatter beyond status / claimed_by / claimed_at / attempts

## acceptance
- queue is drained (pending and claimed both empty) OR max_iterations reached
- final wave report block emitted per the system prompt format
- HANDOFF.md written; final line is `HANDOFF: <abs path>`

## output_format
chat_progress: one line per iteration: "[iter <n>] dispatched=<n> claimed=<n> done=<n> failed=<n> dead-letter=<n>"
chat_final: wave-orchestrator wave-report block per the system prompt

## handoff
write_to: <HANDOFF_DIR>/phase-01-wave-orchestrator-to-run-wave.md
final_line: HANDOFF: <absolute path>
```

The wave-orchestrator runs to completion inside this single Task call. The harness streams its progress lines to chat as it iterates.

## Step 2 -- Post-wave summary

After wave-orchestrator returns:

1. Read its final wave report.
2. Run `bash <plugin>/scripts/registry-refresh.sh <INBOX_DIR>` once more for sanity.
3. Count: tickets in `done/`, `failed/`, `<scope>/.refactor/dead-letter/`.

Print to chat:

```
==========================================
  /rust-monorepo-orchestrator:run-wave complete
==========================================
  domain:           <DOMAIN>
  scope:            <SCOPE>
  orchestrator_branch: <ORCH_BRANCH>
  iterations:       <n>

  outcome counts:
    PASS:           <done count>
    FAIL retried:   <n>
    dead-letter:    <n>
    blocked:        <n>

  registry:    <INBOX_DIR>/_registry.md
  dead-letter: <SCOPE>/.refactor/dead-letter/

  retained worktrees (failed; for inspection):
    <list>

  next steps:
    1. ast-grep scan -c sgconfig.yml --error -- confirm domain is clean.
    2. Review failed worktrees if any; resolve manually or kick off
       /rust-monorepo-orchestrator:replay <ticket_id>.
    3. Review dead-letter entries; decide retry-with-hint or human fix.
==========================================
```

If any ticket exceeded max_attempts, surface its dead-letter file path explicitly so the user can inspect or `/replay`.

**Acceptance for the whole run:**

- Wave terminated cleanly (drained queue or max iterations).
- Every PASS ticket is in `done/` and merged into `<orchestrator_branch>`.
- Every FAIL ticket is in `failed/` (with retry chance) or `dead-letter/` (exhausted).
- `_registry.md` reflects final state.
- HANDOFF.md exists for the wave-orchestrator dispatch.

## Whole-workflow constraints

- Workers run in isolated worktrees (`isolation: worktree`).
- Path-locking prevents concurrent edits to the same files.
- automerge.sh (called by orchestrator on PASS) merges the worker branch and removes the worktree.
- failed/ tickets retain their worktrees for human inspection.
- dead-letter/ tickets retain their worktrees too (until /replay).
- Only the wave-orchestrator uses the Agent tool. Workers and verifiers cannot.
- No emojis. Every claim cites file:line.
