---
name: carbon-system-program
description: "Carbon decoder reference for Solana System Program on Solana — program `11111111111111111111111111111111`, crate `carbon-system-program-decoder` (13 instructions, 2 account types). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"System Program\", \"system-program\", \"carbon-system-program-decoder\", \"11111111111111111111111111111111\", \"SystemProgramDecoder\", \"Solana System Program\", \"CreateAccount\", \"Assign\", \"TransferSol\", \"CreateAccountWithSeed\", \"AdvanceNonceAccount\", \"WithdrawNonceAccount\", \"Nonce\", \"Legacy\"."
---

# System Program

- **Crate:** `carbon-system-program-decoder`
- **Program ID:** `11111111111111111111111111111111`
- **Decoder struct:** `SystemProgramDecoder`
- **Has CPI events:** no

## Instructions

- `CreateAccount`
- `Assign`
- `TransferSol`
- `CreateAccountWithSeed`
- `AdvanceNonceAccount`
- `WithdrawNonceAccount`
- `InitializeNonceAccount`
- `AuthorizeNonceAccount`
- `Allocate`
- `AllocateWithSeed`
- `AssignWithSeed`
- `TransferSolWithSeed`
- `UpgradeNonceAccount`

## Account types

- `Nonce`
- `Legacy`

## Shared types

- `NonceVersion`
- `NonceState`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list system-program

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix system-program <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account system-program <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event system-program <EventName>

# shared type fields
python3 "$CARBON" type system-program <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path system-program
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-system-program-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
