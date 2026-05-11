#!/usr/bin/env bash
# verify-deterministic.sh -- bash-only verifier for mechanical tickets.
#
# Used when a ticket's frontmatter sets `verifier: deterministic`. Skips the
# LLM verifier entirely. The LLM verifier remains the default for tickets
# with judgment in their acceptance ("does the new structure make sense?")
# -- this script is for tickets where acceptance is purely commands and
# ast-grep rules.
#
# Usage: verify-deterministic.sh <ticket-id> <worktree> <inbox-dir> <domain> <scope> <state-dir>
#
# Output (matches the LLM verifier's contract):
#   - prints exactly one VERDICT line on stdout: PASS, FAIL, or RETRY
#   - writes verdict-reason to <state-dir>/verifiers/<ticket-id>/verdict-reason.txt
#   - writes a full report to <state-dir>/verifiers/<ticket-id>/report.md

set -euo pipefail

TICKET_ID="${1:?ticket id required}"
WORKTREE="${2:?worktree required}"
INBOX_DIR="${3:?inbox dir required}"
DOMAIN="${4:?domain required}"
SCOPE="${5:?scope required}"
STATE_DIR="${6:?state dir required}"

TICKET_PATH="$INBOX_DIR/claimed/$TICKET_ID.md"
SGCONFIG="$SCOPE/sgconfig.yml"
TESTS_JSON="$SCOPE/.refactor/domains/$DOMAIN/tests.json"

VERIFIER_STATE="$STATE_DIR/verifiers/$TICKET_ID"
mkdir -p "$VERIFIER_STATE"
REPORT="$VERIFIER_STATE/report.md"
REASON_FILE="$VERIFIER_STATE/verdict-reason.txt"
: > "$REPORT"
: > "$REASON_FILE"

log() {
  printf '%s\n' "$*" >> "$REPORT"
}

verdict() {
  local v="$1" reason="$2"
  echo "$reason" > "$REASON_FILE"
  log ""
  log "VERDICT: $v"
  log "REASON:  $reason"
  echo "$v"
  exit 0
}

log "# Deterministic verifier report -- $TICKET_ID"
log ""
log "ticket_path: $TICKET_PATH"
log "worktree:    $WORKTREE"
log "ts:          $(date -u +%Y-%m-%dT%H:%M:%SZ)"
log ""

[ -f "$TICKET_PATH" ] || verdict FAIL "missing-ticket-file"

# 1. Find the RESULT.md.
RESULT_PATH=$(find "$WORKTREE" -maxdepth 2 -name "${TICKET_ID}-RESULT.md" -type f 2>/dev/null | head -1)
if [ -z "$RESULT_PATH" ] || [ ! -f "$RESULT_PATH" ]; then
  verdict FAIL "missing-result-md"
fi
log "result_path: $RESULT_PATH"

# 2. Check for BLOCKED status in SUMMARY.
SUMMARY_LINE=$(awk '/^## SUMMARY/{flag=1; next} /^## /{flag=0} flag && NF{print; exit}' "$RESULT_PATH" || true)
if printf '%s' "$SUMMARY_LINE" | grep -qi 'BLOCKED'; then
  verdict FAIL "worker-blocked: $SUMMARY_LINE"
fi

# 3. Worktree must be clean (worker committed, or Stop-hook committed).
if [ -n "$(git -C "$WORKTREE" status --porcelain 2>/dev/null)" ]; then
  log ""
  log "## dirty worktree"
  git -C "$WORKTREE" status --short >> "$REPORT" 2>&1 || true
  verdict FAIL "dirty-worktree: worker (or auto-commit hook) failed to commit"
fi

# 4. Parse FILES_TOUCHED and confirm subset of allowed_paths.
ALLOWED=$(python3 - "$TICKET_PATH" <<'PY'
import re, sys
text = open(sys.argv[1]).read()
if not text.startswith("---"):
    sys.exit(0)
end = text.find("\n---", 3)
if end < 0:
    sys.exit(0)
fm = text[3:end]
allowed = []
in_list = False
for line in fm.splitlines():
    stripped = line.strip()
    if stripped.startswith("allowed_paths:"):
        val = stripped[len("allowed_paths:"):].strip()
        if val.startswith("[") and val.endswith("]"):
            for x in val[1:-1].split(","):
                x = x.strip().strip('"').strip("'")
                if x:
                    allowed.append(x)
            break
        elif val == "" or val == "|":
            in_list = True
            continue
        else:
            allowed.append(val.strip('"').strip("'"))
            break
    elif in_list:
        m = re.match(r"^\s+-\s+(.*)$", line)
        if m:
            allowed.append(m.group(1).strip().strip('"').strip("'"))
        elif line.strip() and not line.startswith("  "):
            break
for p in allowed:
    print(p)
PY
)

FILES_TOUCHED=$(awk '
  /^## FILES_TOUCHED/ { flag=1; next }
  /^## /             { flag=0 }
  flag && /^-/ {
    line=$0
    sub(/^-[ \t]*/, "", line)
    sub(/[ \t]*\([^)]*\)[ \t]*$/, "", line)
    if (length(line)) print line
  }
' "$RESULT_PATH")

