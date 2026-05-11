---
description: Convert one service's per-aggregate violations + rules into ONE unified service-level ticket DAG with cross-aggregate dependencies. Context-aware: infers the target service from cwd if no arg passed. The planner reads every per-aggregate violations.md under the service's aggregates and writes a single PLAN.md + tests.json + inbox of tickets that the wave dispatches. Legacy single-aggregate planning still supported: pass `<aggregate>` and only that aggregate's violations are consumed. Invoke as `/rust-monorepo-orchestrator:plan-refactor [<service-or-aggregate>] [--wave-width=<n>]`.
argument-hint: "[<service-or-aggregate>] [--wave-width=<n>]"
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
  - Agent(refactor-planner)
  - Write
model: claude-opus-4-7
---

# /rust-monorepo-orchestrator:plan-refactor

Service-level planning. Reads ALL per-aggregate violations + rules + chains for the target service and produces ONE unified PLAN.md. Cross-aggregate dependencies (shared lib lifts, manifest preambles, ProcessManager wiring across aggregates) are modeled explicitly. The single resulting inbox lives at `.refactor/inbox/<service>/pending/`.

## Step 0 -- Resolve context and inputs

```!
set -e
ARGS=$(printf '%s' "$ARGUMENTS")

TARGET=$(printf '%s' "$ARGS" | awk '{ for (i=1;i<=NF;i++) if ($i !~ /^--/) { print $i; exit } }')
WAVE_WIDTH=$(printf '%s' "$ARGS" | grep -oE -- '--wave-width=[0-9]+' | cut -d= -f2 || true)
[ -z "${WAVE_WIDTH:-}" ] && WAVE_WIDTH=5

PLUGIN_DIR="${CLAUDE_PLUGIN_DIR:-}"
if [ -z "$PLUGIN_DIR" ] || [ ! -d "$PLUGIN_DIR/scripts" ]; then
  CACHE="$HOME/.claude/plugins/cache/skunkworks/rust-monorepo-orchestrator"
  [ -d "$CACHE" ] && PLUGIN_DIR=$(ls -1d "$CACHE"/*/ 2>/dev/null | tail -1 | sed 's:/$::')
fi
test -d "$PLUGIN_DIR/scripts" || { echo "ABORT: cannot locate plugin dir."; exit 0; }

DISCOVERY=$(bash "$PLUGIN_DIR/scripts/discover-workspace.sh" "$(pwd)" 2>/dev/null)
test -n "$DISCOVERY" || { echo "ABORT: workspace discovery failed."; exit 0; }

SCOPE=$(printf '%s' "$DISCOVERY" | jq -r '.workspace_root')
CURRENT_SVC=$(printf '%s' "$DISCOVERY" | jq -r '.current.service // empty')

# Resolve target -> (planning_unit, aggregates_to_include).
PLAN_UNIT=""
INCLUDE_AGGS=""
if [ -n "$TARGET" ]; then
  case "$TARGET" in
    */*)
      PLAN_UNIT="${TARGET#*/}"
      INCLUDE_AGGS="$PLAN_UNIT"
      ;;
    *)
      if printf '%s' "$DISCOVERY" | jq -e --arg s "$TARGET" '.services[] | select(.name == $s)' >/dev/null 2>&1; then
        PLAN_UNIT="$TARGET"
        INCLUDE_AGGS=$(printf '%s' "$DISCOVERY" | jq -r --arg s "$TARGET" '.services[] | select(.name == $s) | .aggregates | join(",")')
      else
        PLAN_UNIT="$TARGET"
        INCLUDE_AGGS="$TARGET"
      fi
      ;;
  esac
elif [ -n "$CURRENT_SVC" ]; then
  PLAN_UNIT="$CURRENT_SVC"
  INCLUDE_AGGS=$(printf '%s' "$DISCOVERY" | jq -r --arg s "$CURRENT_SVC" '.services[] | select(.name == $s) | .aggregates | join(",")')
else
  echo "ABORT: no target supplied and cwd is not inside a service. Usage: /plan-refactor <service-or-aggregate>"
  exit 0
fi

# Verify the audit artefacts exist for each aggregate.
MISSING=()
IFS=',' read -ra AGG_ARRAY <<< "$INCLUDE_AGGS"
for agg in "${AGG_ARRAY[@]}"; do
  agg=$(echo "$agg" | xargs)
  [ -z "$agg" ] && continue
  if [ ! -f "$SCOPE/.refactor/domains/$agg/violations.md" ]; then
    MISSING+=("$agg")
  fi
done
if [ "${#MISSING[@]}" -gt 0 ]; then
  echo "ABORT: violations.md missing for aggregates: ${MISSING[*]}. Run /audit-domain $PLAN_UNIT first."
  exit 0
fi

# Refuse if inbox/pending already has tickets.
INBOX_PENDING="$SCOPE/.refactor/inbox/$PLAN_UNIT/pending"
if [ -d "$INBOX_PENDING" ] && [ -n "$(ls -A "$INBOX_PENDING" 2>/dev/null)" ]; then
  echo "ABORT: $INBOX_PENDING already has tickets. Move or resolve them before re-planning."
  exit 0
fi

DOMAIN_DIR="$SCOPE/.refactor/domains/$PLAN_UNIT"
STANDARD_MD="$SCOPE/.refactor/standard.md"
HAS_STANDARD="false"
[ -f "$STANDARD_MD" ] && HAS_STANDARD="true"

TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)
RUN_ID="plan-refactor-${PLAN_UNIT}-${TIMESTAMP}"
HANDOFF_DIR="$SCOPE/.refactor/handoffs/$RUN_ID"
mkdir -p "$DOMAIN_DIR" "$INBOX_PENDING" "$HANDOFF_DIR"

cat <<EOF
BOOTSTRAP_OK=1
PLAN_UNIT=$PLAN_UNIT
INCLUDE_AGGS=$INCLUDE_AGGS
SCOPE=$SCOPE
WAVE_WIDTH=$WAVE_WIDTH
DOMAIN_DIR=$DOMAIN_DIR
INBOX_PENDING=$INBOX_PENDING
STANDARD_MD=$STANDARD_MD
HAS_STANDARD=$HAS_STANDARD
HANDOFF_DIR=$HANDOFF_DIR
RUN_ID=$RUN_ID
TIMESTAMP=$TIMESTAMP
EOF
```

