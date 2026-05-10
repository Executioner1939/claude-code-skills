---
name: carbon-orca-whirlpool
description: Carbon decoder reference for Orca Whirlpool (concentrated liquidity) on Solana — program `whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc`, crate `carbon-orca-whirlpool-decoder` (58 instructions, 12 account types, 4 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "Orca Whirlpool", "orca-whirlpool", "carbon-orca-whirlpool-decoder", "whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc", "OrcaWhirlpoolDecoder", "Orca Whirlpool (concentrated liquidity)", "InitializeConfig", "InitializePool", "InitializePoolV2", "InitializePoolWithAdaptiveFee", "InitializeTickArray", "InitializeFeeTier", "LiquidityDecreasedEvent", "LiquidityIncreasedEvent", "PoolInitializedEvent", "TradedEvent", "AdaptiveFeeTier", "DynamicTickArray", "FeeTier", "FixedTickArray".
---

# Orca Whirlpool

- **Crate:** `carbon-orca-whirlpool-decoder`
- **Program ID:** `whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc`
- **Decoder struct:** `OrcaWhirlpoolDecoder`
- **Has CPI events:** yes (in instructions/ as `*_event.rs`)

## Instructions

- `InitializeConfig`
- `InitializePool`
- `InitializePoolV2`
- `InitializePoolWithAdaptiveFee`
- `InitializeTickArray`
- `InitializeFeeTier`
- `InitializeAdaptiveFeeTier`
- `InitializeReward`
- `InitializeRewardV2`
- `InitializeConfigExtension`
- `InitializeTokenBadge`
- `DeleteTokenBadge`
- `OpenPosition`
- `OpenPositionWithMetadata`
- `OpenPositionWithTokenExtensions`
- `OpenBundledPosition`
- `InitializePositionBundle`
- `InitializePositionBundleWithMetadata`
- `IncreaseLiquidity`
- `IncreaseLiquidityV2`
- `DecreaseLiquidity`
- `DecreaseLiquidityV2`
- `UpdateFeesAndRewards`
- `CollectFees`
- `CollectFeesV2`
- `CollectProtocolFees`
- `CollectProtocolFeesV2`
- `CollectReward`
- `CollectRewardV2`
- `ClosePosition`
- `ClosePositionWithTokenExtensions`
- `CloseBundledPosition`
- `DeletePositionBundle`
- `LockPosition`
- `TransferLockedPosition`
- `ResetPositionRange`
- `Swap`
- `SwapV2`
- `TwoHopSwap`
- `TwoHopSwapV2`
- `SetCollectProtocolFeesAuthority`
- `SetConfigExtensionAuthority`
- `SetDefaultBaseFeeRate`
- `SetDefaultFeeRate`
- `SetDefaultProtocolFeeRate`
- `SetDelegatedFeeAuthority`
- `SetFeeAuthority`
- `SetFeeRate`
- `SetFeeRateByDelegatedFeeAuthority`
- `SetInitializePoolAuthority`
- `SetPresetAdaptiveFeeConstants`
- `SetProtocolFeeRate`
- `SetRewardAuthority`
- `SetRewardAuthorityBySuperAuthority`
- `SetRewardEmissions`
- `SetRewardEmissionsV2`
- `SetRewardEmissionsSuperAuthority`
- `SetTokenBadgeAuthority`

## Account types

- `AdaptiveFeeTier`
- `DynamicTickArray`
- `FeeTier`
- `FixedTickArray`
- `LockConfig`
- `Oracle`
- `Position`
- `PositionBundle`
- `TokenBadge`
- `Whirlpool`
- `WhirlpoolsConfig`
- `WhirlpoolsConfigExtension`

## CPI events

- `LiquidityDecreasedEvent`
- `LiquidityIncreasedEvent`
- `PoolInitializedEvent`
- `TradedEvent`

## Shared types

- `Tick`
- `DynamicTick`
- `PositionRewardInfo`
- `WhirlpoolRewardInfo`
- `AdaptiveFeeConstants`
- `AdaptiveFeeVariables`
- `WhirlpoolBumps`
- `OpenPositionBumps`
- `OpenPositionWithMetadataBumps`
- `RemainingAccountsInfo`
- `RemainingAccountsSlice`
- `AccountsType`
- `LockType`
- `LockTypeLabel`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list orca-whirlpool

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix orca-whirlpool <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account orca-whirlpool <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event orca-whirlpool <EventName>

# shared type fields
python3 "$CARBON" type orca-whirlpool <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path orca-whirlpool
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-orca-whirlpool-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
