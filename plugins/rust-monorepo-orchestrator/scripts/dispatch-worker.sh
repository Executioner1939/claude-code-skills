#!/usr/bin/env bash
# dispatch-worker.sh -- spawn one ticket-implementer via `claude -p`.
#
# Usage: dispatch-worker.sh <ticket-id> <worktree-path> <plugin-dir> <state-dir> <inbox-dir> <domain>
#
# Runs as an OS-level process. Writes stream-json events to
# <state-dir>/workers/<ticket-id>/log.jsonl and the final assistant
# message to <state-dir>/workers/<ticket-id>/output.txt.
#
# Exits non-zero on `claude -p` failure. The Ralph loop interprets a
# non-zero exit as "worker did not yield RESULT.md" -- the verifier
# will still classify the ticket but with `worker-aborted` reason.

set -euo pipefail

TICKET_ID="${1:?ticket id required}"
WORKTREE="${2:?worktree required}"
PLUGIN_DIR="${3:?plugin dir required}"
STATE_DIR="${4:?state dir required}"
INBOX_DIR="${5:?inbox dir required}"
DOMAIN="${6:?domain required}"

WORKER_STATE="$STATE_DIR/workers/$TICKET_ID"
mkdir -p "$WORKER_STATE"

LOG="$WORKER_STATE/log.jsonl"
OUT="$WORKER_STATE/output.txt"
ERR="$WORKER_STATE/stderr.log"
META="$WORKER_STATE/meta.json"

START_TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Persist dispatch metadata for the monitor.
cat > "$META" <<EOF
{
  "ticket_id": "$TICKET_ID",
  "worktree": "$WORKTREE",
  "domain": "$DOMAIN",
  "start_ts": "$START_TS",
  "agent": "rust-monorepo-orchestrator:ticket-implementer"
}
EOF

TICKET_PATH="$INBOX_DIR/claimed/$TICKET_ID.md"
[ -f "$TICKET_PATH" ] || {
  echo "ERROR: ticket file missing at $TICKET_PATH (claim may have failed)" >&2
  echo "{\"error\":\"missing_ticket\",\"ticket\":\"$TICKET_ID\"}" >> "$LOG"
  exit 2
}

PROMPT="Implement ticket ${TICKET_ID}. Read the claimed ticket at:
${TICKET_PATH}

You are in your isolated worktree at:
${WORKTREE}

Follow the ticket's allowed_paths exactly. Run the acceptance commands. Commit
to the worker branch. Write RESULT.md per the orchestration-protocol skill
and end your output with HANDOFF: <abs path of RESULT.md>."

cd "$WORKTREE"

# Run `claude -p` headless. --bare for deterministic context, --plugin-dir to
# load this orchestrator plugin (gives the agent its system prompt + skills).
# stream-json for the live monitor; output.txt holds the final assistant text
# (extracted from the stream).
set +e
claude -p \
  --bare \
  --plugin-dir "$PLUGIN_DIR" \
  --agent "rust-monorepo-orchestrator:ticket-implementer" \
  --permission-mode acceptEdits \
  --allowedTools "Read,Edit,Write,Bash,Glob,Grep" \
  --max-turns 200 \
  --output-format stream-json \
  --verbose \
  --include-partial-messages \
  "$PROMPT" \
  > "$LOG" 2> "$ERR"
RC=$?
set -e

END_TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Extract final assistant text from the stream-json log (best-effort).
if command -v jq >/dev/null 2>&1 && [ -s "$LOG" ]; then
  jq -rj 'select(.type == "stream_event" and .event.delta.type? == "text_delta") | .event.delta.text' < "$LOG" > "$OUT" 2>/dev/null || true
fi

# Update meta with end timestamp and exit code.
TMP=$(mktemp)
jq --arg end "$END_TS" --argjson rc "$RC" '. + {end_ts: $end, exit_code: $rc}' "$META" > "$TMP" 2>/dev/null && mv "$TMP" "$META" || true

exit "$RC"
