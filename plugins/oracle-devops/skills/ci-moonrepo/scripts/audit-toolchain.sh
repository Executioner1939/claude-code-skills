#!/usr/bin/env bash
# audit-toolchain.sh -- detect the active toolchain-bootstrap strategy and
# enforce single-source-of-truth (workflows.md §4).
#
# Identifies which of the three strategies the repo is on:
#   A -- Manual rustup (moonrepo/setup-rust or dtolnay/rust-toolchain)
#   B -- Proto auto-install (.prototools)
#   C -- moon v2 native (.moon/toolchains.yml)
#
# Fails when:
#   - More than one of {.prototools, .moon/toolchains.yml, rust-toolchain.toml}
#     has a Rust pin AND the pins disagree
#   - MOON_SKIP_SETUP_RUST appears anywhere (silently ignored by moon)
#   - MOON_TOOLCHAIN_FORCE_GLOBALS=<tool-name> (must be true/1 -- parses as
#     boolean; tool name = falsy)
#
# Exit codes:
#   0 -- single coherent strategy; no traps
#   1 -- multi-source drift or known-bug env var detected
#   2 -- usage / no Rust toolchain at all
#
# Usage: audit-toolchain.sh [<workspace-root>]

set -euo pipefail

ROOT="${1:-$PWD}"
cd "$ROOT"

FAIL=0
echo "audit-toolchain.sh: scanning $ROOT"
echo

# ---- Detection ----
STRATEGY_A=0
if grep -lr 'setup-rust\|dtolnay/rust-toolchain' .github/workflows/ 2>/dev/null | head -1 >/dev/null; then
  STRATEGY_A=1
fi

PROTOTOOLS_PIN=""
if [ -f .prototools ]; then
  PROTOTOOLS_PIN=$(grep -E '^[[:space:]]*rust[[:space:]]*=' .prototools 2>/dev/null | head -1 | sed -E 's/.*=[[:space:]]*"?([^"]*)"?.*/\1/')
fi

TOOLCHAINS_PIN=""
if [ -f .moon/toolchains.yml ]; then
  TOOLCHAINS_PIN=$(awk '/^rust:/{in_rust=1; next} /^[a-z]/ && !/^rust:/{in_rust=0} in_rust && /^[[:space:]]+version:/{
    sub(/^[[:space:]]+version:[[:space:]]*/, "")
    gsub(/["'\'']/, "")
    print
    exit
  }' .moon/toolchains.yml 2>/dev/null)
fi

RUST_TOOLCHAIN_PIN=""
if [ -f rust-toolchain.toml ]; then
  RUST_TOOLCHAIN_PIN=$(awk '/^\[toolchain\]/{in_t=1; next} /^\[/ && !/^\[toolchain\]/{in_t=0} in_t && /^[[:space:]]*channel/{
    sub(/^[[:space:]]*channel[[:space:]]*=[[:space:]]*/, "")
    gsub(/["'\'']/, "")
    print
    exit
  }' rust-toolchain.toml 2>/dev/null)
fi

echo "Detected pins:"
echo "  setup-rust / dtolnay in workflows : $STRATEGY_A"
echo "  .prototools rust                  : ${PROTOTOOLS_PIN:-<none>}"
echo "  .moon/toolchains.yml rust.version : ${TOOLCHAINS_PIN:-<none>}"
echo "  rust-toolchain.toml channel       : ${RUST_TOOLCHAIN_PIN:-<none>}"
echo

# ---- Multi-source drift check ----
declare -a pins
declare -a where
[ -n "$PROTOTOOLS_PIN" ] && { pins+=("$PROTOTOOLS_PIN"); where+=(".prototools"); }
[ -n "$TOOLCHAINS_PIN" ] && { pins+=("$TOOLCHAINS_PIN"); where+=(".moon/toolchains.yml"); }
[ -n "$RUST_TOOLCHAIN_PIN" ] && { pins+=("$RUST_TOOLCHAIN_PIN"); where+=("rust-toolchain.toml"); }

if [ ${#pins[@]} -eq 0 ]; then
  echo "audit-toolchain.sh: no Rust pin found in any source. Probably not a Rust repo." >&2
  exit 2
fi

if [ ${#pins[@]} -gt 1 ]; then
  unique=$(printf '%s\n' "${pins[@]}" | sort -u | wc -l | tr -d ' ')
  if [ "$unique" -gt 1 ]; then
    echo "FAIL: Rust pin disagreement across ${#pins[@]} sources:" >&2
    for i in "${!pins[@]}"; do
      echo "  - ${where[$i]} = ${pins[$i]}" >&2
    done
    echo "Pick one source of truth. See references/workflows.md §4." >&2
    FAIL=1
  else
    echo "INFO: ${#pins[@]} sources agree on ${pins[0]}. Consider removing duplicates."
  fi
fi

# ---- MOON_SKIP_SETUP_RUST scan (silently ignored) ----
if grep -rE 'MOON_SKIP_SETUP_RUST' .github/workflows/ 2>/dev/null | head -1 >/dev/null; then
  echo
  echo "FAIL: MOON_SKIP_SETUP_RUST is NOT a real env var; it is silently ignored." >&2
  grep -rEn 'MOON_SKIP_SETUP_RUST' .github/workflows/ 2>/dev/null | head -10 >&2 || true
  echo "Use MOON_SKIP_SETUP_TOOLCHAIN=rust instead." >&2
  FAIL=1
fi

# ---- MOON_TOOLCHAIN_FORCE_GLOBALS=<tool-name> (parses as falsy) ----
if grep -rE 'MOON_TOOLCHAIN_FORCE_GLOBALS[[:space:]]*[:=][[:space:]]*("?(rust|node|deno|bun|python|go)"?)' .github/workflows/ 2>/dev/null | head -1 >/dev/null; then
  echo
  echo "FAIL: MOON_TOOLCHAIN_FORCE_GLOBALS=<tool-name> is wrong. Parsed as boolean (as_bool); a tool name parses as falsy." >&2
  grep -rEn 'MOON_TOOLCHAIN_FORCE_GLOBALS' .github/workflows/ 2>/dev/null | head -10 >&2 || true
  echo "Use MOON_TOOLCHAIN_FORCE_GLOBALS=true (or 1) instead." >&2
  FAIL=1
fi

# ---- Strategy summary ----
echo
if [ -n "$PROTOTOOLS_PIN" ] && [ "$STRATEGY_A" -eq 0 ] && [ -z "$TOOLCHAINS_PIN" ]; then
  echo "Strategy: B (proto auto-install)"
elif [ -n "$TOOLCHAINS_PIN" ] && [ "$STRATEGY_A" -eq 0 ] && [ -z "$PROTOTOOLS_PIN" ]; then
  echo "Strategy: C (moon v2 native)"
elif [ "$STRATEGY_A" -eq 1 ]; then
  echo "Strategy: A (manual rustup before moon)"
else
  echo "Strategy: indeterminate -- multiple sources active"
fi

if [ "$FAIL" -ne 0 ]; then
  exit 1
fi
exit 0
