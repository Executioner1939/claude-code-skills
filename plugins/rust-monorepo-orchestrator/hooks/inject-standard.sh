#!/usr/bin/env bash
# inject-standard.sh -- SessionStart hook script.
#
# If <scope>/.refactor/standard.md exists, emit it as additionalContext
# so it loads into every session (including subagent SessionStart) without
# the user having to paste it manually.

set -euo pipefail

STANDARD=".refactor/standard.md"
[ -f "$STANDARD" ] || exit 0

# Cap at 16k chars; the file is meant to be tight.
CONTENT=$(head -c 16000 "$STANDARD")

if command -v jq >/dev/null 2>&1; then
  jq -n --arg c "$CONTENT" '{
    hookSpecificOutput: {
      hookEventName: "SessionStart",
      additionalContext: ("Project target standard from .refactor/standard.md (loaded automatically by rust-monorepo-orchestrator):\n\n" + $c)
    }
  }'
elif command -v python3 >/dev/null 2>&1; then
  CONTENT="$CONTENT" python3 - <<'PY'
import json, os
content = os.environ.get("CONTENT", "")
print(json.dumps({
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Project target standard from .refactor/standard.md (loaded automatically by rust-monorepo-orchestrator):\n\n" + content
  }
}))
PY
else
  # No jq, no python3 -- fail silently rather than break the session start.
  exit 0
fi
