---
name: carbon-solayer-restaking-program
description: Carbon decoder reference for Solayer Restaking on Solana — program `sSo1iU21jBrU9VaJ8PJib1MtorefUV4fzC9GURa2KNn`, crate `carbon-solayer-restaking-program-decoder` (4 instructions, 1 account types). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "Solayer Restaking Program", "solayer-restaking-program", "carbon-solayer-restaking-program-decoder", "sSo1iU21jBrU9VaJ8PJib1MtorefUV4fzC9GURa2KNn", "SolayerRestakingProgramDecoder", "Solayer Restaking", "BatchThawLstAccounts", "Initialize", "Restake", "Unrestake", "RestakingPool".
---

# Solayer Restaking Program

- **Crate:** `carbon-solayer-restaking-program-decoder`
- **Program ID:** `sSo1iU21jBrU9VaJ8PJib1MtorefUV4fzC9GURa2KNn`
- **Decoder struct:** `SolayerRestakingProgramDecoder`
- **Has CPI events:** no

## Instructions

- `BatchThawLstAccounts`
- `Initialize`
- `Restake`
- `Unrestake`

## Account types

- `RestakingPool`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list solayer-restaking-program

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix solayer-restaking-program <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account solayer-restaking-program <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event solayer-restaking-program <EventName>

# shared type fields
python3 "$CARBON" type solayer-restaking-program <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path solayer-restaking-program
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-solayer-restaking-program-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
