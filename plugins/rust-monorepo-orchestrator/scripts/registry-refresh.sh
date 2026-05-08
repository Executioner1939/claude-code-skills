#!/usr/bin/env bash
# registry-refresh.sh -- rebuild _registry.md for one inbox domain.
#
# Usage: registry-refresh.sh <inbox-domain-dir>
#
# Walks pending / claimed / done / failed sub-directories and emits a
# single Markdown file the orchestrator (and humans) read for state.
# Idempotent; safe to call repeatedly.

set -euo pipefail

INBOX_DIR="${1:?inbox dir required}"
[ -d "$INBOX_DIR" ] || { echo "ERROR: $INBOX_DIR does not exist" >&2; exit 1; }

REGISTRY="$INBOX_DIR/_registry.md"

count_dir() {
  local d="$1/$2"
  if [ -d "$d" ]; then
    find "$d" -maxdepth 1 -name 'T-*.md' -type f 2>/dev/null | wc -l | tr -d ' '
  else
    echo 0
  fi
}

frontmatter_field() {
  awk -F': ' -v key="$1" '
    BEGIN { in_fm=0 }
    /^---$/ { in_fm = !in_fm; next }
    in_fm && $1 == key { print $2; exit }
  ' "$2" 2>/dev/null
}

first_objective_line() {
  awk '/^## objective/{flag=1; next} /^##/{flag=0} flag && NF{print; exit}' "$1" 2>/dev/null
}

PENDING=$(count_dir "$INBOX_DIR" pending)
CLAIMED=$(count_dir "$INBOX_DIR" claimed)
DONE=$(count_dir "$INBOX_DIR" done)
FAILED=$(count_dir "$INBOX_DIR" failed)

NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
DOMAIN=$(basename "$INBOX_DIR")

{
  echo "# Inbox registry -- $DOMAIN"
  echo
  echo "Refreshed: $NOW"
  echo
  echo "| Status | Count |"
  echo "|---|---|"
  echo "| pending | $PENDING |"
  echo "| claimed | $CLAIMED |"
  echo "| done | $DONE |"
  echo "| failed | $FAILED |"
  echo
  echo "## Pending tickets"
  echo
  if [ "$PENDING" -gt 0 ]; then
    for f in "$INBOX_DIR/pending"/T-*.md; do
      [ -f "$f" ] || continue
      ID=$(basename "$f" .md)
      OBJ=$(first_objective_line "$f")
      echo "- $ID -- ${OBJ:-(no objective line)}"
    done
  else
    echo "(none)"
  fi
  echo
  echo "## Claimed tickets"
  echo
  if [ "$CLAIMED" -gt 0 ]; then
    for f in "$INBOX_DIR/claimed"/T-*.md; do
      [ -f "$f" ] || continue
      ID=$(basename "$f" .md)
      BY=$(frontmatter_field claimed_by "$f")
      AT=$(frontmatter_field claimed_at "$f")
      echo "- $ID -- by \`${BY:-?}\` at ${AT:-?}"
    done
  else
    echo "(none)"
  fi
  echo
  echo "## Recently failed (last 10)"
  echo
  if [ "$FAILED" -gt 0 ]; then
    ls -1t "$INBOX_DIR/failed"/T-*.md 2>/dev/null | head -10 | while read -r f; do
      [ -f "$f" ] || continue
      ID=$(basename "$f" .md)
      ATT=$(frontmatter_field attempts "$f")
      echo "- $ID -- attempts: ${ATT:-?}"
    done
  else
    echo "(none)"
  fi
} > "$REGISTRY"

echo "REGISTRY_REFRESHED: $REGISTRY"
