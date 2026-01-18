---
name: designing-solana-dex-tables
description: Designs ClickHouse tables for Solana DEX analytics. Use when creating schemas for trades, pools, tokens, wallets, or time-series aggregations. Triggers on "Solana", "DEX", "swap", "liquidity pool", "OHLCV", "trade analytics", "ClickHouse blockchain", "skip index", "bloom filter", "PREWHERE", "time series", "Delta codec", "DateTime64", "histogram", "backfill materialized view", "AggregatingMergeTree".
---

# Solana DEX Table Design

## Quick Decision Guide

| Need | Solution |
|------|----------|
| Store trades (deduplicated by tx) | ReplacingMergeTree ORDER BY (signature) |
| Pool/token state snapshots | ReplacingMergeTree ORDER BY (address, slot) |
| OHLCV / volume aggregations | Materialized View → AggregatingMergeTree |
| Multi-granularity rollups | Cascaded MVs (5min → hourly → daily) |
| Cross-DEX unified queries | Regular VIEW with UNION ALL |
| Wallet activity scoring | ReplacingMergeTree with pre-computed metrics |
| Secondary filter not in ORDER BY | Skip index (bloom_filter for wallet/signature) |
| Fill gaps in time series | WITH FILL modifier + INTERPOLATE |
| Compress time columns | Delta codec + ZSTD |
| Analyze trade size distribution | histogram() function |
| Backfill MV on large table | Null table streaming technique |

## Core Table Patterns

### Trades Table

```sql
CREATE TABLE dex_trades (
    signature String,           -- Transaction signature (unique key)
    slot UInt64,                -- Slot number (block equivalent)
    block_time DateTime64(3),
    dex LowCardinality(String), -- 'raydium', 'orca', 'jupiter', etc.
    pool_address String,
    trader_wallet String,
    token_in String,
    token_out String,
    amount_in UInt64,           -- Raw amount (apply decimals in query)
    amount_out UInt64,
    price_usd Float64,
    fee_amount UInt64,
    is_buy UInt8                -- 1 = buy, 0 = sell (relative to base token)
)
ENGINE = ReplacingMergeTree()
ORDER BY (pool_address, block_time, signature)
PARTITION BY toYYYYMM(block_time)
```

**ORDER BY rationale:**
- `pool_address` first: most queries filter by pool/token
- `block_time` second: time-range queries are common
- `signature` last: ensures uniqueness for deduplication

### Pool State Snapshots

```sql
CREATE TABLE pool_states (
    pool_address String,
    slot UInt64,
    block_time DateTime64(3),
    token_a_reserve UInt64,
    token_b_reserve UInt64,
    lp_supply UInt64,
    price Float64,
    tvl_usd Float64
)
ENGINE = ReplacingMergeTree()
ORDER BY (pool_address, slot)
PARTITION BY toYYYYMM(block_time)
```

Query latest state:
```sql
SELECT * FROM pool_states FINAL WHERE pool_address = '...'
ORDER BY slot DESC LIMIT 1
```

## Aggregation Patterns

### OHLCV Materialized View

```sql
CREATE TABLE trade_ohlcv_5min (
    pool_address String,
    bucket DateTime,
    open AggregateFunction(argMin, Float64, DateTime64(3)),
    high SimpleAggregateFunction(max, Float64),
    low SimpleAggregateFunction(min, Float64),
    close AggregateFunction(argMax, Float64, DateTime64(3)),
    volume SimpleAggregateFunction(sum, UInt64),
    trade_count SimpleAggregateFunction(sum, UInt64)
)
ENGINE = AggregatingMergeTree()
ORDER BY (pool_address, bucket);

CREATE MATERIALIZED VIEW mv_trade_ohlcv_5min TO trade_ohlcv_5min AS
SELECT
    pool_address,
    toStartOfFiveMinutes(block_time) AS bucket,
    argMinState(price_usd, block_time) AS open,
    maxSimpleState(price_usd) AS high,
    minSimpleState(price_usd) AS low,
    argMaxState(price_usd, block_time) AS close,
    sumSimpleState(amount_out) AS volume,
    countState() AS trade_count
FROM dex_trades
GROUP BY pool_address, bucket;
```

Query OHLCV:
```sql
SELECT
    bucket,
    argMinMerge(open) AS open,
    max(high) AS high,
    min(low) AS low,
    argMaxMerge(close) AS close,
    sum(volume) AS volume
FROM trade_ohlcv_5min
WHERE pool_address = '...' AND bucket >= now() - INTERVAL 24 HOUR
GROUP BY bucket ORDER BY bucket
```

### Cascaded Rollups (5min → hourly → daily)

```sql
-- Hourly from 5min
CREATE MATERIALIZED VIEW mv_trade_ohlcv_hourly TO trade_ohlcv_hourly AS
SELECT
    pool_address,
    toStartOfHour(bucket) AS bucket,
    argMinState(argMinMerge(open), bucket) AS open,
    max(high) AS high,
    min(low) AS low,
    argMaxState(argMaxMerge(close), bucket) AS close,
    sum(volume) AS volume,
    sum(trade_count) AS trade_count
FROM trade_ohlcv_5min
GROUP BY pool_address, toStartOfHour(bucket);
```

## Key Rules

**Deduplication**: Same transaction can be ingested multiple times. ReplacingMergeTree with `signature` in ORDER BY handles this.

**Query with FINAL or re-aggregate**: Data may have duplicates until merge.
```sql
SELECT * FROM dex_trades FINAL WHERE ...
-- OR aggregate to dedupe
SELECT pool_address, sum(amount_out) FROM dex_trades GROUP BY pool_address
```

**Amounts are raw integers**: Store as UInt64, apply decimals in queries:
```sql
SELECT amount_in / pow(10, 9) AS amount_sol  -- SOL has 9 decimals
```

**LowCardinality for enums**: Use for `dex`, `trade_type`, etc. (< 10k distinct values).

## Reference Files

- [references/table-patterns.md](references/table-patterns.md) - Trades, pools, tokens, wallets schemas, date/time types, timezone handling
- [references/aggregations.md](references/aggregations.md) - OHLCV, volume, MVs, time series (gap fill, trends, rates), histograms, MV backfilling, codecs
- [references/unified-views.md](references/unified-views.md) - Cross-DEX queries, UNION patterns
- [references/deduplication.md](references/deduplication.md) - ReplacingMergeTree, insert strategies
- [references/optimization.md](references/optimization.md) - ORDER BY, partitioning, skip indexes, PREWHERE, projections, query parallelism
