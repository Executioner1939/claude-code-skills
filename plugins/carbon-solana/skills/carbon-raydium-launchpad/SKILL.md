---
name: carbon-raydium-launchpad
description: Carbon decoder reference for Raydium Launchpad on Solana — program `LanMV9sAd7wArD4vJFi2qDdfnVhFxYSUg6eADduJ3uj`, crate `carbon-raydium-launchpad-decoder` (22 instructions, 4 account types, 4 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "Raydium Launchpad", "raydium-launchpad", "carbon-raydium-launchpad-decoder", "LanMV9sAd7wArD4vJFi2qDdfnVhFxYSUg6eADduJ3uj", "RaydiumLaunchpadDecoder", "BuyExactIn", "BuyExactOut", "ClaimCreatorFee", "ClaimPlatformFee", "ClaimPlatformFeeFromVault", "ClaimVestedToken", "ClaimVestedEvent", "CreateVestingEvent", "PoolCreateEvent", "TradeEvent", "GlobalConfig", "PlatformConfig", "PoolState", "VestingRecord".
---

# Raydium Launchpad

- **Crate:** `carbon-raydium-launchpad-decoder`
- **Program ID:** `LanMV9sAd7wArD4vJFi2qDdfnVhFxYSUg6eADduJ3uj`
- **Decoder struct:** `RaydiumLaunchpadDecoder`
- **Has CPI events:** yes (in instructions/)

## Instructions

- `BuyExactIn`
- `BuyExactOut`
- `ClaimCreatorFee`
- `ClaimPlatformFee`
- `ClaimPlatformFeeFromVault`
- `ClaimVestedToken`
- `CollectFee`
- `CollectMigrateFee`
- `CreateConfig`
- `CreatePlatformConfig`
- `CreateVestingAccount`
- `Initialize`
- `InitializeV2`
- `InitializeWithToken2022`
- `MigrateToAmm`
- `MigrateToCpswap`
- `RemovePlatformCurveParam`
- `SellExactIn`
- `SellExactOut`
- `UpdateConfig`
- `UpdatePlatformConfig`
- `UpdatePlatformCurveParam`

## Account types

- `GlobalConfig`
- `PlatformConfig`
- `PoolState`
- `VestingRecord`

## CPI events

- `ClaimVestedEvent`
- `CreateVestingEvent`
- `PoolCreateEvent`
- `TradeEvent`

## Shared types

- `AmmCreatorFeeOn`
- `BondingCurveParam`
- `ClaimVestedEvent`
- `ConstantCurve`
- `CreateVestingEvent`
- `CurveParams`
- `FixedCurve`
- `GlobalConfig`
- `LinearCurve`
- `MigrateNftInfo`
- `MintParams`
- `PlatformConfig`
- `PlatformConfigInfo`
- `PlatformConfigParam`
- `PlatformCurveParam`
- `PlatformParams`
- `PoolCreateEvent`
- `PoolState`
- `PoolStatus`
- `TradeDirection`
- `TradeEvent`
- `TransferFeeExtensionParams`
- `VestingParams`
- `VestingRecord`
- `VestingSchedule`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list raydium-launchpad

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix raydium-launchpad <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account raydium-launchpad <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event raydium-launchpad <EventName>

# shared type fields
python3 "$CARBON" type raydium-launchpad <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path raydium-launchpad
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-raydium-launchpad-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
