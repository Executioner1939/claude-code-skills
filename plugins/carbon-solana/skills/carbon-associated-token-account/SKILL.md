---
name: carbon-associated-token-account
description: "Carbon decoder reference for Associated Token Account program on Solana — program `ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL`, crate `carbon-associated-token-account-decoder` (3 instructions). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"SPL Associated Token Account\", \"associated-token-account\", \"carbon-associated-token-account-decoder\", \"ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL\", \"SplAssociatedTokenAccountDecoder\", \"Associated Token Account program\", \"Create\", \"CreateIdempotent\", \"RecoverNested\"."
---

# SPL Associated Token Account

- **Crate:** `carbon-associated-token-account-decoder`
- **Program ID:** `ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL`
- **Decoder struct:** `SplAssociatedTokenAccountDecoder`
- **Has CPI events:** no

## Instructions

- `Create`
- `CreateIdempotent`
- `RecoverNested`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list associated-token-account

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix associated-token-account <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account associated-token-account <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event associated-token-account <EventName>

# shared type fields
python3 "$CARBON" type associated-token-account <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path associated-token-account
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-associated-token-account-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
