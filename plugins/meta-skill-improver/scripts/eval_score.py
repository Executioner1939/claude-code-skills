#!/usr/bin/env python3
"""eval_score.py -- the deterministic grading library for meta-skill-improver.

A pure function from (runs.jsonl, config, optional gold.jsonl, optional
prev scorecard) to a versioned scorecard.json plus a markdown report.

No agent calls. No filesystem mutation outside the explicitly-named output
paths. Deterministic given identical input.

Designed to be unit-testable with synthetic run fixtures: build a runs.jsonl
where you know the expected outcome (e.g. v2 beats v1 by exactly 0.10 with
no variance), pass it through, assert the verdict.

Dependencies: Python 3.11+, numpy. Optional: scipy (better Wilcoxon p-values
for small-N), pyyaml (so config can live in YAML; JSON fallback works without).

Usage (CLI):
    python eval_score.py \\
        --runs evals/<skill>/runs/<run-id>/runs.jsonl \\
        --config evals/<skill>/grading.yaml \\
        --failure-modes evals/<skill>/failure-modes.json \\
        --gold evals/<skill>/gold.jsonl \\
        --prev evals/<skill>/scorecards/0.1.0.json \\
        --out evals/<skill>/scorecards/0.2.0.json
"""

from __future__ import annotations

import argparse
import json
import math
import statistics
import sys
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Literal, Optional

import numpy as np

# Soft deps. The library works without them; richer stats and YAML config are
# enabled when present.
try:
    import yaml as _yaml   # noqa: F401
    _HAS_YAML = True
except ImportError:
    _HAS_YAML = False

try:
    from scipy import stats as _scipy_stats   # noqa: F401
    _HAS_SCIPY = True
except ImportError:
    _HAS_SCIPY = False


# --------------------------------------------------------------------------- #
# Domain types -- small ADT-shaped dataclasses, frozen where reasonable.
# --------------------------------------------------------------------------- #


PromptClass = Literal["vague-real", "explicit-flawed-real", "synthetic-correct", "adversarial"]
Condition = Literal["skill_on", "skill_off"]


@dataclass(frozen=True)
class ComponentWeights:
    correctness: float = 0.40
    root_cause: float = 0.30
    no_regression: float = 0.15
    skill_attribution: float = 0.05
    efficiency: float = 0.10

    def __post_init__(self) -> None:
        total = (
            self.correctness
            + self.root_cause
            + self.no_regression
            + self.skill_attribution
            + self.efficiency
        )
        if not math.isclose(total, 1.0, abs_tol=1e-6):
            raise ValueError(f"component_weights must sum to 1.0; got {total}")


@dataclass(frozen=True)
class PromptWeights:
    vague_real: float = 0.40
    explicit_flawed: float = 0.30
    synthetic_correct: float = 0.15
    adversarial: float = 0.15

    def __post_init__(self) -> None:
        total = self.vague_real + self.explicit_flawed + self.synthetic_correct + self.adversarial
        if not math.isclose(total, 1.0, abs_tol=1e-6):
            raise ValueError(f"prompt_weights must sum to 1.0; got {total}")

    def for_class(self, cls: PromptClass) -> float:
        return {
            "vague-real": self.vague_real,
            "explicit-flawed-real": self.explicit_flawed,
            "synthetic-correct": self.synthetic_correct,
            "adversarial": self.adversarial,
        }[cls]


@dataclass(frozen=True)
class GradingConfig:
    component_weights: ComponentWeights = field(default_factory=ComponentWeights)
    prompt_weights: PromptWeights = field(default_factory=PromptWeights)
    runs_per_cell: int = 5
    min_meaningful_lift: float = 0.05
    fdr_q: float = 0.05
    kappa_min: float = 0.6
    turns_budget: int = 40
    bootstrap_iters: int = 1000

    def __post_init__(self) -> None:
        if self.runs_per_cell < 1:
            raise ValueError("runs_per_cell must be >= 1")
        if not 0.0 < self.min_meaningful_lift < 1.0:
            raise ValueError("min_meaningful_lift must be in (0, 1)")
        if not 0.0 < self.fdr_q < 1.0:
            raise ValueError("fdr_q must be in (0, 1)")
        if not 0.0 <= self.kappa_min <= 1.0:
            raise ValueError("kappa_min must be in [0, 1]")


@dataclass(frozen=True)
class RunComponents:
    correctness: float
    root_cause: Optional[float]   # None if judge has not graded yet
    no_regression: float
    skill_attribution: float
    efficiency: float


