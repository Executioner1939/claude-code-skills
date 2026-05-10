# Phoenix v1

- **Crate:** `carbon-phoenix-v1-decoder`
- **Program ID:** `PhoeNiXZ8ByJGLkxNfZRnkUfjvmuYqLR89jjFHGqdXY`
- **Decoder struct:** `PhoenixDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** no
- **Discriminator style:** raw byte/short

## Account types

### `MarketHeader`
- **Fields:**
  - `discriminant`: `u64`
  - `status`: `u64`
  - `market_size_params`: `MarketSizeParams`
  - `base_params`: `TokenParams`
  - `base_lot_size`: `BaseAtomsPerBaseLot`
  - `quote_params`: `TokenParams`
  - `quote_lot_size`: `QuoteAtomsPerQuoteLot`
  - `tick_size_in_quote_atoms_per_base_unit`: `QuoteAtomsPerBaseUnitPerTick`
  - `authority`: `Pubkey`
  - `fee_recipient`: `Pubkey`
  - `market_sequence_number`: `u64`
  - `successor`: `Pubkey`
  - `raw_base_units_per_base_unit`: `u32`
  - `padding1`: `u32`
  - `padding2`: `[u64; 32]`

### `Seat`
- **Fields:**
  - `discriminant`: `u64`
  - `market`: `Pubkey`
  - `trader`: `Pubkey`
  - `approval_status`: `u64`
  - `padding`: `[u64; 6]`

## Instructions

### `CancelAllOrders`
- **Discriminator:** `0x06`
- **Args:** (none)
- **Account variants:**
  - `9 accounts:` `phoenix_program`, `log_authority`, `market`, `trader`, `base_account`, `quote_account`, `base_vault`, `quote_vault`, `token_program`

### `CancelAllOrdersWithFreeFunds`
- **Discriminator:** `0x07`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `phoenix_program`, `log_authority`, `market`, `trader`

### `CancelMultipleOrdersById`
- **Discriminator:** `0x0a`
- **Args:**
  - `params`: `CancelMultipleOrdersByIdParams`
- **Account variants:**
  - `9 accounts:` `phoenix_program`, `log_authority`, `market`, `trader`, `base_account`, `quote_account`, `base_vault`, `quote_vault`, `token_program`

### `CancelMultipleOrdersByIdWithFreeFunds`
- **Discriminator:** `0x0b`
- **Args:**
  - `params`: `CancelMultipleOrdersByIdParams`
- **Account variants:**
  - `4 accounts:` `phoenix_program`, `log_authority`, `market`, `trader`

### `CancelUpTo`
- **Discriminator:** `0x08`
- **Args:**
  - `params`: `CancelUpToParams`
- **Account variants:**
  - `9 accounts:` `phoenix_program`, `log_authority`, `market`, `trader`, `base_account`, `quote_account`, `base_vault`, `quote_vault`, `token_program`

### `CancelUpToWithFreeFunds`
- **Discriminator:** `0x09`
- **Args:**
  - `params`: `CancelUpToParams`
- **Account variants:**
  - `4 accounts:` `phoenix_program`, `log_authority`, `market`, `trader`

### `ChangeFeeRecipient`
- **Discriminator:** `0x6d`
- **Args:** (none)
- **Account variants:**
  - `5 accounts:` `phoenix_program`, `log_authority`, `market`, `market_authority`, `new_fee_recipient`

### `ChangeMarketStatus`
- **Discriminator:** `0x67`
- **Args:**
  - `market_status`: `MarketStatus`
- **Account variants:**
  - `4 accounts:` `phoenix_program`, `log_authority`, `market`, `market_authority`

### `ChangeSeatStatus`
- **Discriminator:** `0x68`
- **Args:**
  - `approval_status`: `SeatApprovalStatus`
- **Account variants:**
  - `5 accounts:` `phoenix_program`, `log_authority`, `market`, `market_authority`, `seat`

### `ClaimAuthority`
- **Discriminator:** `0x65`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `phoenix_program`, `log_authority`, `market`, `successor`

### `CollectFees`
- **Discriminator:** `0x6c`
- **Args:** (none)
- **Account variants:**
  - `7 accounts:` `phoenix_program`, `log_authority`, `market`, `sweeper`, `fee_recipient`, `quote_vault`, `token_program`

### `DepositFunds`
- **Discriminator:** `0x0d`
- **Args:**
  - `deposit_funds_params`: `DepositParams`
- **Account variants:**
  - `10 accounts:` `phoenix_program`, `log_authority`, `market`, `trader`, `seat`, `base_account`, `quote_account`, `base_vault`, `quote_vault`, `token_program`

### `EvictSeat`
- **Discriminator:** `0x6a`
- **Args:** (none)
- **Account variants:**
  - `11 accounts:` `phoenix_program`, `log_authority`, `market`, `market_authority`, `trader`, `seat`, `base_account`, `quote_account`, `base_vault`, `quote_vault`, `token_program`

### `ForceCancelOrders`
- **Discriminator:** `0x6b`
- **Args:**
  - `params`: `CancelUpToParams`
- **Account variants:**
  - `11 accounts:` `phoenix_program`, `log_authority`, `market`, `market_authority`, `trader`, `seat`, `base_account`, `quote_account`, `base_vault`, `quote_vault`, `token_program`

### `InitializeMarket`
- **Discriminator:** `0x64`
- **Args:**
  - `initialize_params`: `InitializeParams`
- **Account variants:**
  - `10 accounts:` `phoenix_program`, `log_authority`, `market`, `market_creator`, `base_mint`, `quote_mint`, `base_vault`, `quote_vault`, `system_program`, `token_program`

### `Log`
- **Discriminator:** `0x0f`
- **Args:** (none)
- **Account variants:**
  - `1 accounts:` `log_authority`

### `NameSuccessor`
- **Discriminator:** `0x66`
- **Args:**
  - `successor`: `Pubkey`
- **Account variants:**
  - `4 accounts:` `phoenix_program`, `log_authority`, `market`, `market_authority`

### `PlaceLimitOrder`
- **Discriminator:** `0x02`
- **Args:**
  - `order_packet`: `OrderPacket`
- **Account variants:**
  - `10 accounts:` `phoenix_program`, `log_authority`, `market`, `trader`, `seat`, `base_account`, `quote_account`, `base_vault`, `quote_vault`, `token_program`

### `PlaceLimitOrderWithFreeFunds`
- **Discriminator:** `0x03`
- **Args:**
  - `order_packet`: `OrderPacket`
- **Account variants:**
  - `5 accounts:` `phoenix_program`, `log_authority`, `market`, `trader`, `seat`

### `PlaceMultiplePostOnlyOrders`
- **Discriminator:** `0x10`
- **Args:**
  - `multiple_order_packet`: `MultipleOrderPacket`
- **Account variants:**
  - `10 accounts:` `phoenix_program`, `log_authority`, `market`, `trader`, `seat`, `base_account`, `quote_account`, `base_vault`, `quote_vault`, `token_program`

### `PlaceMultiplePostOnlyOrdersWithFreeFunds`
- **Discriminator:** `0x11`
- **Args:**
  - `multiple_order_packet`: `MultipleOrderPacket`
- **Account variants:**
  - `5 accounts:` `phoenix_program`, `log_authority`, `market`, `trader`, `seat`

### `ReduceOrder`
- **Discriminator:** `0x04`
- **Args:**
  - `params`: `ReduceOrderParams`
- **Account variants:**
  - `9 accounts:` `phoenix_program`, `log_authority`, `market`, `trader`, `base_account`, `quote_account`, `base_vault`, `quote_vault`, `token_program`

### `ReduceOrderWithFreeFunds`
- **Discriminator:** `0x05`
- **Args:**
  - `params`: `ReduceOrderParams`
- **Account variants:**
  - `4 accounts:` `phoenix_program`, `log_authority`, `market`, `trader`

### `RequestSeat`
- **Discriminator:** `0x0e`
- **Args:** (none)
- **Account variants:**
  - `6 accounts:` `phoenix_program`, `log_authority`, `market`, `payer`, `seat`, `system_program`

### `RequestSeatAuthorized`
- **Discriminator:** `0x69`
- **Args:** (none)
- **Account variants:**
  - `8 accounts:` `phoenix_program`, `log_authority`, `market`, `market_authority`, `payer`, `trader`, `seat`, `system_program`

### `Swap`
- **Discriminator:** `0x00`
- **Args:**
  - `order_packet`: `OrderPacket`
- **Account variants:**
  - `9 accounts:` `phoenix_program`, `log_authority`, `market`, `trader`, `base_account`, `quote_account`, `base_vault`, `quote_vault`, `token_program`

### `SwapWithFreeFunds`
- **Discriminator:** `0x01`
- **Args:**
  - `order_packet`: `OrderPacket`
- **Account variants:**
  - `5 accounts:` `phoenix_program`, `log_authority`, `market`, `trader`, `seat`

### `WithdrawFunds`
- **Discriminator:** `0x0c`
- **Args:**
  - `withdraw_funds_params`: `WithdrawParams`
- **Account variants:**
  - `9 accounts:` `phoenix_program`, `log_authority`, `market`, `trader`, `base_account`, `quote_account`, `base_vault`, `quote_vault`, `token_program`

## Shared types

### `AuditLogHeader`
- `instruction`: `u8`
- `sequence_number`: `u64`
- `timestamp`: `i64`
- `slot`: `u64`
- `market`: `Pubkey`
- `signer`: `Pubkey`
- `total_events`: `u16`

### `BaseAtomsPerBaseLot`
- `inner`: `u64`

### `CancelMultipleOrdersByIdParams`
- `orders`: `Vec<CancelOrderParams>`

### `CancelOrderParams`
- `side`: `Side`
- `price_in_ticks`: `u64`
- `order_sequence_number`: `u64`

### `CancelUpToParams`
- `side`: `Side`
- `tick_limit`: `Option<u64>`
- `num_orders_to_search`: `Option<u32>`
- `num_orders_to_cancel`: `Option<u32>`

### `CondensedOrder`
- `price_in_ticks`: `u64`
- `size_in_base_lots`: `u64`
- `last_valid_slot`: `Option<u64>`
- `last_valid_unix_timestamp_in_seconds`: `Option<u64>`

### `DepositParams`
- `quote_lots_to_deposit`: `u64`
- `base_lots_to_deposit`: `u64`

### `EvictEvent`
- `index`: `u16`
- `maker_id`: `Pubkey`
- `order_sequence_number`: `u64`
- `price_in_ticks`: `u64`
- `base_lots_evicted`: `u64`

### `ExpiredOrderEvent`
- `index`: `u16`
- `maker_id`: `Pubkey`
- `order_sequence_number`: `u64`
- `price_in_ticks`: `u64`
- `base_lots_removed`: `u64`

### `FIFOOrderId`
- `price_in_ticks`: `Ticks`
- `order_sequence_number`: `u64`

### `FailedMultipleLimitOrderBehavior`
- enum variants: `FailOnInsufficientFundsAndAmendOnCross`, `FailOnInsufficientFundsAndFailOnCross`, `SkipOnInsufficientFundsAndAmendOnCross`, `SkipOnInsufficientFundsAndFailOnCross`

### `FeeEvent`
- `index`: `u16`
- `fees_collected_in_quote_lots`: `u64`

### `FillEvent`
- `index`: `u16`
- `maker_id`: `Pubkey`
- `order_sequence_number`: `u64`
- `price_in_ticks`: `u64`
- `base_lots_filled`: `u64`
- `base_lots_remaining`: `u64`

### `FillSummaryEvent`
- `index`: `u16`
- `client_order_id`: `u128`
- `total_base_lots_filled`: `u64`
- `total_quote_lots_filled`: `u64`
- `total_fee_in_quote_lots`: `u64`

### `InitializeParams`
- `market_size_params`: `MarketSizeParams`
- `num_quote_lots_per_quote_unit`: `u64`
- `tick_size_in_quote_lots_per_base_unit`: `u64`
- `num_base_lots_per_base_unit`: `u64`
- `taker_fee_bps`: `u16`
- `fee_collector`: `Pubkey`
- `raw_base_units_per_base_unit`: `Option<u32>`

### `MarketHeader`
- `discriminant`: `u64`
- `status`: `u64`
- `market_size_params`: `MarketSizeParams`
- `base_params`: `TokenParams`
- `base_lot_size`: `u64`
- `quote_params`: `TokenParams`
- `quote_lot_size`: `u64`
- `tick_size_in_quote_atoms_per_base_unit`: `u64`
- `authority`: `Pubkey`
- `fee_recipient`: `Pubkey`
- `market_sequence_number`: `u64`
- `successor`: `Pubkey`
- `raw_base_units_per_base_unit`: `u32`
- `padding1`: `u32`
- `padding2`: `[u64; 32]`

### `MarketSizeParams`
- `bids_size`: `u64`
- `asks_size`: `u64`
- `num_seats`: `u64`

### `MarketStatus`
- enum variants: `Uninitialized`, `Active`, `PostOnly`, `Paused`, `Closed`, `Tombstoned`

### `MultipleOrderPacket`
- `bids`: `Vec<CondensedOrder>`
- `asks`: `Vec<CondensedOrder>`
- `client_order_id`: `Option<u128>`
- `failed_multiple_limit_order_behavior`: `FailedMultipleLimitOrderBehavior`

### `OrderPacket`
- enum variants: `PostOnly`, `Limit`, `ImmediateOrCancel`

### `PhoenixMarketEvent`
- enum variants: `Uninitialized`, `Header`, `Fill`, `Place`, `Reduce`, `Evict`, `FillSummary`, `Fee`, `TimeInForce`, `ExpiredOrder`

### `PlaceEvent`
- `index`: `u16`
- `order_sequence_number`: `u64`
- `client_order_id`: `u128`
- `price_in_ticks`: `u64`
- `base_lots_placed`: `u64`

### `QuoteAtomsPerBaseUnitPerTick`
- `inner`: `u64`

### `QuoteAtomsPerQuoteLot`
- `inner`: `u64`

### `ReduceEvent`
- `index`: `u16`
- `order_sequence_number`: `u64`
- `price_in_ticks`: `u64`
- `base_lots_removed`: `u64`
- `base_lots_remaining`: `u64`

### `ReduceOrderParams`
- `base_params`: `CancelOrderParams`
- `size`: `u64`

### `SeatApprovalStatus`
- enum variants: `NotApproved`, `Approved`, `Retired`

### `SelfTradeBehavior`
- enum variants: `Abort`, `CancelProvide`, `DecrementTake`

### `Side`
- enum variants: `Bid`, `Ask`

### `Ticks`
- `inner`: `u64`

### `TimeInForceEvent`
- `index`: `u16`
- `order_sequence_number`: `u64`
- `last_valid_slot`: `u64`
- `last_valid_unix_timestamp_in_seconds`: `u64`

### `TokenParams`
- `decimals`: `u32`
- `vault_bump`: `u32`
- `mint_key`: `Pubkey`
- `vault_key`: `Pubkey`

### `WithdrawParams`
- `quote_lots_to_withdraw`: `Option<u64>`
- `base_lots_to_withdraw`: `Option<u64>`
