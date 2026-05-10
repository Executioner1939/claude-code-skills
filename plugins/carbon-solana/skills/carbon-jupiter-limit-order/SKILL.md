---
name: carbon-jupiter-limit-order
description: Carbon decoder reference for Jupiter Limit Order on Solana — program `jupoNjAxXgZ4rjzxzPMP4oxduvQsQtZzyknqvzYNrNu`, crate `carbon-jupiter-limit-order-decoder` (9 instructions, 2 account types, 3 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "Jupiter Limit Order", "jupiter-limit-order", "carbon-jupiter-limit-order-decoder", "jupoNjAxXgZ4rjzxzPMP4oxduvQsQtZzyknqvzYNrNu", "JupiterLimitOrderDecoder", "CancelExpiredOrder", "CancelOrder", "FillOrder", "FlashFillOrder", "InitFee", "InitializeOrder", "CancelOrderEvent", "CreateOrderEvent", "TradeEvent", "Fee", "Order".
---

# Jupiter Limit Order

- **Crate:** `carbon-jupiter-limit-order-decoder`
- **Program ID:** `jupoNjAxXgZ4rjzxzPMP4oxduvQsQtZzyknqvzYNrNu`
- **Decoder struct:** `JupiterLimitOrderDecoder`
- **Has CPI events:** yes (in instructions/)

## Instructions

- `CancelExpiredOrder`
- `CancelOrder`
- `FillOrder`
- `FlashFillOrder`
- `InitFee`
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

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list jupiter-limit-order

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix jupiter-limit-order <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account jupiter-limit-order <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event jupiter-limit-order <EventName>

# shared type fields
python3 "$CARBON" type jupiter-limit-order <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path jupiter-limit-order
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-jupiter-limit-order-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
