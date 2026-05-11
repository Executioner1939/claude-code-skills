#!/usr/bin/env bash
# dispatch-worker.sh -- spawn one ticket-implementer via `claude -p`.
#
# Usage: dispatch-worker.sh <ticket-id> <worktree-path> <plugin-dir> <state-dir> <inbox-dir> <domain> [<scope>]
#
# Runs as an OS-level process. Writes stream-json events to
# <state-dir>/workers/<ticket-id>/log.jsonl and the final assistant
# message to <state-dir>/workers/<ticket-id>/output.txt.
#
# Per-session enhancements:
#   1. Exports CLAUDE_TICKET_ID / CLAUDE_TICKET_PATH / CLAUDE_WORKTREE /
#      CLAUDE_INBOX_DIR / CLAUDE_DOMAIN / CLAUDE_SCOPE so the per-session
#      hook scripts know which ticket the worker is on.
#   2. Generates a per-session settings JSON that registers:
#        - SessionStart  -> inject-workspace-tree.sh
#        - PreToolUse    -> enforce-allowed-paths.sh   (Edit/Write/NotebookEdit)
#        - Stop          -> auto-commit.sh
#      The settings JSON is written to <state-dir>/workers/<ticket-id>/settings.json
#      and passed via `claude -p --settings <file>`. Plugin subagent hooks
#      defined in frontmatter are ignored by Claude Code for security reasons;
#      this side-loaded settings file is the supported alternative for
#      per-session hook configuration.
#   3. Sets CARGO_TARGET_DIR to a wave-shared location so Rust workers
#      reuse compilation artifacts (the single biggest absolute time savings).
#      Override with CARGO_TARGET_DIR_PER_WORKER=1 to force per-worker dirs
#      if cargo lock contention becomes an issue.
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
SCOPE="${7:-}"

# Derive scope from worktree if not passed.
if [ -z "$SCOPE" ]; then
  SCOPE=$(git -C "$WORKTREE" worktree list 2>/dev/null | head -1 | awk '{print $1}')
fi

WORKER_STATE="$STATE_DIR/workers/$TICKET_ID"
mkdir -p "$WORKER_STATE"

LOG="$WORKER_STATE/log.jsonl"
OUT="$WORKER_STATE/output.txt"
ERR="$WORKER_STATE/stderr.log"
META="$WORKER_STATE/meta.json"
SETTINGS="$WORKER_STATE/settings.json"

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

# ----- Per-session settings JSON -----
# Registers SessionStart, PreToolUse, and Stop hooks. The hook commands are
# absolute paths so they work regardless of cwd. Each is silent on the
# happy path; SessionStart emits additionalContext; PreToolUse blocks
# (exit 2) when the agent tries to edit outside allowed_paths; Stop commits.
cat > "$SETTINGS" <<EOF
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash '$PLUGIN_DIR/scripts/inject-workspace-tree.sh'"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Edit|Write|NotebookEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bash '$PLUGIN_DIR/scripts/enforce-allowed-paths.sh'"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash '$PLUGIN_DIR/scripts/auto-commit.sh'"
          }
        ]
      }
    ]
  }
}
EOF

# ----- Shared CARGO_TARGET_DIR -----
# Workers compile from scratch in isolated worktrees by default. Pointing
# CARGO_TARGET_DIR at a wave-shared location lets cargo reuse compilation
# artifacts across workers. Trade-off: cargo serializes on the lock file
# when multiple workers run concurrent builds. In practice this is still
# 5-10x faster than fresh builds. Set CARGO_TARGET_DIR_PER_WORKER=1 to opt
# out (per-worker target dirs; slower but no contention).
if [ "${CARGO_TARGET_DIR_PER_WORKER:-0}" = "1" ]; then
  export CARGO_TARGET_DIR="$WORKER_STATE/cargo-target"
else
  export CARGO_TARGET_DIR="$SCOPE/.refactor/state/cargo-target-shared"
fi
mkdir -p "$CARGO_TARGET_DIR"

# ----- Env for hook scripts -----
export CLAUDE_TICKET_ID="$TICKET_ID"
export CLAUDE_TICKET_PATH="$TICKET_PATH"
export CLAUDE_WORKTREE="$WORKTREE"
export CLAUDE_INBOX_DIR="$INBOX_DIR"
export CLAUDE_DOMAIN="$DOMAIN"
export CLAUDE_SCOPE="$SCOPE"
export CLAUDE_PLUGIN_DIR_ABS="$PLUGIN_DIR"

PROMPT="Implement ticket ${TICKET_ID}.

The SessionStart hook has already injected the full workspace tree and the
list of files you should bulk-read before any other action. Read those files
in PARALLEL in your first response (one Read tool call per file, all in the
same response), then proceed to implement per the ticket at:

  ${TICKET_PATH}

You are in your isolated worktree at:
  ${WORKTREE}

Follow the ticket's allowed_paths exactly (the PreToolUse hook will reject
out-of-scope edits in real time -- if you see a BLOCKED message, surface the
file as a FOLLOW_UP in RESULT.md, do not retry the edit). Run the acceptance
commands. The Stop hook will commit any uncommitted changes automatically
with a conventional-commits message; you may still commit manually if you
prefer, but it is no longer required. Write RESULT.md per the
orchestration-protocol skill and end your output with HANDOFF: <abs path>."

cd "$WORKTREE"

set +e
claude -p \
  --bare \
  --plugin-dir "$PLUGIN_DIR" \
  --agent "rust-monorepo-orchestrator:ticket-implementer" \
  --settings "$SETTINGS" \
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
if command -v jq >/dev/null 2>&1; then
  jq --arg end "$END_TS" --argjson rc "$RC" '. + {end_ts: $end, exit_code: $rc}' "$META" > "$TMP" 2>/dev/null && mv "$TMP" "$META" || rm -f "$TMP"
fi

exit "$RC"
