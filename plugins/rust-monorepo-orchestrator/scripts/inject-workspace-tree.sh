#!/usr/bin/env bash
# inject-workspace-tree.sh -- SessionStart hook: inject the worker's exact
# workspace state into the agent's initial system context so the agent does
# not waste tool turns exploring.
#
# Wired in by dispatch-worker.sh via per-session --settings JSON. Reads:
#   CLAUDE_TICKET_PATH  -- absolute path to the claimed ticket .md
#   CLAUDE_WORKTREE     -- absolute path to the worker's worktree
#   CLAUDE_SCOPE        -- absolute path to the parent repo (optional)
#
# Outputs a JSON object on stdout per the SessionStart hook protocol:
#   {
#     "hookSpecificOutput": {
#       "hookEventName": "SessionStart",
#       "additionalContext": "<tree + needed-files block>"
#     }
#   }
#
# The injected text tells the agent: this IS the repo state, do not explore,
# bulk-read the listed files in parallel before any other tool call.

set -euo pipefail

# Drain stdin (hook input JSON; we ignore it).
if [ ! -t 0 ]; then
  cat >/dev/null 2>&1 || true
fi

TICKET_PATH="${CLAUDE_TICKET_PATH:-}"
WORKTREE="${CLAUDE_WORKTREE:-$(pwd)}"
TICKET_ID="${CLAUDE_TICKET_ID:-?}"

# If we have no ticket context, emit an empty hook result.
if [ -z "$TICKET_PATH" ] || [ ! -f "$TICKET_PATH" ]; then
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":""}}\n'
  exit 0
fi

# Find tool: prefer GNU find. macOS find supports the same flags here.
TREE_DEPTH="${WORKSPACE_TREE_DEPTH:-5}"

# Exclusion patterns. Add more via WORKSPACE_TREE_EXTRA_EXCLUDES env (space-separated).
EXCLUDES=(
  ".git"
  "node_modules"
  "target"
  ".cargo"
  ".cargo-cache"
  "dist"
  "build"
  "out"
  "__pycache__"
  ".venv"
  "venv"
  ".pytest_cache"
  ".ruff_cache"
  ".mypy_cache"
  ".next"
  ".nuxt"
  ".svelte-kit"
  ".turbo"
  ".moon/cache"
  "coverage"
  ".coverage"
  ".nyc_output"
  ".idea"
  ".vscode"
  ".DS_Store"
  ".claude"
  ".refactor"
  "vendor"
  "tmp"
  ".tmp"
  "Cargo.lock"
  "package-lock.json"
  "pnpm-lock.yaml"
  "yarn.lock"
  "poetry.lock"
  "uv.lock"
)
if [ -n "${WORKSPACE_TREE_EXTRA_EXCLUDES:-}" ]; then
  read -r -a EXTRA <<<"${WORKSPACE_TREE_EXTRA_EXCLUDES}"
  EXCLUDES+=("${EXTRA[@]}")
fi

# Build the find prune expression.
PRUNE_ARGS=()
for e in "${EXCLUDES[@]}"; do
  PRUNE_ARGS+=(-o -name "$e")
done
# Drop the leading -o
unset 'PRUNE_ARGS[0]'

# Walk the worktree.
TREE_TMP=$(mktemp)
(
  cd "$WORKTREE"
  find . -maxdepth "$TREE_DEPTH" \( "${PRUNE_ARGS[@]}" \) -prune -o -print 2>/dev/null \
    | sed -e 's|^\./||' \
    | grep -v '^\.$' \
    | sort \
    | head -2000 \
    > "$TREE_TMP"
) || true

# Count.
TOTAL_ENTRIES=$(wc -l < "$TREE_TMP" | tr -d ' ')

# Extract NEEDED_FILES from ticket frontmatter (allowed_paths) and body
# (inputs.context entries). Use python for robust YAML-ish parsing.
NEEDED_TMP=$(mktemp)
python3 - "$TICKET_PATH" "$WORKTREE" > "$NEEDED_TMP" <<'PY'
import os, re, sys
ticket_path = sys.argv[1]
worktree = sys.argv[2]
text = open(ticket_path).read()

