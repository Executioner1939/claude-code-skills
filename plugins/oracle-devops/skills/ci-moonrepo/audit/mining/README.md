# Mining harness for adjacent-fix detection

The 1.2.0 audit revealed that the existing 7-assertion grader cannot
discriminate between skill variants -- both score 100% because the
assertions only check that the agent diagnosed *the named failure
mode*, not that the agent caught the *adjacent* fixes that real
incidents always carry alongside.

This directory builds the co-occurrence table that an upgraded grader
can score against.

## Sources

Two mining surfaces feed the same JSON output:

| Script | Surface | Best for |
|---|---|---|
| `mine-transcripts.py` | Claude Code session transcripts (`~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`) | Discovering pairs the agent has *previously missed* -- the user had to redirect mid-session |
| `mine-ci-chains.py` | `git log` on a target production repo | Discovering pairs that *real engineers* missed and had to come back to fix in a follow-up commit |

Both emit the same `co-occurrences.json` schema (see below), so the
grader can read either one or merge both.

## Output schema (`co-occurrences.json`)

```json
{
  "version": 1,
  "generated_at": "2026-05-17T10:30:00Z",
  "source": "transcripts | ci-chains | merged",
  "failure_modes": {
    "moon-affected-detection-misses-targets": {
      "co_occurring_paths": [
        {
          "primary": ".github/workflows/ci.yaml",
          "adjacent": ".moon/tasks/rust.yml",
          "count": 7,
          "evidence": [
            {"type": "ci-chain", "repo": "acme-platform/repo-a", "commits": ["abc123", "def456"], "window_minutes": 23},
            {"type": "transcript", "session": "0aa1ab44-...", "redirect_turn": 12}
          ]
        }
      ],
      "co_occurring_globs": [
        {"primary_glob": ".github/workflows/*.yaml", "adjacent_glob": ".moon/tasks/**/*.yml", "count": 14}
      ]
    }
  }
}
```

## Failure-mode classification

Both miners use the same keyword classifier (`classifier.py`) to label
a session or commit-chain with a failure-mode id. The classifier
keywords are lifted verbatim from the `description:` and `keywords:`
fields of `plugins/oracle-devops/skills/ci-moonrepo/SKILL.md`, so the
mining surface drifts in lockstep with the skill's trigger surface.

A session / chain that matches keywords for two failure modes is
labelled `multi` and contributes to both. A session / chain with no
keyword hits is dropped.

## How the grader consumes this

The grader's new assertion: *for the diagnosed failure mode, the
agent's `files_changed.txt` must include at least K of the top-N
co-occurring adjacent paths.* `K` and `N` are tunable per failure
mode (suggested defaults: N=5, K=2). A failing co-occurrence is
strong signal: it means the agent diagnosed the symptom but missed a
fix that *real engineers chasing the same symptom needed to apply*.

See `grader-extension.md` for the exact assertion text and a
worked example.

## Running

```bash
# Transcript mining (local ~/.claude/projects)
python3 plugins/oracle-devops/skills/ci-moonrepo/audit/mining/mine-transcripts.py \
  --projects-root ~/.claude/projects \
  --output plugins/oracle-devops/skills/ci-moonrepo/audit/mining/co-occurrences.transcripts.json

# CI commit-chain mining (point at any moon-using repo)
python3 plugins/oracle-devops/skills/ci-moonrepo/audit/mining/mine-ci-chains.py \
  --repo /path/to/production/repo \
  --window-minutes 60 \
  --since 2025-01-01 \
  --output plugins/oracle-devops/skills/ci-moonrepo/audit/mining/co-occurrences.ci-chains.json

# Merge (later -- not yet implemented; the grader can read either file)
```

## Why both surfaces

CI commit chains are the higher-signal source -- timestamps are
objective, "missed-fix" semantics are unambiguous (the later commit
*literally fixed something the earlier one didn't*), and the data is
publicly verifiable. Transcript mining covers the cases that never
made it to commit: the user redirected the agent within the same
session and the agent then converged on the right answer before
committing. Both are useful; CI is more authoritative.

## Limitations

- The classifier is keyword-based, not semantic. Borderline cases
  will mislabel; manual review of the top-50 co-occurrences before
  feeding them into the grader is recommended for the first run.
- Transcript mining cannot distinguish "user redirected agent" from
  "user added a new ask in the same session". The current heuristic
  -- count only file pairs where the second file was edited after a
  user turn that contains an explicit reference to that file's domain
  -- is conservative; it under-reports rather than over-reports.
- CI chain mining requires a target repo with enough moon-touching
  history to produce signal. A new repo with < 50 moon commits will
  not generate useful pairs.
