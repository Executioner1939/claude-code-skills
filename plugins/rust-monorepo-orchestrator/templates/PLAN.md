# PLAN -- <domain>

> Output of `/rust-monorepo-orchestrator:plan-refactor <domain>`. The
> sequenced ticket DAG that drives `/run-wave`. Tests-first per Anthropic
> Opus 4.7 long-horizon recipe.

## Mission

One paragraph: the user's intent for this domain refactor. Inherited
verbatim by every HANDOFF.md in the run.

## Source artefacts

- Violations: `<scope>/.refactor/domains/<domain>/violations.md`
- Standard: `<scope>/.refactor/standard.md`
- Rules: `<scope>/.refactor/rules/<domain>/*.yml`
- Stack: `<scope>/.refactor/stack.json`

## Tests-first manifest

Path: `<scope>/.refactor/domains/<domain>/tests.json`. Schema:

```json
{
  "tests": [
    {
      "id": "TEST-001",
      "command": "cargo test -p orders-domain --test decider_purity",
      "before_state": "FAIL",
      "after_state": "PASS",
      "ties_to_violations": ["V-007", "V-012"],
      "ties_to_tickets": ["T-007", "T-012"],
      "must_not_be_removed": true
    }
  ]
}
```

The verifier reads `tests.json` and refuses to mark any ticket `done`
that removes or weakens a test marked `must_not_be_removed: true`.

## Ticket DAG

Tickets are sequenced by `depends_on`. The orchestrator runs the
topological wavefront -- every ticket whose dependencies are `done` is
eligible to dispatch, modulo path-locking.

| Ticket | Objective summary | Depends on | Allowed paths | Estimated worker turns |
|---|---|---|---|---|
| T-001 | <one-line> | -- | `src/domain/orders/decider.rs` | 10 |
| T-002 | <one-line> | -- | `src/domain/orders/view.rs` | 8 |
| T-003 | <one-line> | T-001 | `src/application/orders/handler.rs` | 15 |
| ... | ... | ... | ... | ... |

Tickets live as files under `<scope>/.refactor/inbox/<domain>/pending/T-NNN.md`.

## Wave width and ordering

- Default wave width: 5 parallel workers.
- Tickets prioritized by:
  1. `depends_on` topological order (mandatory).
  2. Highest leverage first within a tier (most consumers, most violations cleared).
  3. Smallest blast radius first (narrowest `allowed_paths` go first to minimize path-lock contention).

The orchestrator does not need this ordering to be perfect -- path-locking
prevents collisions either way -- but better ordering means fewer rounds.

## Decisions required (human-in-the-loop)

Decisions the planner could not make. Surface to the user at the start of
`/run-wave`; the wave will not begin until each is resolved.

- <decision 1>: <options + tradeoffs>
- <decision 2>: <options + tradeoffs>

## Out of scope (this domain only)

- Cross-domain integration events (separate domain run).
- Read-store schema migrations (separate planning step).
- Performance work.

## Acceptance for the whole plan

- All tickets reference at least one violation in `violations.md`.
- All tickets cite the rule(s) they make pass.
- `depends_on` graph is acyclic.
- `allowed_paths` for each ticket is a non-empty subset of the domain.
- `tests.json` has at least one test per ticket.
- DECISIONS_REQUIRED is non-empty if the planner had any uncertainty.

## Hard truths

Per Anthropic Opus 4.7 prompting docs (`HARD_TRUTHS` convention from
the codebase-archaeology plugin): close the plan with the things that are
true but uncomfortable. Examples:

- Some tickets cannot be parallelized; the critical path is N tickets long.
- Worker time estimates assume Opus 4.7 lead and Sonnet 4.6 workers; downgrade either and estimates inflate.
- Some violations cannot be fixed without API changes; those tickets are flagged
  `human-decision-required` and dispatched only after explicit acknowledgement.
