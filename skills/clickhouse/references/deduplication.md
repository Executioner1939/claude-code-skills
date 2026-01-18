# Blockchain Data Deduplication

## Contents
- Why deduplication matters
- ReplacingMergeTree patterns
- Insert deduplication
- Query patterns

## Why Deduplication Matters

Blockchain indexers often process the same transaction multiple times:
- Reorgs / slot re-processing
- Multiple data sources
- Backfills overlapping with real-time
- Retry logic on failures

**Result**: Same `signature` can appear multiple times in your tables.

## ReplacingMergeTree Patterns

### Basic Trade Deduplication

```sql
CREATE TABLE dex_trades (
    signature String,
    instruction_index UInt8,
    slot UInt64,
    block_time DateTime64(3),
    ...
)
ENGINE = ReplacingMergeTree()
ORDER BY (pool_address, block_time, signature, instruction_index)
```

- `signature + instruction_index` uniquely identifies a swap
- ReplacingMergeTree keeps last inserted row per ORDER BY key
- Duplicates removed during background merges

### With Version Column

If you need to control which row wins (not just last inserted):

```sql
CREATE TABLE pool_states (
    pool_address String,
    slot UInt64,
    ...
)
ENGINE = ReplacingMergeTree(slot)  -- Higher slot wins
ORDER BY (pool_address)
```

### State Tables with Update Tracking

```sql
CREATE TABLE wallet_stats (
    wallet_address String,
    updated_slot UInt64,
    total_trades UInt64,
    ...
)
ENGINE = ReplacingMergeTree(updated_slot)
ORDER BY (wallet_address)
```

Insert updates by re-inserting full row with higher `updated_slot`.

## Query Patterns

### FINAL keyword

Forces deduplication at query time:

```sql
SELECT * FROM pool_states FINAL
WHERE pool_address = '...'
```

**Drawback**: Can be slow on large tables.

### Aggregate to dedupe

Often faster than FINAL:

```sql
-- Get latest state per pool
SELECT
    pool_address,
    argMax(token_a_reserve, slot) AS token_a_reserve,
    argMax(token_b_reserve, slot) AS token_b_reserve,
    argMax(tvl_usd, slot) AS tvl_usd,
    max(slot) AS slot
FROM pool_states
WHERE pool_address IN (...)
GROUP BY pool_address
```

### For trades (where duplicates shouldn't exist)

```sql
-- Count trades (handles potential duplicates)
SELECT
    pool_address,
    uniq(signature, instruction_index) AS trade_count,
    sum(volume_usd) / count() * uniq(signature, instruction_index) AS volume_usd
FROM dex_trades
WHERE block_time >= now() - INTERVAL 1 HOUR
GROUP BY pool_address
```

Or simpler if duplicates are rare:
```sql
SELECT pool_address, count(), sum(volume_usd)
FROM dex_trades FINAL
WHERE block_time >= now() - INTERVAL 1 HOUR
GROUP BY pool_address
```

## Insert Deduplication

ClickHouse can dedupe at insert time (before storage):

### Block-level deduplication

```sql
-- Enable for replicated tables (default on)
-- Controlled by: replicated_deduplication_window

-- For non-replicated tables
CREATE TABLE ...
SETTINGS non_replicated_deduplication_window = 1000
```

Same data block inserted twice → second insert ignored.

### Custom deduplication token

For idempotent batch inserts:

```sql
INSERT INTO dex_trades
SELECT * FROM staging_trades
SETTINGS insert_deduplication_token = 'batch_2024_01_15_slot_12345'
```

Re-running same batch with same token → no duplicates.

### With Materialized Views

```sql
SET deduplicate_blocks_in_dependent_materialized_views = 1
```

Ensures MVs also deduplicate when source table dedupes.

## Gotchas

- **Merges are async**: Duplicates exist until background merge
- **FINAL can be slow**: Prefer aggregate queries on large tables
- **MVs see all inserts**: Even duplicates before they're merged out
- **Dedup window is limited**: Very old duplicates may not be caught
- **Non-deterministic functions break dedup**: `now()`, `rand()` in inserts
