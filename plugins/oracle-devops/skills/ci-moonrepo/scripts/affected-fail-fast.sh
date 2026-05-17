#!/usr/bin/env bash
# affected-fail-fast.sh -- §1 fail-fast contract for moon CI lanes.
#
# If the git diff between MOON_BASE..MOON_HEAD is non-empty but
# `moon query projects --affected` returns zero affected projects, that
# is failure mode moon-affected-detection-misses-targets. moon ships no
# built-in --fail-on-no-affected flag as of 2.2.4; this script is the
# CI-wrapper enforcement.
#
# Drop this into a CI step immediately before `moon ci`.
#
# Exit codes:
#   0 -- diff is empty (nothing to do) OR diff is non-empty AND affected > 0
#   1 -- diff is non-empty AND affected == 0 (the failure mode)
#   2 -- usage / missing tool
#
# Required env: MOON_BASE, MOON_HEAD. Both should be real, non-empty,
# non-all-zero SHAs.

set -euo pipefail

ZERO_SHA="0000000000000000000000000000000000000000"

if [ -z "${MOON_BASE:-}" ] || [ -z "${MOON_HEAD:-}" ]; then
  echo "affected-fail-fast.sh: MOON_BASE and MOON_HEAD must both be set" >&2
  exit 2
fi

if [ "$MOON_BASE" = "$ZERO_SHA" ] || [ "$MOON_BASE" = "" ]; then
  echo "affected-fail-fast.sh: MOON_BASE is empty or all-zero SHA. This is the github.event.before trap." >&2
  echo "Use github.event.pull_request.base.sha on PRs, or guard against empty/zero on push." >&2
  exit 2
fi

if ! command -v moon >/dev/null 2>&1; then
  echo "affected-fail-fast.sh: moon not on PATH" >&2
  exit 2
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "affected-fail-fast.sh: jq not on PATH" >&2
  exit 2
fi

# Count changed files between base and head
changed=$(git diff --name-only "$MOON_BASE..$MOON_HEAD" 2>/dev/null | wc -l | tr -d ' ')

if [ "$changed" -eq 0 ]; then
  echo "affected-fail-fast.sh: no changed files between $MOON_BASE..$MOON_HEAD; nothing to do"
  exit 0
fi

# Count affected projects
affected_count=$(moon query projects --affected 2>/dev/null | jq '.projects | length')

if [ "$affected_count" -gt 0 ]; then
  echo "affected-fail-fast.sh: $changed changed file(s), $affected_count affected project(s) -- pass"
  exit 0
fi

cat >&2 <<EOF
affected-fail-fast.sh: FAIL

$changed file(s) changed between $MOON_BASE..$MOON_HEAD but moon resolved
zero affected projects. This is failure mode
'moon-affected-detection-misses-targets'.

Likely causes (check in order):
  1. fetch-depth: 0 missing on actions/checkout? moon needs full git
     history to diff base..head; without it, behaviour silently degrades.
  2. ^:check edges missing from build-release / deploy tasks? A library
     touch will not propagate to a service's tasks without the explicit
     task-graph edge.
  3. CI-written files polluting the working tree (gha-creds-*.json,
     .argocd-source-*.yaml)? moon diffs working tree, not git index.
  4. Inheritance broken at the workspace-config layer? Editing
     .moon/workspace.yml should mark every project affected.

Reproduce locally:
  moon query projects --affected --base $MOON_BASE --head $MOON_HEAD

See references/workflows.md §1.
EOF
exit 1
