---
name: carbon-kamino-limit-order
description: "Carbon decoder reference for Kamino Limit Order on Solana — program `LiMoM9rMhrdYrfzUCxQppvxCSG1FcrUK9G8uLq4A1GF`, crate `carbon-kamino-limit-order-decoder` (11 instructions, 2 account types, 2 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"Kamino Limit Order\", \"kamino-limit-order\", \"carbon-kamino-limit-order-decoder\", \"LiMoM9rMhrdYrfzUCxQppvxCSG1FcrUK9G8uLq4A1GF\", \"KaminoLimitOrderDecoder\", \"CloseOrderAndClaimTip\", \"CreateOrder\", \"FlashTakeOrderEnd\", \"FlashTakeOrderStart\", \"InitializeGlobalConfig\", \"InitializeVault\", \"OrderDisplayEvent\", \"UserSwapBalancesEvent\", \"GlobalConfig\", \"Order\"."
---

# Kamino Limit Order

- **Crate:** `carbon-kamino-limit-order-decoder`
- **Program ID:** `LiMoM9rMhrdYrfzUCxQppvxCSG1FcrUK9G8uLq4A1GF`
- **Decoder struct:** `KaminoLimitOrderDecoder`
- **Has CPI events:** yes (in instructions/)

## Instructions

- `CloseOrderAndClaimTip`
- `CreateOrder`
- `FlashTakeOrderEnd`
- `FlashTakeOrderStart`
- `InitializeGlobalConfig`
- `InitializeVault`
- `LogUserSwapBalances`
- `TakeOrder`
- `UpdateGlobalConfig`
- `UpdateGlobalConfigAdmin`
- `WithdrawHostTip`

## Account types

- `GlobalConfig`
- `Order`

## CPI events

- `OrderDisplayEvent`
- `UserSwapBalancesEvent`

## Shared types

- `OrderStatus`
- `OrderType`
- `UpdateGlobalConfigMode`
- `UpdateGlobalConfigValue`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list kamino-limit-order

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix kamino-limit-order <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account kamino-limit-order <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event kamino-limit-order <EventName>

# shared type fields
python3 "$CARBON" type kamino-limit-order <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path kamino-limit-order
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-kamino-limit-order-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
