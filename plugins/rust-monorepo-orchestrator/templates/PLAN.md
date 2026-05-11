# PLAN -- <planning_unit>

> Output of `/rust-monorepo-orchestrator:plan-refactor <planning_unit>`. The
> sequenced ticket DAG that drives `/run-wave-ralph`. Tests-first per Anthropic
> Opus 4.7 long-horizon recipe.
>
> If `planning_unit` is a service name, this is a **service-level plan**
> covering all aggregates listed in `## Aggregates included` below, with
> cross-aggregate `depends_on` edges modeled explicitly. If `planning_unit`
> is a single aggregate, this is a legacy aggregate-level plan.

## Mission

One paragraph: the user's intent for this refactor. Inherited verbatim by every
HANDOFF.md in the run.

## Aggregates included

(Service mode only.) The aggregates this plan covers, in audit order:

- `<agg1>` -- <one-line summary of findings count + severity>
- `<agg2>` -- <one-line summary>
- ...

## Source artefacts

Per-aggregate inputs (service mode):

| Aggregate | chain.md | violations.md | rules dir | decisions.md |
|---|---|---|---|---|
| `<agg>` | `.refactor/domains/<agg>/chain.md` | `.refactor/domains/<agg>/violations.md` | `.refactor/rules/<agg>/` | (if present) |

Workspace-level:

- Standard: `.refactor/standard.md`
- Stack: `.refactor/stack.json`

## Tests-first manifest

Path: `.refactor/domains/<planning_unit>/tests.json`. Schema:

```json
{
  "tests": [
    {
      "id": "TEST-001",
      "command": "cargo test -p svc-api-users --test user_decider_purity",
      "before_state": "FAIL",
      "after_state": "PASS",
      "ties_to_violations": ["V-DEC-01"],
      "ties_to_tickets": ["T-013"],
      "aggregate": "user",
      "must_not_be_removed": true
    }
  ]
}
```

The verifier reads `tests.json` and refuses to mark any ticket `done`
that removes or weakens a test marked `must_not_be_removed: true`.

## Shared infrastructure tickets (cross-aggregate)

Tickets that serve every aggregate listed above. These ALWAYS land first;
every per-aggregate ticket depends on the relevant subset.

| Ticket | Objective | Allowed paths | Aggregates served |
|---|---|---|---|
| T-000 | manifest preamble (root Cargo.toml workspace + workspace deps) | `Cargo.toml`, `sgconfig.yml` | all |
| T-001 | lift libs/cqrs verbatim from reference; register in workspace | `libs/cqrs/**`, `Cargo.toml` | all |
| T-002 | lift libs/postgresql | `libs/postgresql/**`, `Cargo.toml` | all |
| T-003 | lift libs/kurrentdb | `libs/kurrentdb/**`, `Cargo.toml` | all |
| T-004 | lift libs/pubsub | `libs/pubsub/**`, `Cargo.toml` | all |
| T-005 | lift libs/otel | `libs/otel/**`, `Cargo.toml` | all |
| T-006 | delete broken libs/shared modules superseded by lifts | `libs/shared/src/**` | all |

## Per-aggregate ticket DAG

For each aggregate, the tickets specific to it. Tickets in this section have
`aggregate: <name>` in their frontmatter and at minimum depend on the relevant
shared-infrastructure tickets above.

### Aggregate: user

| Ticket | Objective | depends_on | allowed_paths | verifier |
|---|---|---|---|---|
| T-NNN | rename application/ to app/ | T-001..T-006 | `services/svc-api-users/src/{application,app}/**` | deterministic |
| T-NNN | introduce UserError typed enum | T-001 | `services/svc-api-users/src/domain/api.rs`, `src/domain/user_decider.rs` | llm |
| ... | ... | ... | ... | ... |

### Aggregate: kyc

(same shape)

### Aggregate: licence

(same shape)

### Aggregate: privacy_export

(same shape)

### Aggregate: privacy_erasure

(same shape)

## Wave width and ordering

- Default wave width: 5 parallel workers.
- Tickets prioritized by:
  1. `depends_on` topological order (mandatory).
  2. Highest leverage first within a tier (most consumers, most violations cleared).
  3. Smallest blast radius first (narrowest `allowed_paths` go first to minimize path-lock contention).
  4. Service-level plans: shared infrastructure tickets dispatched first to unblock per-aggregate parallelism.

The orchestrator does not need this ordering to be perfect -- path-locking
prevents collisions either way -- but better ordering means fewer rounds.

## Decisions required (human-in-the-loop)

Decisions the planner could not make. Surface to the user at the start of
`/run-wave-ralph`; the wave will not begin until each is resolved.

- <decision 1>: <options + tradeoffs>
- <decision 2>: <options + tradeoffs>

## Out of scope

- Cross-service migrations (e.g., svc-api-users's libs lift WILL break
  svc-api-bookings; that service is fixed in its own service-level plan).
- Read-store schema migrations beyond what aggregates' acceptance commands
  require.
- Performance work.

## Acceptance for the whole plan

- All tickets reference at least one violation in a per-aggregate violations.md.
- All tickets cite the rule(s) they make pass.
- `depends_on` graph is acyclic.
- `allowed_paths` for each ticket is a non-empty subset of the planning unit.
- `tests.json` has at least one test per ticket.
- DECISIONS_REQUIRED is non-empty if the planner had any uncertainty.
- Shared infrastructure tickets are de-duplicated (no five separate "lift libs/cqrs" tickets).
- Service-mode: every per-aggregate ticket has a `aggregate:` frontmatter field; shared tickets have it empty.

## Hard truths

Per Anthropic Opus 4.7 prompting docs (`HARD_TRUTHS` convention): close the
plan with the things that are true but uncomfortable.

- Some tickets cannot be parallelized; the critical path is N tickets long.
- Worker time estimates assume Opus 4.7 lead and Sonnet 4.6 workers.
- Service-mode plans break sibling services that depend on libs/shared modules being deleted; those services are fixed in their own service-level plans (out of scope here).
- Some violations cannot be fixed without API changes; those tickets are flagged
  `human-decision-required` and dispatched only after explicit acknowledgement.
