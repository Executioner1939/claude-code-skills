---
description: |
  Evidence-grounded skill evolution. Mines Claude Code transcripts and git
  history across one or more repos for recurring user friction on a topic,
  clusters the friction into anonymized failure-mode reproducers,
  synthesizes a four-class prompt matrix per failure mode, runs the eval
  harness with and without the candidate skill loaded, and produces a
  mathematically-graded scorecard with a promote-or-block verdict. Treats
  the skill-under-test as a non-deterministic SUT and uses property-based
  testing with N runs per cell to separate signal from noise.
disable-model-invocation: true
argument-hint: <topic> --repos <path,...> (--target <plugin>:<skill> | --new <plugin>:<skill>) [--quick|--full] [--dry-run] [--skip-mine] [--baseline-only]
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash(mkdir:*)
  - Bash(date:*)
  - Bash(pwd)
  - Bash(test:*)
  - Bash(ls:*)
  - Bash(echo:*)
  - Bash(cat:*)
  - Bash(jq:*)
  - Bash(sed:*)
  - Bash(awk:*)
  - Bash(grep:*)
  - Bash(find:*)
  - Bash(touch:*)
  - Bash(basename:*)
  - Bash(dirname:*)
  - Bash(wc:*)
  - Bash(head:*)
  - Bash(tail:*)
  - Bash(sort:*)
  - Bash(printf:*)
  - Bash(tr:*)
  - Bash(xargs:*)
  - Bash(git:*)
  - Bash(realpath:*)
  - Bash(python3:*)
  - Bash(uuidgen:*)
  - Agent(transcript-miner)
  - Agent(snapshot-builder)
  - Agent(prompt-synthesizer)
  - Agent(skill-author)
  - Agent(skill-auditor)
  - Agent(sandbox-runner)
model: claude-opus-4-7
---

# /meta-skill-improver:improve-skill

You are running the meta-skill-improver pipeline. The user wants to improve (or author) a skill, grounded in evidence mined from their actual Claude Code sessions and git history across one or more repos.

You orchestrate a chain of agents and a deterministic Python grader. You do not author skill content yourself -- the `skill-author` and `skill-auditor` agents do.

## Phases at a glance

```
Phase 0  Bootstrap   parse args; create per-skill evals/ dir; resolve repos
Phase 1  Mine        transcript-miner -> failure-modes.json (one or many repos)
Phase 2  Snapshot    snapshot-builder per failure mode (parallel) -> snapshots/, postconds/
Phase 3  Prompts     prompt-synthesizer per failure mode (parallel) -> prompts/<id>.jsonl
Phase 4  Author      skill-author OR skill-auditor (one) -> revised skill body + version bump
Phase 5  Run         sandbox-runner per cell (parallel) -> runs/<run-id>/
Phase 6  Judge       LLM-judge batch over collected transcripts -> root_cause scores written back
Phase 7  Grade       python3 scripts/eval_score.py -> scorecards/<version>.json
Phase 8  Verdict     print scorecard summary; explain block reasons if blocked
```

If `--dry-run`: stop after Phase 4. If `--skip-mine`: jump to Phase 2 reading existing failure-modes.json. If `--baseline-only`: only run the skill_off condition in Phase 5.

## Phase 0 -- Bootstrap

Parse `$ARGUMENTS`. Required: `<topic>` (positional, quoted), `--repos <comma-separated absolute paths>`, and exactly one of `--target <plugin>:<skill>` or `--new <plugin>:<skill>`. Optional flags listed in the argument-hint.

