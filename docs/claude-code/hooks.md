# Hooks

Snapshot date: 2026-05-14. Sources of truth:

- Reference: <https://code.claude.com/docs/en/hooks>
- Guide: <https://code.claude.com/docs/en/hooks-guide>

Hooks are user-defined callbacks that fire on lifecycle events. They can observe (record state), inject context (add text to Claude's view), or block (cancel a tool call, prevent a stop, deny a permission). Five handler types: `command`, `http`, `mcp_tool`, `prompt`, `agent`.

## Event catalogue

All 29 events, verbatim from <https://code.claude.com/docs/en/hooks-guide#how-hooks-work>:

| Event | When it fires |
|---|---|
| `SessionStart` | When a session begins or resumes. |
| `Setup` | When you start Claude Code with `--init-only`, or with `--init` or `--maintenance` in `-p` mode. |
| `UserPromptSubmit` | When you submit a prompt, before Claude processes it. |
| `UserPromptExpansion` | When a user-typed command expands into a prompt, before it reaches Claude. Can block the expansion. |
| `PreToolUse` | Before a tool call executes. Can block it. |
| `PermissionRequest` | When a permission dialog appears. |
| `PermissionDenied` | When a tool call is denied by the auto-mode classifier. |
| `PostToolUse` | After a tool call succeeds. |
| `PostToolUseFailure` | After a tool call fails. |
| `PostToolBatch` | After a full batch of parallel tool calls resolves, before the next model call. |
| `Notification` | When Claude Code sends a notification. |
| `SubagentStart` | When a subagent is spawned. |
| `SubagentStop` | When a subagent finishes. |
| `TaskCreated` | When a task is created via `TaskCreate`. |
| `TaskCompleted` | When a task is marked completed. |
| `Stop` | When Claude finishes responding. |
| `StopFailure` | When the turn ends due to an API error. Output and exit code are ignored. |
| `TeammateIdle` | When an agent-team teammate is about to go idle. |
| `InstructionsLoaded` | When `CLAUDE.md` or `.claude/rules/*.md` files are loaded. |
| `ConfigChange` | When a configuration file changes during a session. |
| `CwdChanged` | When the working directory changes (e.g. `cd`). |
| `FileChanged` | When a watched file changes on disk. `matcher` lists filenames to watch. |
| `WorktreeCreate` | When a worktree is being created via `--worktree` or `isolation: worktree`. |
| `WorktreeRemove` | When a worktree is being removed. |
| `PreCompact` | Before context compaction. |
| `PostCompact` | After context compaction completes. |
| `Elicitation` | When an MCP server requests user input during a tool call. |
| `ElicitationResult` | After a user responds to an MCP elicitation, before being sent back to server. |
| `SessionEnd` | When a session terminates. |

## Matcher patterns per event

Matcher syntax (verbatim, <https://code.claude.com/docs/en/hooks>): "Letters, digits, `_`, `|` matchers are evaluated as exact string or pipe-separated list. Other characters are treated as JavaScript regex."

| Event(s) | Matcher field | Example values |
|---|---|---|
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | tool name | `Bash`, `Edit\|Write`, `mcp__.*` |
| `SessionStart` | source | `startup`, `resume`, `clear`, `compact` |
| `Setup` | trigger | `init`, `maintenance` |
| `SessionEnd` | reason | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification` | notification type | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_complete`, `elicitation_response` |
| `SubagentStart`, `SubagentStop` | agent type | `general-purpose`, `Explore`, `Plan`, custom names |
| `PreCompact`, `PostCompact` | trigger | `manual`, `auto` |
| `ConfigChange` | source | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `StopFailure` | error type | `rate_limit`, `authentication_failed`, `oauth_org_not_allowed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `InstructionsLoaded` | load reason | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `Elicitation`, `ElicitationResult` | MCP server name | configured server names |
| `FileChanged` | literal filenames | `.envrc\|.env` |
| `UserPromptExpansion` | command name | skill/command names |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged` | (no matcher support) | always fires |

Source: <https://code.claude.com/docs/en/hooks-guide#filter-hooks-with-matchers>. Fetched 2026-05-14.

## Decision verbs per event

| Event | Decision shape | Effect |
|---|---|---|
| `PreToolUse` | `hookSpecificOutput.permissionDecision: "allow"\|"deny"\|"ask"\|"defer"`, plus `updatedInput`, `additionalContext` | `allow` skips the prompt but does not override deny rules; `deny` cancels; `ask` shows the prompt; `defer` only in `-p` mode. |
| `PostToolUse`, `PostToolBatch` | top-level `decision: "block"` + `reason` | Stops the agentic loop. |
| `Stop`, `SubagentStop` | top-level `decision: "block"` + `reason` | Prevents stop; Claude keeps working. |
| `UserPromptSubmit`, `UserPromptExpansion` | `decision: "block"` plus `additionalContext`, and (UPS only) `sessionTitle` | Rejects or erases the prompt. |
| `PermissionRequest` | `hookSpecificOutput.decision.behavior: "allow"\|"deny"`, optional `updatedInput`, `updatePermissionRules`, `updatedPermissions` | Substitutes for the dialog. |
| `PermissionDenied` | `hookSpecificOutput.retry: true` | Tells the model it may retry. |
| `SessionStart`, `Setup` | `hookSpecificOutput.additionalContext` (plain stdout also reaches Claude) | Inject context. |
| `WorktreeCreate` | `hookSpecificOutput.worktreePath` | Provides the worktree path. |
| `Elicitation`, `ElicitationResult` | `hookSpecificOutput.action: "accept"\|"decline"\|"cancel"`, `content` | Drives the MCP form. |
| `SessionEnd`, `CwdChanged`, `FileChanged`, `Notification`, `PostCompact`, `StopFailure`, `InstructionsLoaded` | none — observability only | — |

Source: <https://code.claude.com/docs/en/hooks-guide#read-input-and-return-output>. Fetched 2026-05-14.

## Exit-code semantics

Verbatim from <https://code.claude.com/docs/en/hooks-guide>:

> Exit 0: the action proceeds. For `UserPromptSubmit`, `UserPromptExpansion`, and `SessionStart` hooks, anything you write to stdout is added to Claude's context.
>
> Exit 2: the action is blocked. Write a reason to stderr.
>
> Any other exit code: the action proceeds. The transcript shows a `<hook name> hook error` notice followed by the first line of stderr.

> Use exit 2 to block with a stderr message, or exit 0 with JSON for structured control. Don't mix them: Claude Code ignores JSON when you exit 2.

## Handler-type matrix

| Type | Default timeout | What it spawns | When to use |
|---|---|---|---|
| `command` | 600 s (10 min) | Shell or exec-form child process. | Deterministic checks: exit-code logic, file-system inspection, fast scripts. |
| `http` | 30 s | POST to URL. Response body uses the same JSON schema as a command hook's stdout. | Centralised policy services, remote audit logging. |
| `mcp_tool` | 60 s | Calls a configured MCP server tool. | When the logic lives in an MCP server. Introduced 2.1.118. |
| `prompt` | 30 s | Single-turn LLM call. Defaults to Haiku; `model` field overrides. | Judgment calls that don't reduce to a clean exit code ("did this commit message capture intent"). |
| `agent` | 60 s | Subagent with tools (Read, Grep, Glob mentioned in docs), up to 50 tool-use turns. **Experimental.** | Verifying claims against actual filesystem state ("did the tests get written, or did Claude just claim they were"). |

Verbatim from <https://code.claude.com/docs/en/hooks-guide>:

> Use prompt hooks when the hook input data alone is enough to make a decision. Use agent hooks when you need to verify something against the actual state of the codebase.

> Agent hooks are experimental. Behavior and configuration may change in future releases. For production workflows, prefer command hooks.

Version-introduction note: a community write-up cited "added in 2.0.41" for `prompt` and `agent` handler types. The official changelog at `anthropics/claude-code/main/CHANGELOG.md` does not preserve 2.0.x history at fetch time (2026-05-14), so the specific introduction version cannot be confirmed from canon. The handler types themselves are documented in the current hooks reference and guide; `prompt` is production-stable and `agent` is flagged experimental.

## Registration locations

| Location | Scope | Shareable |
|---|---|---|
| `~/.claude/settings.json` | All your projects | No, local to your machine. |
| `.claude/settings.json` | Single project | Yes, can be committed. |
| `.claude/settings.local.json` | Single project | No, gitignored. |
| Managed policy settings | Org-wide | Yes, admin-controlled. |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes, bundled with plugin. |
| Skill or agent frontmatter (`hooks:` key) | While the component is active | Yes, defined in the component file. |

Inside `plugin.json` the `hooks` field can be a path string (`"./config/hooks.json"`), an array of paths, or an inline object. Plugin subagents silently ignore frontmatter `hooks:` for security reasons; see [subagents.md](subagents.md#plugin-subagent-restrictions).

Block shape inside `settings.json`, verbatim from <https://code.claude.com/docs/en/hooks-guide>:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "/path/to/script.sh" }
        ]
      }
    ]
  },
  "disableAllHooks": false
}
```

Three outer-level kill switches: `disableAllHooks: true` disables everything (except managed hooks unless `disableAllHooks` is also set there); `allowedHttpHookUrls` (array, supports `*`) restricts HTTP-hook destinations; `allowManagedHooksOnly: true` restricts to managed + SDK + force-enabled plugin hooks.

## Decision combination

Verbatim from <https://code.claude.com/docs/en/hooks-guide#combine-results-from-multiple-hooks>:

> After all matching hooks finish, Claude Code combines their outputs. For `PreToolUse` permission decisions, the most restrictive answer wins: `deny` overrides `ask`, which overrides `allow`. Text from `additionalContext` is kept from every hook and passed to Claude together.

Hook decisions interact with permission modes: a hook returning `deny` blocks even in `bypassPermissions` mode or with `--dangerously-skip-permissions`. The reverse is not true: a hook returning `allow` does not bypass deny rules from settings.

## The `stop_hook_active` loop-breaker

Verbatim from <https://code.claude.com/docs/en/hooks-guide#stop-hook-runs-forever>:

> Your Stop hook script needs to check whether it already triggered a continuation. Parse the `stop_hook_active` field from the JSON input and exit early if it's `true`:
>
> ```bash
> #!/bin/bash
> INPUT=$(cat)
> if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
>   exit 0  # Allow Claude to stop
> fi
> ```

The field is present in `Stop` and `SubagentStop` hook input. Skipping the check is the root cause of <https://github.com/anthropics/claude-code/issues/55754> — a Stop hook that returned `{"ok": false}` looped until session quota was exhausted, ~50 minutes. The issue is closed as duplicate but the cautionary tale stands. See [references.md](references.md#documented-hazards).

## Worked patterns

### Pattern 1 — Block until tests pass

The canonical Stop-hook example. Claude cannot end its turn while `npm test` is failing.

`.claude/hooks/stop.py`:

```python
#!/usr/bin/env python3
import json, sys, subprocess

