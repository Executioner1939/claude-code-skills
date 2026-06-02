---
name: carbon-lifinity-amm-v2
description: "Carbon decoder reference for Lifinity AMM v2 on Solana — program `2wT8Yq49kHgDzXuPxZSaeLaH1qbmGXtEyPy64bL7aD3c`, crate `carbon-lifinity-amm-v2-decoder` (3 instructions, 1 account types). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"Lifinity AMM V2\", \"lifinity-amm-v2\", \"carbon-lifinity-amm-v2-decoder\", \"2wT8Yq49kHgDzXuPxZSaeLaH1qbmGXtEyPy64bL7aD3c\", \"LifinityAmmV2Decoder\", \"Lifinity AMM v2\", \"DepositAllTokenTypes\", \"Swap\", \"WithdrawAllTokenTypes\", \"Amm\"."
---

# Lifinity AMM V2

- **Crate:** `carbon-lifinity-amm-v2-decoder`
- **Program ID:** `2wT8Yq49kHgDzXuPxZSaeLaH1qbmGXtEyPy64bL7aD3c`
- **Decoder struct:** `LifinityAmmV2Decoder`
- **Has CPI events:** no

## Instructions

- `DepositAllTokenTypes`
- `Swap`
- `WithdrawAllTokenTypes`

## Account types

- `Amm`

## Shared types

- `AmmConfig`
- `AmmCurve`
- `AmmFees`
- `CurveType`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list lifinity-amm-v2

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix lifinity-amm-v2 <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account lifinity-amm-v2 <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event lifinity-amm-v2 <EventName>

# shared type fields
python3 "$CARBON" type lifinity-amm-v2 <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path lifinity-amm-v2
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-lifinity-amm-v2-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
