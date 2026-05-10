# Openbook V2

- **Crate:** `carbon-openbook-v2-decoder`
- **Program ID:** `opnb2LAfJYbRMAHHvqjCwQxanZn7ReEHp1k81EohpZb`
- **Decoder struct:** `OpenbookV2Decoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in instructions/ as `*_log_event.rs` and `total_order_fill_event.rs`)
- **Discriminator style:** anchor 8-byte (events use 16-byte anchor event prefix)

## Account types

### `BookSide`
- **Discriminator:** `0x482ce18db2826139`
- **Fields:**
  - `roots`: `[OrderTreeRoot; 2]`
  - `reserved_roots`: `[OrderTreeRoot; 4]`
  - `reserved`: `[u8; 256]`
  - `nodes`: `OrderTreeNodes`

### `EventHeap`
- **Discriminator:** `0x773b3d13a55439af`
- **Fields:**
  - `header`: `EventHeapHeader`
  - `nodes`: `[EventNode; 600]`
  - `reserved`: `[u8; 64]`

### `Market`
- **Discriminator:** `0xdbbed53700e3c69a`
- **Fields:**
  - `bump`: `u8`
  - `base_decimals`: `u8`
  - `quote_decimals`: `u8`
  - `padding1`: `[u8; 5]`
  - `market_authority`: `Pubkey`
  - `time_expiry`: `i64`
  - `collect_fee_admin`: `Pubkey`
  - `open_orders_admin`: `NonZeroPubkeyOption`
  - `consume_events_admin`: `NonZeroPubkeyOption`
  - `close_market_admin`: `NonZeroPubkeyOption`
  - `name`: `[u8; 16]`
  - `bids`: `Pubkey`
  - `asks`: `Pubkey`
  - `event_heap`: `Pubkey`
  - `oracle_a`: `NonZeroPubkeyOption`
  - `oracle_b`: `NonZeroPubkeyOption`
  - `oracle_config`: `OracleConfig`
  - `quote_lot_size`: `i64`
  - `base_lot_size`: `i64`
  - `seq_num`: `u64`
  - `registration_time`: `i64`
  - `maker_fee`: `i64`
  - `taker_fee`: `i64`
  - `fees_accrued`: `u128`
  - `fees_to_referrers`: `u128`
  - `referrer_rebates_accrued`: `u64`
  - `fees_available`: `u64`
  - `maker_volume`: `u128`
  - `taker_volume_wo_oo`: `u128`
  - `base_mint`: `Pubkey`
  - `quote_mint`: `Pubkey`
  - `market_base_vault`: `Pubkey`
  - `base_deposit_total`: `u64`
  - `market_quote_vault`: `Pubkey`
  - `quote_deposit_total`: `u64`
  - `reserved`: `[u8; 128]`

### `OpenOrdersAccount`
- **Discriminator:** `0xffc24e7b1069d0a5`
- **Fields:**
  - `owner`: `Pubkey`
  - `market`: `Pubkey`
  - `name`: `[u8; 32]`
  - `delegate`: `NonZeroPubkeyOption`
  - `account_num`: `u32`
  - `bump`: `u8`
  - `version`: `u8`
  - `padding`: `[u8; 2]`
  - `position`: `Position`
  - `open_orders`: `[OpenOrder; 24]`

### `OpenOrdersIndexer`
- **Discriminator:** `0xc35380d5cc5b1396`
- **Fields:**
  - `bump`: `u8`
  - `created_counter`: `u32`
  - `addresses`: `Vec<Pubkey>`

### `StubOracle`
- **Discriminator:** `0xe0fbfe63b1ae8904`
- **Fields:**
  - `owner`: `Pubkey`
  - `mint`: `Pubkey`
  - `price`: `f64`
  - `last_update_ts`: `i64`
  - `last_update_slot`: `u64`
  - `deviation`: `f64`
  - `reserved`: `[u8; 104]`

## Instructions

### `CreateMarket`
- **Discriminator:** `0x67e261ebc8bcfbfe`
- **Args:**
  - `name`: `String`
  - `oracle_config`: `OracleConfigParams`
  - `quote_lot_size`: `i64`
  - `base_lot_size`: `i64`
  - `maker_fee`: `i64`
  - `taker_fee`: `i64`
  - `time_expiry`: `i64`
- **Account variants:**
  - `21 accounts:` `market, market_authority, bids, asks, event_heap, payer, market_base_vault, market_quote_vault, base_mint, quote_mint, system_program, token_program, associated_token_program, oracle_a, oracle_b, collect_fee_admin, open_orders_admin, consume_events_admin, close_market_admin, event_authority, program`

### `CloseMarket`
- **Discriminator:** `0x589af8ba300e7bf4`
- **Account variants:**
  - `7 accounts:` `close_market_admin, market, bids, asks, event_heap, sol_destination, token_program`

### `CreateOpenOrdersIndexer`
- **Discriminator:** `0x404099ffd947f985`
- **Account variants:**
  - `4 accounts:` `payer, owner, open_orders_indexer, system_program`

### `CloseOpenOrdersIndexer`
- **Discriminator:** `0x67f9e5e7f7fdc588`
- **Account variants:**
  - `4 accounts:` `owner, open_orders_indexer, sol_destination, token_program`

### `CreateOpenOrdersAccount`
- **Discriminator:** `0xccb5afde287dbc47`
- **Args:**
  - `name`: `String`
- **Account variants:**
  - `7 accounts:` `payer, owner, delegate_account, open_orders_indexer, open_orders_account, market, system_program`

### `CloseOpenOrdersAccount`
- **Discriminator:** `0xb04a73d236b35b67`
- **Account variants:**
  - `5 accounts:` `owner, open_orders_indexer, open_orders_account, sol_destination, system_program`

### `PlaceOrder`
- **Discriminator:** `0x33c29baf6d82606a`
- **Args:**
  - `args`: `PlaceOrderArgs`
- **Account variants:**
  - `12 accounts:` `signer, open_orders_account, open_orders_admin, user_token_account, market, bids, asks, event_heap, market_vault, oracle_a, oracle_b, token_program`

### `EditOrder`
- **Discriminator:** `0xfed0761dadf8c846`
- **Args:**
  - `client_order_id`: `u64`
  - `expected_cancel_size`: `i64`
  - `place_order`: `PlaceOrderArgs`
- **Account variants:** same 12 as `PlaceOrder`

### `EditOrderPegged`
- **Discriminator:** `0x3ebb7d451add9d85`
- **Args:**
  - `client_order_id`: `u64`
  - `expected_cancel_size`: `i64`
  - `place_order`: `PlaceOrderPeggedArgs`
- **Account variants:** same 12 as `PlaceOrder`

### `CancelAllAndPlaceOrders`
- **Discriminator:** `0x809bde3cba28e132`
- **Args:**
  - `orders_type`: `PlaceOrderType`
  - `bids`: `Vec<PlaceMultipleOrdersArgs>`
  - `asks`: `Vec<PlaceMultipleOrdersArgs>`
  - `limit`: `u8`
- **Account variants:**
  - `14 accounts:` `signer, open_orders_account, open_orders_admin, user_quote_account, user_base_account, market, bids, asks, event_heap, market_quote_vault, market_base_vault, oracle_a, oracle_b, token_program`

### `PlaceOrders`
- **Discriminator:** `0x3c3f327b0cc53cbe`
- **Args:**
  - `orders_type`: `PlaceOrderType`
  - `bids`: `Vec<PlaceMultipleOrdersArgs>`
  - `asks`: `Vec<PlaceMultipleOrdersArgs>`
  - `limit`: `u8`
- **Account variants:** same 14 as `CancelAllAndPlaceOrders`

### `PlaceOrderPegged`
- **Discriminator:** `0x8db9fb3f4a55d291`
- **Args:**
  - `args`: `PlaceOrderPeggedArgs`
- **Account variants:** same 12 as `PlaceOrder`

### `PlaceTakeOrder`
- **Discriminator:** `0x032c47031ac7cb55`
- **Args:**
  - `args`: `PlaceTakeOrderArgs`
- **Account variants:**
  - `16 accounts:` `signer, penalty_payer, market, market_authority, bids, asks, market_base_vault, market_quote_vault, event_heap, user_base_account, user_quote_account, oracle_a, oracle_b, token_program, system_program, open_orders_admin`

### `CancelOrder`
- **Discriminator:** `0x5f81edf00831df84`
- **Args:**
  - `order_id`: `u128`
- **Account variants:**
  - `5 accounts:` `signer, open_orders_account, market, bids, asks`

### `CancelOrderByClientOrderId`
- **Discriminator:** `0x73b2c908afb77b77`
- **Args:**
  - `client_order_id`: `u64`
- **Account variants:**
  - `5 accounts:` `signer, open_orders_account, market, bids, asks`

### `CancelAllOrders`
- **Discriminator:** `0xc453f3ab1164a08f`
- **Args:**
  - `side_option`: `Option<Side>`
  - `limit`: `u8`
- **Account variants:**
  - `5 accounts:` `signer, open_orders_account, market, bids, asks`

### `Deposit`
- **Discriminator:** `0xf223c68952e1f2b6`
- **Args:**
  - `base_amount`: `u64`
  - `quote_amount`: `u64`
- **Account variants:**
  - `8 accounts:` `owner, user_base_account, user_quote_account, open_orders_account, market, market_base_vault, market_quote_vault, token_program`

### `Refill`
- **Discriminator:** `0x80cf8e0b36e826c9`
- **Args:**
  - `base_amount`: `u64`
  - `quote_amount`: `u64`
- **Account variants:** same 8 as `Deposit`

### `SettleFunds`
- **Discriminator:** `0xee40a3604bab1021`
- **Account variants:**
  - `12 accounts:` `owner, penalty_payer, open_orders_account, market, market_authority, market_base_vault, market_quote_vault, user_base_account, user_quote_account, referrer_account, token_program, system_program`

### `SettleFundsExpired`
- **Discriminator:** `0x6b123845e43837a4`
- **Account variants:**
  - `13 accounts:` `close_market_admin, owner, penalty_payer, open_orders_account, market, market_authority, market_base_vault, market_quote_vault, user_base_account, user_quote_account, referrer_account, token_program, system_program`

### `SweepFees`
- **Discriminator:** `0xafe1624776422294`
- **Account variants:**
  - `6 accounts:` `collect_fee_admin, market, market_authority, market_quote_vault, token_receiver_account, token_program`

### `ConsumeEvents`
- **Discriminator:** `0xdd91b1341f2f3fc9`
- **Args:**
  - `limit`: `u64`
- **Account variants:**
  - `3 accounts:` `consume_events_admin, market, event_heap`
- **Remaining accounts:** yes

### `ConsumeGivenEvents`
- **Discriminator:** `0xd1e336046dac2947`
- **Args:**
  - `slots`: `Vec<u64>`
- **Account variants:**
  - `3 accounts:` `consume_events_admin, market, event_heap`
- **Remaining accounts:** yes

### `PruneOrders`
- **Discriminator:** `0x1bd59fbf0c747079`
- **Args:**
  - `limit`: `u8`
- **Account variants:**
  - `5 accounts:` `close_market_admin, open_orders_account, market, bids, asks`

### `SetDelegate`
- **Discriminator:** `0xf21e2e4c6ceb80b5`
- **Account variants:**
  - `3 accounts:` `owner, open_orders_account, delegate_account`

### `SetMarketExpired`
- **Discriminator:** `0xdb52dbec3c73c540`
- **Account variants:**
  - `2 accounts:` `close_market_admin, market`

### `StubOracleCreate`
- **Discriminator:** `0xac3f65538d4cc7d8`
- **Args:**
  - `price`: `f64`
- **Account variants:**
  - `5 accounts:` `payer, owner, oracle, mint, system_program`

### `StubOracleClose`
- **Discriminator:** `0x5c892d032d3c75e0`
- **Account variants:**
  - `4 accounts:` `owner, oracle, sol_destination, token_program`

### `StubOracleSet`
- **Discriminator:** `0x6dc64f7941caa18e`
- **Args:**
  - `price`: `f64`
- **Account variants:**
  - `2 accounts:` `owner, oracle`

## CPI events

### `DepositLogEvent`
- **Source:** `instructions/deposit_log_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d8dbaa8fc6c8d485e`
- **Fields:**
  - `open_orders_account`: `Pubkey`
  - `signer`: `Pubkey`
  - `base_amount`: `u64`
  - `quote_amount`: `u64`

### `FillLogEvent`
- **Source:** `instructions/fill_log_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d9617299498a2d740`
- **Fields:**
  - `market`: `Pubkey`
  - `taker_side`: `u8`
  - `maker_slot`: `u8`
  - `maker_out`: `bool`
  - `timestamp`: `u64`
  - `seq_num`: `u64`
  - `maker`: `Pubkey`
  - `maker_client_order_id`: `u64`
  - `maker_fee`: `u64`
  - `maker_timestamp`: `u64`
  - `taker`: `Pubkey`
  - `taker_client_order_id`: `u64`
  - `taker_fee_ceil`: `u64`
  - `price`: `i64`
  - `quantity`: `i64`

### `MarketMetaDataLogEvent`
- **Source:** `instructions/market_meta_data_log_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1dd157d4eca43a3c75`
- **Fields:**
  - `market`: `Pubkey`
  - `name`: `String`
  - `base_mint`: `Pubkey`
  - `quote_mint`: `Pubkey`
  - `base_decimals`: `u8`
  - `quote_decimals`: `u8`
  - `base_lot_size`: `i64`
  - `quote_lot_size`: `i64`

### `OpenOrdersPositionLogEvent`
- **Source:** `instructions/open_orders_position_log_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1dc4f99421a8e44906`
- **Fields:**
  - `owner`: `Pubkey`
  - `open_orders_account_num`: `u32`
  - `market`: `Pubkey`
  - `bids_base_lots`: `i64`
  - `bids_quote_lots`: `i64`
  - `asks_base_lots`: `i64`
  - `base_free_native`: `u64`
  - `quote_free_native`: `u64`
  - `locked_maker_fees`: `u64`
  - `referrer_rebates_available`: `u64`
  - `maker_volume`: `u128`
  - `taker_volume`: `u128`

### `SetDelegateLogEvent`
- **Source:** `instructions/set_delegate_log_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d3582975c6d399170`
- **Fields:**
  - `open_orders_account`: `Pubkey`
  - `delegate`: `Option<Pubkey>`

### `SettleFundsLogEvent`
- **Source:** `instructions/settle_funds_log_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d0a32f075ed43e6e9`
- **Fields:**
  - `open_orders_account`: `Pubkey`
  - `base_native`: `u64`
  - `quote_native`: `u64`
  - `referrer_rebate`: `u64`
  - `referrer`: `Option<Pubkey>`

### `SweepFeesLogEvent`
- **Source:** `instructions/sweep_fees_log_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1dd2f21a4d5e30ff3d`
- **Fields:**
  - `market`: `Pubkey`
  - `amount`: `u64`
  - `receiver`: `Pubkey`

### `TotalOrderFillEvent`
- **Source:** `instructions/total_order_fill_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d08eb303aae4c9c69`
- **Fields:**
  - `side`: `u8`
  - `taker`: `Pubkey`
  - `total_quantity_paid`: `u64`
  - `total_quantity_received`: `u64`
  - `fees`: `u64`

## Shared types

### `OracleConfig`
- `conf_filter`: `f64`
- `max_staleness_slots`: `i64`
- `reserved`: `[u8; 72]`

### `OracleConfigParams`
- `conf_filter`: `f32`
- `max_staleness_slots`: `Option<u32>`

### `OracleType` (enum)
- `Pyth | Stub | SwitchboardV1 | SwitchboardV2 | RaydiumCLMM`

### `NonZeroPubkeyOption`
- `key`: `Pubkey`

### `Position`
- `bids_base_lots`: `i64`
- `asks_base_lots`: `i64`
- `base_free_native`: `u64`
- `quote_free_native`: `u64`
- `locked_maker_fees`: `u64`
- `referrer_rebates_available`: `u64`
- `penalty_heap_count`: `u64`
- `maker_volume`: `u128`
- `taker_volume`: `u128`
- `bids_quote_lots`: `i64`
- `reserved`: `[u8; 64]`

### `OpenOrder`
- `id`: `u128`
- `client_id`: `u64`
- `locked_price`: `i64`
- `is_free`: `u8`
- `side_and_tree`: `u8`
- `padding`: `[u8; 6]`

### `OrderTreeRoot`
- `maybe_node`: `u32`
- `leaf_count`: `u32`

### `OrderTreeNodes`
- `order_tree_type`: `u8`
- `padding`: `[u8; 3]`
- `bump_index`: `u32`
- `free_list_len`: `u32`
- `free_list_head`: `u32`
- `reserved`: `[u8; 512]`
- `nodes`: `[AnyNode; 1024]`

### `AnyNode`
- `tag`: `u8`
- `data`: `[u8; 87]`

### `InnerNode`
- `tag`: `u8`
- `padding`: `[u8; 3]`
- `prefix_len`: `u32`
- `key`: `u128`
- `children`: `[u32; 2]`
- `child_earliest_expiry`: `[u64; 2]`
- `reserved`: `[u8; 40]`

### `LeafNode`
- `tag`: `u8`
- `owner_slot`: `u8`
- `time_in_force`: `u16`
- `padding`: `[u8; 4]`
- `key`: `u128`
- `owner`: `Pubkey`
- `quantity`: `i64`
- `timestamp`: `u64`
- `peg_limit`: `i64`
- `client_order_id`: `u64`

### `NodeTag` (enum)
- `Uninitialized | InnerNode | LeafNode | FreeNode | LastFreeNode`

### `EventHeapHeader`
- `free_head`: `u16`
- `used_head`: `u16`
- `count`: `u16`
- `padd`: `u16`
- `seq_num`: `u64`

### `EventNode`
- `next`: `u16`
- `prev`: `u16`
- `pad`: `[u8; 4]`
- `event`: `AnyEvent`

### `AnyEvent`
- `event_type`: `u8`
- `padding`: `[u8; 143]`

### `EventType` (enum)
- `Fill | Out`

### `FillEvent`
- `event_type`: `u8`
- `taker_side`: `u8`
- `maker_out`: `u8`
- `maker_slot`: `u8`
- `padding`: `[u8; 4]`
- `timestamp`: `u64`
- `seq_num`: `u64`
- `maker`: `Pubkey`
- `maker_timestamp`: `u64`
- `taker`: `Pubkey`
- `taker_client_order_id`: `u64`
- `price`: `i64`
- `peg_limit`: `i64`
- `quantity`: `i64`
- `maker_client_order_id`: `u64`
- `reserved`: `[u8; 8]`

### `OutEvent`
- `event_type`: `u8`
- `side`: `u8`
- `owner_slot`: `u8`
- `padding0`: `[u8; 5]`
- `timestamp`: `u64`
- `seq_num`: `u64`
- `owner`: `Pubkey`
- `quantity`: `i64`
- `padding1`: `[u8; 80]`

### `PlaceOrderArgs`
- `side`: `Side`
- `price_lots`: `i64`
- `max_base_lots`: `i64`
- `max_quote_lots_including_fees`: `i64`
- `client_order_id`: `u64`
- `order_type`: `PlaceOrderType`
- `expiry_timestamp`: `u64`
- `self_trade_behavior`: `SelfTradeBehavior`
- `limit`: `u8`

### `PlaceOrderPeggedArgs`
- `side`: `Side`
- `price_offset_lots`: `i64`
- `peg_limit`: `i64`
- `max_base_lots`: `i64`
- `max_quote_lots_including_fees`: `i64`
- `client_order_id`: `u64`
- `order_type`: `PlaceOrderType`
- `expiry_timestamp`: `u64`
- `self_trade_behavior`: `SelfTradeBehavior`
- `limit`: `u8`

### `PlaceTakeOrderArgs`
- `side`: `Side`
- `price_lots`: `i64`
- `max_base_lots`: `i64`
- `max_quote_lots_including_fees`: `i64`
- `order_type`: `PlaceOrderType`
- `limit`: `u8`

### `PlaceMultipleOrdersArgs`
- `price_lots`: `i64`
- `max_quote_lots_including_fees`: `i64`
- `expiry_timestamp`: `u64`

### `OrderParams` (enum)
- `Market | ImmediateOrCancel { price_lots } | Fixed { price_lots, order_type } | OraclePegged { price_offset_lots, order_type, peg_limit } | FillOrKill { price_lots }`

### `OrderState` (enum)
- `Valid | Invalid | Skipped`

### `OrderTreeType` (enum)
- `Bids | Asks`

### `BookSideOrderTree` (enum)
- `Fixed | OraclePegged`

### `Side` (enum)
- `Bid | Ask`

### `SideAndOrderTree` (enum)
- `BidFixed | AskFixed | BidOraclePegged | AskOraclePegged`

### `PlaceOrderType` (enum)
- `Limit | ImmediateOrCancel | PostOnly | Market | PostOnlySlide | FillOrKill`

### `PostOrderType` (enum)
- `Limit | PostOnly | PostOnlySlide`

### `SelfTradeBehavior` (enum)
- `DecrementTake | CancelProvide | AbortTransaction`

### `I80F48`
- `val`: `i128`
