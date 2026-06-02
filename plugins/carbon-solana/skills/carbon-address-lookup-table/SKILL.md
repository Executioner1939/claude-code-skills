---
name: carbon-address-lookup-table
description: "Carbon decoder reference for Address Lookup Table program on Solana — program `AddressLookupTab1e1111111111111111111111111`, crate `carbon-address-lookup-table-decoder` (5 instructions, 1 account types). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"Address Lookup Table\", \"address-lookup-table\", \"carbon-address-lookup-table-decoder\", \"AddressLookupTab1e1111111111111111111111111\", \"AddressLookupTableDecoder\", \"Address Lookup Table program\", \"CloseLookupTable\", \"CreateLookupTable\", \"DeactivateLookupTable\", \"ExtendLookupTable\", \"FreezeLookupTable\", \"AddressLookupTable\"."
---

# Address Lookup Table

- **Crate:** `carbon-address-lookup-table-decoder`
- **Program ID:** `AddressLookupTab1e1111111111111111111111111`
- **Decoder struct:** `AddressLookupTableDecoder`
- **Has CPI events:** no

## Instructions

- `CloseLookupTable`
- `CreateLookupTable`
- `DeactivateLookupTable`
- `ExtendLookupTable`
- `FreezeLookupTable`

## Account types

- `AddressLookupTable`

## Shared types

- `LookupTableAddresses`
- `LookupTableMeta`
- `ProgramState`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list address-lookup-table

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix address-lookup-table <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account address-lookup-table <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event address-lookup-table <EventName>

# shared type fields
python3 "$CARBON" type address-lookup-table <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path address-lookup-table
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-address-lookup-table-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
