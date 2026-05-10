---
name: snapshot-anonymization
description: |
  Rules for converting a real failing repository fragment (e.g. hermes-platform/.moon/services/guardian_agent_service) into an anonymized minimum-reproducer snapshot the eval harness can run without leaking client/repo identity. Covers the deterministic name-mapping table, the things-to-scrub-but-keep-realistic policy, and the manual-review gate before a fixture lands on disk. Auto-loads when the snapshot-builder agent runs, when fixtures are being built, when the user asks "anonymize this snapshot", "scrub the names", "fixture privacy", or "minimum reproducer".
allowed-tools: Read, Grep, Glob, Bash
---

# Snapshot anonymization -- the rules

A snapshot is the smallest filesystem fragment that reproduces a failure mode. It must:

1. Reproduce the failure when the harness runs against it (high fidelity).
2. Carry no identifying information about the source repository (privacy).
3. Stay realistic -- structural shape and token-shape must match the real world (so the agent does not skill-pattern-match a "this is a test" smell).

These three pull in opposite directions. The rules below resolve the tradeoffs.

## Deterministic name-mapping

Maintain a per-skill mapping `evals/<skill>/_name_map.json`:

```json
{
  "hermes-platform":              "example_repo_a",
  "tictaps-platform":             "example_repo_b",
  "borg-platform":                "example_repo_c",
  "guardian_agent_service":       "acme_widget_service",
  "guardian-agent-service":       "acme-widget-service",
  "GuardianAgent":                "AcmeWidget",
  "Hermes Platform":              "Example Platform A",
  "shadowrhyder@gmail.com":       "user@example.com"
}
```

Apply via a single substitution pass (longest match first; case-preserving variants enumerated explicitly so kebab and snake and camel are all caught). Same input -> same output, every time.

**Why deterministic:** if the same name appears in two snapshots, it should map to the same anonymized name. Cross-fixture coherence helps when a failure mode involves two repos calling each other.

## What to scrub

| Category                           | Action                                                     |
| ---------------------------------- | ---------------------------------------------------------- |
| Internal repo names                | Map to `example_repo_<a/b/c>`                              |
| Internal service / project names   | Map to `acme_<noun>_service`                               |
| Internal team / user identifiers   | Map to generic `team_alpha`, `user_a`                      |
| Email addresses                    | Map to `user@example.com`                                  |
| URLs to internal domains           | Map to `example.com` paths                                 |
| API keys, tokens, secrets          | Replace with literal `<REDACTED>` (never partial)          |
| IP addresses                       | Map to `192.0.2.x` (TEST-NET-1)                            |
| Internal Linear / Jira IDs         | Map to `TICKET-1`, `TICKET-2` ...                          |
| Internal Slack channel names       | Map to `#channel-a`, `#channel-b`                          |
| File paths embedding internal names| Apply name-map to each segment                             |
| Author info in git metadata        | Strip if present in fixture; the harness checks out fresh  |

## What to keep realistic

| Category                                | Action                                              |
| --------------------------------------- | --------------------------------------------------- |
| Programming languages and tooling       | Keep verbatim. `moon`, `tsc`, `cargo`, etc.        |
| Public package names                    | Keep verbatim (they are not internal).             |
| Standard config field names and values  | Keep verbatim. `language: typescript` stays.       |
| File structure depth and shape          | Preserve. `services/<name>/src/...` keeps depth.   |
| Numeric magnitudes                      | Preserve order of magnitude. A 500-line file stays a 500-line file. |
| Error messages (when from public tools) | Keep verbatim. The agent will see `moon` errors. |

If a value is "internal but not identifying" (e.g., a port number `8080` or a feature flag like `enable_new_pricing`), keep it. The agent should see realistic config noise.

## What to delete

Sometimes the cleanest fix is removal:

- Files unrelated to the failure mode (vendored binaries, lockfiles for unrelated services).
- Source files larger than the failure mode requires (extract just the function or section needed).
- Comments containing PII or internal context that doesn't help reproduce the failure.

The snapshot is a **minimum** reproducer. Anything that does not contribute to triggering the failure should be cut.

## Verification before commit

Before a snapshot lands in `evals/<skill>/snapshots/<mode-id>/`:

1. **Reproduce check.** Run the failure-mode's deterministic post-condition against the snapshot in baseline state. It must FAIL (otherwise the snapshot does not actually carry the failure).
2. **Anonymization check.** Grep the snapshot tree for any source-repo name (case-insensitive) and any source identifier (the original service names, the original user emails). Zero hits required.
3. **Realism check.** A second human (or a Claude review pass with a separate context) reads the snapshot and tries to identify the source. If they can, the anonymization is incomplete.

The snapshot-builder agent's HANDOFF.md includes the results of all three checks. The orchestrator does not proceed without them.

## On retaining real file contents vs structural shape only

Two reasonable answers:

- **Real contents (with name scrubbing).** Higher fidelity to the real failure. Higher anonymization burden.
- **Structural shape (regenerated contents).** Safer. Lower fidelity -- the agent may not encounter the same surface details that cause the failure to resolve.

This plugin's default policy: **real contents + aggressive name-scrubbing + manual review gate**. The fidelity-vs-safety tradeoff lands on the fidelity side because the failure modes we care about are tooling-shape failures (moon config, terraform module composition, build setup) where the surface details matter for the agent's diagnostic process.

If a snapshot cannot be sufficiently anonymized while preserving the failure (rare), the snapshot-builder writes a "blocked" handoff and the orchestrator drops that failure mode from this run.

## File-tree convention

```
evals/<skill>/snapshots/<mode-id>/
  README.md              # what this snapshot represents; the failure-mode id; the post-condition that should fail in baseline
  baseline/              # the broken state -- this is what the agent receives
    <project tree>
  expected/              # OPTIONAL: a known-good state for reference (the post-condition compares structurally, not byte-equal, so this is a guide, not an oracle)
    <project tree>
  _name_map.snippet.json # the slice of the global _name_map used by this snapshot (for review)
```

The `baseline/` tree is what gets copied into the worktree per cell. The `expected/` tree is human reference only, never used as a grader oracle (the post-condition function does the grading).

## Per-mode post-condition

Lives at `evals/<skill>/postconds/<mode-id>.py`. A pure function:

```python
def check(workdir: pathlib.Path) -> PostCondResult:
    """Run after the agent finishes. workdir is the agent's worktree.
    Return PostCondResult(passed: bool, score: float in [0,1], details: list[str])."""
```

Examples:
- `subprocess.run(["moon", "check"], cwd=workdir).returncode == 0`
- Parse `workdir / ".moon" / "workspace.yml"` and confirm `language` field is set
- Diff `workdir / "<file>"` against an expected schema

The post-condition function defines `correctness` (one of the five score components) for this failure mode. It must be deterministic, fast (no network), and pure.
