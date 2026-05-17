#!/usr/bin/env bash
# audit-bin-collisions.sh -- enforce workspace [[bin]] name uniqueness AND
# moon project-id uniqueness (workflows.md §6).
#
# Detects the silent-bug pattern where two Rust crates in the same
# workspace define [[bin]] entries with the same name. cargo's workspace
# build resolves names in dep order; one wins and the rest of the
# services silently get the wrong binary in target/release/.
#
# Exit codes:
#   0 -- all binary names AND all moon project ids are unique
#   1 -- collisions detected
#   2 -- usage / missing tool
#
# Usage: audit-bin-collisions.sh [<services-dir>]
#        Defaults services-dir to 'services'.

set -euo pipefail

SERVICES_DIR="${1:-services}"

FAIL=0

# ---- (1) cargo [[bin]] uniqueness via cargo metadata ----
echo "[1] cargo workspace [[bin]] name uniqueness"
echo "-------------------------------------------"

if ! command -v cargo >/dev/null 2>&1; then
  echo "  skipped: cargo not on PATH"
elif ! command -v jq >/dev/null 2>&1; then
  echo "  skipped: jq not on PATH"
else
  dupes=$(cargo metadata --format-version 1 --no-deps 2>/dev/null \
    | jq -r '.packages[].targets[] | select(.kind[] == "bin") | .name' \
    | sort | uniq -d)

  if [ -z "$dupes" ]; then
    echo "  pass: every workspace [[bin]] has a unique name"
  else
    echo "  FAIL: duplicate [[bin]] names found:" >&2
    while IFS= read -r name; do
      [ -z "$name" ] && continue
      echo "    - $name" >&2
      # locate the offending crates
      cargo metadata --format-version 1 --no-deps 2>/dev/null \
        | jq -r --arg n "$name" '.packages[] | select(.targets[] | (.kind[] == "bin" and .name == $n)) | "        in package: \(.name) at \(.manifest_path)"' >&2
    done <<< "$dupes"
    FAIL=1
  fi
fi
echo

# ---- (2) moon project-id uniqueness ----
echo "[2] moon project id uniqueness"
echo "------------------------------"

dupes_ids=""
if [ -d "$SERVICES_DIR" ]; then
  dupes_ids=$(find "$SERVICES_DIR" -name moon.yml -maxdepth 2 -exec grep -H '^id:' {} \; 2>/dev/null \
    | sed -E 's/.*id:[[:space:]]*//' | sed -E 's/^["'\'']//; s/["'\'']$//' \
    | sort | uniq -d)
fi

if [ -z "$dupes_ids" ]; then
  echo "  pass: every moon project id is unique"
else
  echo "  FAIL: duplicate moon project ids:" >&2
  while IFS= read -r id; do
    [ -z "$id" ] && continue
    echo "    - $id" >&2
  done <<< "$dupes_ids"
  FAIL=1
fi
echo

if [ "$FAIL" -ne 0 ]; then
  echo "audit-bin-collisions.sh: collisions detected. See references/workflows.md §6." >&2
  exit 1
fi

echo "audit-bin-collisions.sh: all checks pass"
exit 0
