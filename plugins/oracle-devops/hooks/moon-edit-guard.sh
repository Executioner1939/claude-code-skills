#!/usr/bin/env bash
# moon-edit-guard.sh -- PreToolUse hook on Edit|Write|MultiEdit.
#
# Inspects tool_input.file_path against moon-config patterns. Three tiers:
#
#   1. Hard deny (exit 2): top-level .moon/tasks.yml (singular). This file
#      is forbidden by Rule 2 step 0 of the ci-moonrepo skill -- moon v2
#      mandates per-file .moon/tasks/*.yml with explicit inheritedBy:.
#
#   2. Soft warn via additionalContext: writing a .moon/tasks/*.yml whose
#      proposed content lacks an 'inheritedBy:' block. The agent retains
#      autonomy; we just inject the rule.
#
#   3. Generic context pointer: any other moon-relevant edit (.moon/**,
#      */moon.yml, .prototools, rust-toolchain.toml). Reminds the agent
#      that the skill applies.
#
# Decision combination: per Anthropic docs, additionalContext from every
# matching hook is combined and passed to Claude together. The most
# restrictive permissionDecision wins. We emit additionalContext only
# (no permissionDecision) for tiers 2 and 3 so we never interfere with
# permission rules the user has configured.
#
# Performance budget: <5ms on the not-a-moon-file fast path.

set -u

fail_silent() { exit 0; }
trap fail_silent ERR

INPUT=$(cat)
command -v jq >/dev/null 2>&1 || fail_silent

TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
case "$TOOL_NAME" in
  Edit|Write|MultiEdit) : ;;
  *) fail_silent ;;
esac

FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -n "$FILE_PATH" ] || fail_silent

# Extract proposed content. Write -> .tool_input.content;
# Edit -> .tool_input.new_string; MultiEdit -> concatenation of edits[].new_string.
CONTENT=$(printf '%s' "$INPUT" | jq -r '
  .tool_input.content //
  .tool_input.new_string //
  ((.tool_input.edits // []) | map(.new_string // "") | join("\n")) //
  ""
' 2>/dev/null || echo "")

# ---- Tier 1: hard deny on top-level .moon/tasks.{yml,yaml} ----
case "$FILE_PATH" in
  */.moon/tasks.yml|*/.moon/tasks.yaml|.moon/tasks.yml|.moon/tasks.yaml)
    cat >&2 <<'EOF'
[ci-moonrepo] BLOCKED: .moon/tasks.{yml,yaml} (singular, top-level) is forbidden.

moon v2 mandates explicit inheritance via files under .moon/tasks/<name>.yml
that each declare an 'inheritedBy:' condition. The top-level tasks.yml
implicitly inherits into every project in the workspace and is the root
cause of three failure modes catalogued by the ci-moonrepo skill:

  - runInCI polarity flip on scalar merge (a global 'affected' + per-project
    true collapses silently to true because per-key merge strategies do not
    apply to scalars)
  - six-axis merge archaeology (mergeArgs/Deps/Env/Inputs/Outputs/Toolchains
    each default to append; tracing "where did this come from" becomes a
    six-file walk)
  - affected-detection graph drift (mergeDeps: 'replace' on a project that
    did not realise a ^:check edge was inherited silently breaks library
    -> service propagation)

Use one of:
  .moon/tasks/ci-pull-request.yml      (inheritedBy: { tags: [ci-pull-request] })
  .moon/tasks/ci-merge-develop.yml     (inheritedBy: { tags: [ci-merge-develop] })
  .moon/tasks/ci-merge-production.yml  (inheritedBy: { tags: [ci-merge-production] })
  .moon/tasks/<toolchain>-developer.yml (inheritedBy: { toolchains: [<toolchain>] })

Reference: references/workflows.md §2 (runInCI inheritance trap, "Inheritance discipline") and references/ci-guide.md §1 (full inheritance walkthrough).
EOF
    exit 2
    ;;
esac

# ---- Tier 2: soft warn on .moon/tasks/*.yml lacking inheritedBy: ----
case "$FILE_PATH" in
  */.moon/tasks/*.yml|*/.moon/tasks/*.yaml|.moon/tasks/*.yml|.moon/tasks/*.yaml)
    if [ -n "$CONTENT" ] && ! printf '%s' "$CONTENT" | grep -qE '^[[:space:]]*inheritedBy[[:space:]]*:'; then
      MSG="[ci-moonrepo] Editing $FILE_PATH: this file must begin with an 'inheritedBy:' block (see references/workflows.md §2 'Inheritance discipline' and references/ci-guide.md §1). Without it the tasks inherit into every project implicitly and trigger the runInCI polarity flip + six-axis merge archaeology + affected-detection graph drift failure modes. Tag-based pattern: 'inheritedBy: { tags: [ci-pull-request] }'. Toolchain-based pattern: 'inheritedBy: { toolchains: [rust] }'."
      jq -n --arg msg "$MSG" '{
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          additionalContext: $msg
        }
      }'
      exit 0
    fi
    ;;
esac

# ---- Tier 3: generic skill-pointer for any other moon-relevant edit ----
RELEVANT=0
case "$FILE_PATH" in
  */.moon/*|*/moon.yml|.moon/*|moon.yml) RELEVANT=1 ;;
  */.prototools|.prototools) RELEVANT=1 ;;
  */rust-toolchain.toml|rust-toolchain.toml) RELEVANT=1 ;;
esac
[ "$RELEVANT" -eq 0 ] && exit 0

MSG="[ci-moonrepo] Editing $FILE_PATH. Skill ci-moonrepo applies. Mandatory: tag-based explicit inheritance for .moon/tasks/**. Always pass --base/--head to moon ci. Symptom-keyed workflows in references/workflows.md; reference material in references/moon-cheatsheet.md; long-form walkthrough in references/ci-guide.md. Audit scripts available under scripts/ (audit-inheritance.sh, audit-toolchain.sh, audit-name-drift.sh, audit-bin-collisions.sh)."
jq -n --arg msg "$MSG" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    additionalContext: $msg
  }
}'

exit 0
