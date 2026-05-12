#!/usr/bin/env bash
# budget-lib.sh -- shared budget read/write/check helpers for the oracle plugin.
#
# State file: ~/.claude/plugins/oracle/usage.json
# Cost table: ${CLAUDE_PLUGIN_ROOT}/scripts/cost-table.json (read-only)
#
# Failure mode: every helper fails silent (exit 0). The hook callers
# decide whether a failure to read state means "allow" or "deny"; the
# default is allow so an unreadable state file never breaks the session.

set -euo pipefail

ORACLE_DIR="${HOME}/.claude/plugins/oracle"
USAGE_FILE="${ORACLE_DIR}/usage.json"

# Resolve plugin root for the cost table. CLAUDE_PLUGIN_ROOT is set
# by Claude Code when hooks fire. Fall back to a path relative to this
# script for direct-bash testing.
COST_TABLE="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/scripts/cost-table.json"

# Ensure ORACLE_DIR exists.
ensure_dir() {
  mkdir -p "$ORACLE_DIR" 2>/dev/null || true
}

# Read the current state file, or emit a fresh state JSON if absent.
# Rotates the monthly counter when the YYYY-MM period changes.
read_state() {
  ensure_dir
  local now_month now_week now_day
  now_month=$(date -u +%Y-%m)
  now_week=$(date -u +%Y-W%V)
  now_day=$(date -u +%Y-%m-%d)

  if [ ! -f "$USAGE_FILE" ]; then
    jq -n --arg m "$now_month" --arg w "$now_week" --arg d "$now_day" '{
      monthly: {period: $m, credits_used: 0},
      weekly:  {period: $w, credits_used: 0},
      daily:   {period: $d, credits_used: 0},
      rolling_hour: [],
      recent_calls: []
    }'
    return
  fi

  jq --arg m "$now_month" --arg w "$now_week" --arg d "$now_day" '
    .monthly.period as $cm | .weekly.period as $cw | .daily.period as $cd |
    if .monthly.period != $m then .monthly = {period: $m, credits_used: 0} else . end
    | if .weekly.period != $w then .weekly = {period: $w, credits_used: 0} else . end
    | if .daily.period != $d then .daily = {period: $d, credits_used: 0} else . end
  ' "$USAGE_FILE"
}

# Write the new state.
write_state() {
  ensure_dir
  local new_state="$1"
  printf '%s\n' "$new_state" > "$USAGE_FILE.tmp"
  mv "$USAGE_FILE.tmp" "$USAGE_FILE"
}

# Estimate credits for a given (tool_name, tool_input_json) pair.
# Prints the integer credit estimate to stdout.
estimate_cost() {
  local tool_name="$1"
  local tool_input="$2"

  [ ! -f "$COST_TABLE" ] && { echo 0; return; }

  local entry
  entry=$(jq -r --arg t "$tool_name" '.tool_costs[$t] // empty' "$COST_TABLE")
  [ -z "$entry" ] && { echo 0; return; }

  local base scales
  base=$(echo "$entry" | jq -r '.credits_per_call')
  scales=$(echo "$entry" | jq -r '.scales_with')

  case "$scales" in
    fixed)
      echo "$base"
      ;;
    urls_array_length)
      local n
      n=$(echo "$tool_input" | jq -r '(.urls // []) | length' 2>/dev/null || echo 1)
      [ "$n" -lt 1 ] && n=1
      echo $((base * n))
      ;;
    limit_param)
      if [ "$tool_name" = "mcp__plugin_oracle_firecrawl__firecrawl_search" ]; then
        local limit scrape_extra
        limit=$(echo "$tool_input" | jq -r '.limit // 10' 2>/dev/null || echo 10)
        # ceil(limit / 10) * 2
        local search_cost=$(( ((limit + 9) / 10) * 2 ))
        # +1 per result if scrapeOptions present
        scrape_extra=0
        if echo "$tool_input" | jq -e '.scrapeOptions' >/dev/null 2>&1; then
          scrape_extra=$limit
        fi
        echo $((search_cost + scrape_extra))
      elif [ "$tool_name" = "mcp__plugin_oracle_firecrawl__firecrawl_crawl" ]; then
        local crawl_limit
        crawl_limit=$(echo "$tool_input" | jq -r '.limit // .maxPages // 100' 2>/dev/null || echo 100)
        echo $((base * crawl_limit))
      else
        echo "$base"
      fi
      ;;
    *)
      echo "$base"
      ;;
  esac
}

# Read configured monthly budget. Reads in priority order:
#   1. .oracle/budget.json in the current project (project override)
#   2. ~/.claude/plugins/oracle/budget.json (user override)
#   3. cost-table.json default_monthly_budget_credits
get_monthly_budget() {
  local project_cfg=".oracle/budget.json"
  local user_cfg="$ORACLE_DIR/budget.json"

  if [ -f "$project_cfg" ]; then
    jq -r '.monthly_credits // empty' "$project_cfg" 2>/dev/null && return
  fi
  if [ -f "$user_cfg" ]; then
    jq -r '.monthly_credits // empty' "$user_cfg" 2>/dev/null && return
  fi
  if [ -f "$COST_TABLE" ]; then
    jq -r '.default_monthly_budget_credits // 100000' "$COST_TABLE"
    return
  fi
  echo 100000
}

# Read tier thresholds from cost-table.json (with project/user override
# precedence, same as the budget).
get_threshold() {
  local key="$1"
  local project_cfg=".oracle/budget.json"
  local user_cfg="$ORACLE_DIR/budget.json"

  for cfg in "$project_cfg" "$user_cfg"; do
    if [ -f "$cfg" ]; then
      local val
      val=$(jq -r --arg k "$key" '.thresholds[$k] // empty' "$cfg" 2>/dev/null)
      if [ -n "$val" ] && [ "$val" != "null" ]; then
        echo "$val"
        return
      fi
    fi
  done

  jq -r --arg k "$key" '.thresholds[$k]' "$COST_TABLE" 2>/dev/null || echo 0
}
