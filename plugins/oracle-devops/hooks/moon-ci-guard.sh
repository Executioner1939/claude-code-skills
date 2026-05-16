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

Reference: plugins/ci-moonrepo/skills/ci-moonrepo/references/ci-guide.md
section 5 (revision comparison) and section 14 (anti-patterns table).
EOF
  exit 2
fi

# ---- Tier 2: soft warn on `moon ci` lacking explicit base/head ----
if printf '%s' "$COMMAND" | grep -qE 'moon[[:space:]]+ci\b'; then
  if ! printf '%s' "$COMMAND" | grep -qE -- '(--base|--head|MOON_BASE|MOON_HEAD)'; then
    MSG="[ci-moonrepo] 'moon ci' invoked without --base/--head and no MOON_BASE/MOON_HEAD in the command. moon will auto-detect via the ci_env crate, which is fragile across CI providers and on merge-commit bases. Prefer explicit: 'moon ci --base \$BASE_SHA --head \$HEAD_SHA'. Source the base deterministically with 'git merge-base HEAD origin/main'. Reference: references/ci-guide.md section 5."
    jq -n --arg msg "$MSG" '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        additionalContext: $msg
      }
    }'
  fi
fi

exit 0
