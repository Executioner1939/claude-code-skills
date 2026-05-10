---
name: grading
description: |
  The mathematically rigorous grading framework for skill evaluation. Defines per-run score components, aggregation up the cell -> failure-mode -> skill hierarchy, the treatment-effect (lift) measurement, the promotion gate, and the LLM-judge calibration loop. Auto-loads when the meta-skill-improver pipeline runs, when an agent in the pipeline writes a scorecard, when the user asks "how is this skill graded", "promotion gate", "lift", "judge calibration", "scorecard", or "eval methodology".
allowed-tools: Read, Grep, Glob
---

# Grading -- the contract

The skill-under-test is a **non-deterministic system-under-test**. Same input, different output across runs. Treat every `(snapshot, prompt)` pair the way you would treat a flaky integration test: run it `N` times, compute statistics over the distribution, never report a single sample as truth.

That single mental model -- property-based testing with `N` runs per property -- covers the entire framework. The statistical machinery further down is bookkeeping for that idea.

## The contract surface

The grading library is a **pure function**:

```
grade : (runs : Vec<Run>, config : GradingConfig)  ->  Scorecard
```

No agent calls inside `grade`. No filesystem mutation inside `grade`. The runs come in as a list of records; the scorecard goes out as a structured value. The function is deterministic given identical input.

This means the grader is unit-testable with synthetic run fixtures. Build a `runs.jsonl` where you know v2 beats v1 by exactly 0.10 with no variance and assert the verdict. That is the regression test for the grader itself.

## Per-run score

Each run produces five components, each normalized to `[0, 1]`. Each component has a clear source.

| Component             | Source        | How it is computed                                                                                                                          |
| --------------------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `correctness`         | deterministic | fraction of post-conditions passing (e.g. `moon check` exits 0; `workspace.yml` parses; expected files exist). Defined per failure-mode in `evals/<skill>/postconds/<mode-id>.py`. |
| `root_cause`          | LLM-judge     | rubric: did the fix address the underlying issue or paper over it? Likert 1-5 -> mapped to `[0, 1]` as `(score - 1) / 4`.                   |
| `no_regression`       | deterministic | `1 - unexpected_changes / total_files_in_snapshot`, computed by diffing the agent's working tree against the baseline snapshot.              |
| `skill_attribution`   | deterministic | `1` if the skill-under-test was loaded by the run (detected from the run's tool-call log), else `0`.                                        |
| `efficiency`          | deterministic | `1 - clamp(turns_used / turns_budget, 0, 1)`. Penalty for slow fixes.                                                                       |

Composite per run:

```
S_run = w_c * correctness  +  w_r * root_cause  +  w_n * no_regression  +  w_a * skill_attribution  +  w_e * efficiency
```

**Default weights:** `(w_c, w_r, w_n, w_a, w_e) = (0.40, 0.30, 0.15, 0.05, 0.10)`. They live in `evals/<skill>/grading.yaml` so a per-skill override is cheap.

`skill_attribution` is intentionally small (5%). A skill that is never invoked but the run still passes is a strong signal the skill is irrelevant. We want that to show up without dominating.

## Variance handling -- N runs per cell

A single run per cell is noise. Per cell `c = (snapshot, prompt, condition)`:

- Run `N` trials. Default `N = 5`. `--quick` drops to `3`. `--full` raises to `10`.
- Report `mean(S_c)` and a **bootstrap 95% confidence interval** (1000 resamples).
- Never publish a delta whose CIs overlap. If they overlap, the answer is "we don't know yet -- raise N or stop chasing".

The CI is the equivalent of reporting `p99` latency over a window rather than the latency of a single request. Same idea, different metric.

## Aggregation up the hierarchy

```
score(failure_mode m)  =  sum over p in prompt_classes  of  w_p * mean(S over runs at (s_m, p, treatment))
score(skill)           =  sum over m in failure_modes   of  freq(m) * score(m)
```

- **`w_p`** -- prompt-class weights. Default: `(vague-real, explicit-flawed-real, synthetic-correct, adversarial) = (0.40, 0.30, 0.15, 0.15)`. Vague-real is the realistic case. The synthetics are guardrails.
- **`freq(m)`** -- the normalized recurrence count from the mining stage. A failure mode that hit 47 times in transcripts gets more weight than one that hit 2. This is what makes the score *evidence-weighted* rather than *test-weighted*.

## Treatment effect -- the headline number

The skill's value is causal. The point of the framework is to measure how much the skill itself contributes, separate from the underlying model's baseline competence.

For each prompt, run BOTH conditions (skill-on, skill-off):

```
lift  =  score(skill_on) - score(skill_off)
```

Across the full matrix of `(snapshot, prompt)` pairs:

- **Significance:** paired Wilcoxon signed-rank test (non-parametric -- run scores are not normally distributed).
- **Effect size:** Cliff's delta (the non-parametric companion to Cohen's d).
- **Headline format:** `lift = +0.18, delta = 0.42, p = 0.003, n = 32 pairs`.