If the bootstrap output begins with `ABORT:`, halt and print verbatim.

## Step 1 -- Reasoning gate

Open with:

```
Planning service: <PLAN_UNIT>

  aggregates included: <INCLUDE_AGGS>
  violations consumed: <per-aggregate violations.md paths>
  rules consumed:      <per-aggregate rules dirs>
  output:              <DOMAIN_DIR>/PLAN.md + tests.json + <INBOX_PENDING>/T-*.md

Estimated ticket scope: <N aggregates> * <avg-tickets-per-aggregate> shared infrastructure tickets emitted once at the top of the DAG.

Proceed?
```

Auto-proceed unless `INCLUDE_AGGS` has more than 8 entries (a very large plan that may benefit from being split).

## Step 2 -- Dispatch refactor-planner (service-mode)

Use the Task tool to dispatch the `refactor-planner` subagent. The envelope tells the planner: this is a SERVICE-LEVEL plan, here are the per-aggregate violations.md paths, produce ONE unified PLAN.md with cross-aggregate depends_on edges and a single T-000 preamble for shared manifest edits.

```
## goal
Produce one service-level PLAN.md + tests.json + inbox for the <PLAN_UNIT> planning unit. Consume violations + rules from every aggregate listed in <INCLUDE_AGGS>. Emit cross-aggregate depends_on edges where applicable. The wave loop runs against this single inbox; tickets across aggregates compete for path-locks naturally.

## inputs
- scope: { type: path, value: <SCOPE> }
- planning_unit: { type: string, value: <PLAN_UNIT> }
- aggregates: { type: csv-string, value: <INCLUDE_AGGS> }
- violations_md_paths: { type: csv-paths, value: <SCOPE>/.refactor/domains/<agg>/violations.md (for each agg) }
- rules_dirs: { type: csv-paths, value: <SCOPE>/.refactor/rules/<agg>/ (for each agg) }
- decisions_md_paths: { type: csv-paths, value: <SCOPE>/.refactor/domains/<agg>/decisions.md if present (for each agg) }
- standard_md: { type: path?, value: <STANDARD_MD if HAS_STANDARD else null> }
- chain_md_paths: { type: csv-paths, value: <SCOPE>/.refactor/domains/<agg>/chain.md (for each agg) }
- output_plan: { type: path, value: <DOMAIN_DIR>/PLAN.md }
- output_tests: { type: path, value: <DOMAIN_DIR>/tests.json }
- inbox_pending_dir: { type: path, value: <INBOX_PENDING> }
- wave_width: { type: int, value: <WAVE_WIDTH> }
- handoff_dir: { type: path, value: <HANDOFF_DIR> }

## context
- path: ${CLAUDE_PLUGIN_ROOT}/skills/orchestration-protocol/SKILL.md
- path: ${CLAUDE_PLUGIN_ROOT}/skills/astgrep-rule-authoring/SKILL.md
- path: ${CLAUDE_PLUGIN_ROOT}/skills/opus-4-7-prompting/SKILL.md
- path: ${CLAUDE_PLUGIN_ROOT}/templates/ticket.md
- path: ${CLAUDE_PLUGIN_ROOT}/templates/PLAN.md

## constraints
must:
  - emit one ticket per cohesive change unit (not one per finding)
  - de-duplicate shared infrastructure tickets across aggregates: if `lift libs/cqrs` appears in 5 aggregates' violations, emit ONE ticket (T-001 or T-002) and reference it from each aggregate's downstream tickets via depends_on
  - emit T-000 preamble per refactor-planner.md step 4a when 3+ tickets touch a manifest hub
  - set per-ticket frontmatter: severity, commit_type, verifier (per refactor-planner.md step 6a)
  - compute allowed_paths precisely
  - compute depends_on edges including CROSS-AGGREGATE edges (e.g., kyc/UserError introduction depends on the libs lift)
  - choose worker_model per ticket
  - author tests.json
  - write only to <DOMAIN_DIR>/{PLAN.md, tests.json} and <INBOX_PENDING>/T-*.md
  - write a HANDOFF.md to <HANDOFF_DIR>/phase-01-refactor-planner-to-plan-refactor.md
must_not:
  - emit duplicate tickets for the same shared infrastructure change (e.g., five separate "lift libs/cqrs" tickets one per aggregate)
  - publish a cyclic DAG
  - skip DECISIONS_REQUIRED

## acceptance
- T-NNN.md files in <INBOX_PENDING>/
- <DOMAIN_DIR>/PLAN.md with a service-level shape: per-aggregate sections + cross-aggregate dependency graph
- <DOMAIN_DIR>/tests.json valid JSON
- HANDOFF.md written

## output_format
chat_summary_block: as defined in the refactor-planner system prompt

## handoff
write_to: <HANDOFF_DIR>/phase-01-refactor-planner-to-plan-refactor.md
final_line: HANDOFF: <absolute path>
```

