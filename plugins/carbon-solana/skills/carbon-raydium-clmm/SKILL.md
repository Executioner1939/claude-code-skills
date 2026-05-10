---
name: carbon-raydium-clmm
description: Carbon decoder reference for Raydium CLMM (concentrated liquidity) on Solana — program `CAMMCzo5YL8w4VFF8KVHrK22GGUsp5VTaW7grrKgrWqK`, crate `carbon-raydium-clmm-decoder` (24 instructions, 8 account types, 11 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "Raydium CLMM", "raydium-clmm", "carbon-raydium-clmm-decoder", "CAMMCzo5YL8w4VFF8KVHrK22GGUsp5VTaW7grrKgrWqK", "RaydiumClmmDecoder", "Raydium CLMM (concentrated liquidity)", "ClosePosition", "CollectFundFee", "CollectProtocolFee", "CollectRemainingRewards", "CreateAmmConfig", "CreateOperationAccount", "CollectPersonalFeeEvent", "CollectProtocolFeeEvent", "ConfigChangeEvent", "CreatePersonalPositionEvent", "AmmConfig", "ObservationState", "OperationState", "PersonalPositionState".
---

# Raydium CLMM

- **Crate:** `carbon-raydium-clmm-decoder`
- **Program ID:** `CAMMCzo5YL8w4VFF8KVHrK22GGUsp5VTaW7grrKgrWqK`
- **Decoder struct:** `RaydiumClmmDecoder`
- **Has CPI events:** yes (in instructions/)

## Instructions

- `ClosePosition`
- `CollectFundFee`
- `CollectProtocolFee`
- `CollectRemainingRewards`
- `CreateAmmConfig`
- `CreateOperationAccount`
- `CreatePool`
- `DecreaseLiquidity`
- `DecreaseLiquidityV2`
- `IncreaseLiquidity`
- `IncreaseLiquidityV2`
- `InitializeReward`
- `OpenPosition`
- `OpenPositionV2`
- `OpenPositionWithToken22Nft`
- `SetRewardParams`
- `Swap`
- `SwapRouterBaseIn`
- `SwapV2`
- `TransferRewardOwner`
- `UpdateAmmConfig`
- `UpdateOperationAccount`
- `UpdatePoolStatus`
- `UpdateRewardInfos`

## Account types

- `AmmConfig`
- `ObservationState`
- `OperationState`
- `PersonalPositionState`
- `PoolState`
- `ProtocolPositionState`
- `TickArrayBitmapExtension`
- `TickArrayState`

## CPI events

- `CollectPersonalFeeEvent`
- `CollectProtocolFeeEvent`
- `ConfigChangeEvent`
- `CreatePersonalPositionEvent`
- `DecreaseLiquidityEvent`
- `IncreaseLiquidityEvent`
- `LiquidityCalculateEvent`
- `LiquidityChangeEvent`
- `PoolCreatedEvent`
- `SwapEvent`
- `UpdateRewardInfosEvent`

## Shared types

- `InitializeRewardParam`
- `Observation`
- `PoolStatusBitFlag`
- `PoolStatusBitIndex`
- `PositionRewardInfo`
- `RewardInfo`
- `RewardState`
- `TickArryBitmap`
- `TickState`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list raydium-clmm

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix raydium-clmm <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account raydium-clmm <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event raydium-clmm <EventName>

# shared type fields
python3 "$CARBON" type raydium-clmm <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path raydium-clmm
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-raydium-clmm-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
