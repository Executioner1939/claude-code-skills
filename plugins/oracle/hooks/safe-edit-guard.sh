#!/usr/bin/env bash
# safe-edit-guard.sh -- PreToolUse hook for the oracle plugin.
#
# Fires on Edit, Write, MultiEdit, and NotebookEdit tool calls. Consults
# the per-session reads state file written by track-reads.sh. If the
# target path has not been Read in the current session (or was last
# Read more than 50 tool calls ago, approximated by a 30-minute wall
# clock window), emits a non-blocking reminder.
#
# This addresses the corpus-wide error class:
#   "File has not been read yet. Read it first before writing to it."
#   "File has been modified since read"
#   "String to replace not found in file."
#
# Behaviour:
#   - Silent if the file was Read within the freshness window.
#   - Silent if the file does not exist (new-file write is a normal case).
#   - additionalContext reminder otherwise.
#
# Does NOT block. The agent decides whether to re-Read before proceeding.

set -u

fail_silent() { exit 0; }
trap fail_silent ERR

INPUT=$(cat)
command -v jq >/dev/null 2>&1 || fail_silent

TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
[ -z "${TOOL_NAME:-}" ] && fail_silent
case "$TOOL_NAME" in
  Edit|Write|MultiEdit|NotebookEdit) : ;;
  *) fail_silent ;;
esac

# Edit/Write/NotebookEdit all carry `file_path`; MultiEdit carries `file_path` at top level too.
PATH_FIELD=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' 2>/dev/null)
[ -n "$PATH_FIELD" ] || fail_silent

# Resolve to absolute. If realpath isn't available, leave as-is; the match below is path-string equality.
if command -v realpath >/dev/null 2>&1; then
  RESOLVED=$(realpath -m -- "$PATH_FIELD" 2>/dev/null) || RESOLVED="$PATH_FIELD"
else
  RESOLVED="$PATH_FIELD"
fi

# A Write to a path that does not yet exist is a creation, not an edit;
# the read-first guard does not apply.
if [ "$TOOL_NAME" = "Write" ] && [ ! -e "$RESOLVED" ]; then
  exit 0
fi

SESSION_ID=$(printf '%s' "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)
if [ -z "$SESSION_ID" ]; then
  SESSION_ID=$(printf '%s' "${PWD:-noroot}" | shasum -a 256 2>/dev/null | awk '{print $1}' | head -c 16)
  [ -z "$SESSION_ID" ] && SESSION_ID="default"
fi

STATE_FILE="${HOME}/.claude/plugins/oracle/reads-${SESSION_ID}.tsv"

# Freshness window: 30 minutes. If we have no state file, fall back to "never read".
WINDOW_SECS=1800
NOW=$(date +%s 2>/dev/null) || NOW=0

found_fresh=0
if [ -f "$STATE_FILE" ]; then
  # Look for any Read entry of this path within the freshness window.
  while IFS=$'\t' read -r ts p; do
    [ -z "$ts" ] && continue
    [ -z "$p" ] && continue
    if [ "$p" = "$RESOLVED" ] || [ "$p" = "$PATH_FIELD" ]; then
      age=$((NOW - ts))
      if [ "$age" -lt "$WINDOW_SECS" ]; then
        found_fresh=1
        break
      fi
    fi
  done < "$STATE_FILE"
fi

[ "$found_fresh" -eq 1 ] && exit 0

# Emit non-blocking reminder via the documented hookSpecificOutput surface.
# Use a literal tilde prefix for display; shellcheck SC2088 is wrong here
# because we want the unexpanded form in the user-facing message.
DISPLAY_PATH="${RESOLVED#"$HOME"/}"
# shellcheck disable=SC2088
[ "$DISPLAY_PATH" = "$RESOLVED" ] || DISPLAY_PATH="~/${DISPLAY_PATH}"

REMINDER="Oracle safe-edit guard

About to ${TOOL_NAME} this file without a recent Read:
  ${DISPLAY_PATH}

Recommendation: Read the file first. ${TOOL_NAME} fails with 'File has not been read yet' or 'String to replace not found' when the in-context view is stale or absent. Across the local transcript corpus this single error class accounts for ~1,100 preventable failures.

Skip this reminder when: creating a brand-new file, or you Read this path within the last 30 minutes in this session.
"

jq -n --arg msg "$REMINDER" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    additionalContext: $msg
  }
}'

exit 0
