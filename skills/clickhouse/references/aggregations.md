# Solana DEX Aggregation Patterns

## Contents
- OHLCV candles
- Volume aggregations
- Multi-granularity rollups
- Wallet activity windows
- Time series patterns (gap fill, trends, rates)
- Histograms and distributions
- Backfilling materialized views
- Codec optimization for time columns

## OHLCV Candles

### Target Table

```sql
CREATE TABLE trade_ohlcv_5min (
    pool_address String,
    bucket DateTime,

    -- OHLC (need argMin/argMax for first/last by time)
    open AggregateFunction(argMin, Float64, DateTime64(3)),
    high SimpleAggregateFunction(max, Float64),
    low SimpleAggregateFunction(min, Float64),
    close AggregateFunction(argMax, Float64, DateTime64(3)),

    -- Volume
    volume_token_a SimpleAggregateFunction(sum, UInt64),
    volume_token_b SimpleAggregateFunction(sum, UInt64),
    volume_usd SimpleAggregateFunction(sum, Float64),

    -- Counts
    trade_count SimpleAggregateFunction(sum, UInt64),
    buy_count SimpleAggregateFunction(sum, UInt64),
    sell_count SimpleAggregateFunction(sum, UInt64)
)
ENGINE = AggregatingMergeTree()
ORDER BY (pool_address, bucket)
PARTITION BY toYYYYMM(bucket)
```

### Materialized View

```sql
CREATE MATERIALIZED VIEW mv_trade_ohlcv_5min TO trade_ohlcv_5min AS
SELECT
    pool_address,
    toStartOfFiveMinutes(block_time) AS bucket,

    argMinState(price_usd, block_time) AS open,
    maxSimpleState(price_usd) AS high,
    minSimpleState(price_usd) AS low,
    argMaxState(price_usd, block_time) AS close,

    sumSimpleState(amount_in) AS volume_token_a,
    sumSimpleState(amount_out) AS volume_token_b,
    sumSimpleState(volume_usd) AS volume_usd,

    countSimpleState() AS trade_count,
    sumSimpleState(is_buy) AS buy_count,
    sumSimpleState(1 - is_buy) AS sell_count
FROM dex_trades
GROUP BY pool_address, bucket
```

### Query Pattern

```sql
SELECT
    bucket,
    argMinMerge(open) AS open,
    max(high) AS high,
    min(low) AS low,
    argMaxMerge(close) AS close,
    sum(volume_usd) AS volume,
    sum(trade_count) AS trades
FROM trade_ohlcv_5min
WHERE pool_address = '...'
  AND bucket >= now() - INTERVAL 24 HOUR
GROUP BY bucket
ORDER BY bucket
```

## Multi-Granularity Rollups

### Hourly from 5min

```sql
CREATE TABLE trade_ohlcv_hourly AS trade_ohlcv_5min;

CREATE MATERIALIZED VIEW mv_trade_ohlcv_hourly TO trade_ohlcv_hourly AS
SELECT
    pool_address,
    toStartOfHour(bucket) AS bucket,

    -- First open of the hour
    argMinState(argMinMerge(open), bucket) AS open,
    max(high) AS high,
    min(low) AS low,
    -- Last close of the hour
    argMaxState(argMaxMerge(close), bucket) AS close,

    sum(volume_token_a) AS volume_token_a,
    sum(volume_token_b) AS volume_token_b,
    sum(volume_usd) AS volume_usd,
    sum(trade_count) AS trade_count,
    sum(buy_count) AS buy_count,
    sum(sell_count) AS sell_count
FROM trade_ohlcv_5min
GROUP BY pool_address, toStartOfHour(bucket)
```

### Daily from Hourly

```sql
CREATE TABLE trade_ohlcv_daily AS trade_ohlcv_5min;

CREATE MATERIALIZED VIEW mv_trade_ohlcv_daily TO trade_ohlcv_daily AS
SELECT
    pool_address,
    toStartOfDay(bucket) AS bucket,

    argMinState(argMinMerge(open), bucket) AS open,
    max(high) AS high,
    min(low) AS low,
    argMaxState(argMaxMerge(close), bucket) AS close,

    sum(volume_token_a) AS volume_token_a,
    sum(volume_token_b) AS volume_token_b,
    sum(volume_usd) AS volume_usd,
    sum(trade_count) AS trade_count,
    sum(buy_count) AS buy_count,
    sum(sell_count) AS sell_count
FROM trade_ohlcv_hourly
GROUP BY pool_address, toStartOfDay(bucket)
```

