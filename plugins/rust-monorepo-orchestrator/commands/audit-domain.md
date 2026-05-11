---
description: Drill one or more aggregates of a service top-to-bottom (HTTP -> command -> events -> views -> interservice events) in parallel. Accepts a service name (audits ALL aggregates of that service) or `<service>/<aggregate>` (audits one). With no args, infers context from cwd. Emits one violations.md + rule set per aggregate. The cartographers run in parallel across aggregates; the violation-hunters fan out further (one per axis per aggregate). Invoke as `/rust-monorepo-orchestrator:audit-domain [<service-or-aggregate>] [--axes=<csv>]`.
argument-hint: "[<service-or-aggregate>] [--axes=<csv>]"
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
  - Bash(bash:*)
  - Bash(ls:*)
  - Agent(domain-cartographer)
  - Agent(violation-hunter)
  - Agent(rule-author)
  - Write
  - Edit
model: claude-opus-4-7
---

# /rust-monorepo-orchestrator:audit-domain

Context-aware audit. Discovers the workspace + the target service's aggregates from cwd, then drills every aggregate in parallel. The cartographers are independent (one per aggregate); the violation-hunters fan out further (one per axis per aggregate). One rule-author per aggregate.

## Step 0 -- Resolve context

```!
set -e
ARGS=$(printf '%s' "$ARGUMENTS")

TARGET=$(printf '%s' "$ARGS" | awk '{ for (i=1;i<=NF;i++) if ($i !~ /^--/) { print $i; exit } }')

AXES=$(printf '%s' "$ARGS" | grep -oE -- '--axes=[^ ]+' | cut -d= -f2 || true)
[ -z "${AXES:-}" ] && AXES="http_layer,command_handlers,domain_events,decider_purity,views_projections,persistence_adapters,interservice_events,error_handling,dependency_direction,naming_consistency"

PLUGIN_DIR="${CLAUDE_PLUGIN_DIR:-}"
if [ -z "$PLUGIN_DIR" ] || [ ! -d "$PLUGIN_DIR/scripts" ]; then
  CACHE="$HOME/.claude/plugins/cache/skunkworks/rust-monorepo-orchestrator"
  [ -d "$CACHE" ] && PLUGIN_DIR=$(ls -1d "$CACHE"/*/ 2>/dev/null | tail -1 | sed 's:/$::')
fi
test -d "$PLUGIN_DIR/scripts" || { echo "ABORT: cannot locate plugin dir; set CLAUDE_PLUGIN_DIR explicitly."; exit 0; }

DISCOVERY=$(bash "$PLUGIN_DIR/scripts/discover-workspace.sh" "$(pwd)" 2>/dev/null || true)
test -n "$DISCOVERY" || { echo "ABORT: workspace discovery failed."; exit 0; }

SCOPE=$(printf '%s' "$DISCOVERY" | jq -r '.workspace_root')
CURRENT_SVC=$(printf '%s' "$DISCOVERY" | jq -r '.current.service // empty')
CURRENT_AGG=$(printf '%s' "$DISCOVERY" | jq -r '.current.aggregate // empty')

# Resolve TARGET into (service, aggregate-list).
TARGET_SERVICE=""
TARGET_AGGS=""
if [ -n "$TARGET" ]; then
  case "$TARGET" in
    */*)
      TARGET_SERVICE="${TARGET%%/*}"
      TARGET_AGGS="${TARGET#*/}"
      ;;
    *)
      # Could be a service name OR a bare aggregate name (legacy)
      if printf '%s' "$DISCOVERY" | jq -e --arg s "$TARGET" '.services[] | select(.name == $s)' >/dev/null 2>&1; then
        TARGET_SERVICE="$TARGET"
        TARGET_AGGS=$(printf '%s' "$DISCOVERY" | jq -r --arg s "$TARGET" '.services[] | select(.name == $s) | .aggregates | join(",")')
      else
        # Legacy: treat as a bare aggregate name within the current service
        if [ -n "$CURRENT_SVC" ]; then
          TARGET_SERVICE="$CURRENT_SVC"
          TARGET_AGGS="$TARGET"
        else
          echo "ABORT: '$TARGET' is not a known service and cwd is outside any service. Known services: $(printf '%s' "$DISCOVERY" | jq -r '.services | map(.name) | join(", ")')"
          exit 0
        fi
      fi
      ;;
  esac
elif [ -n "$CURRENT_SVC" ]; then
  TARGET_SERVICE="$CURRENT_SVC"
  if [ -n "$CURRENT_AGG" ]; then
    TARGET_AGGS="$CURRENT_AGG"
  else
    TARGET_AGGS=$(printf '%s' "$DISCOVERY" | jq -r --arg s "$CURRENT_SVC" '.services[] | select(.name == $s) | .aggregates | join(",")')
  fi
else
  echo "ABORT: no target given and cwd is not inside a service. Try /audit-domain <service-name>."
  exit 0
fi

# Pre-flight: stack.json must exist.
STACK_JSON="$SCOPE/.refactor/stack.json"
test -f "$STACK_JSON" || { echo "ABORT: $STACK_JSON missing. Run /rust-monorepo-orchestrator:init first."; exit 0; }

STANDARD_MD="$SCOPE/.refactor/standard.md"
HAS_STANDARD="false"
[ -f "$STANDARD_MD" ] && HAS_STANDARD="true"

TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)
RUN_ID="audit-${TARGET_SERVICE}-${TIMESTAMP}"
HANDOFF_DIR="$SCOPE/.refactor/handoffs/$RUN_ID"
SGCONFIG="$SCOPE/sgconfig.yml"
mkdir -p "$HANDOFF_DIR"

# Per-aggregate dirs.
IFS=',' read -ra AGG_ARRAY <<< "$TARGET_AGGS"
for agg in "${AGG_ARRAY[@]}"; do
  agg=$(echo "$agg" | xargs)
  [ -z "$agg" ] && continue
  mkdir -p "$SCOPE/.refactor/domains/$agg" "$SCOPE/.refactor/rules/$agg"
done

cat <<EOF
BOOTSTRAP_OK=1
SCOPE=$SCOPE
TARGET_SERVICE=$TARGET_SERVICE
TARGET_AGGS=$TARGET_AGGS
AXES=$AXES
STACK_JSON=$STACK_JSON
STANDARD_MD=$STANDARD_MD
HAS_STANDARD=$HAS_STANDARD
SGCONFIG=$SGCONFIG
HANDOFF_DIR=$HANDOFF_DIR
RUN_ID=$RUN_ID
TIMESTAMP=$TIMESTAMP
PLUGIN_DIR=$PLUGIN_DIR
EOF
```

