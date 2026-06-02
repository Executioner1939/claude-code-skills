# Datasources

Carbon ships 14 datasource crates. Each implements `carbon_core::datasource::Datasource` and emits one or more `Update` variants. Pick based on:
- **Live vs historical** (real-time stream vs backfill).
- **Scope** (single program vs everything).
- **Infra requirements** (Geyser plugin, Helius account, Yellowstone gRPC endpoint, plain RPC, archive).

## Update types and which sources emit them

| Update | Sources |
|---|---|
| `AccountUpdate` | yellowstone-grpc, helius-laserstream, helius-atlas-ws, helius-gpa-v2, rpc-program-subscribe, rpc-gpa, validator-snapshot, stream-message |
| `TransactionUpdate` | yellowstone-grpc, helius-laserstream, helius-atlas-ws, helius-gtfa, rpc-block-subscribe, rpc-block-crawler, rpc-transaction-crawler, jito-shredstream-grpc, jetstreamer, stream-message |
| `AccountDeletion` | yellowstone-grpc, helius-laserstream, helius-atlas-ws |
| `BlockDetails` | yellowstone-grpc, helius-laserstream, rpc-block-subscribe, rpc-block-crawler, jetstreamer |

A datasource declares what it emits in `update_types() -> Vec<UpdateType>`; the pipeline `build()` step verifies each registered pipe has a producer.

---

## yellowstone-grpc-datasource

Crate: `carbon-yellowstone-grpc-datasource`. Use `YellowstoneGrpcGeyserClient`. Subscribes to a Yellowstone Geyser gRPC endpoint; the workhorse for production.

```rust
YellowstoneGrpcGeyserClient::new(
    endpoint: String,                                       // gRPC URL
    x_token: Option<String>,                                // auth header
    commitment: Option<CommitmentLevel>,                    // Processed | Confirmed | Finalized
    account_filters: HashMap<String, SubscribeRequestFilterAccounts>,
    transaction_filters: HashMap<String, SubscribeRequestFilterTransactions>,
    block_filters: BlockFilters,
    account_deletions_tracked: Arc<RwLock<HashSet<Pubkey>>>,
    geyser_config: YellowstoneGrpcClientConfig,
    disconnect_notifier: Option<mpsc::Sender<DatasourceDisconnection>>,
    stream_timeout: Option<Duration>,                       // default 30s
);
```

`YellowstoneGrpcClientConfig` controls compression, connect/timeout, max_decoding_message_size, TLS, and `tcp_nodelay`.

`account_deletions_tracked` is the **set of pubkeys** to watch for deletion events — Yellowstone doesn't emit explicit deletes, so the datasource synthesizes them when an account in this set drops below a meaningful state. Wrap in `Arc<RwLock<HashSet<Pubkey>>>` and mutate at runtime to add/remove.

## helius-laserstream-datasource

Crate: `carbon-helius-laserstream-datasource`. Use `LaserStreamGeyserClient`. Helius's hosted Yellowstone-compatible endpoint with built-in replay.

Same field shape as yellowstone-grpc, but `LaserStreamClientConfig` adds `replay_enabled: bool` (default `true`) for the catch-up-on-reconnect feature.

## helius-atlas-ws-datasource

Crate: `carbon-helius-atlas-ws-datasource`. Use `HeliusWebsocket`. Helius enhanced WebSocket with cluster routing.

```rust
HeliusWebsocket::new(api_key, filters, account_deletions_tracked, cluster)
    .with_ping_interval_secs(60)
    .with_pong_timeout_secs(15)
    .with_transaction_idle_timeout_secs(30); // optional safeguard for high-throughput streams
```

`Filters::new(accounts: Vec<Pubkey>, transactions: Option<RpcTransactionsConfig>)` — at least one of the two must be non-empty (returns `Err` otherwise).

`Cluster` enum: `MainnetBeta` | `Devnet`.

## helius-gpa-v2-datasource

Crate: `carbon-helius-gpa-v2-datasource`. Use `HeliusGpaV2Datasource`. One-shot bulk fetch of program accounts via Helius's enhanced `getProgramAccounts`. Emits `AccountUpdate` for each result, then completes.

