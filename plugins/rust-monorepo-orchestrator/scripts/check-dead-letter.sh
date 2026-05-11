#!/usr/bin/env bash
# check-dead-letter.sh -- inspect a failed ticket; if attempts >= max_attempts,
# move it to dead-letter/. Otherwise, return it to pending/ for another try.
#
# Usage: check-dead-letter.sh <inbox-domain-dir> <scope> <ticket-id>
#
# Reads `attempts` and `max_attempts` from the ticket frontmatter. Default
# max_attempts is 3 if absent.

set -euo pipefail

INBOX_DIR="${1:?inbox dir required}"
SCOPE="${2:?scope required}"
TICKET_ID="${3:?ticket id required}"

FAILED="$INBOX_DIR/failed/$TICKET_ID.md"

if [ ! -f "$FAILED" ]; then
  echo "ERROR: $FAILED missing; cannot triage" >&2
  exit 1
fi

frontmatter_field() {
  awk -F': ' -v key="$1" '
    BEGIN { in_fm=0 }
    /^---$/ { in_fm = !in_fm; next }
    in_fm && $1 == key { sub(/^[ \t]*/, "", $2); print $2; exit }
  ' "$FAILED" 2>/dev/null | tr -d '"'
}

ATTEMPTS=$(frontmatter_field attempts)
MAX_ATTEMPTS=$(frontmatter_field max_attempts)
ATTEMPTS=${ATTEMPTS:-0}
MAX_ATTEMPTS=${MAX_ATTEMPTS:-3}

if [ "$ATTEMPTS" -ge "$MAX_ATTEMPTS" ]; then
  DLQ_DIR="$SCOPE/.refactor/dead-letter"
  mkdir -p "$DLQ_DIR"
  DLQ="$DLQ_DIR/$TICKET_ID.md"
  mv "$FAILED" "$DLQ"
  echo "DEAD_LETTER: $DLQ (attempts=$ATTEMPTS / max=$MAX_ATTEMPTS)"
  exit 0
fi

# Move back to pending for another attempt. Strip claim metadata.
PENDING_DIR="$INBOX_DIR/pending"
PENDING="$PENDING_DIR/$TICKET_ID.md"
mkdir -p "$PENDING_DIR"
TMP=$(mktemp)
awk '
  BEGIN { in_fm=0 }
  /^---$/ { in_fm = !in_fm; print; next }
  in_fm && /^claimed_by:/  { print "claimed_by: \"\""; next }
  in_fm && /^claimed_at:/  { print "claimed_at: \"\""; next }
  in_fm && /^status:/      { print "status: pending"; next }
  { print }
' "$FAILED" > "$TMP"
mv "$TMP" "$PENDING"
rm -f "$FAILED"
echo "RETURNED_TO_PENDING_FOR_RETRY: $PENDING (attempts=$ATTEMPTS / max=$MAX_ATTEMPTS)"
