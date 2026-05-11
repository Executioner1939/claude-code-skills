#!/usr/bin/env bash
# auto-commit.sh -- Stop hook: commit the worker's pending changes using a
# conventional-commits message derived from the ticket frontmatter.
#
# Wired in by dispatch-worker.sh via a per-session --settings JSON that
# registers this script as a Stop hook command. Receives hook context on
# stdin (we don't currently parse it) and reads ticket metadata from env
# vars set by the dispatcher:
#
#   CLAUDE_TICKET_ID     -- the ticket id (e.g. T-007)
#   CLAUDE_TICKET_PATH   -- absolute path to the claimed ticket .md file
#   CLAUDE_WORKTREE      -- absolute path to the worker's worktree
#
# If the working tree is clean, this script is a no-op (the worker already
# committed). Otherwise it stages everything in the worktree and commits
# with a message of the form:
#
#   <type>(<scope>): <objective> [T-NNN]
#
# Where <type> comes from `commit_type:` in the ticket frontmatter
# (defaulting to a severity-derived value: BLOCKING -> refactor,
# NEEDS-WORK -> refactor, NIT -> chore, BUG/FIX -> fix), <scope> comes
# from the ticket's `domain:`, and <objective> is the first non-blank
# line under the ticket's `## objective` section.

set -euo pipefail

# Drain stdin (Claude Code feeds a JSON context object; we ignore it).
if [ ! -t 0 ]; then
  cat >/dev/null 2>&1 || true
fi

TICKET_ID="${CLAUDE_TICKET_ID:-}"
TICKET_PATH="${CLAUDE_TICKET_PATH:-}"
WORKTREE="${CLAUDE_WORKTREE:-$(pwd)}"

# Best-effort fallback: derive ticket id from worker branch name.
if [ -z "$TICKET_ID" ]; then
  BR=$(git -C "$WORKTREE" branch --show-current 2>/dev/null || true)
  case "$BR" in
    worker/*) TICKET_ID="${BR#worker/}" ;;
  esac
fi

# If we cannot identify the ticket, do nothing (this is a safety net, not a primary path).
[ -n "$TICKET_ID" ] || exit 0

# Find the ticket file if env var not set.
if [ -z "$TICKET_PATH" ]; then
  SCOPE=$(git -C "$WORKTREE" worktree list 2>/dev/null | head -1 | awk '{print $1}')
  if [ -n "$SCOPE" ] && [ -d "$SCOPE/.refactor/inbox" ]; then
    TICKET_PATH=$(find "$SCOPE/.refactor/inbox" -name "$TICKET_ID.md" -path '*/claimed/*' 2>/dev/null | head -1)
  fi
fi
[ -f "$TICKET_PATH" ] || exit 0

# Refuse to commit if the worktree has nothing to commit.
if [ -z "$(git -C "$WORKTREE" status --porcelain 2>/dev/null)" ]; then
  exit 0
fi

# Read frontmatter fields.
fm_field() {
  awk -F': ' -v key="$1" '
    BEGIN { in_fm=0 }
    /^---$/ { in_fm = !in_fm; next }
    in_fm && $1 == key {
      sub(/^[ \t]*/, "", $2)
      gsub(/"/, "", $2)
      print $2
      exit
    }
  ' "$TICKET_PATH"
}

COMMIT_TYPE=$(fm_field commit_type)
DOMAIN=$(fm_field domain)
SEVERITY=$(fm_field severity)

# Default commit_type by severity if absent.
if [ -z "$COMMIT_TYPE" ]; then
  case "$SEVERITY" in
    BLOCKING)   COMMIT_TYPE=refactor ;;
    NEEDS-WORK) COMMIT_TYPE=refactor ;;
    NIT)        COMMIT_TYPE=chore ;;
    BUG|FIX)    COMMIT_TYPE=fix ;;
    *)          COMMIT_TYPE=refactor ;;
  esac
fi

# Extract the first non-blank line under "## objective".
OBJECTIVE=$(awk '
  /^## objective/ { flag=1; next }
  /^## / && flag  { exit }
  flag && NF      { print; exit }
' "$TICKET_PATH" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

# Trim to 72 chars for the subject line (conventional commits convention).
if [ "${#OBJECTIVE}" -gt 60 ]; then
  OBJECTIVE="${OBJECTIVE:0:57}..."
fi

# Build subject line. Scope segment uses the ticket domain.
SCOPE_SEG="${DOMAIN:-refactor}"
SUBJECT="${COMMIT_TYPE}(${SCOPE_SEG}): ${OBJECTIVE} [${TICKET_ID}]"

# Stage all changes within the worktree.
git -C "$WORKTREE" add -A

# Commit. Use -m for the subject and a second -m for the body.
git -C "$WORKTREE" -c user.name="orchestrator-bot" -c user.email="orchestrator@localhost" \
  commit -m "$SUBJECT" -m "Ticket: $TICKET_ID
Domain: $DOMAIN
Auto-committed by the Stop hook." >/dev/null 2>&1 || true

# Always exit 0; a failed commit (e.g., nothing to commit after re-check) must
# not block the worker's Stop event.
exit 0
