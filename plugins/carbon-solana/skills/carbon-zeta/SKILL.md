---
name: carbon-zeta
description: "Carbon decoder reference for Zeta Markets (options/perps) on Solana — program `ZETAxsqBRek56DhiGXrn75yj2NHU3aYUnxvHXpkf3aD`, crate `carbon-zeta-decoder` (0 instructions, 23 account types, 9 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"Zeta Markets\", \"zeta\", \"carbon-zeta-decoder\", \"ZETAxsqBRek56DhiGXrn75yj2NHU3aYUnxvHXpkf3aD\", \"ZetaDecoder\", \"Zeta Markets (options/perps)\", \"TradeEvent\", \"TradeEventV2Event\", \"TradeEventV3Event\", \"PlaceOrderEvent\", \"Pricing\", \"Greeks\", \"MarketIndexes\", \"OpenOrdersMap\"."
---

# Zeta Markets

- **Crate:** `carbon-zeta-decoder`
- **Program ID:** `ZETAxsqBRek56DhiGXrn75yj2NHU3aYUnxvHXpkf3aD`
- **Decoder struct:** `ZetaDecoder`
- **Has CPI events:** yes (in instructions/, *_event.rs)

## Account types

- `Pricing`
- `Greeks`
- `MarketIndexes`
- `OpenOrdersMap`
- `CrossOpenOrdersMap`
- `State`
- `Underlying`
- `SettlementAccount`
- `PerpSyncQueue`
- `ZetaGroup`
- `MarketNode`
- `SpreadAccount`
- `CrossMarginAccountManager`
- `CrossMarginAccount`
- `MarginAccount`
- `TriggerOrder`
- `SocializedLossAccount`
- `WhitelistDepositAccount`
- `WhitelistInsuranceAccount`
- `InsuranceDepositAccount`
- `WhitelistTradingFeesAccount`
- `ReferrerIdAccount`
- `ReferrerPubkeyAccount`

## CPI events

- `TradeEvent`
- `TradeEventV2Event`
- `TradeEventV3Event`
- `PlaceOrderEvent`
- `PlaceMultiOrdersEvent`
- `OrderCompleteEvent`
- `LiquidationEvent`
- `ApplyFundingEvent`
- `PositionMovementEvent`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list zeta

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix zeta <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account zeta <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event zeta <EventName>

# shared type fields
python3 "$CARBON" type zeta <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path zeta
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-zeta-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
