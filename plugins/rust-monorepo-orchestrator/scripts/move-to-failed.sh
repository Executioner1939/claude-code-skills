#!/usr/bin/env bash
# move-to-failed.sh -- move a claimed ticket to failed/ after FAIL verdict.
# Caller decides whether to also dead-letter (see check-dead-letter.sh).
#
# Usage: move-to-failed.sh <inbox-domain-dir> <ticket-id> [<reason>]

set -euo pipefail

INBOX_DIR="${1:?inbox dir required}"
TICKET_ID="${2:?ticket id required}"
REASON="${3:-unspecified}"

CLAIMED="$INBOX_DIR/claimed/$TICKET_ID.md"
FAILED_DIR="$INBOX_DIR/failed"
FAILED="$FAILED_DIR/$TICKET_ID.md"

mkdir -p "$FAILED_DIR"

if [ ! -f "$CLAIMED" ]; then
  echo "ERROR: $CLAIMED missing; cannot move to failed" >&2
  exit 1
fi

NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)

TMP=$(mktemp)
awk -v ts="$NOW" -v reason="$REASON" '
  BEGIN { in_fm=0; bumped=0 }
  /^---$/ { in_fm = !in_fm; print; next }
  in_fm && /^attempts:/ {
    n=$2 + 1
    print "attempts: " n
    bumped=1
    next
  }
  in_fm && /^status:/         { print "status: failed"; next }
  in_fm && /^last_fail_at:/   { print "last_fail_at: " ts; next }
  in_fm && /^last_fail_reason:/ { print "last_fail_reason: \"" reason "\""; next }
  { print }
' "$CLAIMED" > "$TMP"

# Inject attempts/last_fail_at/last_fail_reason if missing.
inject_after_status() {
  local key="$1" val="$2"
  if ! grep -q "^${key}:" "$TMP"; then
    awk -v key="$key" -v val="$val" '
      BEGIN { in_fm=0; injected=0 }
      /^---$/ { in_fm = !in_fm; print; next }
      in_fm && /^status:/ && !injected { print; print key ": " val; injected=1; next }
      { print }
    ' "$TMP" > "${TMP}.2" && mv "${TMP}.2" "$TMP"
  fi
}
inject_after_status "attempts" "1"
inject_after_status "last_fail_at" "$NOW"
inject_after_status "last_fail_reason" "\"$REASON\""

mv "$TMP" "$FAILED"
rm -f "$CLAIMED"
echo "FAILED: $FAILED"
