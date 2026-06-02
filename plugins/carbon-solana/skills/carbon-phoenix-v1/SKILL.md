---
name: carbon-phoenix-v1
description: "Carbon decoder reference for Phoenix v1 (orderbook DEX) on Solana — program `PhoeNiXZ8ByJGLkxNfZRnkUfjvmuYqLR89jjFHGqdXY`, crate `carbon-phoenix-v1-decoder` (28 instructions, 2 account types). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"Phoenix v1\", \"phoenix-v1\", \"carbon-phoenix-v1-decoder\", \"PhoeNiXZ8ByJGLkxNfZRnkUfjvmuYqLR89jjFHGqdXY\", \"PhoenixDecoder\", \"Phoenix v1 (orderbook DEX)\", \"CancelAllOrders\", \"CancelAllOrdersWithFreeFunds\", \"CancelMultipleOrdersById\", \"CancelMultipleOrdersByIdWithFreeFunds\", \"CancelUpTo\", \"CancelUpToWithFreeFunds\", \"MarketHeader\", \"Seat\"."
---

# Phoenix v1

- **Crate:** `carbon-phoenix-v1-decoder`
- **Program ID:** `PhoeNiXZ8ByJGLkxNfZRnkUfjvmuYqLR89jjFHGqdXY`
- **Decoder struct:** `PhoenixDecoder`
- **Has CPI events:** no

## Instructions

- `CancelAllOrders`
- `CancelAllOrdersWithFreeFunds`
- `CancelMultipleOrdersById`
- `CancelMultipleOrdersByIdWithFreeFunds`
- `CancelUpTo`
- `CancelUpToWithFreeFunds`
- `ChangeFeeRecipient`
- `ChangeMarketStatus`
- `ChangeSeatStatus`
- `ClaimAuthority`
- `CollectFees`
- `DepositFunds`
- `EvictSeat`
- `ForceCancelOrders`
- `InitializeMarket`
- `Log`
- `NameSuccessor`
- `PlaceLimitOrder`
- `PlaceLimitOrderWithFreeFunds`
- `PlaceMultiplePostOnlyOrders`
- `PlaceMultiplePostOnlyOrdersWithFreeFunds`
- `ReduceOrder`
- `ReduceOrderWithFreeFunds`
- `RequestSeat`
- `RequestSeatAuthorized`
- `Swap`
- `SwapWithFreeFunds`
- `WithdrawFunds`

## Account types

- `MarketHeader`
- `Seat`

## Shared types

- `AuditLogHeader`
- `BaseAtomsPerBaseLot`
- `CancelMultipleOrdersByIdParams`
- `CancelOrderParams`
- `CancelUpToParams`
- `CondensedOrder`
- `DepositParams`
- `EvictEvent`
- `ExpiredOrderEvent`
- `FIFOOrderId`
- `FailedMultipleLimitOrderBehavior`
- `FeeEvent`
- `FillEvent`
- `FillSummaryEvent`
- `InitializeParams`
- `MarketHeader`
- `MarketSizeParams`
- `MarketStatus`
- `MultipleOrderPacket`
- `OrderPacket`
- `PhoenixMarketEvent`
- `PlaceEvent`
- `QuoteAtomsPerBaseUnitPerTick`
- `QuoteAtomsPerQuoteLot`
- `ReduceEvent`
- `ReduceOrderParams`
- `SeatApprovalStatus`
- `SelfTradeBehavior`
- `Side`
- `Ticks`
- `TimeInForceEvent`
- `TokenParams`
- `WithdrawParams`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list phoenix-v1

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix phoenix-v1 <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account phoenix-v1 <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event phoenix-v1 <EventName>

# shared type fields
python3 "$CARBON" type phoenix-v1 <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path phoenix-v1
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-phoenix-v1-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
