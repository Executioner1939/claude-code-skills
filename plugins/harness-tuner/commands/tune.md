---
description: Apply an approved change plan to the harness with per-category user confirmation. Hard rules baked in: never edits root CLAUDE.md or ~/.claude/; refuses changes that exceed the 200-line ceiling (CLAUDE.md) or 150-line ceiling (path-scoped rules); appends one line to .claude/CHANGELOG.md per applied change. Runs harness-applier (Sonnet 4.6, acceptEdits) which pre-validates the whole plan, asks the user per category (adds / removes / monorepo / specific / none), then applies in plan order. Pre-flight requires .claude/harness-tuner/plans/<latest>/plan.md from /plan. Invoke as `/harness-tuner:tune [<scope>] [--plan=<path>] [--dry-run]`.
argument-hint: "[<scope>] [--plan=<path>] [--dry-run]"
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(mkdir:*)
  - Bash(date:*)
  - Bash(pwd)
  - Bash(test:*)
  - Bash(echo:*)
  - Bash(find:*)
  - Bash(ls:*)
  - Bash(awk:*)
  - Bash(sed:*)
  - Bash(grep:*)
  - Bash(cut:*)
  - Bash(jq:*)
  - Bash(realpath:*)
  - Bash(cat:*)
  - Bash(touch:*)
  - Agent(harness-applier)
  - Edit
  - Write
model: claude-opus-4-7
---

# /harness-tuner:tune

The apply phase. Single dispatch -- the harness-applier runs the entire apply loop inside one Task call, asking the user per category and applying in plan order.

This command does NOT re-run the digest / audit / plan phases. If the user wants the full pipeline, they run the four commands in order: `/digest -> /audit -> /plan -> /tune`. This separation lets the user inspect each phase's output before continuing.

## Step 0 -- Resolve arguments and pre-flight

```!
set -e
ARGS=$(printf '%s' "$ARGUMENTS")

SCOPE=$(printf '%s' "$ARGS" | awk '{ for (i=1;i<=NF;i++) if ($i !~ /^--/) { print $i; exit } }')
case "$SCOPE" in '' | --*) SCOPE="$(pwd)";; esac
test -d "$SCOPE" || { echo "ABORT: scope $SCOPE is not a directory"; exit 0; }
SCOPE=$(cd "$SCOPE" && pwd)

PLAN_PATH=$(printf '%s' "$ARGS" | grep -oE -- '--plan=[^ ]+' | cut -d= -f2 || true)

PLANS_DIR="$SCOPE/.claude/harness-tuner/plans"
if [ -z "${PLAN_PATH:-}" ]; then
  if [ -d "$PLANS_DIR" ]; then
    LATEST=$(ls -1t "$PLANS_DIR" 2>/dev/null | head -1)
    if [ -n "${LATEST:-}" ]; then
      PLAN_PATH="$PLANS_DIR/$LATEST/plan.md"
    fi
  fi
fi

test -f "$PLAN_PATH" || { echo "ABORT: no plan.md found. Run /harness-tuner:plan first, or pass --plan=<path>."; exit 0; }

DRY_RUN="false"
case " $ARGS " in
  *" --dry-run "*) DRY_RUN="true";;
esac

CHANGELOG="$SCOPE/.claude/CHANGELOG.md"
mkdir -p "$(dirname "$CHANGELOG")"
[ -f "$CHANGELOG" ] || cat > "$CHANGELOG" <<EOF
# Harness CHANGELOG

> Maintained by harness-tuner. One line per applied change.
> Format: <ISO 8601> | <change-id> | <action> | <target> | <reason>

EOF

# Refuse if plan has unresolved decisions (a planner / user contract).
DECISIONS=$(awk '/^## 6\. Decisions required/,/^## 7\./' "$PLAN_PATH" | grep -E '^\s*-\s' | wc -l | tr -d ' ')
if [ "$DECISIONS" -gt 0 ]; then
  echo "WARNING: plan.md still has $DECISIONS items in 'Decisions required'. The applier will refuse to run."
  echo "         Edit $PLAN_PATH to resolve them, then re-run /harness-tuner:tune."
fi

TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)
RUN_ID="tune-${TIMESTAMP}"
HANDOFF_DIR="$SCOPE/.claude/harness-tuner/$RUN_ID/handoffs"
mkdir -p "$HANDOFF_DIR"

cat <<EOF
BOOTSTRAP_OK=1
SCOPE=$SCOPE
PLAN_PATH=$PLAN_PATH
DRY_RUN=$DRY_RUN
CHANGELOG=$CHANGELOG
DECISIONS_REMAINING=$DECISIONS
HANDOFF_DIR=$HANDOFF_DIR
RUN_ID=$RUN_ID
TIMESTAMP=$TIMESTAMP
EOF
```