## Volume by Token

```sql
CREATE TABLE token_volume_daily (
    mint_address String,
    day Date,

    volume_usd SimpleAggregateFunction(sum, Float64),
    trade_count SimpleAggregateFunction(sum, UInt64),
    unique_traders AggregateFunction(uniq, String)
)
ENGINE = AggregatingMergeTree()
ORDER BY (mint_address, day);

CREATE MATERIALIZED VIEW mv_token_volume_daily TO token_volume_daily AS
SELECT
    token_a_mint AS mint_address,
    toDate(block_time) AS day,
    sumSimpleState(volume_usd) AS volume_usd,
    countSimpleState() AS trade_count,
    uniqState(trader_wallet) AS unique_traders
FROM dex_trades
GROUP BY mint_address, day
```

Query:
```sql
SELECT
    day,
    sum(volume_usd) AS volume,
    sum(trade_count) AS trades,
    uniqMerge(unique_traders) AS unique_traders
FROM token_volume_daily
WHERE mint_address = '...'
GROUP BY day
ORDER BY day DESC
```

## Wallet Activity Windows

Track wallet behavior over sliding windows:

```sql
CREATE TABLE wallet_activity_windows (
    wallet_address String,
    window_start DateTime,
    window_minutes UInt16,        -- 5, 60, 1440

    trade_count SimpleAggregateFunction(sum, UInt64),
    volume_usd SimpleAggregateFunction(sum, Float64),
    unique_tokens AggregateFunction(uniq, String),
    unique_pools AggregateFunction(uniq, String),

    -- Bot detection signals
    avg_time_between_trades AggregateFunction(avg, Float64),
    trades_per_minute SimpleAggregateFunction(max, Float64)
)
ENGINE = AggregatingMergeTree()
ORDER BY (wallet_address, window_start, window_minutes)
TTL window_start + INTERVAL 7 DAY
```

## Time Series Patterns

### Filling Empty Time Buckets

Sparse data creates gaps in time series. Use `WITH FILL` to fill empty buckets:

```sql
SELECT
    toStartOfHour(block_time) AS h,
    sum(volume_usd) AS volume
FROM dex_trades
WHERE pool_address = '...'
  AND block_time >= now() - INTERVAL 24 HOUR
GROUP BY h
ORDER BY h ASC WITH FILL STEP toIntervalHour(1)
```

Fill with custom boundaries:
```sql
ORDER BY h ASC
WITH FILL
  FROM toStartOfDay(now() - INTERVAL 7 DAY)
  TO toStartOfDay(now())
  STEP toIntervalHour(1)
```

### Filling with Previous Value (Gauges)

For metrics like pool TVL that should carry forward:

```sql
SELECT
    toStartOfHour(block_time) AS h,
    any(tvl_usd) AS tvl
FROM pool_states
WHERE pool_address = '...'
GROUP BY h
ORDER BY h ASC WITH FILL STEP toIntervalHour(1)
INTERPOLATE (tvl AS tvl)  -- Carry forward previous value
```

### Custom Time Intervals

Group by arbitrary intervals (e.g., 4-hour buckets):

```sql
SELECT
    toStartOfInterval(block_time, INTERVAL 4 HOUR) AS bucket,
    sum(volume_usd) AS volume
FROM dex_trades
WHERE pool_address = '...'
GROUP BY bucket
ORDER BY bucket
```

### Trends (Change from Previous Period)

Calculate day-over-day change:

```sql
SELECT
    toDate(block_time) AS d,
    sum(volume_usd) AS volume,
    lagInFrame(volume) OVER (ORDER BY d ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS prev_volume,
    volume - prev_volume AS trend
FROM dex_trades
WHERE pool_address = '...'
GROUP BY d
ORDER BY d ASC
```

### Cumulative Values

Running total over time:

```sql
SELECT
    toDate(block_time) AS d,
    sum(volume_usd) AS daily_volume,
    sum(daily_volume) OVER (ORDER BY d ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_volume
FROM dex_trades
WHERE pool_address = '...'
GROUP BY d
ORDER BY d ASC
```

### Rates (Per-Second Metrics)

Calculate trade rate per second for each hour:

```sql
SELECT
    toStartOfHour(block_time) AS h,
    count() AS trades,
    round(trades / 3600, 2) AS trades_per_second
FROM dex_trades
WHERE pool_address = '...'
  AND block_time >= now() - INTERVAL 24 HOUR
GROUP BY h
ORDER BY h
```

