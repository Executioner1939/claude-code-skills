#!/usr/bin/env bash
# update-progress.sh -- write the live progress.json snapshot for one wave.
# The monitor reads this file; cheap, idempotent.
#
# Usage: update-progress.sh <inbox-domain-dir> <state-dir>
#
# Emits JSON to stdout (caller redirects to <state-dir>/progress.json).

set -euo pipefail

INBOX_DIR="${1:?inbox dir required}"
STATE_DIR="${2:?state dir required}"

count() {
  local d="$1"
  if [ -d "$d" ]; then
    find "$d" -maxdepth 1 -name 'T-*.md' -type f 2>/dev/null | wc -l | tr -d ' '
  else
    echo 0
  fi
}

PENDING=$(count "$INBOX_DIR/pending")
CLAIMED=$(count "$INBOX_DIR/claimed")
DONE=$(count "$INBOX_DIR/done")
FAILED=$(count "$INBOX_DIR/failed")

SCOPE_DIR=$(dirname "$(dirname "$INBOX_DIR")")
DLQ=$(count "$SCOPE_DIR/dead-letter" 2>/dev/null || echo 0)

NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Active workers = subdirs of state/workers/ whose meta.json has no end_ts.
ACTIVE_WORKERS=0
if [ -d "$STATE_DIR/workers" ]; then
  for d in "$STATE_DIR/workers"/*/; do
    [ -d "$d" ] || continue
    META="$d/meta.json"
    [ -f "$META" ] || continue
    if ! grep -q '"end_ts"' "$META" 2>/dev/null; then
      ACTIVE_WORKERS=$((ACTIVE_WORKERS + 1))
    fi
  done
fi

cat <<EOF
{
  "ts": "$NOW",
  "inbox": {
    "pending": $PENDING,
    "claimed": $CLAIMED,
    "done": $DONE,
    "failed": $FAILED,
    "dead_letter": $DLQ
  },
  "active_workers": $ACTIVE_WORKERS,
  "state_dir": "$STATE_DIR"
}
EOF
