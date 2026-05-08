---
description: Convert the latest audit into a concrete change plan. Dispatches the hierarchy-architect (Opus 4.7, effort xhigh) which decides WHERE each change lands (descendant hierarchy only -- never root), HOW it's phrased, WHAT to remove elsewhere, and WHEN to use @ imports. For monorepos, proposes per-service CLAUDE.md content with correctly resolved relative @ imports. Output at .claude/harness-tuner/plans/<timestamp>/plan.md. Pre-flight requires .claude/harness-tuner/audits/<latest>/audit.md from /audit. Invoke as `/harness-tuner:plan [<scope>] [--cwd=<path>] [--audit=<path>]`.
argument-hint: "[<scope>] [--cwd=<path>] [--audit=<path>]"
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
  - Agent(hierarchy-architect)
  - Write
model: claude-opus-4-7
---

# /harness-tuner:plan

Single-phase. The hierarchy-architect runs once; it ingests the audit and emits plan.md. Single-threaded by design (the architect is maintaining global coherence across all proposed changes).

## Step 0 -- Resolve arguments and pre-flight

```!
set -e
ARGS=$(printf '%s' "$ARGUMENTS")

SCOPE=$(printf '%s' "$ARGS" | awk '{ for (i=1;i<=NF;i++) if ($i !~ /^--/) { print $i; exit } }')
case "$SCOPE" in '' | --*) SCOPE="$(pwd)";; esac
test -d "$SCOPE" || { echo "ABORT: scope $SCOPE is not a directory"; exit 0; }
SCOPE=$(cd "$SCOPE" && pwd)

CWD=$(printf '%s' "$ARGS" | grep -oE -- '--cwd=[^ ]+' | cut -d= -f2 || true)
[ -z "${CWD:-}" ] && CWD="$SCOPE"
test -d "$CWD" || { echo "ABORT: cwd $CWD is not a directory"; exit 0; }
CWD=$(cd "$CWD" && pwd)

AUDIT_PATH=$(printf '%s' "$ARGS" | grep -oE -- '--audit=[^ ]+' | cut -d= -f2 || true)
AUDITS_DIR="$SCOPE/.claude/harness-tuner/audits"
if [ -z "${AUDIT_PATH:-}" ]; then
  if [ -d "$AUDITS_DIR" ]; then
    LATEST=$(ls -1t "$AUDITS_DIR" 2>/dev/null | head -1)
    if [ -n "${LATEST:-}" ]; then
      AUDIT_PATH="$AUDITS_DIR/$LATEST/audit.md"
    fi
  fi
fi

test -f "$AUDIT_PATH" || { echo "ABORT: no audit.md found. Run /harness-tuner:audit first, or pass --audit=<path>."; exit 0; }

AUDIT_DIR=$(dirname "$AUDIT_PATH")
GAP_JSON="$AUDIT_DIR/gap_findings.json"
BLOAT_JSON="$AUDIT_DIR/bloat_findings.json"
test -f "$GAP_JSON"   || { echo "ABORT: $GAP_JSON missing."; exit 0; }
test -f "$BLOAT_JSON" || { echo "ABORT: $BLOAT_JSON missing."; exit 0; }

# map.json + digest.md from the digest run; the audit_dir has them as siblings two levels up.
DIGESTS_DIR="$SCOPE/.claude/harness-tuner/digests"
DIGEST_LATEST=$(ls -1t "$DIGESTS_DIR" 2>/dev/null | head -1 || true)
if [ -n "${DIGEST_LATEST:-}" ]; then
  MAP_JSON="$DIGESTS_DIR/$DIGEST_LATEST/map.json"
  DIGEST_MD="$DIGESTS_DIR/$DIGEST_LATEST/digest.md"
fi

TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)
RUN_ID="plan-${TIMESTAMP}"
OUTDIR="$SCOPE/.claude/harness-tuner/plans/$TIMESTAMP"
HANDOFF_DIR="$SCOPE/.claude/harness-tuner/$RUN_ID/handoffs"
mkdir -p "$OUTDIR" "$HANDOFF_DIR"

cat <<EOF
BOOTSTRAP_OK=1
SCOPE=$SCOPE
CWD=$CWD
AUDIT_PATH=$AUDIT_PATH
GAP_JSON=$GAP_JSON
BLOAT_JSON=$BLOAT_JSON
MAP_JSON=${MAP_JSON:-(absent)}
DIGEST_MD=${DIGEST_MD:-(absent)}
OUTDIR=$OUTDIR
HANDOFF_DIR=$HANDOFF_DIR
RUN_ID=$RUN_ID
TIMESTAMP=$TIMESTAMP
EOF
```

