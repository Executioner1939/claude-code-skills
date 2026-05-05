# Types and Composition Reference

Complete type signatures and composition mechanics for all fmodel-rust domain types.

## Table of Contents

1. [Function Type Aliases](#function-type-aliases)
2. [Decider -- Complete API](#decider----complete-api)
3. [View -- Complete API](#view----complete-api)
4. [Saga -- Complete API](#saga----complete-api)
5. [Sum Types](#sum-types)
6. [Identifier Trait](#identifier-trait)
7. [Composition Algebra](#composition-algebra)

---

## Function Type Aliases

fmodel uses boxed closures for all domain functions. The bounds differ based on
the `not-send-futures` feature:

```rust
// Default (Send + Sync, multi-threaded)
pub type DecideFunction<'a, C, S, E, Error> =
    Box<dyn Fn(&C, &S) -> Result<Vec<E>, Error> + 'a + Send + Sync>;
pub type EvolveFunction<'a, S, E> =
    Box<dyn Fn(&S, &E) -> S + 'a + Send + Sync>;
pub type InitialStateFunction<'a, S> =
    Box<dyn Fn() -> S + 'a + Send + Sync>;
pub type ReactFunction<'a, AR, A> =
    Box<dyn Fn(&AR) -> Vec<A> + 'a + Send + Sync>;

// With feature "not-send-futures" (no Send bounds, single-threaded)
pub type DecideFunction<'a, C, S, E, Error> =
    Box<dyn Fn(&C, &S) -> Result<Vec<E>, Error> + 'a>;
pub type EvolveFunction<'a, S, E> =
    Box<dyn Fn(&S, &E) -> S + 'a>;
pub type InitialStateFunction<'a, S> =
    Box<dyn Fn() -> S + 'a>;
pub type ReactFunction<'a, AR, A> =
    Box<dyn Fn(&AR) -> Vec<A> + 'a>;
```

All closures take references (`&C`, `&S`, `&E`) and return owned values.
The `evolve` function returns a new `S` (not mutating in place) -- this is the
functional modeling principle at work.

---

## Decider -- Complete API

### Struct Definition

```rust
pub struct Decider<'a, C: 'a, S: 'a, E: 'a, Error: 'a = ()> {
    pub decide: DecideFunction<'a, C, S, E, Error>,
    pub evolve: EvolveFunction<'a, S, E>,
    pub initial_state: InitialStateFunction<'a, S>,
}
```

- `C` -- Command type (input to `decide`)
- `S` -- State type (rebuilt from events, input to `decide`, output of `evolve`)
- `E` -- Event type (output of `decide`, input to `evolve`)
- `Error` -- Error type (defaults to `()`)
- `'a` -- Lifetime of the closures

### Computation Traits

```rust
/// Event-sourced computation: events in, events out
pub trait EventComputation<C, S, E, Error = ()> {
    fn compute_new_events(&self, current_events: &[E], command: &C) -> Result<Vec<E>, Error>;
}

/// State-stored computation: state in, state out
pub trait StateComputation<C, S, E, Error = ()> {
    fn compute_new_state(&self, current_state: Option<S>, command: &C) -> Result<S, Error>;
}
```

**EventComputation implementation:**
```rust
fn compute_new_events(&self, current_events: &[E], command: &C) -> Result<Vec<E>, Error> {
    // 1. Fold all past events into current state
    let current_state = current_events
        .iter()
        .fold((self.initial_state)(), |state, event| {
            (self.evolve)(&state, event)
        });
    // 2. Run decide with current state and command
    (self.decide)(command, &current_state)
}
```

**StateComputation implementation:**
```rust
fn compute_new_state(&self, current_state: Option<S>, command: &C) -> Result<S, Error> {
    let effective_state = current_state.unwrap_or_else(|| (self.initial_state)());
    let events = (self.decide)(command, &effective_state)?;
    // Fold new events into state
    Ok(events.into_iter().fold(effective_state, |state, event| {
        (self.evolve)(&state, &event)
    }))
}
```

### Mapping Methods

#### map_command

Transforms the command type. One-directional (new -> original).

```rust
fn map_command<C2>(self, f: impl Fn(&C2) -> C) -> Decider<'a, C2, S, E, Error>
```

The closure converts from the new command type to the original. This is contravariant --
the direction is "backwards" because commands are inputs.

```rust
let mapped = order_decider().map_command(|app_cmd: &AppCommand| match app_cmd {
    AppCommand::Order(c) => c.clone(),
    _ => unreachable!(), // only called when command matches
});
```

#### map_event

Transforms the event type. Bidirectional (two closures).

```rust
fn map_event<E2>(
    self,
    f: impl Fn(&E) -> E2,       // original -> new (for decide output)
    g: impl Fn(&E2) -> E,       // new -> original (for evolve input)
) -> Decider<'a, C, S, E2, Error>
```

Two closures because events flow in both directions: `decide` produces events (needs
`E -> E2`) and `evolve` consumes events (needs `E2 -> E`).

```rust
let mapped = order_decider().map_event(
    |e: &OrderEvent| AppEvent::Order(e.clone()),       // produce
    |app_e: &AppEvent| match app_e {                    // consume
        AppEvent::Order(e) => e.clone(),
        _ => unreachable!(),
    },
);
```

#### map_state

Transforms the state type. Bidirectional (two closures).

```rust
fn map_state<S2>(
    self,
    f: impl Fn(&S) -> S2,       // original -> new
    g: impl Fn(&S2) -> S,       // new -> original
) -> Decider<'a, C, S2, E, Error>
```

```rust
let mapped = order_decider().map_state(
    |s: &OrderState| AppState { order: s.clone() },
    |app_s: &AppState| app_s.order.clone(),
);
```

#### map_error

Transforms the error type. One-directional (original -> new).

```rust
fn map_error<Error2>(self, f: impl Fn(&Error) -> Error2) -> Decider<'a, C, S, E, Error2>
```

```rust
let mapped = order_decider().map_error(|e| AppError::Order(e.clone()));
```

### Combine Methods

#### combine (2 deciders)

```rust
fn combine<C2, S2, E2>(
    self,
    decider2: Decider<'a, C2, S2, E2, Error>,
) -> Decider<'a, Sum<C, C2>, (S, S2), Sum<E, E2>, Error>
where
    C2: 'a, S2: 'a + Clone, E2: 'a,
    S: Clone,
```

Result type breakdown:
- Commands: `Sum<C, C2>` -- each command dispatches to the right decider
- State: `(S, S2)` -- tuple of both states, maintained independently
- Events: `Sum<E, E2>` -- each event evolves only its own state component
- Error: same `Error` type (unify errors with `map_error` first if they differ)

**How combine works internally:**

For `decide`:
- `Sum::First(cmd)` -> calls decider1.decide(cmd, &state.0) -> wraps results in `Sum::First`
- `Sum::Second(cmd)` -> calls decider2.decide(cmd, &state.1) -> wraps results in `Sum::Second`

For `evolve`:
- `Sum::First(evt)` -> evolves state.0 with decider1.evolve, state.1 unchanged
- `Sum::Second(evt)` -> evolves state.1 with decider2.evolve, state.0 unchanged

For `initial_state`:
- Returns `(decider1.initial_state(), decider2.initial_state())`

#### combine3 through combine6

```rust
fn combine3<C2, S2, E2, C3, S3, E3>(
    self,
    d2: Decider<'a, C2, S2, E2, Error>,
    d3: Decider<'a, C3, S3, E3, Error>,
) -> Decider<'a, Sum3<C, C2, C3>, (S, S2, S3), Sum3<E, E2, E3>, Error>

// combine4, combine5, combine6 follow the same pattern up to 6 deciders
```

---

## View -- Complete API

### Struct Definition

```rust
pub struct View<'a, S: 'a, E: 'a> {
    pub evolve: EvolveFunction<'a, S, E>,
    pub initial_state: InitialStateFunction<'a, S>,
}
```

No `decide`, no `Error` -- views only project events into state.

### Computation Trait

```rust
pub trait ViewStateComputation<E, S> {
    fn compute_new_state(&self, current_state: Option<S>, events: &[&E]) -> S;
}
```

Implementation folds events over state:
```rust
fn compute_new_state(&self, current_state: Option<S>, events: &[&E]) -> S {
    let effective_state = current_state.unwrap_or_else(|| (self.initial_state)());
    events.iter().fold(effective_state, |state, event| {
        (self.evolve)(&state, event)
    })
}
```

Note: events parameter is `&[&E]` (slice of references), not `&[E]`.

### Mapping Methods

#### map_event (one-directional)

```rust
fn map_event<E2>(self, f: impl Fn(&E2) -> E) -> View<'a, S, E2>
```

Contravariant -- converts from new event type to original (events are inputs to view).

#### map_state (bidirectional)

```rust
fn map_state<S2>(
    self,
    f: impl Fn(&S) -> S2,
    g: impl Fn(&S2) -> S,
) -> View<'a, S2, E>
```

### Merge Methods

`merge` combines views that share the same event type `E`. The state becomes a tuple.
Every event is processed by all merged views.

```rust
fn merge<S2>(self, view2: View<'a, S2, E>) -> View<'a, (S, S2), E>
where S2: 'a + Clone, S: Clone
```

**merge vs combine (deprecated):**
- `merge`: `View<S1, E> + View<S2, E>` -> `View<(S1, S2), E>` -- SAME event type
- `combine` (deprecated): `View<S1, E1> + View<S2, E2>` -> `View<(S1, S2), Sum<E1, E2>>`

Use `merge` because views projecting the same event stream is the common case. If you
need different event types, use `map_event` first to unify them, then `merge`.

```rust
fn merge3<S2, S3>(self, v2: View<'a, S2, E>, v3: View<'a, S3, E>)
    -> View<'a, (S, S2, S3), E>

// merge4, merge5, merge6 follow the same pattern
```

---

## Saga -- Complete API

### Struct Definition

```rust
pub struct Saga<'a, AR: 'a, A: 'a> {
    pub react: ReactFunction<'a, AR, A>,
}
```

- `AR` -- Action Result (typically an event type -- the input)
- `A` -- Action (typically a command type -- the output)

A saga is stateless. It maps events to commands. No evolve, no state.

### Computation Trait

```rust
pub trait ActionComputation<AR, A> {
    fn compute_new_actions(&self, event: &AR) -> Vec<A>;
}
```

### Mapping Methods

#### map_action (one-directional)

```rust
fn map_action<A2>(self, f: impl Fn(&A) -> A2) -> Saga<'a, AR, A2>
```

Transforms the output action type.

#### map_action_result (one-directional)

```rust
fn map_action_result<AR2>(self, f: impl Fn(&AR2) -> AR) -> Saga<'a, AR2, A>
```

Contravariant -- converts from new action result type to original.

### Merge Methods

`merge` combines sagas that share the same action result type `AR`. Actions become
a Sum type.

```rust
fn merge<A2>(self, saga2: Saga<'a, AR, A2>) -> Saga<'a, AR, Sum<A2, A>>
where A2: 'a, A: 'a
```

Note the order: `Sum<A2, A>` (saga2's action type comes first).

Every event is processed by all merged sagas. Results are collected into a single Vec.

```rust
fn merge3<A2, A3>(self, s2: Saga<'a, AR, A2>, s3: Saga<'a, AR, A3>)
    -> Saga<'a, AR, Sum3<A, A2, A3>>

// merge4, merge5, merge6 follow the same pattern
```

**merge vs combine (deprecated):**
- `merge`: `Saga<AR, A1> + Saga<AR, A2>` -> `Saga<AR, Sum<A2, A1>>` -- SAME event type
- `combine` (deprecated): different event types via Sum -- avoid this

---

## Sum Types

```rust
#[derive(Debug, PartialEq, Clone, Serialize, Deserialize)]
pub enum Sum<A, B> {
    First(A),
    Second(B),
}

pub enum Sum3<A, B, C> { First(A), Second(B), Third(C) }
pub enum Sum4<A, B, C, D> { First(A), Second(B), Third(C), Fourth(D) }
pub enum Sum5<A, B, C, D, E> { First(A), Second(B), Third(C), Fourth(D), Fifth(E) }
pub enum Sum6<A, B, C, D, E, F> { First(A), Second(B), Third(C), Fourth(D), Fifth(E), Sixth(F) }
```

All Sum types derive: `Debug`, `PartialEq`, `Clone`, `Serialize`, `Deserialize`.

Sum types are the intermediate representation after `combine`/`merge`. In practice,
you typically map them to your own unified domain enums using `map_command`/`map_event`
so your application code never sees `Sum` directly.

---

## Identifier Trait

```rust
pub trait Identifier {
    fn identifier(&self) -> String;
}
```

Used by aggregates to determine which event stream to load. Typically the aggregate ID.

Auto-implemented for Sum types:
```rust
impl<A: Identifier, B: Identifier> Identifier for Sum<A, B> {
    fn identifier(&self) -> String {
        match self {
            Sum::First(a) => a.identifier(),
            Sum::Second(b) => b.identifier(),
        }
    }
}
```

This means combined deciders automatically route commands to the correct stream.

---

## Composition Algebra

### Type-Level Rules

Combining deciders follows these algebraic rules:

```
combine(Decider<C1, S1, E1, Err>, Decider<C2, S2, E2, Err>)
    = Decider<Sum<C1, C2>, (S1, S2), Sum<E1, E2>, Err>

combine3(d1, d2, d3)
    = Decider<Sum3<C1, C2, C3>, (S1, S2, S3), Sum3<E1, E2, E3>, Err>
```

Merging views:
```
merge(View<S1, E>, View<S2, E>)
    = View<(S1, S2), E>                    // same E
```

Merging sagas:
```
merge(Saga<AR, A1>, Saga<AR, A2>)
    = Saga<AR, Sum<A2, A1>>               // same AR, note A2 comes first
```

### Composition Pipeline

The standard pattern for composing and mapping:

```rust
// 1. Create individual deciders
let d1 = order_decider();
let d2 = shipment_decider();

// 2. Unify error types (required -- combine needs same Error type)
let d1 = d1.map_error(|e| AppError::Order(e.clone()));
let d2 = d2.map_error(|e| AppError::Shipment(e.clone()));

// 3. Combine
let combined = d1.combine(d2);
// Type: Decider<Sum<OrderCmd, ShipmentCmd>, (OrderState, ShipmentState), Sum<OrderEvt, ShipmentEvt>, AppError>

// 4. Map to unified domain types
let final_decider = combined
    .map_command(|cmd: &AppCommand| command_to_sum(cmd))
    .map_event(
        |sum| sum_to_event(sum),
        |evt| event_to_sum(evt),
    );
// Type: Decider<AppCommand, (OrderState, ShipmentState), AppEvent, AppError>
```

### When Mapping is Required

- `map_error` -- before `combine`, if deciders have different error types
- `map_command` -- after `combine`, to use unified command enum instead of `Sum`
- `map_event` -- after `combine`, to use unified event enum instead of `Sum`
- `map_event` on View -- before `merge`, if views consume different event types
- `map_action_result` on Saga -- before `merge`, if sagas react to different event types

### Internal Mechanics

When using `Send + Sync` (default), combine wraps the original deciders in `Arc`:
```rust
let decide1 = Arc::new(self.decide);
let evolve1 = Arc::new(self.evolve);
// ...used inside new closures
```

With `not-send-futures`, `Rc` is used instead. This is transparent to the user but
explains why the closures need `Send + Sync` by default.
