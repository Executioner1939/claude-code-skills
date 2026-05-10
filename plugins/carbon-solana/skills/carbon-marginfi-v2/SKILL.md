---
name: carbon-marginfi-v2
description: Carbon decoder reference for Marginfi v2 (lending) on Solana — program `MFv2hWf31Z9kbCa1snEPYctwafyhdvnV7FZnsebVacA`, crate `carbon-marginfi-v2-decoder` (24 instructions, 3 account types, 14 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "Marginfi V2", "marginfi-v2", "carbon-marginfi-v2-decoder", "MFv2hWf31Z9kbCa1snEPYctwafyhdvnV7FZnsebVacA", "MarginfiV2Decoder", "Marginfi v2 (lending)", "LendingAccountBorrow", "LendingAccountCloseBalance", "LendingAccountDeposit", "LendingAccountEndFlashloan", "LendingAccountLiquidate", "LendingAccountRepay", "LendingAccountBorrowEvent", "LendingAccountDepositEvent", "LendingAccountLiquidateEvent", "LendingAccountRepayEvent", "Bank", "MarginfiAccount", "MarginfiGroup".
---

# Marginfi V2

- **Crate:** `carbon-marginfi-v2-decoder`
- **Program ID:** `MFv2hWf31Z9kbCa1snEPYctwafyhdvnV7FZnsebVacA`
- **Decoder struct:** `MarginfiV2Decoder`
- **Has CPI events:** yes (in instructions/)

## Instructions

- `LendingAccountBorrow`
- `LendingAccountCloseBalance`
- `LendingAccountDeposit`
- `LendingAccountEndFlashloan`
- `LendingAccountLiquidate`
- `LendingAccountRepay`
- `LendingAccountSettleEmissions`
- `LendingAccountStartFlashloan`
- `LendingAccountWithdraw`
- `LendingAccountWithdrawEmissions`
- `LendingPoolAccrueBankInterest`
- `LendingPoolAddBank`
- `LendingPoolAddBankWithSeed`
- `LendingPoolCollectBankFees`
- `LendingPoolConfigureBank`
- `LendingPoolHandleBankruptcy`
- `LendingPoolSetupEmissions`
- `LendingPoolUpdateEmissionsParameters`
- `MarginfiAccountInitialize`
- `MarginfiGroupConfigure`
- `MarginfiGroupInitialize`
- `SetAccountFlag`
- `SetNewAccountAuthority`
- `UnsetAccountFlag`

## Account types

- `Bank`
- `MarginfiAccount`
- `MarginfiGroup`

## CPI events

- `LendingAccountBorrowEvent`
- `LendingAccountDepositEvent`
- `LendingAccountLiquidateEvent`
- `LendingAccountRepayEvent`
- `LendingAccountWithdrawEvent`
- `LendingPoolBankAccrueInterestEvent`
- `LendingPoolBankCollectFeesEvent`
- `LendingPoolBankConfigureEvent`
- `LendingPoolBankCreateEvent`
- `LendingPoolBankHandleBankruptcyEvent`
- `MarginfiAccountCreateEvent`
- `MarginfiAccountTransferAccountAuthorityEvent`
- `MarginfiGroupConfigureEvent`
- `MarginfiGroupCreateEvent`

## Shared types

- `AccountEventHeader`
- `Balance`
- `BalanceDecreaseType`
- `BalanceIncreaseType`
- `BalanceSide`
- `BankConfig`
- `BankConfigCompact`
- `BankConfigOpt`
- `BankOperationalState`
- `BankVaultType`
- `GroupConfig`
- `GroupEventHeader`
- `InterestRateConfig`
- `InterestRateConfigCompact`
- `InterestRateConfigOpt`
- `LendingAccount`
- `LiquidationBalances`
- `OracleConfig`
- `OraclePriceType`
- `OracleSetup`
- `PriceBias`
- `RequirementType`
- `RiskRequirementType`
- `RiskTier`
- `WrappedI80F48`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list marginfi-v2

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix marginfi-v2 <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account marginfi-v2 <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event marginfi-v2 <EventName>

# shared type fields
python3 "$CARBON" type marginfi-v2 <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path marginfi-v2
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-marginfi-v2-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
