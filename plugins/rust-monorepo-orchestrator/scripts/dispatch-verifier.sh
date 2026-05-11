#!/usr/bin/env bash
# dispatch-verifier.sh -- spawn one verifier via `claude -p` and return a verdict.
#
# Usage: dispatch-verifier.sh <ticket-id> <worktree-path> <plugin-dir> <state-dir> <inbox-dir> <domain> <scope>
#
# Prints exactly one verdict line on stdout: PASS, FAIL, RETRY, or DEAD_LETTER.
# DEAD_LETTER is decided by the Ralph loop (this script never emits it directly);
# the verifier emits PASS / FAIL / RETRY only. Full stream-json output goes to
# <state-dir>/verifiers/<ticket-id>/log.jsonl.

set -euo pipefail

TICKET_ID="${1:?ticket id required}"
WORKTREE="${2:?worktree required}"
PLUGIN_DIR="${3:?plugin dir required}"
STATE_DIR="${4:?state dir required}"
INBOX_DIR="${5:?inbox dir required}"
DOMAIN="${6:?domain required}"
SCOPE="${7:?scope required}"

VERIFIER_STATE="$STATE_DIR/verifiers/$TICKET_ID"
mkdir -p "$VERIFIER_STATE"

LOG="$VERIFIER_STATE/log.jsonl"
OUT="$VERIFIER_STATE/output.txt"
ERR="$VERIFIER_STATE/stderr.log"

TICKET_PATH="$INBOX_DIR/claimed/$TICKET_ID.md"
SGCONFIG="$SCOPE/sgconfig.yml"
TESTS_JSON="$SCOPE/.refactor/domains/$DOMAIN/tests.json"

# Find the worker's RESULT.md. The ticket-implementer writes it inside the worktree.
RESULT_PATH=$(find "$WORKTREE" -maxdepth 2 -name "${TICKET_ID}-RESULT.md" -type f 2>/dev/null | head -1)

if [ -z "$RESULT_PATH" ] || [ ! -f "$RESULT_PATH" ]; then
  echo "VERDICT_REASON: missing-result-md" > "$VERIFIER_STATE/verdict-reason.txt"
  echo "FAIL"
  exit 0
fi

PROMPT="Verify ticket ${TICKET_ID}.

ticket_path: ${TICKET_PATH}
result_path: ${RESULT_PATH}
worktree:    ${WORKTREE}
sgconfig:    ${SGCONFIG}
tests_json:  ${TESTS_JSON}

Run all acceptance checks per your system prompt. End your final response
with exactly ONE line of the form:

VERDICT: PASS    (or FAIL or RETRY)
REASON:  <one-line reason>

Followed by HANDOFF: <abs path of HANDOFF.md>."

cd "$WORKTREE"

set +e
claude -p \
  --bare \
  --plugin-dir "$PLUGIN_DIR" \
  --agent "rust-monorepo-orchestrator:verifier" \
  --permission-mode plan \
  --allowedTools "Read,Glob,Grep,Bash" \
  --max-turns 30 \
  --output-format stream-json \
  --verbose \
  --include-partial-messages \
  "$PROMPT" \
  > "$LOG" 2> "$ERR"
RC=$?
set -e

# Extract final assistant text.
if command -v jq >/dev/null 2>&1 && [ -s "$LOG" ]; then
  jq -rj 'select(.type == "stream_event" and .event.delta.type? == "text_delta") | .event.delta.text' < "$LOG" > "$OUT" 2>/dev/null || true
fi

# Parse the verdict line from output.txt. Robust to surrounding text.
VERDICT="FAIL"
REASON="unknown"
if [ -s "$OUT" ]; then
  V_LINE=$(grep -E '^[[:space:]]*VERDICT:[[:space:]]+(PASS|FAIL|RETRY)' "$OUT" | tail -1 || true)
  R_LINE=$(grep -E '^[[:space:]]*REASON:' "$OUT" | tail -1 || true)
  if [ -n "$V_LINE" ]; then
    VERDICT=$(echo "$V_LINE" | sed -E 's/^[[:space:]]*VERDICT:[[:space:]]+([A-Z]+).*/\1/')
  fi
  if [ -n "$R_LINE" ]; then
    REASON=$(echo "$R_LINE" | sed -E 's/^[[:space:]]*REASON:[[:space:]]+//')
  fi
fi

echo "VERDICT_REASON: $REASON" > "$VERIFIER_STATE/verdict-reason.txt"

# If the worker process itself aborted (non-zero RC and no parseable verdict),
# downgrade to FAIL with the aborted reason.
if [ "$RC" -ne 0 ] && [ "$VERDICT" = "FAIL" ] && [ "$REASON" = "unknown" ]; then
  echo "VERDICT_REASON: verifier-aborted (exit=$RC)" > "$VERIFIER_STATE/verdict-reason.txt"
fi

echo "$VERDICT"
