---
description: Audit the Claude harness against the most-recent transcript digest. Cross-references digest findings with the harness map to identify GAPS (recurring friction with no codified artefact addressing it) and BLOAT (oversized CLAUDE.md, redundant rules, ignored skills, hierarchy contradictions, dead references). Emits audit.md the /plan command consumes. Pre-flight requires .claude/harness-tuner/digests/<latest>/digest.md and map.json from /digest. Invoke as `/harness-tuner:audit [<scope>] [--digest=<path>]`.
argument-hint: "[<scope>] [--digest=<path>]"
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
  - Agent(gap-analyzer)
  - Agent(bloat-auditor)
  - Write
model: claude-opus-4-7
---

# /harness-tuner:audit

Two-phase. The gap-analyzer and bloat-auditor run in parallel (their inputs are independent: digest+map for gap; map for bloat). The workflow synthesizes audit.md from both outputs plus a hierarchy-chain analysis.

## Step 0 -- Resolve arguments and pre-flight

```!
set -e
ARGS=$(printf '%s' "$ARGUMENTS")

SCOPE=$(printf '%s' "$ARGS" | awk '{ for (i=1;i<=NF;i++) if ($i !~ /^--/) { print $i; exit } }')
case "$SCOPE" in '' | --*) SCOPE="$(pwd)";; esac
test -d "$SCOPE" || { echo "ABORT: scope $SCOPE is not a directory"; exit 0; }
SCOPE=$(cd "$SCOPE" && pwd)

# --digest path; otherwise pick the most-recent under .claude/harness-tuner/digests/.
DIGEST_PATH=$(printf '%s' "$ARGS" | grep -oE -- '--digest=[^ ]+' | cut -d= -f2 || true)

DIGESTS_DIR="$SCOPE/.claude/harness-tuner/digests"
if [ -z "${DIGEST_PATH:-}" ]; then
  if [ -d "$DIGESTS_DIR" ]; then
    LATEST=$(ls -1t "$DIGESTS_DIR" 2>/dev/null | head -1)
    if [ -n "${LATEST:-}" ]; then
      DIGEST_PATH="$DIGESTS_DIR/$LATEST/digest.md"
    fi
  fi
fi

test -f "$DIGEST_PATH" || { echo "ABORT: no digest.md found. Run /harness-tuner:digest first, or pass --digest=<path>."; exit 0; }

# map.json should be a sibling.
MAP_JSON=$(dirname "$DIGEST_PATH")/map.json
test -f "$MAP_JSON" || { echo "ABORT: $MAP_JSON missing. Re-run /harness-tuner:digest."; exit 0; }

TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)
RUN_ID="audit-${TIMESTAMP}"
OUTDIR="$SCOPE/.claude/harness-tuner/audits/$TIMESTAMP"
HANDOFF_DIR="$SCOPE/.claude/harness-tuner/$RUN_ID/handoffs"
mkdir -p "$OUTDIR" "$HANDOFF_DIR"

cat <<EOF
BOOTSTRAP_OK=1
SCOPE=$SCOPE
DIGEST_PATH=$DIGEST_PATH
MAP_JSON=$MAP_JSON
OUTDIR=$OUTDIR
HANDOFF_DIR=$HANDOFF_DIR
RUN_ID=$RUN_ID
TIMESTAMP=$TIMESTAMP
EOF
```

## Step 1 -- Dispatch gap-analyzer + bloat-auditor in parallel

Send both Task calls in the same response.