# Frontmatter
allowed = []
fm = ""
if text.startswith("---"):
    end = text.find("\n---", 3)
    if end > 0:
        fm = text[3:end]
        in_list = False
        for line in fm.splitlines():
            s = line.strip()
            if s.startswith("allowed_paths:"):
                v = s[len("allowed_paths:"):].strip()
                if v.startswith("[") and v.endswith("]"):
                    for x in v[1:-1].split(","):
                        x = x.strip().strip('"').strip("'")
                        if x: allowed.append(x)
                    break
                elif v in ("", "|"):
                    in_list = True; continue
                else:
                    allowed.append(v.strip('"').strip("'")); break
            elif in_list:
                m = re.match(r"^\s+-\s+(.*)$", line)
                if m:
                    allowed.append(m.group(1).strip().strip('"').strip("'"))
                elif line.strip() and not line.startswith("  "):
                    break

# Inputs.context paths in the body
context_paths = []
body = text.split("\n---", 2)[-1] if text.startswith("---") else text
in_context = False
for line in body.splitlines():
    if line.strip().startswith("## context"):
        in_context = True; continue
    if line.strip().startswith("## ") and in_context:
        break
    if in_context:
        m = re.match(r"^\s*-\s*path:\s*(.+?)\s*$", line)
        if m:
            context_paths.append(m.group(1).strip())

def expand(pat):
    """Expand a path pattern relative to worktree to actual existing files."""
    full = pat
    if not os.path.isabs(full):
        full = os.path.join(worktree, full)
    results = []
    # Strip glob suffixes
    if "*" in full or "?" in full or "[" in full:
        import glob
        results.extend(glob.glob(full, recursive=True))
    else:
        if os.path.isfile(full):
            results.append(full)
        elif os.path.isdir(full):
            # List files in directory (depth 2)
            for root, dirs, files in os.walk(full):
                # Prune common bloat
                dirs[:] = [d for d in dirs if d not in {".git","node_modules","target",".venv","venv","__pycache__","dist","build"}]
                for f in files:
                    results.append(os.path.join(root, f))
                depth = root[len(full):].count(os.sep)
                if depth >= 2:
                    dirs[:] = []
    return results

needed = set()
for p in allowed + context_paths:
    if not p or p.startswith("$"):
        continue
    for r in expand(p):
        if os.path.isfile(r):
            needed.add(r)

for f in sorted(needed)[:80]:  # cap at 80 to avoid blasting context
    print(f)
PY

NEEDED_COUNT=$(wc -l < "$NEEDED_TMP" | tr -d ' ')

# Build the additionalContext text.
CONTEXT_FILE=$(mktemp)
{
  echo "=== WORKSPACE STATE (injected by SessionStart hook) ==="
  echo ""
  echo "This is the EXACT state of your worktree for ticket $TICKET_ID."
  echo "Do not use Glob / find / ls to discover the layout -- it is captured below."
  echo "Bulk-read the files in NEEDED_FILES in a SINGLE parallel tool call (one Read tool"
  echo "call per file, all in the same response) before doing any other work."
  echo ""
  echo "## repo tree ($TOTAL_ENTRIES entries, depth $TREE_DEPTH, bloat dirs pruned)"
  echo ""
  echo "worktree: $WORKTREE"
  echo ""
  echo '```'
  cat "$TREE_TMP"
  echo '```'
  echo ""
  echo "## NEEDED_FILES ($NEEDED_COUNT files derived from ticket allowed_paths and inputs.context)"
  echo ""
  echo "Read these now, in parallel, in your next response:"
  echo ""
  if [ "$NEEDED_COUNT" -gt 0 ]; then
    sed 's/^/- /' "$NEEDED_TMP"
  else
    echo "(none derivable from ticket; consult the ticket file directly)"
  fi
  echo ""
  echo "## ticket"
  echo ""
  echo "claimed ticket: $TICKET_PATH"
  echo ""
  echo "=== END WORKSPACE STATE ==="
} > "$CONTEXT_FILE"

# Emit the hook output. Use python to JSON-encode the context safely.
python3 - "$CONTEXT_FILE" <<'PY'
import json, sys
content = open(sys.argv[1]).read()
out = {
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": content
  }
}
print(json.dumps(out))
PY

rm -f "$TREE_TMP" "$NEEDED_TMP" "$CONTEXT_FILE"
