#!/usr/bin/env bash
# Integration tests for hooks/rate-limit-track.sh

set -u

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$TEST_DIR/.." && pwd)"
HOOK="$PLUGIN_ROOT/hooks/rate-limit-track.sh"

ORACLE_TEST_HOME=$(mktemp -d)
export HOME="$ORACLE_TEST_HOME"
export CLAUDE_PLUGIN_ROOT="$PLUGIN_ROOT"

# shellcheck source=tests/lib/assert.sh
source "$TEST_DIR/lib/assert.sh"

cleanup() { rm -rf "$ORACLE_TEST_HOME"; }
trap cleanup EXIT

USAGE="$ORACLE_TEST_HOME/.claude/plugins/oracle/usage.json"

run_hook() {
  local tool="$1" input_json="$2"
  printf '%s' "$(jq -n --arg t "$tool" --argjson i "$input_json" '{tool_name: $t, tool_input: $i}')" | bash "$HOOK"
}

# ---------------------------------------------------------------------
# First call: state file created, counters at the call cost.
# ---------------------------------------------------------------------

begin "first call creates state file and increments by call cost"
rm -rf "$ORACLE_TEST_HOME/.claude"
run_hook "mcp__plugin_oracle_firecrawl__firecrawl_scrape" '{"url":"https://x"}' >/dev/null
got=$(jq -r '.monthly.credits_used' "$USAGE" 2>/dev/null || echo "MISSING")
assert_eq "1" "$got" "scrape -> 1 credit"

# ---------------------------------------------------------------------
# Subsequent call accumulates.
# ---------------------------------------------------------------------

begin "second call accumulates"
run_hook "mcp__plugin_oracle_firecrawl__firecrawl_batch_scrape" '{"urls":["a","b","c"]}' >/dev/null
got=$(jq -r '.monthly.credits_used' "$USAGE")
assert_eq "4" "$got" "1 + 3 batch = 4"

# ---------------------------------------------------------------------
# Status polls do not increment.
# ---------------------------------------------------------------------

begin "status polls do not increment"
run_hook "mcp__plugin_oracle_firecrawl__firecrawl_check_crawl_status" '{"id":"x"}' >/dev/null
got=$(jq -r '.monthly.credits_used' "$USAGE")
assert_eq "4" "$got" "still 4"

# ---------------------------------------------------------------------
# Non-firecrawl tools are not tracked.
# ---------------------------------------------------------------------

begin "non-firecrawl tools are not tracked"
out=$(run_hook "Bash" '{"command":"ls"}')
got=$(jq -r '.monthly.credits_used' "$USAGE")
assert_eq "4" "$got" "still 4 after Bash"
assert_eq "" "$out" "no output for non-firecrawl"

# ---------------------------------------------------------------------
# Recent calls list grows + caps at 50.
# ---------------------------------------------------------------------

begin "recent_calls cap at 50"
# Already have 2 firecrawl calls. Add 60 more cheap ones.
for _ in $(seq 1 60); do
  run_hook "mcp__plugin_oracle_firecrawl__firecrawl_scrape" '{"url":"https://x"}' >/dev/null
done
got=$(jq -r '.recent_calls | length' "$USAGE")
assert_eq "50" "$got" "capped at 50"

# ---------------------------------------------------------------------
# Rolling-hour bucket retains events within the hour.
# ---------------------------------------------------------------------

begin "rolling_hour contains recent events"
got=$(jq -r '.rolling_hour | length' "$USAGE")
if [ "$got" -gt 0 ] && [ "$got" -le 62 ]; then
  pass "rolling_hour has $got entries"
else
  fail "rolling_hour" "expected 1..62, got $got"
fi

# ---------------------------------------------------------------------
# Tally
# ---------------------------------------------------------------------

printf '\n%d pass, %d fail (test-rate-limit-track)\n' "$PASS_COUNT" "$FAIL_COUNT"
[ "$FAIL_COUNT" -eq 0 ]
