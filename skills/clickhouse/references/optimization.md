# Solana DEX Query Optimization

## Contents
- ORDER BY selection
- Partitioning strategies
- Skip indexes
- Projections for secondary access
- PREWHERE optimization
- Query parallelism
- Common query optimizations

## ORDER BY Selection

ORDER BY determines physical data layout and primary index. Choose based on most common query patterns.

### Trade tables

**By pool (most common):**
```sql
ORDER BY (pool_address, block_time, signature)
```
- Fast: `WHERE pool_address = '...'`
- Fast: `WHERE pool_address = '...' AND block_time >= ...`

**By wallet:**
```sql
ORDER BY (trader_wallet, block_time, signature)
```
- Fast: `WHERE trader_wallet = '...'`

**By token:**
```sql
ORDER BY (token_a_mint, block_time, signature)
```
- Fast: `WHERE token_a_mint = '...'`

### State tables

```sql
ORDER BY (pool_address, slot)
```
- Fast: Latest state per pool with `LIMIT 1`
- Fast: State at specific slot

### Analytics tables

```sql
ORDER BY (wallet_address)  -- Single row per wallet
ORDER BY (mint_address, day)  -- Time series per token
```

## Partitioning

Partition by time for:
- Faster queries with time filters
- Efficient data retention (drop old partitions)
- Parallel query execution

```sql
PARTITION BY toYYYYMM(block_time)
```

**Don't over-partition**: Aim for partitions > 1GB each.

**Partition pruning**: Query must include partition key:
```sql
-- Good: Uses partition pruning
WHERE block_time >= '2024-01-01' AND pool_address = '...'

-- Bad: Full scan across all partitions
WHERE pool_address = '...'
```

## Skip Indexes

Skip indexes help prune granules that can't match query predicates. Useful when ORDER BY doesn't help a specific filter.

### Index Types

| Type | Use Case |
|------|----------|
| `minmax` | Range predicates on loosely sorted columns |
| `set(N)` | Exact match on low-cardinality columns (< N distinct per granule) |
| `bloom_filter` | Exact match/IN on high-cardinality columns |
| `tokenbf_v1` | Word search in strings (hasToken) |
| `ngrambf_v1` | Substring search (LIKE '%...%') |

### Bloom Filter for Wallet/Signature Lookup

When table is ordered by pool but you also filter by wallet:

```sql
CREATE TABLE dex_trades (
    signature String,
    trader_wallet String,
    pool_address String,
    ...
    INDEX idx_wallet trader_wallet TYPE bloom_filter(0.01) GRANULARITY 1,
    INDEX idx_sig signature TYPE bloom_filter(0.01) GRANULARITY 1
)
ENGINE = ReplacingMergeTree()
ORDER BY (pool_address, block_time, signature)
```

Add to existing table:
```sql
ALTER TABLE dex_trades ADD INDEX idx_wallet trader_wallet TYPE bloom_filter(0.01) GRANULARITY 1;
ALTER TABLE dex_trades MATERIALIZE INDEX idx_wallet;
```

### Set Index for DEX Type

When filtering by DEX with few distinct values:

```sql
INDEX idx_dex dex TYPE set(10) GRANULARITY 1
```

### Token Bloom Filter for Text Search

For searching path/memo fields:

```sql
INDEX idx_memo lower(memo) TYPE tokenbf_v1(10000, 7, 7) GRANULARITY 1

-- Query
SELECT * FROM trades WHERE hasToken(lower(memo), 'jupiter')
```

### Verify Index Usage

```sql
EXPLAIN indexes = 1
SELECT * FROM dex_trades WHERE trader_wallet = '...'

-- Check query log for index stats
SELECT
    query,
    ProfileEvents['SelectedMarks'] AS marks_selected,
    ProfileEvents['SelectedRanges'] AS ranges_selected
FROM system.query_log
WHERE query_id = '...'
```

### When Skip Indexes Help

- Filter column not in primary key
- Low selectivity within granules (sparse matching values)
- Correlated with data ordering (values cluster together)

### When Skip Indexes Don't Help

- Most granules contain at least one match (no pruning possible)
- Very high cardinality with uniform distribution
- Column already in primary key

## Projections

Add secondary sort orders without separate tables:

### By wallet (when main table ordered by pool)

```sql
ALTER TABLE dex_trades ADD PROJECTION prj_by_wallet (
    SELECT * ORDER BY (trader_wallet, block_time, signature)
);
ALTER TABLE dex_trades MATERIALIZE PROJECTION prj_by_wallet;
```

Queries filtering by `trader_wallet` automatically use projection.

### By token

```sql
ALTER TABLE dex_trades ADD PROJECTION prj_by_token (
    SELECT * ORDER BY (token_a_mint, block_time, signature)
);
ALTER TABLE dex_trades MATERIALIZE PROJECTION prj_by_token;
```

