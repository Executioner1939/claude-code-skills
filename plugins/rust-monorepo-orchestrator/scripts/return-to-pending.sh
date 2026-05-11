#!/usr/bin/env bash
# return-to-pending.sh -- move a claimed ticket back to pending and increment
# attempts. Used on RETRY verdicts. Caller decides retry vs dead-letter; this
# script only handles the move + counter bump.
#
# Usage: return-to-pending.sh <inbox-domain-dir> <ticket-id> [<hint>]
#
# If <hint> is provided, appends it to the ticket's objective as
# "RETRY HINT (attempt N): <hint>".

set -euo pipefail

INBOX_DIR="${1:?inbox dir required}"
TICKET_ID="${2:?ticket id required}"
HINT="${3:-}"

CLAIMED="$INBOX_DIR/claimed/$TICKET_ID.md"
PENDING_DIR="$INBOX_DIR/pending"
PENDING="$PENDING_DIR/$TICKET_ID.md"

mkdir -p "$PENDING_DIR"

if [ ! -f "$CLAIMED" ]; then
  echo "ERROR: $CLAIMED missing; cannot return to pending" >&2
  exit 1
fi

TMP=$(mktemp)
awk '
  BEGIN { in_fm=0; bumped=0 }
  /^---$/ { in_fm = !in_fm; print; next }
  in_fm && /^attempts:/ {
    n=$2 + 1
    print "attempts: " n
    bumped=1
    next
  }
  in_fm && /^claimed_by:/  { print "claimed_by: \"\""; next }
  in_fm && /^claimed_at:/  { print "claimed_at: \"\""; next }
  in_fm && /^status:/      { print "status: pending"; next }
  /^---$/ && in_fm==0 && bumped==0 {
    print "attempts: 1"
    print
    next
  }
  { print }
' "$CLAIMED" > "$TMP"

# If no attempts line existed at all, inject one.
if ! grep -q '^attempts:' "$TMP"; then
  awk '
    BEGIN { in_fm=0; injected=0 }
    /^---$/ { in_fm = !in_fm; print; next }
    in_fm && /^status:/ && !injected { print; print "attempts: 1"; injected=1; next }
    { print }
  ' "$TMP" > "${TMP}.2" && mv "${TMP}.2" "$TMP"
fi

if [ -n "$HINT" ]; then
  ATTEMPTS=$(awk '/^attempts:/ {print $2; exit}' "$TMP")
  printf "\n\nRETRY HINT (attempt %s): %s\n" "${ATTEMPTS:-?}" "$HINT" >> "$TMP"
fi

mv "$TMP" "$PENDING"
rm -f "$CLAIMED"
echo "RETURNED_TO_PENDING: $PENDING"