```
## goal
Cross-reference the transcript digest against the harness map. Identify GAPS: recurring user friction (high-score findings) that no current artefact addresses. Emit gap_findings.json.

## inputs
- scope: { type: path, value: <SCOPE> }
- digest_md: { type: path, value: <DIGEST_PATH> }
- map_json: { type: path, value: <MAP_JSON> }
- output_path: { type: path, value: <OUTDIR>/gap_findings.json }
- handoff_dir: { type: path, value: <HANDOFF_DIR> }

## context
- path: ${CLAUDE_PLUGIN_ROOT}/skills/harness-anatomy/SKILL.md
  why: artefact taxonomy and hierarchy semantics
  do_not_re_derive: true
- path: ${CLAUDE_PLUGIN_ROOT}/skills/claude-md-authoring/SKILL.md
  why: 200-line ceiling, hierarchy rules, the never-edit-root rule
  do_not_re_derive: true
- path: ${CLAUDE_PLUGIN_ROOT}/skills/opus-4-7-prompting/SKILL.md
  why: prompting discipline
  do_not_re_derive: true

## constraints
must:
  - emit JSON in the gap_findings schema in your system prompt
  - verify each "currently codified" claim from the digest by reading the map's referenced artefact
  - score every gap (inherit digest score, adjust per rules)
  - run independent reads in parallel
  - read-only: no Write, no Edit, no Agent
  - write a HANDOFF.md to <HANDOFF_DIR>/phase-01-gap-analyzer-to-audit.md and end your output with `HANDOFF: <abs path>`
must_not:
  - propose candidate_target.file as the root CLAUDE.md
  - skip low-score gaps (the architect filters)

## out_of_scope
- bloat findings (the bloat-auditor handles those)
- proposing exact remediation locations beyond candidate_target outline

## acceptance
- a JSON code block matching gap_findings schema
- Coverage notes paragraph after the JSON
- HANDOFF.md written; final line is `HANDOFF: <path>`

## output_format
markdown_sections:
  - "(JSON code block: gap_findings.json)"
  - "Coverage notes"
  - "HANDOFF"

## handoff
write_to: <HANDOFF_DIR>/phase-01-gap-analyzer-to-audit.md
final_line: HANDOFF: <absolute path>
```

(... and in parallel ...)

```
## goal
Audit the harness for BLOAT: CLAUDE.md over the 200-line ceiling, redundant rules with overlapping paths, ignored artefacts (skills/commands not triggered in transcripts), @-import overdraft, hierarchy contradictions, dead path-scoped globs, stale references. Emit bloat_findings.json.

## inputs
- scope: { type: path, value: <SCOPE> }
- map_json: { type: path, value: <MAP_JSON> }
- digest_md: { type: path, value: <DIGEST_PATH> }
- output_path: { type: path, value: <OUTDIR>/bloat_findings.json }
- handoff_dir: { type: path, value: <HANDOFF_DIR> }

## context
- path: ${CLAUDE_PLUGIN_ROOT}/skills/harness-anatomy/SKILL.md
  why: artefact taxonomy
  do_not_re_derive: true
- path: ${CLAUDE_PLUGIN_ROOT}/skills/claude-md-authoring/SKILL.md
  why: 200-line ceiling, the line litmus test
  do_not_re_derive: true
- path: ${CLAUDE_PLUGIN_ROOT}/skills/opus-4-7-prompting/SKILL.md
  why: prompting discipline
  do_not_re_derive: true

## constraints
must:
  - emit JSON in the bloat_findings schema in your system prompt
  - cite line counts, glob results, contradiction locations as evidence
  - run all 7 checks (B1-B7) in parallel where possible
  - read-only: no Write, no Edit, no Agent
  - write a HANDOFF.md to <HANDOFF_DIR>/phase-01-bloat-auditor-to-audit.md and end your output with `HANDOFF: <abs path>`
must_not:
  - propose actions on root CLAUDE.md (mark as manual-review for the user)
  - guess at line counts; read each file

## out_of_scope
- gap findings (the gap-analyzer handles those)
- proposing remediation specifics beyond proposed_action outline

## acceptance
- a JSON code block matching bloat_findings schema
- Coverage notes paragraph after the JSON
- HANDOFF.md written; final line is `HANDOFF: <path>`

## output_format
markdown_sections:
  - "(JSON code block: bloat_findings.json)"
  - "Coverage notes"
  - "HANDOFF"

## handoff
write_to: <HANDOFF_DIR>/phase-01-bloat-auditor-to-audit.md
final_line: HANDOFF: <absolute path>
```

