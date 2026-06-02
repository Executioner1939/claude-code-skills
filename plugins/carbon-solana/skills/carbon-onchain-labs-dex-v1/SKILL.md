---
name: carbon-onchain-labs-dex-v1
description: "Carbon decoder reference for Onchain Labs DEX v1 on Solana — program `6m2CDdhRgxpH4WjvdzxAYbGxwdGUz5MziiL5jek2kBma`, crate `carbon-onchain-labs-dex-v1-decoder` (20 instructions, 13 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"OnchainLabs DEX V1\", \"onchain-labs-dex-v1\", \"carbon-onchain-labs-dex-v1-decoder\", \"6m2CDdhRgxpH4WjvdzxAYbGxwdGUz5MziiL5jek2kBma\", \"OnchainLabsDexV1Decoder\", \"Onchain Labs DEX v1\", \"Claim\", \"CommissionSolProxySwap\", \"CommissionSolSwap\", \"CommissionSplProxySwap\", \"CommissionSplSwap\", \"CommissionWrapUnwrap\", \"AddResolverEventEvent\", \"CancelOrderEventEvent\", \"FillOrderEventEvent\", \"InitGlobalConfigEventEvent\"."
---

# OnchainLabs DEX V1

- **Crate:** `carbon-onchain-labs-dex-v1-decoder`
- **Program ID:** `6m2CDdhRgxpH4WjvdzxAYbGxwdGUz5MziiL5jek2kBma`
- **Decoder struct:** `OnchainLabsDexV1Decoder`
- **Has CPI events:** yes (events/)

## Instructions

- `Claim`
- `CommissionSolProxySwap`
- `CommissionSolSwap`
- `CommissionSplProxySwap`
- `CommissionSplSwap`
- `CommissionWrapUnwrap`
- `CpiEvent`
- `CreateTokenAccount`
- `CreateTokenAccountWithSeed`
- `PlatformFeeSolProxySwapV2`
- `PlatformFeeSolWrapUnwrapV2`
- `PlatformFeeSplProxySwapV2`
- `ProxySwap`
- `Swap`
- `SwapTobV3`
- `SwapTobV3Enhanced`
- `SwapTobV3WithReceiver`
- `SwapV3`
- `WrapUnwrapV3`
- `WrapUnwrapV3WithReceiver`

## CPI events

- `AddResolverEventEvent`
- `CancelOrderEventEvent`
- `FillOrderEventEvent`
- `InitGlobalConfigEventEvent`
- `PauseTradingEventEvent`
- `PlaceOrderEventEvent`
- `RefundEventEvent`
- `RemoveResolverEventEvent`
- `SetAdminEventEvent`
- `SetFeeMultiplierEventEvent`
- `SetTradeFeeEventEvent`
- `SwapEventEvent`
- `UpdateOrderEventEvent`

## Shared types

- `SwapArgs`
- `CommissionSwapArgs`
- `CommissionWrapUnwrapArgs`
- `PlatformFeeWrapUnwrapArgs`
- `PlatformFeeWrapUnwrapArgsV2`
- `Route`
- `Dex`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list onchain-labs-dex-v1

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix onchain-labs-dex-v1 <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account onchain-labs-dex-v1 <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event onchain-labs-dex-v1 <EventName>

# shared type fields
python3 "$CARBON" type onchain-labs-dex-v1 <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path onchain-labs-dex-v1
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-onchain-labs-dex-v1-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