@dataclass(frozen=True)
class Run:
    cell_id: str
    trial_index: int
    mode_id: str
    prompt_id: str
    prompt_class: PromptClass
    condition: Condition
    skill_version: str
    components: RunComponents
    turns_used: int
    timestamp: str

    @staticmethod
    def from_json(d: dict) -> "Run":
        c = d["components"]
        return Run(
            cell_id=d["cell_id"],
            trial_index=int(d["trial_index"]),
            mode_id=d["mode_id"],
            prompt_id=d["prompt_id"],
            prompt_class=d["prompt_class"],
            condition=d["condition"],
            skill_version=d["skill_version"],
            components=RunComponents(
                correctness=float(c["correctness"]),
                root_cause=None if c.get("root_cause") is None else float(c["root_cause"]),
                no_regression=float(c["no_regression"]),
                skill_attribution=float(c["skill_attribution"]),
                efficiency=float(c["efficiency"]),
            ),
            turns_used=int(d.get("turns_used", 0)),
            timestamp=d.get("timestamp", ""),
        )


@dataclass(frozen=True)
class CellScore:
    cell_id: str
    mode_id: str
    prompt_class: PromptClass
    condition: Condition
    n_trials: int
    mean: float
    ci_low: float
    ci_high: float
    per_component_mean: dict[str, float]


@dataclass(frozen=True)
class ModeScore:
    mode_id: str
    weight: float
    score_treatment: float
    score_baseline: float
    lift: float
    n_pairs: int


@dataclass(frozen=True)
class LiftReport:
    mean_lift: float
    median_lift: float
    cliffs_delta: float
    wilcoxon_p: Optional[float]
    n_pairs: int


@dataclass(frozen=True)
class CellRegression:
    cell_id: str
    p_value: float
    p_value_bh_threshold: float
    delta_to_prev: float


@dataclass(frozen=True)
class JudgeCalibration:
    n_gold: int
    kappa: Optional[float]
    threshold: float
    passed: bool


@dataclass(frozen=True)
class PromotionVerdict:
    promote: bool
    reasons: list[dict]   # serialized BlockReason variants


@dataclass(frozen=True)
class Scorecard:
    skill: str
    version: str
    generated_at: str
    config: dict
    n_cells: int
    n_runs: int
    skill_score: float
    baseline_score: float
    lift: LiftReport
    cells: list[CellScore]
    modes: list[ModeScore]
    regressions: list[CellRegression]
    judge_calibration: JudgeCalibration
    pareto_dominated: bool
    verdict: PromotionVerdict


# --------------------------------------------------------------------------- #
# Math primitives. Documented in skills/grading/SKILL.md (algorithmic appendix).
# --------------------------------------------------------------------------- #


def composite_score(c: RunComponents, w: ComponentWeights) -> float:
    """The weighted composite per run. Returns NaN if root_cause is not yet graded
    AND that component carries weight; the caller must batch through the judge first."""
    if c.root_cause is None and w.root_cause > 0:
        return float("nan")
    rc = c.root_cause if c.root_cause is not None else 0.0
    return (
        w.correctness * c.correctness
        + w.root_cause * rc
        + w.no_regression * c.no_regression
        + w.skill_attribution * c.skill_attribution
        + w.efficiency * c.efficiency
    )


def bootstrap_ci(values: list[float], n_iters: int = 1000, alpha: float = 0.05,
                 rng: Optional[np.random.Generator] = None) -> tuple[float, float]:
    """Percentile bootstrap CI for the mean. Returns (lo, hi)."""
    if not values:
        return (0.0, 0.0)
    rng = rng or np.random.default_rng(seed=42)
    arr = np.asarray(values, dtype=float)
    n = len(arr)
    if n == 1:
        return (float(arr[0]), float(arr[0]))
    means = np.empty(n_iters)
    for i in range(n_iters):
        sample = rng.choice(arr, size=n, replace=True)
        means[i] = sample.mean()
    lo = float(np.percentile(means, 100 * alpha / 2))
    hi = float(np.percentile(means, 100 * (1 - alpha / 2)))
    return lo, hi


def cliffs_delta(x: list[float], y: list[float]) -> float:
    """Cliff's delta: non-parametric effect size in [-1, 1].
    Positive means x tends to be larger than y."""
    if not x or not y:
        return 0.0
    nx, ny = len(x), len(y)
    greater = 0
    less = 0
    for xi in x:
        for yj in y:
            if xi > yj:
                greater += 1
            elif xi < yj:
                less += 1
    return (greater - less) / (nx * ny)