data = json.load(sys.stdin)

# Break the loop once Claude has already been forced to continue once.
if data.get("stop_hook_active", False):
    sys.exit(0)

result = subprocess.run(["npm", "test"], capture_output=True, timeout=60)
if result.returncode != 0:
    print(json.dumps({
        "decision": "block",
        "reason": f"Tests failing. Fix them before stopping.\n\n{result.stdout.decode()[-2000:]}",
    }))
sys.exit(0)
```

`.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [{ "type": "command", "command": "python .claude/hooks/stop.py" }]
      }
    ]
  }
}
```

### Pattern 2 — Incomplete-task marker file

Drop a marker at the start of a long multi-step job; the hook refuses to let Claude stop until the marker is deleted. Useful when "done" is determined by the user, not by an exit code.

```python
import json, sys
from pathlib import Path

data = json.load(sys.stdin)
if data.get("stop_hook_active"):
    sys.exit(0)

marker = Path(".claude/incomplete-task")
if marker.exists():
    print(json.dumps({
        "decision": "block",
        "reason": f"Task incomplete: {marker.read_text().strip()}",
    }))
sys.exit(0)
```

Have Claude `echo "implement auth" > .claude/incomplete-task` at the start of a task and `rm .claude/incomplete-task` when done. Or generate the marker from a TODO checklist file.

### Pattern 3 — Force "what's next?" — continuous workflow

The hook never lets Claude end naturally; instead it forces an `AskUserQuestion` tool call with context-aware options. Useful as a "drive Claude like a kanban" loop — finish a feature, get presented with next-step options, pick one, repeat.

`.claude/hooks/index.ts`:

```typescript
import type { HookJSONOutput } from "@anthropic-ai/claude-agent-sdk";