### Aggregate projection

Pre-compute daily volume per pool:

```sql
ALTER TABLE dex_trades ADD PROJECTION prj_daily_volume (
    SELECT
        pool_address,
        toDate(block_time) AS day,
        sum(volume_usd) AS volume,
        count() AS trades
    GROUP BY pool_address, day
);
ALTER TABLE dex_trades MATERIALIZE PROJECTION prj_daily_volume;
```

### Check projection usage

```sql
EXPLAIN indexes = 1
SELECT * FROM dex_trades WHERE trader_wallet = '...'

-- Or check query log
SELECT projections FROM system.query_log WHERE query_id = '...'
```

## PREWHERE Optimization

PREWHERE filters data column-by-column before reading other columns, reducing I/O.

### How It Works

1. ClickHouse reads only the PREWHERE column first
2. Identifies which granules have matching rows
3. Only reads other columns for those granules

### Automatic PREWHERE

Enabled by default (`optimize_move_to_prewhere = true`). ClickHouse automatically moves WHERE conditions to PREWHERE, prioritizing smaller columns first.

### Manual PREWHERE

Use explicit PREWHERE for selective filters:

```sql
SELECT signature, volume_usd, trader_wallet
FROM dex_trades
PREWHERE pool_address = '...'      -- Read this small column first
WHERE block_time >= now() - INTERVAL 1 HOUR
  AND volume_usd > 1000
```

### Measuring Impact

```sql
-- Compare with and without
SELECT count() FROM dex_trades
WHERE pool_address = '...'
SETTINGS optimize_move_to_prewhere = false;

SELECT count() FROM dex_trades
WHERE pool_address = '...'
SETTINGS optimize_move_to_prewhere = true;
```

Check which columns were moved to PREWHERE:
```sql
EXPLAIN PLAN actions = 1
SELECT * FROM dex_trades WHERE pool_address = '...' AND volume_usd > 1000
-- Look for "Prewhere filter column" in output
```

### Best Candidates for PREWHERE

- Columns with high selectivity (filter out most rows)
- Smaller data types (LowCardinality, UInt8, etc.)
- Columns not in primary key but frequently filtered

## Query Parallelism

ClickHouse distributes work across parallel processing lanes (threads).

### How It Works

1. Selected granules are distributed across `max_threads` lanes
2. Each lane processes data independently
3. Results are merged at the end

### Monitoring Parallelism

```sql
-- See parallel execution in query plan
EXPLAIN PIPELINE
SELECT sum(volume_usd) FROM dex_trades WHERE pool_address = '...'
-- Look for "× N" indicating parallel execution

-- Check actual threads used
SELECT
    query,
    read_rows,
    ProfileEvents['OSCPUVirtualTimeMicroseconds'] / 1000000 AS cpu_seconds,
    query_duration_ms
FROM system.query_log
WHERE query_id = '...'
```

### When Parallelism Is Limited

- Small result sets (< 163,840 rows by default)
- Not enough data to justify additional threads
- Single partition queries with few granules

Settings (don't modify in production):
```sql
-- merge_tree_min_rows_for_concurrent_read (default: 163840)
-- merge_tree_min_bytes_for_concurrent_read (default: 2097152)
```

## Common Query Optimizations

### Limit columns in SELECT

```sql
-- Bad: Reads all columns
SELECT * FROM dex_trades WHERE ...

-- Good: Only needed columns
SELECT signature, block_time, volume_usd FROM dex_trades WHERE ...
```

### Use LowCardinality

```sql
dex LowCardinality(String)  -- 'raydium', 'orca', etc.
trade_type LowCardinality(String)  -- 'swap', 'add_liq', 'remove_liq'
```

Works well for < 10,000 distinct values. Significant compression and speed gains.

### Avoid Nullable when possible

```sql
-- Slower, more storage
price Nullable(Float64)

-- Faster
price Float64 DEFAULT 0
```

Use default values or sentinel values instead.

### Time range + secondary filter

Ensure partition column is in WHERE:

```sql
-- Good: Partition pruning + index
SELECT * FROM dex_trades
WHERE block_time >= now() - INTERVAL 1 HOUR
  AND pool_address = '...'

-- Less optimal: No partition pruning if block_time not in WHERE
SELECT * FROM dex_trades
WHERE slot >= 250000000
  AND pool_address = '...'
```

## Monitoring Query Performance

```sql
-- Recent slow queries
SELECT
    query,
    query_duration_ms,
    read_rows,
    read_bytes,
    memory_usage
FROM system.query_log
WHERE type = 'QueryFinish'
  AND query_duration_ms > 1000
ORDER BY event_time DESC
LIMIT 20

-- Check if projections are used
SELECT query, projections
FROM system.query_log
WHERE projections != []
ORDER BY event_time DESC
```
