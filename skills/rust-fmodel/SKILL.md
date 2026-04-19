---
name: fmodel-rust
description: >
  Guide for building event-sourced and CQRS systems in Rust using the fmodel-rust library
  (crate: fmodel-rust). Covers Decider, View, Saga domain types, their composition via
  combine/merge/map, and application-layer wiring (EventSourcedAggregate,
  StateStoredAggregate, orchestrating aggregates, MaterializedView, SagaManager).
  Use this skill whenever the user mentions fmodel, fmodel-rust, functional domain modeling
  in Rust, or is building event-sourced / CQRS systems in Rust with deciders, views, sagas,
  or aggregates. Also trigger when the user asks about composing deciders, merging views,
  Sum types for domain composition, EventSourcedOrchestratingAggregate, or the
  decide/evolve/initial_state pattern. Even if the user just says "decider pattern" or
  "event sourcing in Rust" in a context where fmodel-rust is a dependency, use this skill.
---

# fmodel-rust -- Functional Domain Modeling in Rust

fmodel-rust (v0.9.x, currently 0.9.1 on crates.io) is a composition library for building
event-sourced and CQRS systems. Its core idea: domain logic is expressed as pure values
(Decider, View, Saga) that compose algebraically, then get wired to infrastructure via
application-layer types.

Requires Rust **1.75+** (the crate uses native async-fn-in-trait / RPIT, no `async-trait`
crate). Application-layer trait impls should use bare `async fn` — see the repository
example further down.

## Architecture

Two layers with a strict boundary:

```
Domain Layer (pure, no I/O, no async)
  Decider<C, S, E, Error>   -- command handling + state evolution
  View<S, E>                 -- event-driven read model projection
  Saga<AR, A>                -- reactive event-to-command mapping

Application Layer (async, I/O, side effects)
  EventSourcedAggregate      -- decider + event store
  StateStoredAggregate       -- decider + state store
  *OrchestratingAggregate    -- decider + saga (transactional feedback loop)
  MaterializedView           -- view + state repository
  SagaManager                -- saga + action publisher
```

Domain types compose via algebraic operations. Application types wire composed domain
types to infrastructure. Never put I/O in domain types. Never put business logic in
application types.

## The Three Domain Types

### Decider -- The Core Decision Maker

A Decider encapsulates all command-handling and state-evolution logic for an aggregate.
It is parameterized by four types: Command, State, Event, and Error.

```rust
use fmodel_rust::decider::Decider;

fn order_decider<'a>() -> Decider<'a, OrderCommand, OrderState, OrderEvent, OrderError> {
    Decider {
        // Given a command and current state, produce events (or reject)
        decide: Box::new(|cmd, state| match cmd {
            OrderCommand::Create(c) => {
                if state.created {
                    return Err(OrderError::AlreadyExists);
                }
                Ok(vec![OrderEvent::Created(OrderCreatedEvent {
                    order_id: c.order_id.clone(),
                    customer: c.customer.clone(),
                    items: c.items.clone(),
                })])
            }
            OrderCommand::Cancel(c) => {
                if !state.created || state.cancelled {
                    return Err(OrderError::InvalidState);
                }
                Ok(vec![OrderEvent::Cancelled(OrderCancelledEvent {
                    order_id: c.order_id.clone(),
                })])
            }
        }),
        // Given current state and an event, produce new state (infallible)
        evolve: Box::new(|state, event| match event {
            OrderEvent::Created(e) => OrderState {
                order_id: e.order_id.clone(),
                customer: e.customer.clone(),
                items: e.items.clone(),
                created: true,
                cancelled: false,
            },
            OrderEvent::Cancelled(_) => OrderState {
                cancelled: true,
                ..state.clone()
            },
        }),
        // The zero-value for state before any events
        initial_state: Box::new(|| OrderState::default()),
    }
}
```

**Key traits implemented by Decider:**

- `EventComputation` -- `compute_new_events(&[E], &C) -> Result<Vec<E>, Error>`
  Folds events into state via `evolve`, then calls `decide`. Use for event-sourced flow.

