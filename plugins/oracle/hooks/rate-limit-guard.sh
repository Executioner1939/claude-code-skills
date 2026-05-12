#!/usr/bin/env bash
# rate-limit-guard.sh -- PreToolUse hook on firecrawl MCP tools.
#
# Tiered decisions based on monthly budget consumption + single-call
# cost estimate:
#
#   used < soft_warning_pct                 -> allow silently
#   soft_warning_pct <= used < ask_threshold -> allow + inject reminder
#   ask_threshold <= used < deny_threshold   -> permissionDecision=ask
#   used >= deny_threshold                  -> permissionDecision=deny
#   single_call_credits / budget >= single_call_hard_gate_pct
#                                            -> permissionDecision=ask (regardless of used)
#
# Hard rule: never block silently. Every gate or remind explains itself.

set -euo pipefail
fail_silent() { exit 0; }
trap fail_silent ERR

INPUT=$(cat)
command -v jq >/dev/null 2>&1 || fail_silent

TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty')
[ -z "$TOOL_NAME" ] && fail_silent
case "$TOOL_NAME" in
  mcp__plugin_oracle_firecrawl__*) : ;;
  *) fail_silent ;;  # not a firecrawl call; nothing to do
esac

TOOL_INPUT=$(printf '%s' "$INPUT" | jq -c '.tool_input // {}')

# Resolve plugin root + source helpers.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
# shellcheck disable=SC1090,SC1091
source "$PLUGIN_ROOT/scripts/budget-lib.sh"

# State + budget snapshot.
STATE=$(read_state)
BUDGET=$(get_monthly_budget)
USED=$(echo "$STATE" | jq -r '.monthly.credits_used')
HOUR_BUCKET=$(echo "$STATE" | jq -r '[.rolling_hour[] | select(.t > (now - 3600))] | map(.c) | add // 0')
SOFT_PCT=$(get_threshold soft_warning_pct)
ASK_PCT=$(get_threshold ask_threshold_pct)
DENY_PCT=$(get_threshold deny_threshold_pct)
SINGLE_PCT=$(get_threshold single_call_hard_gate_pct)
HOUR_MAX=$(get_threshold rolling_hour_max_credits)

# Estimate cost of this call.
EST=$(estimate_cost "$TOOL_NAME" "$TOOL_INPUT")
[ -z "$EST" ] && EST=0
[ "$EST" -lt 0 ] && EST=0

# Zero-cost calls (status polls, unknown tools) always pass silently.
# They consume no budget; running them while over-budget is allowed.
[ "$EST" -eq 0 ] && exit 0

# Projected percentages.
[ "$BUDGET" -le 0 ] && BUDGET=1
USED_PCT_NOW=$((USED * 100 / BUDGET))
USED_PCT_AFTER=$(((USED + EST) * 100 / BUDGET))
CALL_PCT=$((EST * 100 / BUDGET))

emit_allow() {
  jq -n --arg c "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      additionalContext: $c
    }
  }'
}

emit_ask() {
  jq -n --arg c "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "ask",
      permissionDecisionReason: $c
    }
  }'
}

emit_deny() {
  jq -n --arg c "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $c
    }
  }'
}

base_line="Oracle budget: ${USED}/${BUDGET} credits used (${USED_PCT_NOW}%). This call estimated at ${EST} credits (${CALL_PCT}% of monthly). Tool: ${TOOL_NAME#mcp__plugin_oracle_firecrawl__}."

# 1. Hard deny: would exceed monthly budget.
if [ "$USED_PCT_AFTER" -ge "$DENY_PCT" ]; then
  emit_deny "${base_line} This call would push the monthly total to ${USED_PCT_AFTER}% (>= ${DENY_PCT}%). Denied. Run /oracle:budget to inspect, or set a higher monthly limit in .oracle/budget.json if intended."
  exit 0
fi

# 2. Single-call hard gate (regardless of cumulative used).
if [ "$CALL_PCT" -ge "$SINGLE_PCT" ]; then
  emit_ask "${base_line} This is a single high-cost call (>= ${SINGLE_PCT}% of monthly). Before approving, consider dispatching the cost-rethinker agent for cheaper alternatives. Approve only if you have considered the alternatives."
  exit 0
fi

# 3. Rolling-hour ceiling.
if [ "$HOUR_BUCKET" -gt 0 ] && [ "$HOUR_MAX" -gt 0 ] && [ "$((HOUR_BUCKET + EST))" -ge "$HOUR_MAX" ]; then
  emit_ask "${base_line} Rolling-hour spend would reach ${HOUR_BUCKET}+${EST} = $((HOUR_BUCKET + EST)) credits (limit ${HOUR_MAX}). Approve only if the urgency justifies it."
  exit 0
fi

# 4. Ask tier: 95-100% range.
if [ "$USED_PCT_NOW" -ge "$ASK_PCT" ]; then
  emit_ask "${base_line} Monthly budget is at ${USED_PCT_NOW}% (>= ${ASK_PCT}%). Approve only if essential. Consider /oracle:budget for status."
  exit 0
fi

# 5. Soft warn tier: 80-95% range.
if [ "$USED_PCT_NOW" -ge "$SOFT_PCT" ]; then
  emit_allow "${base_line} Monthly budget is at ${USED_PCT_NOW}% (>= ${SOFT_PCT}% soft-warning threshold). Allowed, but you should plan remaining work around the budget. /oracle:budget for status."
  exit 0
fi

# 6. Under all thresholds: silent allow.
exit 0
