#!/usr/bin/env bash
# init.sh -- bootstrap a fresh orchestrator context window.
#
# Implements the Anthropic Opus 4.7 multi-context-window workflow: a fresh
# planner / orchestrator window can resume cold by calling this script and
# reading the artefacts it points to. State lives on disk under .refactor/;
# the script summarizes that state and prints next-step pointers.
#
# Usage: init.sh [<scope>]
#   <scope> defaults to current working directory.

set -euo pipefail

SCOPE="${1:-$(pwd)}"
SCOPE=$(cd "$SCOPE" && pwd)

REFACTOR="$SCOPE/.refactor"
mkdir -p "$REFACTOR"/{handoffs,domains,inbox,dead-letter,rules}

echo "=========================================="
echo "  rust-monorepo-orchestrator context bootstrap"
echo "=========================================="
echo "scope:    $SCOPE"
echo "refactor: $REFACTOR"
echo

# Existing init artefacts.
if [ -f "$REFACTOR/standard.md" ]; then
  echo "STANDARD: $REFACTOR/standard.md"
fi
if [ -f "$REFACTOR/stack.json" ]; then
  echo "STACK:    $REFACTOR/stack.json"
  if command -v jq >/dev/null 2>&1; then
    jq -r '
      "  framework: " + (.framework // "?"),
      "  edition:   " + (.edition // "?"),
      "  workspace_crates: " + ((.workspace_crates // [] | length) | tostring),
      "  layers_detected: " + ((.layers_detected // []) | join(", "))
    ' "$REFACTOR/stack.json" 2>/dev/null || true
  fi
fi
echo

# Domain summary.
echo "DOMAINS:"
if [ -d "$REFACTOR/domains" ] && [ -n "$(ls -A "$REFACTOR/domains" 2>/dev/null)" ]; then
  for d in "$REFACTOR/domains"/*/; do
    [ -d "$d" ] || continue
    NAME=$(basename "$d")
    HAS_VIOL=$([ -f "$d/violations.md" ] && echo "violations" || echo "-")
    HAS_PLAN=$([ -f "$d/PLAN.md" ] && echo "plan" || echo "-")
    HAS_INBOX=$([ -d "$REFACTOR/inbox/$NAME" ] && echo "inbox" || echo "-")
    echo "  $NAME: $HAS_VIOL / $HAS_PLAN / $HAS_INBOX"
  done
else
  echo "  (none yet -- run /rust-monorepo-orchestrator:audit-domain <name>)"
fi
echo

# Active inbox state.
echo "INBOX (pending / claimed / done / failed):"
if [ -d "$REFACTOR/inbox" ] && [ -n "$(ls -A "$REFACTOR/inbox" 2>/dev/null)" ]; then
  for d in "$REFACTOR/inbox"/*/; do
    [ -d "$d" ] || continue
    NAME=$(basename "$d")
    P=$(find "$d/pending" -maxdepth 1 -name 'T-*.md' 2>/dev/null | wc -l | tr -d ' ')
    C=$(find "$d/claimed" -maxdepth 1 -name 'T-*.md' 2>/dev/null | wc -l | tr -d ' ')
    D=$(find "$d/done"    -maxdepth 1 -name 'T-*.md' 2>/dev/null | wc -l | tr -d ' ')
    F=$(find "$d/failed"  -maxdepth 1 -name 'T-*.md' 2>/dev/null | wc -l | tr -d ' ')
    echo "  $NAME: $P / $C / $D / $F"
  done
else
  echo "  (no waves dispatched yet)"
fi
echo

# Dead-letter.
DL=$(find "$REFACTOR/dead-letter" -maxdepth 1 -name 'T-*.md' 2>/dev/null | wc -l | tr -d ' ')
if [ "$DL" -gt 0 ]; then
  echo "DEAD-LETTER: $DL ticket(s) need human attention -- see $REFACTOR/dead-letter/"
  echo
fi

# Recent handoffs.
echo "RECENT HANDOFFS (last 5):"
if [ -d "$REFACTOR/handoffs" ]; then
  find "$REFACTOR/handoffs" -name 'phase-*.md' -type f 2>/dev/null \
    | sort -r | head -5 | sed 's|^|  |'
fi
echo

# Active worktrees (orchestrator-spawned).
WT_COUNT=$(git -C "$SCOPE" worktree list 2>/dev/null | wc -l | tr -d ' ')
if [ "${WT_COUNT:-0}" -gt 1 ]; then
  echo "ACTIVE WORKTREES:"
  git -C "$SCOPE" worktree list | tail -n +2 | sed 's|^|  |'
  echo
fi

echo "=========================================="
echo "Resume hints:"
echo "  - Read $REFACTOR/standard.md for the target architectural standard."
echo "  - Read the most recent handoff above to see where the last phase left off."
echo "  - Run /rust-monorepo-orchestrator:status for the wave dashboard."
echo "=========================================="
