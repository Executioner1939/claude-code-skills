---
name: carbon-pumpfun
description: "Carbon decoder reference for Pumpfun token launchpad / bonding curve on Solana — program `6EF8rrecthR5Dkzon8Nwu78hRvfCKubJ14M5uBEwF6P`, crate `carbon-pumpfun-decoder` (30 instructions, 6 account types, 23 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"Pumpfun\", \"pumpfun\", \"carbon-pumpfun-decoder\", \"6EF8rrecthR5Dkzon8Nwu78hRvfCKubJ14M5uBEwF6P\", \"PumpfunDecoder\", \"Pumpfun token launchpad / bonding curve\", \"AdminSetCreator\", \"AdminSetIdlAuthority\", \"AdminUpdateTokenIncentives\", \"Buy\", \"BuyExactSolIn\", \"ClaimCashback\", \"AdminSetCreatorEventEvent\", \"AdminSetIdlAuthorityEventEvent\", \"AdminUpdateTokenIncentivesEventEvent\", \"ClaimCashbackEventEvent\", \"BondingCurve\", \"FeeConfig\", \"Global\", \"GlobalVolumeAccumulator\"."
---

# Pumpfun

- **Crate:** `carbon-pumpfun-decoder`
- **Program ID:** `6EF8rrecthR5Dkzon8Nwu78hRvfCKubJ14M5uBEwF6P`
- **Decoder struct:** `PumpfunDecoder`
- **Has CPI events:** yes (events/)

## Instructions

- `AdminSetCreator`
- `AdminSetIdlAuthority`
- `AdminUpdateTokenIncentives`
- `Buy`
- `BuyExactSolIn`
- `ClaimCashback`
- `ClaimTokenIncentives`
- `CloseUserVolumeAccumulator`
- `CollectCreatorFee`
- `CpiEvent`
- `Create`
- `CreateV2`
- `DistributeCreatorFees`
- `ExtendAccount`
- `GetMinimumDistributableFee`
- `InitUserVolumeAccumulator`
- `Initialize`
- `Migrate`
- `MigrateBondingCurveCreator`
- `Sell`
- `SetCreator`
- `SetMayhemVirtualParams`
- `SetMetaplexCreator`
- `SetParams`
- `SetReservedFeeRecipients`
- `SyncUserVolumeAccumulator`
- `ToggleCashbackEnabled`
- `ToggleCreateV2`
- `ToggleMayhemMode`
- `UpdateGlobalAuthority`

## Account types

- `BondingCurve`
- `FeeConfig`
- `Global`
- `GlobalVolumeAccumulator`
- `SharingConfig`
- `UserVolumeAccumulator`

## CPI events

- `AdminSetCreatorEventEvent`
- `AdminSetIdlAuthorityEventEvent`
- `AdminUpdateTokenIncentivesEventEvent`
- `ClaimCashbackEventEvent`
- `ClaimTokenIncentivesEventEvent`
- `CloseUserVolumeAccumulatorEventEvent`
- `CollectCreatorFeeEventEvent`
- `CompleteEventEvent`
- `CompletePumpAmmMigrationEventEvent`
- `CreateEventEvent`
- `DistributeCreatorFeesEventEvent`
- `ExtendAccountEventEvent`
- `InitUserVolumeAccumulatorEventEvent`
- `MigrateBondingCurveCreatorEventEvent`
- `MinimumDistributableFeeEventEvent`
- `ReservedFeeRecipientsEventEvent`
- `SetCreatorEventEvent`
- `SetMetaplexCreatorEventEvent`
- `SetParamsEventEvent`
- `SyncUserVolumeAccumulatorEventEvent`
- `TradeEventEvent`
- `UpdateGlobalAuthorityEventEvent`
- `UpdateMayhemVirtualParamsEventEvent`

## Shared types

- `AdminSetCreatorEvent`
- `AdminSetIdlAuthorityEvent`
- `AdminUpdateTokenIncentivesEvent`
- `ClaimCashbackEvent`
- `ClaimTokenIncentivesEvent`
- `CloseUserVolumeAccumulatorEvent`
- `CollectCreatorFeeEvent`
- `CompleteEvent`
- `CompletePumpAmmMigrationEvent`
- `ConfigStatus`
- `CreateEvent`
- `DistributeCreatorFeesEvent`
- `ExtendAccountEvent`
- `FeeTier`
- `Fees`
- `InitUserVolumeAccumulatorEvent`
- `MigrateBondingCurveCreatorEvent`
- `MinimumDistributableFeeEvent`
- `OptionBool`
- `ReservedFeeRecipientsEvent`
- `SetCreatorEvent`
- `SetMetaplexCreatorEvent`
- `SetParamsEvent`
- `Shareholder`
- `SyncUserVolumeAccumulatorEvent`
- `TradeEvent`
- `UpdateGlobalAuthorityEvent`
- `UpdateMayhemVirtualParamsEvent`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list pumpfun

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix pumpfun <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account pumpfun <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event pumpfun <EventName>

# shared type fields
python3 "$CARBON" type pumpfun <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path pumpfun
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-pumpfun-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
