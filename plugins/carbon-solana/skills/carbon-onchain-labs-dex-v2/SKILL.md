---
name: carbon-onchain-labs-dex-v2
description: Carbon decoder reference for Onchain Labs DEX v2 on Solana — program `proVF4pMXVaYqmy4NjniPh4pqKNfMmsihgd4wdkCX3u`, crate `carbon-onchain-labs-dex-v2-decoder` (13 instructions, 5 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "OnchainLabs DEX V2", "onchain-labs-dex-v2", "carbon-onchain-labs-dex-v2-decoder", "proVF4pMXVaYqmy4NjniPh4pqKNfMmsihgd4wdkCX3u", "OnchainLabsDexV2Decoder", "Onchain Labs DEX v2", "Claim", "CpiEvent", "CreateTokenAccount", "CreateTokenAccountWithSeed", "ProxySwap", "Swap", "SwapCpiEventEvent", "SwapEventEvent", "SwapToCWithFeesCpiEventV2Event", "SwapWithFeesCpiEventEvent".
---

# OnchainLabs DEX V2

- **Crate:** `carbon-onchain-labs-dex-v2-decoder`
- **Program ID:** `proVF4pMXVaYqmy4NjniPh4pqKNfMmsihgd4wdkCX3u`
- **Decoder struct:** `OnchainLabsDexV2Decoder`
- **Has CPI events:** yes (events/)

## Instructions

- `Claim`
- `CpiEvent`
- `CreateTokenAccount`
- `CreateTokenAccountWithSeed`
- `ProxySwap`
- `Swap`
- `SwapTob`
- `SwapTobEnhanced`
- `SwapTobWithReceiver`
- `SwapToc`
- `SwapTocV2`
- `WrapUnwrap`
- `WrapUnwrapWithReceiver`

## CPI events

- `SwapCpiEventEvent`
- `SwapEventEvent`
- `SwapToCWithFeesCpiEventV2Event`
- `SwapWithFeesCpiEventEvent`
- `SwapWithFeesCpiEventEnhancedEvent`

## Shared types

- `SwapArgs`
- `Route`
- `PlatformFeeWrapUnwrapArgs`
- `Dex`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list onchain-labs-dex-v2

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix onchain-labs-dex-v2 <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account onchain-labs-dex-v2 <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event onchain-labs-dex-v2 <EventName>

# shared type fields
python3 "$CARBON" type onchain-labs-dex-v2 <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path onchain-labs-dex-v2
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-onchain-labs-dex-v2-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
