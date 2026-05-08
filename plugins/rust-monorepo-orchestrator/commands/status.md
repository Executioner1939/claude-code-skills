---
description: Print a dashboard of the current state of all domains under .refactor/. Reads stack.json, every domain's PLAN.md / chain.md / violations.md, every inbox's _registry.md, and the dead-letter dir. Pure read-only Bash + Read; no subagents. Invoke as `/rust-monorepo-orchestrator:status [<scope>]`.
argument-hint: "[<scope>]"
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Bash(mkdir:*)
  - Bash(date:*)
  - Bash(pwd)
  - Bash(test:*)
  - Bash(echo:*)
  - Bash(find:*)
  - Bash(ls:*)
  - Bash(awk:*)
  - Bash(sed:*)
  - Bash(grep:*)
  - Bash(cut:*)
  - Bash(jq:*)
  - Bash(realpath:*)
  - Bash(cat:*)
  - Bash(wc:*)
  - Bash(git:*)
model: claude-sonnet-4-6
---

# /rust-monorepo-orchestrator:status

A dashboard. No subagents; no writes. Just reads the .refactor/ tree and prints state.

## Step 0 -- Resolve scope

```!
set -e
ARGS=$(printf '%s' "$ARGUMENTS")
SCOPE=$(printf '%s' "$ARGS" | awk '{ for (i=1;i<=NF;i++) if ($i !~ /^--/) { print $i; exit } }')
case "$SCOPE" in '' | --*) SCOPE="$(pwd)";; esac
test -d "$SCOPE" || { echo "ABORT: scope $SCOPE is not a directory"; exit 0; }
SCOPE=$(cd "$SCOPE" && pwd)

REFACTOR="$SCOPE/.refactor"
test -d "$REFACTOR" || { echo "ABORT: $REFACTOR does not exist. Run /rust-monorepo-orchestrator:init first."; exit 0; }

echo "BOOTSTRAP_OK=1"
echo "SCOPE=$SCOPE"
echo "REFACTOR=$REFACTOR"
```

## Step 1 -- Print global state

Run scripts/init.sh to print the standard state summary:

```!
bash "${CLAUDE_PLUGIN_ROOT}/scripts/init.sh" "$SCOPE"
```

## Step 2 -- Per-domain detail

For each domain directory under `<REFACTOR>/domains/`, read and summarize.

```!
for d in "$REFACTOR"/domains/*/; do
  [ -d "$d" ] || continue
  NAME=$(basename "$d")
  echo
  echo "=========================================="
  echo "  domain: $NAME"
  echo "=========================================="

  # Audit artefacts.
  if [ -f "$d/chain.md" ]; then
    LAYERS=$(grep -E '^## [0-9]+\.' "$d/chain.md" | wc -l | tr -d ' ')
    echo "  chain.md:      yes ($LAYERS sections)"
  else
    echo "  chain.md:      no -- run /audit-domain $NAME"
  fi

  if [ -f "$d/violations.md" ]; then
    BLOCKING=$(grep -c 'BLOCKING' "$d/violations.md" 2>/dev/null || echo 0)
    NEEDS_WORK=$(grep -c 'NEEDS-WORK' "$d/violations.md" 2>/dev/null || echo 0)
    NIT=$(grep -c '\[NIT\]' "$d/violations.md" 2>/dev/null || echo 0)
    echo "  violations.md: yes (BLOCKING=$BLOCKING NEEDS-WORK=$NEEDS_WORK NIT=$NIT)"
  else
    echo "  violations.md: no"
  fi

  # Rules.
  RULES_DIR="$REFACTOR/rules/$NAME"
  if [ -d "$RULES_DIR" ]; then
    RULE_COUNT=$(find "$RULES_DIR" -maxdepth 1 -name '*.yml' 2>/dev/null | wc -l | tr -d ' ')
    echo "  rules/:        $RULE_COUNT files"
  else
    echo "  rules/:        no"
  fi

  # Plan + tests.
  if [ -f "$d/PLAN.md" ]; then
    echo "  PLAN.md:       yes"
  else
    echo "  PLAN.md:       no -- run /plan-refactor $NAME"
  fi

  if [ -f "$d/tests.json" ]; then
    if command -v jq >/dev/null 2>&1; then
      TEST_COUNT=$(jq -r '.tests | length' "$d/tests.json" 2>/dev/null || echo "?")
      echo "  tests.json:    yes ($TEST_COUNT tests)"
    else
      echo "  tests.json:    yes"
    fi
  fi

  # Inbox.
  INBOX_DIR="$REFACTOR/inbox/$NAME"
  if [ -d "$INBOX_DIR" ]; then
    P=$(find "$INBOX_DIR/pending" -maxdepth 1 -name 'T-*.md' 2>/dev/null | wc -l | tr -d ' ')
    C=$(find "$INBOX_DIR/claimed" -maxdepth 1 -name 'T-*.md' 2>/dev/null | wc -l | tr -d ' ')
    DN=$(find "$INBOX_DIR/done"    -maxdepth 1 -name 'T-*.md' 2>/dev/null | wc -l | tr -d ' ')
    F=$(find "$INBOX_DIR/failed"   -maxdepth 1 -name 'T-*.md' 2>/dev/null | wc -l | tr -d ' ')
    TOTAL=$((P + C + DN + F))
    if [ "$TOTAL" -gt 0 ]; then
      PCT_DONE=$((DN * 100 / TOTAL))
      echo "  inbox:         pending=$P claimed=$C done=$DN failed=$F  (${PCT_DONE}% done)"
    else
      echo "  inbox:         empty"
    fi

    if [ "$C" -gt 0 ]; then
      echo "  in-flight:"
      for t in "$INBOX_DIR/claimed"/T-*.md; do
        [ -f "$t" ] || continue
        TID=$(basename "$t" .md)
        BY=$(awk -F': ' '/^claimed_by:/{print $2; exit}' "$t" 2>/dev/null)
        AT=$(awk -F': ' '/^claimed_at:/{print $2; exit}' "$t" 2>/dev/null)
        echo "    $TID by ${BY:-?} at ${AT:-?}"
      done
    fi
  else
    echo "  inbox:         (not yet created)"
  fi
done
```

