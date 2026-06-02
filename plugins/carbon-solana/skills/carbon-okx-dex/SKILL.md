---
name: carbon-okx-dex
description: "Carbon decoder reference for OKX DEX on Solana — program `6m2CDdhRgxpH4WjvdzxAYbGxwdGUz5MziiL5jek2kBma`, crate `carbon-okx-dex-decoder` (12 instructions, 1 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"OKX DEX Aggregator\", \"okx-dex\", \"carbon-okx-dex-decoder\", \"6m2CDdhRgxpH4WjvdzxAYbGxwdGUz5MziiL5jek2kBma\", \"OkxDexDecoder\", \"OKX DEX\", \"Swap\", \"Swap2\", \"ProxySwap\", \"CommissionSolSwap\", \"CommissionSolSwap2\", \"CommissionSplSwap\", \"SwapEvent\"."
---

# OKX DEX Aggregator

- **Crate:** `carbon-okx-dex-decoder`
- **Program ID:** `6m2CDdhRgxpH4WjvdzxAYbGxwdGUz5MziiL5jek2kBma`
- **Decoder struct:** `OkxDexDecoder`
- **Has CPI events:** yes (in instructions/ as `swap_event.rs` and types/ as `swap_event.rs`)

## Instructions

- `Swap`
- `Swap2`
- `ProxySwap`
- `CommissionSolSwap`
- `CommissionSolSwap2`
- `CommissionSplSwap`
- `CommissionSplSwap2`
- `CommissionSolProxySwap`
- `CommissionSplProxySwap`
- `FromSwapLog`
- `CommissionSolFromSwap`
- `CommissionSplFromSwap`

## CPI events

- `SwapEvent`

## Shared types

- `SwapArgs`
- `CommissionSwapArgs`
- `BridgeToArgs`
- `Route`
- `Dex`
- `AdaptorID`
- `SwapType`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list okx-dex

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix okx-dex <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account okx-dex <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event okx-dex <EventName>

# shared type fields
python3 "$CARBON" type okx-dex <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path okx-dex
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-okx-dex-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