If the bootstrap output begins with `ABORT:`, halt and print verbatim.

If `HAS_STANDARD=false`, warn the user once: the violation-hunters will fall back to generic hexagonal heuristics. Suggest re-running `/init --reference=<path>` if a reference exists.

## Step 1 -- Reasoning gate

Open a short narrative in chat. Read `TARGET_SERVICE` and `TARGET_AGGS`. Surface:

```
Auditing <TARGET_SERVICE>:

  aggregates (<N>): <comma-list>
  axes per aggregate (<M>): <comma-list>
  parallel dispatches:
    Phase 1 (cartographers): <N>
    Phase 2 (hunters):        <N * M> = <product>
    Phase 3 (rule-authors):   <N>

Plan:
  1. dispatch N cartographers in parallel (one per aggregate)
  2. once all return, dispatch N*M hunters in parallel (axes per aggregate)
  3. synthesize one violations.md per aggregate
  4. dispatch N rule-authors in parallel (one per aggregate; each writes to .refactor/rules/<aggregate>/)
  5. summarize per-aggregate finding counts and rule counts

Proceed?
```

Auto-proceed without explicit Y/N if `TARGET_AGGS` was unambiguously resolved (either supplied directly or there's only one aggregate). Otherwise ask -- specifically when the user passed just `<service>` and the service has more than 5 aggregates (a large parallel fan-out the user may want to scope down).

## Step 2 -- Dispatch N cartographers in parallel

For each aggregate in `TARGET_AGGS`, dispatch a `domain-cartographer` subagent. **Send all dispatches in the same response**. Each envelope substitutes `<DOMAIN>` with the aggregate name (the cartographer is aggregate-scoped). Use the envelope from the legacy command, with the substitutions for each aggregate's `<DOMAIN_DIR>`.

When all return: write each chain.md to `$SCOPE/.refactor/domains/<aggregate>/chain.md`. Forward any aggregated open questions to the user.

## Step 3 -- Dispatch N*M violation-hunters in parallel

For each (aggregate, axis) pair, dispatch a `violation-hunter`. **All in one response.** Up to 5 aggregates * 10 axes = 50 parallel dispatches is well within Claude Code's parallel-tool-call budget; the model should default to maximal parallelism here per the opus-4-7-prompting skill.

Wait for all to return.

## Step 4 -- Synthesize per-aggregate violations.md

For each aggregate, aggregate its 10 axis fragments into `$SCOPE/.refactor/domains/<aggregate>/violations.md`. Use the schema from the legacy command.

## Step 5 -- Dispatch N rule-authors in parallel

One rule-author per aggregate. Each writes to `$SCOPE/.refactor/rules/<aggregate>/`. The rule-author updates `sgconfig.yml` to register its rules dir; the multiple authors may race on `sgconfig.yml` -- the `rule-author`'s sgconfig update is idempotent and append-only per its system prompt, so this is safe.

## Step 6 -- Print summary

```
==========================================
  /rust-monorepo-orchestrator:audit-domain complete
==========================================
  service:    <TARGET_SERVICE>
  aggregates: <list>
  axes:       <AXES>

  per aggregate:
    <agg>: <findings> findings (B/N/N), <rules> rules
    ...

  artefacts:
    chains:        <SCOPE>/.refactor/domains/*/chain.md
    violations:    <SCOPE>/.refactor/domains/*/violations.md
    rules:         <SCOPE>/.refactor/rules/*/
    sgconfig:      <SGCONFIG>

  handoffs:   <HANDOFF_DIR>/

  next steps:
    1. Review violations.md files.
    2. Run `ast-grep scan -c sgconfig.yml --error` to reproduce findings.
    3. Run /rust-monorepo-orchestrator:plan-refactor <TARGET_SERVICE>
       to produce one unified service-level PLAN.md.
==========================================
```

## Whole-workflow constraints

- Cartographer + hunter dispatches are read-only.
- Rule-author writes only to `.refactor/rules/<aggregate>/` and `sgconfig.yml`.
- Maximum parallelism on hunters (N*M in one response).
- Multiple aggregates audited from a single command invocation; no need to call /audit-domain N times.
- Legacy single-aggregate invocation still supported: `/audit-domain <aggregate-name>` from a service-cwd still works.