When iterating skill v1 -> v2, the same machinery applied to `S_v2 - S_v1` over identical cells.

A move that is statistically significant but tiny (low effect size) is not worth shipping. A move that is large but inside the noise floor is not real. **Both** must clear the bar.

## Per-cell regression detection

When promoting v2 over v1, you do not just want the global score to go up -- you want NO cell to silently get worse. With many cells, naive per-cell tests produce false positives by chance.

**Use Benjamini-Hochberg** to control the False Discovery Rate at `q = 0.05` across all cells.

In systems vocabulary: this is the same idea as "do not page on a single 5xx, page on a sustained rate above expected". BH governs how aggressively you flag based on how many things you are looking at.

Any cell flagged after BH correction blocks promotion until investigated.

## Promotion gates

A skill version `v_new` replaces `v_old` only if **all five** hold:

1. **Meaningful lift.** `mean(lift_new) >= mean(lift_old) + epsilon`. Default `epsilon = 0.05` on the `[0, 1]` scale. Recalibrate after a few runs once you know the natural scale of changes for your skills.
2. **No silent regressions.** No cell degraded under BH-corrected `q < 0.05`.
3. **Coverage non-decreasing.** `coverage(v_new) >= coverage(v_old)`. Coverage is the fraction of mined failure modes with `>= 3` runs of test data.
4. **Judge calibration intact.** `kappa(LLM-judge, human-gold) >= kappa_min`. Default `kappa_min = 0.6`.
5. **Baseline stable.** `score_off(v_new)` within CI of `score_off(v_old)`. Sanity check that the harness or snapshots did not silently change in a way that moved the baseline. If this fails the new score is not comparable to the old.

The verdict is a tagged ADT, not a boolean:

```
PromotionVerdict
  = Promote { lift, effect_size, n_pairs }
  | Block   { reasons : Vec<BlockReason> }

BlockReason
  = LiftBelowThreshold        { observed, required }
  | CellRegression            { cell_id, p_bh }
  | CoverageRegression        { delta_failure_modes }
  | JudgeDrift                { kappa, threshold }
  | BaselineShift             { delta }
```

The orchestrator prints every reason. No silent block reasons.

## LLM-judge calibration -- the hidden footgun

LLM-as-judge is not free of bias. It has its own variance and can drift across model versions. Without calibration, the framework gives you a confident wrong answer.

### The gold set

Maintain a small set of cells you have **personally graded**. Stored at `evals/<skill>/gold.jsonl`.

```
{ "cell_id": "...", "human_score": 0.85, "rationale": "fixed root cause; minor regression in adjacent file" }
```

Target size: 15-20 cells per skill. Diverse: include each prompt class, each failure mode, both conditions.

### The calibration loop

Every full eval run also re-grades the gold set with the LLM-judge.

```
kappa  =  cohens_kappa(judge_scores_on_gold, human_scores_on_gold)
```

Both scores are first quantized into 5 bins (Likert mapping back) so kappa is well-defined. If `kappa < kappa_min` (default `0.6`):

- The judge is **unreliable for this skill** at this moment.
- Block promotion. Do not trust the headline number.
- Fix the rubric: more concrete anchors, fewer Likert points, rewrite ambiguous prompts.
- Re-grade gold whenever the judge model version changes.

### When to trust the judge

`kappa` thresholds, in human terms:

| kappa range  | Interpretation                                   |
| ------------ | ------------------------------------------------ |
| `< 0.4`      | Judge is barely better than chance. Do not ship. |
| `0.4 - 0.6`  | Fair. Tolerable for triage, not for gates.       |
| `0.6 - 0.8`  | Substantial agreement. Default acceptable bar.   |
| `> 0.8`      | Strong agreement. Trust the judge unconditionally for this skill. |

## Pareto reporting -- do not collapse too soon

Score and efficiency travel together. A skill that fixes everything in 50 turns is often worse than one that fixes 90% in 3.

