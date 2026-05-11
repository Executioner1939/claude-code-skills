---
description: End-to-end service migration. Discovers the workspace from cwd, detects services and aggregates, asks for confirmation, then orchestrates the full pipeline (/init -> /audit -> /plan -> /run) across ALL aggregates of the target service in one coherent run. Pauses for DECISIONS_REQUIRED at the planning gate. Drop-in alternative to the four-command sequence when you want a service-wide refactor. Invoke as `/rust-monorepo-orchestrator:migrate [<service-or-aggregate>] [--reference=<path>] [--wave-width=<n>] [--max-iterations=<n>] [--dry-run]`.
argument-hint: "[<service-or-aggregate>] [--reference=<path>] [--wave-width=<n>] [--max-iterations=<n>] [--dry-run]"
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
  - Bash(bash:*)
  - Bash(nohup:*)
  - Agent
  - Write
model: claude-opus-4-7
---

# /rust-monorepo-orchestrator:migrate

End-to-end service migration. One command, full pipeline. Reasons out loud at every gate, asks before doing anything irreversible.

The command is structured as a sequence of *reasoned steps*, not a script. You (Opus 4.7) read the discovery output, talk through what you see, propose a plan, and pause for confirmation before each major phase. The phases:

  1. **Discover** -- walk the workspace from cwd; report what was found.
  2. **Confirm scope** -- if context is unambiguous, surface it; otherwise ask.
  3. **/init** -- if `.refactor/stack.json` is missing, run it. If `--reference=<path>` is supplied AND `.refactor/standard.md` is missing, run it.
  4. **/audit** -- in parallel for every aggregate of the target service. One ticket-axis dispatch per (aggregate, axis) pair -- many subagent dispatches in one response.
  5. **/plan** -- one unified service-level PLAN.md covering all aggregates' tickets, with cross-aggregate dependencies modeled.
  6. **DECISIONS_REQUIRED gate** -- pause; surface every ambiguity the planner could not resolve.
  7. **/run-wave-ralph** -- drive the wave to completion. Live monitor invocation surfaced.

Each phase opens with a short narrative: "Looking at <X>, I see <Y>, I plan to <Z>. Proceed?" -- and only proceeds on approval (or autonomous proceed if the answer is unambiguous, e.g. there is exactly one service and one aggregate).

## Step 0 -- Resolve arguments and discover context

```!
set -e
ARGS=$(printf '%s' "$ARGUMENTS")

# Parse positional service (first non-flag token; may be empty).
TARGET=$(printf '%s' "$ARGS" | awk '{ for (i=1;i<=NF;i++) if ($i !~ /^--/) { print $i; exit } }')

REFERENCE=$(printf '%s' "$ARGS" | grep -oE -- '--reference=[^ ]+' | cut -d= -f2 || true)
WAVE_WIDTH=$(printf '%s' "$ARGS" | grep -oE -- '--wave-width=[0-9]+' | cut -d= -f2 || true)
[ -z "${WAVE_WIDTH:-}" ] && WAVE_WIDTH=5
MAX_ITER=$(printf '%s' "$ARGS" | grep -oE -- '--max-iterations=[0-9]+' | cut -d= -f2 || true)
[ -z "${MAX_ITER:-}" ] && MAX_ITER=50
DRY_RUN=0
printf '%s' "$ARGS" | grep -q -- '--dry-run' && DRY_RUN=1

# Locate the plugin dir to call discover-workspace.sh.
PLUGIN_DIR="${CLAUDE_PLUGIN_DIR:-}"
if [ -z "$PLUGIN_DIR" ] || [ ! -d "$PLUGIN_DIR/scripts" ]; then
  CACHE="$HOME/.claude/plugins/cache/skunkworks/rust-monorepo-orchestrator"
  [ -d "$CACHE" ] && PLUGIN_DIR=$(ls -1d "$CACHE"/*/ 2>/dev/null | tail -1 | sed 's:/$::')
fi
test -d "$PLUGIN_DIR/scripts" || { echo "ABORT: cannot locate plugin dir; set CLAUDE_PLUGIN_DIR explicitly."; exit 0; }

DISCOVERY=$(bash "$PLUGIN_DIR/scripts/discover-workspace.sh" "$(pwd)" 2>/dev/null || true)
if [ -z "$DISCOVERY" ]; then
  echo "ABORT: workspace discovery failed; run from a directory inside a workspace."
  exit 0
fi

WORKSPACE=$(printf '%s' "$DISCOVERY" | jq -r '.workspace_root')
CURRENT_KIND=$(printf '%s' "$DISCOVERY" | jq -r '.current.kind')
CURRENT_SVC=$(printf '%s' "$DISCOVERY" | jq -r '.current.service // empty')
CURRENT_SVC_PATH=$(printf '%s' "$DISCOVERY" | jq -r '.current.service_path // empty')
CURRENT_AGG=$(printf '%s' "$DISCOVERY" | jq -r '.current.aggregate // empty')
SERVICE_COUNT=$(printf '%s' "$DISCOVERY" | jq -r '.services | length')
SERVICE_NAMES=$(printf '%s' "$DISCOVERY" | jq -r '.services | map(.name) | join(",")')
HAS_STACK=$(printf '%s' "$DISCOVERY" | jq -r '.stack_json_exists')
HAS_STANDARD=$(printf '%s' "$DISCOVERY" | jq -r '.standard_md_exists')

# Resolve target.
TARGET_SERVICE=""
TARGET_AGGREGATE=""
if [ -n "$TARGET" ]; then
  case "$TARGET" in
    */*)
      TARGET_SERVICE="${TARGET%%/*}"
      TARGET_AGGREGATE="${TARGET#*/}"
      ;;
    *)
      TARGET_SERVICE="$TARGET"
      ;;
  esac
elif [ -n "$CURRENT_SVC" ]; then
  TARGET_SERVICE="$CURRENT_SVC"
  TARGET_AGGREGATE="$CURRENT_AGG"
fi

cat <<EOF
BOOTSTRAP_OK=1
WORKSPACE=$WORKSPACE
PLUGIN_DIR=$PLUGIN_DIR
CURRENT_KIND=$CURRENT_KIND
CURRENT_SERVICE=$CURRENT_SVC
CURRENT_SERVICE_PATH=$CURRENT_SVC_PATH
CURRENT_AGGREGATE=$CURRENT_AGG
SERVICE_COUNT=$SERVICE_COUNT
SERVICE_NAMES=$SERVICE_NAMES
TARGET_SERVICE=$TARGET_SERVICE
TARGET_AGGREGATE=$TARGET_AGGREGATE
REFERENCE=${REFERENCE:-(none)}
WAVE_WIDTH=$WAVE_WIDTH
MAX_ITER=$MAX_ITER
DRY_RUN=$DRY_RUN
HAS_STACK=$HAS_STACK
HAS_STANDARD=$HAS_STANDARD
EOF

# Stash the full discovery JSON for the model to read.
DISCOVERY_FILE="$WORKSPACE/.refactor/.last-discovery.json"
mkdir -p "$WORKSPACE/.refactor"
printf '%s' "$DISCOVERY" > "$DISCOVERY_FILE"
echo "DISCOVERY_FILE=$DISCOVERY_FILE"
```

