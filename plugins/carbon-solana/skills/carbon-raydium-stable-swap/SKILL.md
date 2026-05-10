---
name: carbon-raydium-stable-swap
description: Carbon decoder reference for Raydium Stable Swap on Solana — program `5quBtoiQqxF9Jv6KYKctB59NT3gtJD2Y65kdnB1Uev3h`, crate `carbon-raydium-stable-swap-decoder` (6 instructions). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "Raydium Stable Swap", "raydium-stable-swap", "carbon-raydium-stable-swap-decoder", "5quBtoiQqxF9Jv6KYKctB59NT3gtJD2Y65kdnB1Uev3h", "RaydiumStableSwapAmmDecoder", "Deposit", "Initialize", "PreInitialize", "SwapBaseIn", "SwapBaseOut", "Withdraw".
---

# Raydium Stable Swap

- **Crate:** `carbon-raydium-stable-swap-decoder`
- **Program ID:** `5quBtoiQqxF9Jv6KYKctB59NT3gtJD2Y65kdnB1Uev3h`
- **Decoder struct:** `RaydiumStableSwapAmmDecoder`
- **Has CPI events:** no

## Instructions

- `Deposit`
- `Initialize`
- `PreInitialize`
- `SwapBaseIn`
- `SwapBaseOut`
- `Withdraw`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list raydium-stable-swap

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix raydium-stable-swap <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account raydium-stable-swap <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event raydium-stable-swap <EventName>

# shared type fields
python3 "$CARBON" type raydium-stable-swap <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path raydium-stable-swap
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-raydium-stable-swap-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
