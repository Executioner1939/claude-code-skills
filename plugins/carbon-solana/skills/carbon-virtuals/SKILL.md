---
name: carbon-virtuals
description: Carbon decoder reference for Virtuals on Solana — program `5U3EU2ubXtK84QcRjWVmYt9RaDyA8gKxdUrPFXmZyaki`, crate `carbon-virtuals-decoder` (8 instructions, 1 account types, 4 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "Virtuals", "virtuals", "carbon-virtuals-decoder", "5U3EU2ubXtK84QcRjWVmYt9RaDyA8gKxdUrPFXmZyaki", "VirtualsDecoder", "Initialize", "Launch", "Buy", "Sell", "InitializeMeteoraAccounts", "CreateMeteoraPool", "BuyEvent", "SellEvent", "LaunchEvent", "GraduationEvent", "VirtualsPool".
---

# Virtuals

- **Crate:** `carbon-virtuals-decoder`
- **Program ID:** `5U3EU2ubXtK84QcRjWVmYt9RaDyA8gKxdUrPFXmZyaki`
- **Decoder struct:** `VirtualsDecoder`
- **Has CPI events:** yes (in instructions/, *_event.rs)

## Instructions

- `Initialize`
- `Launch`
- `Buy`
- `Sell`
- `InitializeMeteoraAccounts`
- `CreateMeteoraPool`
- `ClaimFees`
- `UpdatePoolCreator`

## Account types

- `VirtualsPool`

## CPI events

- `BuyEvent`
- `SellEvent`
- `LaunchEvent`
- `GraduationEvent`

## Shared types

- `PoolState`
- `BuyEvent`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list virtuals

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix virtuals <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account virtuals <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event virtuals <EventName>

# shared type fields
python3 "$CARBON" type virtuals <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path virtuals
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-virtuals-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
