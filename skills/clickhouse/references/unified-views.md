# Cross-DEX Unified Views

## Contents
- Unified trades view
- Unified pools view
- Unified tokens view

## Unified Trades View

Merge trades from multiple DEX-specific tables:

```sql
CREATE VIEW unified_trades AS
SELECT
    signature,
    slot,
    block_time,
    'raydium' AS dex,
    pool_address,
    trader_wallet,
    token_in,
    token_out,
    amount_in,
    amount_out,
    price_usd,
    volume_usd,
    is_buy
FROM raydium_trades

UNION ALL

SELECT
    signature,
    slot,
    block_time,
    'orca' AS dex,
    pool_address,
    trader_wallet,
    token_in,
    token_out,
    amount_in,
    amount_out,
    price_usd,
    volume_usd,
    is_buy
FROM orca_trades

UNION ALL

SELECT
    signature,
    slot,
    block_time,
    'meteora' AS dex,
    pool_address,
    trader_wallet,
    token_in,
    token_out,
    amount_in,
    amount_out,
    price_usd,
    volume_usd,
    is_buy
FROM meteora_trades
```

### Query patterns

**Total volume by DEX:**
```sql
SELECT dex, sum(volume_usd) AS volume
FROM unified_trades
WHERE block_time >= now() - INTERVAL 24 HOUR
GROUP BY dex
```

**Token volume across all DEXes:**
```sql
SELECT
    token_in AS token,
    sum(volume_usd) AS volume,
    count() AS trades
FROM unified_trades
WHERE block_time >= now() - INTERVAL 1 HOUR
GROUP BY token
ORDER BY volume DESC
LIMIT 20
```

## Unified Pools View

Combine different pool types:

```sql
CREATE VIEW unified_pools AS
SELECT
    pool_address,
    'raydium_amm' AS pool_type,
    token_a_mint,
    token_b_mint,
    token_a_reserve,
    token_b_reserve,
    tvl_usd,
    volume_24h_usd,
    slot,
    block_time
FROM raydium_pool_states FINAL

UNION ALL

SELECT
    pool_address,
    'orca_whirlpool' AS pool_type,
    token_a_mint,
    token_b_mint,
    token_a_reserve,
    token_b_reserve,
    tvl_usd,
    volume_24h_usd,
    slot,
    block_time
FROM orca_pool_states FINAL

UNION ALL

SELECT
    pool_address,
    'meteora_dlmm' AS pool_type,
    token_a_mint,
    token_b_mint,
    token_a_reserve,
    token_b_reserve,
    tvl_usd,
    volume_24h_usd,
    slot,
    block_time
FROM meteora_pool_states FINAL
```

## Unified Tokens View

Token info with aggregated stats:

```sql
CREATE VIEW unified_tokens AS
SELECT
    t.mint_address,
    t.name,
    t.symbol,
    t.decimals,
    t.creator_wallet,

    -- Latest price
    p.price_usd,

    -- Aggregated stats
    s.total_pools,
    s.total_volume_24h,
    s.total_tvl
FROM tokens t
LEFT JOIN (
    SELECT
        mint_address,
        argMax(price_usd, block_time) AS price_usd
    FROM token_prices
    WHERE block_time >= now() - INTERVAL 1 HOUR
    GROUP BY mint_address
) p ON t.mint_address = p.mint_address
LEFT JOIN (
    SELECT
        token_a_mint AS mint_address,
        count() AS total_pools,
        sum(volume_24h_usd) AS total_volume_24h,
        sum(tvl_usd) AS total_tvl
    FROM unified_pools
    GROUP BY mint_address
) s ON t.mint_address = s.mint_address
```

## Alternative: merge() Function

For tables with similar schemas, use `merge()` instead of UNION:

```sql
SELECT *
FROM merge('.*_trades')
WHERE block_time >= now() - INTERVAL 1 HOUR
```

**Identify source table:**
```sql
SELECT _table, count()
FROM merge('.*_trades')
WHERE block_time >= now() - INTERVAL 1 HOUR
GROUP BY _table
```

**Handle schema differences:**
```sql
SELECT
    signature,
    block_time,
    -- Handle column that might not exist in all tables
    if(_table = 'pumpfun_trades', bonding_curve_address, pool_address) AS pool_address
FROM merge('.*_trades')
```

## Performance Tips

- **Views don't store data**: Each query re-executes the UNION
- **Use materialized views for heavy aggregations**: If unified queries are frequent
- **Filter early**: Push WHERE conditions into each branch if possible
- **Consider partitioning alignment**: All source tables should partition the same way
