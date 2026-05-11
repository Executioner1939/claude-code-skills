---
description: Run the implementation wave with the Ralph loop. No nested-subagent orchestrator; the bash loop (scripts/run-wave-ralph.sh) drives dispatch, claim, wait, verify, automerge, and triage. Each ticket runs as an OS-level `claude -p` process in its own worktree, so progress survives parent crashes, parallelism is real, and the monitor (scripts/monitor-wave.sh) can tail live. Context-aware: with no args, runs the wave for the inbox matching the current cwd's service. Use this instead of /run-wave on plugins or environments where nested Agent dispatch is restricted. Invoke as `/rust-monorepo-orchestrator:run-wave-ralph [<service-or-aggregate>] [--wave-width=<n>] [--max-iterations=<n>] [--no-monitor]`.
argument-hint: "[<service-or-aggregate>] [--wave-width=<n>] [--max-iterations=<n>] [--no-monitor]"
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(mkdir:*)
  - Bash(date:*)
  - Bash(pwd)
  - Bash(test:*)
  - Bash(echo:*)
  - Bash(awk:*)
  - Bash(sed:*)
  - Bash(grep:*)
  - Bash(cut:*)
  - Bash(jq:*)
  - Bash(realpath:*)
  - Bash(cat:*)
  - Bash(find:*)
  - Bash(ls:*)
  - Bash(git:*)
  - Bash(bash:*)
  - Bash(nohup:*)
  - Write
model: claude-opus-4-7
---

# /rust-monorepo-orchestrator:run-wave-ralph

The Ralph-loop wave runner. Drives the implementation wave for one domain via a bash outer loop instead of a long-lived orchestrator subagent. Each iteration computes the ready set (deps satisfied + path-locks clear), spawns up to `wave_width` `claude -p` workers as separate OS processes (each in its own isolated worktree), waits for them, runs a verifier per result, and routes PASS / RETRY / FAIL through the existing automerge / return-to-pending / move-to-failed / dead-letter pipeline. State lives entirely on disk (`.refactor/state/<wave-id>/`), so a parent-process crash doesn't lose progress.

Use this when:
- The nested-Agent dispatch of `/run-wave` fails (plugin subagent runtime stripping the `Agent` tool).
- You want live observability via `scripts/monitor-wave.sh`.
- You want each worker's `claude -p` log persisted as `stream-json` for later forensics.

## Step 0 -- Resolve arguments and pre-flight

