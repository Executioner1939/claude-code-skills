#!/usr/bin/env bash
# move-to-done.sh -- move a claimed ticket to done/ after PASS + automerge.
#
# Usage: move-to-done.sh <inbox-domain-dir> <ticket-id>

set -euo pipefail

INBOX_DIR="${1:?inbox dir required}"
TICKET_ID="${2:?ticket id required}"

CLAIMED="$INBOX_DIR/claimed/$TICKET_ID.md"
DONE_DIR="$INBOX_DIR/done"
DONE="$DONE_DIR/$TICKET_ID.md"

mkdir -p "$DONE_DIR"

if [ ! -f "$CLAIMED" ]; then
  echo "ERROR: $CLAIMED missing; cannot move to done" >&2
  exit 1
fi

NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
TMP=$(mktemp)
awk -v ts="$NOW" '
  /^status:/    { print "status: done"; next }
  /^done_at:/   { print "done_at: " ts; next }
  { print }
' "$CLAIMED" > "$TMP"

# If done_at wasn't already in the frontmatter, append it.
if ! grep -q '^done_at:' "$TMP"; then
  awk -v ts="$NOW" '
    BEGIN { in_fm=0; stamped=0 }
    /^---$/ { in_fm = !in_fm; if (!in_fm && !stamped) { print "done_at: " ts; stamped=1 } print; next }
    { print }
  ' "$TMP" > "${TMP}.2" && mv "${TMP}.2" "$TMP"
fi

mv "$TMP" "$DONE"
rm -f "$CLAIMED"
echo "DONE: $DONE"
