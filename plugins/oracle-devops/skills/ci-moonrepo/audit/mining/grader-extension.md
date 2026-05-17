# Grader extension: adjacent-fix coverage assertion

The existing 7-assertion template scored 42/42 on both 1.1.0 and 1.2.0
of the ci-moonrepo skill. To discriminate between variants, the grader
needs an assertion that looks beyond "did the agent diagnose the named
failure mode" to "did the agent catch the fixes that real engineers
chasing the same symptom also needed to apply".

This document specifies the assertion shape and how to read it from
`co-occurrences.json`.

## Assertion text (template)

For each eval, add:

> For failure mode `<F>`, the agent's `files_changed.txt` includes at
> least `K` of the top-`N` co-occurring adjacent paths recorded in
> `co-occurrences.json::failure_modes[F].co_occurring_paths[:N]`.

Suggested defaults: `N = 5`, `K = 2`. Tune per failure mode based on the
co-occurrence count distribution -- a long-tail mode where the top-5
pairs each have count >= 5 can afford `K = 3`; a sparse mode where the
top pair has count = 2 should drop to `K = 1`.

## Grader procedure

```python
import json, pathlib

def adjacent_fix_coverage(eval_dir: pathlib.Path, fm_id: str,
                          co_occurrences: dict, N: int = 5, K: int = 2) -> tuple[bool, str]:
    """Returns (passed, evidence_string)."""
    files_changed = set(
        (eval_dir / "outputs" / "files_changed.txt").read_text().splitlines()
    )
    fm = co_occurrences.get("failure_modes", {}).get(fm_id, {})
    top_pairs = fm.get("co_occurring_paths", [])[:N]
    if not top_pairs:
        return True, f"no co-occurrences recorded for {fm_id}; assertion vacuously passes"

    # An adjacent path matches if any of the files_changed *ends with* it
    # (transcript / CI paths may be absolute while files_changed.txt is repo-relative).
    def covered(adj: str) -> bool:
        return any(fc.endswith(adj) or fc == adj for fc in files_changed)

    matched = [p for p in top_pairs if covered(p["adjacent"])]
    passed = len(matched) >= K
    ev = (
        f"matched {len(matched)}/{len(top_pairs)} top pairs (threshold K={K}); "
        f"matched: {[p['adjacent'] for p in matched]}"
    )
    return passed, ev
```

Wire this into the grader subagent's `grading.json` writer:

```json
{
  "expectations": [
    ...,
    {
      "text": "Adjacent-fix coverage: caught >= 2 of top-5 co-occurring paths for moon-affected-detection-misses-targets",
      "passed": false,
      "evidence": "matched 1/5 top pairs (threshold K=2); matched: ['.gitignore']"
    }
  ]
}
```

## Worked example

Imagine `co-occurrences.json` (mined from a target prod repo) contains:

```json
{
  "failure_modes": {
    "moon-affected-detection-misses-targets": {
      "co_occurring_paths": [
        {"primary": ".github/workflows/ci.yaml", "adjacent": ".moon/tasks/rust.yml", "count": 8},
        {"primary": ".github/workflows/ci.yaml", "adjacent": ".gitignore", "count": 5},
        {"primary": ".github/workflows/ci.yaml", "adjacent": ".moon/workspace.yml", "count": 4},
        {"primary": ".github/workflows/ci.yaml", "adjacent": "services/api/moon.yml", "count": 3},
        {"primary": ".moon/tasks/rust.yml", "adjacent": ".prototools", "count": 3}
      ]
    }
  }
}
```

Now grade two agents that both diagnosed the failure mode correctly:

- **Agent A** edited `.github/workflows/ci.yaml` and `.moon/tasks/rust.yml`.
  Matches `top_pairs[0].adjacent`. 1/5 matched. With K=2 -> **fail**.
- **Agent B** edited `.github/workflows/ci.yaml`, `.moon/tasks/rust.yml`,
  `.gitignore`. Matches pairs 0 and 1. 2/5 matched. With K=2 -> **pass**.

This separates "diagnosed the symptom" (both) from "applied the same
adjacent fix real engineers needed" (only B).

## Why this works

The 7-assertion template asks *did the agent recognise the failure
mode*. That's a recall question. The 1.1.0 skill answers it (the
failure-mode rules are essay-form but complete). The 1.2.0 skill
answers it (the failure-mode rules are decision-tree form but the same
content). Both pass.

The adjacent-fix assertion asks *did the agent reach the same scope
real engineers reached*. That's a precision-of-scope question. The
ground truth is in the commit chains -- engineers chasing this exact
symptom in production touched these exact files. An agent that edits
fewer files than the real chain is doing less work than the incident
demanded. An agent that edits more files is over-reaching (caught by
the count threshold; the top-N filter excludes pairs that only
appeared in one chain).

## Tuning the co-occurrence table

After the first mining run, do a manual review of the top-50 pairs
across all failure modes:

- Drop pairs where the "adjacent" is generic noise (`README.md`,
  `package.json` from an unrelated update).
- Promote pairs that look one-off but represent a known landmine.

The mining scripts emit `evidence` per pair so the reviewer can click
through to the original commit / transcript to make this call. The
reviewed table is what feeds the grader.

## Re-running the audit

After the grader is extended:

```bash
# 1. Mine
python3 evals/ci-moonrepo--ci-moonrepo/mining/mine-transcripts.py \
    --output evals/ci-moonrepo--ci-moonrepo/mining/co-occurrences.transcripts.json -v

python3 evals/ci-moonrepo--ci-moonrepo/mining/mine-ci-chains.py \
    --repo /path/to/prod/repo \
    --window-minutes 60 \
    --output evals/ci-moonrepo--ci-moonrepo/mining/co-occurrences.ci-chains.json -v

# 2. Manually review and merge into co-occurrences.reviewed.json

# 3. Re-run iteration-2 with grader pointing at co-occurrences.reviewed.json
```

If 1.2.0 still ties 1.1.0 on the upgraded assertion set, the
restructure produced no behavioural improvement (only readability /
maintenance gains, which the audit cannot measure). If 1.2.0 wins,
that's the formal discrimination signal you were missing.
