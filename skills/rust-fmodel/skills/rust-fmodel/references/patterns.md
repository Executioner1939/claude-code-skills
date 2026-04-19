# Patterns Reference

Correct composition patterns, anti-patterns to avoid, testing DSL, and architectural
decision guidance for fmodel-rust.

## Table of Contents

1. [Correct Patterns](#correct-patterns)
2. [Anti-Patterns](#anti-patterns)
3. [Testing DSL](#testing-dsl)
4. [Decision Matrix](#decision-matrix)
5. [Migration Guidance](#migration-guidance)

---

## Correct Patterns

### Pattern 1: Single Aggregate (Event-Sourced)

The simplest pattern. One decider, one event store, one aggregate.

```rust
// domain/decider.rs -- pure
fn order_decider<'a>() -> Decider<'a, OrderCommand, OrderState, OrderEvent, OrderError> {
    Decider {
        decide: Box::new(|cmd, state| { /* pure command handling */ }),
        evolve: Box::new(|state, event| { /* pure state evolution */ }),
        initial_state: Box::new(|| OrderState::default()),
    }
}

// application/aggregate.rs -- wired
let aggregate = EventSourcedAggregate::new(event_store, order_decider());
let events = aggregate.handle(&command).await?;
```

### Pattern 2: Intra-Service Multi-Aggregate (Transactional)

When multiple aggregates within a bounded context need transactional consistency.

**Step 1: Define individual deciders**
```rust
fn wallet_decider<'a>() -> Decider<'a, WalletCommand, WalletState, WalletEvent, WalletError> { ... }
fn escrow_decider<'a>() -> Decider<'a, EscrowCommand, EscrowState, EscrowEvent, EscrowError> { ... }
```

**Step 2: Define unified domain types**
```rust
enum TransactionCommand { Wallet(WalletCommand), Escrow(EscrowCommand) }
enum TransactionEvent { Wallet(WalletEvent), Escrow(EscrowEvent) }
enum TransactionError { Wallet(WalletError), Escrow(EscrowError) }

impl Identifier for TransactionCommand {
    fn identifier(&self) -> String {
        match self {
            Self::Wallet(cmd) => cmd.identifier(),
            Self::Escrow(cmd) => cmd.identifier(),
        }
    }
}
```

**Step 3: Define bidirectional mapping functions**
```rust
fn command_to_sum(cmd: &TransactionCommand) -> Sum<WalletCommand, EscrowCommand> {
    match cmd {
        TransactionCommand::Wallet(c) => Sum::First(c.clone()),
        TransactionCommand::Escrow(c) => Sum::Second(c.clone()),
    }
}

fn sum_to_event(sum: &Sum<WalletEvent, EscrowEvent>) -> TransactionEvent {
    match sum {
        Sum::First(e) => TransactionEvent::Wallet(e.clone()),
        Sum::Second(e) => TransactionEvent::Escrow(e.clone()),
    }
}

fn event_to_sum(evt: &TransactionEvent) -> Sum<WalletEvent, EscrowEvent> {
    match evt {
        TransactionEvent::Wallet(e) => Sum::First(e.clone()),
        TransactionEvent::Escrow(e) => Sum::Second(e.clone()),
    }
}
```

**Step 4: Compose and map**
```rust
fn transactions_decider<'a>() -> Decider<'a,
    TransactionCommand,
    (WalletState, EscrowState),
    TransactionEvent,
    TransactionError,
> {
    wallet_decider()
        .map_error(|e| TransactionError::Wallet(e.clone()))
        .combine(
            escrow_decider().map_error(|e| TransactionError::Escrow(e.clone()))
        )
        .map_command(|cmd: &TransactionCommand| command_to_sum(cmd))
        .map_event(
            |sum| sum_to_event(sum),
            |evt| event_to_sum(evt),
        )
}
```

**Step 5: Define the saga for cross-aggregate reactions**
```rust
fn transactions_saga<'a>() -> Saga<'a, TransactionEvent, TransactionCommand> {
    Saga {
        react: Box::new(|event| match event {
            TransactionEvent::Escrow(EscrowEvent::PayoutsCalculated { payouts, .. }) => {
                payouts.iter().map(|p| TransactionCommand::Wallet(
                    WalletCommand::CreditBalance { user_id: p.user_id, amount: p.amount }
                )).collect()
            }
            _ => vec![],
        }),
    }
}
```

**Step 6: Wire the orchestrating aggregate**
```rust
let aggregate = EventSourcedOrchestratingAggregate::new(
    event_repository,
    transactions_decider(),
    transactions_saga(),
);
// Single atomic operation across both aggregates
let events = aggregate.handle(&TransactionCommand::Escrow(process_payout_cmd)).await?;
```

### Pattern 3: Compositional Projections

Pure views merged and wired via MaterializedView.

```rust
// Pure views (same event type)
fn wallet_view<'a>() -> View<'a, WalletViewState, TransactionEvent> { ... }
fn escrow_view<'a>() -> View<'a, EscrowViewState, TransactionEvent> { ... }

// Merge
let merged = wallet_view().merge(escrow_view());
// Type: View<(WalletViewState, EscrowViewState), TransactionEvent>

// Wire
let materialized = MaterializedView::new(view_repo, merged);
let (wallet_state, escrow_state) = materialized.handle(&event).await?;
```

### Pattern 4: Cross-Service Saga (Eventual Consistency)

For reacting to events from another service asynchronously.

```rust
// Pure saga
fn party_to_escrow_saga<'a>() -> Saga<'a, PartyEvent, EscrowCommand> {
    Saga {
        react: Box::new(|event| match event {
            PartyEvent::PartyCreated { party_id, buy_in, .. } => {
                vec![EscrowCommand::CreatePartyEscrow(CreatePartyEscrowCommand {
                    party_id: *party_id,
                    buy_in_amount: *buy_in,
                })]
            }
            _ => vec![],
        }),
    }
}

// Action publisher
struct EscrowCommandPublisher { aggregate: SharedEscrowAggregate }

#[async_trait]
impl ActionPublisher<EscrowCommand, AppError> for EscrowCommandPublisher {
    async fn publish(&self, commands: &[EscrowCommand]) -> Result<Vec<EscrowCommand>, AppError> {
        let mut published = Vec::new();
        for cmd in commands {
            self.aggregate.handle(cmd).await?;
            published.push(cmd.clone());
        }
        Ok(published)
    }
}

// Wire
let manager = SagaManager::new(publisher, party_to_escrow_saga());
manager.handle(&party_event).await?;
```

### Pattern 5: Reactor with Saga for Pure Mapping

When external I/O is needed between aggregate commands, keep the reactor but extract
the pure mapping into a Saga.

```rust
// Pure part: Saga handles event-to-command mapping
fn escrow_saga<'a>() -> Saga<'a, PartyEvent, EscrowCommand> {
    Saga { react: Box::new(|event| match event { /* pure mapping */ }) }
}

// Impure part: Reactor handles I/O orchestration
async fn handle(&self, event: &PartyEvent) -> Result<(), Error> {
    let commands = self.saga.compute_new_actions(event);
    for command in commands {
        // External I/O between commands is OK here -- we're outside fmodel
        self.external_service.prepare(&command).await?;
        self.aggregate.handle(&command).await?;
        self.external_service.confirm(&command).await?;
    }
    Ok(())
}
```

---

## Anti-Patterns

### Anti-Pattern 1: Hand-Rolled Aggregate

Manually implementing fetch -> decide -> save instead of using `EventSourcedAggregate`.

```rust
// BAD: duplicates EventSourcedAggregate
pub struct SharedMyAggregate {
    event_store: Arc<MyEventStore>,
    decider: MyDecider,
}
impl SharedMyAggregate {
    pub async fn handle(&self, command: &Cmd) -> Result<Vec<(Event, u64)>, Error> {
        let events = self.event_store.fetch_events(command).await?;
        let new_events = self.decider.compute_new_events(&events, command)?;
        self.event_store.save(&new_events).await
    }
}

// GOOD: use fmodel's aggregate
let aggregate = EventSourcedAggregate::new(event_store, my_decider());
aggregate.handle(&command).await?;
```

Severity: Low (it works, but creates boilerplate across every service).

### Anti-Pattern 2: Imperative Reactor Instead of OrchestratingAggregate

Sequential aggregate.handle() calls in a reactor without transactional guarantees.

```rust
// BAD: not transactional -- if step 4 fails, steps 1-3 are already persisted
async fn handle_party_closed(&self, event: &PartyEvent) -> Result<(), Error> {
    self.escrow_aggregate.handle(&calculate_payouts_cmd).await?;   // step 1
    self.escrow_aggregate.handle(&credit_winner_cmd).await?;       // step 2
    self.escrow_aggregate.handle(&void_loser_cmd).await?;          // step 3
    self.escrow_aggregate.handle(&close_escrow_cmd).await?;        // step 4
}

// GOOD (if no external I/O between steps): use OrchestratingAggregate
let aggregate = EventSourcedOrchestratingAggregate::new(repo, combined_decider, saga);
aggregate.handle(&command).await?;  // all steps atomic
```

Exception: If external I/O is required between steps, the reactor pattern is acceptable.
In that case, extract the pure mapping into a Saga (see Pattern 5 above).

### Anti-Pattern 3: SQL Projections Without View

Business logic mixed directly into SQL queries instead of using a pure View.

```rust
// BAD: untestable without database, logic buried in SQL
async fn project_buy_in(&self, event: &EscrowEvent) -> Result<(), Error> {
    sqlx::query("UPDATE escrows SET total_pot = total_pot + $1 WHERE id = $2")
        .bind(event.amount)
        .bind(event.escrow_id)
        .execute(&self.pool)
        .await?;
    Ok(())
}

// GOOD: pure view + MaterializedView
fn escrow_view<'a>() -> View<'a, EscrowViewState, EscrowEvent> {
    View {
        evolve: Box::new(|state, event| match event {
            EscrowEvent::BuyInEscrowed { amount, .. } => EscrowViewState {
                total_pot: state.total_pot + amount,
                ..state.clone()
            },
            _ => state.clone(),
        }),
        initial_state: Box::new(|| EscrowViewState::default()),
    }
}
// View is testable without DB. MaterializedView handles persistence.
```

### Anti-Pattern 4: No-Op Sagas

Empty sagas that return `vec![]` for every event.

```rust
// BAD: unnecessary boilerplate
pub fn my_saga<'a>() -> Saga<'a, MyEvent, MyCommand> {
    Saga { react: Box::new(|_event| vec![]) }
}
```

A saga is only needed for `EventSourcedOrchestratingAggregate` or `SagaManager`.
If an aggregate has no cross-aggregate reactions, it does not need a saga.

### Anti-Pattern 5: Dual Saga Representation

Both a closure-based `Saga` and a struct implementing `ActionComputation` for the
same logic.

```rust
// BAD: redundant -- the struct wraps the closure which wraps the logic
pub fn my_saga<'a>() -> Saga<'a, MyEvent, MyCommand> {
    Saga { react: Box::new(|event| { /* logic */ }) }
}

pub struct MySaga;
impl ActionComputation<MyEvent, MyCommand> for MySaga {
    fn compute_new_actions(&self, event: &MyEvent) -> Vec<MyCommand> {
        my_saga().compute_new_actions(event)  // creates Saga on every call!
    }
}

// GOOD: pick one. The closure-based Saga is usually sufficient.
```

### Anti-Pattern 6: Using Traits Instead of Composition

Implementing fmodel traits on custom structs but never using fmodel's composition
methods (`combine`, `merge`, `map_*`). This treats fmodel as a trait library
instead of a composition library -- missing its core value proposition.

```rust
// BAD: each decider is isolated, no composition
impl DeciderLogic<Cmd, State, Event, Error> for MyDecider { ... }
impl DeciderLogic<Cmd2, State2, Event2, Error2> for MyDecider2 { ... }
// Cross-aggregate coordination done via hand-rolled reactors

// GOOD: compose at the domain level
let combined = decider1.combine(decider2)
    .map_command(...)
    .map_event(...);
```

---

## Testing DSL

fmodel provides Given-When-Then test specifications for both deciders and views.

### DeciderTestSpecification

```rust
use fmodel_rust::specification::DeciderTestSpecification;

// Event-sourced testing (given events, when command, then events)
DeciderTestSpecification::for_decider(order_decider())
    .given(vec![
        OrderEvent::Created(OrderCreatedEvent {
            order_id: "123".into(),
            customer: "Alice".into(),
            items: vec!["Widget".into()],
        }),
    ])
    .when(OrderCommand::Cancel(CancelOrderCommand {
        order_id: "123".into(),
    }))
    .then(vec![
        OrderEvent::Cancelled(OrderCancelledEvent {
            order_id: "123".into(),
        }),
    ]);

// State-stored testing (given state, when command, then state)
DeciderTestSpecification::for_decider(order_decider())
    .given_state(OrderState {
        order_id: "123".into(),
        customer: "Alice".into(),
        items: vec!["Widget".into()],
        created: true,
        cancelled: false,
    })
    .when(OrderCommand::Cancel(CancelOrderCommand {
        order_id: "123".into(),
    }))
    .then_state(OrderState {
        order_id: "123".into(),
        customer: "Alice".into(),
        items: vec!["Widget".into()],
        created: true,
        cancelled: true,
    });

// Error testing
DeciderTestSpecification::for_decider(order_decider())
    .given(vec![])  // no events -- order doesn't exist
    .when(OrderCommand::Cancel(CancelOrderCommand {
        order_id: "123".into(),
    }))
    .then_error(OrderError::InvalidState);
```

**Methods:**
- `for_decider(decider)` -- create specification for a decider
- `given(events: Vec<E>)` -- set prior events (event-sourced mode)
- `given_state(state: S)` -- set prior state (state-stored mode)
- `when(command: C)` -- set the command to execute
- `then(expected_events: Vec<E>)` -- assert expected events (event-sourced)
- `then_state(expected_state: S)` -- assert expected state (state-stored)
- `then_error(expected_error: Error)` -- assert expected error

### ViewTestSpecification

```rust
use fmodel_rust::specification::ViewTestSpecification;

ViewTestSpecification::for_view(order_view())
    .given(vec![
        OrderEvent::Created(OrderCreatedEvent {
            order_id: "123".into(),
            customer: "Alice".into(),
            items: vec!["Widget".into()],
        }),
        OrderEvent::Cancelled(OrderCancelledEvent {
            order_id: "123".into(),
        }),
    ])
    .then(OrderViewState {
        order_id: "123".into(),
        customer: "Alice".into(),
        item_count: 1,
        status: "CANCELLED".into(),
    });
```

**Methods:**
- `for_view(view)` -- create specification for a view
- `given(events: Vec<E>)` -- set events to process
- `then(expected_state: S)` -- assert expected final state

---

## Decision Matrix

### Aggregate Pattern Selection

| Scenario | Pattern | fmodel Type |
|----------|---------|-------------|
| Single aggregate, event-sourced | Standard | `EventSourcedAggregate` |
| Single aggregate, state-stored | Standard | `StateStoredAggregate` |
| Multi-aggregate, transactional, no external I/O | Combine + Orchestrate | `Decider.combine()` + `EventSourcedOrchestratingAggregate` |
| Multi-aggregate, external I/O between steps | Reactor + Saga | Custom reactor + `Saga` for pure mapping |
| Cross-service event reaction | SagaManager | `Saga` + `SagaManager` |

### Projection Pattern Selection

| Scenario | Pattern | fmodel Type |
|----------|---------|-------------|
| Simple event -> read model | MaterializedView | `View` + `MaterializedView` |
| Multiple views from same events | Merge + MaterializedView | `View.merge()` + `MaterializedView` |
| Complex SQL with joins/aggregations | Custom | Keep hand-rolled (fmodel views are per-entity) |

### Saga Pattern Selection

| Scenario | Pattern | fmodel Type |
|----------|---------|-------------|
| Pure event -> command mapping | Saga | `Saga` |
| Multiple reaction sources, same events | Merge | `Saga.merge()` |
| Event -> command + publish | SagaManager | `Saga` + `SagaManager` |
| Event -> multi-step with external I/O | Reactor + Saga | Custom reactor, saga for pure part |

### Composition Technique Selection

| Need | Technique |
|------|-----------|
| Multiple aggregates in one bounded context | `Decider.combine()` + Sum types |
| Adapting between domain boundaries | `.map_command()`, `.map_event()` |
| Multiple views for same event stream | `View.merge()` |
| Multiple sagas for same event stream | `Saga.merge()` |
| Unifying error types before combine | `.map_error()` |

---

## Migration Guidance

### From Hand-Rolled Aggregate to EventSourcedAggregate

1. Ensure your event store implements `EventRepository`
2. Convert your decider logic to a closure-based `Decider`
3. Replace your custom struct with `EventSourcedAggregate::new(repo, decider)`
4. The `handle` method signature stays the same

### From Imperative Reactor to OrchestratingAggregate

This is only possible if there is no external I/O between aggregate commands.

1. Define individual deciders for each aggregate
2. Unify error types via `map_error`
3. Combine deciders via `combine`
4. Map to unified command/event types via `map_command`/`map_event`
5. Define a saga for the cross-aggregate reactions
6. Wire with `EventSourcedOrchestratingAggregate`

If external I/O is required between steps, keep the reactor but extract the pure
event-to-command mapping into a Saga (Pattern 5).

### From SQL Projections to MaterializedView

1. Define a view state struct (the shape of your read model)
2. Create a pure View with evolve logic (what was in SQL becomes struct updates)
3. Implement `ViewStateRepository` on your database adapter
4. Wire with `MaterializedView`

The view is now testable without a database. The repository handles persistence.

### Checklist for Correct fmodel Usage

- [ ] Domain types (Decider, View, Saga) contain zero I/O
- [ ] Decider closures take references and return owned values
- [ ] `evolve` is total (handles every event variant, never fails)
- [ ] `decide` returns `Result` (can reject commands)
- [ ] Error types are unified before `combine` (use `map_error`)
- [ ] Mapping functions are applied after `combine` to use domain enums
- [ ] `Identifier` is implemented on all command types
- [ ] Views use `merge` (not deprecated `combine`) for same-event composition
- [ ] Sagas use `merge` (not deprecated `combine`) for same-event composition
- [ ] No-op sagas are deleted (only create sagas when needed)
- [ ] OrchestratingAggregate is only used when no external I/O between steps