### Rolling Time Windows

Group by 24-hour windows offset from a specific time:

```sql
SELECT
    dateDiff('day', toDateTime('2024-01-01 18:00:00'), block_time) AS day_offset,
    sum(volume_usd) AS volume
FROM dex_trades
WHERE pool_address = '...'
GROUP BY day_offset
ORDER BY day_offset
```

## Histograms and Distributions

Build histograms to analyze trade size distribution:

```sql
WITH histogram(10)(volume_usd) AS hist
SELECT
    round(arrayJoin(hist).1) AS lower_bound,
    round(arrayJoin(hist).2) AS upper_bound,
    arrayJoin(hist).3 AS count,
    bar(count, 0, max(count) OVER (), 20) AS visual
FROM (
    SELECT sum(volume_usd) AS volume_usd
    FROM dex_trades
    WHERE pool_address = '...'
      AND block_time >= now() - INTERVAL 24 HOUR
    GROUP BY signature
)
```

Result shows trade size buckets:
```
│ lower_bound │ upper_bound │ count │ visual              │
│         100 │         500 │    53 │ ████████████████████│
│         500 │        1000 │    19 │ ███████             │
│        1000 │        5000 │     6 │ ██                  │
```

### Per-wallet trade distribution

```sql
SELECT
    trader_wallet,
    count() AS trades,
    quantiles(0.5, 0.9, 0.99)(volume_usd) AS volume_percentiles
FROM dex_trades
WHERE pool_address = '...'
  AND block_time >= now() - INTERVAL 7 DAY
GROUP BY trader_wallet
ORDER BY trades DESC
LIMIT 10
```

## Backfilling Materialized Views

When creating MVs on tables with existing data, you need to backfill.

### Method 1: Direct INSERT (simple but memory-intensive)

```sql
-- MV target table already exists
INSERT INTO trade_ohlcv_5min
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
GROUP BY pool_address, bucket
```

### Method 2: Null Table (memory-efficient for large datasets)

For billion+ row tables, use a Null table to process in streaming fashion:

```sql
-- 1. Create temporary Null table (stores nothing)
CREATE TABLE dex_trades_backfill AS dex_trades
ENGINE = Null;

-- 2. Create MV from Null table to target
CREATE MATERIALIZED VIEW mv_backfill TO trade_ohlcv_5min AS
SELECT
    pool_address,
    toStartOfFiveMinutes(block_time) AS bucket,
    argMinState(price_usd, block_time) AS open,
    maxSimpleState(price_usd) AS high,
    minSimpleState(price_usd) AS low,
    argMaxState(price_usd, block_time) AS close,
    sumSimpleState(amount_out) AS volume,
    countState() AS trade_count
FROM dex_trades_backfill
GROUP BY pool_address, bucket;

-- 3. Stream data through (processes block by block)
INSERT INTO dex_trades_backfill
SELECT * FROM dex_trades;

-- 4. Cleanup
DROP VIEW mv_backfill;
DROP TABLE dex_trades_backfill;
```

This approach:
- Processes data in blocks (low memory)
- Writes partial states to target incrementally
- States merge in background

### Backfill by time range

For very large datasets, backfill in chunks:

```sql
INSERT INTO trade_ohlcv_5min
SELECT ...
FROM dex_trades
WHERE block_time >= '2024-01-01' AND block_time < '2024-02-01'
GROUP BY pool_address, bucket;

-- Repeat for each month
```

## Codec Optimization for Time Columns

Time columns in time series data benefit from Delta codec:

```sql
CREATE TABLE dex_trades (
    block_time DateTime64(3) CODEC(Delta(4), ZSTD(1)),
    slot UInt64 CODEC(Delta(8), ZSTD(1)),
    ...
)
```

Delta encodes differences between consecutive values. Sequential timestamps compress extremely well since differences are small and regular.

Compression comparison:
- Without codec: ~8 bytes per timestamp
- With Delta + ZSTD: ~1-2 bytes per timestamp

Apply to existing table:
```sql
ALTER TABLE dex_trades
MODIFY COLUMN block_time CODEC(Delta(4), ZSTD(1))
```

## Gotchas

- **SimpleAggregateFunction vs AggregateFunction**: Use Simple for sum/min/max (smaller storage). Use full AggregateFunction for argMin/argMax/uniq.
- **Cascaded MVs see blocks, not merged data**: Can't use FINAL in MV source.
- **GROUP BY must match ORDER BY**: Target table ORDER BY should include all GROUP BY columns.
