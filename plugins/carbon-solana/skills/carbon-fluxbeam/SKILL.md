---
name: carbon-fluxbeam
description: "Carbon decoder reference for Fluxbeam on Solana — program `FLUXubRmkEi2q6K3Y9kBPg9248ggaZVsoSFhtJHSrm1X`, crate `carbon-fluxbeam-decoder` (6 instructions, 1 account types). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"Fluxbeam\", \"fluxbeam\", \"carbon-fluxbeam-decoder\", \"FLUXubRmkEi2q6K3Y9kBPg9248ggaZVsoSFhtJHSrm1X\", \"FluxbeamDecoder\", \"DepositAllTokenTypes\", \"DepositSingleTokenTypeExactAmountIn\", \"Initialize\", \"Swap\", \"WithdrawAllTokenTypes\", \"WithdrawSingleTokenTypeExactAmountOut\", \"SwapV1\"."
---

# Fluxbeam

- **Crate:** `carbon-fluxbeam-decoder`
- **Program ID:** `FLUXubRmkEi2q6K3Y9kBPg9248ggaZVsoSFhtJHSrm1X`
- **Decoder struct:** `FluxbeamDecoder`
- **Has CPI events:** no

## Instructions

- `DepositAllTokenTypes`
- `DepositSingleTokenTypeExactAmountIn`
- `Initialize`
- `Swap`
- `WithdrawAllTokenTypes`
- `WithdrawSingleTokenTypeExactAmountOut`

## Account types

- `SwapV1`

## Shared types

- `ConstantPriceCurve`
- `ConstantProductCurve`
- `CurveType`
- `Fees`
- `OffsetCurve`
- `SwapCurve`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list fluxbeam

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix fluxbeam <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account fluxbeam <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event fluxbeam <EventName>

# shared type fields
python3 "$CARBON" type fluxbeam <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path fluxbeam
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-fluxbeam-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
