#!/usr/bin/env bash
# monitor-wave.sh -- live TUI for an in-flight Ralph wave.
#
# Usage:
#   monitor-wave.sh <scope> [<wave-id-or-'latest'>] [<refresh-seconds=2>]
#
# Reads <scope>/.refactor/state/<wave_id>/progress.json + per-worker meta.json
# and renders a refreshing dashboard. Detects "stuck" workers (no log activity
# for STUCK_THRESHOLD seconds, default 180).
#
# Exits when the wave's run.log contains "wave end:" (drained or max-iter)
# or when the user presses Ctrl+C.

set -euo pipefail

SCOPE="${1:?scope required}"
WAVE_ARG="${2:-latest}"
REFRESH_SEC="${3:-2}"
STUCK_THRESHOLD="${STUCK_THRESHOLD:-180}"   # seconds

STATE_BASE="$SCOPE/.refactor/state"
[ -d "$STATE_BASE" ] || { echo "ERROR: no state dir at $STATE_BASE; is a wave running?" >&2; exit 1; }

resolve_wave() {
  if [ "$WAVE_ARG" = "latest" ]; then
    if [ -L "$STATE_BASE/latest" ]; then
      readlink "$STATE_BASE/latest"
    else
      ls -1t "$STATE_BASE" 2>/dev/null | grep -E '^wave-' | head -1
    fi
  else
    echo "$WAVE_ARG"
  fi
}

WAVE_ID=$(resolve_wave)
[ -n "$WAVE_ID" ] || { echo "ERROR: could not resolve wave id" >&2; exit 1; }
STATE="$STATE_BASE/$WAVE_ID"
[ -d "$STATE" ] || { echo "ERROR: wave state dir $STATE missing" >&2; exit 1; }

PROGRESS="$STATE/progress.json"
RUN_LOG="$STATE/run.log"

# Terminal helpers
if command -v tput >/dev/null 2>&1; then
  COLS=$(tput cols 2>/dev/null || echo 80)
  BOLD=$(tput bold 2>/dev/null || echo "")
  DIM=$(tput dim 2>/dev/null || echo "")
  RESET=$(tput sgr0 2>/dev/null || echo "")
  RED=$(tput setaf 1 2>/dev/null || echo "")
  GREEN=$(tput setaf 2 2>/dev/null || echo "")
  YELLOW=$(tput setaf 3 2>/dev/null || echo "")
  CYAN=$(tput setaf 6 2>/dev/null || echo "")
  CLEAR=$(tput clear 2>/dev/null || echo "")
else
  COLS=80
  BOLD=""; DIM=""; RESET=""; RED=""; GREEN=""; YELLOW=""; CYAN=""; CLEAR=""
fi

bar() {
  local width="$1"
  printf '%*s' "$width" '' | tr ' ' '='
}

trap 'echo; echo "monitor exiting."; exit 0' INT TERM

now_epoch() { date +%s; }

iso_to_epoch() {
  # Best-effort ISO 8601 -> epoch. Falls back to current time on parse failure.
  local s="$1"
  if [ -z "$s" ]; then echo 0; return; fi
  if date -j -u -f "%Y-%m-%dT%H:%M:%SZ" "$s" +%s 2>/dev/null; then return; fi
  date -d "$s" +%s 2>/dev/null || echo 0
}