- `StateComputation` -- `compute_new_state(Option<S>, &C) -> Result<S, Error>`
  Calls `decide` on current state, then folds resulting events. Use for state-stored flow.

### View -- Read Model Projection

A View projects events into a read-model state. No commands, no errors -- just
evolve and initial_state.

```rust
use fmodel_rust::view::View;

fn order_view<'a>() -> View<'a, OrderViewState, OrderEvent> {
    View {
        evolve: Box::new(|state, event| match event {
            OrderEvent::Created(e) => OrderViewState {
                order_id: e.order_id.clone(),
                customer: e.customer.clone(),
                item_count: e.items.len(),
                status: "ACTIVE".into(),
            },
            OrderEvent::Cancelled(_) => OrderViewState {
                status: "CANCELLED".into(),
                ..state.clone()
            },
        }),
        initial_state: Box::new(|| OrderViewState::default()),
    }
}
```

**Trait:** `ViewStateComputation` -- `compute_new_state(Option<S>, &[&E]) -> S`

### Saga -- Reactive Event-to-Command Mapping

A Saga reacts to events (action results) by producing commands (actions). Pure function,
no state, no I/O.

```rust
use fmodel_rust::saga::Saga;

fn order_to_shipment_saga<'a>() -> Saga<'a, OrderEvent, ShipmentCommand> {
    Saga {
        react: Box::new(|event| match event {
            OrderEvent::Created(e) => vec![ShipmentCommand::Create(CreateShipmentCommand {
                shipment_id: Uuid::new_v4(),
                order_id: e.order_id.clone(),
                items: e.items.clone(),
            })],
            _ => vec![],
        }),
    }
}
```

**Trait:** `ActionComputation` -- `compute_new_actions(&AR) -> Vec<A>`

## Composition

This is fmodel's distinguishing feature. Domain types compose algebraically using
Sum types (coproducts) and tuples (products).

### Sum Types

fmodel provides `Sum<A, B>` through `Sum6<A, B, C, D, E, F>` for type-safe coproducts:

```rust
use fmodel_rust::Sum;

// After combining two deciders, commands become Sum<C1, C2>
// and events become Sum<E1, E2>
enum Sum<A, B> {
    First(A),
    Second(B),
}
```

### Combining Deciders

`combine()` merges two deciders into one that handles both command/event types:

```rust
let combined = order_decider()
    .map_error(|e| AppError::Order(e.clone()))
    .combine(
        shipment_decider().map_error(|e| AppError::Shipment(e.clone()))
    );
// Type: Decider<Sum<OrderCmd, ShipmentCmd>, (OrderState, ShipmentState), Sum<OrderEvent, ShipmentEvent>, AppError>
```

To use unified domain enums instead of Sum types, apply mapping functions:

```rust
let mapped = combined
    .map_command(|cmd: &AppCommand| match cmd {
        AppCommand::Order(c) => Sum::First(c.clone()),
        AppCommand::Shipment(c) => Sum::Second(c.clone()),
    })
    .map_event(
        |sum| match sum {  // Sum -> unified
            Sum::First(e) => AppEvent::Order(e.clone()),
            Sum::Second(e) => AppEvent::Shipment(e.clone()),
        },
        |evt| match evt {  // unified -> Sum
            AppEvent::Order(e) => Sum::First(e.clone()),
            AppEvent::Shipment(e) => Sum::Second(e.clone()),
        },
    );
```

### Merging Views

`merge()` combines views that share the same event type into a single view with
tuple state:

```rust
let merged = order_view().merge(shipment_view());
// Type: View<(OrderViewState, ShipmentViewState), AppEvent>
```

Both views process every event. Use `merge` (not the deprecated `combine`) because
views typically subscribe to the same event stream.

### Merging Sagas

`merge()` combines sagas that share the same action-result type. Prefer `merge` over
`Saga::combine` — the latter is deprecated for the same reason `View::combine` is.

```rust
let merged = order_to_shipment_saga().merge(order_to_notification_saga());
// Type: Saga<OrderEvent, Sum<NotificationCommand, ShipmentCommand>>
```

