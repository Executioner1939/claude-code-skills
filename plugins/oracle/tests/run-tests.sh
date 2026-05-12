#!/usr/bin/env bash
# Top-level test runner for the oracle plugin.
# Runs:
#   1. shellcheck against every .sh file in the plugin
#   2. JSON syntax check on every .json + hooks.json + .mcp.json
#   3. Each test-*.sh file under tests/
#
# Exits non-zero on any failure. Designed to run from anywhere.

set -u

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$TEST_DIR/.." && pwd)"

# Track aggregate counts.
TOTAL_PASS=0
TOTAL_FAIL=0
FAILED_FILES=""

# ---------------------------------------------------------------------
# Stage 1: shellcheck
# ---------------------------------------------------------------------

printf '\n=== Stage 1: shellcheck ===\n'

if ! command -v shellcheck >/dev/null 2>&1; then
  printf 'WARN: shellcheck not installed; skipping. brew install shellcheck (macOS) or apt install shellcheck.\n'
else
  SH_FAIL=0
  while IFS= read -r f; do
    if shellcheck -x "$f" >/dev/null 2>&1; then
      printf '  PASS shellcheck %s\n' "${f#"$PLUGIN_ROOT"/}"
      TOTAL_PASS=$((TOTAL_PASS + 1))
    else
      printf '  FAIL shellcheck %s\n' "${f#"$PLUGIN_ROOT"/}"
      shellcheck -x "$f" | sed 's/^/    /'
      SH_FAIL=$((SH_FAIL + 1))
      TOTAL_FAIL=$((TOTAL_FAIL + 1))
      FAILED_FILES="${FAILED_FILES}${FAILED_FILES:+, }shellcheck:$(basename "$f")"
    fi
  done < <(find "$PLUGIN_ROOT" -type f -name '*.sh' -not -path '*/node_modules/*')

  if [ "$SH_FAIL" -eq 0 ]; then
    printf '  (all shell scripts clean)\n'
  fi
fi

# ---------------------------------------------------------------------
# Stage 2: JSON syntax
# ---------------------------------------------------------------------

printf '\n=== Stage 2: JSON syntax ===\n'

JSON_FAIL=0
while IFS= read -r f; do
  if jq empty "$f" >/dev/null 2>&1; then
    printf '  PASS json %s\n' "${f#"$PLUGIN_ROOT"/}"
    TOTAL_PASS=$((TOTAL_PASS + 1))
  else
    printf '  FAIL json %s\n' "${f#"$PLUGIN_ROOT"/}"
    JSON_FAIL=$((JSON_FAIL + 1))
    TOTAL_FAIL=$((TOTAL_FAIL + 1))
    FAILED_FILES="${FAILED_FILES}${FAILED_FILES:+, }json:$(basename "$f")"
  fi
done < <(find "$PLUGIN_ROOT" -type f \( -name '*.json' -o -name '.mcp.json' \) -not -path '*/node_modules/*')

# ---------------------------------------------------------------------
# Stage 3: shell tests
# ---------------------------------------------------------------------

printf '\n=== Stage 3: shell tests ===\n'

for test_file in "$TEST_DIR"/test-*.sh; do
  [ -f "$test_file" ] || continue
  name=$(basename "$test_file")
  printf '\n--- %s ---\n' "$name"
  if bash "$test_file"; then
    TOTAL_PASS=$((TOTAL_PASS + 1))
  else
    TOTAL_FAIL=$((TOTAL_FAIL + 1))
    FAILED_FILES="${FAILED_FILES}${FAILED_FILES:+, }$name"
  fi
done

# ---------------------------------------------------------------------
# Final tally
# ---------------------------------------------------------------------

printf '\n=== Final ===\n'
printf 'Stages run: shellcheck, json, %d test files.\n' "$(find "$TEST_DIR" -maxdepth 1 -type f -name 'test-*.sh' | wc -l | tr -d ' ')"
printf 'Aggregate: %d pass, %d fail.\n' "$TOTAL_PASS" "$TOTAL_FAIL"

if [ "$TOTAL_FAIL" -gt 0 ]; then
  printf 'Failed: %s\n' "$FAILED_FILES"
  exit 1
fi
exit 0
