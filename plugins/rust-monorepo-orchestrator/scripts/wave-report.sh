#!/usr/bin/env bash
# wave-report.sh -- emit the final wave summary block.
#
# Usage: wave-report.sh <inbox-domain-dir> <state-dir> <wave-id> <scope>

set -euo pipefail

INBOX_DIR="${1:?inbox dir required}"
STATE_DIR="${2:?state dir required}"
WAVE_ID="${3:?wave id required}"
SCOPE="${4:?scope required}"

count() {
  local d="$1"
  if [ -d "$d" ]; then
    find "$d" -maxdepth 1 -name 'T-*.md' -type f 2>/dev/null | wc -l | tr -d ' '
  else
    echo 0
  fi
}

DONE=$(count "$INBOX_DIR/done")
FAILED=$(count "$INBOX_DIR/failed")
PENDING=$(count "$INBOX_DIR/pending")
CLAIMED=$(count "$INBOX_DIR/claimed")
DLQ=$(count "$SCOPE/.refactor/dead-letter")

# Find retained worktrees (failed tickets' worktrees still on disk).
RETAINED=""
if [ -d "$SCOPE/.refactor/worktrees" ]; then
  RETAINED=$(find "$SCOPE/.refactor/worktrees" -mindepth 1 -maxdepth 1 -type d | head -20)
fi

REPORT="$STATE_DIR/REPORT.md"
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)

{
  echo "=========================================="
  echo "  wave-orchestrator (ralph) complete"
  echo "=========================================="
  echo "  wave_id:    $WAVE_ID"
  echo "  finished:   $NOW"
  echo "  inbox:      $INBOX_DIR"
  echo ""
  echo "  outcome counts:"
  echo "    PASS (done):      $DONE"
  echo "    FAIL (failed):    $FAILED"
  echo "    DEAD_LETTER:      $DLQ"
  echo "    pending (left):   $PENDING"
  echo "    claimed (left):   $CLAIMED"
  echo ""
  echo "  state_dir:   $STATE_DIR"
  echo "  run_log:     $STATE_DIR/run.log"
  echo "  registry:    $INBOX_DIR/_registry.md"
  echo ""
  if [ -n "$RETAINED" ]; then
    echo "  retained worktrees (for inspection):"
    echo "$RETAINED" | sed 's/^/    /'
  else
    echo "  retained worktrees: (none)"
  fi
  echo ""
  echo "=========================================="
} | tee "$REPORT"
