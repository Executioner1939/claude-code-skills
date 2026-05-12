#!/usr/bin/env bash
# rate-limit-track.sh -- PostToolUse hook on firecrawl MCP tools.
#
# Increments the monthly / weekly / daily / rolling-hour counters by
# the estimated cost of the call that just executed. Estimates are
# best-effort; firecrawl does not return actual credits consumed in
# the tool_result payload.

set -euo pipefail
fail_silent() { exit 0; }
trap fail_silent ERR

INPUT=$(cat)
command -v jq >/dev/null 2>&1 || fail_silent

TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty')
[ -z "$TOOL_NAME" ] && fail_silent
case "$TOOL_NAME" in
  mcp__plugin_oracle_firecrawl__*) : ;;
  *) fail_silent ;;
esac

TOOL_INPUT=$(printf '%s' "$INPUT" | jq -c '.tool_input // {}')

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
# shellcheck disable=SC1090,SC1091
source "$PLUGIN_ROOT/scripts/budget-lib.sh"

EST=$(estimate_cost "$TOOL_NAME" "$TOOL_INPUT")
[ -z "$EST" ] && EST=0
[ "$EST" -lt 0 ] && EST=0
[ "$EST" -eq 0 ] && exit 0  # status polls and unknown tools: nothing to track

STATE=$(read_state)
NOW_EPOCH=$(date -u +%s)
SHORT_TOOL="${TOOL_NAME#mcp__plugin_oracle_firecrawl__}"

NEW_STATE=$(echo "$STATE" | jq \
  --argjson cost "$EST" \
  --arg tool "$SHORT_TOOL" \
  --argjson t "$NOW_EPOCH" '
    .monthly.credits_used = (.monthly.credits_used + $cost)
    | .weekly.credits_used  = (.weekly.credits_used  + $cost)
    | .daily.credits_used   = (.daily.credits_used   + $cost)
    | .rolling_hour = ((.rolling_hour // []) + [{t: $t, c: $cost}] | map(select(.t > ($t - 3600))))
    | .recent_calls = ((.recent_calls // []) + [{t: $t, tool: $tool, c: $cost}] | .[-50:])
  ')

write_state "$NEW_STATE"

# Surface a short post-call note via additionalContext so the agent
# sees the running totals next turn. Throttle: only emit when crossing
# the soft-warning threshold to avoid noise on every call.
BUDGET=$(get_monthly_budget)
[ "$BUDGET" -le 0 ] && BUDGET=1
NEW_USED=$(echo "$NEW_STATE" | jq -r '.monthly.credits_used')
NEW_PCT=$((NEW_USED * 100 / BUDGET))
SOFT_PCT=$(get_threshold soft_warning_pct)

if [ "$NEW_PCT" -ge "$SOFT_PCT" ]; then
  jq -n --arg c "Oracle budget post-call: ${NEW_USED}/${BUDGET} credits used (${NEW_PCT}%). Last call: ${SHORT_TOOL} cost ${EST}. Run /oracle:budget for the full picture." '{
    hookSpecificOutput: {
      hookEventName: "PostToolUse",
      additionalContext: $c
    }
  }'
fi

exit 0
