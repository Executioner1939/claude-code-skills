---
name: carbon-meteora-damm-v2
description: "Carbon decoder reference for Meteora DAMM v2 on Solana — program `cpamdpZCGKUy5JxQXB4dcpGPiikHawvSWAd6mEn1sGG`, crate `carbon-meteora-damm-v2-decoder` (35 instructions, 9 account types, 23 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"Meteora DAMM V2\", \"meteora-damm-v2\", \"carbon-meteora-damm-v2-decoder\", \"cpamdpZCGKUy5JxQXB4dcpGPiikHawvSWAd6mEn1sGG\", \"MeteoraDammV2Decoder\", \"Meteora DAMM v2\", \"AddLiquidity\", \"ClaimPartnerFee\", \"ClaimPositionFee\", \"ClaimProtocolFee\", \"ClaimReward\", \"CloseConfig\", \"EvtClaimPartnerFeeEvent\", \"EvtClaimPositionFeeEvent\", \"EvtClaimProtocolFeeEvent\", \"EvtClaimRewardEvent\", \"Config\", \"Operator\", \"PodAlignedFeeMarketCapScheduler\", \"PodAlignedFeeRateLimiter\"."
---

# Meteora DAMM V2

- **Crate:** `carbon-meteora-damm-v2-decoder`
- **Program ID:** `cpamdpZCGKUy5JxQXB4dcpGPiikHawvSWAd6mEn1sGG`
- **Decoder struct:** `MeteoraDammV2Decoder`
- **Has CPI events:** yes (events/)

## Instructions

- `AddLiquidity`
- `ClaimPartnerFee`
- `ClaimPositionFee`
- `ClaimProtocolFee`
- `ClaimReward`
- `CloseConfig`
- `CloseOperatorAccount`
- `ClosePosition`
- `CloseTokenBadge`
- `CpiEvent`
- `CreateConfig`
- `CreateDynamicConfig`
- `CreateOperatorAccount`
- `CreatePosition`
- `CreateTokenBadge`
- `DummyIx`
- `FundReward`
- `InitializeCustomizablePool`
- `InitializePool`
- `InitializePoolWithDynamicConfig`
- `InitializeReward`
- `LockPosition`
- `PermanentLockPosition`
- `RefreshVesting`
- `RemoveAllLiquidity`
- `RemoveLiquidity`
- `SetPoolStatus`
- `SplitPosition`
- `SplitPosition2`
- `Swap`
- `Swap2`
- `UpdatePoolFees`
- `UpdateRewardDuration`
- `UpdateRewardFunder`
- `WithdrawIneligibleReward`

## Account types

- `Config`
- `Operator`
- `PodAlignedFeeMarketCapScheduler`
- `PodAlignedFeeRateLimiter`
- `PodAlignedFeeTimeScheduler`
- `Pool`
- `Position`
- `TokenBadge`
- `Vesting`

## CPI events

- `EvtClaimPartnerFeeEvent`
- `EvtClaimPositionFeeEvent`
- `EvtClaimProtocolFeeEvent`
- `EvtClaimRewardEvent`
- `EvtCloseConfigEvent`
- `EvtClosePositionEvent`
- `EvtCreateConfigEvent`
- `EvtCreateDynamicConfigEvent`
- `EvtCreatePositionEvent`
- `EvtCreateTokenBadgeEvent`
- `EvtFundRewardEvent`
- `EvtInitializePoolEvent`
- `EvtInitializeRewardEvent`
- `EvtLiquidityChangeEvent`
- `EvtLockPositionEvent`
- `EvtPermanentLockPositionEvent`
- `EvtSetPoolStatusEvent`
- `EvtSplitPosition2Event`
- `EvtSwap2Event`
- `EvtUpdatePoolFeesEvent`
- `EvtUpdateRewardDurationEvent`
- `EvtUpdateRewardFunderEvent`
- `EvtWithdrawIneligibleRewardEvent`

## Shared types

- `AddLiquidityParameters`
- `BaseFeeInfo`
- `BaseFeeParameters`
- `BaseFeeStruct`
- `BorshFeeMarketCapScheduler`
- `BorshFeeRateLimiter`
- `BorshFeeTimeScheduler`
- `DummyParams`
- `DynamicConfigParameters`
- `DynamicFeeConfig`
- `DynamicFeeParameters`
- `DynamicFeeStruct`
- `InitializeCustomizablePoolParameters`
- `InitializePoolParameters`
- `PoolFeeParameters`
- `PoolFeesConfig`
- `PoolFeesStruct`
- `PoolMetrics`
- `PositionMetrics`
- `RemoveLiquidityParameters`
- `RewardInfo`
- `SplitAmountInfo`
- `SplitPositionInfo`
- `SplitPositionParameters`
- `SplitPositionParameters2`
- `StaticConfigParameters`
- `SwapParameters`
- `SwapParameters2`
- `SwapResult2`
- `UpdatePoolFeesParameters`
- `UserRewardInfo`
- `VestingParameters`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list meteora-damm-v2

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix meteora-damm-v2 <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account meteora-damm-v2 <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event meteora-damm-v2 <EventName>

# shared type fields
python3 "$CARBON" type meteora-damm-v2 <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path meteora-damm-v2
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-meteora-damm-v2-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
