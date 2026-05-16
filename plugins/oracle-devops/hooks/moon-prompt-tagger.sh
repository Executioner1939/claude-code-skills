#!/usr/bin/env bash
# moon-prompt-tagger.sh -- UserPromptSubmit hook.
#
# Pattern-matches the submitted prompt for moon-CI topics. On match, prints
# a skill-pointer paragraph plus the four load-bearing rules to stdout.
# UserPromptSubmit hooks have stdout-as-additionalContext semantics per
# the hooks-guide exit-code section, so a plain `cat` is the simplest
# correct primitive.
#
# Pattern surface (case-insensitive):
#   - moon (ci|run|exec|query|migrate)   (the documented subcommands)
#   - runInCI                            (the runInCI semantic axis)
#   - inheritedBy                        (the mandatory inheritance key)
#   - moon.yml                           (project-level config filename)
#   - task inheritance                   (the concept by name)
#   - github.event.before                (the zero-SHA trap)
#   - moonrepo                           (the brand)
#   - .moon/                             (the workspace directory)
#   - MOON_BASE / MOON_HEAD              (revision-comparison envs)
#
# Performance budget: <5ms on the no-match fast path (single grep -qiE).

set -u

fail_silent() { exit 0; }
trap fail_silent ERR

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
  PROMPT=$(printf '%s' "$INPUT" | jq -r '.prompt // empty' 2>/dev/null || true)
fi

[ -n "${PROMPT:-}" ] || exit 0

# Single regex hit-or-miss. POSIX-portable -- uses [[:space:]] not \b.
if ! printf '%s' "$PROMPT" | grep -qiE 'moon[[:space:]]+(ci|run|exec|query|migrate)|runInCI|inheritedBy|moon\.yml|task[[:space:]]+inheritance|github\.event\.before|moonrepo|\.moon/|MOON_BASE|MOON_HEAD'; then
  exit 0
fi

cat <<'EOF'
[ci-moonrepo] moonrepo topic detected in prompt.

Skill: ci-moonrepo:ci-moonrepo. Six production-failure-mode-anchored rules in
SKILL.md; comprehensive walkthrough in references/ci-guide.md (14 sections
covering moon ci end-to-end -- seven-step algorithm, runInCI semantics,
mandatory inheritedBy + tag-based CI lanes, explicit-target filtering rule,
revision comparison, affected-detection edges, parallelism, remote caching,
toolchain bootstrap strategies, reporting, v2.1 + v2.2 features, two worked
workflows, anti-patterns mapped to failure modes).

Load-bearing rules:
  - Every .moon/tasks/*.yml MUST declare 'inheritedBy:'. Tag-based CI lanes:
    ci-pull-request, ci-merge-develop, ci-merge-production. Toolchain-based
    developer commands via 'inheritedBy: { toolchains: [<name>] }'.
  - moon ci MUST receive explicit --base and --head (or MOON_BASE / MOON_HEAD).
    Never trust ${{ github.event.before }} -- it is empty / all-zero on new
    branches and first pushes.
  - runInCI: 'affected' is the right default for CI lanes. runInCI: true on a
    PR lane fires the task every PR regardless of touched files (almost
    always unwanted).
  - "Resolved targets: 0" on an obviously-changed diff is a propagation bug,
    not "nothing to do" -- check the task graph with `moon query projects
    --affected` and `moon query tasks --affected --json`.
EOF

exit 0
