#!/usr/bin/env bash
# automerge.sh -- merge worker branch into orchestrator branch and remove
# the worktree. Run after the verifier returns PASS.
#
# Usage: automerge.sh <ticket-id> <worktree-path> <worker-branch> [<orchestrator-branch>]
#
# Steps:
#   1. Sanity-check the worktree (exists, clean working tree).
#   2. From the main repo, switch to <orchestrator-branch> (default: current
#      branch when this script started running).
#   3. Try `git merge --ff-only <worker-branch>`; fall back to `--no-ff`
#      with a descriptive merge commit referencing the ticket id.
#   4. `git worktree remove --force <worktree-path>`.
#   5. `rm -rf` any residue (Rust target/ outside the worktree).
#   6. Delete the (now-merged) worker branch.
#
# Refuses to run if the worktree has uncommitted changes -- the worker is
# responsible for committing before yielding.

set -euo pipefail

TICKET_ID="${1:?ticket id required}"
WORKTREE_PATH="${2:?worktree path required}"
WORKER_BRANCH="${3:?worker branch required}"
ORCH_BRANCH_ARG="${4:-}"

[ -d "$WORKTREE_PATH" ] || { echo "ERROR: worktree $WORKTREE_PATH does not exist" >&2; exit 1; }

# Identify the original repo (the worktree's main repo). `git worktree list`
# prints the main repo first.
ORIG_REPO=$(git -C "$WORKTREE_PATH" worktree list | head -1 | awk '{print $1}')
[ -d "$ORIG_REPO/.git" ] || [ -f "$ORIG_REPO/.git" ] || {
  echo "ERROR: could not locate main repo for worktree $WORKTREE_PATH" >&2
  exit 1
}

# Verify the worktree is clean before any destructive op.
if [ -n "$(git -C "$WORKTREE_PATH" status --porcelain)" ]; then
  echo "ERROR: worktree $WORKTREE_PATH has uncommitted changes; refusing automerge" >&2
  echo "       The worker must commit before yielding." >&2
  git -C "$WORKTREE_PATH" status --short >&2
  exit 1
fi

# Resolve orchestrator branch.
if [ -n "$ORCH_BRANCH_ARG" ]; then
  ORCH_BRANCH="$ORCH_BRANCH_ARG"
else
  ORCH_BRANCH=$(git -C "$ORIG_REPO" rev-parse --abbrev-ref HEAD)
fi

# Switch the main repo to the orchestrator branch if not already there.
CURRENT=$(git -C "$ORIG_REPO" rev-parse --abbrev-ref HEAD)
if [ "$CURRENT" != "$ORCH_BRANCH" ]; then
  git -C "$ORIG_REPO" checkout "$ORCH_BRANCH"
fi

# Try fast-forward merge first.
if git -C "$ORIG_REPO" merge --ff-only "$WORKER_BRANCH" 2>/dev/null; then
  MERGE_MODE="ff"
else
  # Capture a one-line summary from the worker branch's last commit subject
  # for the merge commit message.
  WORKER_SUBJECT=$(git -C "$ORIG_REPO" log -1 --pretty=%s "$WORKER_BRANCH" 2>/dev/null || echo "(unknown)")
  git -C "$ORIG_REPO" merge --no-ff "$WORKER_BRANCH" \
    -m "ticket: $TICKET_ID -- automerged by orchestrator (worker subject: $WORKER_SUBJECT)"
  MERGE_MODE="no-ff"
fi

# Remove the worktree (force; we already verified clean state).
git -C "$ORIG_REPO" worktree remove --force "$WORKTREE_PATH"

# Belt-and-braces: remove any residue.
if [ -d "$WORKTREE_PATH" ]; then
  rm -rf "$WORKTREE_PATH"
fi

# Delete the (now-merged) worker branch.
if git -C "$ORIG_REPO" show-ref --verify --quiet "refs/heads/$WORKER_BRANCH"; then
  git -C "$ORIG_REPO" branch -d "$WORKER_BRANCH" 2>/dev/null || \
    git -C "$ORIG_REPO" branch -D "$WORKER_BRANCH"
fi

echo "MERGED: $TICKET_ID via $MERGE_MODE; worktree removed: $WORKTREE_PATH"
