#!/usr/bin/env bash
# Integration tests for hooks/rate-limit-guard.sh

set -u

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$TEST_DIR/.." && pwd)"
HOOK="$PLUGIN_ROOT/hooks/rate-limit-guard.sh"

# Isolated HOME so the user's real ~/.claude is not touched.
ORACLE_TEST_HOME=$(mktemp -d)
export HOME="$ORACLE_TEST_HOME"
export CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT"

# shellcheck source=tests/lib/assert.sh
source "$TEST_DIR/lib/assert.sh"

cleanup() { rm -rf "$ORACLE_TEST_HOME"; }
trap cleanup EXIT

# Helper: seed the usage state file with a given monthly used count.
seed_state() {
  local used="$1"
  local month
  month=$(date -u +%Y-%m)
  mkdir -p "$ORACLE_TEST_HOME/.claude/plugins/oracle"
  jq -n --argjson u "$used" --arg m "$month" '{
    monthly: {period: $m, credits_used: $u},
    weekly:  {period: "x", credits_used: 0},
    daily:   {period: "x", credits_used: 0},
    rolling_hour: [],
    recent_calls: []
  }' > "$ORACLE_TEST_HOME/.claude/plugins/oracle/usage.json"
}

# Helper: seed a budget override (project-scoped).
seed_budget_project() {
  mkdir -p .oracle
  jq -n --argjson b "$1" '{monthly_credits: $b}' > .oracle/budget.json
}

# Helper: feed a PreToolUse JSON payload to the hook and capture output.
run_hook() {
  local tool="$1" input_json="$2"
  printf '%s' "$(jq -n --arg t "$tool" --argjson i "$input_json" '{tool_name: $t, tool_input: $i}')" | bash "$HOOK"
}

# ---------------------------------------------------------------------
# Non-firecrawl tool: hook is a no-op.
# ---------------------------------------------------------------------

begin "non-firecrawl tool: hook exits silently"
out=$(run_hook "Bash" '{"command":"ls"}')
assert_eq "" "$out" "no output"

# ---------------------------------------------------------------------
# Silent allow (used = 0, small call).
# ---------------------------------------------------------------------

begin "silent allow at 0% used + tiny scrape"
seed_state 0
out=$(run_hook "mcp__plugin_oracle_firecrawl__firecrawl_scrape" '{"url":"https://x"}')
assert_eq "" "$out" "no remind / no gate"

# ---------------------------------------------------------------------
# Soft warning at 80%.
# ---------------------------------------------------------------------

begin "soft warn at 80% used"
cd "$ORACLE_TEST_HOME" || exit 1
seed_budget_project 1000
seed_state 850   # 85% used, after a 1-cr scrape: 851 (still <95%)
out=$(run_hook "mcp__plugin_oracle_firecrawl__firecrawl_scrape" '{"url":"https://x"}')
assert_contains "$out" "soft-warning"
assert_contains "$out" "additionalContext"
assert_not_contains "$out" '"permissionDecision"'

# ---------------------------------------------------------------------
# Ask gate at 95%.
# ---------------------------------------------------------------------

begin "ask gate at 95% used"
seed_state 960   # 96% used
out=$(run_hook "mcp__plugin_oracle_firecrawl__firecrawl_scrape" '{"url":"https://x"}')
assert_contains "$out" '"permissionDecision": "ask"'
assert_contains "$out" "essential"

# ---------------------------------------------------------------------
# Deny at >100%.
# ---------------------------------------------------------------------

begin "deny when call would exceed monthly budget"
seed_state 999   # one credit left
# A 5-cr extract call would push to 1004 (100.4%)
out=$(run_hook "mcp__plugin_oracle_firecrawl__firecrawl_extract" '{"urls":["a"]}')
assert_contains "$out" '"permissionDecision": "deny"'

# ---------------------------------------------------------------------
# Single-call hard gate at 15%+.
# ---------------------------------------------------------------------

begin "single-call hard gate at >=15% of monthly"
seed_state 0
# Budget is 1000 (project override), so 15% = 150 credits.
# A crawl with limit=200 = 200 credits = 20% -> gate.
out=$(run_hook "mcp__plugin_oracle_firecrawl__firecrawl_crawl" '{"url":"https://x","limit":200}')
assert_contains "$out" '"permissionDecision": "ask"'
assert_contains "$out" "single high-cost call"
assert_contains "$out" "cost-rethinker"

# ---------------------------------------------------------------------
# Default-limit crawl on small project budget triggers gate.
# ---------------------------------------------------------------------

begin "default-limit crawl (100) on 200-credit budget triggers single-call gate"
seed_budget_project 200
seed_state 0
# Default crawl limit = 100 credits = 50% of 200 -> single-call gate.
out=$(run_hook "mcp__plugin_oracle_firecrawl__firecrawl_crawl" '{"url":"https://x"}')
assert_contains "$out" '"permissionDecision": "ask"'

# ---------------------------------------------------------------------
# Status polls always pass silently.
# ---------------------------------------------------------------------

begin "status polls cost 0 and pass silently"
seed_state 999
out=$(run_hook "mcp__plugin_oracle_firecrawl__firecrawl_check_crawl_status" '{"id":"x"}')
assert_eq "" "$out" "no output for status poll"

# ---------------------------------------------------------------------
# Tally
# ---------------------------------------------------------------------

printf '\n%d pass, %d fail (test-rate-limit-guard)\n' "$PASS_COUNT" "$FAIL_COUNT"
[ "$FAIL_COUNT" -eq 0 ]
