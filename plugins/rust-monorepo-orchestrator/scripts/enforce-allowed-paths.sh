#!/usr/bin/env bash
# enforce-allowed-paths.sh -- PreToolUse hook for Edit/Write/NotebookEdit.
#
# Wired in by dispatch-worker.sh via a per-session --settings JSON that
# registers this script as a PreToolUse hook matching Edit|Write|NotebookEdit.
# Receives the hook input as JSON on stdin per Claude Code's hook protocol:
#
#   { "session_id": "...", "tool_name": "Edit",
#     "tool_input": { "file_path": "/abs/path", ... }, ... }
#
# Reads the active ticket's allowed_paths frontmatter field (set by the
# dispatcher via CLAUDE_TICKET_PATH) and exits 2 (BLOCK) if the file path is
# not within any allowed_paths entry. Exits 0 to allow the tool call.
#
# Out-of-scope blocking is the speed win: the worker sees the rejection in
# the same turn and corrects course, instead of completing the edit and
# being FAIL'd by the verifier 5 minutes later.

set -euo pipefail

TICKET_PATH="${CLAUDE_TICKET_PATH:-}"

# If the ticket path is not set, this hook cannot enforce; allow the call.
[ -n "$TICKET_PATH" ] && [ -f "$TICKET_PATH" ] || { exit 0; }

# Parse stdin (Claude Code's hook input JSON).
if [ -t 0 ] || ! command -v jq >/dev/null 2>&1; then
  # No stdin or no jq -- cannot enforce safely; allow.
  exit 0
fi

INPUT=$(cat)
TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null || echo "")
FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || echo "")

# If we cannot extract a file path, allow (the tool itself will validate).
[ -n "$FILE_PATH" ] || exit 0

# Read allowed_paths from frontmatter. Supports both list-of-lines and
# single-line `[a, b]` styles.
TMP_ALLOWED=$(python3 - "$TICKET_PATH" <<'PY'
import re, sys
text = open(sys.argv[1]).read()
if not text.startswith("---"):
    sys.exit(0)
end = text.find("\n---", 3)
if end < 0:
    sys.exit(0)
fm = text[3:end]
allowed = []
in_list = False
for line in fm.splitlines():
    stripped = line.strip()
    if stripped.startswith("allowed_paths:"):
        val = stripped[len("allowed_paths:"):].strip()
        if val.startswith("[") and val.endswith("]"):
            for x in val[1:-1].split(","):
                x = x.strip().strip('"').strip("'")
                if x:
                    allowed.append(x)
            break
        elif val == "" or val == "|":
            in_list = True
            continue
        else:
            allowed.append(val.strip('"').strip("'"))
            break
    elif in_list:
        m = re.match(r"^\s+-\s+(.*)$", line)
        if m:
            allowed.append(m.group(1).strip().strip('"').strip("'"))
        elif line.strip() and not line.startswith("  "):
            break
for p in allowed:
    print(p)
PY
)

# If no allowed_paths declared, allow (defensive default; the verifier still
# catches it). An empty allowed_paths is almost certainly a planner bug.
if [ -z "$TMP_ALLOWED" ]; then
  exit 0
fi

# Resolve file_path to absolute (it usually is already).
ABS_FILE="$FILE_PATH"
case "$ABS_FILE" in
  /*) ;;
  *) ABS_FILE="$(pwd)/$ABS_FILE" ;;
esac

# Determine the scope (worktree root) so we can compare relative paths
# against allowed_paths entries that are scope-relative.
SCOPE=$(git rev-parse --show-toplevel 2>/dev/null || true)
REL_FILE="$ABS_FILE"
if [ -n "$SCOPE" ]; then
  case "$ABS_FILE" in
    "$SCOPE"/*) REL_FILE="${ABS_FILE#"$SCOPE"/}" ;;
  esac
fi

# Compare. Each allowed_paths entry may be:
#   - a glob (foo/**, foo/*, foo/*.rs)
#   - an exact file (Cargo.toml)
#   - a directory (src/domain/)
# We use bash's [[ $f == $pattern ]] for glob matching, plus prefix tests
# for directory entries.
match=0
while IFS= read -r pat; do
  [ -z "$pat" ] && continue
  # Normalize: strip trailing slash.
  pat="${pat%/}"
  if [[ "$REL_FILE" == $pat ]]; then
    match=1; break
  fi
  if [[ "$REL_FILE" == "$pat" ]]; then
    match=1; break
  fi
  # Directory entry: allow anything under the dir.
  if [[ "$REL_FILE" == "$pat"/* ]]; then
    match=1; break
  fi
  # Glob with /** at end: bash [[ ]] matches /** correctly.
  if [[ "$REL_FILE" == ${pat%/\*\*}/* ]]; then
    case "$pat" in
      */\*\*) match=1; break ;;
    esac
  fi
done <<< "$TMP_ALLOWED"

if [ "$match" -eq 1 ]; then
  exit 0
fi

# Block. Exit 2 sends stderr back to the agent so it can correct.
TICKET_ID="${CLAUDE_TICKET_ID:-?}"
{
  echo "BLOCKED: $TOOL_NAME on '$FILE_PATH' is outside this ticket's allowed_paths."
  echo "Ticket: $TICKET_ID"
  echo "Allowed paths (from frontmatter):"
  printf '%s' "$TMP_ALLOWED" | sed 's/^/  - /'
  echo
  echo "If you believe this file SHOULD be in scope, surface it as a FOLLOW_UP in RESULT.md"
  echo "instead of editing it. The orchestrator will create a new ticket if appropriate."
} >&2

exit 2
