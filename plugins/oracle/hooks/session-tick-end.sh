#!/usr/bin/env bash
# session-tick-end.sh -- Stop hook for oracle session summaries.
#
# Once per agent-stop:
#   1. Check stop_hook_active loop-breaker (per documented incident #55754).
#   2. Read turn-start.ts (written by session-tick-start.sh).
#   3. Compute active interval = now - turn_start.
#   4. Add to cumulative active-ms.
#   5. Record last-stop.ts for the next idle-gap measurement (informational
#      only -- idle time is structurally excluded from active-ms by virtue
#      of being measured Stop-to-UserPromptSubmit, not the reverse).
#
# This hook never blocks. It is observability-only: we record state so the
# UserPromptSubmit hook can read it on the next turn. We do NOT emit
# `decision: block` -- that would create a Stop loop.

set -u

fail_silent() { exit 0; }
trap fail_silent ERR

INPUT=$(cat)
command -v jq >/dev/null 2>&1 || fail_silent

# Loop-breaker. Always exit early if we've already been forced to continue.
# Defensive even though we don't block -- if another hook does, we don't want
# to re-run our state update twice on the same turn.
STOP_ACTIVE=$(printf '%s' "$INPUT" | jq -r '.stop_hook_active // false' 2>/dev/null)
[ "$STOP_ACTIVE" = "true" ] && exit 0

SESSION_ID=$(printf '%s' "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
[ -z "$SESSION_ID" ] && SESSION_ID="default"

STATE_DIR="$HOME/.claude/plugins/oracle/sessions/$SESSION_ID"
[ -d "$STATE_DIR" ] || exit 0   # tick-start hasn't run yet; nothing to record

NOW_MS=$(($(date +%s) * 1000))

# Read turn-start (set by UserPromptSubmit). If absent, this Stop is unpaired
# with a recorded UserPromptSubmit -- shouldn't happen in normal flow, no-op.
TURN_START_FILE="$STATE_DIR/turn-start.ts"
[ -f "$TURN_START_FILE" ] || exit 0

TURN_START=$(cat "$TURN_START_FILE" 2>/dev/null || echo "$NOW_MS")
ACTIVE_INCREMENT=$((NOW_MS - TURN_START))

# Guard against clock-skew negatives.
[ "$ACTIVE_INCREMENT" -lt 0 ] && ACTIVE_INCREMENT=0

# Accumulate.
ACTIVE_MS=$(cat "$STATE_DIR/active-ms" 2>/dev/null || echo 0)
ACTIVE_MS=$((ACTIVE_MS + ACTIVE_INCREMENT))
echo "$ACTIVE_MS" > "$STATE_DIR/active-ms"

# Record last-stop. Lets us later compute idle gaps if we ever want them
# explicitly; today we just need it for diagnostics.
echo "$NOW_MS" > "$STATE_DIR/last-stop.ts"

# Clear the turn-start marker so a stray double-Stop in the same turn doesn't
# double-count.
rm -f "$TURN_START_FILE" 2>/dev/null || true

exit 0
