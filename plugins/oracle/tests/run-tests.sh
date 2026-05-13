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

# Run from the plugin root so shellcheck -x can resolve the
# `# shellcheck source=...` directives relative to the plugin
# tree (they use plugin-relative paths). Running from any other
# cwd breaks source-following with SC1091.
cd "$PLUGIN_ROOT" || exit 1

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
# Stage 2b: YAML frontmatter in skill SKILL.md files
# ---------------------------------------------------------------------
# Skills declare metadata in a YAML frontmatter block at the top of
# SKILL.md. A YAML parse error means the harness silently skips the
# skill. The oracle 0.2.0 build hit two such cases (anti-hype-ranking,
# vet) -- both descriptions contained unescaped double quotes inside a
# double-quoted YAML scalar. This stage catches that class of error
# before the plugin is published.

printf '\n=== Stage 2b: YAML frontmatter ===\n'

if ! command -v python3 >/dev/null 2>&1; then
  printf 'WARN: python3 not installed; skipping YAML frontmatter check.\n'
else
  YAML_FAIL=0
  while IFS= read -r f; do
    if python3 -c "
import sys, re
try:
    import yaml
except ImportError:
    sys.exit(0)
src = open('$f').read()
m = re.match(r'^---\n(.*?)\n---\n', src, re.DOTALL)
if not m:
    print('  WARN no frontmatter: $f')
    sys.exit(0)
try:
    data = yaml.safe_load(m.group(1))
    if not isinstance(data, dict):
        sys.exit(2)
    if 'name' not in data or 'description' not in data:
        sys.exit(3)
except Exception as e:
    print('  parse error:', e)
    sys.exit(1)
" >/dev/null 2>&1; then
      printf '  PASS yaml %s\n' "${f#"$PLUGIN_ROOT"/}"
      TOTAL_PASS=$((TOTAL_PASS + 1))
    else
      rc=$?
      printf '  FAIL yaml %s (exit %d)\n' "${f#"$PLUGIN_ROOT"/}" "$rc"
      python3 -c "
import sys, re
import yaml
src = open('$f').read()
m = re.match(r'^---\n(.*?)\n---\n', src, re.DOTALL)
if m:
    try:
        yaml.safe_load(m.group(1))
    except Exception as e:
        print('   ', e)
" 2>&1 | sed 's/^/    /'
      YAML_FAIL=$((YAML_FAIL + 1))
      TOTAL_FAIL=$((TOTAL_FAIL + 1))
      FAILED_FILES="${FAILED_FILES}${FAILED_FILES:+, }yaml:$(basename "$(dirname "$f")")"
    fi
  done < <(find "$PLUGIN_ROOT" -type f -name 'SKILL.md' -not -path '*/node_modules/*')
fi

# ---------------------------------------------------------------------
# Stage 2c: POSIX `[` test operator lint
# ---------------------------------------------------------------------
# Hook scripts run under bash but are sometimes piped through zsh
# (which evaluates `[` strictly). Inside single-bracket `[ ... ]`
# tests the `==` operator is a bashism that explodes under zsh's
# `(eval):1: == not found`. Use `=` for POSIX equality or upgrade to
# the double-bracket form `[[ ... == ... ]]` which permits `==`.
# Transcript-corpus evidence shows 17 such failures across all
# sessions on this machine.

printf '\n=== Stage 2c: POSIX [ ... == ... ] lint ===\n'

# Pattern: a single-bracket `[` followed by a literal `==` followed by
# a closing `]` on the same line, ignoring comment lines (which can
# legitimately reference the operator in prose). The closing-`]`
# requirement is what stops this stage from flagging its own regex
# patterns and printf strings.
POSIX_FAIL=0
# Match a real `[ ... == ... ]` test, not a comment-prose mention.
# Real tests have at least one operand that is either a variable
# expansion (`$foo`, `"$foo"`) or a quoted literal (`"x"`). Requiring
# `$` or `"` somewhere inside the bracket scope drops the false-
# positive on printf-string mentions of the pattern.
POSIX_PATTERN='(^|[^[])\[ [^][]*[$"][^][]*[[:space:]]==[[:space:]][^][]*\]|(^|[^[])\[ [^][]*[[:space:]]==[[:space:]][^][]*[$"][^][]*\]'
while IFS= read -r f; do
  # Strip comment lines first; the lint applies to executable shell
  # only, not to documentation prose inside `# ...` comments.
  if grep -vE '^[[:space:]]*#' "$f" | grep -nE "$POSIX_PATTERN" >/dev/null 2>&1; then
    printf '  FAIL posix-test %s\n' "${f#"$PLUGIN_ROOT"/}"
    grep -vE '^[[:space:]]*#' "$f" | grep -nE "$POSIX_PATTERN" | sed 's/^/    /'
    POSIX_FAIL=$((POSIX_FAIL + 1))
    TOTAL_FAIL=$((TOTAL_FAIL + 1))
    FAILED_FILES="${FAILED_FILES}${FAILED_FILES:+, }posix-test:$(basename "$f")"
  else
    printf '  PASS posix-test %s\n' "${f#"$PLUGIN_ROOT"/}"
    TOTAL_PASS=$((TOTAL_PASS + 1))
  fi
done < <(find "$PLUGIN_ROOT" -type f -name '*.sh' -not -path '*/node_modules/*')

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