## Step 1 -- Dispatch hierarchy-architect

```
## goal
Convert audit findings into a concrete change plan. For each gap and bloat finding, decide WHERE the change lands (NEVER root CLAUDE.md), HOW it is phrased, WHAT to remove elsewhere, and WHEN to use @ imports. For monorepo cases, propose per-service CLAUDE.md content with correctly-resolved relative @-imports. Emit plan.md.

## inputs
- scope: { type: path, value: <SCOPE> }
- cwd: { type: path, value: <CWD> }
- audit_md: { type: path, value: <AUDIT_PATH> }
- gap_findings_json: { type: path, value: <GAP_JSON> }
- bloat_findings_json: { type: path, value: <BLOAT_JSON> }
- map_json: { type: path?, value: <MAP_JSON or null> }
- digest_md: { type: path?, value: <DIGEST_MD or null> }
- output_path: { type: path, value: <OUTDIR>/plan.md }
- handoff_dir: { type: path, value: <HANDOFF_DIR> }

## context
- path: ${CLAUDE_PLUGIN_ROOT}/skills/harness-anatomy/SKILL.md
  why: artefact taxonomy, hierarchy semantics, @-import resolution
  do_not_re_derive: true
- path: ${CLAUDE_PLUGIN_ROOT}/skills/claude-md-authoring/SKILL.md
  why: 200-line ceiling, never-edit-root, positive framing, style mirroring, length thresholds
  do_not_re_derive: true
- path: ${CLAUDE_PLUGIN_ROOT}/skills/opus-4-7-prompting/SKILL.md
  why: snippet bank to reuse in proposed content
  do_not_re_derive: true

## constraints
must:
  - emit plan.md per the schema in your system prompt (7 sections)
  - validate every proposed change against the 200-line ceiling (CLAUDE.md) or 150-line ceiling (path-scoped rules)
  - validate every @-import resolves when computed relative to the target file
  - sequence apply order with removals before adds
  - cite every G-NN and B-NN in the proposed change's "Tied to" field
  - write only to <OUTDIR>/plan.md
  - write a HANDOFF.md to <HANDOFF_DIR>/phase-01-hierarchy-architect-to-plan.md and end your output with `HANDOFF: <abs path>`
must_not:
  - target root <SCOPE>/CLAUDE.md or ~/.claude/CLAUDE.md (use Manual-review section instead)
  - emit a change that pushes any file over its ceiling
  - emit a plan with unresolved @-imports
  - emit alternatives or "options" -- choose one target per change

## out_of_scope
- applying changes (the harness-applier does that)
- editing existing harness content (you author plan.md only)

## acceptance
- <OUTDIR>/plan.md exists with all 7 sections
- per-service CLAUDE.md proposals if applicable
- Manual-review section if any root or ~/.claude/ items exist
- Decisions required surfaced
- HANDOFF.md written; final line is `HANDOFF: <path>`

## output_format
chat_summary_block: as defined in the hierarchy-architect system prompt

## handoff
write_to: <HANDOFF_DIR>/phase-01-hierarchy-architect-to-plan.md
final_line: HANDOFF: <absolute path>
```

## Step 2 -- Verify and summarize

After the architect returns:

1. Confirm `<OUTDIR>/plan.md` exists.
2. Read its sections to count: additions, removals, manual-review items, decisions required.
3. If decisions required exist, list them prominently.

Print:

```
==========================================
  /harness-tuner:plan complete
==========================================
  scope:           <SCOPE>
  cwd:             <CWD>
  audit:           <AUDIT_PATH>

  artefacts:
    plan:          <OUTDIR>/plan.md

  changes proposed:
    additions:     <n>
    shrinks:       <n>
    removes:       <n>
    merges:        <n>
    restructures:  <n>
    reconciles:    <n>
    per-service CLAUDE.md: <n>

  manual-review items: <n>  (root CLAUDE.md / user-global; not auto-applied)
  decisions required:  <n>  (must resolve before /tune)

  next steps:
    1. Review plan.md.
    2. Resolve any "Decisions required" items.
    3. /harness-tuner:tune to apply with confirmation between phases.
       OR /harness-tuner:tune --plan=<OUTDIR>/plan.md to skip straight
       to apply.
==========================================
```

**Acceptance for the whole run:**

- `<OUTDIR>/plan.md` exists with all 7 sections.
- Architect's HANDOFF.md exists.
- Decisions required surfaced to chat.
- No proposed change targets root CLAUDE.md or ~/.claude/.

## Whole-workflow constraints

- Single agent, single dispatch.
- Read-only on the harness; only writes are plan.md and HANDOFF.
- The architect refuses any proposal that violates the never-edit-root rule or the 200-line ceiling.
