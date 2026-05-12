#!/usr/bin/env bash
# intercept-install.sh -- PreToolUse hook for the oracle plugin.
#
# Inspects the Bash tool's `command` field. Detects install/add subcommands
# across npm, pnpm, yarn, bun, cargo, pip, uv, poetry, brew, apt, apt-get,
# go, and gem. Distinguishes pinned from unpinned package args. When at
# least one unpinned package is detected, emits a non-blocking
# additionalContext reminder to verify the latest version via the
# package-manager CLI first, then firecrawl-search, then WebSearch.
#
# This hook does NOT block. The reminder is soft; the agent decides
# whether to verify before proceeding.

set -euo pipefail

# Fail-silent helpers. The hook must never break a session.
fail_silent() { exit 0; }
trap fail_silent ERR

INPUT=$(cat)
command -v jq >/dev/null 2>&1 || fail_silent

CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$CMD" ] && fail_silent

# Split the command into segments on standard shell separators so that
# `cd foo && npm install bar` is analysed as two segments rather than one.
SEGMENTS=$(printf '%s' "$CMD" | sed -E 's/(\|\||&&|;)/\n/g')

# Look up the canonical version-check CLI for a given package manager.
lookup_cli_for_pm() {
  case "$1" in
    npm|pnpm|yarn|bun) printf 'npm view <pkg> version' ;;
    cargo) printf 'cargo search <crate> --limit 1' ;;
    pip|uv-pip) printf 'pip index versions <pkg>' ;;
    uv) printf 'uv pip index versions <pkg>' ;;
    poetry) printf 'pip index versions <pkg>  # poetry uses the PyPI index' ;;
    brew) printf 'brew info --json=v2 <formula>' ;;
    apt|apt-get) printf 'apt-cache madison <pkg>' ;;
    go) printf 'go list -m -versions <module>' ;;
    gem) printf 'gem info -r <gem>' ;;
    *) printf 'unknown' ;;
  esac
}

# Detect whether a package arg is pinned. The pinning syntaxes covered:
#   npm/pnpm/yarn/bun:  pkg@1.2.3        (also @scope/pkg@1.2.3)
#   cargo:              crate@1.2.3
#   pip / uv:           pkg==1.2.3, pkg>=1.2.3, pkg<=1.2.3, pkg~=1.2.3, pkg!=1.2.3
#   apt / apt-get:      pkg=1.2.3
#   poetry:             pkg=1.2.3 or pkg@1.2.3
#   go:                 module@v1.2.3
#   gem:                pinned via --version flag (handled at segment level)
is_pinned() {
  local pkg="$1"
  case "$pkg" in
    *'=='*|*'>='*|*'<='*|*'~='*|*'!='*|*'>'*|*'<'*) return 0 ;;
    *'@'*)
      # Strip a leading @scope/ from npm-style scoped packages, then re-check.
      local without_scope="${pkg#@*/}"
      case "$without_scope" in
        *'@'*) return 0 ;;
      esac
      return 1
      ;;
    *'='*) return 0 ;;
  esac
  return 1
}

# Accumulate findings across segments.
report_lines=""
any_unpinned=0

