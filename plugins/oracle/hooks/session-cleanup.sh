#!/usr/bin/env bash
# session-cleanup.sh -- SessionEnd hook for oracle session-summary state.
#
# On every session termination:
#   1. Best-effort prune of session state dirs older than 30 days under
#      ~/.claude/plugins/oracle/sessions/.
#   2. Best-effort prune of legacy reads-<session>.tsv files older than
#      30 days (the safe-edit-guard's per-session state from oracle 0.5.0).
#
# SessionEnd hook is observability-only per the docs (no decision verb).
# We silently no-op on any failure -- the hook never blocks session
# termination.

set -u

fail_silent() { exit 0; }
trap fail_silent ERR

ORACLE_STATE="$HOME/.claude/plugins/oracle"
[ -d "$ORACLE_STATE" ] || exit 0

# Prune sessions/<id>/ directories last touched more than 30 days ago.
if [ -d "$ORACLE_STATE/sessions" ]; then
  find "$ORACLE_STATE/sessions" -mindepth 1 -maxdepth 1 -type d -mtime +30 \
    -exec rm -rf {} + 2>/dev/null || true
fi

# Prune legacy reads-<session>.tsv files from the safe-edit-guard.
find "$ORACLE_STATE" -maxdepth 1 -type f -name 'reads-*.tsv' -mtime +30 \
  -delete 2>/dev/null || true

exit 0
