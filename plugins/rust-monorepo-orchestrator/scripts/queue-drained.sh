#!/usr/bin/env bash
# queue-drained.sh -- exit 0 iff the inbox has no pending and no claimed tickets.
#
# Usage: queue-drained.sh <inbox-domain-dir>
#
# Exit 0 = drained (Ralph loop should stop).
# Exit 1 = not drained (more work to do or workers in flight).

set -euo pipefail

INBOX_DIR="${1:?inbox dir required}"

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

if [ "$PENDING" -eq 0 ] && [ "$CLAIMED" -eq 0 ]; then
  exit 0
fi
exit 1
