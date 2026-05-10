---
name: carbon-marinade-finance
description: Carbon decoder reference for Marinade Finance (liquid staking) on Solana — program `MarBmsSgKXdrN1egZf5sqe1TMai9K1rChYNDJgjq7aD`, crate `carbon-marinade-finance-decoder` (53 instructions, 2 account types). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "Marinade Finance", "marinade-finance", "carbon-marinade-finance-decoder", "MarBmsSgKXdrN1egZf5sqe1TMai9K1rChYNDJgjq7aD", "MarinadeFinanceDecoder", "Marinade Finance (liquid staking)", "AddLiquidity", "AddLiquidityEvent", "AddValidator", "AddValidatorEvent", "ChangeAuthority", "ChangeAuthorityEvent", "State", "TicketAccountData".
---

# Marinade Finance

- **Crate:** `carbon-marinade-finance-decoder`
- **Program ID:** `MarBmsSgKXdrN1egZf5sqe1TMai9K1rChYNDJgjq7aD`
- **Decoder struct:** `MarinadeFinanceDecoder`
- **Has CPI events:** yes (in instructions/)

## Instructions

- `AddLiquidity`
- `AddLiquidityEvent`
- `AddValidator`
- `AddValidatorEvent`
- `ChangeAuthority`
- `ChangeAuthorityEvent`
- `Claim`
- `ClaimEvent`
- `ConfigLp`
- `ConfigLpEvent`
- `ConfigMarinade`
- `ConfigMarinadeEvent`
- `ConfigValidatorSystem`
- `DeactivateStake`
- `DeactivateStakeEvent`
- `Deposit`
- `DepositEvent`
- `DepositStakeAccount`
- `DepositStakeAccountEvent`
- `EmergencyPauseEvent`
- `EmergencyUnstake`
- `Initialize`
- `InitializeEvent`
- `LiquidUnstake`
- `LiquidUnstakeEvent`
- `MergeStakes`
- `MergeStakesEvent`
- `OrderUnstake`
- `OrderUnstakeEvent`
- `PartialUnstake`
- `Pause`
- `ReallocStakeList`
- `ReallocStakeListEvent`
- `ReallocValidatorList`
- `ReallocValidatorListEvent`
- `Redelegate`
- `RedelegateEvent`
- `RemoveLiquidity`
- `RemoveLiquidityEvent`
- `RemoveValidator`
- `RemoveValidatorEvent`
- `Resume`
- `ResumeEvent`
- `SetValidatorScore`
- `SetValidatorScoreEvent`
- `StakeReserve`
- `StakeReserveEvent`
- `UpdateActive`
- `UpdateActiveEvent`
- `UpdateDeactivated`
- `UpdateDeactivatedEvent`
- `WithdrawStakeAccount`
- `WithdrawStakeAccountEvent`

## Account types

- `State`
- `TicketAccountData`

## Shared types

- `BoolValueChange`
- `ChangeAuthorityData`
- `ConfigLpParams`
- `ConfigMarinadeParams`
- `Fee`
- `FeeCents`
- `FeeCentsValueChange`
- `FeeValueChange`
- `InitializeData`
- `LiqPool`
- `LiqPoolInitializeData`
- `List`
- `PubkeyValueChange`
- `SplitStakeAccountInfo`
- `StakeList`
- `StakeRecord`
- `StakeSystem`
- `U32ValueChange`
- `U64ValueChange`
- `ValidatorList`
- `ValidatorRecord`
- `ValidatorSystem`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list marinade-finance

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix marinade-finance <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account marinade-finance <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event marinade-finance <EventName>

# shared type fields
python3 "$CARBON" type marinade-finance <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path marinade-finance
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-marinade-finance-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