When the agent returns:
1. Confirm PLAN.md + tests.json exist.
2. Count tickets in `$INBOX_PENDING/`.
3. Surface DECISIONS_REQUIRED verbatim and pause.

## Step 3 -- Print summary

```
==========================================
  /rust-monorepo-orchestrator:plan-refactor complete
==========================================
  planning unit: <PLAN_UNIT>
  aggregates:    <INCLUDE_AGGS>
  scope:         <SCOPE>
  wave_width:    <WAVE_WIDTH>

  tickets:       <count> in <INBOX_PENDING>/
    by severity: BLOCKING <n>, NEEDS-WORK <n>, NIT <n>
    by model:    sonnet <n>, opus <n>
    by verifier: deterministic <n>, llm <n>, hybrid <n>
    shared:      <n> shared infrastructure tickets serve all aggregates

  artefacts:
    plan:        <DOMAIN_DIR>/PLAN.md
    tests:       <DOMAIN_DIR>/tests.json
    inbox:       <INBOX_PENDING>/

  decisions required (resolve before /run):
    - <decision 1>
    - <decision 2>

  next steps:
    1. Review PLAN.md.
    2. Resolve any DECISIONS_REQUIRED above.
    3. Run /rust-monorepo-orchestrator:run-wave-ralph <PLAN_UNIT>
       to start the parallel implementation wave.
==========================================
```

## Whole-workflow constraints

- Service-level planning is the default; aggregate-level is opt-in via `<service>/<aggregate>`.
- Cross-aggregate dependencies are first-class.
- Shared infrastructure tickets appear once at the top of the DAG.
- Read-only on source; writes only to `.refactor/domains/<plan_unit>/` and `.refactor/inbox/<plan_unit>/pending/`.
