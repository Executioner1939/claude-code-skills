---
name: carbon-moonshot
description: "Carbon decoder reference for Moonshot launchpad on Solana — program `MoonCVVNZFSYkqNXP6bxHLPL6QQJiMagDL3qcqUQTrG`, crate `carbon-moonshot-decoder` (8 instructions, 2 account types). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"Moonshot\", \"moonshot\", \"carbon-moonshot-decoder\", \"MoonCVVNZFSYkqNXP6bxHLPL6QQJiMagDL3qcqUQTrG\", \"MoonshotDecoder\", \"Moonshot launchpad\", \"Buy\", \"ConfigInit\", \"ConfigUpdate\", \"MigrateFunds\", \"MigrationEvent\", \"Sell\", \"ConfigAccount\", \"CurveAccount\"."
---

# Moonshot

- **Crate:** `carbon-moonshot-decoder`
- **Program ID:** `MoonCVVNZFSYkqNXP6bxHLPL6QQJiMagDL3qcqUQTrG`
- **Decoder struct:** `MoonshotDecoder`
- **Has CPI events:** yes (in instructions/)

## Instructions

- `Buy`
- `ConfigInit`
- `ConfigUpdate`
- `MigrateFunds`
- `MigrationEvent`
- `Sell`
- `TokenMint`
- `TradeEvent`

## Account types

- `ConfigAccount`
- `CurveAccount`

## Shared types

- `ConfigParams`
- `Currency`
- `CurveType`
- `FixedSide`
- `MigrationTarget`
- `TokenMintParams`
- `TradeParams`
- `TradeType`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list moonshot

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix moonshot <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account moonshot <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event moonshot <EventName>

# shared type fields
python3 "$CARBON" type moonshot <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path moonshot
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-moonshot-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
