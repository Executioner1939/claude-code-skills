---
name: carbon-meteora-dlmm
description: "Carbon decoder reference for Meteora DLMM (dynamic liquidity market maker) on Solana — program `LBUZKhRxPF3XUpBCjp4YzTKgLccjZhTSDM9YuVaPwxo`, crate `carbon-meteora-dlmm-decoder` (88 instructions, 10 account types). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"Meteora DLMM\", \"meteora-dlmm\", \"carbon-meteora-dlmm-decoder\", \"LBUZKhRxPF3XUpBCjp4YzTKgLccjZhTSDM9YuVaPwxo\", \"MeteoraDlmmDecoder\", \"Meteora DLMM (dynamic liquidity market maker)\", \"AddLiquidity\", \"AddLiquidity2\", \"AddLiquidityByStrategy\", \"AddLiquidityByStrategy2\", \"AddLiquidityByStrategyOneSide\", \"AddLiquidityByWeight\", \"BinArray\", \"BinArrayBitmapExtension\", \"ClaimFeeOperator\", \"LbPair\"."
---

# Meteora DLMM

- **Crate:** `carbon-meteora-dlmm-decoder`
- **Program ID:** `LBUZKhRxPF3XUpBCjp4YzTKgLccjZhTSDM9YuVaPwxo`
- **Decoder struct:** `MeteoraDlmmDecoder`
- **Has CPI events:** yes (in instructions/)

## Instructions

- `AddLiquidity`
- `AddLiquidity2`
- `AddLiquidityByStrategy`
- `AddLiquidityByStrategy2`
- `AddLiquidityByStrategyOneSide`
- `AddLiquidityByWeight`
- `AddLiquidityEvent`
- `AddLiquidityOneSide`
- `AddLiquidityOneSidePrecise`
- `AddLiquidityOneSidePrecise2`
- `ClaimFee`
- `ClaimFee2`
- `ClaimFeeEvent`
- `ClaimReward`
- `ClaimReward2`
- `ClaimRewardEvent`
- `CloseClaimProtocolFeeOperator`
- `ClosePosition`
- `ClosePosition2`
- `ClosePositionIfEmpty`
- `ClosePresetParameter`
- `ClosePresetParameter2`
- `CompositionFeeEvent`
- `CreateClaimProtocolFeeOperator`
- `DecreasePositionLengthEvent`
- `DynamicFeeParameterUpdateEvent`
- `FeeParameterUpdateEvent`
- `FundReward`
- `FundRewardEvent`
- `GoToABin`
- `GoToABinEvent`
- `IncreaseObservationEvent`
- `IncreaseOracleLength`
- `IncreasePositionLengthEvent`
- `InitializeBinArray`
- `InitializeBinArrayBitmapExtension`
- `InitializeCustomizablePermissionlessLbPair`
- `InitializeCustomizablePermissionlessLbPair2`
- `InitializeLbPair`
- `InitializeLbPair2`
- `InitializePermissionLbPair`
- `InitializePosition`
- `InitializePositionByOperator`
- `InitializePositionPda`
- `InitializePresetParameter`
- `InitializePresetParameter2`
- `InitializeReward`
- `InitializeRewardEvent`
- `InitializeTokenBadge`
- `LbPairCreateEvent`
- `MigrateBinArray`
- `MigratePosition`
- `PositionCloseEvent`
- `PositionCreateEvent`
- `RemoveAllLiquidity`
- `RemoveLiquidity`
- `RemoveLiquidity2`
- `RemoveLiquidityByRange`
- `RemoveLiquidityByRange2`
- `RemoveLiquidityEvent`
- `SetActivationPoint`
- `SetPairStatus`
- `SetPairStatusPermissionless`
- `SetPreActivationDuration`
- `SetPreActivationSwapAddress`
- `Swap`
- `Swap2`
- `SwapEvent`
- `SwapExactOut`
- `SwapExactOut2`
- `SwapWithPriceImpact`
- `SwapWithPriceImpact2`
- `TogglePairStatus`
- `UpdateBaseFeeParameters`
- `UpdateDynamicFeeParameters`
- `UpdateFeeParameters`
- `UpdateFeesAndReward2`
- `UpdateFeesAndRewards`
- `UpdatePositionLockReleasePointEvent`
- `UpdatePositionOperator`
- `UpdatePositionOperatorEvent`
- `UpdateRewardDuration`
- `UpdateRewardDurationEvent`
- `UpdateRewardFunder`
- `UpdateRewardFunderEvent`
- `WithdrawIneligibleReward`
- `WithdrawIneligibleRewardEvent`
- `WithdrawProtocolFee`

## Account types

- `BinArray`
- `BinArrayBitmapExtension`
- `ClaimFeeOperator`
- `LbPair`
- `Oracle`
- `Position`
- `PositionV2`
- `PresetParameter`
- `PresetParameter2`
- `TokenBadge`

## Shared types

- `AccountsType`
- `ActivationType`
- `AddLiquiditySingleSidePreciseParameter`
- `AddLiquiditySingleSidePreciseParameter2`
- `BaseFeeParameter`
- `Bin`
- `BinLiquidityDistribution`
- `BinLiquidityDistributionByWeight`
- `BinLiquidityReduction`
- `CompressedBinDepositAmount`
- `CompressedBinDepositAmount2`
- `CustomizableParams`
- `DynamicFeeParameter`
- `FeeInfo`
- `FeeParameter`
- `InitPermissionPairIx`
- `InitPresetParameters2Ix`
- `InitPresetParametersIx`
- `InitializeLbPair2Params`
- `LayoutVersion`
- `LiquidityOneSideParameter`
- `LiquidityParameter`
- `LiquidityParameterByStrategy`
- `LiquidityParameterByStrategyOneSide`
- `LiquidityParameterByWeight`
- `Observation`
- `PairStatus`
- `PairType`
- `ProtocolFee`
- `RemainingAccountsInfo`
- `RemainingAccountsSlice`
- `RewardInfo`
- `Rounding`
- `StaticParameters`
- `StrategyParameters`
- `StrategyType`
- `TokenProgramFlags`
- `UserRewardInfo`
- `VariableParameters`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list meteora-dlmm

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix meteora-dlmm <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account meteora-dlmm <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event meteora-dlmm <EventName>

# shared type fields
python3 "$CARBON" type meteora-dlmm <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path meteora-dlmm
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-meteora-dlmm-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