Note the `Sum` ordering: `merge(self, other)` produces `Sum<OtherAction, SelfAction>`, so
the **second** saga's action type ends up in `Sum::First`. Double-check this when pattern-
matching on the result — it's counterintuitive.

All composition supports up to 6 types via `combine3`..`combine6` and `merge3`..`merge6`,
with companion type aliases `Sum3`..`Sum6` and `Saga3`..`Saga6` for ergonomic signatures.

### Mapping Functions

Every domain type supports mapping to adapt between type boundaries:

| Type    | Method              | Effect                                      |
|---------|---------------------|---------------------------------------------|
| Decider | `.map_command(f)`   | Transform command type (one-directional)    |
| Decider | `.map_event(f, g)`  | Transform event type (bidirectional)        |
| Decider | `.map_state(f, g)`  | Transform state type (bidirectional)        |
| Decider | `.map_error(f)`     | Transform error type (one-directional)      |
| View    | `.map_event(f)`     | Transform event type (one-directional)      |
| View    | `.map_state(f, g)`  | Transform state type (bidirectional)        |
| Saga    | `.map_action(f)`    | Transform action type (one-directional)     |
| Saga    | `.map_action_result(f)` | Transform action result (one-directional) |

Bidirectional maps take two closures: one for each direction. This is needed because
`evolve` consumes events (needs `Sum -> E`) while `decide` produces them (needs `E -> Sum`).

## Application Layer Wiring

Application types connect domain logic to infrastructure via async repository traits.
The same Decider can be wired to different aggregate types -- the domain logic stays
identical, only the persistence strategy changes.

### The Four Aggregate Types

fmodel provides four aggregate types. All share the same Decider, but differ in how
they persist and whether they support cross-aggregate orchestration:

| Type | Persists | Orchestrates | Repository Trait | handle() Returns |
|------|----------|-------------|------------------|-----------------|
| `EventSourcedAggregate` | Events | No | `EventRepository` | `Result<Vec<(E, Version)>, Error>` |
| `StateStoredAggregate` | State | No | `StateRepository` | `Result<(S, Version), Error>` |
| `EventSourcedOrchestratingAggregate` | Events | Yes (saga) | `EventRepository` | `Result<Vec<(E, Version)>, Error>` |
| `StateStoredOrchestratingAggregate` | State | Yes (saga) | `StateRepository` | `Result<(S, Version), Error>` |

#### EventSourcedAggregate -- Event Log

Stores every event that ever happened. State is rebuilt by replaying events through
`evolve`. Best for: audit trails, temporal queries, event-driven architectures.

```rust
use fmodel_rust::aggregate::EventSourcedAggregate;

let aggregate = EventSourcedAggregate::new(event_repository, order_decider());
// Algorithm: fetch_events -> fold via evolve -> decide -> save new events
let events = aggregate.handle(&command).await?;
```

Requires `EventRepository<C, E, Version, Error>`:
- `fetch_events(&C)` -- load all events for this aggregate's stream
- `save(&[E])` -- append new events
- `version_provider(&E)` -- get version for optimistic concurrency

#### StateStoredAggregate -- Current State Only

Stores only the latest state. No event history. Best for: CRUD-like domains where
history isn't needed, simpler infrastructure (just a database row).

```rust
use fmodel_rust::aggregate::StateStoredAggregate;

let aggregate = StateStoredAggregate::new(state_repository, order_decider());
// Algorithm: fetch_state -> decide -> fold new events via evolve -> save new state
let (new_state, version) = aggregate.handle(&command).await?;
```

Requires `StateRepository<C, S, Version, Error>`:
- `fetch_state(&C)` -- load current state + version
- `save(&S, &Option<Version>)` -- upsert with optimistic concurrency

The decider's `decide` still produces events internally, and `evolve` still folds them
into state -- but the events are transient. Only the final state is persisted.

#### EventSourcedOrchestratingAggregate -- Transactional Multi-Aggregate

Adds a Saga feedback loop to event-sourced persistence. When the decider produces
events, the saga reacts to produce new commands, which are recursively fed back.
All events across all aggregates are saved in one atomic batch.

