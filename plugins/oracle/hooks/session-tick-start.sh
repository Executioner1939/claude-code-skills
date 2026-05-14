#!/usr/bin/env bash
# session-tick-start.sh -- UserPromptSubmit hook for oracle session summaries.
#
# Once per user prompt:
#   1. Resolve session_id and the per-session state directory.
#   2. Initialise state on first fire of the session.
#   3. Increment turn-count.
#   4. Record turn-start.ts (consumed by session-tick-end.sh on next Stop).
#   5. Check thresholds: if (active_ms - last_summary.active_ms >= 30 min)
#      OR (turn_count - last_summary.turn >= 50), invoke session-summary.sh
#      and emit its output as additionalContext.
#
# UserPromptSubmit consumes stdout as additionalContext per the documented
# exit-code semantics. We use that primitive directly -- no JSON wrapping.
#
# Performance budget: ~5ms on the no-summary path. Summary fire path is
# bounded by the inner narrator timeout (60s in session-summary.sh) but
# the surrounding hook is tagged with a 90s timeout in hooks.json to
# accommodate.

set -u

fail_silent() { exit 0; }
trap fail_silent ERR

INPUT=$(cat)
command -v jq >/dev/null 2>&1 || fail_silent

SESSION_ID=$(printf '%s' "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
TRANSCRIPT_PATH=$(printf '%s' "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null)

[ -z "$SESSION_ID" ] && SESSION_ID="default"

STATE_DIR="$HOME/.claude/plugins/oracle/sessions/$SESSION_ID"
mkdir -p "$STATE_DIR"

NOW_MS=$(($(date +%s) * 1000))

# Initialise on first fire of the session.
[ -f "$STATE_DIR/start.ts" ] || echo "$NOW_MS" > "$STATE_DIR/start.ts"
[ -f "$STATE_DIR/turn-count" ] || echo 0 > "$STATE_DIR/turn-count"
[ -f "$STATE_DIR/active-ms" ] || echo 0 > "$STATE_DIR/active-ms"
[ -f "$STATE_DIR/last-summary.json" ] || \
  printf '{"turn":0,"active_ms":0,"line":0}\n' > "$STATE_DIR/last-summary.json"

# Increment turn-count.
TURN=$(cat "$STATE_DIR/turn-count" 2>/dev/null || echo 0)
TURN=$((TURN + 1))
echo "$TURN" > "$STATE_DIR/turn-count"

# Record turn-start (consumed by Stop hook).
echo "$NOW_MS" > "$STATE_DIR/turn-start.ts"

# Read cumulative active-ms (last updated by Stop hook).
ACTIVE_MS=$(cat "$STATE_DIR/active-ms" 2>/dev/null || echo 0)

# Read last-summary snapshot.
LAST_TURN=$(jq -r '.turn // 0' "$STATE_DIR/last-summary.json" 2>/dev/null || echo 0)
LAST_ACTIVE=$(jq -r '.active_ms // 0' "$STATE_DIR/last-summary.json" 2>/dev/null || echo 0)
LAST_LINE=$(jq -r '.line // 0' "$STATE_DIR/last-summary.json" 2>/dev/null || echo 0)

# Threshold check.
TURN_DELTA=$((TURN - LAST_TURN))
ACTIVE_DELTA=$((ACTIVE_MS - LAST_ACTIVE))

# Allow override via env: ORACLE_SUMMARY_TURNS, ORACLE_SUMMARY_ACTIVE_MS.
TURN_THRESHOLD="${ORACLE_SUMMARY_TURNS:-50}"
ACTIVE_THRESHOLD="${ORACLE_SUMMARY_ACTIVE_MS:-1800000}"   # 30 min in ms

FIRE=0
if [ "$TURN_DELTA" -ge "$TURN_THRESHOLD" ]; then
  FIRE=1
elif [ "$ACTIVE_DELTA" -ge "$ACTIVE_THRESHOLD" ]; then
  FIRE=1
fi

[ "$FIRE" -eq 0 ] && exit 0

# Don't fire on the very first turn even if thresholds are zero-defaulted.
[ "$TURN" -le 1 ] && exit 0

# Compute wall-ms for the summary's wall-clock display.
START_MS=$(cat "$STATE_DIR/start.ts" 2>/dev/null || echo "$NOW_MS")
WALL_MS=$((NOW_MS - START_MS))

# Locate session-summary.sh.
SUMMARY_SCRIPT="${CLAUDE_PLUGIN_ROOT:-$(cd -- "$(dirname -- "$0")/.." && pwd)}/scripts/session-summary.sh"
[ -x "$SUMMARY_SCRIPT" ] || exit 0

# Invoke. Output goes to stdout -> additionalContext.
bash "$SUMMARY_SCRIPT" "$TRANSCRIPT_PATH" "$LAST_LINE" "$STATE_DIR" \
  "$TURN" "$ACTIVE_MS" "$WALL_MS" || true

# Update last-summary snapshot.
CUR_LINES=$(wc -l < "$TRANSCRIPT_PATH" 2>/dev/null | tr -d ' ')
CUR_LINES="${CUR_LINES:-$LAST_LINE}"
jq -n --argjson turn "$TURN" --argjson active "$ACTIVE_MS" --argjson line "$CUR_LINES" \
  '{turn: $turn, active_ms: $active, line: $line}' > "$STATE_DIR/last-summary.json"

exit 0
