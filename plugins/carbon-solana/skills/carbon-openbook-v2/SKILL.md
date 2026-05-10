---
name: carbon-openbook-v2
description: Carbon decoder reference for OpenBook v2 (orderbook DEX) on Solana — program `opnb2LAfJYbRMAHHvqjCwQxanZn7ReEHp1k81EohpZb`, crate `carbon-openbook-v2-decoder` (29 instructions, 6 account types, 8 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "Openbook V2", "openbook-v2", "carbon-openbook-v2-decoder", "opnb2LAfJYbRMAHHvqjCwQxanZn7ReEHp1k81EohpZb", "OpenbookV2Decoder", "OpenBook v2 (orderbook DEX)", "CreateMarket", "CloseMarket", "CreateOpenOrdersIndexer", "CloseOpenOrdersIndexer", "CreateOpenOrdersAccount", "CloseOpenOrdersAccount", "DepositLogEvent", "FillLogEvent", "MarketMetaDataLogEvent", "OpenOrdersPositionLogEvent", "BookSide", "EventHeap", "Market", "OpenOrdersAccount".
---

# Openbook V2

- **Crate:** `carbon-openbook-v2-decoder`
- **Program ID:** `opnb2LAfJYbRMAHHvqjCwQxanZn7ReEHp1k81EohpZb`
- **Decoder struct:** `OpenbookV2Decoder`
- **Has CPI events:** yes (in instructions/ as `*_log_event.rs` and `total_order_fill_event.rs`)

## Instructions

- `CreateMarket`
- `CloseMarket`
- `CreateOpenOrdersIndexer`
- `CloseOpenOrdersIndexer`
- `CreateOpenOrdersAccount`
- `CloseOpenOrdersAccount`
- `PlaceOrder`
- `EditOrder`
- `EditOrderPegged`
- `CancelAllAndPlaceOrders`
- `PlaceOrders`
- `PlaceOrderPegged`
- `PlaceTakeOrder`
- `CancelOrder`
- `CancelOrderByClientOrderId`
- `CancelAllOrders`
- `Deposit`
- `Refill`
- `SettleFunds`
- `SettleFundsExpired`
- `SweepFees`
- `ConsumeEvents`
- `ConsumeGivenEvents`
- `PruneOrders`
- `SetDelegate`
- `SetMarketExpired`
- `StubOracleCreate`
- `StubOracleClose`
- `StubOracleSet`

## Account types

- `BookSide`
- `EventHeap`
- `Market`
- `OpenOrdersAccount`
- `OpenOrdersIndexer`
- `StubOracle`

## CPI events

- `DepositLogEvent`
- `FillLogEvent`
- `MarketMetaDataLogEvent`
- `OpenOrdersPositionLogEvent`
- `SetDelegateLogEvent`
- `SettleFundsLogEvent`
- `SweepFeesLogEvent`
- `TotalOrderFillEvent`

## Shared types

- `OracleConfig`
- `OracleConfigParams`
- `OracleType`
- `NonZeroPubkeyOption`
- `Position`
- `OpenOrder`
- `OrderTreeRoot`
- `OrderTreeNodes`
- `AnyNode`
- `InnerNode`
- `LeafNode`
- `NodeTag`
- `EventHeapHeader`
- `EventNode`
- `AnyEvent`
- `EventType`
- `FillEvent`
- `OutEvent`
- `PlaceOrderArgs`
- `PlaceOrderPeggedArgs`
- `PlaceTakeOrderArgs`
- `PlaceMultipleOrdersArgs`
- `OrderParams`
- `OrderState`
- `OrderTreeType`
- `BookSideOrderTree`
- `Side`
- `SideAndOrderTree`
- `PlaceOrderType`
- `PostOrderType`
- `SelfTradeBehavior`
- `I80F48`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list openbook-v2

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix openbook-v2 <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account openbook-v2 <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event openbook-v2 <EventName>

# shared type fields
python3 "$CARBON" type openbook-v2 <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path openbook-v2
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-openbook-v2-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
