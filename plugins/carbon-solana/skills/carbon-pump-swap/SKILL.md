---
name: carbon-pump-swap
description: "Carbon decoder reference for Pumpswap (Pumpfun's AMM) on Solana — program `pAMMBay6oceH9fJKBRHGP5D4bD4sWpmSwMn52FMfXEA`, crate `carbon-pump-swap-decoder` (26 instructions, 7 account types, 22 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"Pump Swap\", \"pump-swap\", \"carbon-pump-swap-decoder\", \"pAMMBay6oceH9fJKBRHGP5D4bD4sWpmSwMn52FMfXEA\", \"PumpSwapDecoder\", \"Pumpswap (Pumpfun's AMM)\", \"AdminSetCoinCreator\", \"AdminUpdateTokenIncentives\", \"Buy\", \"BuyExactQuoteIn\", \"ClaimCashback\", \"ClaimTokenIncentives\", \"AdminSetCoinCreatorEventEvent\", \"AdminUpdateTokenIncentivesEventEvent\", \"BuyEventEvent\", \"ClaimCashbackEventEvent\", \"BondingCurve\", \"FeeConfig\", \"GlobalConfig\", \"GlobalVolumeAccumulator\"."
---

# Pump Swap

- **Crate:** `carbon-pump-swap-decoder`
- **Program ID:** `pAMMBay6oceH9fJKBRHGP5D4bD4sWpmSwMn52FMfXEA`
- **Decoder struct:** `PumpSwapDecoder`
- **Has CPI events:** yes (events/)

## Instructions

- `AdminSetCoinCreator`
- `AdminUpdateTokenIncentives`
- `Buy`
- `BuyExactQuoteIn`
- `ClaimCashback`
- `ClaimTokenIncentives`
- `CloseUserVolumeAccumulator`
- `CollectCoinCreatorFee`
- `CpiEvent`
- `CreateConfig`
- `CreatePool`
- `Deposit`
- `Disable`
- `ExtendAccount`
- `InitUserVolumeAccumulator`
- `MigratePoolCoinCreator`
- `Sell`
- `SetCoinCreator`
- `SetReservedFeeRecipients`
- `SyncUserVolumeAccumulator`
- `ToggleCashbackEnabled`
- `ToggleMayhemMode`
- `TransferCreatorFeesToPump`
- `UpdateAdmin`
- `UpdateFeeConfig`
- `Withdraw`

## Account types

- `BondingCurve`
- `FeeConfig`
- `GlobalConfig`
- `GlobalVolumeAccumulator`
- `Pool`
- `SharingConfig`
- `UserVolumeAccumulator`

## CPI events

- `AdminSetCoinCreatorEventEvent`
- `AdminUpdateTokenIncentivesEventEvent`
- `BuyEventEvent`
- `ClaimCashbackEventEvent`
- `ClaimTokenIncentivesEventEvent`
- `CloseUserVolumeAccumulatorEventEvent`
- `CollectCoinCreatorFeeEventEvent`
- `CreateConfigEventEvent`
- `CreatePoolEventEvent`
- `DepositEventEvent`
- `DisableEventEvent`
- `ExtendAccountEventEvent`
- `InitUserVolumeAccumulatorEventEvent`
- `MigratePoolCoinCreatorEventEvent`
- `ReservedFeeRecipientsEventEvent`
- `SellEventEvent`
- `SetBondingCurveCoinCreatorEventEvent`
- `SetMetaplexCoinCreatorEventEvent`
- `SyncUserVolumeAccumulatorEventEvent`
- `UpdateAdminEventEvent`
- `UpdateFeeConfigEventEvent`
- `WithdrawEventEvent`

## Shared types

- `AdminSetCoinCreatorEvent`
- `AdminUpdateTokenIncentivesEvent`
- `BuyEvent`
- `ClaimCashbackEvent`
- `ClaimTokenIncentivesEvent`
- `CloseUserVolumeAccumulatorEvent`
- `CollectCoinCreatorFeeEvent`
- `ConfigStatus`
- `CreateConfigEvent`
- `CreatePoolEvent`
- `DepositEvent`
- `DisableEvent`
- `ExtendAccountEvent`
- `FeeTier`
- `Fees`
- `InitUserVolumeAccumulatorEvent`
- `MigratePoolCoinCreatorEvent`
- `OptionBool`
- `ReservedFeeRecipientsEvent`
- `SellEvent`
- `SetBondingCurveCoinCreatorEvent`
- `SetMetaplexCoinCreatorEvent`
- `Shareholder`
- `SyncUserVolumeAccumulatorEvent`
- `UpdateAdminEvent`
- `UpdateFeeConfigEvent`
- `WithdrawEvent`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list pump-swap

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix pump-swap <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account pump-swap <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event pump-swap <EventName>

# shared type fields
python3 "$CARBON" type pump-swap <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path pump-swap
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-pump-swap-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
