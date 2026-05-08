---
description: Read Claude Code session transcripts for the current project and emit a structured digest of recurring user friction, repeated tool failures, scope-creep patterns, uncodified workflows, and bloat signals. Anonymizes paths and secrets. Read-only. Output at .claude/harness-tuner/digests/<timestamp>/digest.md. Phase 1 of the /harness-tuner:tune pipeline; standalone-runnable. Invoke as `/harness-tuner:digest [<scope>] [--days=<n>] [--max-findings=<n>]`.
argument-hint: "[<scope>] [--days=<n>] [--max-findings=<n>]"
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
  - Bash(jq:*)
  - Bash(realpath:*)
  - Bash(cat:*)
  - Agent(transcript-digester)
  - Agent(harness-mapper)
  - Write
model: claude-opus-4-7
---

# /harness-tuner:digest

Two-phase workflow. The harness-mapper builds a configuration map (so the digester knows what's already codified). The transcript-digester reads transcripts, scores findings, anonymizes, and emits a digest. Both run **in parallel** (their inputs are independent); the workflow then writes the outputs.

## Step 0 -- Resolve arguments

```!
set -e
ARGS=$(printf '%s' "$ARGUMENTS")

# Parse positional scope (first non-flag token, defaults to pwd).
SCOPE=$(printf '%s' "$ARGS" | awk '{ for (i=1;i<=NF;i++) if ($i !~ /^--/) { print $i; exit } }')
case "$SCOPE" in '' | --*) SCOPE="$(pwd)";; esac
test -d "$SCOPE" || { echo "ABORT: scope $SCOPE is not a directory"; exit 0; }
SCOPE=$(cd "$SCOPE" && pwd)

# Days flag (default 30).
DAYS=$(printf '%s' "$ARGS" | grep -oE -- '--days=[0-9]+' | cut -d= -f2 || true)
[ -z "${DAYS:-}" ] && DAYS=30

# Max-findings flag (default 20).
MAX=$(printf '%s' "$ARGS" | grep -oE -- '--max-findings=[0-9]+' | cut -d= -f2 || true)
[ -z "${MAX:-}" ] && MAX=20

# Resolve probable transcript directory.
SANITIZED=$(printf '%s' "$SCOPE" | sed 's|/|-|g')
PROBABLE_TRANSCRIPT_DIR="$HOME/.claude/projects/$SANITIZED"
TRANSCRIPT_DIR=""
if [ -d "$PROBABLE_TRANSCRIPT_DIR" ]; then
  TRANSCRIPT_DIR="$PROBABLE_TRANSCRIPT_DIR"
fi

TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)
RUN_ID="digest-${TIMESTAMP}"
OUTDIR="$SCOPE/.claude/harness-tuner/digests/$TIMESTAMP"
HANDOFF_DIR="$SCOPE/.claude/harness-tuner/$RUN_ID/handoffs"
mkdir -p "$OUTDIR" "$HANDOFF_DIR"

cat <<EOF
BOOTSTRAP_OK=1
SCOPE=$SCOPE
DAYS=$DAYS
MAX=$MAX
TRANSCRIPT_DIR=${TRANSCRIPT_DIR:-(unknown -- digester will resolve)}
OUTDIR=$OUTDIR
HANDOFF_DIR=$HANDOFF_DIR
RUN_ID=$RUN_ID
TIMESTAMP=$TIMESTAMP
EOF
```

If the bootstrap output begins with `ABORT:`, halt and print the message verbatim.

## Step 1 -- Dispatch the two read-only agents in parallel

Use the Task tool to dispatch both agents in the **same response** so they run in parallel. Their inputs do not depend on each other.

### Envelope: harness-mapper

```
## goal
Walk the harness configuration at <SCOPE> and emit a structured map.json describing every CLAUDE.md, .claude/ artefact, skill, agent, command, hook, and setting at user-global, project root, descendant-directory, and per-service levels. Identify the autoload chain for cwd = <SCOPE>.

## inputs
- scope: { type: path, value: <SCOPE> }
- cwd: { type: path, value: <SCOPE> }
- handoff_dir: { type: path, value: <HANDOFF_DIR> }
- run_id: { type: string, value: <RUN_ID> }

## context
- path: ${CLAUDE_PLUGIN_ROOT}/skills/harness-anatomy/SKILL.md
  why: artefact taxonomy and detection signals; do not re-derive
  do_not_re_derive: true
- path: ${CLAUDE_PLUGIN_ROOT}/skills/claude-md-authoring/SKILL.md
  why: 200-line ceiling, hierarchy rules, path-scope semantics
  do_not_re_derive: true
- path: ${CLAUDE_PLUGIN_ROOT}/skills/opus-4-7-prompting/SKILL.md
  why: prompting discipline
  do_not_re_derive: true

## constraints
must:
  - emit JSON in the schema in your system prompt
  - cite path:line for every non-obvious detection
  - run independent reads in parallel
  - read-only: no Write, no Edit, no Agent
  - write a HANDOFF.md to <HANDOFF_DIR>/phase-01-harness-mapper-to-digest.md and end your output with `HANDOFF: <abs path>`
must_not:
  - propose changes (later phases do that)
  - skip ~/.claude/ artefacts (the user-global level matters for the audit)

## out_of_scope
- transcripts (the digester handles those)
- proposing edits

## acceptance
- a JSON code block matching the map schema
- Coverage notes paragraph after the JSON
- HANDOFF.md written; final line is `HANDOFF: <path>`

## output_format
markdown_sections:
  - "(JSON code block: the map)"
  - "Coverage notes"
  - "HANDOFF"

## handoff
write_to: <HANDOFF_DIR>/phase-01-harness-mapper-to-digest.md
final_line: HANDOFF: <absolute path>
```

### Envelope: transcript-digester

```
## goal
Read Claude Code session transcripts for the project at <SCOPE> over the last <DAYS> days, mine them for recurring patterns per the transcript-mining taxonomy, score, anonymize, and emit a structured digest.md (capped at <MAX> top findings).

## inputs
- scope: { type: path, value: <SCOPE> }
- transcript_dir: { type: path?, value: <TRANSCRIPT_DIR or null> }
- date_range_days: { type: int, value: <DAYS> }
- max_findings: { type: int, value: <MAX> }
- handoff_dir: { type: path, value: <HANDOFF_DIR> }
- run_id: { type: string, value: <RUN_ID> }

## context
- path: ${CLAUDE_PLUGIN_ROOT}/skills/transcript-mining/SKILL.md
  why: pattern taxonomy, scoring, anonymization, JSONL parsing
  do_not_re_derive: true
- path: ${CLAUDE_PLUGIN_ROOT}/skills/opus-4-7-prompting/SKILL.md
  why: prompting discipline
  do_not_re_derive: true

## constraints
must:
  - emit Markdown in the 6-section schema in your system prompt
  - anonymize paths, tokens, IPs, emails BEFORE they reach the digest
  - cite turn numbers for every excerpt
  - score every finding (recurrence x severity x recency)
  - stream-parse JSONL with bash + jq + sed (do not Read whole transcripts into context)
  - read-only: no Write, no Edit, no Agent
  - write a HANDOFF.md to <HANDOFF_DIR>/phase-01-transcript-digester-to-digest.md and end your output with `HANDOFF: <abs path>`
must_not:
  - invent excerpts; if you cannot cite, drop the finding
  - leak unanonymized content
  - exceed max_findings (cap with an honest tail)

## out_of_scope
- harness configuration (the mapper handles that)
- proposing edits

## acceptance
- a fenced markdown block: the digest with all 6 sections
- Coverage notes paragraph after the block
- HANDOFF.md written; final line is `HANDOFF: <path>`

## output_format
markdown_sections:
  - "(fenced markdown block: the digest)"
  - "Coverage notes"
  - "HANDOFF"

## handoff
write_to: <HANDOFF_DIR>/phase-01-transcript-digester-to-digest.md
final_line: HANDOFF: <absolute path>
```

Wait for both agents. If either fails or returns an empty HANDOFF, retry once with a tighter prompt; on second failure, log the failure and proceed with whichever returned (mark the missing artefact in the summary).

## Step 2 -- Synthesize and write outputs

Use the Write tool to produce two files:

1. `<OUTDIR>/map.json` -- the JSON from harness-mapper.
2. `<OUTDIR>/digest.md` -- the markdown from transcript-digester.

If transcript-digester surfaced "transcript directory not found", do NOT write `digest.md`; instead, write `<OUTDIR>/digest-missing.md` containing the agent's diagnostic about which paths it tried, so the user can pass `--transcript-dir=<path>` on a re-run.

## Step 3 -- Print summary

Print to chat:

```
==========================================
  /harness-tuner:digest complete
==========================================
  scope:           <SCOPE>
  days:            <DAYS>
  max_findings:    <MAX>
  transcript_dir:  <TRANSCRIPT_DIR or "(not found; see digest-missing.md)">

  artefacts:
    map:    <OUTDIR>/map.json
    digest: <OUTDIR>/digest.md  (or <OUTDIR>/digest-missing.md)

  handoffs: <HANDOFF_DIR>/

  next steps:
    1. Review the digest. Findings are sorted by score; the top items are
       highest-leverage to fix.
    2. /harness-tuner:audit <scope> (M2; not yet implemented) will combine
       the digest with the map to identify gaps, bloat, and hierarchy
       issues.
==========================================
```

If the agent surfaced any open questions (e.g., transcript-dir resolution ambiguity, services without CLAUDE.md), surface them prominently above the summary.

**Acceptance for the whole run:**

- `<OUTDIR>/map.json` exists and is valid JSON.
- `<OUTDIR>/digest.md` (or `digest-missing.md`) exists.
- HANDOFF.md exists for both dispatched agents under `<HANDOFF_DIR>/`.
- Open questions surfaced to chat.
- The summary block prints the resolved values.

## Whole-workflow constraints

- Read-only on the project tree, the harness, and the transcripts. The only writes are `map.json`, `digest.md` (or `digest-missing.md`), and the HANDOFF files.
- Both agents print `HANDOFF: <abs path>` as their final line. The orchestrator halts on missing handoffs.
- Both agents run in parallel (dispatch them in the same response).
- Anonymization is the digester's responsibility; the workflow does not re-process its output.
- Never edit root `./CLAUDE.md`. (This command does not edit anything in the harness; the constraint applies to subsequent /audit, /plan, /tune commands.)
