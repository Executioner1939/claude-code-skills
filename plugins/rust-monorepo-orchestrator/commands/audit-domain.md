---
description: Drill one domain top-to-bottom (HTTP -> command -> events -> views -> interservice events) and emit a violations report plus a paired set of ast-grep rules (instance + generalized) that prevent the same mistakes recurring. Three-phase workflow with HANDOFF chain. The cartographer maps the chain (sequential), N violation-hunters drill each axis (parallel), the rule-author writes the YAML (sequential, after all hunters return). Read-only on the source tree; only writes are .refactor/domains/<domain>/violations.md, .refactor/rules/<domain>/*.yml, and sgconfig.yml. Invoke as `/rust-monorepo-orchestrator:audit-domain <domain> [--axes=<csv>] [--scope=<path>]`.
argument-hint: "<domain> [--axes=<csv>] [--scope=<path>]"
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
  - Bash(awk:*)
  - Bash(sed:*)
  - Bash(grep:*)
  - Bash(cut:*)
  - Bash(jq:*)
  - Bash(realpath:*)
  - Bash(cat:*)
  - Bash(find:*)
  - Agent(domain-cartographer)
  - Agent(violation-hunter)
  - Agent(rule-author)
  - Write
  - Edit
model: claude-opus-4-7
---

# /rust-monorepo-orchestrator:audit-domain

Three-phase workflow. The cartographer maps the chain (sequential, because subsequent agents need its output). The violation-hunters drill each axis (**parallel**, one dispatch per axis, all in the same response). The rule-author writes the YAML (sequential, after all hunters return).

The orchestration-protocol skill governs handoffs and the structured envelope. Agents auto-load the skills they need; do not restate methodology in your envelopes.

## Step 0 -- Resolve arguments

```!
set -e
ARGS=$(printf '%s' "$ARGUMENTS")

# Parse positional domain (first non-flag token).
DOMAIN=$(printf '%s' "$ARGS" | awk '{ for (i=1;i<=NF;i++) if ($i !~ /^--/) { print $i; exit } }')
test -n "$DOMAIN" || { echo "ABORT: domain is required. Usage: /rust-monorepo-orchestrator:audit-domain <domain> [--axes=<csv>] [--scope=<path>]"; exit 0; }

# Parse --scope flag (default cwd).
SCOPE=$(printf '%s' "$ARGS" | grep -oE -- '--scope=[^ ]+' | cut -d= -f2 || true)
[ -z "${SCOPE:-}" ] && SCOPE="$(pwd)"
test -d "$SCOPE" || { echo "ABORT: scope $SCOPE is not a directory"; exit 0; }
SCOPE=$(cd "$SCOPE" && pwd)

# Parse --axes flag (default: full set).
AXES=$(printf '%s' "$ARGS" | grep -oE -- '--axes=[^ ]+' | cut -d= -f2 || true)
[ -z "${AXES:-}" ] && AXES="http_layer,command_handlers,domain_events,decider_purity,views_projections,persistence_adapters,interservice_events,error_handling,dependency_direction,naming_consistency"

# Pre-flight: stack.json must exist (from /init).
STACK_JSON="$SCOPE/.refactor/stack.json"
test -f "$STACK_JSON" || { echo "ABORT: $STACK_JSON does not exist. Run /rust-monorepo-orchestrator:init first."; exit 0; }

# standard.md may or may not exist (only if /init --reference was used).
STANDARD_MD="$SCOPE/.refactor/standard.md"
HAS_STANDARD="false"
[ -f "$STANDARD_MD" ] && HAS_STANDARD="true"

TIMESTAMP=$(date -u +%Y%m%dT%H%M%SZ)
RUN_ID="audit-domain-${DOMAIN}-${TIMESTAMP}"
DOMAIN_DIR="$SCOPE/.refactor/domains/$DOMAIN"
RULES_DIR="$SCOPE/.refactor/rules/$DOMAIN"
HANDOFF_DIR="$SCOPE/.refactor/handoffs/$RUN_ID"
SGCONFIG="$SCOPE/sgconfig.yml"
mkdir -p "$DOMAIN_DIR" "$RULES_DIR" "$HANDOFF_DIR"

cat <<EOF
BOOTSTRAP_OK=1
DOMAIN=$DOMAIN
SCOPE=$SCOPE
AXES=$AXES
STACK_JSON=$STACK_JSON
STANDARD_MD=$STANDARD_MD
HAS_STANDARD=$HAS_STANDARD
DOMAIN_DIR=$DOMAIN_DIR
RULES_DIR=$RULES_DIR
HANDOFF_DIR=$HANDOFF_DIR
SGCONFIG=$SGCONFIG
RUN_ID=$RUN_ID
TIMESTAMP=$TIMESTAMP
EOF
```

If the bootstrap output begins with `ABORT:`, halt and print the message verbatim.

If `HAS_STANDARD=false`, print a one-line warning to chat and proceed: the violation-hunters will fall back to generic hexagonal heuristics. The audit will be less precise; suggest the user re-run `/init --reference=<path>` if they have one.

## Step 1 -- Dispatch domain-cartographer (sequential)

Use the Task tool to dispatch the `domain-cartographer` subagent with this envelope verbatim:

```
## goal
Trace the <DOMAIN> domain end-to-end through every hexagonal layer in <SCOPE> and emit a structured chain.md that subsequent violation-hunters use as their input.

## inputs
- scope: { type: path, value: <SCOPE> }
- domain: { type: string, value: <DOMAIN> }
- stack_json: { type: path, value: <STACK_JSON> }
- standard_md: { type: path?, value: <STANDARD_MD if HAS_STANDARD else null> }
- handoff_dir: { type: path, value: <HANDOFF_DIR> }

## context
- path: ${CLAUDE_PLUGIN_ROOT}/skills/orchestration-protocol/SKILL.md
  why: handoff contract; do not re-derive
  do_not_re_derive: true
- path: ${CLAUDE_PLUGIN_ROOT}/skills/opus-4-7-prompting/SKILL.md
  why: prompting discipline; do not re-derive
  do_not_re_derive: true
- path: <STACK_JSON>
  why: layer detection from /init
  do_not_re_derive: true

## constraints
must:
  - emit chain.md in the 11-section schema in your system prompt
  - cite path:line for every entry
  - run independent reads in parallel
  - read-only: no Write, no Edit, no Agent
  - write a HANDOFF.md to <HANDOFF_DIR>/phase-01-domain-cartographer-to-violation-hunters.md and end your output with `HANDOFF: <abs path>`
must_not:
  - bleed into adjacent domains
  - propose violations or fixes (later phases do that)

## out_of_scope
- violation hunting (the next phase does that)
- writing rules

## acceptance
- a fenced markdown block: chain.md with all 11 sections
- Coverage notes paragraph after the block
- HANDOFF.md written; final line is `HANDOFF: <path>`

## output_format
markdown_sections:
  - "(fenced markdown block: chain.md)"
  - "Coverage notes"
  - "HANDOFF"

## handoff
write_to: <HANDOFF_DIR>/phase-01-domain-cartographer-to-violation-hunters.md
final_line: HANDOFF: <absolute path>
```

When the agent returns:

1. Extract the fenced chain.md block.
2. Use the Write tool to save it at `<DOMAIN_DIR>/chain.md`.
3. If the agent surfaced Open questions, forward them to the user and pause for answers. Append the resolved answers to chain.md under a `## 12. Open questions (resolved)` section.

**Acceptance for Step 1:** `<DOMAIN_DIR>/chain.md` exists with all 11 sections and resolved Open questions.

## Step 2 -- Dispatch N violation-hunters in parallel

Parse `AXES` into a list. For each axis, dispatch a `violation-hunter` subagent with this envelope. **Send all the dispatches in the same response so they run in parallel.**

```
## goal
Hunt architectural violations in the <DOMAIN> domain on the <AXIS> axis. Read the chain.md produced by the cartographer and the standard.md (if present); find where actual code diverges from the standard's rules for this axis; emit a violations fragment.

## inputs
- scope: { type: path, value: <SCOPE> }
- domain: { type: string, value: <DOMAIN> }
- axis: { type: enum<...>, value: <AXIS> }
- chain_md: { type: path, value: <DOMAIN_DIR>/chain.md }
- standard_md: { type: path?, value: <STANDARD_MD if HAS_STANDARD else null> }
- handoff_dir: { type: path, value: <HANDOFF_DIR> }

## context
- path: ${CLAUDE_PLUGIN_ROOT}/skills/orchestration-protocol/SKILL.md
  why: handoff contract; do not re-derive
  do_not_re_derive: true
- path: ${CLAUDE_PLUGIN_ROOT}/skills/opus-4-7-prompting/SKILL.md
  why: prompting discipline (recall-first review)
  do_not_re_derive: true

## constraints
must:
  - apply the axis-specific checks defined in your system prompt
  - quote the standard rule for every finding (or note "(no rule; generic heuristic applied)" with a flag in Open questions)
  - cite path:line for every finding
  - mark every finding's pattern-eligibility flag
  - emit pattern signatures for the rule-author
  - run independent searches in parallel
  - read-only: no Write, no Edit, no Agent
  - write a HANDOFF.md to <HANDOFF_DIR>/phase-02-violation-hunter-<AXIS>-to-rule-author.md and end your output with `HANDOFF: <abs path>`
must_not:
  - drift into other axes (one axis per dispatch)
  - filter for severity (recall first; the user filters)

## out_of_scope
- writing rules
- proposing fixes beyond a one-line "suggested remediation"

## acceptance
- a fenced markdown block: violations fragment per the schema in your system prompt
- pattern signatures table populated for every pattern-eligible finding
- HANDOFF.md written; final line is `HANDOFF: <path>`

## output_format
markdown_sections:
  - "(fenced markdown block: violations fragment)"
  - "Coverage notes"
  - "HANDOFF"

## handoff
write_to: <HANDOFF_DIR>/phase-02-violation-hunter-<AXIS>-to-rule-author.md
final_line: HANDOFF: <absolute path>
```

Wait for ALL hunter dispatches to return. If any fails or returns empty, retry once with a tighter prompt; on second failure, log to `<HANDOFF_DIR>/_failures.log` and proceed with reduced coverage (note in the final report).

## Step 3 -- Synthesize violations.md

Aggregate the per-axis fragments into a single `violations.md`:

```markdown
# Violations: <domain>

> Audited at: <ISO 8601>
> Scope: <scope>
> Standard: <standard_md or "(none -- generic hexagonal heuristics applied)">
> Axes: <list>

## Summary
Headline counts: <total findings>, BLOCKING <n>, NEEDS-WORK <n>, NIT <n>, pattern-eligible <n>.

## Findings by axis

(... copy each fragment under a sub-heading named for its axis ...)

## Consolidated pattern signatures (for rule-author)

(... merge the per-axis pattern signature tables into one ...)

## Open questions

(... merge the per-axis Open questions ...)
```

Use the Write tool to save at `<DOMAIN_DIR>/violations.md`.

## Step 4 -- Dispatch rule-author (sequential)

Use the Task tool to dispatch the `rule-author` subagent:

```
## goal
Author paired (instance, generalized) ast-grep rules from violations.md. For every PATTERN-ELIGIBLE finding, emit one instance rule and one generalized rule. For non-pattern-eligible findings, emit only an instance rule. Validate every rule with a dry-run before committing. Update sgconfig.yml.

## inputs
- scope: { type: path, value: <SCOPE> }
- domain: { type: string, value: <DOMAIN> }
- violations_md: { type: path, value: <DOMAIN_DIR>/violations.md }
- standard_md: { type: path?, value: <STANDARD_MD if HAS_STANDARD else null> }
- output_dir: { type: path, value: <RULES_DIR> }
- sgconfig_path: { type: path, value: <SGCONFIG> }
- handoff_dir: { type: path, value: <HANDOFF_DIR> }

## context
- path: ${CLAUDE_PLUGIN_ROOT}/skills/astgrep-rule-authoring/SKILL.md
  why: YAML schema, pattern syntax, rule kinds, instance + generalized pair pattern
  do_not_re_derive: true
- path: ${CLAUDE_PLUGIN_ROOT}/skills/orchestration-protocol/SKILL.md
  why: handoff contract
  do_not_re_derive: true
- path: ${CLAUDE_PLUGIN_ROOT}/skills/opus-4-7-prompting/SKILL.md
  why: anti-over-engineering, anti-test-gaming, reversibility-gate
  do_not_re_derive: true

## constraints
must:
  - author paired rules for every pattern-eligible finding
  - validate every rule via dry-run (ast-grep scan --rule <file>)
  - cite the standard rule and the V-NN id in every authored rule's note:
  - merge-update sgconfig.yml idempotently
  - write only under .refactor/rules/<domain>/ and sgconfig.yml
  - write a HANDOFF.md to <HANDOFF_DIR>/phase-03-rule-author-to-audit-domain.md and end your output with `HANDOFF: <abs path>`
must_not:
  - overwrite or delete entries from other domains in sgconfig.yml
  - publish a rule that fails its dry-run validation
  - generalize beyond the immediate class

## out_of_scope
- editing source code
- proposing refactors

## acceptance
- one or two .yml files per pattern-eligible finding (or one for non-pattern-eligible)
- _manifest.md listing every rule with its V-NN id(s)
- sgconfig.yml updated to register the rules dir
- a chat-summary block per the schema in your system prompt
- HANDOFF.md written; final line is `HANDOFF: <path>`

## output_format
chat_summary_block: as defined in the rule-author system prompt

## handoff
write_to: <HANDOFF_DIR>/phase-03-rule-author-to-audit-domain.md
final_line: HANDOFF: <absolute path>
```

When the agent returns:

1. Read `<RULES_DIR>/_manifest.md` to confirm the rules were authored.
2. Read `<SGCONFIG>` to confirm the rules dir was registered.
3. If the agent reported any "open issues (rules I could not write cleanly)", forward them to the user verbatim.

**Acceptance for Step 4:** `<RULES_DIR>/*.yml` files exist, `_manifest.md` exists, `sgconfig.yml` registers the rules dir, every rule passes its own dry-run.

## Step 5 -- Synthesize summary

Print to chat:

```
==========================================
  /rust-monorepo-orchestrator:audit-domain complete
==========================================
  domain:     <DOMAIN>
  scope:      <SCOPE>
  axes:       <AXES>

  artefacts:
    chain:        <DOMAIN_DIR>/chain.md
    violations:   <DOMAIN_DIR>/violations.md
    rules dir:    <RULES_DIR>/
    manifest:     <RULES_DIR>/_manifest.md
    sgconfig:     <SGCONFIG>

  counts:
    findings:        <total>
      BLOCKING:      <n>
      NEEDS-WORK:    <n>
      NIT:           <n>
      pattern-elig:  <n>
    rules authored:
      instance:      <n>
      generalized:   <n>
      one-offs:      <n>

  handoffs:   <HANDOFF_DIR>/

  next steps:
    1. Review violations.md and the authored rules.
    2. Run `ast-grep scan -c sgconfig.yml --error` to confirm the rules
       reproduce the audit's findings.
    3. Run /rust-monorepo-orchestrator:plan-refactor <DOMAIN> to convert
       violations into a sequenced ticket DAG.
==========================================
```

If any agent surfaced Open questions, list them prominently above the summary.

**Acceptance for the whole run:**

- `<DOMAIN_DIR>/chain.md` exists.
- `<DOMAIN_DIR>/violations.md` exists with all sections.
- `<RULES_DIR>/*.yml` files exist (count >= number of pattern-eligible findings).
- `<SGCONFIG>` registers `.refactor/rules/<DOMAIN>`.
- HANDOFF.md exists for every dispatched agent under `<HANDOFF_DIR>/`.
- The summary block prints the resolved values.

## Whole-workflow constraints

- The cartographer is read-only. Hunters are read-only. The rule-author writes to `.refactor/rules/<domain>/` and `sgconfig.yml` only.
- All hunter dispatches in Step 2 run in parallel (same response).
- Every agent prints `HANDOFF: <abs path>` as its final line. The orchestrator halts on missing handoffs.
- No emojis in any artefact.
- Every claim in violations.md cites path:line.
- Every authored rule cites its V-NN and the standard rule it enforces.
