---
name: carbon-meteora-dbc
description: Carbon decoder reference for Meteora DBC (dynamic bonding curve) on Solana — program `dbcij3LWUppWqq96dh6gJWwBifmcGfLSB5D4DuSMaqN`, crate `carbon-meteora-dbc-decoder` (47 instructions, 9 account types). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "Meteora Dynamic Bonding Curve (DBC)", "meteora-dbc", "carbon-meteora-dbc-decoder", "dbcij3LWUppWqq96dh6gJWwBifmcGfLSB5D4DuSMaqN", "DynamicBondingCurveDecoder", "Meteora DBC (dynamic bonding curve)", "ClaimCreatorTradingFee", "ClaimProtocolFee", "ClaimTradingFee", "CloseClaimFeeOperator", "CreateClaimFeeOperator", "CreateConfig", "ClaimFeeOperator", "Config", "LockEscrow", "MeteoraDammMigrationMetadata".
---

# Meteora Dynamic Bonding Curve (DBC)

- **Crate:** `carbon-meteora-dbc-decoder`
- **Program ID:** `dbcij3LWUppWqq96dh6gJWwBifmcGfLSB5D4DuSMaqN`
- **Decoder struct:** `DynamicBondingCurveDecoder`
- **Has CPI events:** yes (in instructions/)

## Instructions

- `ClaimCreatorTradingFee`
- `ClaimProtocolFee`
- `ClaimTradingFee`
- `CloseClaimFeeOperator`
- `CreateClaimFeeOperator`
- `CreateConfig`
- `CreateLocker`
- `CreatePartnerMetadata`
- `CreateVirtualPoolMetadata`
- `CreatorWithdrawSurplus`
- `EvtClaimCreatorTradingFeeEvent`
- `EvtClaimProtocolFeeEvent`
- `EvtClaimTradingFeeEvent`
- `EvtCloseClaimFeeOperatorEvent`
- `EvtCreateClaimFeeOperatorEvent`
- `EvtCreateConfigEvent`
- `EvtCreateConfigV2Event`
- `EvtCreateDammV2MigrationMetadataEvent`
- `EvtCreateMeteoraMigrationMetadataEvent`
- `EvtCreatorWithdrawSurplusEvent`
- `EvtCurveCompleteEvent`
- `EvtInitializePoolEvent`
- `EvtPartnerMetadataEvent`
- `EvtPartnerWithdrawMigrationFeeEvent`
- `EvtPartnerWithdrawSurplusEvent`
- `EvtProtocolWithdrawSurplusEvent`
- `EvtSwap2Event`
- `EvtSwapEvent`
- `EvtUpdatePoolCreatorEvent`
- `EvtVirtualPoolMetadataEvent`
- `EvtWithdrawLeftoverEvent`
- `EvtWithdrawMigrationFeeEvent`
- `InitializeVirtualPoolWithSplToken`
- `InitializeVirtualPoolWithToken2022`
- `MigrateMeteoraDamm`
- `MigrateMeteoraDammClaimLpToken`
- `MigrateMeteoraDammLockLpToken`
- `MigrationDammV2`
- `MigrationDammV2CreateMetadata`
- `MigrationMeteoraDammCreateMetadata`
- `PartnerWithdrawSurplus`
- `ProtocolWithdrawSurplus`
- `Swap`
- `Swap2`
- `TransferPoolCreator`
- `WithdrawLeftover`
- `WithdrawMigrationFee`

## Account types

- `ClaimFeeOperator`
- `Config`
- `LockEscrow`
- `MeteoraDammMigrationMetadata`
- `MeteoraDammV2Metadata`
- `PartnerMetadata`
- `PoolConfig`
- `VirtualPool`
- `VirtualPoolMetadata`

## Shared types

- `BaseFeeConfig`
- `BaseFeeParameters`
- `ConfigParameters`
- `CreatePartnerMetadataParameters`
- `CreateVirtualPoolMetadataParameters`
- `DynamicFeeConfig`
- `DynamicFeeParameters`
- `InitializePoolParameters`
- `LiquidityDistributionConfig`
- `LiquidityDistributionParameters`
- `LockedVestingConfig`
- `LockedVestingParams`
- `MigratedPoolFee`
- `MigrationFee`
- `PoolFeeParameters`
- `PoolFees`
- `PoolFeesConfig`
- `PoolMetrics`
- `SwapParameters`
- `SwapParameters2`
- `SwapResult`
- `SwapResult2`
- `TokenSupplyParams`
- `VolatilityTracker`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list meteora-dbc

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix meteora-dbc <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account meteora-dbc <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event meteora-dbc <EventName>

# shared type fields
python3 "$CARBON" type meteora-dbc <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path meteora-dbc
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-meteora-dbc-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