def benjamini_hochberg(p_values: list[float], q: float = 0.05) -> list[bool]:
    """Benjamini-Hochberg FDR control. Returns a list of booleans, True for cells
    flagged at q-level FDR. p_values may arrive in any order; the result is
    aligned to the input order."""
    if not p_values:
        return []
    m = len(p_values)
    indexed = sorted(enumerate(p_values), key=lambda t: t[1])
    flags = [False] * m
    # Walk descending: largest BH-acceptable threshold determines cutoff
    cutoff_rank = -1
    for rank, (orig_idx, p) in enumerate(indexed, start=1):
        threshold = (rank / m) * q
        if p <= threshold:
            cutoff_rank = rank
    if cutoff_rank > 0:
        for rank, (orig_idx, _) in enumerate(indexed, start=1):
            if rank <= cutoff_rank:
                flags[orig_idx] = True
    return flags


def cohens_kappa(rater_a: list[float], rater_b: list[float], n_bins: int = 5) -> float:
    """Cohen's kappa for two raters on the same items. Scores in [0, 1] are
    quantized into n_bins discrete categories before computing kappa.
    Returns kappa in [-1, 1]; 1 = perfect, 0 = chance, < 0 = worse than chance."""
    if not rater_a or not rater_b:
        return 0.0
    if len(rater_a) != len(rater_b):
        raise ValueError("rater_a and rater_b must have the same length")
    a = _quantize(rater_a, n_bins)
    b = _quantize(rater_b, n_bins)
    n = len(a)
    p_o = sum(1 for ai, bi in zip(a, b) if ai == bi) / n
    pa_counts = [0] * n_bins
    pb_counts = [0] * n_bins
    for ai, bi in zip(a, b):
        pa_counts[ai] += 1
        pb_counts[bi] += 1
    p_e = sum((pa_counts[i] / n) * (pb_counts[i] / n) for i in range(n_bins))
    if math.isclose(p_e, 1.0):
        return 1.0 if math.isclose(p_o, 1.0) else 0.0
    return (p_o - p_e) / (1.0 - p_e)


def _quantize(values: list[float], n_bins: int) -> list[int]:
    """Map values in [0, 1] into integer bins [0..n_bins-1]."""
    out: list[int] = []
    for v in values:
        v_clamped = max(0.0, min(1.0, float(v)))
        b = min(int(v_clamped * n_bins), n_bins - 1)
        out.append(b)
    return out


def paired_wilcoxon(x: list[float], y: list[float]) -> Optional[float]:
    """Returns the p-value of the paired Wilcoxon signed-rank test, or None
    if the test cannot run (e.g., all differences are zero).

    Uses scipy when available (exact p-values for small N). Falls back to a
    large-sample normal approximation that is reasonable for n_pairs >= 10.
    """
    if len(x) != len(y) or len(x) == 0:
        return None
    diffs = [a - b for a, b in zip(x, y) if a != b]
    if not diffs:
        return None

    if _HAS_SCIPY:
        try:
            result = _scipy_stats.wilcoxon(x=x, y=y, zero_method="wilcox", alternative="two-sided")
            return float(result.pvalue)
        except ValueError:
            return None

    # Normal-approximation fallback. Walk the (unsigned) ranks, assign signs.
    abs_diffs = sorted(((abs(d), d) for d in diffs), key=lambda t: t[0])
    # Average ranks across ties.
    ranks: list[float] = [0.0] * len(abs_diffs)
    i = 0
    while i < len(abs_diffs):
        j = i
        while j + 1 < len(abs_diffs) and abs_diffs[j + 1][0] == abs_diffs[i][0]:
            j += 1
        avg_rank = (i + j + 2) / 2.0   # ranks are 1-indexed in the formula
        for k in range(i, j + 1):
            ranks[k] = avg_rank
        i = j + 1
    w_plus = sum(rk for rk, (_, d) in zip(ranks, abs_diffs) if d > 0)
    w_minus = sum(rk for rk, (_, d) in zip(ranks, abs_diffs) if d < 0)
    n = len(diffs)
    mean_w = n * (n + 1) / 4.0
    var_w = n * (n + 1) * (2 * n + 1) / 24.0
    if var_w <= 0:
        return None
    w = min(w_plus, w_minus)
    z = (w - mean_w) / math.sqrt(var_w)
    # Two-sided p via normal CDF.
    return 2.0 * (1.0 - _normal_cdf(abs(z)))


