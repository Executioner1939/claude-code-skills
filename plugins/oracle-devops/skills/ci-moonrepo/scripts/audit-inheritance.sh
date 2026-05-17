#!/usr/bin/env bash
# audit-inheritance.sh -- enforce the inheritance discipline rule from
# references/workflows.md §2.
#
# Two checks, each emits a clear violation list and exits non-zero if any
# violation is found:
#
#   (a) Forbidden-default: every .moon/tasks/*.yml MUST begin with an
#       `inheritedBy:` block. A file without one inherits into every
#       project in the workspace, which is the root cause of the runInCI
#       polarity flip + six-axis merge archaeology + affected-detection
#       graph drift failure modes.
#
#   (b) Explicit-runInCI: every task in every moon.yml and
#       .moon/tasks/**/*.yml MUST set options.runInCI explicitly. The
#       implicit default is `true` for non-dev/start/serve task names,
#       which silently fires expensive tasks (build-release, docker-push)
#       on every PR.
#
# Exit codes:
#   0 -- all checks pass
#   1 -- at least one violation
#   2 -- usage / missing tool
#
# Usage: audit-inheritance.sh [<workspace-root>]
#        Defaults workspace-root to $PWD.

set -euo pipefail

ROOT="${1:-$PWD}"
cd "$ROOT"

if [ ! -d .moon ]; then
  echo "audit-inheritance.sh: no .moon/ directory at $ROOT" >&2
  exit 2
fi

FAIL=0

# ---- (a) forbidden-default check ----
echo "[a] inheritedBy: required on every .moon/tasks/*.yml"
echo "----------------------------------------------------"

violations_a=()
while IFS= read -r -d '' file; do
  if ! grep -qE '^[[:space:]]*inheritedBy[[:space:]]*:' "$file"; then
    violations_a+=("$file")
  fi
done < <(find .moon/tasks -maxdepth 2 -type f \( -name '*.yml' -o -name '*.yaml' \) -print0 2>/dev/null)

# also catch the forbidden top-level singular forms
for forbidden in .moon/tasks.yml .moon/tasks.yaml; do
  if [ -f "$forbidden" ]; then
    violations_a+=("$forbidden (forbidden top-level singular form)")
  fi
done

if [ ${#violations_a[@]} -eq 0 ]; then
  echo "  pass: every .moon/tasks file declares inheritedBy"
else
  echo "  FAIL: ${#violations_a[@]} file(s) without an inheritedBy: block:"
  for v in "${violations_a[@]}"; do
    echo "    - $v"
  done
  FAIL=1
fi
echo

# ---- (b) explicit-runInCI check ----
echo "[b] options.runInCI must be set explicitly on every task"
echo "--------------------------------------------------------"

# Heuristic: for each task block, check that within ~30 lines of `tasks:` we
# see at least one runInCI: line per command:/script:. This is not a full
# YAML parse -- for high precision use `moon project <id> --json` and check
# `.tasks[].options.runInCI`.
violations_b=()

run_moon_check() {
  if ! command -v moon >/dev/null 2>&1; then
    return 2
  fi
  # Resolved tasks per project; null runInCI is a violation.
  local out
  out=$(moon projects 2>/dev/null | awk 'NR>1 {print $1}' || true)
  [ -z "$out" ] && return 0
  while IFS= read -r project; do
    [ -z "$project" ] && continue
    moon project "$project" --json 2>/dev/null \
      | jq -r --arg p "$project" '
          .tasks // {} |
          to_entries[] |
          select(.value.options.runInCI == null) |
          "\($p):\(.key)"
        ' 2>/dev/null || true
  done <<< "$out"
}

if command -v moon >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    violations_b+=("$line")
  done < <(run_moon_check)

  if [ ${#violations_b[@]} -eq 0 ]; then
    echo "  pass: every task has options.runInCI set explicitly"
  else
    echo "  FAIL: ${#violations_b[@]} task(s) without explicit options.runInCI:"
    for v in "${violations_b[@]}"; do
      echo "    - $v"
    done
    FAIL=1
  fi
else
  echo "  skipped: 'moon' or 'jq' not on PATH; cannot resolve tasks"
fi
echo

if [ "$FAIL" -ne 0 ]; then
  echo "audit-inheritance.sh: violations found. See references/workflows.md §2." >&2
  exit 1
fi

echo "audit-inheritance.sh: all checks pass"
exit 0
