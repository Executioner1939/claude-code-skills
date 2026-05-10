---
name: carbon-memo-program
description: Carbon decoder reference for SPL Memo program on Solana — program `spl_memo_interface::v3::ID`, crate `carbon-memo-program-decoder` (1 instructions). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "Memo Program", "memo-program", "carbon-memo-program-decoder", "spl_memo_interface::v3::ID", "MemoProgramDecoder", "SPL Memo program", "Memo".
---

# Memo Program

- **Crate:** `carbon-memo-program-decoder`
- **Program ID:** `spl_memo_interface::v3::ID`
- **Decoder struct:** `MemoProgramDecoder`
- **Has CPI events:** no

## Instructions

- `Memo`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list memo-program

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix memo-program <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account memo-program <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event memo-program <EventName>

# shared type fields
python3 "$CARBON" type memo-program <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path memo-program
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-memo-program-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