```rust
use fmodel_rust::aggregate::EventSourcedOrchestratingAggregate;

let aggregate = EventSourcedOrchestratingAggregate::new(
    repository,
    combined_decider(),   // Decider.combine() result
    cross_aggregate_saga(),
);
let all_events = aggregate.handle(&command).await?;
```

The recursion: decide -> events -> saga.react -> new commands -> decide -> ...
until no new commands are produced. Everything is saved in one batch.

Requires a combined decider (via `.combine()`) and a saga that maps events to
commands. Use this when multiple aggregates within a bounded context need
transactional consistency WITHOUT external I/O between steps.

#### StateStoredOrchestratingAggregate -- Same but State-Stored

Same saga feedback loop, but persists only the final tuple state.

```rust
use fmodel_rust::aggregate::StateStoredOrchestratingAggregate;

let aggregate = StateStoredOrchestratingAggregate::new(
    state_repository,
    combined_decider(),
    cross_aggregate_saga(),
);
let (combined_state, version) = aggregate.handle(&command).await?;
```

#### When to Use Which Aggregate

```
Single aggregate?
  +-- Need event history? --> EventSourcedAggregate
  +-- State only?         --> StateStoredAggregate

Multiple aggregates, transactional?
  +-- Need event history? --> EventSourcedOrchestratingAggregate
  +-- State only?         --> StateStoredOrchestratingAggregate

Multiple aggregates with external I/O between steps?
  --> Reactor pattern + Saga for pure mapping (not an fmodel aggregate)

Cross-service reactions?
  --> SagaManager + ActionPublisher
```

### MaterializedView -- Event-Driven Read Models

MaterializedView wires a pure View to a ViewStateRepository for event-driven
projections. It handles the fetch-evolve-save cycle for you.

```rust
use fmodel_rust::materialized_view::MaterializedView;

let materialized = MaterializedView::new(view_repository, order_view());

// For each event: fetch current view state -> evolve -> save new state
let new_state: Result<OrderViewState, Error> = materialized.handle(&event).await?;
```

#### ViewStateRepository Trait

The repository is keyed by the event -- typically you extract an ID from the event
to look up the current projection state:

fmodel-rust uses native async-fn-in-trait (Rust 1.75+), so do **not** annotate these impls
with `#[async_trait]` — write bare `async fn` directly:

```rust
impl ViewStateRepository<OrderEvent, OrderViewState, AppError> for PostgresViewRepo {
    async fn fetch_state(&self, event: &OrderEvent) -> Result<Option<OrderViewState>, AppError> {
        // Extract the key from the event
        let order_id = match event {
            OrderEvent::Created(e) => &e.order_id,
            OrderEvent::Updated(e) => &e.order_id,
            OrderEvent::Cancelled(e) => &e.order_id,
        };
        // Load current projection state from database
        let row = sqlx::query_as::<_, OrderViewState>(
            "SELECT * FROM order_views WHERE order_id = $1"
        )
        .bind(order_id)
        .fetch_optional(&self.pool)
        .await?;
        Ok(row)
    }

    async fn save(&self, state: &OrderViewState) -> Result<OrderViewState, AppError> {
        // Upsert the projection
        sqlx::query_as::<_, OrderViewState>(
            "INSERT INTO order_views (order_id, customer, item_count, status)
             VALUES ($1, $2, $3, $4)
             ON CONFLICT (order_id) DO UPDATE SET
               customer = $2, item_count = $3, status = $4
             RETURNING *"
        )
        .bind(&state.order_id)
        .bind(&state.customer)
        .bind(state.item_count as i32)
        .bind(&state.status)
        .fetch_one(&self.pool)
        .await
        .map_err(AppError::from)
    }
}
```

#### Merged Views with Tuple State

When views are merged, the state becomes a tuple. The repository must handle this:

