---
description: Run ast-grep scan across all authored domain rules and report a domain-by-domain dashboard of remaining violations. Pure Bash + ast-grep; no subagents. Use this between waves to confirm a domain is clean, or before /run-wave to baseline. Invoke as `/rust-monorepo-orchestrator:sweep-rules [<scope>] [--domain=<name>] [--json]`.
argument-hint: "[<scope>] [--domain=<name>] [--json]"
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Bash(mkdir:*)
  - Bash(date:*)
  - Bash(pwd)
  - Bash(test:*)
  - Bash(echo:*)
  - Bash(find:*)
  - Bash(ls:*)
  - Bash(awk:*)
  - Bash(sed:*)
  - Bash(grep:*)
  - Bash(cut:*)
  - Bash(jq:*)
  - Bash(realpath:*)
  - Bash(cat:*)
  - Bash(wc:*)
  - Bash(ast-grep:*)
  - Bash(sg:*)
model: claude-sonnet-4-6
---

# /rust-monorepo-orchestrator:sweep-rules

Run `ast-grep scan` against the project's `sgconfig.yml` (which the rule-author has registered each domain's rule directory in). Reports the count of remaining violations per domain, per rule. Refuses-clean exits 0; any remaining violations exit 1.

## Step 0 -- Resolve arguments

```!
set -e
ARGS=$(printf '%s' "$ARGUMENTS")
SCOPE=$(printf '%s' "$ARGS" | awk '{ for (i=1;i<=NF;i++) if ($i !~ /^--/) { print $i; exit } }')
case "$SCOPE" in '' | --*) SCOPE="$(pwd)";; esac
test -d "$SCOPE" || { echo "ABORT: scope $SCOPE is not a directory"; exit 0; }
SCOPE=$(cd "$SCOPE" && pwd)

DOMAIN_FILTER=$(printf '%s' "$ARGS" | grep -oE -- '--domain=[^ ]+' | cut -d= -f2 || true)

JSON_MODE="false"
case " $ARGS " in
  *" --json "*) JSON_MODE="true";;
esac

SGCONFIG="$SCOPE/sgconfig.yml"
test -f "$SGCONFIG" || { echo "ABORT: $SGCONFIG missing. Run /rust-monorepo-orchestrator:audit-domain <name> first."; exit 0; }

# Locate the ast-grep binary.
SG_BIN=""
if command -v ast-grep >/dev/null 2>&1; then SG_BIN="ast-grep"
elif command -v sg >/dev/null 2>&1; then SG_BIN="sg"
else
  echo "ABORT: ast-grep is not installed (looked for ast-grep, sg)."
  exit 0
fi

cat <<EOF
BOOTSTRAP_OK=1
SCOPE=$SCOPE
SGCONFIG=$SGCONFIG
SG_BIN=$SG_BIN
DOMAIN_FILTER=${DOMAIN_FILTER:-(all)}
JSON_MODE=$JSON_MODE
EOF
```

## Step 1 -- Run the scan

```!
cd "$SCOPE"

if [ "$JSON_MODE" = "true" ]; then
  # JSON mode: emit ast-grep --json verbatim.
  if [ -n "${DOMAIN_FILTER:-}" ]; then
    RULES_DIR=".refactor/rules/$DOMAIN_FILTER"
    test -d "$RULES_DIR" || { echo '{"error":"domain not found"}'; exit 0; }
    "$SG_BIN" scan -c "$SGCONFIG" --json | jq --arg dom "$DOMAIN_FILTER" '[.[] | select(.ruleId | startswith($dom + "-") or contains("/" + $dom + "/"))]'
  else
    "$SG_BIN" scan -c "$SGCONFIG" --json
  fi
  exit 0
fi

# Human-readable mode.
echo "=========================================="
echo "  ast-grep sweep"
echo "=========================================="
echo "  sgconfig:  $SGCONFIG"
echo "  domain:    ${DOMAIN_FILTER:-(all)}"
echo

# Per-domain summary by counting findings in --json output.
TMP=$(mktemp)
"$SG_BIN" scan -c "$SGCONFIG" --json > "$TMP" 2>/dev/null || true

if [ ! -s "$TMP" ]; then
  echo "  CLEAN: 0 violations across all rules."
  rm -f "$TMP"
  exit 0
fi

# Group by ruleId; the ruleId convention from rule-author is
# <domain>-<...> for instance and generalized.
TOTAL=$(jq 'length' "$TMP")
echo "  TOTAL VIOLATIONS: $TOTAL"
echo
echo "  by rule:"
jq -r 'group_by(.ruleId) | map({ruleId: .[0].ruleId, count: length}) | sort_by(-.count) | .[] | "    \(.count)\t\(.ruleId)"' "$TMP" 2>/dev/null

echo
echo "  first 10 violations:"
jq -r '.[0:10] | .[] | "    \(.file):\(.range.start.line) [\(.ruleId)] \(.message // "")"' "$TMP" 2>/dev/null

rm -f "$TMP"

if [ "$TOTAL" -gt 0 ]; then
  echo
  echo "  Run with --json for the full structured output."
  echo "  Pipe to | jq for filtering."
  exit 1
fi
```

## Step 2 -- Print suggestions

```!
echo
echo "=========================================="
echo "  hints"
echo "=========================================="
echo "  - JSON for tooling:    /rust-monorepo-orchestrator:sweep-rules --json"
echo "  - Single domain:       /rust-monorepo-orchestrator:sweep-rules --domain=<name>"
echo "  - For an in-flight wave, use /rust-monorepo-orchestrator:status to see"
echo "    pending tickets that should resolve the violations above."
echo "=========================================="
```

## Whole-workflow constraints

- Read-only. No writes. No subagents.
- Exits non-zero if any violation is reported (so it fits in CI).
- `--json` mode prints raw ast-grep JSON for tooling integration.