## Step 1 -- Reasoning gate: confirm scope with the user

Read `$DISCOVERY_FILE` to see the full workspace shape (services and their aggregates). Then open in chat with a short narrative. **The exact shape of this narrative matters; this is the difference between "rote workflow" and "reasoned engine."**

Template:

```
Looking at <WORKSPACE>:

  workspace marker: <Cargo [workspace] / moon.yml / pnpm-workspace / ...>
  services found:   <N> (<list>)
  current cwd:      <CURRENT_KIND> -> <service/aggregate or "workspace root">

  service:aggregates table
    <svc-A>: agg1, agg2
    <svc-B>: agg3, agg4, agg5
    ...

Target inferred from <args | cwd | none>:
  service:   <TARGET_SERVICE or "(none)">
  aggregate: <TARGET_AGGREGATE or "(all)">

Plan:
  1. <init? yes/skipped (already initialized)>
  2. audit <N> aggregates in parallel
  3. produce one unified PLAN.md (<estimated ticket count>)
  4. pause for DECISIONS_REQUIRED
  5. run-wave-ralph with wave_width=<WAVE_WIDTH>, max_iter=<MAX_ITER>
```

**Decision branches:**

- If `TARGET_SERVICE` is non-empty AND the service exists in discovery: proceed (no question needed) -- but still print the narrative so the user can interrupt.
- If `TARGET_SERVICE` is empty AND `SERVICE_COUNT == 1`: target = that one service, all aggregates. Print and proceed.
- If `TARGET_SERVICE` is empty AND `SERVICE_COUNT > 1`: ASK -- "Which service do you want to migrate? Options: <list>. Or 'all' for the whole workspace."
- If `TARGET_SERVICE` is named but not found in discovery: ABORT -- "Service '<x>' not found. Available: <list>."
- If `TARGET_AGGREGATE` is named but the service has no aggregates detected: WARN and proceed (the audit-domain agents fall back to structural scanning).

If `DRY_RUN=1`, print the plan and stop here.

If the orchestrator branch is `main`, surface the warning from `/run-wave-ralph` Step 0 and ask before continuing.

## Step 2 -- /init (conditional)

Run `/rust-monorepo-orchestrator:init` ONLY if `HAS_STACK=false` OR `--reference` was supplied and `HAS_STANDARD=false`.

You may dispatch the same agents the `init` command does (`stack-detective`, `reference-ingester`) via the Agent tool with the envelopes from `commands/init.md`. Inherit those envelopes verbatim; do not retype them; only substitute scope = WORKSPACE.

When init completes:

- Read `$WORKSPACE/.refactor/stack.json` to confirm.
- If `--reference` was supplied, read `$WORKSPACE/.refactor/standard.md`.
- If the stack.json's `services_detected` does not include `TARGET_SERVICE`, surface to user and ask for confirmation (the stack-detective may have used different service-name heuristics than discover-workspace.sh).

## Step 3 -- /audit, in parallel across all aggregates of the target service