```rust
HeliusGpaV2Datasource::new(helius_rpc_url, program_id);
HeliusGpaV2Datasource::new_with_config(helius_rpc_url, program_id, HeliusGpaV2Config { ... });
```

Use this for **initial state hydration** before flipping over to a streaming source.

## helius-gtfa-datasource

Crate: `carbon-helius-gtfa-datasource`. Use `HeliusGtfaDatasource`. "Get Transactions For Address" — fetches historical transaction signatures for one address via Helius's enhanced API, with rich filtering.

```rust
HeliusGtfaDatasource::new(helius_rpc_url, address);
HeliusGtfaDatasource::new_with_config(helius_rpc_url, address, HeliusGtfaConfig {
    sort_order: Some(SortOrder::Asc),         // Asc | Desc
    limit: Some(100),                         // page size, max 100
    commitment: Some(CommitmentConfig::confirmed()),
    filters: Some(HeliusGtfaFilters {
        slot: Some(RangeFilter { gte: Some(start), lt: Some(end), ..Default::default() }),
        block_time: Some(BlockTimeFilter { gte: Some(unix_ts), ..Default::default() }),
        signature: None,
        status: Some(TransactionStatusFilter::Succeeded),  // Succeeded | Failed | Any
    }),
    min_context_slot: None,
});
```

Backfill workflow: pair with a streaming source filtered by the same address.

## rpc-block-subscribe-datasource

Crate: `carbon-rpc-block-subscribe-datasource`. Use `RpcBlockSubscribe`. Standard Solana RPC `blockSubscribe` over WebSocket — no special infra needed.

```rust
RpcBlockSubscribe::new(rpc_ws_url, filters);
RpcBlockSubscribe::with_disconnect_notifier(rpc_ws_url, filters, disconnect_notifier);
```

`Filters::new(block_filter: RpcBlockSubscribeFilter, block_subscribe_config: Option<RpcBlockSubscribeConfig>)`. The filter is `RpcBlockSubscribeFilter::All` or `RpcBlockSubscribeFilter::MentionsAccountOrProgram(String)`.

`RpcBlockSubscribeConfig` controls commitment, transaction details, rewards, encoding, and `max_supported_transaction_version` (set this to `0` for v0 transactions).

## rpc-block-crawler-datasource

Crate: `carbon-rpc-block-crawler-datasource`. Use `RpcBlockCrawler`. Sequential block-range fetcher using `getBlock`.

```rust
RpcBlockCrawler::new(
    rpc_url,
    start_slot,
    end_slot: Option<u64>,                  // None = run forever / catch up
    block_interval: Option<Duration>,        // default 100ms
    block_config: RpcBlockConfig,
    max_concurrent_requests: Option<usize>,  // default 10
    channel_buffer_size: Option<usize>,      // default 1000
);
```

## rpc-program-subscribe-datasource

Crate: `carbon-rpc-program-subscribe-datasource`. Use `RpcProgramSubscribe`. Standard `programSubscribe` WebSocket. Emits only `AccountUpdate`.

```rust
RpcProgramSubscribe::new(rpc_ws_url, Filters::new(pubkey, Some(RpcProgramAccountsConfig { ... })));
```

## rpc-gpa-datasource

Crate: `carbon-rpc-gpa-datasource`. Use `GpaDatasource`. One-shot `getProgramAccounts`. Bulk hydration without Helius. Emits `AccountUpdate` for every result, then completes.

```rust
GpaDatasource::new(rpc_url, program_id);
```

## rpc-transaction-crawler-datasource

Crate: `carbon-rpc-transaction-crawler-datasource`. Use `RpcTransactionCrawler`. Crawls historical signatures for one account with `getSignaturesForAddress` + `getTransaction`.

```rust
RpcTransactionCrawler::new(
    rpc_url,
    account: Pubkey,
    connection_config: ConnectionConfig,
    filters: Filters,
    commitment: Option<CommitmentConfig>,
);
```

`ConnectionConfig::default()` is `batch_limit=100, polling_interval=5s, max_concurrent_requests=5, retry=default(3, 1s, 10s, x2.0)`. `Filters` can scope by `accounts` (additional pubkeys to require), `before_signature`, and `until_signature` (pagination/bookend).

