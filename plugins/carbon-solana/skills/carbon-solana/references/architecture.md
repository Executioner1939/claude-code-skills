# Architecture — Pipeline & Builder

## Pipeline

The `Pipeline` struct (`carbon_core::pipeline::Pipeline`) holds:

| Field | Type | Notes |
|---|---|---|
| `datasources` | `Vec<(DatasourceId, Arc<dyn Datasource + Send + Sync>)>` | Each source has a unique `DatasourceId` (random or named). |
| `account_pipes` | `Vec<Box<dyn AccountPipes>>` | One per `.account(...)` call. |
| `account_deletion_pipes` | `Vec<Box<dyn AccountDeletionPipes>>` | One per `.account_deletions(...)` call. |
| `block_details_pipes` | `Vec<Box<dyn BlockDetailsPipes>>` | One per `.block_details(...)` call. |
| `instruction_pipes` | `Vec<Box<dyn InstructionPipes>>` | One per `.instruction(...)` call. |
| `transaction_pipes` | `Vec<Box<dyn TransactionPipes>>` | One per `.transaction(...)` call. |
| `metrics` | `Arc<MetricsCollection>` | Aggregates all `Metrics` impls. |
| `metrics_flush_interval` | `Option<u64>` | Seconds. Default: 5. |
| `datasource_cancellation_token` | `Option<CancellationToken>` | Used to externally trigger shutdown. |
| `shutdown_strategy` | `ShutdownStrategy` | See below. |
| `channel_buffer_size` | `usize` | Default `DEFAULT_CHANNEL_BUFFER_SIZE` = `1_000`. |

`Pipeline::run(&mut self) -> CarbonResult<()>` is the entry point. It:
1. Initializes metrics.
2. Spawns one Tokio task per datasource (each calls `consume(...)`).
3. Loops on `tokio::select!` over: cancellation, SIGINT, metrics flush tick, and the update channel.
4. Routes each `Update` to the matching pipes.

## ShutdownStrategy

```rust
pub enum ShutdownStrategy {
    Immediate,        // stop everything when SIGINT/cancel arrives
    ProcessPending,   // [DEFAULT] stop datasources, drain queued updates
}
```

Set with `.shutdown_strategy(ShutdownStrategy::Immediate)`.

## PipelineBuilder

Construct via `Pipeline::builder()` or `PipelineBuilder::new()`. All builders return `Self` for chaining.

### Datasource methods
- `.datasource(impl Datasource + 'static) -> Self` — adds one source with a random `DatasourceId`.
- `.datasource_with_id(impl Datasource + 'static, DatasourceId) -> Self` — same but with a known ID for filtering.

### Pipe methods
- `.account(decoder, processor)` and `.account_with_filters(decoder, processor, filters)`
- `.account_deletions(processor)` and `.account_deletions_with_filters(processor, filters)`
- `.block_details(processor)` and `.block_details_with_filters(processor, filters)`
- `.instruction(decoder, processor)` and `.instruction_with_filters(decoder, processor, filters)`
- `.transaction::<T, U>(schema, processor)` and `.transaction_with_filters::<T, U>(schema, processor, filters)`

### Other methods
- `.metrics(Arc<dyn Metrics>)` — call multiple times to register multiple sinks (e.g. `LogMetrics` + `PrometheusMetrics`).
- `.metrics_flush_interval(secs: u64)`
- `.shutdown_strategy(ShutdownStrategy)`
- `.datasource_cancellation_token(CancellationToken)` — supply your own token if you need external control.
- `.channel_buffer_size(usize)` — backpressure on the central update channel. Increase for high-throughput streams; decrease to apply backpressure earlier.

### Build
- `.build() -> CarbonResult<Pipeline>` — validates that for each pipe type registered, at least one datasource declares the matching `UpdateType`. Returns `Err` if there's a mismatch (e.g. you registered a `.transaction(...)` pipe but no datasource emits `UpdateType::Transaction`).

## Update flow

```
Datasource -> mpsc::channel<(Update, DatasourceId)> -> Pipeline.run loop -> route to matching pipes
                                                                          \-> account_pipes
                                                                           \-> account_deletion_pipes
                                                                            \-> block_details_pipes
                                                                             \-> instruction/transaction pipes (after instruction nesting)
```

The `Update` enum has 4 variants:
- `Account(AccountUpdate)`
- `Transaction(Box<TransactionUpdate>)` — boxed because it's the largest variant
- `AccountDeletion(AccountDeletion)`
- `BlockDetails(BlockDetails)`

For transactions, the pipeline:
1. Extracts a `TransactionMetadata` (slot, signature, fee_payer, meta, message, index, block_time, block_hash).
2. Pulls all instructions (top-level + inner from `meta.inner_instructions`) into `InstructionsWithMetadata` — each instruction gets an `InstructionMetadata { transaction_metadata, stack_height, index, absolute_path }`.
3. Builds a `NestedInstructions` tree using `stack_height` (max depth = 5, the Solana CPI limit).
4. Walks the tree calling each instruction-pipe's decoder on every `NestedInstruction`.
5. For transaction pipes, runs schema matching against the flattened instruction list.

## Concurrency model

- One Tokio task per datasource. Each pushes onto the central mpsc channel.
- A single `Pipeline.run` loop pulls updates and dispatches them sequentially to each pipe in registration order. Pipe processors are `async fn` and awaited inline — there is **no** automatic per-pipe parallelism. If you need concurrency inside a processor, spawn your own tasks.
- Metrics flush happens on a `tokio::time::interval`.
- SIGINT is caught with `tokio::signal::ctrl_c`. With `Immediate`, the loop breaks at once; with `ProcessPending`, the datasource cancel token fires, sources stop pushing, and the loop continues until the channel drains.

## Errors

- `CarbonResult<T>` = `Result<T, carbon_core::error::Error>`.
- A processor returning `Err` is logged and counted; it does NOT halt the pipeline.
- Datasource consume errors are logged; the task exits but the rest of the pipeline keeps running. There is no built-in datasource auto-restart — most datasources implement reconnection internally (Yellowstone, Helius Atlas, RPC block subscribe).

## Multi-datasource patterns

```rust
let mainnet = DatasourceId::new_named("mainnet");
let backfill = DatasourceId::new_named("backfill");

Pipeline::builder()
    .datasource_with_id(yellowstone_grpc, mainnet.clone())
    .datasource_with_id(rpc_transaction_crawler, backfill.clone())
    // only run live processor on mainnet
    .instruction_with_filters(
        decoder,
        live_processor,
        vec![Box::new(DatasourceFilter::new(mainnet))],
    )
    .build()?
    .run().await
```

Filters (`carbon_core::filter::Filter`) gate which updates a pipe sees. Built-in: `DatasourceFilter`. Implement `Filter` for custom logic (e.g. only process when `meta.fee_payer == X`).