def _normal_cdf(z: float) -> float:
    """Stdlib normal CDF via the erf identity: Phi(z) = 0.5 * (1 + erf(z / sqrt(2)))."""
    return 0.5 * (1.0 + math.erf(z / math.sqrt(2.0)))


# --------------------------------------------------------------------------- #
# Aggregation: cell -> mode -> skill.
# --------------------------------------------------------------------------- #


def aggregate_cell(runs: list[Run], config: GradingConfig) -> CellScore:
    """Mean composite over the trials of a single cell, plus bootstrap CI and
    per-component mean."""
    if not runs:
        raise ValueError("aggregate_cell requires at least one run")
    cell_id = runs[0].cell_id
    mode_id = runs[0].mode_id
    prompt_class = runs[0].prompt_class
    condition = runs[0].condition

    composites = [composite_score(r.components, config.component_weights) for r in runs]
    composites = [s for s in composites if not math.isnan(s)]
    if not composites:
        return CellScore(
            cell_id=cell_id,
            mode_id=mode_id,
            prompt_class=prompt_class,
            condition=condition,
            n_trials=0,
            mean=float("nan"),
            ci_low=float("nan"),
            ci_high=float("nan"),
            per_component_mean={},
        )

    mean = statistics.fmean(composites)
    ci_lo, ci_hi = bootstrap_ci(composites, n_iters=config.bootstrap_iters)

    per_component_mean = {
        "correctness": statistics.fmean(r.components.correctness for r in runs),
        "root_cause": statistics.fmean(r.components.root_cause for r in runs if r.components.root_cause is not None) if any(r.components.root_cause is not None for r in runs) else float("nan"),
        "no_regression": statistics.fmean(r.components.no_regression for r in runs),
        "skill_attribution": statistics.fmean(r.components.skill_attribution for r in runs),
        "efficiency": statistics.fmean(r.components.efficiency for r in runs),
    }

    return CellScore(
        cell_id=cell_id,
        mode_id=mode_id,
        prompt_class=prompt_class,
        condition=condition,
        n_trials=len(composites),
        mean=mean,
        ci_low=ci_lo,
        ci_high=ci_hi,
        per_component_mean=per_component_mean,
    )


def aggregate_mode(
    cells: list[CellScore],
    mode_id: str,
    mode_weight: float,
    config: GradingConfig,
) -> ModeScore:
    """Weighted average over prompt classes, paired with the baseline."""
    treatment = [c for c in cells if c.mode_id == mode_id and c.condition == "skill_on"]
    baseline = [c for c in cells if c.mode_id == mode_id and c.condition == "skill_off"]

    pairs = []
    for t in treatment:
        match = next((b for b in baseline if b.prompt_class == t.prompt_class), None)
        if match is not None:
            pairs.append((t, match))

    if not pairs:
        return ModeScore(mode_id=mode_id, weight=mode_weight, score_treatment=float("nan"),
                         score_baseline=float("nan"), lift=float("nan"), n_pairs=0)

    score_t = sum(config.prompt_weights.for_class(t.prompt_class) * t.mean for t, _ in pairs)
    score_b = sum(config.prompt_weights.for_class(b.prompt_class) * b.mean for _, b in pairs)
    return ModeScore(
        mode_id=mode_id,
        weight=mode_weight,
        score_treatment=score_t,
        score_baseline=score_b,
        lift=score_t - score_b,
        n_pairs=len(pairs),
    )


def aggregate_skill(modes: list[ModeScore]) -> tuple[float, float]:
    """Frequency-weighted score across failure modes. Returns (treatment, baseline)."""
    if not modes:
        return 0.0, 0.0
    total_weight = sum(m.weight for m in modes if not math.isnan(m.score_treatment))
    if total_weight == 0:
        return 0.0, 0.0
    score_t = sum(m.weight * m.score_treatment for m in modes if not math.isnan(m.score_treatment)) / total_weight
    score_b = sum(m.weight * m.score_baseline for m in modes if not math.isnan(m.score_baseline)) / total_weight
    return score_t, score_b


# --------------------------------------------------------------------------- #
# Lift, regression detection, judge calibration, promotion verdict.
# --------------------------------------------------------------------------- #