## jito-shredstream-grpc-datasource

Crate: `carbon-jito-shredstream-grpc-datasource`. Use `JitoShredstreamGrpcClient`. Subscribes to Jito's pre-confirmation shredstream — the **lowest-latency** source available. Emits `TransactionUpdate` only.

```rust
JitoShredstreamGrpcClient::new(endpoint);
```

Caveat: shred-level data, so transactions arrive before bank confirmation. Status meta is partial. Use only when you need ms-level latency and accept reorgs.

## jetstreamer-datasource

Crate: `carbon-jetstreamer-datasource`. Use `JetstreamerDatasource`. Replays from the **Old Faithful** historical archive. Massive parallel backfills.

```rust
JetstreamerDatasource::new(
    range: JetstreamerRange,                      // ::slots(start, end) | ::epochs(start, end) | ::all
    filter: JetstreamerFilter,                    // include_blocks/include_transactions + tx filters
    threads: u64,                                 // parallelism
    tracking_interval_slots: Option<u64>,         // periodic stats logging
    archive_url: Option<String>,                  // override JETSTREAMER_COMPACT_INDEX_BASE_URL
    network: Option<String>,                      // override JETSTREAMER_NETWORK
);
JetstreamerDatasource::new_with_old_faithful_mainnet(range, filter, threads, tracking_interval_slots);
```

`JetstreamerRange` is in `jetstreamer_datasource::range`.

## validator-snapshot-datasource

Crate: `carbon-validator-snapshot-datasource`. Use `SnapshotDatasource`. Boots a `Bank` from a downloaded validator snapshot and walks accounts.

```rust
SnapshotDatasource::new(
    source: SnapshotSource,        // LocalPath(PathBuf) | Remote { url: String }
    owners: Vec<Pubkey>,           // filter by program owner
    accounts: Vec<Pubkey>,         // explicit account keys
);
```

Use for one-shot deep state initialization (e.g. all positions for a perps program).

## stream-message-datasource

Crate: `carbon-stream-message-datasource`. Use `StreamMessageClient`. Bridge from your own custom `mpsc::Receiver<UnifiedMessage>` into a Carbon pipeline. Use when you have an existing source (e.g. Kafka, Redis) and want to plug it into Carbon's processor model.

```rust
StreamMessageClient::new(
    account_deletions_tracked: Arc<RwLock<HashSet<Pubkey>>>,
    receiver: Receiver<UnifiedMessage>,
);

pub enum UnifiedMessage {
    Account(AccountUpdate),
    Transaction(Box<TransactionUpdate>),
}
```

---

## Filter types you'll commonly construct

For Yellowstone/Helius LaserStream:
- `SubscribeRequestFilterAccounts { account, owner, filters, nonempty_txn_signature }` — track all accounts, accounts owned by a program, or specific keys.
- `SubscribeRequestFilterTransactions { vote, failed, account_include, account_exclude, account_required, signature }` — `account_required = vec![program_id.to_string()]` is the common DEX pattern.
- `SubscribeRequestFilterBlocks { ... }` for block details.

For RPC block-subscribe: `RpcBlockSubscribeFilter::MentionsAccountOrProgram(program_id.to_string())`.

For program-subscribe: `RpcProgramAccountsConfig { filters: Some(vec![ ... ]), account_config: ..., with_context: Some(true), sort_results: ... }` from `solana_client::rpc_config`.

## Picking a source

| Workload | Recommendation |
|---|---|
| Production real-time DEX indexer | yellowstone-grpc or helius-laserstream |
| Lowest possible latency, accept reorgs | jito-shredstream-grpc + secondary confirm source |
| Local dev / no special infra | rpc-block-subscribe |
| Backfill historical txs for one account | rpc-transaction-crawler or helius-gtfa |
| Backfill blocks in a slot range | rpc-block-crawler or jetstreamer |
| One-shot full program state | rpc-gpa or helius-gpa-v2 or validator-snapshot |
| Bridge an existing custom feed | stream-message |
