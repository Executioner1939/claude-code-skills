#!/usr/bin/env bash
# refresh-inventory.sh — PostToolUse hook that keeps the design-system
# component graph fresh after edits.
#
# Runs inventory.py in the background when:
#   1. The edited file lives under components/(atoms|molecules|organisms|templates|pages)/
#   2. The project opts in (one of):
#        - $CLAUDE_PROJECT_DIR/.design-storybook-atomic/ already exists, or
#        - $CLAUDE_PROJECT_DIR/.design-storybook-atomic.yml exists
#   3. Last scan was > 30 seconds ago (debounce — avoids re-scanning on
#      every keystroke when the user is making a series of edits).
#
# The scanner runs detached so it never blocks the user. Output goes to
# .design-storybook-atomic/inventory.json. Errors are logged to
# .design-storybook-atomic/scan.log and silently swallowed — a stale
# inventory is better than a noisy hook.
#
# Why a hook? The audit-* skills used to re-walk the filesystem inside
# an LLM agent on every run. With this hook, the inventory is always
# fresh and audits become reads instead of scans.

set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-}"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"

if [[ -z "$PLUGIN_ROOT" || ! -d "$PLUGIN_ROOT" ]]; then
  exit 0
fi

# Read the hook payload from stdin. Tolerate missing jq.
input=""
if [[ -p /dev/stdin || -t 0 ]]; then
  input="$(cat || true)"
fi

# Extract file_path. Accept Edit, Write, MultiEdit shapes.
file_path=""
if command -v jq >/dev/null 2>&1 && [[ -n "$input" ]]; then
  file_path="$(printf '%s' "$input" | jq -r '
    .tool_input.file_path
    // .tool_input.notebook_path
    // (.tool_input.edits[0].file_path // empty)
    // empty' 2>/dev/null || true)"
fi

[[ -z "$file_path" ]] && exit 0

# Only react to component-tier files.
case "$file_path" in
  *components/atoms/*|*components/molecules/*|*components/organisms/*|*components/templates/*|*components/pages/*) ;;
  *) exit 0 ;;
esac

# Opt-in gate.
INV_DIR="$PROJECT_DIR/.design-storybook-atomic"
if [[ ! -d "$INV_DIR" && ! -f "$PROJECT_DIR/.design-storybook-atomic.yml" ]]; then
  exit 0
fi

mkdir -p "$INV_DIR"

# Debounce — last scan within 30s, skip.
LAST="$INV_DIR/.last-scan"
now=$(date +%s)
if [[ -f "$LAST" ]]; then
  prev=$(cat "$LAST" 2>/dev/null || echo 0)
  if (( now - prev < 30 )); then
    exit 0
  fi
fi
echo "$now" > "$LAST"

# Locate Python.
PY="$(command -v python3 || command -v python || true)"
[[ -z "$PY" ]] && exit 0

SCAN="$PLUGIN_ROOT/scripts/inventory.py"
[[ -f "$SCAN" ]] || exit 0

# Run detached. Don't block the user; don't surface scan errors in chat.
nohup "$PY" "$SCAN" scan \
  --root "$PROJECT_DIR" \
  --tier all \
  --out "$INV_DIR/inventory.json" \
  >> "$INV_DIR/scan.log" 2>&1 &

disown 2>/dev/null || true
exit 0
