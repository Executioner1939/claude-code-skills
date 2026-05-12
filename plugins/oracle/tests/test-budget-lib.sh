#!/usr/bin/env bash
# Unit tests for scripts/budget-lib.sh

set -u

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$TEST_DIR/.." && pwd)"

# Set up an isolated HOME so the user's real ~/.claude is not touched.
ORACLE_TEST_HOME=$(mktemp -d)
export HOME="$ORACLE_TEST_HOME"
export CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT"

# shellcheck source=tests/lib/assert.sh
source "$TEST_DIR/lib/assert.sh"
# shellcheck source=scripts/budget-lib.sh
source "$PLUGIN_ROOT/scripts/budget-lib.sh"

cleanup() { rm -rf "$ORACLE_TEST_HOME"; }
trap cleanup EXIT

# ---------------------------------------------------------------------
# estimate_cost
# ---------------------------------------------------------------------

begin "estimate_cost: firecrawl_scrape (fixed)"
got=$(estimate_cost mcp__plugin_oracle_firecrawl__firecrawl_scrape '{"url":"https://x"}')
assert_eq "1" "$got"

begin "estimate_cost: firecrawl_map (fixed)"
got=$(estimate_cost mcp__plugin_oracle_firecrawl__firecrawl_map '{"url":"https://x"}')
assert_eq "1" "$got"

begin "estimate_cost: firecrawl_batch_scrape with 5 URLs"
got=$(estimate_cost mcp__plugin_oracle_firecrawl__firecrawl_batch_scrape '{"urls":["a","b","c","d","e"]}')
assert_eq "5" "$got"

begin "estimate_cost: firecrawl_batch_scrape with empty urls"
got=$(estimate_cost mcp__plugin_oracle_firecrawl__firecrawl_batch_scrape '{"urls":[]}')
assert_eq "1" "$got"

begin "estimate_cost: firecrawl_search default limit (10)"
got=$(estimate_cost mcp__plugin_oracle_firecrawl__firecrawl_search '{"query":"x"}')
assert_eq "2" "$got"

begin "estimate_cost: firecrawl_search limit=25 (ceil(25/10)=3, 3*2=6)"
got=$(estimate_cost mcp__plugin_oracle_firecrawl__firecrawl_search '{"query":"x","limit":25}')
assert_eq "6" "$got"

begin "estimate_cost: firecrawl_search with scrapeOptions adds limit credits"
got=$(estimate_cost mcp__plugin_oracle_firecrawl__firecrawl_search '{"query":"x","limit":10,"scrapeOptions":{"formats":["markdown"]}}')
# ceil(10/10)*2 = 2, + 10 (scrape) = 12
assert_eq "12" "$got"

begin "estimate_cost: firecrawl_crawl default limit (100)"
got=$(estimate_cost mcp__plugin_oracle_firecrawl__firecrawl_crawl '{"url":"https://x"}')
assert_eq "100" "$got"

begin "estimate_cost: firecrawl_crawl limit=500"
got=$(estimate_cost mcp__plugin_oracle_firecrawl__firecrawl_crawl '{"url":"https://x","limit":500}')
assert_eq "500" "$got"

begin "estimate_cost: firecrawl_extract with 3 URLs (3 * 5 = 15)"
got=$(estimate_cost mcp__plugin_oracle_firecrawl__firecrawl_extract '{"urls":["a","b","c"]}')
assert_eq "15" "$got"

begin "estimate_cost: firecrawl_agent fixed (50)"
got=$(estimate_cost mcp__plugin_oracle_firecrawl__firecrawl_agent '{"prompt":"x"}')
assert_eq "50" "$got"

begin "estimate_cost: status polls cost 0"
got=$(estimate_cost mcp__plugin_oracle_firecrawl__firecrawl_check_crawl_status '{"id":"x"}')
assert_eq "0" "$got"
got=$(estimate_cost mcp__plugin_oracle_firecrawl__firecrawl_check_batch_status '{"id":"x"}')
assert_eq "0" "$got"
got=$(estimate_cost mcp__plugin_oracle_firecrawl__firecrawl_agent_status '{"id":"x"}')
assert_eq "0" "$got"

begin "estimate_cost: unknown tool returns 0"
got=$(estimate_cost some_unknown_tool '{}')
assert_eq "0" "$got"

# ---------------------------------------------------------------------
# read_state / write_state
# ---------------------------------------------------------------------

begin "read_state: emits a fresh state when no file exists"
rm -f "$ORACLE_TEST_HOME/.claude/plugins/oracle/usage.json"
fresh=$(read_state)
assert_contains "$fresh" '"monthly"'
assert_contains "$fresh" '"weekly"'
assert_contains "$fresh" '"daily"'
assert_contains "$fresh" '"credits_used": 0'

begin "read_state: rotates monthly counter when period changes"
ensure_dir
# Write a state with a stale month.
printf '%s\n' '{"monthly":{"period":"1999-01","credits_used":12345},"weekly":{"period":"1999-W01","credits_used":99},"daily":{"period":"1999-01-01","credits_used":7},"rolling_hour":[],"recent_calls":[]}' > "$ORACLE_TEST_HOME/.claude/plugins/oracle/usage.json"
rotated=$(read_state)
rotated_used=$(echo "$rotated" | jq -r '.monthly.credits_used')
rotated_period=$(echo "$rotated" | jq -r '.monthly.period')
assert_eq "0" "$rotated_used" "monthly rotated"
assert_matches "$rotated_period" '^[0-9]{4}-[0-9]{2}$' "monthly period current"

begin "write_state: round-trip persists"
sample='{"monthly":{"period":"2026-05","credits_used":42},"weekly":{"period":"2026-W19","credits_used":42},"daily":{"period":"2026-05-13","credits_used":42},"rolling_hour":[],"recent_calls":[]}'
write_state "$sample"
got=$(jq -r '.monthly.credits_used' "$ORACLE_TEST_HOME/.claude/plugins/oracle/usage.json")
assert_eq "42" "$got"

# ---------------------------------------------------------------------
# get_monthly_budget
# ---------------------------------------------------------------------

begin "get_monthly_budget: default from cost-table"
unset CLAUDE_PROJECT_DIR
(cd "$ORACLE_TEST_HOME" && rm -rf .oracle && {
  budget=$(get_monthly_budget)
  if [ "$budget" -gt 0 ]; then pass "default budget > 0 ($budget)"; else fail "default" "non-positive budget: $budget"; fi
})

begin "get_monthly_budget: project override wins"
(cd "$ORACLE_TEST_HOME" && {
  mkdir -p .oracle
  echo '{"monthly_credits": 7777}' > .oracle/budget.json
  budget=$(get_monthly_budget)
  assert_eq "7777" "$budget" "project override"
})

# ---------------------------------------------------------------------
# get_threshold
# ---------------------------------------------------------------------

begin "get_threshold: returns numeric value for known threshold"
v=$(get_threshold soft_warning_pct)
assert_matches "$v" '^[0-9]+$' "soft_warning_pct numeric"
v=$(get_threshold single_call_hard_gate_pct)
assert_matches "$v" '^[0-9]+$' "single_call_hard_gate_pct numeric"

# ---------------------------------------------------------------------
# Tally
# ---------------------------------------------------------------------

printf '\n%d pass, %d fail (test-budget-lib)\n' "$PASS_COUNT" "$FAIL_COUNT"
[ "$FAIL_COUNT" -eq 0 ]
