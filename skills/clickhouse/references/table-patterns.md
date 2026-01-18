# Solana DEX Table Patterns

## Contents
- Trades table
- Pool tables
- Token tables
- Wallet tables
- Data types summary
- Date and time types

## Trades Table

The core event table for DEX analytics.

```sql
CREATE TABLE dex_trades (
    -- Identity
    signature String,
    instruction_index UInt8,      -- Multiple swaps per tx

    -- Ordering
    slot UInt64,
    block_time DateTime64(3),

    -- Source
    dex LowCardinality(String),   -- 'raydium', 'orca', 'jupiter', 'meteora'
    program_id String,

    -- Pool/Pair
    pool_address String,
    token_a_mint String,          -- Base token
    token_b_mint String,          -- Quote token

    -- Trade details
    trader_wallet String,
    token_in String,
    token_out String,
    amount_in UInt64,
    amount_out UInt64,

    -- Pricing
    price Float64,                -- token_out/token_in
    price_usd Float64,
    volume_usd Float64,

    -- Fees
    fee_amount UInt64,
    fee_mint String,

    -- Direction
    is_buy UInt8,                 -- 1 = buy base, 0 = sell base
    trade_type LowCardinality(String)  -- 'swap', 'add_liquidity', 'remove_liquidity'
)
ENGINE = ReplacingMergeTree()
ORDER BY (pool_address, block_time, signature, instruction_index)
PARTITION BY toYYYYMM(block_time)
```

### Alternative ORDER BY options

**By wallet (for wallet analytics):**
```sql
ORDER BY (trader_wallet, block_time, signature)
```

**By token (for token analytics):**
```sql
ORDER BY (token_a_mint, block_time, signature)
```

**Consider projections** for secondary access patterns instead of multiple tables.

## Pool Tables

### Pool Creation Events

```sql
CREATE TABLE pool_creations (
    signature String,
    slot UInt64,
    block_time DateTime64(3),

    dex LowCardinality(String),
    pool_address String,

    token_a_mint String,
    token_b_mint String,

    creator_wallet String,
    initial_token_a UInt64,
    initial_token_b UInt64,
    initial_lp_supply UInt64,

    fee_rate UInt32,              -- Basis points
    pool_type LowCardinality(String)  -- 'constant_product', 'stable', 'concentrated'
)
ENGINE = ReplacingMergeTree()
ORDER BY (pool_address, slot)
```

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
    price_usd Float64,
    tvl_usd Float64,

    volume_24h_usd Float64,
    fee_24h_usd Float64
)
ENGINE = ReplacingMergeTree()
ORDER BY (pool_address, slot)
PARTITION BY toYYYYMM(block_time)
```

**Query latest state:**
```sql
SELECT * FROM pool_states FINAL
WHERE pool_address = '...'
ORDER BY slot DESC LIMIT 1
```

**Query state at specific time:**
```sql
SELECT * FROM pool_states FINAL
WHERE pool_address = '...' AND slot <= toUInt64(...)
ORDER BY slot DESC LIMIT 1
```

## Token Tables

### Token Metadata

```sql
CREATE TABLE tokens (
    mint_address String,
    slot_created UInt64,
    block_time_created DateTime64(3),

    name String,
    symbol LowCardinality(String),
    decimals UInt8,

    creator_wallet String,
    supply UInt64,

    -- Metadata
    uri String,
    is_verified UInt8,

    -- Updated fields
    updated_slot UInt64
)
ENGINE = ReplacingMergeTree(updated_slot)
ORDER BY (mint_address)
```

### Token Price History

```sql
CREATE TABLE token_prices (
    mint_address String,
    block_time DateTime64(3),

    price_usd Float64,
    price_sol Float64,

    source LowCardinality(String)  -- 'jupiter', 'birdeye', 'computed'
)
ENGINE = ReplacingMergeTree()
ORDER BY (mint_address, block_time)
PARTITION BY toYYYYMM(block_time)
TTL block_time + INTERVAL 90 DAY
```

## Wallet Tables

### Wallet Activity Summary

```sql
CREATE TABLE wallet_stats (
    wallet_address String,
    updated_slot UInt64,

    -- Counts
    total_trades UInt64,
    unique_tokens_traded UInt32,
    unique_pools_used UInt32,

    -- Volume
    total_volume_usd Float64,
    volume_30d_usd Float64,

    -- PnL
    realized_pnl_usd Float64,

    -- Activity
    first_trade_time DateTime64(3),
    last_trade_time DateTime64(3),

    -- Risk indicators
    is_bot UInt8,
    risk_score Float32
)
ENGINE = ReplacingMergeTree(updated_slot)
ORDER BY (wallet_address)
```

### Wallet Token Holdings

```sql
CREATE TABLE wallet_holdings (
    wallet_address String,
    mint_address String,
    slot UInt64,

    balance UInt64,
    value_usd Float64
)
ENGINE = ReplacingMergeTree()
ORDER BY (wallet_address, mint_address, slot)
```

## Data Types Summary

| Solana Concept | ClickHouse Type |
|----------------|-----------------|
| Signature (88 chars) | String |
| Address (44 chars) | String |
| Slot | UInt64 |
| Timestamp | DateTime64(3) |
| Token amount (raw) | UInt64 |
| Price | Float64 |
| Decimals | UInt8 |
| Boolean flags | UInt8 |
| Enum-like values | LowCardinality(String) |

## Date and Time Types

### Choosing the Right Type

| Type | Bytes | Range | Use Case |
|------|-------|-------|----------|
| `Date` | 2 | 1970-2149 | Daily aggregations only |
| `Date32` | 4 | 1900-2299 | Historical dates |
| `DateTime` | 4 | 1970-2106 | Second precision sufficient |
| `DateTime64(3)` | 8 | 1900-2299 | Millisecond precision (Solana standard) |
| `DateTime64(6)` | 8 | 1900-2299 | Microsecond precision |
| `DateTime64(9)` | 8 | 1900-2299 | Nanosecond precision |

**Recommendation for Solana**: Use `DateTime64(3)` for `block_time` - Solana block times have millisecond precision.

### Timezone Handling

Store timestamps in UTC. Apply timezone conversion at query time:

```sql
-- Table definition (no timezone = UTC)
CREATE TABLE dex_trades (
    block_time DateTime64(3),
    ...
)

-- Query with timezone conversion
SELECT
    toTimezone(block_time, 'America/New_York') AS local_time,
    sum(volume_usd)
FROM dex_trades
WHERE block_time >= now() - INTERVAL 24 HOUR
GROUP BY toStartOfHour(local_time)
```

Or store with explicit timezone:
```sql
block_time DateTime64(3, 'UTC')
```

### Type Conversions

```sql
-- DateTime64 to Date
SELECT toDate(block_time) AS day

-- DateTime64 to DateTime (lose precision)
SELECT toDateTime(block_time) AS second_precision

-- Unix timestamp (milliseconds) to DateTime64
SELECT fromUnixTimestamp64Milli(1704067200000) AS block_time

-- DateTime64 to Unix milliseconds
SELECT toUnixTimestamp64Milli(block_time) AS unix_ms
```

### Storage Optimization

Combine with Delta codec for sequential time data:
```sql
block_time DateTime64(3) CODEC(Delta(4), ZSTD(1))
slot UInt64 CODEC(Delta(8), ZSTD(1))
```
