---
name: narrator
description: Configure the model that narrates oracle session summaries. Selects which Claude model is invoked via `claude --model <m> -p` when the session-summary threshold is crossed (every 30 min of active agent time or every 50 turns, whichever lands first). Default is Sonnet 4.6. Set to `off` to disable the LLM narrative tier and keep only the deterministic counts. Modelled on `/model` in the Claude Code CLI.
argument-hint: "[<model-id> | sonnet | opus | haiku | off | show]"
allowed-tools: Bash
disable-model-invocation: true
---

# /oracle:narrator

Set or inspect the model that narrates oracle's periodic session summaries.

## Arguments

| Form | Effect |
|---|---|
| `/oracle:narrator` or `/oracle:narrator show` | Print the current narrator setting. |
| `/oracle:narrator <model-id>` | Set the narrator to the named model. The model ID is passed verbatim to `claude --model <id> -p`. Examples: `claude-sonnet-4-6`, `claude-opus-4-7`, `claude-haiku-4-5-20251001`. |
| `/oracle:narrator sonnet` | Alias for `claude-sonnet-4-6` (the default). |
| `/oracle:narrator opus` | Alias for `claude-opus-4-7`. |
| `/oracle:narrator haiku` | Alias for `claude-haiku-4-5-20251001`. |
| `/oracle:narrator off` | Disable the LLM tier entirely. Summaries fall back to the deterministic-counts ship-receipt block only. |

## State file

The choice is persisted at `~/.claude/plugins/oracle/narrator.conf` (a single line containing the model ID, or the literal string `off`). The file is per-machine, not per-project, not per-session. If the file is absent, the default is `claude-sonnet-4-6`.

## Steps

Given the argument `$ARGUMENTS`, execute the following bash block:

```bash
CONF="$HOME/.claude/plugins/oracle/narrator.conf"
mkdir -p "$(dirname "$CONF")"

arg=$(echo "$ARGUMENTS" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')

case "$arg" in
  ""|show)
    if [ -f "$CONF" ]; then
      current=$(cat "$CONF")
      echo "oracle narrator: $current"
    else
      echo "oracle narrator: claude-sonnet-4-6 (default; no narrator.conf written)"
    fi
    ;;
  sonnet)
    echo "claude-sonnet-4-6" > "$CONF"
    echo "oracle narrator set to claude-sonnet-4-6 (sonnet)"
    ;;
  opus)
    echo "claude-opus-4-7" > "$CONF"
    echo "oracle narrator set to claude-opus-4-7 (opus)"
    ;;
  haiku)
    echo "claude-haiku-4-5-20251001" > "$CONF"
    echo "oracle narrator set to claude-haiku-4-5-20251001 (haiku)"
    ;;
  off|none|disable|disabled)
    echo "off" > "$CONF"
    echo "oracle narrator disabled; summaries will use deterministic counts only"
    ;;
  *)
    # Treat as a literal model ID. Minimal validation: must start with 'claude-'.
    if ! echo "$arg" | grep -qE '^claude-[a-z0-9.-]+$'; then
      echo "error: unrecognised model id '$arg'. Expected one of:"
      echo "  - claude-sonnet-4-6 (or alias: sonnet)"
      echo "  - claude-opus-4-7 (or alias: opus)"
      echo "  - claude-haiku-4-5-20251001 (or alias: haiku)"
      echo "  - off"
      echo "  - any literal model ID starting with 'claude-'"
      exit 1
    fi
    echo "$arg" > "$CONF"
    echo "oracle narrator set to $arg"
    ;;
esac
```

## Verification

After running the command, the next `UserPromptSubmit` that crosses a summary threshold will pick up the new setting (state is read at fire time, not at session start).

## Cost shape

| Narrator | Approx cost per summary | 4-hour session (8 fires) |
|---|---|---|
| `off` | $0 | $0 |
| `claude-haiku-4-5-20251001` | ~$0.001 | ~$0.008 |
| `claude-sonnet-4-6` (default) | ~$0.02 | ~$0.16 |
| `claude-opus-4-7` | ~$0.10 | ~$0.80 |
