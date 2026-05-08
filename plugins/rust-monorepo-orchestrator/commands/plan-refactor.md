---
description: Convert a domain's violations + authored rules into a sequenced ticket DAG (with allowed_paths, depends_on, acceptance criteria, and worker model per ticket) plus a tests.json manifest. Single-phase workflow dispatching the refactor-planner. Pre-flight requires .refactor/domains/<domain>/{chain,violations}.md and .refactor/rules/<domain>/ from /audit-domain. Output at .refactor/domains/<domain>/PLAN.md, .refactor/domains/<domain>/tests.json, and ticket files under .refactor/inbox/<domain>/pending/. Invoke as `/rust-monorepo-orchestrator:plan-refactor <domain> [--scope=<path>] [--wave-width=<n>]`.
argument-hint: "<domain> [--scope=<path>] [--wave-width=<n>]"
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
  - Agent(refactor-planner)
  - Write
model: claude-opus-4-7
---

# /rust-monorepo-orchestrator:plan-refactor

Single-phase workflow. The refactor-planner is single-threaded by design (it maintains topological order across many tickets); no parallelism here.

## Step 0 -- Resolve arguments and pre-flight

```!
set -e
ARGS=$(printf '%s' "$ARGUMENTS")

DOMAIN=$(printf '%s' "$ARGS" | awk '{ for (i=1;i<=NF;i++) if ($i !~ /^--/) { print $i; exit } }')
test -n "$DOMAIN" || { echo "ABORT: domain is required. Usage: /rust-monorepo-orchestrator:plan-refactor <domain> [--scope=<path>] [--wave-width=<n>]"; exit 0; }

SCOPE=$(printf '%s' "$ARGS" | grep -oE -- '--scope=[^ ]+' | cut -d= -f2 || true)
[ -z "${SCOPE:-}" ] && SCOPE="$(pwd)"
test -d "$SCOPE" || { echo "ABORT: scope $SCOPE is not a directory"; exit 0; }
SCOPE=$(cd "$SCOPE" && pwd)

WAVE_WIDTH=$(printf '%s' "$ARGS" | grep -oE -- '--wave-width=[0-9]+' | cut -d= -f2 || true)
[ -z "${WAVE_WIDTH:-}" ] && WAVE_WIDTH=5

# Pre-flight: every input from /audit-domain must exist.
DOMAIN_DIR="$SCOPE/.refactor/domains/$DOMAIN"
RULES_DIR="$SCOPE/.refactor/rules/$DOMAIN"
INBOX_PENDING="$SCOPE/.refactor/inbox/$DOMAIN/pending"

test -f "$DOMAIN_DIR/chain.md"      || { echo "ABORT: $DOMAIN_DIR/chain.md missing. Run /rust-monorepo-orchestrator:audit-domain $DOMAIN first."; exit 0; }
test -f "$DOMAIN_DIR/violations.md" || { echo "ABORT: $DOMAIN_DIR/violations.md missing. Run /rust-monorepo-orchestrator:audit-domain $DOMAIN first."; exit 0; }
test -d "$RULES_DIR"                || { echo "ABORT: $RULES_DIR missing. Run /rust-monorepo-orchestrator:audit-domain $DOMAIN first."; exit 0; }

# Refuse if pending/ already has tickets (avoid clobbering an active wave).
if [ -d "$INBOX_PENDING" ] && [ -n "$(ls -A "$INBOX_PENDING" 2>/dev/null)" ]; then
  echo "ABORT: $INBOX_PENDING already has tickets. Resolve or move them before re-planning."
  exit 0
fi

STANDARD_MD="$SCOPE/.refactor/standard.md"
HAS_STANDARD="false"
[ -f "$STANDARD_MD" ] && HAS_STANDARD="true"

TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)
RUN_ID="plan-refactor-${DOMAIN}-${TIMESTAMP}"
HANDOFF_DIR="$SCOPE/.refactor/handoffs/$RUN_ID"
mkdir -p "$DOMAIN_DIR" "$INBOX_PENDING" "$HANDOFF_DIR"

cat <<EOF
BOOTSTRAP_OK=1
DOMAIN=$DOMAIN
SCOPE=$SCOPE
WAVE_WIDTH=$WAVE_WIDTH
DOMAIN_DIR=$DOMAIN_DIR
RULES_DIR=$RULES_DIR
INBOX_PENDING=$INBOX_PENDING
STANDARD_MD=$STANDARD_MD
HAS_STANDARD=$HAS_STANDARD
HANDOFF_DIR=$HANDOFF_DIR
RUN_ID=$RUN_ID
TIMESTAMP=$TIMESTAMP
EOF
```

If the bootstrap output begins with `ABORT:`, halt and print the message verbatim.

## Step 1 -- Dispatch refactor-planner