def compute_lift_report(cells: list[CellScore], config: GradingConfig) -> LiftReport:
    """Paired lift across all cells. Pair on (mode_id, prompt_class)."""
    treatments = [c for c in cells if c.condition == "skill_on"]
    baselines = [c for c in cells if c.condition == "skill_off"]
    pair_map: dict[tuple[str, str], tuple[float, float]] = {}
    for t in treatments:
        for b in baselines:
            if b.mode_id == t.mode_id and b.prompt_class == t.prompt_class:
                pair_map[(t.mode_id, t.prompt_class)] = (t.mean, b.mean)
                break

    if not pair_map:
        return LiftReport(mean_lift=0.0, median_lift=0.0, cliffs_delta=0.0,
                          wilcoxon_p=None, n_pairs=0)

    treatment_vals = [t for t, _ in pair_map.values()]
    baseline_vals = [b for _, b in pair_map.values()]
    lifts = [t - b for t, b in pair_map.values()]

    return LiftReport(
        mean_lift=statistics.fmean(lifts),
        median_lift=statistics.median(lifts),
        cliffs_delta=cliffs_delta(treatment_vals, baseline_vals),
        wilcoxon_p=paired_wilcoxon(treatment_vals, baseline_vals),
        n_pairs=len(pair_map),
    )


def detect_regressions(
    current: list[CellScore],
    previous: Optional[list[dict]],
    config: GradingConfig,
) -> list[CellRegression]:
    """For each cell present in both current and previous, run a one-sided
    Wilcoxon-style sanity check on the per-trial composites. Apply BH FDR
    correction across cells. Return only cells flagged as regressed."""
    if not previous:
        return []
    prev_index: dict[str, dict] = {c["cell_id"]: c for c in previous}

    p_values: list[tuple[str, float, float]] = []  # (cell_id, p, delta)
    for cur in current:
        prev = prev_index.get(cur.cell_id)
        if prev is None or prev.get("condition") != cur.condition:
            continue
        delta = cur.mean - prev["mean"]
        if delta >= 0:
            continue   # not a regression candidate
        # Cheap z-style test using prev's CI as a noise floor estimator.
        prev_lo, prev_hi = prev.get("ci_low"), prev.get("ci_high")
        if prev_lo is None or prev_hi is None:
            continue
        sigma = max((prev_hi - prev_lo) / 3.92, 1e-6)   # approx sd from CI width
        z = abs(delta) / sigma
        p = 2.0 * (1.0 - _normal_cdf(z))
        p_values.append((cur.cell_id, float(p), float(delta)))

    if not p_values:
        return []

    flags = benjamini_hochberg([p for _, p, _ in p_values], q=config.fdr_q)
    regressions: list[CellRegression] = []
    for (cell_id, p, delta), flagged in zip(p_values, flags):
        if flagged:
            regressions.append(
                CellRegression(
                    cell_id=cell_id,
                    p_value=p,
                    p_value_bh_threshold=config.fdr_q,
                    delta_to_prev=delta,
                )
            )
    return regressions


def judge_calibration(gold_path: Optional[Path], config: GradingConfig) -> JudgeCalibration:
    """Compare the LLM-judge's scores against human-gold scores using Cohen's kappa."""
    if gold_path is None or not gold_path.exists():
        return JudgeCalibration(n_gold=0, kappa=None, threshold=config.kappa_min, passed=False)

    judge_scores: list[float] = []
    human_scores: list[float] = []
    for line in gold_path.read_text().splitlines():
        line = line.strip()
        if not line:
            continue
        rec = json.loads(line)
        # Both fields must be present per gold.jsonl contract.
        if "judge_score" in rec and "human_score" in rec:
            judge_scores.append(float(rec["judge_score"]))
            human_scores.append(float(rec["human_score"]))

    if len(judge_scores) < 5:
        return JudgeCalibration(n_gold=len(judge_scores), kappa=None,
                                threshold=config.kappa_min, passed=False)

    k = cohens_kappa(judge_scores, human_scores, n_bins=5)
    return JudgeCalibration(
        n_gold=len(judge_scores),
        kappa=k,
        threshold=config.kappa_min,
        passed=k >= config.kappa_min,
    )