```rust
// Two views merged
let merged = order_view().merge(shipment_view());
// Type: View<(OrderViewState, ShipmentViewState), AppEvent>

// Repository handles tuple state
impl ViewStateRepository<AppEvent, (OrderViewState, ShipmentViewState), AppError>
    for MergedViewRepo
{
    async fn fetch_state(&self, event: &AppEvent)
        -> Result<Option<(OrderViewState, ShipmentViewState)>, AppError>
    {
        // Extract ID from event, load both states
        let id = event.aggregate_id();
        let order_state = self.order_repo.fetch_by_id(&id).await?;
        let shipment_state = self.shipment_repo.fetch_by_id(&id).await?;
        match (order_state, shipment_state) {
            (Some(o), Some(s)) => Ok(Some((o, s))),
            _ => Ok(None),
        }
    }

    async fn save(&self, state: &(OrderViewState, ShipmentViewState))
        -> Result<(OrderViewState, ShipmentViewState), AppError>
    {
        let o = self.order_repo.save(&state.0).await?;
        let s = self.shipment_repo.save(&state.1).await?;
        Ok((o, s))
    }
}

let materialized = MaterializedView::new(merged_repo, merged);
let (order_state, shipment_state) = materialized.handle(&event).await?;
```

#### Projection Strategies

| Strategy | Pattern | When to Use |
|----------|---------|-------------|
| Single view, single entity | `MaterializedView::new(repo, view)` | One read model per aggregate |
| Multiple views, same events | `view1.merge(view2)` + `MaterializedView` | Keep multiple projections in sync |
| Different event sources | `view.map_event(f)` to unify, then `merge` | Cross-domain projections |
| Complex SQL / joins | Hand-rolled projection | When view state doesn't map to a single row |

### SagaManager

```rust
use fmodel_rust::saga_manager::SagaManager;

let manager = SagaManager::new(action_publisher, order_to_shipment_saga());
let actions = manager.handle(&order_event).await?;
```

Requires `ActionPublisher<A, Error>`:
- `publish(&[A]) -> Result<Vec<A>, Error>`

## Identifier Trait

Commands must implement `Identifier` for stream routing:

```rust
use fmodel_rust::Identifier;

impl Identifier for OrderCommand {
    fn identifier(&self) -> String {
        match self {
            OrderCommand::Create(c) => c.order_id.to_string(),
            OrderCommand::Cancel(c) => c.order_id.to_string(),
        }
    }
}
```

`Identifier` is auto-implemented for `Sum<A, B>` when both `A` and `B` implement it.

## Concurrency

By default, all closures require `Send + Sync` and the crate wraps them in `Arc<Mutex<T>>`
internally (multi-threaded). Enable the `not-send-futures` feature for single-threaded
contexts — it switches to `Rc<RefCell<T>>` and drops the `Send` bounds:

```toml
[dependencies]
fmodel-rust = { version = "0.9", features = ["not-send-futures"] }
```

## Decision Guide

| Scenario | Use |
|----------|-----|
| Single aggregate, event-sourced | `EventSourcedAggregate` |
| Single aggregate, state-stored | `StateStoredAggregate` |
| Multi-aggregate, transactional, no I/O between steps | `Decider.combine()` + `EventSourcedOrchestratingAggregate` |
| Multi-aggregate with external I/O between steps | Reactor + `Saga` for pure mapping |
| Read model projection | `View` + `MaterializedView` |
| Multiple projections from same events | `View.merge()` + `MaterializedView` |
| Cross-service event-to-command | `Saga` + `SagaManager` |
| Multiple reaction sources, same events | `Saga.merge()` + `SagaManager` |

## Reference Files

For deeper details, read the relevant reference file:

- `references/types-and-composition.md` -- Complete type signatures for all domain types,
  all method signatures for combine/merge/map, Sum type variants, and composition algebra
  with detailed code examples. Read this when implementing composition or needing exact
  function signatures.

- `references/application-layer.md` -- All application-layer types, async trait signatures,
  repository trait requirements, and complete wiring examples. Read this when implementing
  the infrastructure/persistence layer.

- `references/patterns.md` -- Correct composition patterns with step-by-step examples,
  anti-patterns to avoid, testing DSL (DeciderTestSpecification, ViewTestSpecification),
  and migration guidance. Read this when designing system architecture or reviewing
  existing fmodel usage for correctness.
