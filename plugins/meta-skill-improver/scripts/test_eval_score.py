#!/usr/bin/env python3
"""Smoke test for eval_score.py with synthetic runs.

Builds a runs.jsonl where the answer is known by construction (skill_on cells
beat skill_off cells by exactly 0.20 on every cell) and confirms the grader
returns a meaningful lift, a positive Cliff's delta, and a PROMOTE verdict
when the gold set is consistent.

Run: python3 test_eval_score.py
"""

from __future__ import annotations

import json
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import eval_score as es


def synth_run(cell_id: str, mode_id: str, prompt_class: str, condition: str, trial: int,
              corr: float, no_reg: float, attr: float, eff: float, rc: float | None = 0.5) -> dict:
    return {
        "cell_id": cell_id,
        "trial_index": trial,
        "mode_id": mode_id,
        "prompt_id": f"{mode_id}--{prompt_class}--0",
        "prompt_class": prompt_class,
        "condition": condition,
        "skill_version": "test-v0.1",
        "components": {
            "correctness": corr,
            "root_cause": rc,
            "no_regression": no_reg,
            "skill_attribution": attr,
            "efficiency": eff,
        },
        "turns_used": 10,
        "timestamp": "2026-05-10T12:00:00Z",
    }


def build_runs_jsonl(path: Path) -> None:
    """Two failure modes, four prompt classes, two conditions, 5 trials each.
    Treatment beats baseline by 0.20 on the composite for every cell."""
    runs: list[dict] = []
    for mode_id in ["mode-alpha", "mode-beta"]:
        for cls in ["vague-real", "explicit-flawed-real", "synthetic-correct", "adversarial"]:
            for cond in ["skill_on", "skill_off"]:
                for trial in range(5):
                    if cond == "skill_on":
                        corr, rc, no_reg, attr, eff = 0.90, 0.85, 0.95, 1.0, 0.80
                    else:
                        corr, rc, no_reg, attr, eff = 0.55, 0.50, 0.90, 0.0, 0.70
                    runs.append(synth_run(
                        cell_id=f"{mode_id}--{cls}--0--{cond}",
                        mode_id=mode_id,
                        prompt_class=cls,
                        condition=cond,
                        trial=trial,
                        corr=corr, rc=rc, no_reg=no_reg, attr=attr, eff=eff,
                    ))
    with path.open("w") as f:
        for r in runs:
            f.write(json.dumps(r) + "\n")


def build_failure_modes_json(path: Path) -> None:
    data = {
        "topic": "synthetic test",
        "target_skill": "test-plugin:test-skill",
        "generated_at": "2026-05-10T12:00:00Z",
        "repos_scanned": [],
        "failure_modes": [
            {
                "id": "mode-alpha", "title": "Alpha mode", "summary": "alpha",
                "frequency": 0.8, "severity": 0.7, "recency": 0.9, "weight": 0.504,
                "incidents": [{"source": "transcript", "repo": "synthetic", "ref": "abc", "when": "2026-05-01T00:00:00Z", "excerpt": "x"}],
                "candidate_post_conditions": ["x"],
                "candidate_skill_rule": "do x"
            },
            {
                "id": "mode-beta", "title": "Beta mode", "summary": "beta",
                "frequency": 0.3, "severity": 0.5, "recency": 0.7, "weight": 0.105,
                "incidents": [{"source": "transcript", "repo": "synthetic", "ref": "def", "when": "2026-05-01T00:00:00Z", "excerpt": "y"}],
                "candidate_post_conditions": ["y"],
                "candidate_skill_rule": "do y"
            }
        ]
    }
    path.write_text(json.dumps(data, indent=2))


def build_gold_jsonl(path: Path, agreement: str) -> None:
    """Build a gold set. agreement='high' -> kappa >= 0.6; agreement='low' -> kappa < 0.6."""
    pairs = []
    if agreement == "high":
        # Both raters agree on every item.
        for human in [0.1, 0.3, 0.5, 0.5, 0.7, 0.7, 0.9, 0.9, 0.9, 0.9]:
            pairs.append((human, human))
    else:
        # Anti-correlated.
        for h, j in zip([0.1, 0.3, 0.5, 0.7, 0.9, 0.1, 0.3, 0.5, 0.7, 0.9],
                        [0.9, 0.7, 0.5, 0.3, 0.1, 0.9, 0.7, 0.5, 0.3, 0.1]):
            pairs.append((h, j))
    with path.open("w") as f:
        for i, (h, j) in enumerate(pairs):
            f.write(json.dumps({"cell_id": f"gold-{i}", "human_score": h, "judge_score": j}) + "\n")


