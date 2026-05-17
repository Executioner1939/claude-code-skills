#!/usr/bin/env bash
# moon-ci-guard.sh -- PreToolUse hook on Bash.
#
# Inspects tool_input.command for moon-CI patterns:
#
#   1. Hard deny (exit 2): any `moon ci|run|exec|query` invocation that
#      references ${{ github.event.before }}. This is the zero-SHA
#      production trap: github.event.before is empty string on freshly
#      created branches and an all-zero SHA ("0000000000000000000000000000000000000000")
#      on a first push. Either case makes moon's revision-comparison
#      silently degrade to "no diff" -> "no affected" -> CI green on broken
#      code. There is no legitimate use case in a production pipeline.
#
#   2. Soft warn via additionalContext: `moon ci` invoked without
#      --base / --head and without MOON_BASE / MOON_HEAD in the command
#      line. moon will fall back to auto-detect via the ci_env crate;
#      this is fragile across CI providers and merge-commit bases. Prefer
#      explicit revision-comparison.
#
# Performance budget: <5ms on the no-moon-command fast path. Single
# `case` short-circuit before any grep.

set -u

fail_silent() { exit 0; }
trap fail_silent ERR

INPUT=$(cat)
command -v jq >/dev/null 2>&1 || fail_silent

TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
[ "$TOOL_NAME" = "Bash" ] || fail_silent

COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
[ -n "$COMMAND" ] || fail_silent

# Fast no-op: no "moon" token at all.
case "$COMMAND" in
  *moon*) : ;;
  *) exit 0 ;;
esac

# ---- Tier 1: hard deny on github.event.before reaching a moon command ----
if printf '%s' "$COMMAND" | grep -qE 'github\.event\.before' && \
   printf '%s' "$COMMAND" | grep -qE 'moon[[:space:]]+(ci|run|exec|query)\b'; then
  cat >&2 <<'EOF'
[ci-moonrepo] BLOCKED: moon command references ${{ github.event.before }}.

github.event.before is empty string on freshly created branches and the
all-zero SHA "0000000000000000000000000000000000000000" on a first push.
Either case makes moon's revision-comparison silently degrade to "no diff"
-> "no affected targets" -> CI reports green on broken code. This is one
of the catalogued production failure modes in the ci-moonrepo skill.

Always pass --base and --head explicitly, or set MOON_BASE / MOON_HEAD env
vars. Source the base ref deterministically; e.g.:

  BASE=$(git merge-base HEAD origin/main)
  HEAD=$(git rev-parse HEAD)
  moon ci --base "$BASE" --head "$HEAD"

Or, in a GitHub Actions context, use github.event.pull_request.base.sha
plus github.event.pull_request.head.sha (these are stable), never
github.event.before.

Reference: references/workflows.md §1 (affected-detection no-op) and
references/ci-guide.md §2 (revision comparison deep dive).
EOF
  exit 2
fi

# ---- Tier 2: soft warn on `moon ci` lacking explicit base/head ----
if printf '%s' "$COMMAND" | grep -qE 'moon[[:space:]]+ci\b'; then
  if ! printf '%s' "$COMMAND" | grep -qE -- '(--base|--head|MOON_BASE|MOON_HEAD)'; then
    MSG="[ci-moonrepo] 'moon ci' invoked without --base/--head and no MOON_BASE/MOON_HEAD in the command. moon will auto-detect via the ci_env crate, which is fragile across CI providers and on merge-commit bases. Prefer explicit: 'moon ci --base \$BASE_SHA --head \$HEAD_SHA'. Source the base deterministically with 'git merge-base HEAD origin/main'. Reference: references/workflows.md §1 and references/ci-guide.md §2."
    jq -n --arg msg "$MSG" '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        additionalContext: $msg
      }
    }'
  fi
fi

# ---- Tier 3: warn on interactive graph commands without --json or --dot ----
# moon project-graph / task-graph / action-graph open a browser when run
# without --json or --dot. In a non-interactive context that hangs the
# tool call. The skill bundles scripts/graph-json.sh as the safe wrapper.
if printf '%s' "$COMMAND" | grep -qE 'moon[[:space:]]+(project-graph|task-graph|action-graph)\b'; then
  if ! printf '%s' "$COMMAND" | grep -qE -- '(--json|--dot|scripts/graph-json\.sh)'; then
    MSG="[ci-moonrepo] 'moon project-graph' / 'moon task-graph' / 'moon action-graph' are INTERACTIVE by default -- they open a browser to render the DAG and will hang in a non-interactive tool context. Pass --json or --dot, or use the bundled wrapper: '\${CLAUDE_PLUGIN_ROOT}/scripts/graph-json.sh <subcommand> [args...]'. Reference: references/advanced.md 'Project and action graphs'."
    jq -n --arg msg "$MSG" '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        additionalContext: $msg
      }
    }'
  fi
fi

# ---- Tier 4: catch the silently-ignored MOON_SKIP_SETUP_RUST ----
if printf '%s' "$COMMAND" | grep -qE 'MOON_SKIP_SETUP_RUST\b'; then
  MSG="[ci-moonrepo] MOON_SKIP_SETUP_RUST is NOT a real env var -- it is silently ignored by moon. Use MOON_SKIP_SETUP_TOOLCHAIN=rust (per-tool) or MOON_SKIP_SETUP_TOOLCHAIN=rust:1.90.0 (per-version). Reference: references/workflows.md §4 and references/moon-cheatsheet.md 'Environment variables'."
  jq -n --arg msg "$MSG" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      additionalContext: $msg
    }
  }'
fi

# ---- Tier 5: catch --json on moon query (it is the default, flag is ignored) ----
if printf '%s' "$COMMAND" | grep -qE 'moon[[:space:]]+query[[:space:]]+[a-z-]+[[:space:]].*--json\b'; then
  MSG="[ci-moonrepo] 'moon query' subcommands emit JSON by default -- there is no --json flag. The flag is silently ignored. Drop it from the invocation. Reference: references/moon-cheatsheet.md 'Affected detection'."
  jq -n --arg msg "$MSG" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      additionalContext: $msg
    }
  }'
fi

exit 0