```!
set -e

# Resolve REPO_ROOT. The user invokes /improve-skill from their working
# marketplace tree, which is git rev-parse --show-toplevel of cwd. We prefer
# that over CLAUDE_PLUGIN_ROOT, because for installed plugins
# CLAUDE_PLUGIN_ROOT points at the user-scope cache (e.g.
# ~/.claude/plugins/cache/skunkworks/meta-skill-improver/), not the working
# marketplace -- editing the cache would not affect the user's checkout.
#
# If cwd is not inside a git repo or that repo has no .claude-plugin/, we
# fall back to CLAUDE_PLUGIN_ROOT/../.. (development mode where the plugin
# lives in-tree at plugins/<plugin>/ and the user invokes from the
# marketplace root via --plugin-dir).

CWD_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [ -n "$CWD_ROOT" ] && test -d "$CWD_ROOT/.claude-plugin"; then
  REPO_ROOT="$CWD_ROOT"
elif [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && test -d "$CLAUDE_PLUGIN_ROOT/../../.claude-plugin"; then
  REPO_ROOT=$(cd "$CLAUDE_PLUGIN_ROOT/../.." && pwd)
else
  echo "ABORT: not inside a marketplace tree (no .claude-plugin/ found at git toplevel of cwd or CLAUDE_PLUGIN_ROOT/../..)"
  echo "  cwd:                $(pwd)"
  echo "  git toplevel:       ${CWD_ROOT:-<none>}"
  echo "  CLAUDE_PLUGIN_ROOT: ${CLAUDE_PLUGIN_ROOT:-<unset>}"
  echo ""
  echo "  Run /improve-skill from the marketplace repo you want to edit."
  exit 0
fi

# A run-id ULID-shaped enough.
RUN_ID=$(date +%Y%m%dT%H%M%S)-$(uuidgen 2>/dev/null | tr '[:upper:]' '[:lower:]' | head -c 6 || echo "rnd$$")
echo "RUN_ID=$RUN_ID"
echo "REPO_ROOT=$REPO_ROOT"
```

After running this preprocess, parse the user's `$ARGUMENTS` string yourself (you cannot rely on positional shell parsing here -- you do it):

1. Extract `<topic>` -- the first quoted segment, or up to the first `--`.
2. Extract `--repos <list>` -- split on comma, trim each, verify each path exists with `test -d <path>`.
3. Extract exactly one of `--target` or `--new`. If both or neither, abort with a usage message.
4. Apply flag defaults: N=5, quick -> N=3, full -> N=10. Record `IS_NEW = true|false`.

Resolve `SKILL = $TARGET || $NEW`. Split on `:` to get `(host_plugin, skill_name)`. Verify:
- For `--target`: `<repo_root>/plugins/<host_plugin>/skills/<skill_name>/SKILL.md` MUST exist.
- For `--new`: that path MUST NOT exist; the plugin dir MUST exist.

Compute paths:

```
EVALS_ROOT=$REPO_ROOT/evals/$host_plugin--$skill_name
HANDOFF_DIR=$EVALS_ROOT/_handoffs/$RUN_ID
mkdir -p $EVALS_ROOT/snapshots $EVALS_ROOT/postconds $EVALS_ROOT/prompts $EVALS_ROOT/runs/$RUN_ID $EVALS_ROOT/scorecards $HANDOFF_DIR
```

Write a copy of the default `templates/grading.yaml` to `$EVALS_ROOT/grading.yaml` if it does not exist (do not overwrite).

If a previous scorecard exists, find the most recent one in `$EVALS_ROOT/scorecards/*.json` (sort by mtime). Record its path as `PREV_SCORECARD`.

## Phase 0.5 -- Build the marketplace dependency map

The skill-author and skill-auditor agents need a structured view of every plugin / command / agent / skill in the marketplace, plus the list of existing skill names (for collision detection). Run this block via the Bash tool (it depends on `$REPO_ROOT` / `$EVALS_ROOT` resolved in Phase 0; preprocessing it at command-load time would fail):