def assert_close(label: str, actual: float, expected: float, tol: float = 0.05) -> None:
    if abs(actual - expected) > tol:
        raise AssertionError(f"{label}: expected ~{expected}, got {actual}")
    print(f"  OK  {label}: {actual:.4f} (expected ~{expected})")


def expect_true(label: str, cond: bool) -> None:
    if not cond:
        raise AssertionError(f"{label}: expected True")
    print(f"  OK  {label}")


def expect_false(label: str, cond: bool) -> None:
    if cond:
        raise AssertionError(f"{label}: expected False")
    print(f"  OK  {label} (got False as expected)")


def main() -> int:
    with tempfile.TemporaryDirectory() as tmpdir:
        tmp = Path(tmpdir)
        runs_path = tmp / "runs.jsonl"
        modes_path = tmp / "failure-modes.json"
        gold_high = tmp / "gold-high.jsonl"
        gold_low = tmp / "gold-low.jsonl"

        build_runs_jsonl(runs_path)
        build_failure_modes_json(modes_path)
        build_gold_jsonl(gold_high, "high")
        build_gold_jsonl(gold_low, "low")

        runs = es.load_runs(runs_path)
        config = es.GradingConfig()
        weights = es.load_failure_modes(modes_path)

        print(f"\nLoaded {len(runs)} runs across {len({r.cell_id for r in runs})} cells")

        # Test 1: with high-agreement gold, scorecard should PROMOTE.
        print("\n[1] high-kappa gold, treatment dominates baseline -> expect PROMOTE")
        sc_high = es.grade(
            runs=runs, config=config, failure_mode_weights=weights,
            gold_path=gold_high, prev_scorecard=None,
            skill="test-plugin:test-skill", version="0.1.0",
            timestamp="2026-05-10T12:00:00Z",
        )
        # By construction skill_on composite = 0.40*0.90 + 0.30*0.85 + 0.15*0.95 + 0.05*1.00 + 0.10*0.80 = 0.8875
        # skill_off composite                = 0.40*0.55 + 0.30*0.50 + 0.15*0.90 + 0.05*0.00 + 0.10*0.70 = 0.575
        # lift                               = 0.3125
        assert_close("skill_score (treatment, freq-weighted)", sc_high.skill_score, 0.8875, tol=0.02)
        assert_close("baseline_score", sc_high.baseline_score, 0.575, tol=0.02)
        assert_close("mean_lift", sc_high.lift.mean_lift, 0.3125, tol=0.02)
        expect_true("Cliff's delta strongly positive", sc_high.lift.cliffs_delta > 0.9)
        expect_true("judge calibration passed", sc_high.judge_calibration.passed)
        expect_true("PROMOTE verdict", sc_high.verdict.promote)
        expect_false("no block reasons", bool(sc_high.verdict.reasons))

        # Test 2: low-kappa gold should block on JudgeDrift even with great lift.
        print("\n[2] low-kappa gold (anti-correlated) -> expect BLOCK due to JudgeDrift")
        sc_low = es.grade(
            runs=runs, config=config, failure_mode_weights=weights,
            gold_path=gold_low, prev_scorecard=None,
            skill="test-plugin:test-skill", version="0.1.0",
            timestamp="2026-05-10T12:00:00Z",
        )
        expect_false("PROMOTE blocked", sc_low.verdict.promote)
        kinds = {r["kind"] for r in sc_low.verdict.reasons}
        expect_true("JudgeDrift in reasons", "JudgeDrift" in kinds)

        # Test 3: feed prior scorecard with same scores; lift-vs-prev should fail.
        print("\n[3] prior scorecard identical -> expect BLOCK on LiftBelowThreshold")
        prev = json.loads(json.dumps(es._scorecard_to_dict(sc_high), default=str))
        sc_repeat = es.grade(
            runs=runs, config=config, failure_mode_weights=weights,
            gold_path=gold_high, prev_scorecard=prev,
            skill="test-plugin:test-skill", version="0.2.0",
            timestamp="2026-05-10T13:00:00Z",
        )
        expect_false("repeat does not promote", sc_repeat.verdict.promote)
        kinds = {r["kind"] for r in sc_repeat.verdict.reasons}
        expect_true("LiftBelowThreshold in reasons", "LiftBelowThreshold" in kinds)

        # Markdown render does not crash.
        md = es.render_markdown_report(sc_high)
        expect_true("markdown report includes PROMOTE", "PROMOTE" in md)
        expect_true("markdown report includes Headline", "## Headline" in md)

    print("\nAll smoke tests passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
