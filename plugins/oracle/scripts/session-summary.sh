#!/usr/bin/env bash
# session-summary.sh -- emit a periodic session summary.
#
# Invoked by session-tick-start.sh when a summary threshold is crossed.
# Reads the transcript_path JSONL, counts events since the last-summary
# line index, formats Tier 1 (deterministic ship-receipt block), and if
# narrator != off, invokes `claude --model <m> -p` for the Tier 2
# CodeRabbit-style narrative + self-review questions.
#
# Usage:
#   session-summary.sh <transcript_path> <last_summary_line> <session_state_dir> \
#                      <turn_count> <active_ms> <wall_ms>
#
# Output: full multi-section summary to stdout (consumed as additionalContext
#         by the UserPromptSubmit hook that invokes this script).
#
# Exit codes:
#   0 success (or graceful no-op)
#   non-zero only on script-level failure
#
# Design notes:
#   - Tier 1 is always emitted; Tier 2 is best-effort and silently dropped
#     if `claude` is unavailable or the call times out.
#   - The narrator call is synchronous and bounded by a 60s timeout; the
#     UserPromptSubmit hook that invokes us has a higher hook timeout to
#     accommodate.

set -u
trap 'exit 0' ERR

TRANSCRIPT="${1:-}"
LAST_LINE="${2:-0}"
STATE_DIR="${3:-}"
TURN_COUNT="${4:-0}"
ACTIVE_MS="${5:-0}"
WALL_MS="${6:-0}"

[ -z "$TRANSCRIPT" ] || [ ! -f "$TRANSCRIPT" ] && exit 0
command -v jq >/dev/null 2>&1 || exit 0

# ---- Tier 1: deterministic counts ----
TOTAL_LINES=$(wc -l < "$TRANSCRIPT" 2>/dev/null | tr -d ' ')
TOTAL_LINES="${TOTAL_LINES:-0}"
START_LINE=$((LAST_LINE + 1))
NEW_LINES=$((TOTAL_LINES - LAST_LINE))
[ "$NEW_LINES" -lt 0 ] && NEW_LINES=0

# Extract tool-use blocks from the new slice of the transcript. Each line is
# one message object; assistant messages can contain tool_use entries in
# .message.content[].
SLICE=""
if [ "$NEW_LINES" -gt 0 ]; then
  SLICE=$(tail -n "+$START_LINE" "$TRANSCRIPT" 2>/dev/null || echo "")
fi

