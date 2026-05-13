#!/usr/bin/env bash
# track-reads.sh -- PostToolUse hook for the oracle plugin.
#
# Records every Read tool invocation into a per-session state file so the
# companion PreToolUse hook (safe-edit-guard.sh) can detect Edit/Write
# tool calls that target a file the session has not Read recently.
#
# State file: ~/.claude/plugins/oracle/reads-<session>.tsv
# Format:    one line per Read, "<unix-epoch>\t<absolute-path>".
#
# Stateless on its own; the guard hook is the consumer.
#
# Failure modes are all fail-silent. The hook must never break a session.

set -u

fail_silent() { exit 0; }
trap fail_silent ERR

INPUT=$(cat)
command -v jq >/dev/null 2>&1 || fail_silent

TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
[ "${TOOL_NAME:-}" = "Read" ] || fail_silent

PATH_FIELD=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -n "${PATH_FIELD:-}" ] || fail_silent

SESSION_ID=$(printf '%s' "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
if [ -z "$SESSION_ID" ]; then
  # Fallback: hash the cwd so multi-session-per-repo still works.
  SESSION_ID=$(printf '%s' "${PWD:-noroot}" | shasum -a 256 2>/dev/null | awk '{print $1}' | head -c 16)
  [ -z "$SESSION_ID" ] && SESSION_ID="default"
fi

STATE_DIR="${HOME}/.claude/plugins/oracle"
mkdir -p "$STATE_DIR" 2>/dev/null || fail_silent
STATE_FILE="$STATE_DIR/reads-${SESSION_ID}.tsv"

NOW=$(date +%s 2>/dev/null) || fail_silent
printf '%s\t%s\n' "$NOW" "$PATH_FIELD" >> "$STATE_FILE" 2>/dev/null || fail_silent

# Trim the state file when it grows beyond 1000 lines to bound disk use.
LINES=$(wc -l < "$STATE_FILE" 2>/dev/null | tr -d ' ')
if [ -n "$LINES" ] && [ "$LINES" -gt 1000 ]; then
  tail -n 500 "$STATE_FILE" > "$STATE_FILE.tmp" 2>/dev/null && mv "$STATE_FILE.tmp" "$STATE_FILE" 2>/dev/null
fi

exit 0
