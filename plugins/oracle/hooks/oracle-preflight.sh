#!/usr/bin/env bash
# Oracle preflight hook.
#
# Wired to UserPromptSubmit. Fires on every prompt the user submits.
#
# Decision tree:
#   1. Raw payload does not contain "oracle:"        -> exit 0 (microseconds)
#   2. Parsed cwd is not in the registered-projects  -> exit 0 silently
#      registry at ~/.claude/oracle/projects.yaml
#   3. Renderer --check reports clean                -> exit 0
#   4. Renderer --check reports drift                -> re-render in place
#   5. Anything errors                               -> exit 1, surface stderr
#
# The registry is opt-in: only projects where the user has run /oracle:init
# (or hand-added the path) get monitored. Other projects -- including ones
# that happen to have a .oracle/ directory from prior research output --
# are left untouched.
#
# Performance budget: under 1ms on the common no-op path (fast grep),
# under 100ms on the registered-but-clean path (two python invocations).

set -euo pipefail

PLUGIN_DIR="${CLAUDE_PLUGIN_ROOT:-$(cd -- "$(dirname -- "$0")/.." && pwd)}"
RENDERER="$PLUGIN_DIR/scripts/oracle-render.py"
REGISTRY="${ORACLE_PROJECT_REGISTRY:-$HOME/.claude/oracle/projects.yaml}"

payload="$(cat)"

# Fast path: no oracle command in the prompt at all.
case "$payload" in
  *oracle:*) ;;
  *) exit 0 ;;
esac

if ! command -v python3 >/dev/null 2>&1; then
  echo "[oracle] python3 not found; skipping preflight render check" >&2
  exit 0
fi

# Parse cwd from the hook payload. Fall back to PWD if the field is absent.
cwd="$(printf '%s' "$payload" | python3 -c '
import json, os, sys
try:
    d = json.load(sys.stdin)
except Exception:
    print(os.getcwd())
    sys.exit(0)
print(d.get("cwd") or os.getcwd())
')"

# Registry check. No registry file -> no registered projects -> always no-op.
if [[ ! -f "$REGISTRY" ]]; then
  exit 0
fi

registered="$(REGISTRY="$REGISTRY" CWD="$cwd" python3 -c '
import os, sys
try:
    import yaml
except Exception:
    # Without yaml we cannot safely parse; treat as "not registered".
    print("0"); sys.exit(0)
reg = os.environ["REGISTRY"]
cwd = os.path.realpath(os.environ["CWD"])
try:
    with open(reg) as f:
        data = yaml.safe_load(f) or {}
except Exception:
    print("0"); sys.exit(0)
projects = data.get("projects") or []
# Accept either ["/p1", "/p2"] or {"/p1": {...}, "/p2": {...}}
if isinstance(projects, dict):
    paths = list(projects.keys())
else:
    paths = [p if isinstance(p, str) else (p.get("path") if isinstance(p, dict) else None)
             for p in projects]
paths = [os.path.realpath(p) for p in paths if p]
print("1" if cwd in paths else "0")
')"

if [[ "$registered" != "1" ]]; then
  exit 0
fi

# Drift check. Renderer exits 0 if clean, 2 if re-render needed, 1 on hard error.
# Bash quirk: `$?` after `if cmd; then ...; fi` is the if-block's exit, not
# cmd's. Capture the renderer's exit explicitly via `||`.
rc=0
python3 "$RENDERER" --plugin-dir "$PLUGIN_DIR" --cwd "$cwd" --check >/dev/null 2>&1 || rc=$?

case "$rc" in
  0)
    exit 0
    ;;
  2)
    if python3 "$RENDERER" --plugin-dir "$PLUGIN_DIR" --cwd "$cwd" >&2; then
      echo "[oracle] re-rendered harness for $cwd" >&2
      exit 0
    else
      echo "[oracle] preflight render failed; aborting command" >&2
      exit 1
    fi
    ;;
  *)
    # Re-run --check without /dev/null so the user sees the actual error.
    python3 "$RENDERER" --plugin-dir "$PLUGIN_DIR" --cwd "$cwd" --check >&2 || true
    echo "[oracle] preflight check errored (rc=$rc); aborting command" >&2
    exit 1
    ;;
esac
