#!/usr/bin/env bash
# run-wave-ralph.sh -- the Ralph-loop wave runner.
#
# Replaces the wave-orchestrator subagent (which depended on nested
# `Agent` dispatch). Each iteration:
#   1. Check queue-drained -> break.
#   2. Compute ready set (deps + path-locks).
#   3. Per ticket in the ready set, in parallel:
#        a. Create worktree (off orchestrator branch).
#        b. Claim ticket atomically.
#        c. Spawn `claude -p ticket-implementer` as background process.
#   4. wait for all worker processes.
#   5. Per ticket, serial:
#        a. Spawn `claude -p verifier`; parse VERDICT line.
#        b. PASS  -> automerge + move-to-done.
#           RETRY -> return-to-pending (loop re-tries it).
#           FAIL  -> move-to-failed; check-dead-letter triages.
#        c. registry-refresh.
#   6. update-progress.
#
# Usage:
#   run-wave-ralph.sh <domain> <scope> [<wave_width=5>] [<max_iter=50>] [<plugin_dir>]
#
# The plugin dir defaults to the directory containing this script's parent,
# i.e. plugins/rust-monorepo-orchestrator/. Pass explicitly if invoking from
# an unusual location.

set -euo pipefail

DOMAIN="${1:?domain required}"
SCOPE="${2:?scope required}"
WAVE_WIDTH="${3:-5}"
MAX_ITER="${4:-50}"
PLUGIN_DIR="${5:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

INBOX="$SCOPE/.refactor/inbox/$DOMAIN"
[ -d "$INBOX" ] || { echo "ERROR: inbox $INBOX missing" >&2; exit 1; }

ORCH_BRANCH=$(git -C "$SCOPE" branch --show-current)
WAVE_ID="wave-$DOMAIN-$(date -u +%Y%m%dT%H%M%SZ)"
STATE="$SCOPE/.refactor/state/$WAVE_ID"
mkdir -p "$STATE/workers" "$STATE/verifiers" "$STATE/iterations"

RUN_LOG="$STATE/run.log"
PROGRESS="$STATE/progress.json"
LATEST_LINK="$SCOPE/.refactor/state/latest"

log() {
  local ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  printf '[%s] %s\n' "$ts" "$*" | tee -a "$RUN_LOG"
}

# Convenience symlink so the monitor can find the current wave without knowing the timestamp.
ln -sfn "$WAVE_ID" "$LATEST_LINK" 2>/dev/null || true

log "wave start: domain=$DOMAIN scope=$SCOPE wave_width=$WAVE_WIDTH max_iter=$MAX_ITER"
log "orchestrator_branch=$ORCH_BRANCH plugin_dir=$PLUGIN_DIR"
log "state_dir=$STATE"

# Sanity checks
command -v claude >/dev/null 2>&1 || { log "ERROR: 'claude' CLI not on PATH"; exit 1; }
command -v jq     >/dev/null 2>&1 || log "WARNING: 'jq' not on PATH; final-text extraction skipped"

bash "$PLUGIN_DIR/scripts/registry-refresh.sh" "$INBOX" >/dev/null
bash "$PLUGIN_DIR/scripts/update-progress.sh" "$INBOX" "$STATE" > "$PROGRESS"