If decisions are unresolved (count > 0), halt and instruct the user to resolve and re-run.

If `--dry-run`, the applier prints every action without writing. Surface this to chat: `DRY-RUN MODE: no files will be modified.`

## Step 1 -- Dispatch harness-applier

```
## goal
Apply the approved plan at <PLAN_PATH> to the harness. Pre-validate the entire plan; ask the user per category (all / adds / removes / monorepo / specific / none); apply in plan order; append to <CHANGELOG> per change; surface manual-review items without editing root CLAUDE.md or ~/.claude/; refuse changes that exceed ceilings or break @-imports.

## inputs
- scope: { type: path, value: <SCOPE> }
- plan_md: { type: path, value: <PLAN_PATH> }
- changelog_path: { type: path, value: <CHANGELOG> }
- dry_run: { type: bool, value: <DRY_RUN> }
- handoff_dir: { type: path, value: <HANDOFF_DIR> }

## context
- path: ${CLAUDE_PLUGIN_ROOT}/skills/harness-anatomy/SKILL.md
  why: artefact taxonomy; understanding what each target type is
  do_not_re_derive: true
- path: ${CLAUDE_PLUGIN_ROOT}/skills/claude-md-authoring/SKILL.md
  why: 200-line ceiling, 150-line ceiling for rules, never-edit-root
  do_not_re_derive: true
- path: ${CLAUDE_PLUGIN_ROOT}/skills/opus-4-7-prompting/SKILL.md
  why: prompting discipline (reversibility-gate, investigate-before-answering, avoid-over-engineering, commit-to-an-approach)
  do_not_re_derive: true

## constraints
must:
  - pre-validate the whole plan before applying anything
  - never edit <SCOPE>/CLAUDE.md or anything under ~/.claude/ (refuse with `would-edit-root`)
  - refuse a change that pushes any CLAUDE.md over 200 lines (continue with next change)
  - refuse a change that pushes any path-scoped rule over 150 lines
  - validate every @-import resolves before declaring a write done
  - append exactly one CHANGELOG line per applied change
  - confirm per category before applying (don't apply until user picks one)
  - apply changes in plan's apply order
  - for manual-review items, surface to chat with verbatim content for the user to paste
  - write a HANDOFF.md to <HANDOFF_DIR>/phase-01-harness-applier-to-tune.md and end your output with `HANDOFF: <abs path>`
must_not:
  - reorder changes or skip ones the user did not exclude
  - "improve" anything beyond what the plan specifies
  - retry-with-tweaks on a failed change (log + continue)
  - amend the CHANGELOG retroactively

## out_of_scope
- editing root CLAUDE.md
- editing ~/.claude/
- modifying the plan itself
- running new audits

## acceptance
- chat output prints applied / skipped / aborted counts per the system prompt's report block
- CHANGELOG has new lines for each applied change
- manual-review items surfaced to chat verbatim
- HANDOFF.md written; final line is `HANDOFF: <path>`

## output_format
chat_progress: one line per applied change ("[applied] C-NNN: <one-line>")
chat_final: complete report block per the harness-applier system prompt

## handoff
write_to: <HANDOFF_DIR>/phase-01-harness-applier-to-tune.md
final_line: HANDOFF: <absolute path>
```

## Step 2 -- Print summary

After harness-applier returns:

```
==========================================
  /harness-tuner:tune complete
==========================================
  scope:              <SCOPE>
  plan:               <PLAN_PATH>
  dry_run:            <DRY_RUN>

  changes applied:    <n>
  changes skipped:    <n>
  manual-review:      <n>  (surfaced for the user to paste manually)

  changelog:          <CHANGELOG>
  handoffs:           <HANDOFF_DIR>/

  next steps:
    1. Review .claude/CHANGELOG.md.
    2. Open a fresh Claude Code session to confirm the autoload chain
       loads the new content. Run /harness-tuner:digest again later to
       see if friction has dropped.
    3. For manual-review items, paste them into <SCOPE>/CLAUDE.md or
       ~/.claude/CLAUDE.md as you agree.
==========================================
```

If anything was skipped, list each skipped change with reason. If manual-review items exist, surface them prominently with their verbatim recommended content.

**Acceptance for the whole run:**

- harness-applier returned with HANDOFF and a report block.
- CHANGELOG has the right number of new lines (= applied count).
- No edit to root CLAUDE.md or ~/.claude/.
- Skipped / aborted changes have a documented reason.

## Whole-workflow constraints

- Never edits root CLAUDE.md or ~/.claude/.
- Pre-validates the entire plan before any write.
- Asks the user per category before applying.
- Refuses changes that violate the 200-line / 150-line ceilings.
- Refuses unresolved `@`-imports.
- CHANGELOG every applied change.
- Single dispatch (the applier loops internally).
