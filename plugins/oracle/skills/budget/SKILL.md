---
name: budget
description: 'This skill should be used when the user invokes `/oracle:budget` to view, reset, or configure firecrawl-MCP budget tracking maintained by the oracle plugins rate-limit hooks. Subcommands include `show` (default; display current usage + projections + recent calls), `reset` (zero the counters; useful at month boundary or after a manual key rotation), `set <key>=<value>` (override a threshold or the monthly cap; values persist in .oracle/budget.json). Use whenever the user types `/oracle:budget`, `oracle budget`, `budget status`, `how much firecrawl have I used`, or `reset oracle budget`.'
argument-hint: '[show | reset | set key=value]  (default: show)'
allowed-tools: Bash, Read, Write, Edit
---

# /oracle:budget

Manage the oracle firecrawl-MCP budget tracker. State lives at
`~/.claude/plugins/oracle/usage.json`; overrides live at
`.oracle/budget.json` (project) or
`~/.claude/plugins/oracle/budget.json` (user).

## Parse arguments

`$ARGUMENTS` is one of:

- empty or `show` -- display current usage + projections.
- `reset` -- ask the user for typed confirmation, then clear the
  counters.
- `set <key>=<value>` -- write the override into the user-scoped
  budget config.

## Subcommand: show (default)

Run the following bash to read state and emit a structured report:

```bash
USAGE="$HOME/.claude/plugins/oracle/usage.json"
COST_TABLE="${CLAUDE_PLUGIN_ROOT}/scripts/cost-table.json"
BUDGET_CFG_USER="$HOME/.claude/plugins/oracle/budget.json"
BUDGET_CFG_PROJ=".oracle/budget.json"

[ ! -f "$USAGE" ] && { echo "No usage state yet. Run a firecrawl call to seed it."; exit 0; }

# Resolve monthly budget (priority: project > user > cost-table default).
get_budget() {
  for cfg in "$BUDGET_CFG_PROJ" "$BUDGET_CFG_USER"; do
    [ -f "$cfg" ] && jq -r '.monthly_credits // empty' "$cfg" 2>/dev/null | grep -q . && {
      jq -r '.monthly_credits' "$cfg"
      return
    }
  done
  jq -r '.default_monthly_budget_credits // 100000' "$COST_TABLE" 2>/dev/null || echo 100000
}

BUDGET=$(get_budget)
jq -r --argjson budget "$BUDGET" '
  def pct(n): (n * 100 / $budget | floor);
  "Monthly:    \(.monthly.credits_used) / \($budget) credits (\(pct(.monthly.credits_used))%) for period \(.monthly.period)",
  "Weekly:     \(.weekly.credits_used) credits for period \(.weekly.period)",
  "Daily:      \(.daily.credits_used) credits for period \(.daily.period)",
  "",
  "Last 10 calls:",
  (.recent_calls[-10:] // [] | reverse | .[] | "  \(.t | strftime("%Y-%m-%d %H:%M:%S"))  \(.tool)  \(.c) cr")
' "$USAGE"
```

After the report, project the month-end based on the daily average so
the user can see whether they are tracking under or over budget. Show
which thresholds apply (soft/ask/deny/single-call/rolling-hour).

## Subcommand: reset

Before clearing state, **state explicitly what will be reset** and
ask the user to type `RESET-ORACLE-BUDGET` to confirm. Do not
proceed without that exact phrase in the next user turn.

```bash
USAGE="$HOME/.claude/plugins/oracle/usage.json"

# Move the existing state aside rather than deleting outright.
TS=$(date -u +%Y%m%dT%H%M%SZ)
if [ -f "$USAGE" ]; then
  mv "$USAGE" "${USAGE}.${TS}.bak"
fi
echo "Reset complete. Previous state archived to ${USAGE}.${TS}.bak."
```

## Subcommand: set

Override one of the configurable values. Supported keys:

- `monthly_credits` -- the monthly budget cap.
- `thresholds.soft_warning_pct`
- `thresholds.ask_threshold_pct`
- `thresholds.deny_threshold_pct`
- `thresholds.single_call_hard_gate_pct`
- `thresholds.rolling_hour_max_credits`

Write to the user-scoped config:

```bash
CFG="$HOME/.claude/plugins/oracle/budget.json"
mkdir -p "$(dirname "$CFG")"
[ ! -f "$CFG" ] && echo '{}' > "$CFG"

KEY="$1"   # e.g. monthly_credits or thresholds.soft_warning_pct
VAL="$2"   # e.g. 50000 or 75 or "some-string"

# Detect numeric-vs-string. Numeric values pass --argjson so jq
# stores them as numbers; non-numeric pass --arg so jq stores
# them as strings. The case statement is the guard the original
# pattern was missing.
case "$VAL" in
  ''|*[!0-9.-]*)
    # Contains non-numeric or is empty -> string
    jq --arg key "$KEY" --arg val "$VAL" '
      setpath(($key | split(".")); $val)
    ' "$CFG" > "$CFG.tmp" && mv "$CFG.tmp" "$CFG"
    ;;
  *)
    # Pure numeric -> json number
    jq --arg key "$KEY" --argjson val "$VAL" '
      setpath(($key | split(".")); $val)
    ' "$CFG" > "$CFG.tmp" && mv "$CFG.tmp" "$CFG"
    ;;
esac
echo "Set $KEY = $VAL in $CFG."
```

Verify the write succeeded by reading the new value back and
showing it.

## Rules

- **Never silently zero state.** The reset path requires typed
  confirmation; archived backups go to `usage.json.<timestamp>.bak`.
- **Never modify the cost-table.** That ships with the plugin and
  is read-only. The user customises via `.oracle/budget.json` or
  `~/.claude/plugins/oracle/budget.json`, never via the cost
  table.
- **Show before mutate.** Every `set` operation must echo the
  effective new value after the write.

## Edge cases

- **`~/.claude/plugins/oracle/usage.json` does not exist.** Report
  "no usage state yet" and exit cleanly. The first firecrawl call
  seeds it via the PostToolUse hook.
- **`jq` not installed.** Print a one-line error pointing to `brew
  install jq` (macOS) or the equivalent.
- **Invalid argument.** Print the supported subcommand list and
  exit.