```
DEP_MAP="$EVALS_ROOT/_dep-map.yaml"
EXISTING_SKILLS="$EVALS_ROOT/_existing-skills.txt"

cd "$REPO_ROOT"
{
  echo "# Generated by /improve-skill at $RUN_ID"
  echo "marketplace:"
  jq -r '"  name: " + .name + "\n  version: " + .metadata.version' .claude-plugin/marketplace.json
  echo "plugins:"
  for p in plugins/*/; do
    pname=$(basename "$p")
    test -f "$p/.claude-plugin/plugin.json" || continue
    pversion=$(jq -r '.version // "unknown"' "$p/.claude-plugin/plugin.json")
    echo "  - name: $pname"
    echo "    version: $pversion"
    echo "    path: $REPO_ROOT/$p"
    echo "    commands:"
    if test -d "$p/commands"; then
      for c in "$p"commands/*.md; do
        test -f "$c" || continue
        cname=$(basename "$c" .md)
        ahint=$(awk '/^---$/{f++; next} f==1' "$c" | grep -E '^argument-hint:' | head -1 | sed 's/argument-hint:[ ]*//')
        agents_used=$(awk '/^---$/{f++; next} f==1' "$c" | grep -oE 'Agent\([^)]+\)' | sed 's/Agent(//;s/)//' | sort -u | tr '\n' ',' | sed 's/,$//')
        echo "      - name: $cname"
        echo "        path: $REPO_ROOT/$c"
        test -n "$ahint" && echo "        argument_hint: $ahint"
        test -n "$agents_used" && echo "        invokes_agents: [$agents_used]"
      done
    fi
    echo "    agents:"
    if test -d "$p/agents"; then
      for a in "$p"agents/*.md; do
        test -f "$a" || continue
        aname=$(basename "$a" .md)
        skills_loaded=$(awk '/^skills:/{flag=1; next} flag && /^[^[:space:]-]/{flag=0} flag' "$a" | grep -E '^[ ]+-' | sed 's/^[ ]*-[ ]*//' | tr '\n' ',' | sed 's/,$//')
        echo "      - name: $aname"
        echo "        path: $REPO_ROOT/$a"
        test -n "$skills_loaded" && echo "        loads_skills: [$skills_loaded]"
      done
    fi
    echo "    skills:"
    if test -d "$p/skills"; then
      for s in "$p"skills/*/; do
        sname=$(basename "$s")
        case "$sname" in _*) continue;; esac
        test -f "$s/SKILL.md" || continue
        echo "      - name: $sname"
        echo "        path: $REPO_ROOT/$s/SKILL.md"
      done
    fi
  done
} > "$DEP_MAP"

{
  for d in plugins/*/skills/*/; do
    sname=$(basename "$d")
    case "$sname" in _*) continue;; esac
    pname=$(basename "$(dirname "$(dirname "$d")")")
    echo "$pname:$sname"
  done
  for f in plugins/*/commands/*.md; do
    test -f "$f" || continue
    cname=$(basename "$f" .md)
    pname=$(basename "$(dirname "$(dirname "$f")")")
    echo "$pname:$cname (command)"
  done
} | sort -u > "$EXISTING_SKILLS"

echo "DEP_MAP=$DEP_MAP"
echo "EXISTING_SKILLS=$EXISTING_SKILLS"
```

`$DEP_MAP` is the path skill-author and skill-auditor will consume as `dependency_map`; `$EXISTING_SKILLS` is what they consume as `existing_skills`. Cite them as literal paths in subsequent envelopes.

## Phase 1 -- Mine (skip if --skip-mine)

Dispatch `transcript-miner` (Agent tool, `subagent_type=transcript-miner`) with this envelope. Substitute literals.

```
## goal
Walk transcripts and git history across the named repos to identify recurring
user friction on the topic; cluster into discrete failure modes; emit a
structured failure-modes.json.

## inputs
- topic: { type: string, value: "<TOPIC>" }
- repos: { type: array<path>, value: [<REPOS>] }
- output_path: { type: path, value: <EVALS_ROOT>/failure-modes.json }
- target_skill: { type: string, value: "<SKILL>" }
- repo_root: { type: path, value: <REPO_ROOT> }
- handoff_path: { type: path, value: <HANDOFF_DIR>/phase-01-transcript-miner.md }
- lookback_days: { type: integer, value: 90 }

## constraints
must:
  - cite >= 1 transcript excerpt AND >= 1 commit per cluster (when both are available)
  - produce >= 2 incidents per cluster; single incidents go in git_only_findings or are dropped
  - rank clusters by frequency * severity * recency
must_not:
  - invent excerpts or SHAs
  - anonymize (snapshot-builder does that next phase)

## acceptance
- failure-modes.json validates against templates/failure-mode.schema.json
- handoff_path exists and announces with `HANDOFF: ...`
```

