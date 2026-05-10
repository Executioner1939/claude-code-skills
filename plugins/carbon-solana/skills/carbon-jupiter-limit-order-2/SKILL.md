---
name: carbon-jupiter-limit-order-2
description: Carbon decoder reference for Jupiter Limit Order v2 on Solana — program `j1o2qRpjcyUwEvwtcfhEQefh773ZgjxcVRry7LDqg5X`, crate `carbon-jupiter-limit-order-2-decoder` (6 instructions, 2 account types, 3 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "Jupiter Limit Order 2", "jupiter-limit-order-2", "carbon-jupiter-limit-order-2-decoder", "j1o2qRpjcyUwEvwtcfhEQefh773ZgjxcVRry7LDqg5X", "JupiterLimitOrder2Decoder", "Jupiter Limit Order v2", "CancelOrder", "FlashFillOrder", "InitializeOrder", "PreFlashFillOrder", "UpdateFee", "WithdrawFee", "CancelOrderEvent", "CreateOrderEvent", "TradeEvent", "Fee", "Order".
---

# Jupiter Limit Order 2

- **Crate:** `carbon-jupiter-limit-order-2-decoder`
- **Program ID:** `j1o2qRpjcyUwEvwtcfhEQefh773ZgjxcVRry7LDqg5X`
- **Decoder struct:** `JupiterLimitOrder2Decoder`
- **Has CPI events:** yes (in instructions/)

## Instructions

- `CancelOrder`
- `FlashFillOrder`
- `InitializeOrder`
- `PreFlashFillOrder`
- `UpdateFee`
- `WithdrawFee`

## Account types

- `Fee`
- `Order`

## CPI events

- `CancelOrderEvent`
- `CreateOrderEvent`
- `TradeEvent`

## Shared types

- `FlashFillOrderParams`
- `InitializeOrderParams`
- `PreFlashFillOrderParams`
- `UpdateFeeParams`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list jupiter-limit-order-2

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix jupiter-limit-order-2 <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account jupiter-limit-order-2 <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event jupiter-limit-order-2 <EventName>

# shared type fields
python3 "$CARBON" type jupiter-limit-order-2 <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path jupiter-limit-order-2
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-jupiter-limit-order-2-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