The aggregates of `TARGET_SERVICE` are listed in `DISCOVERY_FILE.services[<target>].aggregates`. For each aggregate:

- If `TARGET_AGGREGATE` is set, audit only that one.
- Otherwise, audit ALL aggregates of the service.

For each aggregate, run the audit-domain pipeline. **Dispatch the cartographers (one per aggregate) in parallel in the same response** -- they are independent reads.

After cartographers return, dispatch all 10 violation-hunters per aggregate in parallel (so N aggregates * 10 axes = up to 10N hunter dispatches; this is the heavy parallelism). The model should be willing to dispatch large parallel batches here -- this is exactly what the Anthropic Opus 4.7 "encourage parallel sub-agent dispatch" prompt guidance is for.

After all hunters return, dispatch the rule-author once per aggregate (sequential per aggregate, but the aggregates' rule-authors can run in parallel).

Write artefacts:
- `$WORKSPACE/.refactor/domains/<aggregate>/{chain.md, violations.md}` per aggregate
- `$WORKSPACE/.refactor/rules/<aggregate>/*.yml` per aggregate
- Updated `$WORKSPACE/sgconfig.yml` registering all aggregates' rule dirs

Surface to chat the per-aggregate finding counts after each one completes.

## Step 4 -- /plan, service-level

Dispatch the `refactor-planner` once with `mode: service`. Pass it the union of all aggregates' artefacts as input. The planner produces ONE unified PLAN.md, ONE tests.json, and tickets under `.refactor/inbox/<service>/pending/`.

Use the envelope from `commands/plan-refactor.md`, but with these substitutions:

- `domain` argument becomes the SERVICE NAME (e.g., `svc-api-users`)
- `violations_md` becomes a LIST of every per-aggregate violations.md, joined as "service-level violations":
  ```
  - $WORKSPACE/.refactor/domains/user/violations.md
  - $WORKSPACE/.refactor/domains/kyc/violations.md
  - ...
  ```
- `rules_dir` becomes a LIST of all per-aggregate rule dirs
- Output goes to `$WORKSPACE/.refactor/domains/<service>/PLAN.md` and tests.json
- Inbox goes to `$WORKSPACE/.refactor/inbox/<service>/pending/`
- The planner MUST emit cross-aggregate depends_on edges where applicable (e.g., shared `libs/cqrs` lift precedes per-aggregate consumption tickets).

The planner already understands the T-000 preamble pattern (manifest-hub consolidation) from v0.6.0; this is exactly when it shines, because the service-level plan touches root Cargo.toml across many aggregates.

## Step 5 -- DECISIONS_REQUIRED gate

When the planner returns:

- Print every DECISIONS_REQUIRED entry verbatim.
- For each, propose a default with reasoning.
- ASK the user, one prompt per decision OR a compact multi-pick block (use AskUserQuestion).
- Append the resolved answers to `$WORKSPACE/.refactor/domains/<service>/decisions.md`.

Do NOT proceed to Step 6 until decisions are resolved (or the user explicitly says "use all defaults").

## Step 6 -- /run-wave-ralph

Use the existing `/rust-monorepo-orchestrator:run-wave-ralph` envelope. The "domain" argument is the SERVICE NAME. Launch the bash Ralph loop in background; surface the monitor invocation and the wave state directory.

If `DRY_RUN=1` was set, skip this step (the plan + decisions are the only artefacts produced).

## Step 7 -- Final summary

```
==========================================
  /rust-monorepo-orchestrator:migrate complete
==========================================
  service:       <TARGET_SERVICE>
  aggregates:    <comma-separated>
  workspace:     <WORKSPACE>
  branch:        <orchestrator branch>

  artefacts:
    stack:         <WORKSPACE>/.refactor/stack.json
    standard:      <WORKSPACE>/.refactor/standard.md (if reference supplied)
    per-aggregate: <WORKSPACE>/.refactor/domains/<agg>/{chain,violations}.md
    plan:          <WORKSPACE>/.refactor/domains/<service>/PLAN.md
    tests:         <WORKSPACE>/.refactor/domains/<service>/tests.json
    decisions:     <WORKSPACE>/.refactor/domains/<service>/decisions.md
    inbox:         <WORKSPACE>/.refactor/inbox/<service>/pending/

  wave:
    pid:           <ralph PID>     (background)
    state dir:     <state>
    monitor:       bash <PLUGIN_DIR>/scripts/monitor-wave.sh <WORKSPACE> latest
    tail log:      tail -f <state>/run.log
    report (done): <state>/REPORT.md
==========================================
```

## Whole-workflow constraints

- The command is reasoned, not rote. Open each phase with "Looking at X, I see Y, here is what I propose." Pause on ambiguity.
- Discovery is automatic; the user never has to type `--scope=`.
- Service-level by default; aggregate-level only when explicitly requested via `<service>/<aggregate>`.
- Parallelism is the default. N aggregates * 10 axes = up to 10N parallel hunter dispatches; do not serialize unless agents request it.
- Every phase preserves a HANDOFF.md path that the next phase reads, per orchestration-protocol.
- The model MUST NOT silently narrow scope. If the user said `svc-api-users` (no aggregate), audit ALL aggregates.
