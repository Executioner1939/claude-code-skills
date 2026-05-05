#!/usr/bin/env bash
# /Users/skunkworks/.claude/codify/codify-stop.sh
#
# Stop hook for the /codify slash command. Reads stdin JSON from Claude Code,
# self-gates on stop_hook_active and a session-keyed sentinel file, then spawns
# wave-1 (envelope_proposal) report runs that exec-chain into wave-2 once they
# complete. The hook returns immediately; spawned children run detached.

set -e

INPUT=$(cat)

# Loop guard: if Claude is being kept alive by another Stop hook, do not act.
if [ "$(printf '%s' "$INPUT" | jq -r '.stop_hook_active // false')" = "true" ]; then
  exit 0
fi

SESSION_ID=$(printf '%s' "$INPUT" | jq -r '.session_id // empty')
[ -n "$SESSION_ID" ] || exit 0

SENTINEL="$HOME/.claude/codify/.codify-active-${SESSION_ID}"
test -f "$SENTINEL" || exit 0  # /codify did not run this turn

# Sentinel format: 3 lines: inbox path / timestamp / runs dir
INBOX=$(sed -n '1p' "$SENTINEL")
TIMESTAMP=$(sed -n '2p' "$SENTINEL")
RUNS_DIR=$(sed -n '3p' "$SENTINEL")

if ! test -d "$INBOX"; then
  rm -f "$SENTINEL"
  exit 0
fi

mkdir -p "$RUNS_DIR"
DISPATCH_LOG="$RUNS_DIR/_dispatch.log"
REPO_ROOT=/Users/skunkworks/Documents/Work/Personal/claude-code-skills

# Clear sentinel BEFORE spawning so subsequent Stop fires don't re-dispatch.
rm -f "$SENTINEL"

# Catalog reports by wave prefix.
WAVE1=()
while IFS= read -r f; do [ -n "$f" ] && WAVE1+=("$f"); done < <(ls "$INBOX"/01-*.md 2>/dev/null || true)
WAVE2=()
while IFS= read -r f; do [ -n "$f" ] && WAVE2+=("$f"); done < <(ls "$INBOX"/[2-9][0-9]-*.md 2>/dev/null || true)

{
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] codify-stop.sh fired"
  echo "  session_id=$SESSION_ID"
  echo "  inbox=$INBOX"
  echo "  runs_dir=$RUNS_DIR"
  echo "  wave1 reports: ${#WAVE1[@]}"
  echo "  wave2 reports: ${#WAVE2[@]}"
} >> "$DISPATCH_LOG"

# Auto-generate the wave-2 dispatcher script. It is exec-chained from the lead
# wave-1 process, OR invoked directly if there is no wave-1.
WAVE2_SCRIPT="$RUNS_DIR/_wave2.sh"
{
  echo '#!/usr/bin/env bash'
  echo 'set +e'
  echo "DISPATCH_LOG=\"$DISPATCH_LOG\""
  echo 'echo "[$(date "+%Y-%m-%d %H:%M:%S")] wave-2 dispatcher starting" >> "$DISPATCH_LOG"'
  for r in "${WAVE2[@]}"; do
    SLUG=$(basename "$r" .md)
    LOG="$RUNS_DIR/$SLUG.log"
    cat <<EOF
echo "[\$(date '+%Y-%m-%d %H:%M:%S')] wave-2 spawn: $SLUG" >> "\$DISPATCH_LOG"
nohup setsid bash -c 'cd "$REPO_ROOT" && claude --bare -p --permission-mode bypassPermissions --no-session-persistence --max-turns 30 --output-format json "\$(cat "$r")"' </dev/null >> "$LOG" 2>&1 &
disown
EOF
  done
  echo 'echo "[$(date "+%Y-%m-%d %H:%M:%S")] wave-2 dispatcher exit (all spawned, detached)" >> "$DISPATCH_LOG"'
} > "$WAVE2_SCRIPT"
chmod +x "$WAVE2_SCRIPT"

# Wave 1: spawn one detached process per envelope-proposal report. The lead
# (first) wave-1 process exec-chains to the wave-2 dispatcher on exit.
# Spec expects 0 or 1 wave-1 reports; multiple is handled by running the
# extras in parallel without chaining.
if [ "${#WAVE1[@]}" -gt 0 ]; then
  for i in "${!WAVE1[@]}"; do
    r="${WAVE1[$i]}"
    SLUG=$(basename "$r" .md)
    LOG="$RUNS_DIR/$SLUG.log"
    if [ "$i" = "0" ]; then
      WAVE1_LEAD_SCRIPT="$RUNS_DIR/_wave1-lead.sh"
      cat > "$WAVE1_LEAD_SCRIPT" <<EOF
#!/usr/bin/env bash
cd "$REPO_ROOT"
claude --bare -p \\
  --permission-mode bypassPermissions \\
  --no-session-persistence \\
  --max-turns 30 \\
  --output-format json \\
  "\$(cat "$r")"
exec bash "$WAVE2_SCRIPT"
EOF
      chmod +x "$WAVE1_LEAD_SCRIPT"
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] wave-1 lead spawn: $SLUG (chains to wave-2)" >> "$DISPATCH_LOG"
      nohup setsid bash "$WAVE1_LEAD_SCRIPT" </dev/null >> "$LOG" 2>&1 &
      disown
    else
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] wave-1 extra spawn: $SLUG" >> "$DISPATCH_LOG"
      nohup setsid bash -c "cd \"$REPO_ROOT\" && claude --bare -p --permission-mode bypassPermissions --no-session-persistence --max-turns 30 --output-format json \"\$(cat \"$r\")\"" </dev/null >> "$LOG" 2>&1 &
      disown
    fi
  done
else
  # No wave-1; run wave-2 directly.
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] no wave-1; dispatching wave-2 directly" >> "$DISPATCH_LOG"
  nohup setsid bash "$WAVE2_SCRIPT" </dev/null >> "$DISPATCH_LOG" 2>&1 &
  disown
fi

exit 0
