#!/usr/bin/env bash
# assert.sh -- tiny assert helpers for the oracle test suite.
# Source from each test file; the test runner aggregates pass/fail counts
# from PASS_COUNT / FAIL_COUNT after each file runs.

# shellcheck disable=SC2034
PASS_COUNT=0
FAIL_COUNT=0
TEST_NAME=""

# Begin a named test block.
begin() {
  TEST_NAME="$1"
}

# Record a pass.
pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  printf '  \033[32mPASS\033[0m %s\n' "${TEST_NAME}${1:+: }${1:-}"
}

# Record a fail with context.
fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  printf '  \033[31mFAIL\033[0m %s\n    %s\n' "${TEST_NAME}${1:+: }${1:-}" "${2:-}"
}

# Assert two strings are equal.
assert_eq() {
  local expected="$1" actual="$2" label="${3:-eq}"
  if [ "$expected" = "$actual" ]; then
    pass "$label"
  else
    fail "$label" "expected: $(printf '%s' "$expected" | head -c 200); actual: $(printf '%s' "$actual" | head -c 200)"
  fi
}

# Assert haystack contains needle (substring).
assert_contains() {
  local haystack="$1" needle="$2" label="${3:-contains}"
  case "$haystack" in
    *"$needle"*) pass "$label" ;;
    *) fail "$label" "needle '$needle' not in haystack: $(printf '%s' "$haystack" | head -c 200)" ;;
  esac
}

# Assert haystack does NOT contain needle.
assert_not_contains() {
  local haystack="$1" needle="$2" label="${3:-not-contains}"
  case "$haystack" in
    *"$needle"*) fail "$label" "needle '$needle' unexpectedly in haystack: $(printf '%s' "$haystack" | head -c 200)" ;;
    *) pass "$label" ;;
  esac
}

# Assert haystack matches a regex (using grep -E).
assert_matches() {
  local haystack="$1" pattern="$2" label="${3:-matches}"
  if printf '%s' "$haystack" | grep -Eq "$pattern"; then
    pass "$label"
  else
    fail "$label" "pattern /$pattern/ did not match: $(printf '%s' "$haystack" | head -c 200)"
  fi
}

# Assert command succeeds (exit 0).
assert_succeeds() {
  local label="${1:-succeeds}"
  shift
  if "$@" >/dev/null 2>&1; then
    pass "$label"
  else
    fail "$label" "command failed: $*"
  fi
}

# Assert command fails (exit non-zero).
assert_fails() {
  local label="${1:-fails}"
  shift
  if "$@" >/dev/null 2>&1; then
    fail "$label" "command unexpectedly succeeded: $*"
  else
    pass "$label"
  fi
}
