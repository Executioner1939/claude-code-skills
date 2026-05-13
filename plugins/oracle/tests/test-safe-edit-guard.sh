#!/usr/bin/env bash
# Integration tests for hooks/safe-edit-guard.sh and hooks/track-reads.sh.
#
# Exercises the read-state tracker + the edit guard end-to-end using
# a temporary HOME so the production state file is untouched.

set -u

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$TEST_DIR/.." && pwd)"
GUARD="$PLUGIN_ROOT/hooks/safe-edit-guard.sh"
TRACKER="$PLUGIN_ROOT/hooks/track-reads.sh"

# shellcheck source=tests/lib/assert.sh
source "$TEST_DIR/lib/assert.sh"

# Use an isolated HOME so we don't poison the user's real state file.
TMP_HOME=$(mktemp -d 2>/dev/null) || { printf 'mktemp failed\n'; exit 1; }
trap 'rm -rf "$TMP_HOME"' EXIT
export HOME="$TMP_HOME"

# A real existing file to target.
EXISTING_FILE="$TMP_HOME/sample.txt"
printf 'hello\nworld\n' > "$EXISTING_FILE"

SESSION_ID="test-session-1"

track_read() {
  local fp="$1"
  printf '%s' "$(jq -n --arg fp "$fp" --arg sid "$SESSION_ID" \
    '{tool_name: "Read", tool_input: {file_path: $fp}, session_id: $sid}')" \
    | bash "$TRACKER"
}

run_guard() {
  local tool="$1" fp="$2"
  printf '%s' "$(jq -n --arg t "$tool" --arg fp "$fp" --arg sid "$SESSION_ID" \
    '{tool_name: $t, tool_input: {file_path: $fp}, session_id: $sid}')" \
    | bash "$GUARD"
}

# ---------------------------------------------------------------------
# track-reads writes the state file.
# ---------------------------------------------------------------------

begin "track-reads writes state file"
track_read "$EXISTING_FILE"
state="$TMP_HOME/.claude/plugins/oracle/reads-${SESSION_ID}.tsv"
if [ -f "$state" ]; then
  pass "state file exists"
else
  fail "state file exists" "expected $state"
fi

begin "track-reads records the path"
out=$(grep -F "$EXISTING_FILE" "$state" || true)
assert_contains "$out" "$EXISTING_FILE"

# ---------------------------------------------------------------------
# Guard is silent when path was read recently.
# ---------------------------------------------------------------------

begin "guard silent when Edit on freshly-Read path"
out=$(run_guard "Edit" "$EXISTING_FILE")
assert_eq "" "$out" "silent"

begin "guard silent when MultiEdit on freshly-Read path"
out=$(run_guard "MultiEdit" "$EXISTING_FILE")
assert_eq "" "$out" "silent"

# ---------------------------------------------------------------------
# Guard fires when path was never read.
# ---------------------------------------------------------------------

UNREAD_FILE="$TMP_HOME/never-read.txt"
printf 'unread\n' > "$UNREAD_FILE"

begin "guard fires on Edit of unread file"
out=$(run_guard "Edit" "$UNREAD_FILE")
assert_contains "$out" "Oracle safe-edit guard"
assert_contains "$out" "never-read.txt"

# ---------------------------------------------------------------------
# Write to a nonexistent path is silent (creation case).
# ---------------------------------------------------------------------

begin "guard silent on Write to nonexistent path (creation)"
out=$(run_guard "Write" "$TMP_HOME/brand-new.txt")
assert_eq "" "$out" "silent"

# ---------------------------------------------------------------------
# Guard silent on tools it does not cover.
# ---------------------------------------------------------------------

begin "guard silent on Bash tool"
out=$(printf '%s' "$(jq -n --arg fp "$UNREAD_FILE" \
  '{tool_name: "Bash", tool_input: {command: "ls"}}')" | bash "$GUARD")
assert_eq "" "$out" "silent"

# ---------------------------------------------------------------------
# Guard fires when last Read was outside the freshness window.
# ---------------------------------------------------------------------

STALE_FILE="$TMP_HOME/stale.txt"
printf 'stale\n' > "$STALE_FILE"
# Inject a stale entry by hand: timestamp two hours ago.
two_hours_ago=$(( $(date +%s) - 7200 ))
printf '%s\t%s\n' "$two_hours_ago" "$STALE_FILE" >> "$state"

begin "guard fires on Edit of stale-Read path"
out=$(run_guard "Edit" "$STALE_FILE")
assert_contains "$out" "Oracle safe-edit guard"

# ---------------------------------------------------------------------
# Tracker handles malformed input fail-silent.
# ---------------------------------------------------------------------

begin "tracker fail-silent on malformed input"
out=$(printf 'not json' | bash "$TRACKER" 2>&1)
assert_eq "" "$out" "silent"

begin "guard fail-silent on malformed input"
out=$(printf 'not json' | bash "$GUARD" 2>&1)
assert_eq "" "$out" "silent"

# ---------------------------------------------------------------------
# Tally
# ---------------------------------------------------------------------

printf '\n%d pass, %d fail (test-safe-edit-guard)\n' "$PASS_COUNT" "$FAIL_COUNT"
[ "$FAIL_COUNT" -eq 0 ]