After it returns, validate by running via the Bash tool (orchestrator-runtime, not a `!`-preprocessed block):

```
test -f $EVALS_ROOT/failure-modes.json && jq empty $EVALS_ROOT/failure-modes.json
N_MODES=$(jq '.failure_modes | length' $EVALS_ROOT/failure-modes.json)
echo "N_MODES=$N_MODES"
```

If validation fails or `N_MODES = 0`, abort with a clear message ("no failure modes found; topic may not match transcript content").

## Phase 2 -- Snapshot (parallel, one dispatch per failure mode)

For each failure mode in `failure-modes.json`, dispatch a `snapshot-builder` agent. These can run in parallel (multiple Task calls in one assistant message).

Per dispatch envelope:

```
## goal
Capture and anonymize the minimum-reproducer filesystem fragment for failure
mode <id>; write the deterministic post-condition function.

## inputs
- failure_mode: { type: object, value: <copy verbatim from failure-modes.json> }
- repos: { type: array<path>, value: [<REPOS>] }
- snapshots_root: { type: path, value: <EVALS_ROOT>/snapshots/ }
- postconds_root: { type: path, value: <EVALS_ROOT>/postconds/ }
- name_map_path: { type: path, value: <EVALS_ROOT>/_name_map.json }
- handoff_path: { type: path, value: <HANDOFF_DIR>/phase-02-snapshot-<id>.md }

## constraints
must:
  - reproduction check passes (post-condition fails on baseline state)
  - anonymization check passes (zero hits for source identifiers)
  - realism check passes (random files still parse as their declared format)
must_not:
  - leak source-repo identifiers
  - skip the verification gate

## acceptance
- snapshots/<id>/baseline/ exists
- postconds/<id>.py exists and is importable
- handoff_path exists and announces success or blocked
```

After all dispatches return, count successful snapshots. If any failure mode produced a blocked handoff, log it but continue with the remaining modes.

## Phase 3 -- Prompts (parallel, one dispatch per failure mode)

Same parallelism shape. Per dispatch envelope:

```
## goal
Build the four-class prompt matrix for failure mode <id>.

## inputs
- failure_mode: { type: object, value: <verbatim from failure-modes.json> }
- snapshot_path: { type: path, value: <EVALS_ROOT>/snapshots/<id>/baseline/ }
- name_map_path: { type: path, value: <EVALS_ROOT>/_name_map.json }
- output_path: { type: path, value: <EVALS_ROOT>/prompts/<id>.jsonl }
- handoff_path: { type: path, value: <HANDOFF_DIR>/phase-03-prompts-<id>.md }
- target_count: { type: integer, value: 2 }   # per class; --quick collapses to 1

## constraints
must:
  - emit at least 1 prompt per class (4 classes total per failure mode)
  - vague-real and explicit-flawed-real are pulled verbatim from transcripts when available
  - prompts are self-contained (no conversational continuations)
  - apply the name-map; no source identifiers in prompts
must_not:
  - paraphrase real-class prompts
  - reference paths that do not exist in the snapshot

## acceptance
- prompts/<id>.jsonl exists with one JSON object per line
- 4 classes represented
```

## Phase 4 -- Author or audit the skill

Dispatch ONE of:

- `skill-author` (when `--new`)
- `skill-auditor` (when `--target`)

Envelope (skill-author variant):