Wait for both. Retry once on empty handoff; on second failure, log to `<HANDOFF_DIR>/_failures.log` and proceed with whichever returned.

## Step 2 -- Synthesize audit.md

Use the Write tool to create `<OUTDIR>/audit.md` with this shape:

```markdown
# Harness audit

> Project: <SCOPE>
> Digest read: <DIGEST_PATH>
> Map read: <MAP_JSON>
> Generated at: <ISO 8601>

## Summary

One paragraph: total findings (gaps + bloat); BLOCKING / NEEDS-WORK / NIT counts; the autoload-chain risks (any contradictions found by bloat-auditor).

## 1. Gaps (uncodified friction; sorted by score)

(... copy each gap from gap_findings.json under a sub-heading; keep the
gap_type tag visible ...)

## 2. Bloat (existing artefacts that need shrinking, merging, or removing)

(... copy each finding from bloat_findings.json under a sub-heading,
grouped by type: SHRINK, MERGE, REMOVE-OR-PROMOTE, RESTRUCTURE,
RECONCILE, DEAD, STALE-REFERENCE ...)

## 3. Hierarchy issues

For the cwd specified in map.json, list the autoload chain in load order
and flag any contradictions or gaps:

| Order | File | Loads when | Lines | Issues |
|---|---|---|---|---|

## 4. Manual-review items (root CLAUDE.md)

Things the audit identified that *should* change in root CLAUDE.md but
which the harness-applier will not edit. The user reviews these
manually.

## 5. Decisions required

Things the architect (M3) cannot decide alone. Examples:
- "Skill X has zero transcript hits AND no description match -- delete or promote?"
- "Two services have contradictory event-naming rules -- which is canonical?"

## 6. Counts

| Category | Count |
|---|---|
| Gaps total | <n> |
|   slash_command | <n> |
|   hook | <n> |
|   rule | <n> |
|   prompt_snippet | <n> |
|   skill | <n> |
|   claude_md_descendant | <n> |
|   command_routing | <n> |
|   agent_prompt | <n> |
| Bloat total | <n> |
|   SHRINK | <n> |
|   MERGE | <n> |
|   REMOVE-OR-PROMOTE | <n> |
|   RESTRUCTURE | <n> |
|   RECONCILE | <n> |
|   DEAD | <n> |
|   STALE-REFERENCE | <n> |
| Manual-review | <n> |
| Decisions required | <n> |
```

## Step 3 -- Print summary

```
==========================================
  /harness-tuner:audit complete
==========================================
  scope:           <SCOPE>
  digest:          <DIGEST_PATH>
  map:             <MAP_JSON>

  artefacts:
    audit:         <OUTDIR>/audit.md
    gap json:      <OUTDIR>/gap_findings.json
    bloat json:    <OUTDIR>/bloat_findings.json

  counts:
    gaps:          <n> (BLOCKING <n>, NEEDS-WORK <n>, NIT <n>)
    bloat:         <n> (BLOCKING <n>, NEEDS-WORK <n>, NIT <n>)
    manual-review: <n>
    decisions req: <n>

  handoffs:        <HANDOFF_DIR>/

  next steps:
    1. Review audit.md.
    2. Resolve any "Decisions required" items.
    3. /harness-tuner:plan to convert findings into a concrete change plan
       (the hierarchy-architect places each change in the right level of
       the hierarchy).
==========================================
```

If any "Decisions required" exist, list them prominently above the summary.

**Acceptance for the whole run:**

- `<OUTDIR>/audit.md` exists with all 6 sections.
- `<OUTDIR>/gap_findings.json` and `<OUTDIR>/bloat_findings.json` are valid JSON.
- HANDOFF.md exists for both dispatched agents.
- Decisions required surfaced to chat.

## Whole-workflow constraints

- Read-only on the harness, the digest, the map, the source tree. Only writes are audit.md, gap_findings.json, bloat_findings.json, and HANDOFF artefacts.
- Both agents run in parallel.
- Never proposes edits to root CLAUDE.md (manual-review only).
- All claims trace to either a digest F-NN or a map artefact path.