def decide_promotion(
    skill_score: float,
    baseline_score: float,
    prev_skill_score: Optional[float],
    prev_baseline_score: Optional[float],
    lift_report: LiftReport,
    regressions: list[CellRegression],
    calibration: JudgeCalibration,
    coverage_now: int,
    coverage_prev: Optional[int],
    config: GradingConfig,
) -> PromotionVerdict:
    """Apply the five gates. Returns a verdict with explicit reasons on block."""
    reasons: list[dict] = []

    # Gate 1: meaningful lift (vs prior)
    if prev_skill_score is not None:
        observed = skill_score - prev_skill_score
        if observed < config.min_meaningful_lift:
            reasons.append({
                "kind": "LiftBelowThreshold",
                "observed": observed,
                "required": config.min_meaningful_lift,
            })
    else:
        # First iteration: lift is vs the baseline
        if lift_report.mean_lift < config.min_meaningful_lift:
            reasons.append({
                "kind": "LiftBelowThreshold",
                "observed": lift_report.mean_lift,
                "required": config.min_meaningful_lift,
            })

    # Gate 2: no per-cell regressions
    for r in regressions:
        reasons.append({"kind": "CellRegression", "cell_id": r.cell_id,
                        "p_bh": r.p_value, "delta": r.delta_to_prev})

    # Gate 3: coverage non-decreasing
    if coverage_prev is not None and coverage_now < coverage_prev:
        reasons.append({"kind": "CoverageRegression",
                        "delta_failure_modes": coverage_now - coverage_prev})

    # Gate 4: judge calibration
    if calibration.kappa is None or not calibration.passed:
        reasons.append({"kind": "JudgeDrift",
                        "kappa": calibration.kappa,
                        "threshold": calibration.threshold,
                        "n_gold": calibration.n_gold})

    # Gate 5: baseline stability (compare to prior)
    if prev_baseline_score is not None:
        delta = abs(baseline_score - prev_baseline_score)
        # Heuristic: if the baseline shifted by more than the meaningful-lift threshold,
        # the harness state has changed and the new score is not comparable.
        if delta > config.min_meaningful_lift:
            reasons.append({"kind": "BaselineShift", "delta": delta,
                            "threshold": config.min_meaningful_lift})

    return PromotionVerdict(promote=(len(reasons) == 0), reasons=reasons)


# --------------------------------------------------------------------------- #
# I/O loaders.
# --------------------------------------------------------------------------- #


def load_runs(path: Path) -> list[Run]:
    runs: list[Run] = []
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line:
            continue
        runs.append(Run.from_json(json.loads(line)))
    return runs


def load_config(path: Optional[Path]) -> GradingConfig:
    if path is None or not path.exists():
        return GradingConfig()
    text = path.read_text()
    if _HAS_YAML and path.suffix.lower() in (".yaml", ".yml"):
        raw = _yaml.safe_load(text) or {}
    else:
        # JSON fallback. If the user wrote YAML but pyyaml is missing, surface
        # the dependency need rather than silently mis-parse.
        try:
            raw = json.loads(text)
        except json.JSONDecodeError as exc:
            if path.suffix.lower() in (".yaml", ".yml") and not _HAS_YAML:
                raise RuntimeError(
                    f"{path} looks like YAML but pyyaml is not installed. "
                    "Either install pyyaml or rewrite the config as JSON."
                ) from exc
            raise
    cw = raw.get("component_weights") or {}
    pw = raw.get("prompt_weights") or {}
    component_weights = ComponentWeights(
        correctness=cw.get("correctness", 0.40),
        root_cause=cw.get("root_cause", 0.30),
        no_regression=cw.get("no_regression", 0.15),
        skill_attribution=cw.get("skill_attribution", 0.05),
        efficiency=cw.get("efficiency", 0.10),
    )
    prompt_weights = PromptWeights(
        vague_real=pw.get("vague_real", 0.40),
        explicit_flawed=pw.get("explicit_flawed", 0.30),
        synthetic_correct=pw.get("synthetic_correct", 0.15),
        adversarial=pw.get("adversarial", 0.15),
    )
    return GradingConfig(
        component_weights=component_weights,
        prompt_weights=prompt_weights,
        runs_per_cell=raw.get("runs_per_cell", 5),
        min_meaningful_lift=raw.get("min_meaningful_lift", 0.05),
        fdr_q=raw.get("fdr_q", 0.05),
        kappa_min=raw.get("kappa_min", 0.6),
        turns_budget=raw.get("turns_budget", 40),
        bootstrap_iters=raw.get("bootstrap_iters", 1000),
    )


def load_failure_modes(path: Optional[Path]) -> dict[str, float]:
    """Return mode_id -> weight (the freq*severity*recency product). Defaults to
    equal weight if no file is provided."""
    if path is None or not path.exists():
        return {}
    data = json.loads(path.read_text())
    return {m["id"]: float(m.get("weight", 1.0)) for m in data.get("failure_modes", [])}


def load_prev_scorecard(path: Optional[Path]) -> Optional[dict]:
    if path is None or not path.exists():
        return None
    return json.loads(path.read_text())


