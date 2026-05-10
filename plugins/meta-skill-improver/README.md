# `meta-skill-improver` — evidence-grounded skill evolution

A plugin that turns recurring user friction across one or more repositories into a versioned, mathematically-graded skill, with an attached regression suite that proves the skill actually fixes the friction.

It is the skill that produces well-tested skills.

## What it does

Given an invocation like:

```
/meta-skill-improver:improve-skill "moon CI failures across hermes-platform, tictaps-platform, borg-platform -> ci-moonrepo skill"
```

The pipeline:

1. **Mines** transcripts and git history across the named repos, looking for recurring failure modes on the topic.
2. **Clusters** the findings into discrete failure modes ranked by `frequency * severity * recency`.
3. **Snapshots** each failure mode as an anonymized minimum-reproducer filesystem fragment under `evals/<skill>/snapshots/<mode-id>/`.
4. **Synthesizes** a four-class prompt matrix per failure mode (vague-real, explicit-flawed-real, synthetic-correct, adversarial).
5. **Authors or revises** the candidate skill, grounded in the mined evidence (every rule cites a failure mode it defends against).
6. **Runs the eval harness** — for each `(snapshot, prompt, condition)` cell it spawns a worktree-isolated agent run, with N trials per cell to handle agent non-determinism. Two conditions: skill-on (treatment) and skill-off (baseline).
7. **Grades** the runs with a pure deterministic library (`scripts/eval_score.py`) — no agent calls inside the grader.
8. **Decides** promote / block / iterate, with a promotion gate that requires a meaningful lift, no per-cell regressions under FDR control, no judge drift, and no coverage loss.

The output is a versioned skill plus a `evals/<skill>/scorecards/<version>.json` that future iterations replay against.

## Why it exists

Most skills are written from gut feeling, then quietly drift. This plugin makes skill quality measurable. The skill-under-test is treated as a non-deterministic system-under-test. The eval methodology is property-based testing with `N` runs per property and a paired Wilcoxon test for signal vs noise. See [`skills/grading/SKILL.md`](skills/grading/SKILL.md).

## Layout

```
meta-skill-improver/
  .claude-plugin/plugin.json
  commands/
    improve-skill.md            # the orchestrator
  agents/
    transcript-miner.md         # multi-repo transcript + git mining, emits clustered failure modes
    snapshot-builder.md         # captures + anonymizes minimum-reproducer trees
    prompt-synthesizer.md       # builds the four-class prompt matrix per failure mode
    skill-author.md             # produces a NEW skill from clustered evidence
    skill-auditor.md            # produces a DIFF against an existing skill from clustered evidence + scorecard
    sandbox-runner.md           # drives a single (snapshot, prompt, condition) cell to N runs in worktree isolation
  skills/
    grading/SKILL.md            # the grading spec -- read this first
    eval-methodology/SKILL.md   # PBT-for-non-deterministic-SUT framing, prompt classes, judge calibration
    snapshot-anonymization/SKILL.md  # rules for scrubbing identifiers out of fixtures
  scripts/
    eval_score.py               # pure (runs.jsonl, grading.yaml) -> scorecard.json
  templates/
    grading.yaml                # default scoring config (per-skill override-able)
    failure-mode.schema.json    # JSON Schema for the clustered findings
```

## Persisted artefacts (per skill under improvement)

```
evals/<skill-name>/
  grading.yaml             # weights, N, epsilon, q, kappa_min  -- overrides defaults
  failure-modes.json       # mined clusters: id, freq, severity, recency, citations, weight
  snapshots/<mode-id>/     # the anonymized fixture trees
  prompts/<mode-id>.jsonl  # the four-class prompt matrix
  postconds/<mode-id>.py   # deterministic post-condition graders (per-skill, per-mode)
  gold.jsonl               # human-graded calibration cells (the LLM-judge sanity set)
  runs/<run-id>/           # raw run artefacts: transcripts, file diffs, per-component scores
  scorecards/<version>.json   # aggregated per-version output -- the regression baseline
```

## Inputs the orchestrator accepts

```
/meta-skill-improver:improve-skill <topic> --repos <path>,<path>,... --target <plugin>:<skill> [options]

Options:
  --topic <quoted string>      What to mine for. Required.
  --repos <comma-list>         Absolute paths to repos to mine. At least one. Required.
  --target <plugin>:<skill>    Existing skill to revise. Mutually exclusive with --new.
  --new <plugin>:<skill>       New skill to author. Mutually exclusive with --target.
  --quick                      N=3 runs per cell, single prompt class. Cheap pass.
  --full                       N=10 runs per cell, all prompt classes. Expensive pass.
                               (Default: N=5, all prompt classes.)
  --dry-run                    Mine, snapshot, synthesize, but do NOT run the harness.
  --skip-mine                  Reuse evals/<skill>/failure-modes.json from a prior run.
  --baseline-only              Run only the without-skill condition (for fresh baselines).
```

## Building blocks composed from `_codify/`

This plugin reuses the proven pieces of `/codify`:

- The **invocation envelope** (goal/inputs/context/constraints/out_of_scope/acceptance/output_format) for every Task dispatch.
- The **HANDOFF.md contract** between agents in the chain (see `plugins/anvil/skills/_handoff/HANDOFF-template.md`).
- The **finding schema** from `transcript-analyzer.md` — extended with `severity`, `recency`, `frequency`, and a per-failure-mode cluster id.
- The **report shape** from `skill-author.md` and `skill-auditor.md` — extended with the post-condition section and the prompt-class brief.

What is new: snapshot-builder, prompt-synthesizer, sandbox-runner, the grading library, and the orchestrator wires it together.

## Stability

`v0.1.0` -- proof of concept. The grading methodology is stable; the orchestrator is the first surface likely to evolve as the marketplace gains more skills under improvement.
