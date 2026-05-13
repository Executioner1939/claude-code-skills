## Rate-limit etiquette

The firecrawl PreToolUse / PostToolUse hooks gate calls against the
`{{ budget.monthly_credits }}` monthly-credit budget tracked at
`~/.claude/plugins/oracle/usage.json`. The behaviour tiers are:

- Under {{ budget.thresholds.soft_remind_at_pct }}% of monthly budget:
  silent allow.
- {{ budget.thresholds.soft_remind_at_pct }}% to {{ budget.thresholds.ask_permission_at_pct }}%:
  soft reminder, no permission prompt.
- {{ budget.thresholds.ask_permission_at_pct }}% to {{ budget.thresholds.hard_deny_at_pct }}%
  (or any single call expected to consume >= {{ budget.single_call_ask_pct }}%
  of remaining budget, or rolling-hour usage over
  {{ budget.rolling_hour_ask_credits }} credits): ask permission.
- Above {{ budget.thresholds.hard_deny_at_pct }}%: hard deny.

When the gate asks for permission, prefer the cheapest cascade tier
that still answers the claim. The `cost-rethinker` subagent dispatches
multi-angle alternatives when an expensive call is flagged.
