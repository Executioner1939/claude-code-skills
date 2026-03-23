# Application Layer Reference

Complete reference for all application-layer types, async traits, and repository
interfaces in fmodel-rust. These types wire pure domain logic to infrastructure.

## Table of Contents

1. [EventSourcedAggregate](#eventsourcedaggregate)
2. [StateStoredAggregate](#statestoredaggregate)
3. [EventSourcedOrchestratingAggregate](#eventsourcedorchestratingaggregate)
4. [StateStoredOrchestratingAggregate](#statestoredorchestratingaggregate)
5. [MaterializedView](#materializedview)
6. [SagaManager](#sagamanager)
7. [Repository Traits](#repository-traits)
8. [Complete Wiring Examples](#complete-wiring-examples)

---

## EventSourcedAggregate

The standard event-sourced command handler. Fetches events, rebuilds state via the
decider's evolve, runs decide, and saves new events.

### Struct

```rust
pub struct EventSourcedAggregate<C, S, E, Repository, Decider, Version, Error>
where
    Repository: EventRepository<C, E, Version, Error>,
    Decider: EventComputation<C, S, E, Error>,
{
    repository: Repository,
    decider: Decider,
    // PhantomData for unused type params
}
```

### Constructor

```rust
pub fn new(repository: Repository, decider: Decider) -> Self
```

### Handle Method

```rust
pub async fn handle(&self, command: &C) -> Result<Vec<(E, Version)>, Error>
```

**Algorithm:**
1. `repository.fetch_events(command)` -- load all events for this aggregate
2. Strip versions: `events.iter().map(|(e, _)| e)` -- get raw events
3. `decider.compute_new_events(&current_events, command)` -- decide
4. If no new events, return empty vec
5. `repository.save(&new_events)` -- persist new events

### Usage

```rust
use fmodel_rust::aggregate::EventSourcedAggregate;
use fmodel_rust::decider::EventComputation;

struct MyEventStore { /* ... */ }

#[async_trait]
impl EventRepository<OrderCommand, OrderEvent, u64, AppError> for MyEventStore {
    async fn fetch_events(&self, command: &OrderCommand) -> Result<Vec<(OrderEvent, u64)>, AppError> {
        let stream_id = command.identifier();
        // Load from database by stream_id
        todo!()
    }

    async fn save(&self, events: &[OrderEvent]) -> Result<Vec<(OrderEvent, u64)>, AppError> {
        // Append to event store
        todo!()
    }

    async fn version_provider(&self, event: &OrderEvent) -> Result<Option<u64>, AppError> {
        // Return the version/sequence number for optimistic concurrency
        todo!()
    }
}

let aggregate = EventSourcedAggregate::new(event_store, order_decider());
let result = aggregate.handle(&command).await?;
```

---

## StateStoredAggregate

State-stored command handler. Fetches current state, runs decide + evolve, saves
the new state. No event log -- only the latest state is persisted.

### Struct

```rust
pub struct StateStoredAggregate<C, S, E, Repository, Decider, Version, Error>
where
    Repository: StateRepository<C, S, Version, Error>,
    Decider: StateComputation<C, S, E, Error>,
{
    repository: Repository,
    decider: Decider,
}
```

### Handle Method

```rust
pub async fn handle(&self, command: &C) -> Result<(S, Version), Error>
```

**Algorithm:**
1. `repository.fetch_state(command)` -- load current state + version
2. `decider.compute_new_state(current_state, command)` -- decide + evolve
3. `repository.save(&new_state, &version)` -- persist new state with version

### Usage

```rust
struct MyStateStore { /* ... */ }

#[async_trait]
impl StateRepository<OrderCommand, OrderState, u64, AppError> for MyStateStore {
    async fn fetch_state(&self, command: &OrderCommand) -> Result<Option<(OrderState, u64)>, AppError> {
        let id = command.identifier();
        // Load from database
        todo!()
    }

    async fn save(&self, state: &OrderState, version: &Option<u64>) -> Result<(OrderState, u64), AppError> {
        // Upsert with optimistic concurrency check on version
        todo!()
    }
}

let aggregate = StateStoredAggregate::new(state_store, order_decider());
let (new_state, version) = aggregate.handle(&command).await?;
```

---

## EventSourcedOrchestratingAggregate

Combines a Decider with a Saga for transactional multi-aggregate coordination.
When the decider produces events, the saga reacts to produce new commands, which
are recursively fed back into the decider. Everything happens in one atomic batch.

### Struct

```rust
pub struct EventSourcedOrchestratingAggregate<'a, C, S, E, Repository, Version, Error>
where
    Repository: EventRepository<C, E, Version, Error>,
{
    repository: Repository,
    decider: Decider<'a, C, S, E, Error>,
    saga: Saga<'a, E, C>,
}
```

Note: The decider and saga are concrete `Decider`/`Saga` values (not trait objects),
because the orchestrating aggregate needs direct access to the closures for recursive
processing.

### Constructor

```rust
pub fn new(
    repository: Repository,
    decider: Decider<'a, C, S, E, Error>,
    saga: Saga<'a, E, C>,
) -> Self
```

### Handle Method

```rust
pub async fn handle(&self, command: &C) -> Result<Vec<(E, Version)>, Error>
```

**Algorithm (recursive):**
1. `repository.fetch_events(command)` -- load events for this command's stream
2. Rebuild state from events via `evolve`
3. `decide(command, &state)` -- produce new events
4. For each new event: `saga.react(&event)` -- produce new commands
5. For each new command: **recursively** execute steps 1-4
6. Collect ALL events across all recursive calls
7. `repository.save(&all_events)` -- save everything in one batch

The recursion terminates when the saga produces no new commands for any events.

### When to Use

Use EventSourcedOrchestratingAggregate when:
- Multiple aggregates within a bounded context need transactional consistency
- The cross-aggregate coordination is purely domain logic (no external I/O)
- Events from aggregate A must trigger commands on aggregate B atomically

Do NOT use when:
- External I/O (API calls, ledger operations) is needed between aggregate commands
- The aggregates belong to different bounded contexts (use SagaManager instead)
- Simple single-aggregate command handling suffices

### Usage

```rust
use fmodel_rust::aggregate::EventSourcedOrchestratingAggregate;

// 1. Combine deciders (unify error types first)
let combined_decider = order_decider()
    .map_error(|e| AppError::Order(e.clone()))
    .combine(shipment_decider().map_error(|e| AppError::Shipment(e.clone())))
    .map_command(|cmd: &AppCommand| command_to_sum(cmd))
    .map_event(|sum| sum_to_event(sum), |evt| event_to_sum(evt));

// 2. Define saga for cross-aggregate reactions
let saga = Saga {
    react: Box::new(|event: &AppEvent| match event {
        AppEvent::Order(OrderEvent::Created(e)) => {
            vec![AppCommand::Shipment(ShipmentCommand::Create(CreateShipmentCommand {
                order_id: e.order_id.clone(),
                items: e.items.clone(),
            }))]
        }
        _ => vec![],
    }),
};

// 3. Wire
let aggregate = EventSourcedOrchestratingAggregate::new(
    combined_event_repository,
    combined_decider,
    saga,
);

// 4. One call handles everything transactionally
let all_events = aggregate.handle(&AppCommand::Order(create_order_cmd)).await?;
// all_events contains both OrderCreated AND ShipmentCreated
```

---

## StateStoredOrchestratingAggregate

Same saga feedback loop as EventSourcedOrchestratingAggregate, but persists only
the latest state instead of an event log. The decider still produces events
internally (and the saga still reacts to them), but only the final tuple state
is saved after all recursion completes.

### Struct

```rust
pub struct StateStoredOrchestratingAggregate<'a, C, S, E, Repository, Version, Error>
where
    Repository: StateRepository<C, S, Version, Error>,
{
    repository: Repository,
    decider: Decider<'a, C, S, E, Error>,
    saga: Saga<'a, E, C>,
}
```

### Constructor

```rust
pub fn new(
    repository: Repository,
    decider: Decider<'a, C, S, E, Error>,
    saga: Saga<'a, E, C>,
) -> Self
```

### Handle Method

```rust
pub async fn handle(&self, command: &C) -> Result<(S, Version), Error>
```

**Algorithm:**
1. `repository.fetch_state(command)` -- load current combined state
2. `decide(command, &state)` -- produce events
3. For each event: `saga.react(&event)` -- produce new commands
4. For each new command: **recursively** decide (using evolving state)
5. Fold all events into final state via `evolve`
6. `repository.save(&final_state, &version)` -- save just the end state

### When to Choose State-Stored vs Event-Sourced Orchestrating

| Factor | Event-Sourced | State-Stored |
|--------|--------------|--------------|
| History | Full event log preserved | Only latest state |
| Storage | Grows with every command | Fixed size per aggregate |
| Replay | Can rebuild any past state | Cannot |
| Projections | Events available for MaterializedView | Must query state directly |
| Debugging | Every decision traceable via events | Only current state visible |
| Infrastructure | Event store (EventStoreDB, custom) | Database row/document |

Use state-stored orchestrating when you need transactional multi-aggregate
consistency but don't need event history. Common for CRUD-heavy bounded contexts
where the orchestration is the valuable part, not the audit trail.

### Usage

```rust
use fmodel_rust::aggregate::StateStoredOrchestratingAggregate;

// Same combined decider and saga as event-sourced variant
let combined_decider = wallet_decider()
    .map_error(|e| AppError::Wallet(e.clone()))
    .combine(escrow_decider().map_error(|e| AppError::Escrow(e.clone())))
    .map_command(command_to_sum)
    .map_event(sum_to_event, event_to_sum);

let saga = transactions_saga();

// Only the repository type changes
let aggregate = StateStoredOrchestratingAggregate::new(
    state_repository,  // implements StateRepository
    combined_decider,
    saga,
);

// Returns combined state tuple instead of event list
let ((wallet_state, escrow_state), version) = aggregate.handle(&command).await?;
```

---

## Aggregate Type Comparison

All four aggregate types share the same Decider -- the domain logic is identical.
Only the persistence strategy and orchestration capability differ.

### Same Decider, Different Aggregates

```rust
// One decider definition
let decider = order_decider();

// Four ways to wire it:

// 1. Event-sourced (stores events)
let es = EventSourcedAggregate::new(event_repo, decider);
let events: Vec<(OrderEvent, u64)> = es.handle(&cmd).await?;

// 2. State-stored (stores latest state)
let ss = StateStoredAggregate::new(state_repo, decider);
let (state, version): (OrderState, u64) = ss.handle(&cmd).await?;

// 3. Event-sourced orchestrating (events + saga loop)
let eso = EventSourcedOrchestratingAggregate::new(event_repo, combined_decider, saga);
let events: Vec<(AppEvent, u64)> = eso.handle(&cmd).await?;

// 4. State-stored orchestrating (state + saga loop)
let sso = StateStoredOrchestratingAggregate::new(state_repo, combined_decider, saga);
let (state, version) = sso.handle(&cmd).await?;
```

### Decision Tree

```
Do you need cross-aggregate transactional consistency?
|
+-- NO (single aggregate)
|   |
|   +-- Need event history / audit trail / projections?
|   |   --> EventSourcedAggregate
|   |
|   +-- Just need current state?
|       --> StateStoredAggregate
|
+-- YES (multiple aggregates in one bounded context)
    |
    +-- Is there external I/O between aggregate steps?
    |   --> Cannot use orchestrating aggregate.
    |       Use a reactor/process manager + Saga for pure mapping.
    |
    +-- No external I/O between steps:
        |
        +-- Need event history?
        |   --> EventSourcedOrchestratingAggregate
        |       (Decider.combine() + Saga + EventRepository)
        |
        +-- Just need final state?
            --> StateStoredOrchestratingAggregate
                (Decider.combine() + Saga + StateRepository)
```

### Key Structural Differences

The non-orchestrating aggregates accept any type implementing `EventComputation`
or `StateComputation` (trait-based). This means you can pass a `Decider` value or
your own struct that implements the trait:

```rust
// These work because Decider implements EventComputation
EventSourcedAggregate::new(repo, order_decider());
StateStoredAggregate::new(repo, order_decider());
```

The orchestrating aggregates require concrete `Decider` and `Saga` values (not
trait objects) because they need direct access to the internal closures for the
recursive feedback loop:

```rust
// Must be Decider<...> and Saga<...> values
EventSourcedOrchestratingAggregate::new(repo, decider_value, saga_value);
StateStoredOrchestratingAggregate::new(repo, decider_value, saga_value);
```

---

## MaterializedView

Wires a pure View with a ViewStateRepository to handle event-driven projections.
The MaterializedView handles the complete fetch-evolve-save cycle.

### Struct

```rust
pub struct MaterializedView<S, E, Repository, View, Error>
where
    Repository: ViewStateRepository<E, S, Error>,
    View: ViewStateComputation<E, S>,
{
    repository: Repository,
    view: View,
}
```

### Constructor

```rust
pub fn new(repository: Repository, view: View) -> Self
```

### Handle Method

```rust
pub async fn handle(&self, event: &E) -> Result<S, Error>
```

**Algorithm:**
1. `repository.fetch_state(event)` -- load current view state (keyed by event)
2. `view.compute_new_state(current_state, &[event])` -- evolve state with event
3. `repository.save(&new_state)` -- persist new view state
4. Return the saved state

If `fetch_state` returns `None`, the view's `initial_state()` is used as the
starting point. This means the first event for any entity automatically creates
the projection from scratch.

### Event Keying

The `ViewStateRepository.fetch_state(&E)` takes a reference to the event, not an
ID. The repository implementation must extract the relevant key from the event to
look up the correct projection row:

```rust
#[async_trait]
impl ViewStateRepository<OrderEvent, OrderViewState, AppError> for PostgresViewRepo {
    async fn fetch_state(&self, event: &OrderEvent) -> Result<Option<OrderViewState>, AppError> {
        // Extract the entity key from whichever event variant
        let order_id = match event {
            OrderEvent::Created(e) => &e.order_id,
            OrderEvent::Updated(e) => &e.order_id,
            OrderEvent::Cancelled(e) => &e.order_id,
        };
        sqlx::query_as::<_, OrderViewState>(
            "SELECT order_id, customer, item_count, status FROM order_views WHERE order_id = $1"
        )
        .bind(order_id)
        .fetch_optional(&self.pool)
        .await
        .map_err(AppError::from)
    }

    async fn save(&self, state: &OrderViewState) -> Result<OrderViewState, AppError> {
        sqlx::query_as::<_, OrderViewState>(
            "INSERT INTO order_views (order_id, customer, item_count, status)
             VALUES ($1, $2, $3, $4)
             ON CONFLICT (order_id) DO UPDATE SET
               customer = EXCLUDED.customer,
               item_count = EXCLUDED.item_count,
               status = EXCLUDED.status
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

### Single View Wiring

```rust
use fmodel_rust::materialized_view::MaterializedView;

let materialized = MaterializedView::new(postgres_repo, order_view());

// Process events as they arrive (from subscription, message queue, etc.)
for event in incoming_events {
    let new_state = materialized.handle(&event).await?;
    // new_state is the updated OrderViewState
}
```

### Merged Views -- Multiple Projections from Same Events

When you merge views, the state becomes a tuple. Each sub-view processes every
event independently, and the repository must handle the composite state.

```rust
// Define views that share the same event type
fn order_view<'a>() -> View<'a, OrderViewState, AppEvent> {
    View {
        evolve: Box::new(|state, event| match event {
            AppEvent::Order(OrderEvent::Created(e)) => OrderViewState {
                order_id: e.order_id.clone(),
                customer: e.customer.clone(),
                item_count: e.items.len(),
                status: "ACTIVE".into(),
            },
            AppEvent::Order(OrderEvent::Cancelled(_)) => OrderViewState {
                status: "CANCELLED".into(),
                ..state.clone()
            },
            _ => state.clone(), // ignore non-order events
        }),
        initial_state: Box::new(|| OrderViewState::default()),
    }
}

fn shipment_view<'a>() -> View<'a, ShipmentViewState, AppEvent> {
    View {
        evolve: Box::new(|state, event| match event {
            AppEvent::Shipment(ShipmentEvent::Created(e)) => ShipmentViewState {
                shipment_id: e.shipment_id.clone(),
                order_id: e.order_id.clone(),
                status: "PENDING".into(),
            },
            AppEvent::Shipment(ShipmentEvent::Shipped(_)) => ShipmentViewState {
                status: "SHIPPED".into(),
                ..state.clone()
            },
            AppEvent::Shipment(ShipmentEvent::Delivered(_)) => ShipmentViewState {
                status: "DELIVERED".into(),
                ..state.clone()
            },
            _ => state.clone(), // ignore non-shipment events
        }),
        initial_state: Box::new(|| ShipmentViewState::default()),
    }
}

// Merge -- both views process every AppEvent
let merged = order_view().merge(shipment_view());
// Type: View<(OrderViewState, ShipmentViewState), AppEvent>
```

#### Repository for Tuple State

The repository for a merged view must fetch and save the composite state. There
are two common strategies:

**Strategy 1: Separate tables, composed in repository**

```rust
struct ComposedViewRepo {
    order_repo: PostgresOrderViewRepo,
    shipment_repo: PostgresShipmentViewRepo,
}

#[async_trait]
impl ViewStateRepository<AppEvent, (OrderViewState, ShipmentViewState), AppError>
    for ComposedViewRepo
{
    async fn fetch_state(&self, event: &AppEvent)
        -> Result<Option<(OrderViewState, ShipmentViewState)>, AppError>
    {
        let id = extract_aggregate_id(event);
        let order = self.order_repo.fetch_by_id(&id).await?;
        let shipment = self.shipment_repo.fetch_by_id(&id).await?;
        match (order, shipment) {
            (Some(o), Some(s)) => Ok(Some((o, s))),
            // If either is missing, return None so initial_state is used
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
```

**Strategy 2: Single denormalized table**

```rust
struct DenormalizedViewRepo { pool: PgPool }

#[async_trait]
impl ViewStateRepository<AppEvent, (OrderViewState, ShipmentViewState), AppError>
    for DenormalizedViewRepo
{
    async fn fetch_state(&self, event: &AppEvent)
        -> Result<Option<(OrderViewState, ShipmentViewState)>, AppError>
    {
        let id = extract_aggregate_id(event);
        let row = sqlx::query(
            "SELECT * FROM order_shipment_view WHERE aggregate_id = $1"
        )
        .bind(&id)
        .fetch_optional(&self.pool)
        .await?;

        Ok(row.map(|r| (
            OrderViewState {
                order_id: r.get("order_id"),
                customer: r.get("customer"),
                item_count: r.get::<i32, _>("item_count") as usize,
                status: r.get("order_status"),
            },
            ShipmentViewState {
                shipment_id: r.get("shipment_id"),
                order_id: r.get("order_id"),
                status: r.get("shipment_status"),
            },
        )))
    }

    async fn save(&self, state: &(OrderViewState, ShipmentViewState))
        -> Result<(OrderViewState, ShipmentViewState), AppError>
    {
        sqlx::query(
            "INSERT INTO order_shipment_view
               (aggregate_id, order_id, customer, item_count, order_status,
                shipment_id, shipment_status)
             VALUES ($1, $2, $3, $4, $5, $6, $7)
             ON CONFLICT (aggregate_id) DO UPDATE SET
               customer = EXCLUDED.customer,
               item_count = EXCLUDED.item_count,
               order_status = EXCLUDED.order_status,
               shipment_id = EXCLUDED.shipment_id,
               shipment_status = EXCLUDED.shipment_status"
        )
        .bind(&state.0.order_id)
        .bind(&state.0.order_id)
        .bind(&state.0.customer)
        .bind(state.0.item_count as i32)
        .bind(&state.0.status)
        .bind(&state.1.shipment_id)
        .bind(&state.1.status)
        .execute(&self.pool)
        .await?;

        Ok(state.clone())
    }
}
```

#### Wiring the Merged MaterializedView

```rust
let merged_view = order_view().merge(shipment_view());
let materialized = MaterializedView::new(composed_repo, merged_view);

// Both projections update atomically for each event
let (order_state, shipment_state) = materialized.handle(&event).await?;
```

### In-Memory ViewStateRepository for Testing

```rust
use std::sync::Arc;
use tokio::sync::RwLock;
use std::collections::HashMap;

struct InMemoryViewRepo {
    store: Arc<RwLock<HashMap<String, OrderViewState>>>,
}

#[async_trait]
impl ViewStateRepository<OrderEvent, OrderViewState, AppError> for InMemoryViewRepo {
    async fn fetch_state(&self, event: &OrderEvent) -> Result<Option<OrderViewState>, AppError> {
        let store = self.store.read().await;
        Ok(store.get(&event.order_id()).cloned())
    }

    async fn save(&self, state: &OrderViewState) -> Result<OrderViewState, AppError> {
        let mut store = self.store.write().await;
        store.insert(state.order_id.clone(), state.clone());
        Ok(state.clone())
    }
}
```

### Projection Strategies Summary

| Strategy | fmodel Pattern | Best For |
|----------|---------------|----------|
| Single entity projection | `MaterializedView::new(repo, view)` | One read model per aggregate type |
| Multi-projection, same events | `view1.merge(view2)` + `MaterializedView` | Keeping multiple read models in sync from one event stream |
| Cross-domain projection | `view.map_event(f)` to unify event types, then `merge` | Views consuming events from different aggregate types |
| 3+ projections | `view1.merge3(v2, v3)` up to `merge6` | Many read models from same events |
| Complex analytics / joins | Hand-rolled `EventProcessor` | When projection logic requires database joins, window functions, or multi-table writes that don't fit the single-state-per-entity model |

### MaterializedView vs Hand-Rolled Projections

MaterializedView is the right choice when your projection maps one event to one
entity's state update. The pure View handles the business logic (what fields change),
and the ViewStateRepository handles persistence (how to store it).

Hand-rolled projections are better when:
- An event affects multiple database rows (e.g., updating a summary table AND a detail table)
- The projection requires database joins or aggregations
- The projection needs to call external services during processing
- The state model doesn't fit the fetch-one/save-one pattern

---

## SagaManager

Wires a pure Saga with an ActionPublisher for cross-service event-to-command pipelines.

### Struct

```rust
pub struct SagaManager<A, AR, Publisher, Saga, Error>
where
    Publisher: ActionPublisher<A, Error>,
    Saga: ActionComputation<AR, A>,
{
    action_publisher: Publisher,
    saga: Saga,
}
```

### Handle Method

```rust
pub async fn handle(&self, action_result: &AR) -> Result<Vec<A>, Error>
```

**Algorithm:**
1. `saga.compute_new_actions(action_result)` -- react to event, produce commands
2. If no actions, return empty vec
3. `action_publisher.publish(&actions)` -- publish commands

### Usage

```rust
use fmodel_rust::saga_manager::SagaManager;

struct HttpCommandPublisher { client: reqwest::Client, base_url: String }

#[async_trait]
impl ActionPublisher<ShipmentCommand, AppError> for HttpCommandPublisher {
    async fn publish(&self, actions: &[ShipmentCommand]) -> Result<Vec<ShipmentCommand>, AppError> {
        let mut published = Vec::new();
        for action in actions {
            // POST command to shipment service
            self.client.post(&self.base_url)
                .json(action)
                .send()
                .await
                .map_err(|e| AppError::PublishFailed(e.to_string()))?;
            published.push(action.clone());
        }
        Ok(published)
    }
}

let manager = SagaManager::new(http_publisher, order_to_shipment_saga());
let published = manager.handle(&order_event).await?;
```

---

## Repository Traits

### EventRepository

```rust
#[async_trait]
pub trait EventRepository<C, E, Version, Error> {
    /// Load all events for the aggregate identified by the command
    async fn fetch_events(&self, command: &C) -> Result<Vec<(E, Version)>, Error>;

    /// Persist new events and return them with assigned versions
    async fn save(&self, events: &[E]) -> Result<Vec<(E, Version)>, Error>;

    /// Get the version of a specific event (for optimistic concurrency)
    async fn version_provider(&self, event: &E) -> Result<Option<Version>, Error>;
}
```

The `Version` type parameter is typically `u64` or `i64` for sequence numbers.
`fetch_events` uses the command's `Identifier` implementation to determine which
stream to load from.

### StateRepository

```rust
#[async_trait]
pub trait StateRepository<C, S, Version, Error> {
    /// Load current state and its version for the aggregate identified by the command
    async fn fetch_state(&self, command: &C) -> Result<Option<(S, Version)>, Error>;

    /// Persist new state with optimistic concurrency (version check)
    async fn save(&self, state: &S, version: &Option<Version>) -> Result<(S, Version), Error>;
}
```

`version` in `save` is `Option<Version>`:
- `None` means first write (no existing state)
- `Some(v)` means update -- check that stored version matches `v`

### ViewStateRepository

```rust
#[async_trait]
pub trait ViewStateRepository<E, S, Error> {
    /// Load current view state, keyed by the event's identity
    async fn fetch_state(&self, event: &E) -> Result<Option<S>, Error>;

    /// Persist new view state
    async fn save(&self, state: &S) -> Result<S, Error>;
}
```

No version parameter -- view projections are idempotent rebuilds, not
concurrency-controlled writes. The event parameter in `fetch_state` is used to
extract the key (e.g., order_id from the event) to look up the current projection.

### ActionPublisher

```rust
#[async_trait]
pub trait ActionPublisher<A, Error> {
    /// Publish actions (commands) and return the ones successfully published
    async fn publish(&self, actions: &[A]) -> Result<Vec<A>, Error>;
}
```

Implementations can publish via HTTP, message queue, direct aggregate calls, etc.

---

## Complete Wiring Examples

### Event-Sourced System with Projections and Sagas

```rust
// Domain layer -- pure
let decider = order_decider();
let view = order_view();
let saga = order_to_shipment_saga();

// Application layer -- wired to infrastructure
let aggregate = EventSourcedAggregate::new(event_store, decider);
let projection = MaterializedView::new(view_repo, view);
let saga_manager = SagaManager::new(command_publisher, saga);

// Command handling
let new_events = aggregate.handle(&command).await?;

// Project events to read model
for (event, _version) in &new_events {
    projection.handle(event).await?;
}

// React to events (cross-service)
for (event, _version) in &new_events {
    saga_manager.handle(event).await?;
}
```

### Multi-Aggregate Orchestrating System

```rust
// Domain layer -- compose
let combined = order_decider()
    .map_error(|e| AppError::Order(e.clone()))
    .combine(shipment_decider().map_error(|e| AppError::Shipment(e.clone())))
    .map_command(command_to_sum)
    .map_event(sum_to_event, event_to_sum);

let saga = cross_aggregate_saga();

// Application layer
let aggregate = EventSourcedOrchestratingAggregate::new(
    combined_event_store,
    combined,
    saga,
);

// Single atomic operation across both aggregates
let all_events = aggregate.handle(&command).await?;
```

### Async Trait Bounds

By default, all repository traits require `Send + Sync`:

```rust
#[async_trait]
pub trait EventRepository<C, E, Version, Error>: Send + Sync { ... }
```

With `not-send-futures` feature, `Send + Sync` bounds are removed:

```rust
#[async_trait(?Send)]
pub trait EventRepository<C, E, Version, Error> { ... }
```

Use `not-send-futures` when working with `!Send` types (e.g., `Rc<RefCell<T>>` for
in-memory testing) or single-threaded runtimes.