```
## goal
Author a new skill body for <SKILL> grounded in the clustered failure modes.

## inputs
- failure_modes_path: { type: path, value: <EVALS_ROOT>/failure-modes.json }
- target_skill: { type: string, value: "<SKILL>" }
- repo_root: { type: path, value: <REPO_ROOT> }
- dependency_map: { type: path, value: <DEP_MAP from Phase 0.5> }
- existing_skills: { type: path, value: <EXISTING_SKILLS from Phase 0.5> }
- reference_paths: <plugin-dev:skill-development, plugin-structure, command-development; skill-creator:skill-creator>
- output_path: { type: path, value: <REPO_ROOT>/plugins/<host>/skills/<name>/SKILL.md }
- handoff_path: { type: path, value: <HANDOFF_DIR>/phase-04-skill-author.md }

## acceptance
- output_path exists; frontmatter parses as YAML
- every rule has a [failure-mode: <id>] anchor
- plugin and marketplace versions bumped (in sync)
```

Envelope (skill-auditor variant):

```
## goal
Revise <SKILL> grounded in the clustered failure modes and the previous scorecard.

## inputs
- failure_modes_path: { type: path, value: <EVALS_ROOT>/failure-modes.json }
- target_skill: { type: string, value: "<SKILL>" }
- target_skill_path: { type: path, value: <REPO_ROOT>/plugins/<host>/skills/<name>/SKILL.md }
- previous_scorecard_path: { type: path, value: <PREV_SCORECARD or null> }
- repo_root: { type: path, value: <REPO_ROOT> }
- dependency_map: { type: path, value: <DEP_MAP from Phase 0.5> }
- reference_paths: <as above, plus plugin-dev:agent-development>
- output_path: { type: path, value: <REPO_ROOT>/plugins/<host>/skills/<name>/SKILL.md }
- handoff_path: { type: path, value: <HANDOFF_DIR>/phase-04-skill-auditor.md }

## acceptance
- output_path updated; frontmatter parses
- every changed rule has [failure-mode: ...] AND [revised: ...] annotations
- plugin and marketplace versions bumped (in sync)
```

Capture `NEW_SKILL_VERSION` from the agent's HANDOFF. Capture `SKILL_BODY_SHA` by running (after substituting `<host>` and `<name>` with the resolved values) via the Bash tool, NOT as a `!`-prefixed preprocessed block:

```
git -C $REPO_ROOT log -n 1 --format=%H -- plugins/<host>/skills/<name>/SKILL.md
```

If `--dry-run`, stop here. Print: "Dry-run complete. Skill at $output_path; eval not run." Exit.

## Phase 5 -- Run the sandbox harness

Build the cell list. For each `(failure_mode, prompt, condition)`:

- `condition in {skill_on, skill_off}` (skill-only when `--baseline-only` flips this).
- `prompt` enumerated from `prompts/<id>.jsonl`.

Cell ID format: `<mode-id>--<class>--<prompt-index>--<condition>`.

Dispatch `sandbox-runner` per cell. These run in parallel (multiple Task calls per assistant message); the orchestrator does NOT need to serialize. Per dispatch envelope:

```
## goal
Run N trials of cell <cell-id> in worktree isolation.

## inputs
- cell_id: { type: string, value: "<cell-id>" }
- snapshot_path: { type: path, value: <EVALS_ROOT>/snapshots/<mode-id>/baseline/ }
- snapshot_ref: { type: string, value: <git-ref or null> }
- prompt: { type: object, value: <one JSON line from prompts/<mode-id>.jsonl> }
- condition: { type: string, value: "skill_on" | "skill_off" }
- skill_under_test: { type: string, value: "<SKILL>" }
- skill_version: { type: string, value: "<NEW_SKILL_VERSION>" }
- runs_per_cell: { type: integer, value: <N> }
- turns_budget: { type: integer, value: 40 }
- runs_root: { type: path, value: <EVALS_ROOT>/runs/<RUN_ID>/ }
- postcond_path: { type: path, value: <EVALS_ROOT>/postconds/<mode-id>.py }
- handoff_path: { type: path, value: <HANDOFF_DIR>/phase-05-run-<cell-id>.md }

## constraints
must:
  - run N trials in worktree isolation
  - capture transcript, diff, turn count, and post-condition result per trial
  - compute deterministic components per trial; mark needs_judge=true
must_not:
  - mutate the snapshot directory
  - score root_cause (judge does that in Phase 6)
```