# --------------------------------------------------------------------------- #
# Top-level grade() function -- the public API.
# --------------------------------------------------------------------------- #


def group_runs_by_cell(runs: list[Run]) -> dict[str, list[Run]]:
    groups: dict[str, list[Run]] = {}
    for r in runs:
        groups.setdefault(r.cell_id, []).append(r)
    return groups


def grade(
    runs: list[Run],
    config: GradingConfig,
    failure_mode_weights: dict[str, float],
    gold_path: Optional[Path],
    prev_scorecard: Optional[dict],
    skill: str,
    version: str,
    timestamp: str,
) -> Scorecard:
    cell_scores: list[CellScore] = []
    for cell_id, cell_runs in group_runs_by_cell(runs).items():
        cell_scores.append(aggregate_cell(cell_runs, config))

    mode_ids = sorted({c.mode_id for c in cell_scores})
    mode_scores: list[ModeScore] = []
    for mid in mode_ids:
        weight = failure_mode_weights.get(mid, 1.0)
        mode_scores.append(aggregate_mode(cell_scores, mid, weight, config))

    skill_score, baseline_score = aggregate_skill(mode_scores)
    lift_report = compute_lift_report(cell_scores, config)

    prev_cells = prev_scorecard["cells"] if prev_scorecard else None
    prev_skill_score = prev_scorecard["skill_score"] if prev_scorecard else None
    prev_baseline_score = prev_scorecard["baseline_score"] if prev_scorecard else None
    coverage_prev = prev_scorecard["n_cells"] if prev_scorecard else None
    regressions = detect_regressions(cell_scores, prev_cells, config)
    calibration = judge_calibration(gold_path, config)

    verdict = decide_promotion(
        skill_score=skill_score,
        baseline_score=baseline_score,
        prev_skill_score=prev_skill_score,
        prev_baseline_score=prev_baseline_score,
        lift_report=lift_report,
        regressions=regressions,
        calibration=calibration,
        coverage_now=len(cell_scores),
        coverage_prev=coverage_prev,
        config=config,
    )

    pareto_dominated = (
        prev_scorecard is not None
        and prev_skill_score is not None
        and skill_score < prev_skill_score
    )

    return Scorecard(
        skill=skill,
        version=version,
        generated_at=timestamp,
        config={
            "component_weights": asdict(config.component_weights),
            "prompt_weights": asdict(config.prompt_weights),
            "runs_per_cell": config.runs_per_cell,
            "min_meaningful_lift": config.min_meaningful_lift,
            "fdr_q": config.fdr_q,
            "kappa_min": config.kappa_min,
        },
        n_cells=len(cell_scores),
        n_runs=len(runs),
        skill_score=skill_score,
        baseline_score=baseline_score,
        lift=lift_report,
        cells=cell_scores,
        modes=mode_scores,
        regressions=regressions,
        judge_calibration=calibration,
        pareto_dominated=pareto_dominated,
        verdict=verdict,
    )


# --------------------------------------------------------------------------- #
# Markdown report (the human-readable scorecard summary).
# --------------------------------------------------------------------------- #


def render_markdown_report(sc: Scorecard) -> str:
    lines: list[str] = []
    lines.append(f"# Scorecard: {sc.skill} @ {sc.version}")
    lines.append("")
    lines.append(f"**Generated:** {sc.generated_at}")
    lines.append(f"**Cells:** {sc.n_cells}  ·  **Runs:** {sc.n_runs}")
    lines.append("")
    lines.append("## Headline")
    lines.append("")
    lines.append(f"- **Skill score:** {sc.skill_score:.4f}")
    lines.append(f"- **Baseline score:** {sc.baseline_score:.4f}")
    lines.append(f"- **Mean lift:** {sc.lift.mean_lift:+.4f}")
    lines.append(f"- **Cliff's delta:** {sc.lift.cliffs_delta:+.3f}")
    p = sc.lift.wilcoxon_p
    lines.append(f"- **Wilcoxon p:** {p:.4f}" if p is not None else "- **Wilcoxon p:** n/a")
    lines.append(f"- **Pairs:** {sc.lift.n_pairs}")
    lines.append("")

    lines.append("## Verdict")
    lines.append("")
    if sc.verdict.promote:
        lines.append("**PROMOTE.** All five gates passed.")
    else:
        lines.append("**BLOCK.** Reasons:")
        for r in sc.verdict.reasons:
            lines.append(f"- `{r['kind']}` -- {json.dumps({k: v for k, v in r.items() if k != 'kind'})}")
    lines.append("")

    lines.append("## Judge calibration")
    cal = sc.judge_calibration
    if cal.kappa is None:
        lines.append(f"- gold cells: {cal.n_gold}  ·  kappa: n/a  ·  threshold: {cal.threshold}")
    else:
        lines.append(f"- gold cells: {cal.n_gold}  ·  kappa: {cal.kappa:.3f}  ·  threshold: {cal.threshold}  ·  passed: {cal.passed}")
    lines.append("")

    lines.append("## Per-mode lift")
    lines.append("")
    lines.append("| mode | weight | score_on | score_off | lift | pairs |")
    lines.append("|---|---:|---:|---:|---:|---:|")
    for m in sc.modes:
        lines.append(f"| {m.mode_id} | {m.weight:.3f} | {m.score_treatment:.3f} | {m.score_baseline:.3f} | {m.lift:+.3f} | {m.n_pairs} |")
    lines.append("")

    if sc.regressions:
        lines.append("## Per-cell regressions (BH-corrected)")
        lines.append("")
        lines.append("| cell | delta vs prev | p (BH) |")
        lines.append("|---|---:|---:|")
        for r in sc.regressions:
            lines.append(f"| {r.cell_id} | {r.delta_to_prev:+.3f} | {r.p_value:.4f} |")
        lines.append("")

    return "\n".join(lines)


