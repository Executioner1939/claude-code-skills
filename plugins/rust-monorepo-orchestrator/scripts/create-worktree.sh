#!/usr/bin/env bash
# create-worktree.sh -- create an isolated git worktree + branch for one ticket.
#
# Usage: create-worktree.sh <ticket-id> <scope> <base-branch>
#
# Creates a branch named worker/<ticket-id> off <base-branch> and a worktree
# at <scope>/.refactor/worktrees/<ticket-id>. Prints the absolute worktree
# path on stdout (so the caller can capture it).

set -euo pipefail

TICKET_ID="${1:?ticket id required}"
SCOPE="${2:?scope required}"
BASE_BRANCH="${3:?base branch required}"

[ -d "$SCOPE/.git" ] || [ -f "$SCOPE/.git" ] || {
  echo "ERROR: $SCOPE is not a git repo" >&2
  exit 1
}

WORKER_BRANCH="worker/${TICKET_ID}"
WORKTREE_DIR="$SCOPE/.refactor/worktrees/${TICKET_ID}"

mkdir -p "$SCOPE/.refactor/worktrees"

# Clean up any stale worktree at this path (idempotent across retries).
if [ -d "$WORKTREE_DIR" ]; then
  git -C "$SCOPE" worktree remove --force "$WORKTREE_DIR" 2>/dev/null || true
  rm -rf "$WORKTREE_DIR"
fi

# Delete the (potentially-stale) worker branch.
if git -C "$SCOPE" show-ref --verify --quiet "refs/heads/$WORKER_BRANCH"; then
  git -C "$SCOPE" branch -D "$WORKER_BRANCH" 2>/dev/null || true
fi

# Create worktree + branch off the base.
git -C "$SCOPE" worktree add -b "$WORKER_BRANCH" "$WORKTREE_DIR" "$BASE_BRANCH" >&2

ABS=$(cd "$WORKTREE_DIR" && pwd)
echo "$ABS"