const input = await Bun.stdin.json();
if (input.stop_hook_active) {
  console.log(JSON.stringify({}));
  process.exit(0);
}

const output: HookJSONOutput = {
  decision: "block",
  reason: "Use the AskUserQuestion tool to ask what to refine or build next.",
};
console.log(JSON.stringify(output));
```

### Pattern 4 — Prompt-based hook (let Haiku judge)

Instead of a deterministic shell check, Haiku reviews the transcript and decides if work is complete. Good when "done" isn't easily expressed as an exit code.

```json
{
  "hooks": {
    "Stop": [{
      "type": "prompt",
      "prompt": "Review context. ALL must be true: 1) code builds, 2) tests pass, 3) all TODOs in current task resolved. Return {\"decision\":\"approve\"|\"block\",\"reason\":\"...\"}. Context: $ARGUMENTS",
      "timeout": 30
    }]
  }
}
```

For verifying claims against actual filesystem state ("did Claude actually write the tests, or just claim to"), use `"type": "agent"` instead — it spawns a subagent with Read/Grep/Glob and a 60s default timeout. Agent hooks are flagged experimental in canon; reserve them for cases prompt hooks cannot answer.

### Pattern 5 — Combine deterministic + judgment

Chain multiple Stop hooks. Fast deterministic checks first, then a prompt hook for the judgment call. Each fires in sequence; any one returning `decision: "block"` forces continuation.

```json
{
  "hooks": {
    "Stop": [
      { "type": "command", "command": "cargo check --message-format=short" },
      { "type": "command", "command": "cargo fmt --check" },
      { "type": "prompt", "prompt": "Are all items in the task checklist done? Context: $ARGUMENTS" }
    ]
  }
}
```

## Limitations and footguns

Verbatim from <https://code.claude.com/docs/en/hooks-guide#limitations>:

- "Command hooks communicate through stdout, stderr, and exit codes only. They cannot trigger `/` commands or tool calls."
- "Hook timeout is 10 minutes by default, configurable per hook with the `timeout` field (in seconds)."
- "`PostToolUse` hooks cannot undo actions since the tool has already executed."
- "`PermissionRequest` hooks do not fire in non-interactive mode (`-p`). Use `PreToolUse` hooks for automated permission decisions."
- "`Stop` hooks fire whenever Claude finishes responding, not only at task completion. They do not fire on user interrupts. API errors fire `StopFailure` instead."
- "When multiple PreToolUse hooks return `updatedInput` to rewrite a tool's arguments, the last one to finish wins. Since hooks run in parallel, the order is non-deterministic."

Additional documented hazards (see [references.md](references.md#documented-hazards) for issue numbers and current state):

- **Skill-frontmatter Stop hooks don't fire on macOS** (#19225, closed-stale). Use `.claude/settings.json` instead.
- **Plugin-installed Stop hooks with exit code 2 fail to continue** (#10412, closed). Worked when placed in `.claude/hooks/` directly; broken when shipped via plugin manifest.
- **50-minute infinite Stop loop from malformed JSON** (#55754, closed as duplicate). Root cause: missing `stop_hook_active` check.
- **Background-subagent state desync infinite loop** (#58637, open). A second class of Stop-loop pathology.
- **`/reload-plugins` does not reload hook scripts** (#55008, open). Iterate hooks in `.claude/hooks/` during development; switch to plugin layout only after the script stabilises.
- **Bare hook entry `{type, command}` silently breaks the entire hooks config** (#49990, open). No error, no warning. Always nest hooks inside `hooks: [{matcher, hooks: [...]}]`.

## Best practices

- "Use exit 2 to block with a stderr message, or exit 0 with JSON for structured control. Don't mix them: Claude Code ignores JSON when you exit 2." (Anthropic)
- "Keep the matcher as narrow as possible. Matching on `.*` or leaving the matcher empty would auto-approve every permission prompt, including file writes and shell commands." (Anthropic)
- "For full execution details including which hooks matched, their exit codes, stdout, and stderr, read the debug log. Start Claude Code with `claude --debug-file /tmp/claude.log`." (Anthropic)
- Always include `if data.get("stop_hook_active"): sys.exit(0)` (or its language equivalent) in every Stop and SubagentStop hook. Skipping it is the root cause of #55754 and the surrounding class of incidents.
- Treat `continue: false` as the kill switch. A Stop hook that emits `{"continue": false, "stopReason": "..."}` overrides everything and ends the session. Useful safety valve, dangerous default.

## Marketplace examples

- `plugins/oracle/hooks/oracle-preflight.sh` — `SessionStart` hook that injects the verification protocol.
- `plugins/oracle/hooks/rate-limit-guard.sh` and `rate-limit-track.sh` — paired `PreToolUse` / `PostToolUse` hooks on the firecrawl-mcp surface that enforce tiered budget gating.
- `plugins/oracle/hooks/safe-edit-guard.sh` — `PreToolUse` on `Edit|Write|MultiEdit|NotebookEdit` that warns when the target path has not been Read within a 30-minute freshness window.
- `plugins/oracle/hooks/intercept-install.sh` — `PreToolUse` on `Bash` that intercepts unpinned install commands across thirteen package managers.

## Sources

- [Hooks reference](https://code.claude.com/docs/en/hooks) — fetched 2026-05-14.
- [Hooks guide](https://code.claude.com/docs/en/hooks-guide) — fetched 2026-05-14.
- [Plugins reference, hooks section](https://code.claude.com/docs/en/plugins-reference#hooks) — fetched 2026-05-14.
- [anthropics/claude-code CHANGELOG (preserves 2.1.x; 2.0.x history not retained)](https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md) — fetched 2026-05-14.
