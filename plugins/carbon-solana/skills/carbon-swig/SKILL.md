---
name: carbon-swig
description: Carbon decoder reference for Swig on Solana — program `swigypWHEksbC64pWKwah1WTeh9JXwx8H1rJHLdbQMB`, crate `carbon-swig-decoder` (13 instructions). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "Swig", "swig", "carbon-swig-decoder", "swigypWHEksbC64pWKwah1WTeh9JXwx8H1rJHLdbQMB", "SwigDecoder", "CreateV1", "AddAuthorityV1", "RemoveAuthorityV1", "UpdateAuthorityV1", "SignV1", "CreateSessionV1".
---

# Swig

- **Crate:** `carbon-swig-decoder`
- **Program ID:** `swigypWHEksbC64pWKwah1WTeh9JXwx8H1rJHLdbQMB`
- **Decoder struct:** `SwigDecoder`
- **Has CPI events:** no

## Instructions

- `CreateV1`
- `AddAuthorityV1`
- `RemoveAuthorityV1`
- `UpdateAuthorityV1`
- `SignV1`
- `CreateSessionV1`
- `CreateSubAccountV1`
- `WithdrawFromSubAccountV1`
- `SubAccountSignV1`
- `ToggleSubAccountV1`
- `SignV2`
- `MigrateToWalletAddressV1`
- `TransferAssetsV1`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list swig

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix swig <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account swig <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event swig <EventName>

# shared type fields
python3 "$CARBON" type swig <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path swig
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-swig-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
