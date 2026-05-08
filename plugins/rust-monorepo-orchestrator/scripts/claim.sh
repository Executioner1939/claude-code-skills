#!/usr/bin/env bash
# claim.sh -- atomic ticket claim via POSIX rename(2).
#
# Usage: claim.sh <inbox-domain-dir> <ticket-id> <agent-id>
#
# Atomically moves <inbox>/pending/T-NNN.md -> <inbox>/claimed/T-NNN.md.
# Two workers may race; only one wins (POSIX rename is atomic on the same
# filesystem; mv -n refuses to overwrite). The loser exits 1.
#
# On success, stamps claimed_by / claimed_at into the ticket frontmatter
# and prints the absolute claimed path on stdout: `CLAIMED: <path>`.

set -euo pipefail

INBOX_DIR="${1:?inbox dir required}"
TICKET_ID="${2:?ticket id required}"
AGENT_ID="${3:?agent id required}"

PENDING="$INBOX_DIR/pending/$TICKET_ID.md"
CLAIMED_DIR="$INBOX_DIR/claimed"
CLAIMED="$CLAIMED_DIR/$TICKET_ID.md"

mkdir -p "$CLAIMED_DIR"

if [ ! -f "$PENDING" ]; then
  echo "ERROR: $PENDING does not exist (already claimed, never created, or wrong path)" >&2
  exit 1
fi

# Atomic claim. mv -n refuses to overwrite an existing target.
# If two workers race, only one rename succeeds; the loser sees a non-zero
# exit (or, on some platforms, success with the source still in place --
# we verify both directions below).
if ! mv -n "$PENDING" "$CLAIMED" 2>/dev/null; then
  echo "ERROR: $TICKET_ID claim failed (likely a race; another worker won)" >&2
  exit 1
fi

# Verify: claimed exists, pending no longer exists.
if [ ! -f "$CLAIMED" ] || [ -f "$PENDING" ]; then
  echo "ERROR: claim verification failed for $TICKET_ID" >&2
  exit 1
fi

# Stamp frontmatter. Use awk + tmp file (no in-place editing across platforms).
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
TMP=$(mktemp)
awk -v agent="$AGENT_ID" -v ts="$NOW" '
  /^claimed_by:/  { print "claimed_by: " agent; next }
  /^claimed_at:/  { print "claimed_at: " ts; next }
  /^status:/      { print "status: claimed"; next }
  { print }
' "$CLAIMED" > "$TMP"
mv "$TMP" "$CLAIMED"

ABS=$(cd "$(dirname "$CLAIMED")" && pwd)/$(basename "$CLAIMED")
echo "CLAIMED: $ABS"
exit 0
