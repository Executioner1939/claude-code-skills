# Pipes & Processors

A **pipe** binds a decoder (where applicable) + a processor + optional filters into a unit the pipeline can run for a specific update type. A **processor** is your async fn that receives the pipe's input tuple.

## The Processor trait

```rust
#[async_trait]
pub trait Processor {
    type InputType;
    async fn process(
        &mut self,
        data: Self::InputType,
        metrics: Arc<MetricsCollection>,
    ) -> CarbonResult<()>;
}
```

`process` takes `&mut self`, so you can hold mutable per-pipe state (a `HashMap` cache, a DB pool, a counter). The pipeline owns one instance per pipe and calls `process` sequentially for that pipe — no need for additional locking inside.

If `process` returns `Err`, the pipeline logs and increments a failure counter but **continues**. To halt the pipeline from a processor, signal externally (cancel a `CancellationToken` you injected via `.datasource_cancellation_token(...)`).

`metrics: Arc<MetricsCollection>` exposes:
- `metrics.increment_counter(name: &str, value: u64).await?`
- `metrics.update_gauge(name: &str, value: f64).await?`
- `metrics.record_histogram(name: &str, value: f64).await?`

## The five pipe types

### 1. Account pipe — `.account(decoder, processor)`

```rust
type AccountProcessorInputType<T> = (
    AccountMetadata,
    DecodedAccount<T>,
    solana_account::Account,   // raw account, in case you need lamports/owner/data
);

#[async_trait]
impl Processor for MyAccountProcessor {
    type InputType = AccountProcessorInputType<MyProgramAccount>;
    async fn process(
        &mut self,
        (meta, decoded, raw): Self::InputType,
        _metrics: Arc<MetricsCollection>,
    ) -> CarbonResult<()> {
        match decoded.data {
            MyProgramAccount::PoolState(p) => { /* ... */ }
            _ => {}
        }
        Ok(())
    }
}
```

`DecodedAccount<T>` carries `lamports`, `data: T`, `owner`, `executable`, `rent_epoch`. The third tuple element is the raw `solana_account::Account` for cases where you need an undecoded view.

### 2. Account-deletion pipe — `.account_deletions(processor)`

No decoder. The processor's `InputType` is just `AccountDeletion`:
```rust
pub struct AccountDeletion {
    pub pubkey: Pubkey,
    pub slot: u64,
    pub transaction_signature: Option<Signature>,
}
```

Only emitted by sources that track deletions (Yellowstone, LaserStream, Atlas) and only for keys in the `account_deletions_tracked` set.

### 3. Block-details pipe — `.block_details(processor)`

```rust
pub struct BlockDetails {
    pub slot: u64,
    pub block_hash: Option<Hash>,
    pub previous_block_hash: Option<Hash>,
    pub rewards: Option<Rewards>,
    pub num_reward_partitions: Option<u64>,
    pub block_time: Option<i64>,
    pub block_height: Option<u64>,
}
```

Use this for chain-tip tracking, fork detection, slot-time stats.

### 4. Instruction pipe — `.instruction(decoder, processor)` ⭐ most common

```rust
type InstructionProcessorInputType<T> = (
    InstructionMetadata,
    DecodedInstruction<T>,
    NestedInstructions,                  // inner CPI tree of THIS instruction
    solana_instruction::Instruction,     // raw ix (program_id, accounts, data)
);
```

The pipeline walks every transaction's full instruction tree and calls `decode_instruction(&raw_ix)` on each `NestedInstruction`. Decoders return `None` when the instruction is for a different program — the pipeline silently moves on.

```rust
#[async_trait]
impl Processor for MyIxProcessor {
    type InputType = InstructionProcessorInputType<MyProgramInstruction>;
    async fn process(
        &mut self,
        (meta, ix, inner, raw): Self::InputType,
        _metrics: Arc<MetricsCollection>,
    ) -> CarbonResult<()> {
        let sig = meta.transaction_metadata.signature;
        let stack_height = meta.stack_height;  // 1 = top-level, >1 = inner CPI
        match ix.data {
            MyProgramInstruction::Swap(s) => {
                let accs = MyProgramInstruction::Swap::arrange_accounts(&ix.accounts);
                if let Some(a) = accs {
                    println!("{sig} swap user={} pool={} amount={}", a.user, a.pool, s.amount);
                }
            }
            _ => {}
        }
        Ok(())
    }
}
```