After all return, collect every trial's transcript path into a judge-batch list.

## Phase 6 -- LLM-judge batch (root_cause)

For each trial transcript flagged `needs_judge`, evaluate the root_cause component. Use the Read tool to load the transcript JSONL and the diff, then a single Likert-1-to-5 judgment per trial. Apply the same rubric to every trial:

```
1 = the agent ignored the issue or made it worse
2 = the agent papered over the symptom (e.g., disabled a check)
3 = the agent partially addressed the root cause
4 = the agent fixed the root cause but with extraneous changes
5 = the agent fixed the root cause cleanly
```

Map to `[0, 1]` as `(score - 1) / 4` and write back to each trial's `components.json` under the `root_cause` key. Build a flat `runs.jsonl` from all trials' components into `<EVALS_ROOT>/runs/<RUN_ID>/runs.jsonl`.

Also re-grade `gold.jsonl` (if it exists) with the same rubric -- this is what the kappa calibration reads.

## Phase 7 -- Grade

Run via the Bash tool (orchestrator-runtime, not a `!`-preprocessed block — it depends on `$REPO_ROOT` / `$EVALS_ROOT` / `$RUN_ID` / `$SKILL` / `$NEW_SKILL_VERSION` / `$PREV_SCORECARD` resolved in earlier phases):

```
python3 $REPO_ROOT/plugins/meta-skill-improver/scripts/eval_score.py \
  --runs $EVALS_ROOT/runs/$RUN_ID/runs.jsonl \
  --config $EVALS_ROOT/grading.yaml \
  --failure-modes $EVALS_ROOT/failure-modes.json \
  --gold $EVALS_ROOT/gold.jsonl \
  --prev $PREV_SCORECARD \
  --skill "$SKILL" \
  --version "$NEW_SKILL_VERSION" \
  --out $EVALS_ROOT/scorecards/$NEW_SKILL_VERSION.json \
  --out-md $EVALS_ROOT/scorecards/$NEW_SKILL_VERSION.md
```

The script's exit code is `0` on PROMOTE, `1` on BLOCK. Capture both the JSON and the markdown.

If the script aborts with a missing-dep error (numpy / pyyaml), print the install line:

```
pip install --user numpy pyyaml scipy
```

and exit. Do not retry.

## Phase 8 -- Verdict

Read the markdown scorecard. Print the headline section and the verdict section verbatim. If BLOCK, also print every reason. Suggest next steps:

- `LiftBelowThreshold` -> the skill body did not produce enough lift; the skill-auditor should iterate.
- `CellRegression` -> a specific cell got worse; investigate that cell's transcript.
- `JudgeDrift` -> the LLM-judge has drifted; refresh the gold set or rewrite the prompts to be more concrete.
- `BaselineShift` -> the harness or snapshot state has changed; re-run the baseline before iterating.
- `CoverageRegression` -> the skill iteration removed snapshots; investigate why.

Print final summary, substituting literals:

```
============================================================
  /improve-skill complete
============================================================
  skill:    <SKILL>
  version:  <NEW_SKILL_VERSION>
  verdict:  <PROMOTE | BLOCK>
  lift:     <mean lift +/- delta>
  cells:    <count>
  runs:     <count>
  scorecard:
    json: <EVALS_ROOT>/scorecards/<NEW_SKILL_VERSION>.json
    md:   <EVALS_ROOT>/scorecards/<NEW_SKILL_VERSION>.md
============================================================
```

## Whole-workflow constraints

- Never run agents outside of git worktrees during Phase 5.
- Every Task dispatch uses the structured envelope above. No free-form prose prompts.
- Every agent in the chain MUST write a HANDOFF.md and announce with `HANDOFF: <path>`. If any agent skips the handoff, halt and surface the gap to the user.
- The orchestrator never edits skill bodies; the skill-author / skill-auditor agents do.
- The orchestrator never grades; `eval_score.py` does.
- Plugin and marketplace versions stay in sync at all times.
- No emojis in any output.
