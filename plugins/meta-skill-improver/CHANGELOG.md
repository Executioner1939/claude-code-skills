# Changelog

All notable changes to `meta-skill-improver` are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the plugin adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Convention: every version bump touches this file in the same commit. New entries go at the top under `[Unreleased]`; on release, that section is renamed to the version + ISO date.

## [Unreleased]

## [0.1.3] - 2026-05-14

### Fixed

- Phases 0.5, 1, and 7 of `/meta-skill-improver:improve-skill` no longer crash the command preprocessor. The dependency-map build block, the post-mine validation block, and the `eval_score.py` invocation block were all `!`-prefixed (executed by the slash-command preprocessor at command-load time) but referenced `$REPO_ROOT`, `$EVALS_ROOT`, `$RUN_ID`, `$SKILL`, `$NEW_SKILL_VERSION`, and `$PREV_SCORECARD` — variables resolved only at orchestrator runtime by Phase 0. Each `!` fence runs in its own shell, so those vars expanded to the empty string and the python3 invocation aborted on a `/plugins/...` path that did not exist. Converted all three fences to plain code blocks; the orchestrator runs them via the Bash tool after the values are set. Phase 0's bootstrap block remains `!`-prefixed because that is where the variables are first produced.

## [0.1.2] - 2026-05-14

### Fixed

- Phase 4 of `/meta-skill-improver:improve-skill` no longer crashes the command preprocessor. The `git log` snippet that captures `SKILL_BODY_SHA` was previously written as a `!`-prefixed shell block containing literal `<host>` and `<name>` placeholders; zsh interpreted `<host>` as input redirection and aborted with `no such file or directory: host` before the command body ever reached the orchestrator. The block is now a plain documentation fence — the orchestrator runs it via the Bash tool after resolving the values.

## [0.1.1] - 2026-05-10

### Fixed

- Phase 0 of `/meta-skill-improver:improve-skill` now resolves `REPO_ROOT` from `git rev-parse --show-toplevel` of the cwd (requiring that toplevel to contain a `.claude-plugin/` directory). The previous derivation (`$CLAUDE_PLUGIN_ROOT/../..`) pointed at the user-scope plugin cache when the plugin was installed via `/plugin install` (rather than run via `--plugin-dir`), causing the orchestrator to attempt edits inside the cache instead of the user's working marketplace tree. `$CLAUDE_PLUGIN_ROOT/../..` is retained as a fallback for the development-mode case (in-tree plugin invoked via `--plugin-dir`). On total failure, the command aborts with cwd, git toplevel, and `CLAUDE_PLUGIN_ROOT` printed for diagnosis.

## [0.1.0] - 2026-05-10

### Added

- Initial release. Evidence-grounded skill evolution + grading harness.
- Slash command: `/meta-skill-improver:improve-skill <topic> --repos <paths> (--target <plugin:skill> | --new <plugin:skill>) [--quick|--full] [--dry-run] [--skip-mine] [--baseline-only]` -- 8-phase orchestrator (mine, snapshot, prompts, author / audit, run, judge, grade, verdict).
- Subagents (6):
  - `transcript-miner` -- multi-repo evidence mining across `~/.claude/projects/<sanitized-cwd>/*.jsonl` plus per-repo `git log`. Clusters incidents into discrete failure modes ranked by `frequency * severity * recency`.
  - `snapshot-builder` -- captures the minimum-reproducer filesystem fragment per failure mode, applies deterministic name-map anonymization, generates the deterministic post-condition Python function, gates on a three-check verification (reproduction, anonymization, realism).
  - `prompt-synthesizer` -- builds the four-class prompt matrix (`vague-real`, `explicit-flawed-real`, `synthetic-correct`, `adversarial`).
  - `skill-author` -- authors a new skill grounded in the clustered evidence, with every rule citing the failure mode it defends against.
  - `skill-auditor` -- diff-oriented revision against an existing skill, citing both failure modes and prior cell-level scorecard signals.
  - `sandbox-runner` -- drives a single `(snapshot, prompt, condition)` cell to N trials in worktree isolation; captures transcript, diff, turn count, post-condition result; computes deterministic component scores.
- Knowledge skills (3):
  - `grading` -- the math: PBT-for-non-deterministic-SUT framing, five-component weighted composite (`correctness`, `root_cause`, `no_regression`, `skill_attribution`, `efficiency`), bootstrap 95% CI, paired Wilcoxon signed-rank, Cliff's delta, Benjamini-Hochberg FDR for per-cell regressions, Cohen's kappa for LLM-judge calibration, five-gate promotion verdict (lift, no-regression, coverage, judge-calibration, baseline-stability).
  - `eval-methodology` -- the design: how the four prompt classes work, why pair treatment with baseline (causal lift), worktree isolation per cell, judge gold-set calibration, cost model and `--quick`/`--full` levers, retire-snapshot policy.
  - `snapshot-anonymization` -- the privacy rules: deterministic name-mapping (longest match first, case-preserving variants), what-to-scrub vs what-to-keep matrix, three-check verification gate, real-contents-with-aggressive-scrubbing default policy, blocked-handoff path when anonymization cannot preserve the failure.
- Pure deterministic grading library at `scripts/eval_score.py` (~970 lines). Stdlib + numpy core; soft imports of scipy (better Wilcoxon p-values for small N) and pyyaml (so config can live in YAML; JSON fallback works without). Smoke test at `scripts/test_eval_score.py` covers `PROMOTE-on-clean-lift`, `BLOCK-on-judge-drift` (anti-correlated gold set), and `BLOCK-on-insufficient-lift-vs-prior` (identical scorecard input) using synthetic fixtures.
- Templates: `grading.yaml` (default scoring config; per-skill override-able at `evals/<skill>/grading.yaml`), `failure-mode.schema.json` (JSON Schema for the `transcript-miner` output the rest of the pipeline consumes).
- README documenting plugin layout, the 8-phase pipeline, persisted artefacts at `evals/<skill>/`, and the four user-facing taste-knobs (component weights, prompt-class weights, runs-per-cell, minimum meaningful lift).