iter=0
while (( iter < MAX_ITER )); do
  iter=$((iter + 1))
  ITER_DIR="$STATE/iterations/iter-$iter"
  mkdir -p "$ITER_DIR"

  # Drain check.
  if bash "$PLUGIN_DIR/scripts/queue-drained.sh" "$INBOX"; then
    log "iter=$iter queue drained; exiting loop"
    break
  fi

  # Compute ready set.
  READY=$(bash "$PLUGIN_DIR/scripts/compute-ready.sh" "$INBOX" "$WAVE_WIDTH" || true)
  if [ -z "$READY" ]; then
    log "iter=$iter no ready tickets (deps not yet satisfied, or path-lock contention). Sleeping 5s."
    sleep 5
    continue
  fi

  # Dispatch workers in parallel.
  declare -a PIDS=()
  declare -a TICKETS=()
  declare -A WORKTREES=()
  while IFS= read -r ticket; do
    [ -z "$ticket" ] && continue
    log "iter=$iter dispatch $ticket"
    if ! WORKTREE=$(bash "$PLUGIN_DIR/scripts/create-worktree.sh" "$ticket" "$SCOPE" "$ORCH_BRANCH" 2>>"$RUN_LOG"); then
      log "iter=$iter create-worktree FAILED for $ticket; skipping this iteration"
      continue
    fi
    if ! bash "$PLUGIN_DIR/scripts/claim.sh" "$INBOX" "$ticket" "ralph-wave-$iter" >>"$RUN_LOG"; then
      log "iter=$iter claim FAILED for $ticket (race lost); cleaning worktree"
      git -C "$SCOPE" worktree remove --force "$WORKTREE" 2>/dev/null || true
      continue
    fi
    bash "$PLUGIN_DIR/scripts/dispatch-worker.sh" \
      "$ticket" "$WORKTREE" "$PLUGIN_DIR" "$STATE" "$INBOX" "$DOMAIN" \
      >/dev/null 2>&1 &
    PIDS+=($!)
    TICKETS+=("$ticket")
    WORKTREES["$ticket"]="$WORKTREE"
    echo "$ticket	$WORKTREE	$!" >> "$ITER_DIR/dispatched.tsv"
  done <<< "$READY"

  log "iter=$iter dispatched=${#TICKETS[@]} pids=${PIDS[*]:-none}"
  bash "$PLUGIN_DIR/scripts/update-progress.sh" "$INBOX" "$STATE" > "$PROGRESS"

  # Wait for all workers.
  if [ "${#PIDS[@]}" -gt 0 ]; then
    wait "${PIDS[@]}" 2>/dev/null || true
  fi
  log "iter=$iter workers complete; entering verify phase"

  # Verify each result in serial (cheap; reads RESULT.md + reruns acceptance).
  for ticket in "${TICKETS[@]}"; do
    WORKTREE="${WORKTREES[$ticket]}"
    WORKER_BRANCH="worker/$ticket"
    set +e
    VERDICT=$(bash "$PLUGIN_DIR/scripts/dispatch-verifier.sh" \
      "$ticket" "$WORKTREE" "$PLUGIN_DIR" "$STATE" "$INBOX" "$DOMAIN" "$SCOPE")
    VRC=$?
    set -e
    REASON=""
    [ -f "$STATE/verifiers/$ticket/verdict-reason.txt" ] && \
      REASON=$(cat "$STATE/verifiers/$ticket/verdict-reason.txt")

    case "$VERDICT" in
      PASS)
        log "iter=$iter $ticket VERDICT=PASS; automerging"
        if bash "$PLUGIN_DIR/scripts/automerge.sh" "$ticket" "$WORKTREE" "$WORKER_BRANCH" "$ORCH_BRANCH" >>"$RUN_LOG" 2>&1; then
          bash "$PLUGIN_DIR/scripts/move-to-done.sh" "$INBOX" "$ticket" >>"$RUN_LOG"
        else
          log "iter=$iter $ticket automerge FAILED; moving to failed/"
          bash "$PLUGIN_DIR/scripts/move-to-failed.sh" "$INBOX" "$ticket" "automerge-failed" >>"$RUN_LOG"
          bash "$PLUGIN_DIR/scripts/check-dead-letter.sh" "$INBOX" "$SCOPE" "$ticket" >>"$RUN_LOG" || true
        fi
        ;;
      RETRY)
        log "iter=$iter $ticket VERDICT=RETRY reason=$REASON"
        bash "$PLUGIN_DIR/scripts/return-to-pending.sh" "$INBOX" "$ticket" "$REASON" >>"$RUN_LOG"
        ;;
      FAIL|*)
        log "iter=$iter $ticket VERDICT=FAIL reason=$REASON"
        bash "$PLUGIN_DIR/scripts/move-to-failed.sh" "$INBOX" "$ticket" "$REASON" >>"$RUN_LOG"
        bash "$PLUGIN_DIR/scripts/check-dead-letter.sh" "$INBOX" "$SCOPE" "$ticket" >>"$RUN_LOG" || true
        ;;
    esac

    bash "$PLUGIN_DIR/scripts/registry-refresh.sh" "$INBOX" >/dev/null
    bash "$PLUGIN_DIR/scripts/update-progress.sh" "$INBOX" "$STATE" > "$PROGRESS"
  done

  log "iter=$iter complete; loop continues"
done

# Final report.
if (( iter >= MAX_ITER )); then
  log "REACHED MAX ITERATIONS ($MAX_ITER) without drain"
fi

bash "$PLUGIN_DIR/scripts/update-progress.sh" "$INBOX" "$STATE" > "$PROGRESS"
bash "$PLUGIN_DIR/scripts/wave-report.sh" "$INBOX" "$STATE" "$WAVE_ID" "$SCOPE"

log "wave end: WAVE_ID=$WAVE_ID"
