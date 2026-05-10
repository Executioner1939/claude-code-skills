---
name: carbon-pancake-swap
description: Carbon decoder reference for Pancake Swap on Solana — program `HpNfyc2Saw7RKkQd8nEL4khUcuPhQ7WwY1B2qjx8jxFq`, crate `carbon-pancake-swap-decoder` (27 instructions, 10 account types, 11 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "Pancake Swap", "pancake-swap", "carbon-pancake-swap-decoder", "HpNfyc2Saw7RKkQd8nEL4khUcuPhQ7WwY1B2qjx8jxFq", "PancakeSwapDecoder", "ClosePosition", "CollectFundFee", "CollectProtocolFee", "CollectRemainingRewards", "CreateAmmConfig", "CreateOperationAccount", "CollectPersonalFeeEvent", "CollectProtocolFeeEvent", "ConfigChangeEvent", "CreatePersonalPositionEvent", "AmmConfig", "ObservationState", "OperationState", "PermissionlessFarmSwitch".
---

# Pancake Swap

- **Crate:** `carbon-pancake-swap-decoder`
- **Program ID:** `HpNfyc2Saw7RKkQd8nEL4khUcuPhQ7WwY1B2qjx8jxFq`
- **Decoder struct:** `PancakeSwapDecoder`
- **Has CPI events:** yes (in instructions/)

## Instructions

- `ClosePosition`
- `CollectFundFee`
- `CollectProtocolFee`
- `CollectRemainingRewards`
- `CreateAmmConfig`
- `CreateOperationAccount`
- `CreatePermissionlessFarmSwitch`
- `CreatePool`
- `CreateSupportMintAssociated`
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
- `TogglePermissionlessFarmSwitch`
- `TransferRewardOwner`
- `UpdateAmmConfig`
- `UpdateOperationAccount`
- `UpdatePoolStatus`
- `UpdateRewardInfos`

## Account types

- `AmmConfig`
- `ObservationState`
- `OperationState`
- `PermissionlessFarmSwitch`
- `PersonalPositionState`
- `PoolState`
- `ProtocolPositionState`
- `SupportMintAssociated`
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

- `AmmConfig`
- `CollectPersonalFeeEvent`
- `CollectProtocolFeeEvent`
- `ConfigChangeEvent`
- `CreatePersonalPositionEvent`
- `DecreaseLiquidityEvent`
- `IncreaseLiquidityEvent`
- `InitializeRewardParam`
- `LiquidityCalculateEvent`
- `LiquidityChangeEvent`
- `Observation`
- `ObservationState`
- `OperationState`
- `PermissionlessFarmSwitch`
- `PersonalPositionState`
- `PoolCreatedEvent`
- `PoolState`
- `PositionRewardInfo`
- `ProtocolPositionState`
- `RewardInfo`
- `SupportMintAssociated`
- `SwapEvent`
- `TickArrayBitmapExtension`
- `TickArrayState`
- `TickState`
- `UpdateRewardInfosEvent`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list pancake-swap

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix pancake-swap <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account pancake-swap <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event pancake-swap <EventName>

# shared type fields
python3 "$CARBON" type pancake-swap <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path pancake-swap
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-pancake-swap-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
