---
name: carbon-vertigo
description: "Carbon decoder reference for Vertigo on Solana — program `vrTGoBuy5rYSxAfV3jaRJWHH6nN9WK4NRExGxsk1bCJ`, crate `carbon-vertigo-decoder` (6 instructions, 1 account types, 3 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"Vertigo\", \"vertigo\", \"carbon-vertigo-decoder\", \"vrTGoBuy5rYSxAfV3jaRJWHH6nN9WK4NRExGxsk1bCJ\", \"VertigoDecoder\", \"Buy\", \"Sell\", \"Create\", \"Claim\", \"QuoteBuy\", \"QuoteSell\", \"BuyEvent\", \"SellEvent\", \"PoolCreatedEvent\", \"Pool\"."
---

# Vertigo

- **Crate:** `carbon-vertigo-decoder`
- **Program ID:** `vrTGoBuy5rYSxAfV3jaRJWHH6nN9WK4NRExGxsk1bCJ`
- **Decoder struct:** `VertigoDecoder`
- **Has CPI events:** yes (in instructions/, *_event.rs)

## Instructions

- `Buy`
- `Sell`
- `Create`
- `Claim`
- `QuoteBuy`
- `QuoteSell`

## Account types

- `Pool`

## CPI events

- `BuyEvent`
- `SellEvent`
- `PoolCreatedEvent`

## Shared types

- `FeeParams`
- `SwapParams`
- `CreateParams`
- `SwapResult`
- `PoolCreated`
- `BuyEvent`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list vertigo

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix vertigo <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account vertigo <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event vertigo <EventName>

# shared type fields
python3 "$CARBON" type vertigo <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path vertigo
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-vertigo-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