process_segment() {
  local segment="$1"

  # Trim whitespace.
  segment=$(printf '%s' "$segment" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')
  [ -z "$segment" ] && return

  # Strip leading `sudo`, `env VAR=val`, etc., so that
  # `sudo apt-get install foo` is recognised as an apt-get install.
  while :; do
    case "$segment" in
      'sudo '*) segment="${segment#sudo }" ;;
      'env '*)
        # Drop `env` plus one VAR=val token at a time.
        segment="${segment#env }"
        # If the new leading token contains `=`, drop it; otherwise stop.
        case "$segment" in
          *' '*)
            local first="${segment%% *}"
            case "$first" in
              *'='*) segment="${segment#* }" ;;
              *) break ;;
            esac
            ;;
          *) break ;;
        esac
        ;;
      *) break ;;
    esac
  done

  # Tokenise. Bash word-splitting is good enough here; install commands
  # rarely contain quoted package names with spaces.
  # shellcheck disable=SC2206
  local tokens=( $segment )
  [ "${#tokens[@]}" -lt 2 ] && return

  local pm="" verb="" pkg_start=2

  case "${tokens[0]}" in
    npm|pnpm|yarn|bun)
      case "${tokens[1]}" in
        install|i|add) pm="${tokens[0]}"; verb="${tokens[1]}" ;;
      esac
      ;;
    cargo)
      case "${tokens[1]}" in
        add|install) pm="cargo"; verb="${tokens[1]}" ;;
      esac
      ;;
    pip|pip3)
      [ "${tokens[1]:-}" = "install" ] && { pm="pip"; verb="install"; }
      ;;
    uv)
      case "${tokens[1]:-}" in
        add) pm="uv"; verb="add" ;;
        pip)
          [ "${tokens[2]:-}" = "install" ] && { pm="uv-pip"; verb="install"; pkg_start=3; }
          ;;
      esac
      ;;
    poetry)
      [ "${tokens[1]:-}" = "add" ] && { pm="poetry"; verb="add"; }
      ;;
    brew)
      [ "${tokens[1]:-}" = "install" ] && { pm="brew"; verb="install"; }
      ;;
    apt|apt-get)
      [ "${tokens[1]:-}" = "install" ] && { pm="${tokens[0]}"; verb="install"; }
      ;;
    go)
      case "${tokens[1]:-}" in
        get|install) pm="go"; verb="${tokens[1]}" ;;
      esac
      ;;
    gem)
      [ "${tokens[1]:-}" = "install" ] && { pm="gem"; verb="install"; }
      ;;
  esac

  [ -z "$pm" ] && return

  # Walk the rest of the tokens, separating flags from package args.
  # Honor pin-by-flag (--version <ver>, --version=<ver>) and skip
  # manifest-driven installs (-r / --requirement / --requirements <file>).
  local pkgs=()
  local pin_via_flag=0
  local manifest_install=0
  local i="$pkg_start"
  while [ "$i" -lt "${#tokens[@]}" ]; do
    local arg="${tokens[$i]}"
    case "$arg" in
      -r|--requirement|--requirements)
        manifest_install=1
        i=$((i + 2))
        continue
        ;;
      --version|-v)
        # Next token is the pinned version. Treat all packages in this
        # segment as pinned.
        pin_via_flag=1
        i=$((i + 2))
        continue
        ;;
      --version=*)
        pin_via_flag=1
        ;;
      --frozen-lockfile|--locked|--from-lockfile|--no-save)
        # These do not pin a version, but neither do they constitute an
        # unpinned install in the sense we care about: they install from
        # a manifest that has already pinned things.
        manifest_install=1
        ;;
      # Long-form flags that take an argument (consume the next token).
      # Covers the common surface across npm/pnpm/yarn/bun, cargo, pip,
      # uv, poetry, brew, apt. Unknown long-form flags without `=` fall
      # through to the `-*` catch-all and may produce a spurious package
      # arg -- a soft-reminder false positive, not a correctness bug.
      --prefix|--cwd|--workspace|--registry|--tag|--omit|--include|--save-prefix|\
      --target|--target-dir|--manifest-path|--features|--bin|--example|--git|\
      --branch|--rev|--path|--root|--index|--index-url|--extra-index-url|\
      --find-links|--constraint|--no-binary|--only-binary|--platform|\
      --python-version|--implementation|--abi|--python|--source|--group|\
      --extras|--target-release|--option|--config-file)
        i=$((i + 2))
        continue
        ;;
      # Long-form flags with embedded value (--flag=val): the value is
      # bundled in the same token, so no extra consumption is needed.
      --*=*) : ;;
      # Short flags that take an argument. Only include those that are
      # unambiguous across the supported PMs.
      -w|-C|-t|-G|-E)
        i=$((i + 2))
        continue
        ;;
      -*) : ;;  # other flags, ignore
      *) pkgs+=("$arg") ;;
    esac
    i=$((i + 1))
  done

  # No package args -- manifest install. Skip.
  [ "${#pkgs[@]}" -eq 0 ] && return
  [ "$manifest_install" -eq 1 ] && return
  [ "$pin_via_flag" -eq 1 ] && return

  # Identify unpinned packages.
  local unpinned=()
  for pkg in "${pkgs[@]}"; do
    if ! is_pinned "$pkg"; then
      unpinned+=("$pkg")
    fi
  done

  [ "${#unpinned[@]}" -eq 0 ] && return

  local joined
  joined=$(IFS=,; printf '%s' "${unpinned[*]}")
  local cli
  cli=$(lookup_cli_for_pm "$pm")
  report_lines+="- ${pm} ${verb}: unpinned [${joined}]. Canonical CLI lookup: ${cli}. Fallback: firecrawl-search, then WebSearch."$'\n'
  any_unpinned=1
}

# Process each segment.
while IFS= read -r seg; do
  process_segment "$seg"
done <<< "$SEGMENTS"

[ "$any_unpinned" -eq 0 ] && exit 0

REMINDER="Oracle verification: this Bash call would install at least one unpinned package. Before running it, verify the latest version of each package via the verification cascade.

${report_lines}
This is a soft reminder. The tool call is not blocked. Decide deliberately. If a pinned version is intended, re-issue the command with an explicit version (for example, npm install pkg@1.2.3 or cargo add crate@1.2.3) and the reminder will not fire."

jq -n --arg c "$REMINDER" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    additionalContext: $c
  }
}'