```
## goal
Convert the violations and authored rules for the <DOMAIN> domain into a sequenced ticket DAG. Emit one ticket per cohesive change unit with explicit allowed_paths, depends_on, acceptance criteria, and worker_model selection. Author tests-first into tests.json. Write PLAN.md.

## inputs
- scope: { type: path, value: <SCOPE> }
- domain: { type: string, value: <DOMAIN> }
- violations_md: { type: path, value: <DOMAIN_DIR>/violations.md }
- rules_dir: { type: path, value: <RULES_DIR> }
- standard_md: { type: path?, value: <STANDARD_MD if HAS_STANDARD else null> }
- chain_md: { type: path, value: <DOMAIN_DIR>/chain.md }
- output_plan: { type: path, value: <DOMAIN_DIR>/PLAN.md }
- output_tests: { type: path, value: <DOMAIN_DIR>/tests.json }
- inbox_pending_dir: { type: path, value: <INBOX_PENDING> }
- wave_width: { type: int, value: <WAVE_WIDTH> }
- handoff_dir: { type: path, value: <HANDOFF_DIR> }

## context
- path: ${CLAUDE_PLUGIN_ROOT}/skills/orchestration-protocol/SKILL.md
  why: ticket file shape; HANDOFF contract
  do_not_re_derive: true
- path: ${CLAUDE_PLUGIN_ROOT}/skills/astgrep-rule-authoring/SKILL.md
  why: read each rule's expected matches (acceptance criteria reference the rules)
  do_not_re_derive: true
- path: ${CLAUDE_PLUGIN_ROOT}/skills/opus-4-7-prompting/SKILL.md
  why: prompting discipline (commit-to-an-approach, anti-over-engineering, no-test-gaming, file-line-discipline)
  do_not_re_derive: true
- path: ${CLAUDE_PLUGIN_ROOT}/templates/ticket.md
  why: ticket file shape; copy verbatim per ticket
  do_not_re_derive: true
- path: ${CLAUDE_PLUGIN_ROOT}/templates/PLAN.md
  why: PLAN.md skeleton
  do_not_re_derive: true

## constraints
must:
  - emit one ticket per cohesive change unit (not one per finding; not bundled across layers)
  - compute allowed_paths precisely; this is the verifier's enforcement boundary
  - compute depends_on edges; refuse to publish a cyclic DAG
  - choose worker_model per ticket (sonnet for mechanical, opus for architectural)
  - author tests.json with at least one test per ticket; mark must_not_be_removed: true on critical tests
  - write only to <DOMAIN_DIR>/{PLAN.md, tests.json} and <INBOX_PENDING>/T-*.md
  - write a HANDOFF.md to <HANDOFF_DIR>/phase-01-refactor-planner-to-plan-refactor.md and end your output with `HANDOFF: <abs path>`
must_not:
  - bundle findings across services or layers into one ticket
  - exceed the inbox/pending/ write surface
  - publish a DAG with cycles
  - skip DECISIONS_REQUIRED -- surface every ambiguity

## out_of_scope
- editing source code (the wave does that)
- proposing tests beyond what the ticket needs to verify

## acceptance
- T-NNN.md files exist in <INBOX_PENDING>/
- <DOMAIN_DIR>/PLAN.md exists with all sections
- <DOMAIN_DIR>/tests.json exists with at least one test per ticket
- DECISIONS_REQUIRED listed in PLAN.md if any
- HANDOFF.md written; final line is `HANDOFF: <path>`

## output_format
chat_summary_block: as defined in the refactor-planner system prompt

## handoff
write_to: <HANDOFF_DIR>/phase-01-refactor-planner-to-plan-refactor.md
final_line: HANDOFF: <absolute path>
```

When the agent returns:

1. Confirm `<DOMAIN_DIR>/PLAN.md` exists with the documented sections.
2. Confirm `<DOMAIN_DIR>/tests.json` is valid JSON.
3. Count ticket files in `<INBOX_PENDING>/`.
4. If the agent surfaced DECISIONS_REQUIRED, **list them in chat verbatim and pause**. The user must resolve them before `/run-wave` runs.

## Step 2 -- Print summary

```
==========================================
  /rust-monorepo-orchestrator:plan-refactor complete
==========================================
  domain:        <DOMAIN>
  scope:         <SCOPE>
  wave_width:    <WAVE_WIDTH>

  tickets:       <count> in <INBOX_PENDING>/
    by severity: BLOCKING <n>, NEEDS-WORK <n>, NIT <n>
    by model:    sonnet <n>, opus <n>

  artefacts:
    plan:        <DOMAIN_DIR>/PLAN.md
    tests:       <DOMAIN_DIR>/tests.json
    inbox:       <INBOX_PENDING>/

  decisions required (resolve before /run-wave):
    - <decision 1>
    - <decision 2>

  next steps:
    1. Review PLAN.md and the ticket files.
    2. Resolve any DECISIONS_REQUIRED above.
    3. Run /rust-monorepo-orchestrator:run-wave <DOMAIN> to start the
       parallel implementation wave.
==========================================
```

**Acceptance for the whole run:**

- `<DOMAIN_DIR>/PLAN.md` exists.
- `<DOMAIN_DIR>/tests.json` is valid JSON.
- `<INBOX_PENDING>/T-*.md` files exist.
- DAG is acyclic (planner verified).
- DECISIONS_REQUIRED surfaced to chat.
- HANDOFF.md exists under `<HANDOFF_DIR>/`.

## Whole-workflow constraints

- Single agent dispatch. No parallelism in planning.
- Refuses to run if `/audit-domain` artefacts are missing.
- Refuses to run if `pending/` is non-empty (would clobber an in-flight wave).
- Read-only on the source tree; writes only to `.refactor/domains/<domain>/{PLAN.md, tests.json}` and `.refactor/inbox/<domain>/pending/`.
