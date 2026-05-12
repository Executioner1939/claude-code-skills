#!/usr/bin/env bash
# Integration tests for hooks/intercept-install.sh

set -u

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$TEST_DIR/.." && pwd)"
HOOK="$PLUGIN_ROOT/hooks/intercept-install.sh"

# shellcheck source=tests/lib/assert.sh
source "$TEST_DIR/lib/assert.sh"

run() {
  local cmd="$1"
  printf '%s' "$(jq -n --arg c "$cmd" '{tool_input: {command: $c}}')" | bash "$HOOK"
}

# ---------------------------------------------------------------------
# Unpinned: should emit a reminder.
# ---------------------------------------------------------------------

begin "unpinned npm install"
out=$(run "npm install next")
assert_contains "$out" "Oracle verification"
assert_contains "$out" "[next]"

begin "unpinned pnpm add (scoped pkg)"
out=$(run "pnpm add @xyflow/react")
assert_contains "$out" "[@xyflow/react]"

begin "unpinned cargo add"
out=$(run "cargo add tokio")
assert_contains "$out" "cargo add"
assert_contains "$out" "[tokio]"

begin "unpinned sudo apt-get install"
out=$(run "sudo apt-get install postgresql")
assert_contains "$out" "apt-get install"
assert_contains "$out" "[postgresql]"

begin "unpinned cd && npm install (second segment)"
out=$(run "cd /tmp/foo && npm install lodash")
assert_contains "$out" "[lodash]"

begin "mixed pinned + unpinned -> only unpinned listed"
out=$(run "npm install react@19 react-dom next")
assert_contains "$out" "[react-dom,next]"
assert_not_contains "$out" "react@19"

# ---------------------------------------------------------------------
# Pinned: should be silent.
# ---------------------------------------------------------------------

begin "pinned npm install (@ver)"
out=$(run "npm install next@16.2.6")
assert_eq "" "$out" "silent"

begin "pinned pnpm scoped"
out=$(run "pnpm add @xyflow/react@12.4.0")
assert_eq "" "$out" "silent"

begin "pinned pip install (==ver)"
out=$(run "pip install requests==2.31.0")
assert_eq "" "$out" "silent"

begin "pinned cargo add (@ver)"
out=$(run "cargo add tokio@1.40.0")
assert_eq "" "$out" "silent"

# ---------------------------------------------------------------------
# Manifest-driven: should be silent.
# ---------------------------------------------------------------------

begin "manifest-only pnpm install"
out=$(run "pnpm install")
assert_eq "" "$out" "silent"

begin "pip install -r requirements.txt"
out=$(run "pip install -r requirements.txt")
assert_eq "" "$out" "silent"

begin "cargo install with --version flag (pins via flag)"
out=$(run "cargo install ripgrep --version 14.0.0")
assert_eq "" "$out" "silent"

# ---------------------------------------------------------------------
# Flag-with-arg parsing (the bug we fixed in 0.1.1).
# ---------------------------------------------------------------------

begin "npm install lodash --prefix /tmp/sandbox: path is NOT a package"
out=$(run "npm install lodash --prefix /tmp/sandbox")
assert_contains "$out" "[lodash]"
assert_not_contains "$out" "/tmp/sandbox"

begin "cargo add tokio --features full: 'full' is not a package"
out=$(run "cargo add tokio --features full")
assert_contains "$out" "[tokio]"
assert_not_contains "$out" "full"

# ---------------------------------------------------------------------
# Non-install commands: silent.
# ---------------------------------------------------------------------

begin "ls is not an install"
out=$(run "ls -la")
assert_eq "" "$out" "silent"

begin "cargo build is not an install"
out=$(run "cargo build")
assert_eq "" "$out" "silent"

# ---------------------------------------------------------------------
# Tally
# ---------------------------------------------------------------------

printf '\n%d pass, %d fail (test-intercept-install)\n' "$PASS_COUNT" "$FAIL_COUNT"
[ "$FAIL_COUNT" -eq 0 ]
