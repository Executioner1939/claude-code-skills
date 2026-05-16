#!/usr/bin/env bash
# lint-moon-config.sh -- standalone deterministic linter for moonrepo configs.
#
# Invocation:
#   ./lint-moon-config.sh                  # lints $PWD
#   ./lint-moon-config.sh <workspace-root> # lints the given root
#
# Exit codes:
#   0  clean (no violations, or no .moon/ directory present)
#   1  script error (unreadable file, etc.)
#   2  one or more violations found (printed to stdout)
#
# Rules:
#
#   R1. No top-level .moon/tasks.yml or .moon/tasks.yaml (singular). moon v2
#       mandates per-file .moon/tasks/<name>.yml each with an explicit
#       'inheritedBy:' condition. The singular top-level file inherits
#       into every project implicitly and triggers the runInCI polarity
#       flip + six-axis merge archaeology failure modes.
#
#   R2. Every .moon/tasks/*.yml or .moon/tasks/*.yaml MUST declare an
#       'inheritedBy:' block at top level. Without it the file's tasks
#       inherit into every project implicitly (same root cause as R1).
#
#   R3. .moon/workspace.yml must use the canonical camelCase 'localReadOnly'
#       spelling under the remote: block (v1.40.0+,
#       https://moonrepo.dev/docs/config/workspace#localreadonly). Common
#       typos (localreadonly, local_read_only, LocalReadOnly) silently
#       fail to apply.
#
# These rules are derived from the ci-moonrepo skill's mandatory section
# (Rule 2 step 0) and the catalogued production failure modes. See
# plugins/ci-moonrepo/skills/ci-moonrepo/references/ci-guide.md sections
# 3 and 14.

set -eu

ROOT="${1:-${PWD:-$(pwd)}}"

if [ ! -d "$ROOT" ]; then
  printf 'lint-moon-config: %s is not a directory\n' "$ROOT" >&2
  exit 1
fi

if [ ! -d "$ROOT/.moon" ]; then
  printf 'lint-moon-config: no .moon/ directory at %s; nothing to lint\n' "$ROOT" >&2
  exit 0
fi

violations=0
emit() {
  printf 'VIOLATION (%s): %s\n' "$1" "$2"
  violations=$((violations + 1))
}

# ---- R1: no top-level .moon/tasks.{yml,yaml} ----
for f in "$ROOT/.moon/tasks.yml" "$ROOT/.moon/tasks.yaml"; do
  if [ -f "$f" ]; then
    emit R1 "$f is forbidden (top-level tasks.yml). Move tasks into .moon/tasks/<name>.yml with explicit 'inheritedBy:' blocks."
  fi
done

# ---- R2: every .moon/tasks/*.{yml,yaml} declares inheritedBy: ----
if [ -d "$ROOT/.moon/tasks" ]; then
  while IFS= read -r -d '' f; do
    if ! grep -qE '^[[:space:]]*inheritedBy[[:space:]]*:' "$f"; then
      rel="${f#"$ROOT"/}"
      emit R2 "$rel lacks an 'inheritedBy:' block. Add a tag-based ('inheritedBy: { tags: [...] }') or toolchain-based ('inheritedBy: { toolchains: [...] }') condition."
    fi
  done < <(find "$ROOT/.moon/tasks" -maxdepth 3 -type f \( -name '*.yml' -o -name '*.yaml' \) -print0)
fi

# ---- R3: workspace.yml uses canonical 'localReadOnly' spelling ----
ws=""
for cand in "$ROOT/.moon/workspace.yml" "$ROOT/.moon/workspace.yaml"; do
  [ -f "$cand" ] && ws="$cand" && break
done
if [ -n "$ws" ]; then
  # Find any case-or-snake variant that is NOT the canonical camelCase form.
  bad=$(grep -nE '(localreadonly|local_read_only|LocalReadOnly|LOCAL_READ_ONLY)' "$ws" || true)
  if [ -n "$bad" ]; then
    while IFS= read -r line; do
      [ -z "$line" ] && continue
      emit R3 "$ws uses non-canonical spelling: $line. Canonical: camelCase 'localReadOnly' (https://moonrepo.dev/docs/config/workspace#localreadonly)."
    done <<EOF
$bad
EOF
  fi
fi

if [ "$violations" -gt 0 ]; then
  printf '\nlint-moon-config: %d violation(s). See plugins/ci-moonrepo/skills/ci-moonrepo/references/ci-guide.md sections 3 + 14.\n' "$violations"
  exit 2
fi

printf 'lint-moon-config: clean (%s)\n' "$ROOT"
exit 0
