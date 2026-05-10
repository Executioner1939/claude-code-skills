---
name: carbon-token-program
description: Carbon decoder reference for SPL Token program on Solana — program `TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA`, crate `carbon-token-program-decoder` (25 instructions, 3 account types). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "SPL Token Program", "token-program", "carbon-token-program-decoder", "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA", "TokenProgramDecoder", "SPL Token program", "InitializeMint", "InitializeAccount", "InitializeMultisig", "Transfer", "Approve", "Revoke", "Account", "Mint", "Multisig".
---

# SPL Token Program

- **Crate:** `carbon-token-program-decoder`
- **Program ID:** `TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA`
- **Decoder struct:** `TokenProgramDecoder`
- **Has CPI events:** no

## Instructions

- `InitializeMint`
- `InitializeAccount`
- `InitializeMultisig`
- `Transfer`
- `Approve`
- `Revoke`
- `SetAuthority`
- `MintTo`
- `Burn`
- `CloseAccount`
- `FreezeAccount`
- `ThawAccount`
- `TransferChecked`
- `ApproveChecked`
- `MintToChecked`
- `BurnChecked`
- `InitializeAccount2`
- `SyncNative`
- `InitializeAccount3`
- `InitializeMultisig2`
- `InitializeMint2`
- `GetAccountDataSize`
- `InitializeImmutableOwner`
- `AmountToUiAmount`
- `UiAmountToAmount`

## Account types

- `Account`
- `Mint`
- `Multisig`

## Shared types

- `AuthorityType`
- `AccountState`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list token-program

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix token-program <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account token-program <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event token-program <EventName>

# shared type fields
python3 "$CARBON" type token-program <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path token-program
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-token-program-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