```!
set -e
ARGS=$(printf '%s' "$ARGUMENTS")

TARGET=$(printf '%s' "$ARGS" | awk '{ for (i=1;i<=NF;i++) if ($i !~ /^--/) { print $i; exit } }')

# Locate plugin dir for discover-workspace.sh.
PLUGIN_DIR_DISC="${CLAUDE_PLUGIN_DIR:-}"
if [ -z "$PLUGIN_DIR_DISC" ] || [ ! -d "$PLUGIN_DIR_DISC/scripts" ]; then
  CACHE="$HOME/.claude/plugins/cache/skunkworks/rust-monorepo-orchestrator"
  [ -d "$CACHE" ] && PLUGIN_DIR_DISC=$(ls -1d "$CACHE"/*/ 2>/dev/null | tail -1 | sed 's:/$::')
fi
test -d "$PLUGIN_DIR_DISC/scripts" || { echo "ABORT: cannot locate plugin dir."; exit 0; }

DISCOVERY=$(bash "$PLUGIN_DIR_DISC/scripts/discover-workspace.sh" "$(pwd)" 2>/dev/null || true)
test -n "$DISCOVERY" || { echo "ABORT: workspace discovery failed."; exit 0; }

SCOPE=$(printf '%s' "$DISCOVERY" | jq -r '.workspace_root')
CURRENT_SVC=$(printf '%s' "$DISCOVERY" | jq -r '.current.service // empty')

# Resolve DOMAIN (the inbox key) from TARGET or current context.
DOMAIN=""
if [ -n "$TARGET" ]; then
  case "$TARGET" in
    */*) DOMAIN="${TARGET#*/}";;
    *) DOMAIN="$TARGET";;
  esac
elif [ -n "$CURRENT_SVC" ]; then
  DOMAIN="$CURRENT_SVC"
fi
test -n "$DOMAIN" || { echo "ABORT: no target supplied and cwd is not inside a service. Usage: /run-wave-ralph <service-or-aggregate>"; exit 0; }

WAVE_WIDTH=$(printf '%s' "$ARGS" | grep -oE -- '--wave-width=[0-9]+' | cut -d= -f2 || true)
[ -z "${WAVE_WIDTH:-}" ] && WAVE_WIDTH=5

MAX_ITERATIONS=$(printf '%s' "$ARGS" | grep -oE -- '--max-iterations=[0-9]+' | cut -d= -f2 || true)
[ -z "${MAX_ITERATIONS:-}" ] && MAX_ITERATIONS=50

NO_MONITOR=0
printf '%s' "$ARGS" | grep -q -- '--no-monitor' && NO_MONITOR=1

# Pre-flight.
DOMAIN_DIR="$SCOPE/.refactor/domains/$DOMAIN"
INBOX_DIR="$SCOPE/.refactor/inbox/$DOMAIN"
PLAN_MD="$DOMAIN_DIR/PLAN.md"
TESTS_JSON="$DOMAIN_DIR/tests.json"
SGCONFIG="$SCOPE/sgconfig.yml"

test -f "$PLAN_MD"        || { echo "ABORT: $PLAN_MD missing. Run /rust-monorepo-orchestrator:plan-refactor $DOMAIN first."; exit 0; }
test -f "$TESTS_JSON"     || { echo "ABORT: $TESTS_JSON missing."; exit 0; }
test -d "$INBOX_DIR/pending" || { echo "ABORT: $INBOX_DIR/pending missing."; exit 0; }
test -f "$SGCONFIG"       || { echo "ABORT: $SGCONFIG missing. Run /rust-monorepo-orchestrator:audit-domain $DOMAIN first."; exit 0; }

# Ensure inbox state subdirs exist.
mkdir -p "$INBOX_DIR/claimed" "$INBOX_DIR/done" "$INBOX_DIR/failed" "$SCOPE/.refactor/dead-letter" "$SCOPE/.refactor/state" "$SCOPE/.refactor/worktrees"

# Pending count -- refuse if zero.
PENDING_COUNT=$(find "$INBOX_DIR/pending" -maxdepth 1 -name 'T-*.md' 2>/dev/null | wc -l | tr -d ' ')
[ "$PENDING_COUNT" -gt 0 ] || { echo "ABORT: $INBOX_DIR/pending has 0 tickets. Run /rust-monorepo-orchestrator:plan-refactor $DOMAIN first."; exit 0; }

# Resolve orchestrator branch.
ORCH_BRANCH=$(git -C "$SCOPE" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
[ -n "$ORCH_BRANCH" ] || { echo "ABORT: $SCOPE is not a git repo (or detached HEAD)"; exit 0; }
if [ "$ORCH_BRANCH" = "main" ]; then
  echo "WARNING: orchestrator branch is 'main'. Automerges will land directly on main."
  echo "         Strongly recommended: switch to a feature branch first (git checkout -b refactor/$DOMAIN)."
fi

# Locate the plugin dir. Prefer the env var CLAUDE_PLUGIN_DIR; fall back to the cached install.
PLUGIN_DIR="${CLAUDE_PLUGIN_DIR:-}"
if [ -z "$PLUGIN_DIR" ] || [ ! -d "$PLUGIN_DIR/scripts" ]; then
  CACHE_CANDIDATE="$HOME/.claude/plugins/cache/skunkworks/rust-monorepo-orchestrator"
  if [ -d "$CACHE_CANDIDATE" ]; then
    PLUGIN_DIR=$(ls -1d "$CACHE_CANDIDATE"/*/ 2>/dev/null | tail -1)
    PLUGIN_DIR="${PLUGIN_DIR%/}"
  fi
fi
test -d "$PLUGIN_DIR/scripts" || { echo "ABORT: cannot locate plugin dir; set CLAUDE_PLUGIN_DIR explicitly."; exit 0; }

# Sanity: claude CLI present.
command -v claude >/dev/null 2>&1 || { echo "ABORT: 'claude' CLI not on PATH; the Ralph loop spawns claude -p per worker."; exit 0; }

TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)
RUN_ID="run-wave-ralph-${DOMAIN}-${TIMESTAMP}"
WAVE_LOG_DIR="$SCOPE/.refactor/handoffs/$RUN_ID"
mkdir -p "$WAVE_LOG_DIR"

cat <<EOF
BOOTSTRAP_OK=1
DOMAIN=$DOMAIN
SCOPE=$SCOPE
WAVE_WIDTH=$WAVE_WIDTH
MAX_ITERATIONS=$MAX_ITERATIONS
INBOX_DIR=$INBOX_DIR
PLAN_MD=$PLAN_MD
TESTS_JSON=$TESTS_JSON
SGCONFIG=$SGCONFIG
ORCH_BRANCH=$ORCH_BRANCH
PENDING_COUNT=$PENDING_COUNT
PLUGIN_DIR=$PLUGIN_DIR
WAVE_LOG_DIR=$WAVE_LOG_DIR
RUN_ID=$RUN_ID
TIMESTAMP=$TIMESTAMP
NO_MONITOR=$NO_MONITOR
EOF
```

