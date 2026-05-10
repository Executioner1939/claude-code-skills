---
name: carbon-raydium-liquidity-locking
description: Carbon decoder reference for Raydium Liquidity Locking on Solana — program `LockrWmn6K5twhz3y9w1dQERbmgSaRkfnTeTKbpofwE`, crate `carbon-raydium-liquidity-locking-decoder` (4 instructions, 2 account types, 1 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "Raydium Liquidity Locking", "raydium-liquidity-locking", "carbon-raydium-liquidity-locking-decoder", "LockrWmn6K5twhz3y9w1dQERbmgSaRkfnTeTKbpofwE", "RaydiumLiquidityLockingDecoder", "CollectClmmFeesAndRewards", "CollectCpFees", "LockClmmPosition", "LockCpLiquidity", "SettleCpFeeEvent", "LockedClmmPositionState", "LockedCpLiquidityState".
---

# Raydium Liquidity Locking

- **Crate:** `carbon-raydium-liquidity-locking-decoder`
- **Program ID:** `LockrWmn6K5twhz3y9w1dQERbmgSaRkfnTeTKbpofwE`
- **Decoder struct:** `RaydiumLiquidityLockingDecoder`
- **Has CPI events:** yes (in instructions/)

## Instructions

- `CollectClmmFeesAndRewards`
- `CollectCpFees`
- `LockClmmPosition`
- `LockCpLiquidity`

## Account types

- `LockedClmmPositionState`
- `LockedCpLiquidityState`

## CPI events

- `SettleCpFeeEvent`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list raydium-liquidity-locking

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix raydium-liquidity-locking <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account raydium-liquidity-locking <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event raydium-liquidity-locking <EventName>

# shared type fields
python3 "$CARBON" type raydium-liquidity-locking <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path raydium-liquidity-locking
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-raydium-liquidity-locking-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