# --------------------------------------------------------------------------- #
# CLI.
# --------------------------------------------------------------------------- #


def _scorecard_to_dict(sc: Scorecard) -> dict:
    return {
        "skill": sc.skill,
        "version": sc.version,
        "generated_at": sc.generated_at,
        "config": sc.config,
        "n_cells": sc.n_cells,
        "n_runs": sc.n_runs,
        "skill_score": sc.skill_score,
        "baseline_score": sc.baseline_score,
        "lift": asdict(sc.lift),
        "cells": [asdict(c) for c in sc.cells],
        "modes": [asdict(m) for m in sc.modes],
        "regressions": [asdict(r) for r in sc.regressions],
        "judge_calibration": asdict(sc.judge_calibration),
        "pareto_dominated": sc.pareto_dominated,
        "verdict": {
            "promote": sc.verdict.promote,
            "reasons": sc.verdict.reasons,
        },
    }


def main(argv: Optional[list[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="Score a meta-skill-improver eval run.")
    parser.add_argument("--runs", type=Path, required=True, help="Path to runs.jsonl")
    parser.add_argument("--config", type=Path, default=None, help="Path to grading.yaml (defaults loaded if absent)")
    parser.add_argument("--failure-modes", type=Path, default=None, help="Path to failure-modes.json")
    parser.add_argument("--gold", type=Path, default=None, help="Path to gold.jsonl")
    parser.add_argument("--prev", type=Path, default=None, help="Path to previous scorecard JSON")
    parser.add_argument("--skill", type=str, required=True, help="<plugin>:<skill> identifier")
    parser.add_argument("--version", type=str, required=True, help="Version of the skill being scored")
    parser.add_argument("--timestamp", type=str, default="", help="ISO timestamp; defaults to current time")
    parser.add_argument("--out", type=Path, required=True, help="Path to write the scorecard JSON")
    parser.add_argument("--out-md", type=Path, default=None, help="Optional path to write the markdown report")

    args = parser.parse_args(argv)

    runs = load_runs(args.runs)
    config = load_config(args.config)
    failure_mode_weights = load_failure_modes(args.failure_modes)
    prev_scorecard = load_prev_scorecard(args.prev)

    if not args.timestamp:
        from datetime import datetime, timezone
        args.timestamp = datetime.now(timezone.utc).isoformat()

    sc = grade(
        runs=runs,
        config=config,
        failure_mode_weights=failure_mode_weights,
        gold_path=args.gold,
        prev_scorecard=prev_scorecard,
        skill=args.skill,
        version=args.version,
        timestamp=args.timestamp,
    )

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(_scorecard_to_dict(sc), indent=2, default=str))
    if args.out_md:
        args.out_md.parent.mkdir(parents=True, exist_ok=True)
        args.out_md.write_text(render_markdown_report(sc))

    print(f"PROMOTE={sc.verdict.promote}  lift={sc.lift.mean_lift:+.4f}  delta={sc.lift.cliffs_delta:+.3f}  p={sc.lift.wilcoxon_p}  n={sc.lift.n_pairs}")
    return 0 if sc.verdict.promote else 1


if __name__ == "__main__":
    sys.exit(main())