## Step 3 -- Dead-letter dashboard

```!
DL="$REFACTOR/dead-letter"
DL_COUNT=$(find "$DL" -maxdepth 1 -name 'T-*.md' 2>/dev/null | wc -l | tr -d ' ')
echo
echo "=========================================="
echo "  dead-letter: $DL_COUNT ticket(s)"
echo "=========================================="

if [ "$DL_COUNT" -gt 0 ]; then
  for t in "$DL"/T-*.md; do
    [ -f "$t" ] || continue
    TID=$(basename "$t" .md)
    DOM=$(awk -F': ' '/^domain:/{print $2; exit}' "$t" 2>/dev/null)
    ATT=$(awk -F': ' '/^attempts:/{print $2; exit}' "$t" 2>/dev/null)
    echo "  $TID (domain: ${DOM:-?}, attempts: ${ATT:-?})"
    echo "    -> /rust-monorepo-orchestrator:replay $TID --note '...' to resurrect"
  done
fi
```

## Step 4 -- Active worktrees

```!
echo
echo "=========================================="
echo "  active worktrees"
echo "=========================================="
git -C "$SCOPE" worktree list 2>/dev/null | tail -n +2 | sed 's|^|  |' || echo "  (none)"
```

## Step 5 -- Recent handoffs

```!
echo
echo "=========================================="
echo "  recent handoffs (last 10)"
echo "=========================================="
find "$REFACTOR/handoffs" -name 'phase-*.md' -type f 2>/dev/null \
  | sort -r | head -10 | sed 's|^|  |'
```

## Step 6 -- Summary

```!
echo
echo "=========================================="
echo "  next-step hints"
echo "=========================================="
echo "  - /rust-monorepo-orchestrator:audit-domain <name>     map and find violations for a domain"
echo "  - /rust-monorepo-orchestrator:plan-refactor <name>    convert violations into a ticket DAG"
echo "  - /rust-monorepo-orchestrator:run-wave <name>         run the implementation wave"
echo "  - /rust-monorepo-orchestrator:replay <ticket_id>      resurrect a dead-lettered ticket"
echo "  - /rust-monorepo-orchestrator:sweep-rules             ast-grep scan across all domains"
echo "=========================================="
```

## Whole-workflow constraints

- Read-only. No writes. No subagents.
- Tolerant of missing artefacts -- prints what exists, hints at what to run for what's missing.