render() {
  local now=$(now_epoch)

  # Parse progress.json if present.
  local pending=0 claimed=0 done_count=0 failed=0 dlq=0 active=0
  if [ -s "$PROGRESS" ] && command -v jq >/dev/null 2>&1; then
    pending=$(jq -r '.inbox.pending // 0' "$PROGRESS" 2>/dev/null || echo 0)
    claimed=$(jq -r '.inbox.claimed // 0' "$PROGRESS" 2>/dev/null || echo 0)
    done_count=$(jq -r '.inbox.done // 0' "$PROGRESS" 2>/dev/null || echo 0)
    failed=$(jq -r '.inbox.failed // 0' "$PROGRESS" 2>/dev/null || echo 0)
    dlq=$(jq -r '.inbox.dead_letter // 0' "$PROGRESS" 2>/dev/null || echo 0)
    active=$(jq -r '.active_workers // 0' "$PROGRESS" 2>/dev/null || echo 0)
  fi

  local total=$((pending + claimed + done_count + failed + dlq))

  # Latest iteration number from run.log.
  local iter="?"
  if [ -s "$RUN_LOG" ]; then
    iter=$(grep -oE 'iter=[0-9]+' "$RUN_LOG" | tail -1 | sed 's/iter=//')
    iter="${iter:-?}"
  fi

  printf '%s' "$CLEAR"
  printf '%s%s%s\n' "$BOLD" "Ralph wave monitor -- $WAVE_ID" "$RESET"
  printf '%s\n' "$(bar 60)"
  printf 'iter: %s    state_dir: %s%s%s\n' "$iter" "$DIM" "$STATE" "$RESET"
  echo
  printf '%spending%s %3d   %sclaimed%s %3d   %sdone%s %s%3d%s   %sfailed%s %s%3d%s   %sdead-letter%s %s%3d%s   active_workers %s%d%s\n' \
    "$CYAN" "$RESET" "$pending" \
    "$YELLOW" "$RESET" "$claimed" \
    "$GREEN" "$RESET" "$BOLD" "$done_count" "$RESET" \
    "$RED" "$RESET" "$BOLD" "$failed" "$RESET" \
    "$RED" "$RESET" "$BOLD" "$dlq" "$RESET" \
    "$BOLD" "$active" "$RESET"
  echo

  # Per-worker block: list in-flight workers from state/workers/*/meta.json.
  printf '%s%-12s %-9s %-50s %s%s\n' "$BOLD" "TICKET" "DURATION" "STATUS" "" "$RESET"
  printf '%s\n' "$(bar 80)"

  if [ -d "$STATE/workers" ]; then
    for d in "$STATE/workers"/*/; do
      [ -d "$d" ] || continue
      META="$d/meta.json"
      [ -f "$META" ] || continue
      local tid=$(jq -r '.ticket_id' "$META" 2>/dev/null || echo "?")
      local start_ts=$(jq -r '.start_ts' "$META" 2>/dev/null || echo "")
      local end_ts=$(jq -r '.end_ts // empty' "$META" 2>/dev/null || echo "")
      local rc=$(jq -r '.exit_code // empty' "$META" 2>/dev/null || echo "")
      local start_epoch=$(iso_to_epoch "$start_ts")
      local end_epoch=$(iso_to_epoch "$end_ts")
      local dur
      if [ -n "$end_ts" ]; then
        dur=$((end_epoch - start_epoch))
        if [ -z "$rc" ] || [ "$rc" = "0" ]; then
          printf '%s%-12s %s%5ds done%s  %sexit=%s%s\n' "$DIM" "$tid" "$RESET" "$dur" "$DIM" "" "${rc:-?}" "$RESET"
        else
          printf '%s%-12s %s%5ds done%s  %sexit=%s%s\n' "$RED" "$tid" "$RESET" "$dur" "$RED" "" "$rc" "$RESET"
        fi
      else
        dur=$((now - start_epoch))
        # Stuck detection: tail log activity
        local log_file="$d/log.jsonl"
        local last_activity=$now
        if [ -f "$log_file" ]; then
          if [ "$(uname)" = "Darwin" ]; then
            last_activity=$(stat -f %m "$log_file" 2>/dev/null || echo $now)
          else
            last_activity=$(stat -c %Y "$log_file" 2>/dev/null || echo $now)
          fi
        fi
        local silence=$((now - last_activity))
        if [ "$silence" -gt "$STUCK_THRESHOLD" ]; then
          printf '%s%-12s %s%5ds %sSTUCK%s  no log activity for %ds\n' \
            "$YELLOW" "$tid" "$RESET" "$dur" "$YELLOW" "$RESET" "$silence"
        else
          printf '%s%-12s %s%5ds %srunning%s\n' "$CYAN" "$tid" "$RESET" "$dur" "$CYAN" "$RESET"
        fi
      fi
    done
  fi
  echo

  # Tail of run.log
  printf '%srecent log:%s\n' "$BOLD" "$RESET"
  printf '%s\n' "$(bar 60)"
  if [ -s "$RUN_LOG" ]; then
    tail -8 "$RUN_LOG" | sed "s/^/$DIM/; s/$/$RESET/"
  fi
  echo
  printf '%s(refreshing every %ss; Ctrl+C to exit)%s\n' "$DIM" "$REFRESH_SEC" "$RESET"
}

while true; do
  render
  # Stop if wave is over.
  if [ -s "$RUN_LOG" ] && grep -q 'wave end:' "$RUN_LOG"; then
    echo
    printf '%swave terminated.%s See REPORT.md.\n' "$BOLD" "$RESET"
    break
  fi
  sleep "$REFRESH_SEC"
done
