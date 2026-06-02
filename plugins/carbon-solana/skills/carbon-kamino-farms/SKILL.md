---
name: carbon-kamino-farms
description: "Carbon decoder reference for Kamino Farms on Solana — program `FarmsPZpWu9i7Kky8tPN37rs2TpmMrAZrC7S7vJa91Hr`, crate `carbon-kamino-farms-decoder` (25 instructions, 4 account types). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"Kamino Farms\", \"kamino-farms\", \"carbon-kamino-farms-decoder\", \"FarmsPZpWu9i7Kky8tPN37rs2TpmMrAZrC7S7vJa91Hr\", \"KaminoFarmsDecoder\", \"AddRewards\", \"DepositToFarmVault\", \"HarvestReward\", \"IdlMissingTypes\", \"InitializeFarm\", \"InitializeFarmDelegated\", \"FarmState\", \"GlobalConfig\", \"OraclePrices\", \"UserState\"."
---

# Kamino Farms

- **Crate:** `carbon-kamino-farms-decoder`
- **Program ID:** `FarmsPZpWu9i7Kky8tPN37rs2TpmMrAZrC7S7vJa91Hr`
- **Decoder struct:** `KaminoFarmsDecoder`
- **Has CPI events:** no

## Instructions

- `AddRewards`
- `DepositToFarmVault`
- `HarvestReward`
- `IdlMissingTypes`
- `InitializeFarm`
- `InitializeFarmDelegated`
- `InitializeGlobalConfig`
- `InitializeReward`
- `InitializeUser`
- `RefreshFarm`
- `RefreshUserState`
- `RewardUserOnce`
- `SetStakeDelegated`
- `Stake`
- `TransferOwnership`
- `Unstake`
- `UpdateFarmAdmin`
- `UpdateFarmConfig`
- `UpdateGlobalConfig`
- `UpdateGlobalConfigAdmin`
- `WithdrawFromFarmVault`
- `WithdrawReward`
- `WithdrawSlashedAmount`
- `WithdrawTreasury`
- `WithdrawUnstakedDeposits`

## Account types

- `FarmState`
- `GlobalConfig`
- `OraclePrices`
- `UserState`

## Shared types

- `DatedPrice`
- `FarmConfigOption`
- `GlobalConfigOption`
- `LockingMode`
- `Price`
- `RewardInfo`
- `RewardPerTimeUnitPoint`
- `RewardScheduleCurve`
- `RewardType`
- `TimeUnit`
- `TokenInfo`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list kamino-farms

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix kamino-farms <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account kamino-farms <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event kamino-farms <EventName>

# shared type fields
python3 "$CARBON" type kamino-farms <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path kamino-farms
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-kamino-farms-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