`DecodedInstruction<T>` has:
- `program_id: Pubkey`
- `data: T` — the decoded variant (your program's `Instruction` enum).
- `accounts: Vec<AccountMeta>` — the raw account list. **Always pass to `arrange_accounts`** to get named pubkeys.

The fourth tuple element (raw `solana_instruction::Instruction`) is rarely needed; useful only if you want re-encoding or external logging.

### 5. Transaction pipe — `.transaction::<T, U>(schema, processor)`

```rust
type TransactionProcessorInputType<T, U = ()> = (
    Arc<TransactionMetadata>,
    Vec<(InstructionMetadata, DecodedInstruction<T>)>,  // flattened, in tree order
    Option<U>,                                           // schema-matched payload
);
```

Use when you need the **whole transaction at once** — e.g. detect Pumpfun migration patterns where `Initialize` + multiple `Withdraw` instructions co-occur, or for cross-protocol patterns (SOL transfer + token transfer + invoke X).

`U` is a custom struct you define; the schema's `match_schema::<U>` returns it via serde. See `references/transaction-schema.md`.

## Filters

`*_with_filters(...)` variants accept `Vec<Box<dyn Filter + Send + Sync + 'static>>`. Each filter:

```rust
pub trait Filter: Send + Sync {
    fn filter(&self, update: &Update) -> bool;
}
```

Return `true` to allow, `false` to drop. Built-in:
- `DatasourceFilter::new(DatasourceId)` — only updates from this source.

For custom filters, implement `Filter` directly:

```rust
struct OnlyMainnetSwaps;
impl Filter for OnlyMainnetSwaps {
    fn filter(&self, update: &Update) -> bool {
        match update {
            Update::Transaction(tx) => !tx.meta.status.is_err(),
            _ => false,
        }
    }
}
```

## Decoding CPI log events

Anchor-style programs emit events as base64-encoded log lines from a CPI to the program itself. `InstructionMetadata` provides:

```rust
pub fn decode_log_events<T: CarbonDeserialize>(&self) -> Vec<T>
```

Walk only the logs that belong to this specific instruction (it accounts for stack height + position). Returns all matching events in order.

```rust
use carbon_pumpfun_decoder::events::trade_event::TradeEventEvent;

async fn process(&mut self, (meta, ix, _, _): Self::InputType, _: Arc<MetricsCollection>) -> CarbonResult<()> {
    match ix.data {
        PumpfunInstruction::Buy(_) | PumpfunInstruction::Sell(_) => {
            for ev in meta.decode_log_events::<TradeEventEvent>() {
                println!("trade: mint={} sol={} tok={} buy={}", ev.mint, ev.sol_amount, ev.token_amount, ev.is_buy);
            }
        }
        _ => {}
    }
    Ok(())
}
```

Some programs (e.g. Raydium CPMM) put events in `types/<name>_event.rs` instead of an `events/` folder; the per-protocol page tells you where to import from.

## Account-meta arrangement

Most decoder instruction structs implement `ArrangeAccounts`:

```rust
trait ArrangeAccounts {
    type ArrangedAccounts;
    fn arrange_accounts(accounts: &[AccountMeta]) -> Option<Self::ArrangedAccounts>;
}
```

Two patterns inside the impl:

1. **Match on `accounts.len()`** — different account-count variants for the same instruction (common in Raydium AMM v4 where one variant is 17 accounts, another 18). Optional accounts become `Option<Pubkey>` in the arranged struct.
2. **Sequential `next_account(&mut iter)?`** — single variant, fixed order, possibly with a trailing `remaining: Vec<AccountMeta>` for variable trailing accounts (typical of newer Anchor IDLs).

Always treat the result as `Option`; truncated/malformed instructions return `None`.

## Multiple pipes per program

Register the same decoder twice with different processors when you want concern-separated handlers:

```rust
Pipeline::builder()
    .datasource(...)
    .instruction(RaydiumDecoder, SwapWatcher)
    .instruction(RaydiumDecoder, PoolCreationWatcher)
    .build()?.run().await
```

Each pipe gets its own filter list and runs independently in registration order.
