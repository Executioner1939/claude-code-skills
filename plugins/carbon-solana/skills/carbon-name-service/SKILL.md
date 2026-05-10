---
name: carbon-name-service
description: Carbon decoder reference for SNS Name Service on Solana — program `namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX`, crate `carbon-name-service-decoder` (5 instructions, 1 account types). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "SPL Name Service", "name-service", "carbon-name-service-decoder", "namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX", "NameDecoder", "SNS Name Service", "Create", "Update", "Transfer", "Delete", "Realloc", "NameRecordHeader".
---

# SPL Name Service

- **Crate:** `carbon-name-service-decoder`
- **Program ID:** `namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX`
- **Decoder struct:** `NameDecoder`
- **Has CPI events:** no

## Instructions

- `Create`
- `Update`
- `Transfer`
- `Delete`
- `Realloc`

## Account types

- `NameRecordHeader`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list name-service

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix name-service <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account name-service <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event name-service <EventName>

# shared type fields
python3 "$CARBON" type name-service <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path name-service
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-name-service-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