# Parse counts. Tolerate malformed lines via try/catch in jq.
counts_json=$(printf '%s\n' "$SLICE" | jq -s -c '
  [ .[] | try (
      .message.content[]? | select(.type == "tool_use") | .name
    ) catch empty
  ] | reduce .[] as $name ({}; .[$name] += 1)
' 2>/dev/null || echo "{}")

# Categorise into the buckets the summary block presents.
get_count() {
  local key="$1"
  printf '%s' "$counts_json" | jq -r --arg k "$key" '.[$k] // 0'
}

EDITS=$(( $(get_count Edit) + $(get_count Write) + $(get_count MultiEdit) ))
READS=$(get_count Read)
BASH_CALLS=$(get_count Bash)
TASKS_CREATED=$(get_count TaskCreate)
TASKS_UPDATED=$(get_count TaskUpdate)
AGENT_DISPATCHES=$(get_count Agent)
GREPS=$(get_count Grep)
GLOBS=$(get_count Glob)
WEBFETCHES=$(( $(get_count WebFetch) + $(get_count WebSearch) ))

# Extract a list of distinct files edited (up to 10).
files_edited=$(printf '%s\n' "$SLICE" | jq -r '
  try (.message.content[]? | select(.type == "tool_use") |
       select(.name == "Edit" or .name == "Write" or .name == "MultiEdit") |
       .input.file_path) catch empty
' 2>/dev/null | sort -u | head -10)

# Extract distinct bash commands (first token, up to 10).
bash_commands=$(printf '%s\n' "$SLICE" | jq -r '
  try (.message.content[]? | select(.type == "tool_use" and .name == "Bash") |
       .input.command) catch empty
' 2>/dev/null | awk '{print $1}' | sort -u | head -10)

# Wall-clock formatting.
active_min=$((ACTIVE_MS / 60000))
wall_min=$((WALL_MS / 60000))
idle_min=$((wall_min - active_min))
[ "$idle_min" -lt 0 ] && idle_min=0

# ---- Emit Tier 1 ----
cat <<EOF
============================================================
  oracle session checkpoint -- turn ${TURN_COUNT}
============================================================
  timing:
    active work:        ${active_min} min
    wall-clock:         ${wall_min} min
    user idle:          ${idle_min} min
  activity since last checkpoint (${NEW_LINES} transcript lines):
    file edits:         ${EDITS}
    file reads:         ${READS}
    bash invocations:   ${BASH_CALLS}
    grep / glob:        $((GREPS + GLOBS))
    web fetch / search: ${WEBFETCHES}
    tasks created:      ${TASKS_CREATED}
    tasks updated:      ${TASKS_UPDATED}
    subagent dispatch:  ${AGENT_DISPATCHES}
EOF

if [ -n "$files_edited" ]; then
  echo "  files touched (top 10):"
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    short="${f#"$HOME"/}"
    [ "$short" != "$f" ] && short="~/${short}"
    echo "    ${short}"
  done <<< "$files_edited"
fi

if [ -n "$bash_commands" ]; then
  echo "  bash verbs (top 10):"
  while IFS= read -r c; do
    [ -z "$c" ] && continue
    echo "    ${c}"
  done <<< "$bash_commands"
fi

echo "============================================================"

# ---- Tier 2: LLM narrator ----
NARRATOR_CONF="$HOME/.claude/plugins/oracle/narrator.conf"
NARRATOR="claude-sonnet-4-6"
if [ -f "$NARRATOR_CONF" ]; then
  NARRATOR=$(tr -d '[:space:]' < "$NARRATOR_CONF")
fi

if [ "$NARRATOR" = "off" ]; then
  exit 0
fi

if ! command -v claude >/dev/null 2>&1; then
  exit 0
fi

# Build the narrator prompt. Include the deterministic counts (the narrator
# uses them as ground truth) and a tail of assistant text outputs so it can
# narrate what was actually said and decided.
agent_text=$(printf '%s\n' "$SLICE" | jq -r '
  try (.message.content[]? | select(.type == "text") | .text) catch empty
' 2>/dev/null | tail -c 8000)

PROMPT=$(cat <<PEOF
You are a code-review-style narrator for a long Claude Code session. The
agent has been working for ${active_min} minutes of active time across
${TURN_COUNT} turns. Below is a structured snapshot of what happened since
the last checkpoint, plus a tail of the agent's own text output.

Counts since last checkpoint:
  file edits: ${EDITS}
  file reads: ${READS}
  bash invocations: ${BASH_CALLS}
  grep/glob: $((GREPS + GLOBS))
  web fetch/search: ${WEBFETCHES}
  tasks created: ${TASKS_CREATED}
  tasks updated: ${TASKS_UPDATED}
  subagent dispatch: ${AGENT_DISPATCHES}

Files touched (top 10):
${files_edited:-(none)}

Tail of agent's text output (last 8KB):
---
${agent_text:-(no text in this window)}
---

Produce a CodeRabbit-style review of the work done in this window, in
the following exact structure. Be specific, not generic. Cite the actual
files and decisions visible in the snapshot above.

## What was accomplished
(one paragraph, 3-5 sentences)

## Notable decisions
(bulleted list of 2-4 concrete decisions the agent made; if none are visible,
say so)

## Quality concerns and friction
(bulleted list of 2-4 specific things worth a second look -- defects,
backtracks, repeated retries, scope creep, missing tests, etc. -- or
explicitly say "no concerns surfaced in this window")

## Three review questions for the agent
1. (a specific question about the approach taken)
2. (a specific question about an assumption that should be revisited)
3. (a specific question about scope or next steps)

End the review there. Do not add a closing summary. Do not use emoji.
PEOF
)

# Invoke the narrator. 60s timeout. Discard stderr; on failure we fall back
# to Tier 1 only.
echo ""
echo "============================================================"
echo "  narrator (${NARRATOR})"
echo "============================================================"

narration=$(printf '%s' "$PROMPT" | timeout 60 claude --model "$NARRATOR" -p 2>/dev/null || echo "")
if [ -n "$narration" ]; then
  printf '%s\n' "$narration"
else
  echo "  (narrator unavailable or timed out; deterministic tier above is authoritative)"
fi
echo "============================================================"

exit 0
