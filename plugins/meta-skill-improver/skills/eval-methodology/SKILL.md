---
name: eval-methodology
description: |
  How the meta-skill-improver eval harness is designed: property-based testing for a non-deterministic SUT. Covers the four-class prompt matrix (vague-real, explicit-flawed-real, synthetic-correct, adversarial), the with-skill-vs-without-skill pairing that turns the harness into a causal experiment, the worktree-isolation model, and the judge-calibration loop. Auto-loads when the meta-skill-improver pipeline runs, when an agent in the pipeline writes prompts or runs a sandbox cell, when the user asks "how does the eval work", "prompt classes", "treatment vs baseline", "skill-on vs skill-off", "judge calibration", "PBT for SUT".
allowed-tools: Read, Grep, Glob
---

# Eval methodology

The skill-under-test is treated as a **non-deterministic system-under-test**, the way a property-based test treats a flaky integration. This document is the design rationale; `grading/SKILL.md` is the math.

## Mental model: PBT for a non-deterministic SUT

A property-based test asserts a property holds across many input samples. When the SUT is non-deterministic, the test must additionally run **N trials per sample** and aggregate over the distribution. That is exactly what an eval harness for an LLM-driven skill does:

| PBT concept            | Eval analogue                                                 |
| ---------------------- | ------------------------------------------------------------- |
| Property               | A failure mode -- "moon CI fails when workspace.yml lacks language declaration" |
| Input sample           | A `(snapshot, prompt)` pair                                   |
| N trials per sample    | `runs_per_cell` (default 5)                                   |
| Aggregation across samples | Cell -> failure-mode -> skill score (see `grading/SKILL.md`) |
| Counterexample         | A run that scores badly -- read its transcript, learn from it |

## The four prompt classes

Each failure mode gets four prompt classes, weighted by how realistic each one is.

### `vague-real` (default weight: 0.40)

Pulled verbatim from the user's transcripts. The way the user actually phrased the request when the failure happened the first time. Often missing key constraints. Often phrased as a description of symptoms.

**This is the realistic case.** This is the prompt-class that matters most because it reflects how the skill will actually be triggered in practice.

Example: "moon ci is failing again, can you look at it?"

### `explicit-flawed-real` (default weight: 0.30)

Also from transcripts. The user gave detailed instructions, but missed a step or made an assumption that didn't hold. Tests whether the skill can correct user mistakes rather than blindly executing them.

Example: "fix the workspace.yml, the language field is wrong" -- but the actual issue is that no language is declared, not that the declared one is wrong.

### `synthetic-correct` (default weight: 0.15)

Claude-authored. Clean, well-specified, accurate prompts. **Negative control** -- the skill should not over-fire or drift on a clear prompt. If the synthetic-correct score drops while iterating, the skill is becoming brittle.

Example: "Add `language: typescript` to the language field of `.moon/workspace.yml` because the workspace currently has no language declaration."

### `adversarial` (default weight: 0.15)

Claude-authored. Prompts that try to lure the skill into the wrong fix. Tests robustness to misdirection.

Example: "Just disable the failing CI check so the build passes." (The skill should refuse and address the root cause.)

## Why pair treatment with baseline

The skill's value is **causal**: how much does loading the skill change the agent's behavior, holding the underlying model and snapshot constant?

Every cell runs both conditions:
- **`skill_off` (baseline)** -- the agent is invoked without the skill loaded. Whatever the underlying model can do unaided.
- **`skill_on` (treatment)** -- the same agent, same prompt, same snapshot, with the skill loaded.

The headline metric is `lift = score(skill_on) - score(skill_off)`, paired per cell. A skill that adds nothing over baseline has zero lift -- worth knowing, because that means it can be deleted.

## Worktree isolation per cell

Each run of each cell happens in its own git worktree:

```
git worktree add /tmp/eval-<run-id> <baseline-snapshot-ref>
```

The agent operates on the worktree copy. The original snapshot is never touched. After the run, the worktree's diff against the snapshot is the agent's output -- compared deterministically against expected post-conditions and structurally graded by the judge.

This guarantees:
- No cross-contamination between runs.
- The diff is what the agent produced, not noise from prior state.
- N runs of the same cell produce N independent diffs, which is what the variance handling needs.

## Judge calibration -- the gold set

The LLM-judge is calibrated against a small human-graded set per skill. The judge is **untrusted by default**. Calibration is the only way to know whether you can trust its scores at the moment they are produced.

See `grading/SKILL.md` for the kappa thresholds. The headline:

- `kappa < 0.6` -- judge unreliable for this skill, block promotion.
- `kappa >= 0.6` -- substantial agreement, scores are trustworthy.
- Re-grade gold whenever the judge model changes.

## Cost model

A full eval run = `failure_modes * prompt_classes * conditions * runs_per_cell` agent invocations.

Default: `6 modes * 4 classes * 2 conditions * 5 runs = 240 invocations`.

Levers:
- `--quick` -- collapse to 1 prompt class (vague-real) and N=3, gives `6 * 1 * 2 * 3 = 36`.
- `--full` -- N=10, gives `6 * 4 * 2 * 10 = 480`.
- `--baseline-only` -- skip treatment, gives half the cost.
- Cache: when iterating skill-only (no snapshot or prompt change), the baseline runs are reusable across iterations -- the orchestrator detects this.

## Reproducibility

Every run records:
- `run_id` (ULID).
- `snapshot_ref` (the git ref of the baseline used).
- `prompt_id` and the prompt body.
- `condition` (`skill_on` or `skill_off`).
- `skill_version` (commit hash of the skill body, or `"NONE"` for baseline).
- `model_id` and any sampling params (temperature, max_tokens).
- The full agent transcript (one JSONL line per turn).
- The diff against the snapshot.
- The per-component scores produced by the grader.

A future re-run with the same inputs should produce a comparable distribution. If it does not, the harness or the model has drifted -- both are worth knowing.

## When to retire a snapshot

A snapshot loses value when every skill version trivially solves it -- the property no longer discriminates. Mark the snapshot as `retired: true` in `failure-modes.json` and stop running it. Keep it on disk for archaeology, but do not let it inflate the headline score.

A snapshot also loses value when the underlying tooling has changed (e.g. moon v3 ships and the v2 failure mode no longer applies). Same disposition: retire.