Always report **(score, efficiency) as a pair** and flag any version Pareto-dominated by a predecessor. The single composite is for the gate; the Pareto plot is for the human reviewer.

The grader emits both.

## The typed config (the contract you actually own)

Everything statistical above is implementation detail. The user-facing surface is a small typed config in `evals/<skill>/grading.yaml`.

The Rust-equivalent shape (real implementation is Python):

```rust
struct GradingConfig {
    component_weights: ComponentWeights,   // sums to 1, validated at load
    prompt_weights:    PromptWeights,      // sums to 1, validated at load
    runs_per_cell:     NonZeroU8,          // default 5; --quick -> 3; --full -> 10
    min_meaningful_lift: f64,              // default 0.05, in [0, 1]
    fdr_q: f64,                            // default 0.05
    kappa_min: f64,                        // default 0.6
    turns_budget: u32,                     // default 40 (per cell)
    bootstrap_iters: u32,                  // default 1000
}

struct ComponentWeights {
    correctness: f64,         // default 0.40
    root_cause: f64,          // default 0.30
    no_regression: f64,       // default 0.15
    skill_attribution: f64,   // default 0.05
    efficiency: f64,          // default 0.10
}

struct PromptWeights {
    vague_real: f64,          // default 0.40
    explicit_flawed: f64,     // default 0.30
    synthetic_correct: f64,   // default 0.15
    adversarial: f64,         // default 0.15
}
```

You should never have to read past this section. The four taste-knobs you actually own are:

1. `component_weights` -- five floats, sum to 1.
2. `prompt_weights` -- four floats, sum to 1.
3. `runs_per_cell` -- cost knob.
4. `min_meaningful_lift` -- minimum lift you call meaningful.

Everything else has a sane default and you can leave it.

## Persisted artefacts on disk

```
evals/<skill-name>/
  grading.yaml              # the GradingConfig above (per-skill override)
  failure-modes.json        # mined clusters: id, freq, severity, recency, citations, weight
  snapshots/<mode-id>/      # the anonymized fixture trees (one per failure mode)
  prompts/<mode-id>.jsonl   # four-class prompt matrix per failure mode
  postconds/<mode-id>.py    # deterministic post-condition graders (per-skill, per-mode)
  gold.jsonl                # human-graded calibration cells
  runs/<run-id>/            # one directory per harness run; raw transcripts, file diffs, per-component scores, judge outputs
  scorecards/<version>.json # aggregated per-version output -- the regression baseline
```

`scorecards/<version>.json` is what the next iteration replays against. It is the regression net.

## Algorithmic appendix (you should not have to read this)

The statistical machinery the library implements. Here for reproducibility, not for you.

### Bootstrap CI

For a cell with `N` run scores `s_1, ..., s_N`:

```
for i in 1..1000:
    sample with replacement N values from {s_1..s_N}
    record the mean
ci_low, ci_high = 2.5th and 97.5th percentile of the recorded means
```

### Paired Wilcoxon

For paired observations `(x_i, y_i)` for `i in 1..n`:

```
d_i  =  x_i - y_i  (drop ties)
rank |d_i|
W+  =  sum of ranks where d_i > 0
W-  =  sum of ranks where d_i < 0
W   =  min(W+, W-)
p   =  scipy.stats.wilcoxon(x, y).pvalue
```

### Cliff's delta

For two samples `X` (size `n1`) and `Y` (size `n2`):

```
delta  =  (#{ (x, y) : x > y }  -  #{ (x, y) : x < y })  /  (n1 * n2)
```

`abs(delta) < 0.147` = negligible; `< 0.33` = small; `< 0.474` = medium; `>= 0.474` = large.

### Benjamini-Hochberg FDR

For `m` per-cell p-values `p_1, ..., p_m`, sorted ascending:

```
for k in 1..m:
    threshold_k  =  (k / m) * q
flag cell k iff p_k <= threshold_k for some k
```

### Cohen's kappa

For two graders' Likert scores binned into `k` categories:

```
p_o  =  observed agreement (fraction where they match)
p_e  =  expected agreement by chance (sum over categories of (p_a * p_b))
kappa  =  (p_o - p_e) / (1 - p_e)
```

`kappa = 1` is perfect; `kappa = 0` is chance; `kappa < 0` is worse than chance.

End of appendix. Everything above is what the grader actually does. Everything in the contract surface section is what you actually configure.
