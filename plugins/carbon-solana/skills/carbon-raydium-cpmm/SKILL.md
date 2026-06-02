---
name: carbon-raydium-cpmm
description: "Carbon decoder reference for Raydium CPMM (constant product v3) on Solana — program `CPMMoo8L3F4NbTegBCKVNunggL7H1ZpdTHKxQB5qKP1C`, crate `carbon-raydium-cpmm-decoder` (14 instructions, 4 account types, 2 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"Raydium CPMM\", \"raydium-cpmm\", \"carbon-raydium-cpmm-decoder\", \"CPMMoo8L3F4NbTegBCKVNunggL7H1ZpdTHKxQB5qKP1C\", \"RaydiumCpmmDecoder\", \"Raydium CPMM (constant product v3)\", \"ClosePermissionPda\", \"CollectCreatorFee\", \"CollectFundFee\", \"CollectProtocolFee\", \"CreateAmmConfig\", \"CreatePermissionPda\", \"LpChangeEvent\", \"SwapEvent\", \"AmmConfig\", \"ObservationState\", \"Permission\", \"PoolState\"."
---

# Raydium CPMM

- **Crate:** `carbon-raydium-cpmm-decoder`
- **Program ID:** `CPMMoo8L3F4NbTegBCKVNunggL7H1ZpdTHKxQB5qKP1C`
- **Decoder struct:** `RaydiumCpmmDecoder`
- **Has CPI events:** yes (in instructions/)

## Instructions

- `ClosePermissionPda`
- `CollectCreatorFee`
- `CollectFundFee`
- `CollectProtocolFee`
- `CreateAmmConfig`
- `CreatePermissionPda`
- `Deposit`
- `Initialize`
- `InitializeWithPermission`
- `SwapBaseInput`
- `SwapBaseOutput`
- `UpdateAmmConfig`
- `UpdatePoolStatus`
- `Withdraw`

## Account types

- `AmmConfig`
- `ObservationState`
- `Permission`
- `PoolState`

## CPI events

- `LpChangeEvent`
- `SwapEvent`

## Shared types

- `AmmConfig`
- `CreatorFeeOn`
- `Observation`
- `ObservationState`
- `Permission`
- `PoolState`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list raydium-cpmm

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix raydium-cpmm <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account raydium-cpmm <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event raydium-cpmm <EventName>

# shared type fields
python3 "$CARBON" type raydium-cpmm <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path raydium-cpmm
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-raydium-cpmm-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
