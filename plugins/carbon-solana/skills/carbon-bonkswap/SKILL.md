---
name: carbon-bonkswap
description: "Carbon decoder reference for Bonkswap on Solana — program `BSwp6bEBihVLdqJRKGgzjcGLHkcTuzmSo1TQkHepzH8p`, crate `carbon-bonkswap-decoder` (19 instructions, 5 account types). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"Bonkswap\", \"bonkswap\", \"carbon-bonkswap-decoder\", \"BSwp6bEBihVLdqJRKGgzjcGLHkcTuzmSo1TQkHepzH8p\", \"BonkswapDecoder\", \"AddSupply\", \"AddTokens\", \"ClosePool\", \"CreateDualFarm\", \"CreateFarm\", \"CreatePool\", \"Farm\", \"Pool\", \"PoolV2\", \"Provider\"."
---

# Bonkswap

- **Crate:** `carbon-bonkswap-decoder`
- **Program ID:** `BSwp6bEBihVLdqJRKGgzjcGLHkcTuzmSo1TQkHepzH8p`
- **Decoder struct:** `BonkswapDecoder`
- **Has CPI events:** no

## Instructions

- `AddSupply`
- `AddTokens`
- `ClosePool`
- `CreateDualFarm`
- `CreateFarm`
- `CreatePool`
- `CreateProvider`
- `CreateState`
- `CreateTripleFarm`
- `ResetFarm`
- `Swap`
- `UpdateFees`
- `UpdateRewardTokens`
- `WithdrawBuyback`
- `WithdrawLpFee`
- `WithdrawMercantiFee`
- `WithdrawProjectFee`
- `WithdrawRewards`
- `WithdrawShares`

## Account types

- `Farm`
- `Pool`
- `PoolV2`
- `Provider`
- `State`

## Shared types

- `FarmType`
- `FixedPoint`
- `Product`
- `Token`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list bonkswap

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix bonkswap <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account bonkswap <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event bonkswap <EventName>

# shared type fields
python3 "$CARBON" type bonkswap <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path bonkswap
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-bonkswap-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