in_allowed() {
  local f="$1" pat
  while IFS= read -r pat; do
    [ -z "$pat" ] && continue
    pat="${pat%/}"
    [[ "$f" == "$pat" ]] && return 0
    [[ "$f" == "$pat"/* ]] && return 0
    case "$pat" in
      */\*\*) [[ "$f" == ${pat%/\*\*}/* ]] && return 0 ;;
      */\*)   [[ "$f" == ${pat%/\*}/* ]] && return 0 ;;
    esac
    # Bash glob match.
    [[ "$f" == $pat ]] && return 0
  done <<< "$ALLOWED"
  return 1
}

if [ -n "$FILES_TOUCHED" ]; then
  OUT_OF_SCOPE=()
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    if ! in_allowed "$f"; then
      OUT_OF_SCOPE+=("$f")
    fi
  done <<< "$FILES_TOUCHED"
  if [ "${#OUT_OF_SCOPE[@]}" -gt 0 ]; then
    log ""
    log "## scope-exceeded"
    printf '  %s\n' "${OUT_OF_SCOPE[@]}" >> "$REPORT"
    verdict FAIL "scope-exceeded: ${OUT_OF_SCOPE[*]}"
  fi
fi

# 5. Re-run acceptance commands.
ACCEPT_LINES=$(awk '
  /^## acceptance/ { flag=1; next }
  /^## /           { flag=0 }
  flag && /^-/ {
    line=$0
    sub(/^-[ \t]*/, "", line)
    if (length(line)) print line
  }
' "$TICKET_PATH")

FAILED_CMDS=()
log ""
log "## acceptance re-run"
if [ -n "$ACCEPT_LINES" ]; then
  while IFS= read -r line; do
    # Extract the backticked command, if any. Acceptance lines look like
    # "`cargo test -p foo` exits 0" or similar.
    CMD=$(printf '%s' "$line" | sed -nE 's/.*`([^`]+)`.*/\1/p')
    [ -z "$CMD" ] && continue
    log ""
    log "command: $CMD"
    set +e
    (cd "$WORKTREE" && eval "$CMD") > "$VERIFIER_STATE/cmd.stdout" 2> "$VERIFIER_STATE/cmd.stderr"
    RC=$?
    set -e
    if [ "$RC" -eq 0 ]; then
      log "result: PASS"
    else
      log "result: FAIL (exit=$RC)"
      tail -20 "$VERIFIER_STATE/cmd.stderr" 2>/dev/null | sed 's/^/  /' >> "$REPORT" || true
      FAILED_CMDS+=("$CMD")
    fi
  done <<< "$ACCEPT_LINES"
fi

if [ "${#FAILED_CMDS[@]}" -gt 0 ]; then
  verdict FAIL "acceptance-failed: ${FAILED_CMDS[0]}"
fi

# 6. Re-run any ast-grep rules referenced in the ticket.
RULE_IDS=$(awk '
  /^## inputs/ { flag=1; next }
  /^## /       { flag=0 }
  flag && /rule_id:/ {
    line=$0
    sub(/.*value:[ \t]*/, "", line)
    sub(/[ \t]*}.*/, "", line)
    print line
  }
' "$TICKET_PATH" | tr -d ' ')

if [ -f "$SGCONFIG" ] && [ -n "$RULE_IDS" ]; then
  log ""
  log "## ast-grep rules"
  while IFS= read -r RULE; do
    [ -z "$RULE" ] && continue
    log ""
    log "rule: $RULE"
    set +e
    (cd "$SCOPE" && ast-grep scan -c "$SGCONFIG" --rule "$RULE" --error 2>&1) > "$VERIFIER_STATE/sg.out"
    RC=$?
    set -e
    if [ "$RC" -eq 0 ]; then
      log "result: PASS (no findings)"
    else
      log "result: FAIL (findings remain)"
      sed 's/^/  /' "$VERIFIER_STATE/sg.out" >> "$REPORT" 2>/dev/null || true
      verdict FAIL "unfixed-violations: $RULE"
    fi
  done <<< "$RULE_IDS"
fi

# 7. Tests.json must_not_be_removed sanity.
if [ -f "$TESTS_JSON" ] && command -v jq >/dev/null 2>&1; then
  log ""
  log "## must_not_be_removed tests"
  MUST_NOT_REMOVE=$(jq -r --arg tid "$TICKET_ID" '
    .tests[]?
    | select(.must_not_be_removed == true)
    | select(.ties_to_tickets // [] | index($tid))
    | .command
  ' "$TESTS_JSON")

  if [ -n "$MUST_NOT_REMOVE" ]; then
    while IFS= read -r CMD; do
      [ -z "$CMD" ] && continue
      log ""
      log "must-not-remove cmd: $CMD"
      set +e
      (cd "$WORKTREE" && eval "$CMD") > "$VERIFIER_STATE/mnr.out" 2>&1
      RC=$?
      set -e
      if [ "$RC" -eq 0 ]; then
        log "result: PASS"
      else
        log "result: FAIL"
        tail -10 "$VERIFIER_STATE/mnr.out" 2>/dev/null | sed 's/^/  /' >> "$REPORT" || true
        verdict FAIL "must-not-remove-test-violated: $CMD"
      fi
    done <<< "$MUST_NOT_REMOVE"
  else
    log "(none for this ticket)"
  fi
fi

verdict PASS "all checks passed"