If the bootstrap output begins with `ABORT:`, halt and print verbatim.

If the warning about `main` appears, surface it to chat and ask the user to confirm before proceeding.

## Step 1 -- Launch the Ralph loop

Spawn `scripts/run-wave-ralph.sh` in the background. State and logs live under `$SCOPE/.refactor/state/wave-<DOMAIN>-<timestamp>/`. The `latest` symlink at `$SCOPE/.refactor/state/latest` points at the active wave so the monitor can find it without knowing the timestamp.

```!
set -e
nohup bash "$PLUGIN_DIR/scripts/run-wave-ralph.sh" \
  "$DOMAIN" "$SCOPE" "$WAVE_WIDTH" "$MAX_ITERATIONS" "$PLUGIN_DIR" \
  > "$WAVE_LOG_DIR/run-wave.out" 2> "$WAVE_LOG_DIR/run-wave.err" &
RALPH_PID=$!
echo "$RALPH_PID" > "$WAVE_LOG_DIR/ralph.pid"
sleep 1
test -d "$SCOPE/.refactor/state/latest" 2>/dev/null && WAVE_ID=$(readlink "$SCOPE/.refactor/state/latest") || WAVE_ID="(starting...)"
echo "RALPH_PID=$RALPH_PID"
echo "WAVE_ID=$WAVE_ID"
echo "WAVE_STATE_DIR=$SCOPE/.refactor/state/$WAVE_ID"
echo "RUN_LOG=$SCOPE/.refactor/state/$WAVE_ID/run.log"
```

## Step 2 -- Surface monitor instructions

Print to chat:

```
==========================================
  /rust-monorepo-orchestrator:run-wave-ralph started
==========================================
  domain:           <DOMAIN>
  scope:            <SCOPE>
  orchestrator:     <ORCH_BRANCH>
  wave_width:       <WAVE_WIDTH>
  max_iterations:   <MAX_ITERATIONS>
  pending tickets:  <PENDING_COUNT>

  ralph PID:        <RALPH_PID>     (background)
  wave_id:          <WAVE_ID>
  state_dir:        <SCOPE>/.refactor/state/<WAVE_ID>/
  run_log:          <SCOPE>/.refactor/state/<WAVE_ID>/run.log

  monitor (open in a second terminal):
    bash <PLUGIN_DIR>/scripts/monitor-wave.sh <SCOPE> latest

  tail run log:
    tail -f <SCOPE>/.refactor/state/<WAVE_ID>/run.log

  stop the wave:
    kill <RALPH_PID>     (in-flight workers may still complete)

  final report when done:
    <SCOPE>/.refactor/state/<WAVE_ID>/REPORT.md
==========================================
```

If `NO_MONITOR=0` (the default), the harness should ALSO offer to launch the monitor in the foreground for the user. The monitor is a long-running TUI and is invoked via `Bash` (background false) — but since this is a slash command, only the user can decide whether to spawn it. Surface the exact invocation and let them choose.

## Whole-workflow constraints

- The Ralph loop runs as a backgrounded bash process under `nohup`. It survives shell exit.
- Each worker is a separate `claude -p` invocation. No nested `Agent` dispatch.
- Workers run with `--bare`, `--plugin-dir <plugin>`, `--agent rust-monorepo-orchestrator:ticket-implementer`, `--permission-mode acceptEdits`, `--output-format stream-json`.
- Verifiers run with `--agent rust-monorepo-orchestrator:verifier`, `--permission-mode plan` (read-only).
- Final wave summary is written to `<state_dir>/REPORT.md` and printed to chat via `wave-report.sh`.
- All state movements (claim, return-to-pending, move-to-done, move-to-failed, dead-letter) go through the existing scripts.

## Acceptance for the whole run

- `run-wave-ralph.sh` exits with status 0 (drained) or surfaces `REACHED MAX ITERATIONS`.
- Every PASS ticket is in `done/` and merged into the orchestrator branch.
- Every FAIL ticket is in `failed/` (eligible for retry) or `dead-letter/` (exhausted).
- `_registry.md` and `progress.json` reflect final state.
- `<state_dir>/REPORT.md` exists.
