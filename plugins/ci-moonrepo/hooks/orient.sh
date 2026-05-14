#!/usr/bin/env bash
# orient.sh -- SessionStart hook for the ci-moonrepo plugin.
#
# Walks up from the session cwd looking for a .moon/ directory. If found,
# emits a four-line orientation that points the agent at the skill, the
# three CI lanes (tag-based explicit inheritance), the mandatory inheritedBy
# rule, and the always-explicit --base/--head rule.
#
# Performance budget: <5ms on the no-moon-context fast path. We walk up at
# most 8 parents before giving up.
#
# Output protocol: SessionStart hooks may write to stdout and the content is
# appended to Claude's context (per the hooks-guide exit-code semantics).
# We use stdout rather than the JSON hookSpecificOutput surface because it
# is the simpler primitive for the SessionStart event.

set -u

fail_silent() { exit 0; }
trap fail_silent ERR

INPUT=$(cat)

# Resolve cwd from the hook payload. Tolerate jq absence: fall back to $PWD.
if command -v jq >/dev/null 2>&1; then
  CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || true)
fi
[ -z "${CWD:-}" ] && CWD="${PWD:-$(pwd)}"

# Walk up from cwd looking for .moon/. Cap at 8 levels to bound the worst case.
# A bare .moon/ directly at $HOME is moon's own tool-state directory (proto-
# managed toolchain cache, lockfiles, etc.) -- it is NOT a workspace marker
# and must not fire the orientation. We accept the .moon/ only if it sits at
# a strict descendant of $HOME, or somewhere outside $HOME entirely.
HOME_REAL="${HOME:-/}"
dir="$CWD"
moon_root=""
for _ in 1 2 3 4 5 6 7 8; do
  if [ -d "$dir/.moon" ] && [ "$dir" != "$HOME_REAL" ]; then
    moon_root="$dir"
    break
  fi
  parent=$(dirname "$dir")
  if [ "$parent" = "$dir" ] || [ "$dir" = "$HOME_REAL" ]; then
    break
  fi
  dir="$parent"
done

[ -z "$moon_root" ] && exit 0

DISPLAY_ROOT="${moon_root#"$HOME"/}"
if [ "$DISPLAY_ROOT" != "$moon_root" ]; then
  DISPLAY_ROOT="~/${DISPLAY_ROOT}"
fi

cat <<EOF
[ci-moonrepo] moonrepo workspace detected at ${DISPLAY_ROOT}.

Skill ci-moonrepo:ci-moonrepo applies. Six production-failure-mode-anchored rules
in SKILL.md; comprehensive walkthrough in references/ci-guide.md (14 sections).

Load-bearing rules:
  1. Every .moon/tasks/*.yml MUST declare an 'inheritedBy:' block. Tag-based
     CI lanes: ci-pull-request / ci-merge-develop / ci-merge-production.
     Toolchain-conditioned developer commands via 'inheritedBy: { toolchains: [...] }'.
  2. moon ci MUST receive explicit --base and --head (or MOON_BASE / MOON_HEAD
     env). Never rely on \${{ github.event.before }} -- it is empty string on
     new branches and an all-zero SHA on first push.
  3. "Resolved targets: 0" on an obviously-changed diff is a propagation bug,
     not "nothing to do".

Forbidden: top-level .moon/tasks.yml (singular); toolchain-named .moon/tasks/
files without an inheritedBy: condition.
EOF

exit 0
