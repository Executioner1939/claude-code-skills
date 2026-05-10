# Drift v2

- **Crate:** `carbon-drift-v2-decoder`
- **Program ID:** `dRiftyHA39MWEi3m9aunc5MzRF1JYuBsbn6VPcn33UH`
- **Decoder struct:** `DriftDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in instructions/)
- **Discriminator style:** anchor 8-byte

## Account types

### `FuelOverflow`
- **Fields:**
  - `authority`: `Pubkey`
  - `fuel_insurance`: `u128`
  - `fuel_deposits`: `u128`
  - `fuel_borrows`: `u128`
  - `fuel_positions`: `u128`
  - `fuel_taker`: `u128`
  - `fuel_maker`: `u128`
  - `last_fuel_sweep_ts`: `u32`
  - `last_reset_ts`: `u32`
  - `padding`: `[u128; 6]`

### `HighLeverageModeConfig`
- **Fields:**
  - `max_users`: `u32`
  - `current_users`: `u32`
  - `reduce_only`: `u8`
  - `padding`: `[u8; 31]`

### `InsuranceFundStake`
- **Fields:**
  - `authority`: `Pubkey`
  - `if_shares`: `u128`
  - `last_withdraw_request_shares`: `u128`
  - `if_base`: `u128`
  - `last_valid_ts`: `i64`
  - `last_withdraw_request_value`: `u64`
  - `last_withdraw_request_ts`: `i64`
  - `cost_basis`: `i64`
  - `market_index`: `u16`
  - `padding`: `[u8; 14]`

### `OpenbookV2FulfillmentConfig`
- **Fields:**
  - `key`: `Pubkey`
  - `openbook_v2_program_id`: `Pubkey`
  - `openbook_v2_market`: `Pubkey`
  - `openbook_v2_market_authority`: `Pubkey`
  - `openbook_v2_event_heap`: `Pubkey`
  - `openbook_v2_bids`: `Pubkey`
  - `openbook_v2_asks`: `Pubkey`
  - `openbook_v2_base_vault`: `Pubkey`
  - `openbook_v2_quote_vault`: `Pubkey`
  - `market_index`: `u16`
  - `fulfillment_type`: `SpotFulfillmentType`
  - `status`: `SpotFulfillmentConfigStatus`
  - `padding`: `[u8; 4]`

### `PerpMarket`
- **Fields:**
  - `key`: `Pubkey`
  - `amm`: `AMM`
  - `pnl_pool`: `PoolBalance`
  - `name`: `[u8; 32]`
  - `insurance_claim`: `InsuranceClaim`
  - `unrealized_pnl_max_imbalance`: `u64`
  - `expiry_ts`: `i64`
  - `expiry_price`: `i64`
  - `next_fill_record_id`: `u64`
  - `next_funding_rate_record_id`: `u64`
  - `next_curve_record_id`: `u64`
  - `imf_factor`: `u32`
  - `unrealized_pnl_imf_factor`: `u32`
  - `liquidator_fee`: `u32`
  - `if_liquidation_fee`: `u32`
  - `margin_ratio_initial`: `u32`
  - `margin_ratio_maintenance`: `u32`
  - `unrealized_pnl_initial_asset_weight`: `u32`
  - `unrealized_pnl_maintenance_asset_weight`: `u32`
  - `number_of_users_with_base`: `u32`
  - `number_of_users`: `u32`
  - `market_index`: `u16`
  - `status`: `MarketStatus`
  - `contract_type`: `ContractType`
  - `contract_tier`: `ContractTier`
  - `paused_operations`: `u8`
  - `quote_spot_market_index`: `u16`
  - `fee_adjustment`: `i16`
  - `fuel_boost_position`: `u8`
  - `fuel_boost_taker`: `u8`
  - `fuel_boost_maker`: `u8`
  - `pool_id`: `u8`
  - `high_leverage_margin_ratio_initial`: `u16`
  - `high_leverage_margin_ratio_maintenance`: `u16`
  - `padding`: `[u8; 38]`

### `PhoenixV1FulfillmentConfig`
- **Fields:**
  - `key`: `Pubkey`
  - `phoenix_program_id`: `Pubkey`
  - `phoenix_log_authority`: `Pubkey`
  - `phoenix_market`: `Pubkey`
  - `phoenix_base_vault`: `Pubkey`
  - `phoenix_quote_vault`: `Pubkey`
  - `market_index`: `u16`
  - `fulfillment_type`: `SpotFulfillmentType`
  - `status`: `SpotFulfillmentConfigStatus`
  - `padding`: `[u8; 4]`

### `PrelaunchOracle`
- **Fields:**
  - `price`: `i64`
  - `max_price`: `i64`
  - `confidence`: `u64`
  - `last_update_slot`: `u64`
  - `amm_last_update_slot`: `u64`
  - `perp_market_index`: `u16`
  - `padding`: `[u8; 70]`

### `ProtectedMakerModeConfig`
- **Fields:**
  - `max_users`: `u32`
  - `current_users`: `u32`
  - `reduce_only`: `u8`
  - `padding`: `[u8; 31]`

### `ProtocolIfSharesTransferConfig`
- **Fields:**
  - `whitelisted_signers`: `[Pubkey; 4]`
  - `max_transfer_per_epoch`: `u128`
  - `current_epoch_transfer`: `u128`
  - `next_epoch_ts`: `i64`
  - `padding`: `[u128; 8]`

### `PythLazerOracle`
- **Fields:**
  - `price`: `i64`
  - `lish_time`: `u64`
  - `posted_slot`: `u64`
  - `exponent`: `i32`
  - `padding`: `[u8; 4]`
  - `conf`: `u64`

### `ReferrerName`
- **Fields:**
  - `authority`: `Pubkey`
  - `user`: `Pubkey`
  - `user_stats`: `Pubkey`
  - `name`: `[u8; 32]`

### `SerumV3FulfillmentConfig`
- **Fields:**
  - `key`: `Pubkey`
  - `serum_program_id`: `Pubkey`
  - `serum_market`: `Pubkey`
  - `serum_request_queue`: `Pubkey`
  - `serum_event_queue`: `Pubkey`
  - `serum_bids`: `Pubkey`
  - `serum_asks`: `Pubkey`
  - `serum_base_vault`: `Pubkey`
  - `serum_quote_vault`: `Pubkey`
  - `serum_open_orders`: `Pubkey`
  - `serum_signer_nonce`: `u64`
  - `market_index`: `u16`
  - `fulfillment_type`: `SpotFulfillmentType`
  - `status`: `SpotFulfillmentConfigStatus`
  - `padding`: `[u8; 4]`

### `SignedMsgUserOrders`
- **Fields:**
  - `authority_key`: `Pubkey`
  - `padding`: `u32`
  - `signed_msg_order_data`: `Vec<SignedMsgOrderId>`

### `SpotMarket`
- **Fields:**
  - `key`: `Pubkey`
  - `oracle`: `Pubkey`
  - `mint`: `Pubkey`
  - `vault`: `Pubkey`
  - `name`: `[u8; 32]`
  - `historical_oracle_data`: `HistoricalOracleData`
  - `historical_index_data`: `HistoricalIndexData`
  - `revenue_pool`: `PoolBalance`
  - `spot_fee_pool`: `PoolBalance`
  - `insurance_fund`: `InsuranceFund`
  - `total_spot_fee`: `u128`
  - `deposit_balance`: `u128`
  - `borrow_balance`: `u128`
  - `cumulative_deposit_interest`: `u128`
  - `cumulative_borrow_interest`: `u128`
  - `total_social_loss`: `u128`
  - `total_quote_social_loss`: `u128`
  - `withdraw_guard_threshold`: `u64`
  - `max_token_deposits`: `u64`
  - `deposit_token_twap`: `u64`
  - `borrow_token_twap`: `u64`
  - `utilization_twap`: `u64`
  - `last_interest_ts`: `u64`
  - `last_twap_ts`: `u64`
  - `expiry_ts`: `i64`
  - `order_step_size`: `u64`
  - `order_tick_size`: `u64`
  - `min_order_size`: `u64`
  - `max_position_size`: `u64`
  - `next_fill_record_id`: `u64`
  - `next_deposit_record_id`: `u64`
  - `initial_asset_weight`: `u32`
  - `maintenance_asset_weight`: `u32`
  - `initial_liability_weight`: `u32`
  - `maintenance_liability_weight`: `u32`
  - `imf_factor`: `u32`
  - `liquidator_fee`: `u32`
  - `if_liquidation_fee`: `u32`
  - `optimal_utilization`: `u32`
  - `optimal_borrow_rate`: `u32`
  - `max_borrow_rate`: `u32`
  - `decimals`: `u32`
  - `market_index`: `u16`
  - `orders_enabled`: `bool`
  - `oracle_source`: `OracleSource`
  - `status`: `MarketStatus`
  - `asset_tier`: `AssetTier`
  - `paused_operations`: `u8`
  - `if_paused_operations`: `u8`
  - `fee_adjustment`: `i16`
  - `max_token_borrows_fraction`: `u16`
  - `flash_loan_amount`: `u64`
  - `flash_loan_initial_token_amount`: `u64`
  - `total_swap_fee`: `u64`
  - `scale_initial_asset_weight_start`: `u64`
  - `min_borrow_rate`: `u8`
  - `fuel_boost_deposits`: `u8`
  - `fuel_boost_borrows`: `u8`
  - `fuel_boost_taker`: `u8`
  - `fuel_boost_maker`: `u8`
  - `fuel_boost_insurance`: `u8`
  - `token_program`: `u8`
  - `pool_id`: `u8`
  - `padding`: `[u8; 40]`

### `State`
- **Fields:**
  - `admin`: `Pubkey`
  - `whitelist_mint`: `Pubkey`
  - `discount_mint`: `Pubkey`
  - `signer`: `Pubkey`
  - `srm_vault`: `Pubkey`
  - `perp_fee_structure`: `FeeStructure`
  - `spot_fee_structure`: `FeeStructure`
  - `oracle_guard_rails`: `OracleGuardRails`
  - `number_of_authorities`: `u64`
  - `number_of_sub_accounts`: `u64`
  - `lp_cooldown_time`: `u64`
  - `liquidation_margin_buffer_ratio`: `u32`
  - `settlement_duration`: `u16`
  - `number_of_markets`: `u16`
  - `number_of_spot_markets`: `u16`
  - `signer_nonce`: `u8`
  - `min_perp_auction_duration`: `u8`
  - `default_market_order_time_in_force`: `u8`
  - `default_spot_auction_duration`: `u8`
  - `exchange_status`: `u8`
  - `liquidation_duration`: `u8`
  - `initial_pct_to_liquidate`: `u16`
  - `max_number_of_sub_accounts`: `u16`
  - `max_initialize_user_fee`: `u16`
  - `padding`: `[u8; 10]`

### `User`
- **Fields:**
  - `authority`: `Pubkey`
  - `delegate`: `Pubkey`
  - `name`: `[u8; 32]`
  - `spot_positions`: `[SpotPosition; 8]`
  - `perp_positions`: `[PerpPosition; 8]`
  - `orders`: `[Order; 32]`
  - `last_add_perp_lp_shares_ts`: `i64`
  - `total_deposits`: `u64`
  - `total_withdraws`: `u64`
  - `total_social_loss`: `u64`
  - `settled_perp_pnl`: `i64`
  - `cumulative_spot_fees`: `i64`
  - `cumulative_perp_funding`: `i64`
  - `liquidation_margin_freed`: `u64`
  - `last_active_slot`: `u64`
  - `next_order_id`: `u32`
  - `max_margin_ratio`: `u32`
  - `next_liquidation_id`: `u16`
  - `sub_account_id`: `u16`
  - `status`: `u8`
  - `is_margin_trading_enabled`: `bool`
  - `idle`: `bool`
  - `open_orders`: `u8`
  - `has_open_order`: `bool`
  - `open_auctions`: `u8`
  - `has_open_auction`: `bool`
  - `margin_mode`: `MarginMode`
  - `pool_id`: `u8`
  - `padding1`: `[u8; 3]`
  - `last_fuel_bonus_update_ts`: `u32`
  - `padding`: `[u8; 12]`

### `UserStats`
- **Fields:**
  - `authority`: `Pubkey`
  - `referrer`: `Pubkey`
  - `fees`: `UserFees`
  - `next_epoch_ts`: `i64`
  - `maker_volume30d`: `u64`
  - `taker_volume30d`: `u64`
  - `filler_volume30d`: `u64`
  - `last_maker_volume30d_ts`: `i64`
  - `last_taker_volume30d_ts`: `i64`
  - `last_filler_volume30d_ts`: `i64`
  - `if_staked_quote_asset_amount`: `u64`
  - `number_of_sub_accounts`: `u16`
  - `number_of_sub_accounts_created`: `u16`
  - `referrer_status`: `u8`
  - `disable_update_perp_bid_ask_twap`: `bool`
  - `padding1`: `[u8; 1]`
  - `fuel_overflow_status`: `u8`
  - `fuel_insurance`: `u32`
  - `fuel_deposits`: `u32`
  - `fuel_borrows`: `u32`
  - `fuel_positions`: `u32`
  - `fuel_taker`: `u32`
  - `fuel_maker`: `u32`
  - `if_staked_gov_token_amount`: `u64`
  - `last_fuel_if_bonus_update_ts`: `u32`
  - `padding`: `[u8; 12]`

## Instructions

### `AddInsuranceFundStake`
- **Discriminator:** `0xfb90730bde2f3eec`
- **Args:**
  - `market_index`: `u16`
  - `amount`: `u64`
- **Account variants:**
  - `10 accounts:` `state`, `spot_market`, `insurance_fund_stake`, `user_stats`, `authority`, `spot_market_vault`, `insurance_fund_vault`, `drift_signer`, `user_token_account`, `token_program`

### `AddPerpLpShares`
- **Discriminator:** `0x38d138c577febc75`
- **Args:**
  - `n_shares`: `u64`
  - `market_index`: `u16`
- **Account variants:**
  - `3 accounts:` `state`, `user`, `authority`

### `AdminDisableUpdatePerpBidAskTwap`
- **Discriminator:** `0x11a4522db756bfc7`
- **Args:**
  - `disable`: `bool`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `user_stats`

### `BeginSwap`
- **Discriminator:** `0xae6de401f269e869`
- **Args:**
  - `in_market_index`: `u16`
  - `out_market_index`: `u16`
  - `amount_in`: `u64`
- **Account variants:**
  - `11 accounts:` `state`, `user`, `user_stats`, `authority`, `out_spot_market_vault`, `in_spot_market_vault`, `out_token_account`, `in_token_account`, `token_program`, `drift_signer`, `instructions`

### `CancelOrder`
- **Discriminator:** `0x5f81edf00831df84`
- **Args:**
  - `order_id`: `Option<u32>`
- **Account variants:**
  - `3 accounts:` `state`, `user`, `authority`

### `CancelOrderByUserId`
- **Discriminator:** `0x6bd3fa8512253964`
- **Args:**
  - `user_order_id`: `u8`
- **Account variants:**
  - `3 accounts:` `state`, `user`, `authority`

### `CancelOrders`
- **Discriminator:** `0xeee15f9ee36708c2`
- **Args:**
  - `market_type`: `Option<MarketType>`
  - `market_index`: `Option<u16>`
  - `direction`: `Option<PositionDirection>`
- **Account variants:**
  - `3 accounts:` `state`, `user`, `authority`

### `CancelOrdersByIds`
- **Discriminator:** `0x861390a55ef0d25e`
- **Args:**
  - `order_ids`: `Vec<u32>`
- **Account variants:**
  - `3 accounts:` `state`, `user`, `authority`

### `CancelRequestRemoveInsuranceFundStake`
- **Discriminator:** `0x61eb4e3ed42af17f`
- **Args:**
  - `market_index`: `u16`
- **Account variants:**
  - `5 accounts:` `spot_market`, `insurance_fund_stake`, `user_stats`, `authority`, `insurance_fund_vault`

### `DeleteInitializedPerpMarket`
- **Discriminator:** `0x5b9a18576a3bbe42`
- **Args:**
  - `market_index`: `u16`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `DeleteInitializedSpotMarket`
- **Discriminator:** `0x1f8c43bfbd1465dd`
- **Args:**
  - `market_index`: `u16`
- **Account variants:**
  - `7 accounts:` `admin`, `state`, `spot_market`, `spot_market_vault`, `insurance_fund_vault`, `drift_signer`, `token_program`

### `DeletePrelaunchOracle`
- **Discriminator:** `0x3ba964314511adfd`
- **Args:**
  - `perp_market_index`: `u16`
- **Account variants:**
  - `4 accounts:` `admin`, `prelaunch_oracle`, `perp_market`, `state`

### `DeleteSignedMsgUserOrders`
- **Discriminator:** `0xddf780fdd4fe2e99`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `signed_msg_user_orders`, `state`, `authority`

### `DeleteUser`
- **Discriminator:** `0xba5511f9dbe762fb`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `user`, `user_stats`, `state`, `authority`

### `Deposit`
- **Discriminator:** `0xf223c68952e1f2b6`
- **Args:**
  - `market_index`: `u16`
  - `amount`: `u64`
  - `reduce_only`: `bool`
- **Account variants:**
  - `7 accounts:` `state`, `user`, `user_stats`, `authority`, `spot_market_vault`, `user_token_account`, `token_program`

### `DepositIntoPerpMarketFeePool`
- **Discriminator:** `0x223a39446150f406`
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `8 accounts:` `state`, `perp_market`, `admin`, `source_vault`, `drift_signer`, `quote_spot_market`, `spot_market_vault`, `token_program`

### `DepositIntoSpotMarketRevenuePool`
- **Discriminator:** `0x5c28972a7afe8bf6`
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `6 accounts:` `state`, `spot_market`, `authority`, `spot_market_vault`, `user_token_account`, `token_program`

### `DepositIntoSpotMarketVault`
- **Discriminator:** `0x30fc7749ffcdaef7`
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `6 accounts:` `state`, `spot_market`, `admin`, `source_vault`, `spot_market_vault`, `token_program`

### `DisableUserHighLeverageMode`
- **Discriminator:** `0xb79b2d00e255d545`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `state`, `authority`, `user`, `high_leverage_mode_config`

### `EnableUserHighLeverageMode`
- **Discriminator:** `0xe718e670c9ad49b8`
- **Args:**
  - `sub_account_id`: `u16`
- **Account variants:**
  - `4 accounts:` `state`, `user`, `authority`, `high_leverage_mode_config`

### `EndSwap`
- **Discriminator:** `0xb1b81bc1220dd291`
- **Args:**
  - `in_market_index`: `u16`
  - `out_market_index`: `u16`
  - `limit_price`: `Option<u64>`
  - `reduce_only`: `Option<SwapReduceOnly>`
- **Account variants:**
  - `11 accounts:` `state`, `user`, `user_stats`, `authority`, `out_spot_market_vault`, `in_spot_market_vault`, `out_token_account`, `in_token_account`, `token_program`, `drift_signer`, `instructions`

### `FillPerpOrder`
- **Discriminator:** `0x0dbcf86786d96af0`
- **Args:**
  - `order_id`: `Option<u32>`
  - `maker_order_id`: `Option<u32>`
- **Account variants:**
  - `6 accounts:` `state`, `authority`, `filler`, `filler_stats`, `user`, `user_stats`

### `FillSpotOrder`
- **Discriminator:** `0xd4ce82ad1522c728`
- **Args:**
  - `order_id`: `Option<u32>`
  - `fulfillment_type`: `Option<SpotFulfillmentType>`
  - `maker_order_id`: `Option<u32>`
- **Account variants:**
  - `6 accounts:` `state`, `authority`, `filler`, `filler_stats`, `user`, `user_stats`

### `ForceCancelOrders`
- **Discriminator:** `0x40b5c43fde4840e8`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `state`, `authority`, `filler`, `user`

### `ForceDeleteUser`
- **Discriminator:** `0x02f1c3ace318fe9e`
- **Args:** (none)
- **Account variants:**
  - `6 accounts:` `user`, `user_stats`, `state`, `authority`, `keeper`, `drift_signer`

### `InitUserFuel`
- **Discriminator:** `0x84bfe48dc98a3c30`
- **Args:**
  - `fuel_boost_deposits`: `Option<i32>`
  - `fuel_boost_borrows`: `Option<u32>`
  - `fuel_boost_taker`: `Option<u32>`
  - `fuel_boost_maker`: `Option<u32>`
  - `fuel_boost_insurance`: `Option<u32>`
- **Account variants:**
  - `4 accounts:` `admin`, `state`, `user`, `user_stats`

### `Initialize`
- **Discriminator:** `0xafaf6d1f0d989bed`
- **Args:** (none)
- **Account variants:**
  - `7 accounts:` `admin`, `state`, `quote_asset_mint`, `drift_signer`, `rent`, `system_program`, `token_program`

### `InitializeFuelOverflow`
- **Discriminator:** `0x58df84a1d0588e2a`
- **Args:** (none)
- **Account variants:**
  - `6 accounts:` `fuel_overflow`, `user_stats`, `authority`, `payer`, `rent`, `system_program`

### `InitializeHighLeverageModeConfig`
- **Discriminator:** `0xd5a75df6d0825af8`
- **Args:**
  - `max_users`: `u32`
- **Account variants:**
  - `5 accounts:` `admin`, `high_leverage_mode_config`, `state`, `rent`, `system_program`

### `InitializeInsuranceFundStake`
- **Discriminator:** `0xbbb3f346f85a5c93`
- **Args:**
  - `market_index`: `u16`
- **Account variants:**
  - `8 accounts:` `spot_market`, `insurance_fund_stake`, `user_stats`, `state`, `authority`, `payer`, `rent`, `system_program`

### `InitializeOpenbookV2FulfillmentConfig`
- **Discriminator:** `0x07dd67996b391bc5`
- **Args:**
  - `market_index`: `u16`
- **Account variants:**
  - `10 accounts:` `base_spot_market`, `quote_spot_market`, `state`, `openbook_v2_program`, `openbook_v2_market`, `drift_signer`, `openbook_v2_fulfillment_config`, `admin`, `rent`, `system_program`

### `InitializePerpMarket`
- **Discriminator:** `0x8409e5767576753e`
- **Args:**
  - `market_index`: `u16`
  - `amm_base_asset_reserve`: `u128`
  - `amm_quote_asset_reserve`: `u128`
  - `amm_periodicity`: `i64`
  - `amm_peg_multiplier`: `u128`
  - `oracle_source`: `OracleSource`
  - `contract_tier`: `ContractTier`
  - `margin_ratio_initial`: `u32`
  - `margin_ratio_maintenance`: `u32`
  - `liquidator_fee`: `u32`
  - `if_liquidation_fee`: `u32`
  - `imf_factor`: `u32`
  - `active_status`: `bool`
  - `base_spread`: `u32`
  - `max_spread`: `u32`
  - `max_open_interest`: `u128`
  - `max_revenue_withdraw_per_period`: `u64`
  - `quote_max_insurance`: `u64`
  - `order_step_size`: `u64`
  - `order_tick_size`: `u64`
  - `min_order_size`: `u64`
  - `concentration_coef_scale`: `u128`
  - `curve_update_intensity`: `u8`
  - `amm_jit_intensity`: `u8`
  - `name`: `[u8; 32]`
- **Account variants:**
  - `6 accounts:` `admin`, `state`, `perp_market`, `oracle`, `rent`, `system_program`

### `InitializePhoenixFulfillmentConfig`
- **Discriminator:** `0x87846e6bb9a0a99a`
- **Args:**
  - `market_index`: `u16`
- **Account variants:**
  - `10 accounts:` `base_spot_market`, `quote_spot_market`, `state`, `phoenix_program`, `phoenix_market`, `drift_signer`, `phoenix_fulfillment_config`, `admin`, `rent`, `system_program`

### `InitializePredictionMarket`
- **Discriminator:** `0xf846c6e0e0697dc3`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `InitializePrelaunchOracle`
- **Discriminator:** `0xa9b25419af3e1df7`
- **Args:**
  - `params`: `PrelaunchOracleParams`
- **Account variants:**
  - `5 accounts:` `admin`, `prelaunch_oracle`, `state`, `rent`, `system_program`

### `InitializeProtectedMakerModeConfig`
- **Discriminator:** `0x4367dc435820fc08`
- **Args:**
  - `max_users`: `u32`
- **Account variants:**
  - `5 accounts:` `admin`, `protected_maker_mode_config`, `state`, `rent`, `system_program`

### `InitializeProtocolIfSharesTransferConfig`
- **Discriminator:** `0x5983efc8b28d6ac2`
- **Args:** (none)
- **Account variants:**
  - `5 accounts:` `admin`, `protocol_if_shares_transfer_config`, `state`, `rent`, `system_program`

### `InitializePythLazerOracle`
- **Discriminator:** `0x8c6b21d6ebdb6714`
- **Args:**
  - `feed_id`: `u32`
- **Account variants:**
  - `5 accounts:` `admin`, `lazer_oracle`, `state`, `rent`, `system_program`

### `InitializePythPullOracle`
- **Discriminator:** `0xf98cfdf3f84af0ee`
- **Args:**
  - `feed_id`: `[u8; 32]`
- **Account variants:**
  - `5 accounts:` `admin`, `pyth_solana_receiver`, `price_feed`, `system_program`, `state`

### `InitializeReferrerName`
- **Discriminator:** `0xeb7ee70a2aa41a3d`
- **Args:**
  - `name`: `[u8; 32]`
- **Account variants:**
  - `7 accounts:` `referrer_name`, `user`, `user_stats`, `authority`, `payer`, `rent`, `system_program`

### `InitializeSerumFulfillmentConfig`
- **Discriminator:** `0xc1d384ac46ab075e`
- **Args:**
  - `market_index`: `u16`
- **Account variants:**
  - `11 accounts:` `base_spot_market`, `quote_spot_market`, `state`, `serum_program`, `serum_market`, `serum_open_orders`, `drift_signer`, `serum_fulfillment_config`, `admin`, `rent`, `system_program`

### `InitializeSignedMsgUserOrders`
- **Discriminator:** `0xa4639c7e9c3963b4`
- **Args:**
  - `num_orders`: `u16`
- **Account variants:**
  - `5 accounts:` `signed_msg_user_orders`, `authority`, `payer`, `rent`, `system_program`

### `InitializeSpotMarket`
- **Discriminator:** `0xeac4802c5e0f30c9`
- **Args:**
  - `optimal_utilization`: `u32`
  - `optimal_borrow_rate`: `u32`
  - `max_borrow_rate`: `u32`
  - `oracle_source`: `OracleSource`
  - `initial_asset_weight`: `u32`
  - `maintenance_asset_weight`: `u32`
  - `initial_liability_weight`: `u32`
  - `maintenance_liability_weight`: `u32`
  - `imf_factor`: `u32`
  - `liquidator_fee`: `u32`
  - `if_liquidation_fee`: `u32`
  - `active_status`: `bool`
  - `asset_tier`: `AssetTier`
  - `scale_initial_asset_weight_start`: `u64`
  - `withdraw_guard_threshold`: `u64`
  - `order_tick_size`: `u64`
  - `order_step_size`: `u64`
  - `if_total_factor`: `u32`
  - `name`: `[u8; 32]`
- **Account variants:**
  - `11 accounts:` `spot_market`, `spot_market_mint`, `spot_market_vault`, `insurance_fund_vault`, `drift_signer`, `state`, `oracle`, `admin`, `rent`, `system_program`, `token_program`

### `InitializeUser`
- **Discriminator:** `0x6f11b9fa3c7a26fe`
- **Args:**
  - `sub_account_id`: `u16`
  - `name`: `[u8; 32]`
- **Account variants:**
  - `7 accounts:` `user`, `user_stats`, `state`, `authority`, `payer`, `rent`, `system_program`

### `InitializeUserStats`
- **Discriminator:** `0xfef34862fb82a8d5`
- **Args:** (none)
- **Account variants:**
  - `6 accounts:` `user_stats`, `state`, `authority`, `payer`, `rent`, `system_program`

### `LiquidateBorrowForPerpPnl`
- **Discriminator:** `0xa911205acf94d11b`
- **Args:**
  - `perp_market_index`: `u16`
  - `spot_market_index`: `u16`
  - `liquidator_max_liability_transfer`: `u128`
  - `limit_price`: `Option<u64>`
- **Account variants:**
  - `6 accounts:` `state`, `authority`, `liquidator`, `liquidator_stats`, `user`, `user_stats`

### `LiquidatePerp`
- **Discriminator:** `0x4b2377f7bf128b02`
- **Args:**
  - `market_index`: `u16`
  - `liquidator_max_base_asset_amount`: `u64`
  - `limit_price`: `Option<u64>`
- **Account variants:**
  - `6 accounts:` `state`, `authority`, `liquidator`, `liquidator_stats`, `user`, `user_stats`

### `LiquidatePerpPnlForDeposit`
- **Discriminator:** `0xed4bc6ebe9ba4b23`
- **Args:**
  - `perp_market_index`: `u16`
  - `spot_market_index`: `u16`
  - `liquidator_max_pnl_transfer`: `u128`
  - `limit_price`: `Option<u64>`
- **Account variants:**
  - `6 accounts:` `state`, `authority`, `liquidator`, `liquidator_stats`, `user`, `user_stats`

### `LiquidatePerpWithFill`
- **Discriminator:** `0x5f6f7c6956a9bb22`
- **Args:**
  - `market_index`: `u16`
- **Account variants:**
  - `6 accounts:` `state`, `authority`, `liquidator`, `liquidator_stats`, `user`, `user_stats`

### `LiquidateSpot`
- **Discriminator:** `0x6b00802923e5fb12`
- **Args:**
  - `asset_market_index`: `u16`
  - `liability_market_index`: `u16`
  - `liquidator_max_liability_transfer`: `u128`
  - `limit_price`: `Option<u64>`
- **Account variants:**
  - `6 accounts:` `state`, `authority`, `liquidator`, `liquidator_stats`, `user`, `user_stats`

### `LiquidateSpotWithSwapBegin`
- **Discriminator:** `0x0c2bb0539cfb750d`
- **Args:**
  - `asset_market_index`: `u16`
  - `liability_market_index`: `u16`
  - `swap_amount`: `u64`
- **Account variants:**
  - `13 accounts:` `state`, `authority`, `liquidator`, `liquidator_stats`, `user`, `user_stats`, `liability_spot_market_vault`, `asset_spot_market_vault`, `liability_token_account`, `asset_token_account`, `token_program`, `drift_signer`, `instructions`

### `LiquidateSpotWithSwapEnd`
- **Discriminator:** `0x8e58a3a0df4b37e1`
- **Args:**
  - `asset_market_index`: `u16`
  - `liability_market_index`: `u16`
- **Account variants:**
  - `13 accounts:` `state`, `authority`, `liquidator`, `liquidator_stats`, `user`, `user_stats`, `liability_spot_market_vault`, `asset_spot_market_vault`, `liability_token_account`, `asset_token_account`, `token_program`, `drift_signer`, `instructions`

### `LogUserBalances`
- **Discriminator:** `0xa21523fb2039a1d2`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `state`, `authority`, `user`

### `ModifyOrder`
- **Discriminator:** `0x2f7c75ffc9c5825e`
- **Args:**
  - `order_id`: `Option<u32>`
  - `modify_order_params`: `ModifyOrderParams`
- **Account variants:**
  - `3 accounts:` `state`, `user`, `authority`

### `ModifyOrderByUserId`
- **Discriminator:** `0x9e4d04fdfcc2a1b3`
- **Args:**
  - `user_order_id`: `u8`
  - `modify_order_params`: `ModifyOrderParams`
- **Account variants:**
  - `3 accounts:` `state`, `user`, `authority`

### `MoveAmmPrice`
- **Discriminator:** `0xeb6d0252db76069f`
- **Args:**
  - `base_asset_reserve`: `u128`
  - `quote_asset_reserve`: `u128`
  - `sqrt_k`: `u128`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `OpenbookV2FulfillmentConfigStatus`
- **Discriminator:** `0x19ad13bd04d340ee`
- **Args:**
  - `status`: `SpotFulfillmentConfigStatus`
- **Account variants:**
  - `3 accounts:` `state`, `openbook_v2_fulfillment_config`, `admin`

### `PauseSpotMarketDepositWithdraw`
- **Discriminator:** `0xb7773baa8923f256`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `state`, `keeper`, `spot_market`, `spot_market_vault`

### `PhoenixFulfillmentConfigStatus`
- **Discriminator:** `0x601f71200ccb079a`
- **Args:**
  - `status`: `SpotFulfillmentConfigStatus`
- **Account variants:**
  - `3 accounts:` `state`, `phoenix_fulfillment_config`, `admin`

### `PlaceAndMakePerpOrder`
- **Discriminator:** `0x95750bed2f5f59ed`
- **Args:**
  - `params`: `OrderParams`
  - `taker_order_id`: `u32`
- **Account variants:**
  - `6 accounts:` `state`, `user`, `user_stats`, `taker`, `taker_stats`, `authority`

### `PlaceAndMakeSignedMsgPerpOrder`
- **Discriminator:** `0x101a7b835e1daf62`
- **Args:**
  - `params`: `OrderParams`
  - `signed_msg_order_uuid`: `[u8; 8]`
- **Account variants:**
  - `7 accounts:` `state`, `user`, `user_stats`, `taker`, `taker_stats`, `taker_signed_msg_user_orders`, `authority`

### `PlaceAndMakeSpotOrder`
- **Discriminator:** `0x959e5542ef09f362`
- **Args:**
  - `params`: `OrderParams`
  - `taker_order_id`: `u32`
  - `fulfillment_type`: `Option<SpotFulfillmentType>`
- **Account variants:**
  - `6 accounts:` `state`, `user`, `user_stats`, `taker`, `taker_stats`, `authority`

### `PlaceAndTakePerpOrder`
- **Discriminator:** `0xd53301bb6cdce6e0`
- **Args:**
  - `params`: `OrderParams`
  - `success_condition`: `Option<u32>`
- **Account variants:**
  - `4 accounts:` `state`, `user`, `user_stats`, `authority`

### `PlaceAndTakeSpotOrder`
- **Discriminator:** `0xbf038a4772c6ca64`
- **Args:**
  - `params`: `OrderParams`
  - `fulfillment_type`: `Option<SpotFulfillmentType>`
  - `maker_order_id`: `Option<u32>`
- **Account variants:**
  - `4 accounts:` `state`, `user`, `user_stats`, `authority`

### `PlaceOrders`
- **Discriminator:** `0x3c3f327b0cc53cbe`
- **Args:**
  - `params`: `Vec<OrderParams>`
- **Account variants:**
  - `3 accounts:` `state`, `user`, `authority`

### `PlacePerpOrder`
- **Discriminator:** `0x45a15dca787e4cb9`
- **Args:**
  - `params`: `OrderParams`
- **Account variants:**
  - `3 accounts:` `state`, `user`, `authority`

### `PlaceSignedMsgTakerOrder`
- **Discriminator:** `0x204f658b1906620f`
- **Args:**
  - `signed_msg_order_params_message_bytes`: `Vec<u8>`
  - `is_delegate_signer`: `bool`
- **Account variants:**
  - `6 accounts:` `state`, `user`, `user_stats`, `signed_msg_user_orders`, `authority`, `ix_sysvar`

### `PlaceSpotOrder`
- **Discriminator:** `0x2d4f51a0f85a5bdc`
- **Args:**
  - `params`: `OrderParams`
- **Account variants:**
  - `3 accounts:` `state`, `user`, `authority`

### `PostMultiPythPullOracleUpdatesAtomic`
- **Discriminator:** `0xf34fcce4e3d064f4`
- **Args:**
  - `params`: `Vec<u8>`
- **Account variants:**
  - `3 accounts:` `keeper`, `pyth_solana_receiver`, `guardian_set`

### `PostPythLazerOracleUpdate`
- **Discriminator:** `0xdaedaaf5278fa621`
- **Args:**
  - `pyth_message`: `Vec<u8>`
- **Account variants:**
  - `3 accounts:` `keeper`, `pyth_lazer_storage`, `ix_sysvar`

### `PostPythPullOracleUpdateAtomic`
- **Discriminator:** `0x747a899ee0c3ad77`
- **Args:**
  - `feed_id`: `[u8; 32]`
  - `params`: `Vec<u8>`
- **Account variants:**
  - `4 accounts:` `keeper`, `pyth_solana_receiver`, `guardian_set`, `price_feed`

### `RecenterPerpMarketAmm`
- **Discriminator:** `0x18570a73a5be508b`
- **Args:**
  - `peg_multiplier`: `u128`
  - `sqrt_k`: `u128`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `ReclaimRent`
- **Discriminator:** `0xdac813c5e359c016`
- **Args:** (none)
- **Account variants:**
  - `5 accounts:` `user`, `user_stats`, `state`, `authority`, `rent`

### `RemoveInsuranceFundStake`
- **Discriminator:** `0x80a68e09febb8fae`
- **Args:**
  - `market_index`: `u16`
- **Account variants:**
  - `9 accounts:` `state`, `spot_market`, `insurance_fund_stake`, `user_stats`, `authority`, `insurance_fund_vault`, `drift_signer`, `user_token_account`, `token_program`

### `RemovePerpLpShares`
- **Discriminator:** `0xd559d912a037358d`
- **Args:**
  - `shares_to_burn`: `u64`
  - `market_index`: `u16`
- **Account variants:**
  - `3 accounts:` `state`, `user`, `authority`

### `RemovePerpLpSharesInExpiringMarket`
- **Discriminator:** `0x53fefd893b7a449c`
- **Args:**
  - `shares_to_burn`: `u64`
  - `market_index`: `u16`
- **Account variants:**
  - `2 accounts:` `state`, `user`

### `RepegAmmCurve`
- **Discriminator:** `0x03246659b48078d5`
- **Args:**
  - `new_peg_candidate`: `u128`
- **Account variants:**
  - `4 accounts:` `state`, `perp_market`, `oracle`, `admin`

### `RequestRemoveInsuranceFundStake`
- **Discriminator:** `0x8e46cc5c496ab434`
- **Args:**
  - `market_index`: `u16`
  - `amount`: `u64`
- **Account variants:**
  - `5 accounts:` `spot_market`, `insurance_fund_stake`, `user_stats`, `authority`, `insurance_fund_vault`

### `ResetFuelSeason`
- **Discriminator:** `0xc77ac0ff20633fc8`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `user_stats`, `authority`, `state`, `admin`

### `ResetPerpMarketAmmOracleTwap`
- **Discriminator:** `0x7f0a37a47be22f18`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `state`, `perp_market`, `oracle`, `admin`

### `ResizeSignedMsgUserOrders`
- **Discriminator:** `0x890a579612734fa8`
- **Args:**
  - `num_orders`: `u16`
- **Account variants:**
  - `3 accounts:` `signed_msg_user_orders`, `authority`, `system_program`

### `ResolvePerpBankruptcy`
- **Discriminator:** `0xe010b0d6a2d5b7de`
- **Args:**
  - `quote_spot_market_index`: `u16`
  - `market_index`: `u16`
- **Account variants:**
  - `10 accounts:` `state`, `authority`, `liquidator`, `liquidator_stats`, `user`, `user_stats`, `spot_market_vault`, `insurance_fund_vault`, `drift_signer`, `token_program`

### `ResolvePerpPnlDeficit`
- **Discriminator:** `0xa8cc44969f7e5f94`
- **Args:**
  - `spot_market_index`: `u16`
  - `perp_market_index`: `u16`
- **Account variants:**
  - `6 accounts:` `state`, `authority`, `spot_market_vault`, `insurance_fund_vault`, `drift_signer`, `token_program`

### `ResolveSpotBankruptcy`
- **Discriminator:** `0x7cc2f0fec6d5347a`
- **Args:**
  - `market_index`: `u16`
- **Account variants:**
  - `10 accounts:` `state`, `authority`, `liquidator`, `liquidator_stats`, `user`, `user_stats`, `spot_market_vault`, `insurance_fund_vault`, `drift_signer`, `token_program`

### `RevertFill`
- **Discriminator:** `0xeceeb045ef0ab5c1`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `state`, `authority`, `filler`, `filler_stats`

### `SetUserStatusToBeingLiquidated`
- **Discriminator:** `0x6a85a0cec1abc0c2`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `state`, `user`, `authority`

### `SettleExpiredMarket`
- **Discriminator:** `0x78590b197a4d48c1`
- **Args:**
  - `market_index`: `u16`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `SettleExpiredMarketPoolsToRevenuePool`
- **Discriminator:** `0x3713eea9e35ac8b8`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `state`, `admin`, `spot_market`, `perp_market`

### `SettleFundingPayment`
- **Discriminator:** `0xde5aca5e1c2d73b7`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `state`, `user`

### `SettleLp`
- **Discriminator:** `0x9be7747161e58b8d`
- **Args:**
  - `market_index`: `u16`
- **Account variants:**
  - `2 accounts:` `state`, `user`

### `SettleMultiplePnls`
- **Discriminator:** `0x7f4275392832987f`
- **Args:**
  - `market_indexes`: `Vec<u16>`
  - `mode`: `SettlePnlMode`
- **Account variants:**
  - `4 accounts:` `state`, `user`, `authority`, `spot_market_vault`

### `SettlePnl`
- **Discriminator:** `0x2b3dea2d0f5f9899`
- **Args:**
  - `market_index`: `u16`
- **Account variants:**
  - `4 accounts:` `state`, `user`, `authority`, `spot_market_vault`

### `SettleRevenueToInsuranceFund`
- **Discriminator:** `0xc8785d884526c79f`
- **Args:**
  - `spot_market_index`: `u16`
- **Account variants:**
  - `6 accounts:` `state`, `spot_market`, `spot_market_vault`, `drift_signer`, `insurance_fund_vault`, `token_program`

### `SweepFuel`
- **Discriminator:** `0xaf6b1338a5f12b45`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `fuel_overflow`, `user_stats`, `authority`, `signer`

### `TransferDeposit`
- **Discriminator:** `0x141493df293fcc6f`
- **Args:**
  - `market_index`: `u16`
  - `amount`: `u64`
- **Account variants:**
  - `6 accounts:` `from_user`, `to_user`, `user_stats`, `authority`, `state`, `spot_market_vault`

### `TransferPools`
- **Discriminator:** `0xc5679a196b5a3c5e`
- **Args:**
  - `deposit_from_market_index`: `u16`
  - `deposit_to_market_index`: `u16`
  - `borrow_from_market_index`: `u16`
  - `borrow_to_market_index`: `u16`
  - `deposit_amount`: `Option<u64>`
  - `borrow_amount`: `Option<u64>`
- **Account variants:**
  - `10 accounts:` `from_user`, `to_user`, `user_stats`, `authority`, `state`, `deposit_from_spot_market_vault`, `deposit_to_spot_market_vault`, `borrow_from_spot_market_vault`, `borrow_to_spot_market_vault`, `drift_signer`

### `TransferProtocolIfShares`
- **Discriminator:** `0x5e5de2f0c3c9b86d`
- **Args:**
  - `market_index`: `u16`
  - `shares`: `u128`
- **Account variants:**
  - `8 accounts:` `signer`, `transfer_config`, `state`, `spot_market`, `insurance_fund_stake`, `user_stats`, `authority`, `insurance_fund_vault`

### `TriggerOrder`
- **Discriminator:** `0x3f7033e9e82ff0c7`
- **Args:**
  - `order_id`: `u32`
- **Account variants:**
  - `4 accounts:` `state`, `authority`, `filler`, `user`

### `UpdateAdmin`
- **Discriminator:** `0xa1b028d53cb8b3e4`
- **Args:**
  - `admin`: `Pubkey`
- **Account variants:**
  - `2 accounts:` `admin`, `state`

### `UpdateAmmJitIntensity`
- **Discriminator:** `0xb5bf356da6f9378e`
- **Args:**
  - `amm_jit_intensity`: `u8`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `UpdateAmms`
- **Discriminator:** `0xc96ad9fd04afe461`
- **Args:**
  - `market_indexes`: `[u16; 5]`
- **Account variants:**
  - `2 accounts:` `state`, `authority`

### `UpdateDiscountMint`
- **Discriminator:** `0x20fc7ad3421f2ff1`
- **Args:**
  - `discount_mint`: `Pubkey`
- **Account variants:**
  - `2 accounts:` `admin`, `state`

### `UpdateExchangeStatus`
- **Discriminator:** `0x53a0fcfa817431df`
- **Args:**
  - `exchange_status`: `u8`
- **Account variants:**
  - `2 accounts:` `admin`, `state`

### `UpdateFundingRate`
- **Discriminator:** `0xc9b274d4a69048ee`
- **Args:**
  - `market_index`: `u16`
- **Account variants:**
  - `3 accounts:` `state`, `perp_market`, `oracle`

### `UpdateHighLeverageModeConfig`
- **Discriminator:** `0x407ad45d8dd9ca37`
- **Args:**
  - `max_users`: `u32`
  - `reduce_only`: `bool`
- **Account variants:**
  - `3 accounts:` `admin`, `high_leverage_mode_config`, `state`

### `UpdateInitialPctToLiquidate`
- **Discriminator:** `0xd285e180c2320d6d`
- **Args:**
  - `initial_pct_to_liquidate`: `u16`
- **Account variants:**
  - `2 accounts:` `admin`, `state`

### `UpdateInsuranceFundUnstakingPeriod`
- **Discriminator:** `0x2c452be2ccdfca34`
- **Args:**
  - `insurance_fund_unstaking_period`: `i64`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `spot_market`

### `UpdateK`
- **Discriminator:** `0x4862098b81e5ac38`
- **Args:**
  - `sqrt_k`: `u128`
- **Account variants:**
  - `4 accounts:` `admin`, `state`, `perp_market`, `oracle`

### `UpdateLiquidationDuration`
- **Discriminator:** `0x1c9a14f966c04947`
- **Args:**
  - `liquidation_duration`: `u8`
- **Account variants:**
  - `2 accounts:` `admin`, `state`

### `UpdateLiquidationMarginBufferRatio`
- **Discriminator:** `0x84e0f3a09a5261d7`
- **Args:**
  - `liquidation_margin_buffer_ratio`: `u32`
- **Account variants:**
  - `2 accounts:` `admin`, `state`

### `UpdateLpCooldownTime`
- **Discriminator:** `0xc6855829f1773d0e`
- **Args:**
  - `lp_cooldown_time`: `u64`
- **Account variants:**
  - `2 accounts:` `admin`, `state`

### `UpdateOracleGuardRails`
- **Discriminator:** `0x83700a3b203628a4`
- **Args:**
  - `oracle_guard_rails`: `OracleGuardRails`
- **Account variants:**
  - `2 accounts:` `admin`, `state`

### `UpdatePerpAuctionDuration`
- **Discriminator:** `0x7e6e34ae1eced75a`
- **Args:**
  - `min_perp_auction_duration`: `u8`
- **Account variants:**
  - `2 accounts:` `admin`, `state`

### `UpdatePerpBidAskTwap`
- **Discriminator:** `0xf717ff41d45addc2`
- **Args:** (none)
- **Account variants:**
  - `5 accounts:` `state`, `perp_market`, `oracle`, `keeper_stats`, `authority`

### `UpdatePerpFeeStructure`
- **Discriminator:** `0x17b26fcb49168c4b`
- **Args:**
  - `fee_structure`: `FeeStructure`
- **Account variants:**
  - `2 accounts:` `admin`, `state`

### `UpdatePerpMarketAmmOracleTwap`
- **Discriminator:** `0xf14a727bce9918ca`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `state`, `perp_market`, `oracle`, `admin`

### `UpdatePerpMarketAmmSummaryStats`
- **Discriminator:** `0x7a65f9eed109f1f5`
- **Args:**
  - `params`: `UpdatePerpMarketSummaryStatsParams`
- **Account variants:**
  - `5 accounts:` `admin`, `state`, `perp_market`, `spot_market`, `oracle`

### `UpdatePerpMarketBaseSpread`
- **Discriminator:** `0x475f54a8099dc641`
- **Args:**
  - `base_spread`: `u32`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `UpdatePerpMarketConcentrationCoef`
- **Discriminator:** `0x184ee87ea9b0e610`
- **Args:**
  - `concentration_scale`: `u128`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `UpdatePerpMarketContractTier`
- **Discriminator:** `0xec800f5fcbd64475`
- **Args:**
  - `contract_tier`: `ContractTier`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `UpdatePerpMarketCurveUpdateIntensity`
- **Discriminator:** `0x3283069ce2e7bd48`
- **Args:**
  - `curve_update_intensity`: `u8`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `UpdatePerpMarketExpiry`
- **Discriminator:** `0x2cdde397838c166e`
- **Args:**
  - `expiry_ts`: `i64`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `UpdatePerpMarketFeeAdjustment`
- **Discriminator:** `0xc2ae57662b942070`
- **Args:**
  - `fee_adjustment`: `i16`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `UpdatePerpMarketFuel`
- **Discriminator:** `0xfc8d6e651b63b615`
- **Args:**
  - `fuel_boost_taker`: `Option<u8>`
  - `fuel_boost_maker`: `Option<u8>`
  - `fuel_boost_position`: `Option<u8>`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `UpdatePerpMarketFundingPeriod`
- **Discriminator:** `0xaba1455b818ba11c`
- **Args:**
  - `funding_period`: `i64`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `UpdatePerpMarketHighLeverageMarginRatio`
- **Discriminator:** `0x5870563118744a9d`
- **Args:**
  - `margin_ratio_initial`: `u16`
  - `margin_ratio_maintenance`: `u16`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `UpdatePerpMarketImfFactor`
- **Discriminator:** `0xcfc23884234347f4`
- **Args:**
  - `imf_factor`: `u32`
  - `unrealized_pnl_imf_factor`: `u32`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `UpdatePerpMarketLiquidationFee`
- **Discriminator:** `0x5a89099129089475`
- **Args:**
  - `liquidator_fee`: `u32`
  - `if_liquidation_fee`: `u32`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `UpdatePerpMarketMarginRatio`
- **Discriminator:** `0x82ad6b2d77691a71`
- **Args:**
  - `margin_ratio_initial`: `u32`
  - `margin_ratio_maintenance`: `u32`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `UpdatePerpMarketMaxFillReserveFraction`
- **Discriminator:** `0x13ac729a2a87a185`
- **Args:**
  - `max_fill_reserve_fraction`: `u16`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `UpdatePerpMarketMaxImbalances`
- **Discriminator:** `0x0fce49853c085659`
- **Args:**
  - `unrealized_max_imbalance`: `u64`
  - `max_revenue_withdraw_per_period`: `u64`
  - `quote_max_insurance`: `u64`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `UpdatePerpMarketMaxOpenInterest`
- **Discriminator:** `0xc24f95e0f666ba8c`
- **Args:**
  - `max_open_interest`: `u128`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `UpdatePerpMarketMaxSlippageRatio`
- **Discriminator:** `0xeb2528c4469236c9`
- **Args:**
  - `max_slippage_ratio`: `u16`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `UpdatePerpMarketMaxSpread`
- **Discriminator:** `0x50fc7a3e28da5b64`
- **Args:**
  - `max_spread`: `u32`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `UpdatePerpMarketMinOrderSize`
- **Discriminator:** `0xe24a05596cdf2e8d`
- **Args:**
  - `order_size`: `u64`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `UpdatePerpMarketName`
- **Discriminator:** `0xd31f15d2406c42c9`
- **Args:**
  - `name`: `[u8; 32]`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `UpdatePerpMarketNumberOfUsers`
- **Discriminator:** `0x233e90b1b43ed7c4`
- **Args:**
  - `number_of_users`: `Option<u32>`
  - `number_of_users_with_base`: `Option<u32>`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `UpdatePerpMarketOracle`
- **Discriminator:** `0xb6716fa043ae59bf`
- **Args:**
  - `oracle`: `Pubkey`
  - `oracle_source`: `OracleSource`
  - `skip_invariant_check`: `bool`
- **Account variants:**
  - `5 accounts:` `admin`, `state`, `perp_market`, `oracle`, `old_oracle`

### `UpdatePerpMarketPausedOperations`
- **Discriminator:** `0x351088841edc7955`
- **Args:**
  - `paused_operations`: `u8`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `UpdatePerpMarketPerLpBase`
- **Discriminator:** `0x679867665990c147`
- **Args:**
  - `per_lp_base`: `i8`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `UpdatePerpMarketStatus`
- **Discriminator:** `0x47c9af7affcfc4cf`
- **Args:**
  - `status`: `MarketStatus`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `UpdatePerpMarketStepSizeAndTickSize`
- **Discriminator:** `0xe7ff6119928bae04`
- **Args:**
  - `step_size`: `u64`
  - `tick_size`: `u64`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `UpdatePerpMarketTargetBaseAssetAmountPerLp`
- **Discriminator:** `0x3e5744731d9696a5`
- **Args:**
  - `target_base_asset_amount_per_lp`: `i32`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `UpdatePerpMarketUnrealizedAssetWeight`
- **Discriminator:** `0x8784cda56d96a66a`
- **Args:**
  - `unrealized_initial_asset_weight`: `u32`
  - `unrealized_maintenance_asset_weight`: `u32`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `perp_market`

### `UpdatePrelaunchOracle`
- **Discriminator:** `0xdc841b1be9dc3ddb`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `state`, `perp_market`, `oracle`

### `UpdatePrelaunchOracleParams`
- **Discriminator:** `0x62cd93f3124b53cf`
- **Args:**
  - `params`: `PrelaunchOracleParams`
- **Account variants:**
  - `4 accounts:` `admin`, `prelaunch_oracle`, `perp_market`, `state`

### `UpdateProtectedMakerModeConfig`
- **Discriminator:** `0x56a6ebfd43cadf11`
- **Args:**
  - `max_users`: `u32`
  - `reduce_only`: `bool`
- **Account variants:**
  - `3 accounts:` `admin`, `protected_maker_mode_config`, `state`

### `UpdateProtocolIfSharesTransferConfig`
- **Discriminator:** `0x22872f5bdc18d435`
- **Args:**
  - `whitelisted_signers`: `Option<[Pubkey; 4]>`
  - `max_transfer_per_epoch`: `Option<u128>`
- **Account variants:**
  - `3 accounts:` `admin`, `protocol_if_shares_transfer_config`, `state`

### `UpdatePythPullOracle`
- **Discriminator:** `0xe6bfbd5e6c3b4ac5`
- **Args:**
  - `feed_id`: `[u8; 32]`
  - `params`: `Vec<u8>`
- **Account variants:**
  - `4 accounts:` `keeper`, `pyth_solana_receiver`, `encoded_vaa`, `price_feed`

### `UpdateSerumFulfillmentConfigStatus`
- **Discriminator:** `0xab6df0fb5f019559`
- **Args:**
  - `status`: `SpotFulfillmentConfigStatus`
- **Account variants:**
  - `3 accounts:` `state`, `serum_fulfillment_config`, `admin`

### `UpdateSerumVault`
- **Discriminator:** `0xdb08f660a9795b6e`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `state`, `admin`, `srm_vault`

### `UpdateSpotAuctionDuration`
- **Discriminator:** `0xb6b2cb48bb8f9d6b`
- **Args:**
  - `default_spot_auction_duration`: `u8`
- **Account variants:**
  - `2 accounts:` `admin`, `state`

### `UpdateSpotFeeStructure`
- **Discriminator:** `0x61d8698371f68e8d`
- **Args:**
  - `fee_structure`: `FeeStructure`
- **Account variants:**
  - `2 accounts:` `admin`, `state`

### `UpdateSpotMarketAssetTier`
- **Discriminator:** `0xfdd1e70ef2d0f382`
- **Args:**
  - `asset_tier`: `AssetTier`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `spot_market`

### `UpdateSpotMarketBorrowRate`
- **Discriminator:** `0x47efec99d23efe4c`
- **Args:**
  - `optimal_utilization`: `u32`
  - `optimal_borrow_rate`: `u32`
  - `max_borrow_rate`: `u32`
  - `min_borrow_rate`: `Option<u8>`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `spot_market`

### `UpdateSpotMarketCumulativeInterest`
- **Discriminator:** `0x27a68bf39ea59be1`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `state`, `spot_market`, `oracle`, `spot_market_vault`

### `UpdateSpotMarketExpiry`
- **Discriminator:** `0xd00bd39fe2180bf7`
- **Args:**
  - `expiry_ts`: `i64`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `spot_market`

### `UpdateSpotMarketFeeAdjustment`
- **Discriminator:** `0x94b6037e9d72dc63`
- **Args:**
  - `fee_adjustment`: `i16`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `spot_market`

### `UpdateSpotMarketFuel`
- **Discriminator:** `0xe2fd4c471102aba9`
- **Args:**
  - `fuel_boost_deposits`: `Option<u8>`
  - `fuel_boost_borrows`: `Option<u8>`
  - `fuel_boost_taker`: `Option<u8>`
  - `fuel_boost_maker`: `Option<u8>`
  - `fuel_boost_insurance`: `Option<u8>`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `spot_market`

### `UpdateSpotMarketIfFactor`
- **Discriminator:** `0x931ee02212e66904`
- **Args:**
  - `spot_market_index`: `u16`
  - `user_if_factor`: `u32`
  - `total_if_factor`: `u32`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `spot_market`

### `UpdateSpotMarketIfPausedOperations`
- **Discriminator:** `0x65d74f4a3b294f0c`
- **Args:**
  - `paused_operations`: `u8`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `spot_market`

### `UpdateSpotMarketLiquidationFee`
- **Discriminator:** `0x0b0dff35388868b1`
- **Args:**
  - `liquidator_fee`: `u32`
  - `if_liquidation_fee`: `u32`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `spot_market`

### `UpdateSpotMarketMarginWeights`
- **Discriminator:** `0x6d2157c3ff240651`
- **Args:**
  - `initial_asset_weight`: `u32`
  - `maintenance_asset_weight`: `u32`
  - `initial_liability_weight`: `u32`
  - `maintenance_liability_weight`: `u32`
  - `imf_factor`: `u32`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `spot_market`

### `UpdateSpotMarketMaxTokenBorrows`
- **Discriminator:** `0x3966ccd4fd5f0dc7`
- **Args:**
  - `max_token_borrows_fraction`: `u16`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `spot_market`

### `UpdateSpotMarketMaxTokenDeposits`
- **Discriminator:** `0x38bf4f121a7950d0`
- **Args:**
  - `max_token_deposits`: `u64`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `spot_market`

### `UpdateSpotMarketMinOrderSize`
- **Discriminator:** `0x5d800b771a14b532`
- **Args:**
  - `order_size`: `u64`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `spot_market`

### `UpdateSpotMarketName`
- **Discriminator:** `0x11d00101a2d3bce0`
- **Args:**
  - `name`: `[u8; 32]`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `spot_market`

### `UpdateSpotMarketOracle`
- **Discriminator:** `0x72b86625f6bab463`
- **Args:**
  - `oracle`: `Pubkey`
  - `oracle_source`: `OracleSource`
  - `skip_invariant_check`: `bool`
- **Account variants:**
  - `5 accounts:` `admin`, `state`, `spot_market`, `oracle`, `old_oracle`

### `UpdateSpotMarketOrdersEnabled`
- **Discriminator:** `0xbe4fce0f1ae5e52b`
- **Args:**
  - `orders_enabled`: `bool`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `spot_market`

### `UpdateSpotMarketPausedOperations`
- **Discriminator:** `0x643d9951b40c06f8`
- **Args:**
  - `paused_operations`: `u8`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `spot_market`

### `UpdateSpotMarketPoolId`
- **Discriminator:** `0x16d5c5a08bc15195`
- **Args:**
  - `pool_id`: `u8`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `spot_market`

### `UpdateSpotMarketRevenueSettlePeriod`
- **Discriminator:** `0x515c7e29fae19cdb`
- **Args:**
  - `revenue_settle_period`: `i64`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `spot_market`

### `UpdateSpotMarketScaleInitialAssetWeightStart`
- **Discriminator:** `0xd9cccc76cc82e193`
- **Args:**
  - `scale_initial_asset_weight_start`: `u64`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `spot_market`

### `UpdateSpotMarketStatus`
- **Discriminator:** `0x4e5e10bcc16ee71f`
- **Args:**
  - `status`: `MarketStatus`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `spot_market`

### `UpdateSpotMarketStepSizeAndTickSize`
- **Discriminator:** `0xee998950ce3bfa3d`
- **Args:**
  - `step_size`: `u64`
  - `tick_size`: `u64`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `spot_market`

### `UpdateStateMaxInitializeUserFee`
- **Discriminator:** `0xede119edc12d4d61`
- **Args:**
  - `max_initialize_user_fee`: `u16`
- **Account variants:**
  - `2 accounts:` `admin`, `state`

### `UpdateStateMaxNumberOfSubAccounts`
- **Discriminator:** `0x9b7bd602dda6cc55`
- **Args:**
  - `max_number_of_sub_accounts`: `u16`
- **Account variants:**
  - `2 accounts:` `admin`, `state`

### `UpdateStateSettlementDuration`
- **Discriminator:** `0x6144c7eb83503dad`
- **Args:**
  - `settlement_duration`: `u16`
- **Account variants:**
  - `2 accounts:` `admin`, `state`

### `UpdateUserAdvancedLp`
- **Discriminator:** `0x42506bba1bf2425f`
- **Args:**
  - `sub_account_id`: `u16`
  - `advanced_lp`: `bool`
- **Account variants:**
  - `2 accounts:` `user`, `authority`

### `UpdateUserCustomMarginRatio`
- **Discriminator:** `0x15dd8cbb20810b7b`
- **Args:**
  - `sub_account_id`: `u16`
  - `margin_ratio`: `u32`
- **Account variants:**
  - `2 accounts:` `user`, `authority`

### `UpdateUserDelegate`
- **Discriminator:** `0x8bcd8d8d71245ebb`
- **Args:**
  - `sub_account_id`: `u16`
  - `delegate`: `Pubkey`
- **Account variants:**
  - `2 accounts:` `user`, `authority`

### `UpdateUserFuelBonus`
- **Discriminator:** `0x58afc9bede648f39`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `state`, `authority`, `user`, `user_stats`

### `UpdateUserGovTokenInsuranceStake`
- **Discriminator:** `0x8f63ebbb149fb854`
- **Args:** (none)
- **Account variants:**
  - `6 accounts:` `state`, `spot_market`, `insurance_fund_stake`, `user_stats`, `signer`, `insurance_fund_vault`

### `UpdateUserGovTokenInsuranceStakeDevnet`
- **Discriminator:** `0x81b9f3b7e46f40af`
- **Args:**
  - `gov_stake_amount`: `u64`
- **Account variants:**
  - `2 accounts:` `user_stats`, `signer`

### `UpdateUserIdle`
- **Discriminator:** `0xfd85431667a11464`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `state`, `authority`, `filler`, `user`

### `UpdateUserMarginTradingEnabled`
- **Discriminator:** `0xc25cccdff6bc1fcb`
- **Args:**
  - `sub_account_id`: `u16`
  - `margin_trading_enabled`: `bool`
- **Account variants:**
  - `2 accounts:` `user`, `authority`

### `UpdateUserName`
- **Discriminator:** `0x8719b938a5352288`
- **Args:**
  - `sub_account_id`: `u16`
  - `name`: `[u8; 32]`
- **Account variants:**
  - `2 accounts:` `user`, `authority`

### `UpdateUserOpenOrdersCount`
- **Discriminator:** `0x682741d2faa36486`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `state`, `authority`, `filler`, `user`

### `UpdateUserPoolId`
- **Discriminator:** `0xdb56496a38da806d`
- **Args:**
  - `sub_account_id`: `u16`
  - `pool_id`: `u8`
- **Account variants:**
  - `2 accounts:` `user`, `authority`

### `UpdateUserProtectedMakerOrders`
- **Discriminator:** `0x72277bc6bb195adb`
- **Args:**
  - `sub_account_id`: `u16`
  - `protected_maker_orders`: `bool`
- **Account variants:**
  - `4 accounts:` `state`, `user`, `authority`, `protected_maker_mode_config`

### `UpdateUserQuoteAssetInsuranceStake`
- **Discriminator:** `0xfb659c07023f1e17`
- **Args:** (none)
- **Account variants:**
  - `6 accounts:` `state`, `spot_market`, `insurance_fund_stake`, `user_stats`, `signer`, `insurance_fund_vault`

### `UpdateUserReduceOnly`
- **Discriminator:** `0xc7472a439013566d`
- **Args:**
  - `sub_account_id`: `u16`
  - `reduce_only`: `bool`
- **Account variants:**
  - `2 accounts:` `user`, `authority`

### `UpdateUserStatsReferrerStatus`
- **Discriminator:** `0xae9a482abf9491cd`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `state`, `authority`, `user_stats`

### `UpdateWhitelistMint`
- **Discriminator:** `0xa10fa21394789097`
- **Args:**
  - `whitelist_mint`: `Pubkey`
- **Account variants:**
  - `2 accounts:` `admin`, `state`

### `UpdateWithdrawGuardThreshold`
- **Discriminator:** `0x3812273d9bd32c85`
- **Args:**
  - `withdraw_guard_threshold`: `u64`
- **Account variants:**
  - `3 accounts:` `admin`, `state`, `spot_market`

### `Withdraw`
- **Discriminator:** `0xb712469c946da122`
- **Args:**
  - `market_index`: `u16`
  - `amount`: `u64`
  - `reduce_only`: `bool`
- **Account variants:**
  - `8 accounts:` `state`, `user`, `user_stats`, `authority`, `spot_market_vault`, `drift_signer`, `user_token_account`, `token_program`

## CPI events

### `CurveRecordEvent`
- **Source:** `instructions/curve_record_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d65ee28e4462e3d75`
- **Fields:**
  - `ts`: `i64`
  - `record_id`: `u64`
  - `peg_multiplier_before`: `u128`
  - `base_asset_reserve_before`: `u128`
  - `quote_asset_reserve_before`: `u128`
  - `sqrt_k_before`: `u128`
  - `peg_multiplier_after`: `u128`
  - `base_asset_reserve_after`: `u128`
  - `quote_asset_reserve_after`: `u128`
  - `sqrt_k_after`: `u128`
  - `base_asset_amount_long`: `u128`
  - `base_asset_amount_short`: `u128`
  - `base_asset_amount_with_amm`: `i128`
  - `total_fee`: `i128`
  - `total_fee_minus_distributions`: `i128`
  - `adjustment_cost`: `i128`
  - `oracle_price`: `i64`
  - `fill_record`: `u128`
  - `number_of_users`: `u32`
  - `market_index`: `u16`

### `DeleteUserRecordEvent`
- **Source:** `instructions/delete_user_record_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d476fbe76070384de`
- **Fields:**
  - `ts`: `i64`
  - `user_authority`: `Pubkey`
  - `user`: `Pubkey`
  - `sub_account_id`: `u16`
  - `keeper`: `Option<Pubkey>`

### `DepositRecordEvent`
- **Source:** `instructions/deposit_record_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1db4f1dacf66872c86`
- **Fields:**
  - `ts`: `i64`
  - `user_authority`: `Pubkey`
  - `user`: `Pubkey`
  - `direction`: `DepositDirection`
  - `deposit_record_id`: `u64`
  - `amount`: `u64`
  - `market_index`: `u16`
  - `oracle_price`: `i64`
  - `market_deposit_balance`: `u128`
  - `market_withdraw_balance`: `u128`
  - `market_cumulative_deposit_interest`: `u128`
  - `market_cumulative_borrow_interest`: `u128`
  - `total_deposits_after`: `u64`
  - `total_withdraws_after`: `u64`
  - `explanation`: `DepositExplanation`
  - `transfer_user`: `Option<Pubkey>`

### `FuelSeasonRecordEvent`
- **Source:** `instructions/fuel_season_record_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d13897721e0f90657`
- **Fields:**
  - `ts`: `i64`
  - `authority`: `Pubkey`
  - `fuel_insurance`: `u128`
  - `fuel_deposits`: `u128`
  - `fuel_borrows`: `u128`
  - `fuel_positions`: `u128`
  - `fuel_taker`: `u128`
  - `fuel_maker`: `u128`
  - `fuel_total`: `u128`

### `FuelSweepRecordEvent`
- **Source:** `instructions/fuel_sweep_record_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d295425f684f08308`
- **Fields:**
  - `ts`: `i64`
  - `authority`: `Pubkey`
  - `user_stats_fuel_insurance`: `u32`
  - `user_stats_fuel_deposits`: `u32`
  - `user_stats_fuel_borrows`: `u32`
  - `user_stats_fuel_positions`: `u32`
  - `user_stats_fuel_taker`: `u32`
  - `user_stats_fuel_maker`: `u32`
  - `fuel_overflow_fuel_insurance`: `u128`
  - `fuel_overflow_fuel_deposits`: `u128`
  - `fuel_overflow_fuel_borrows`: `u128`
  - `fuel_overflow_fuel_positions`: `u128`
  - `fuel_overflow_fuel_taker`: `u128`
  - `fuel_overflow_fuel_maker`: `u128`

### `FundingPaymentRecordEvent`
- **Source:** `instructions/funding_payment_record_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d083b601489c9385f`
- **Fields:**
  - `ts`: `i64`
  - `user_authority`: `Pubkey`
  - `user`: `Pubkey`
  - `market_index`: `u16`
  - `funding_payment`: `i64`
  - `base_asset_amount`: `i64`
  - `user_last_cumulative_funding`: `i64`
  - `amm_cumulative_funding_long`: `i128`
  - `amm_cumulative_funding_short`: `i128`

### `FundingRateRecordEvent`
- **Source:** `instructions/funding_rate_record_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d4403ff1a855b93fe`
- **Fields:**
  - `ts`: `i64`
  - `record_id`: `u64`
  - `market_index`: `u16`
  - `funding_rate`: `i64`
  - `funding_rate_long`: `i128`
  - `funding_rate_short`: `i128`
  - `cumulative_funding_rate_long`: `i128`
  - `cumulative_funding_rate_short`: `i128`
  - `oracle_price_twap`: `i64`
  - `mark_price_twap`: `u64`
  - `period_revenue`: `i64`
  - `base_asset_amount_with_amm`: `i128`
  - `base_asset_amount_with_unsettled_lp`: `i128`

### `InsuranceFundRecordEvent`
- **Source:** `instructions/insurance_fund_record_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d38ded7eb4ec56392`
- **Fields:**
  - `ts`: `i64`
  - `spot_market_index`: `u16`
  - `perp_market_index`: `u16`
  - `user_if_factor`: `u32`
  - `total_if_factor`: `u32`
  - `vault_amount_before`: `u64`
  - `insurance_vault_amount_before`: `u64`
  - `total_if_shares_before`: `u128`
  - `total_if_shares_after`: `u128`
  - `amount`: `i64`

### `InsuranceFundStakeRecordEvent`
- **Source:** `instructions/insurance_fund_stake_record_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d44429c07d894fa72`
- **Fields:**
  - `ts`: `i64`
  - `user_authority`: `Pubkey`
  - `action`: `StakeAction`
  - `amount`: `u64`
  - `market_index`: `u16`
  - `insurance_vault_amount_before`: `u64`
  - `if_shares_before`: `u128`
  - `user_if_shares_before`: `u128`
  - `total_if_shares_before`: `u128`
  - `if_shares_after`: `u128`
  - `user_if_shares_after`: `u128`
  - `total_if_shares_after`: `u128`

### `LiquidationRecordEvent`
- **Source:** `instructions/liquidation_record_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d7f11006cb60de735`
- **Fields:**
  - `ts`: `i64`
  - `liquidation_type`: `LiquidationType`
  - `user`: `Pubkey`
  - `liquidator`: `Pubkey`
  - `margin_requirement`: `u128`
  - `total_collateral`: `i128`
  - `margin_freed`: `u64`
  - `liquidation_id`: `u16`
  - `bankrupt`: `bool`
  - `canceled_order_ids`: `Vec<u32>`
  - `liquidate_perp`: `LiquidatePerpRecord`
  - `liquidate_spot`: `LiquidateSpotRecord`
  - `liquidate_borrow_for_perp_pnl`: `LiquidateBorrowForPerpPnlRecord`
  - `liquidate_perp_pnl_for_deposit`: `LiquidatePerpPnlForDepositRecord`
  - `perp_bankruptcy`: `PerpBankruptcyRecord`
  - `spot_bankruptcy`: `SpotBankruptcyRecord`

### `LpRecordEvent`
- **Source:** `instructions/lp_record_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d65163626b20d8e6f`
- **Fields:**
  - `ts`: `i64`
  - `user`: `Pubkey`
  - `action`: `LPAction`
  - `n_shares`: `u64`
  - `market_index`: `u16`
  - `delta_base_asset_amount`: `i64`
  - `delta_quote_asset_amount`: `i64`
  - `pnl`: `i64`

### `NewUserRecordEvent`
- **Source:** `instructions/new_user_record_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1decba71db2a3395f9`
- **Fields:**
  - `ts`: `i64`
  - `user_authority`: `Pubkey`
  - `user`: `Pubkey`
  - `sub_account_id`: `u16`
  - `name`: `[u8; 32]`
  - `referrer`: `Pubkey`

### `OrderActionRecordEvent`
- **Source:** `instructions/order_action_record_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1de0344347c2ed6d01`
- **Fields:**
  - `ts`: `i64`
  - `action`: `OrderAction`
  - `action_explanation`: `OrderActionExplanation`
  - `market_index`: `u16`
  - `market_type`: `MarketType`
  - `filler`: `Option<Pubkey>`
  - `filler_reward`: `Option<u64>`
  - `fill_record_id`: `Option<u64>`
  - `base_asset_amount_filled`: `Option<u64>`
  - `quote_asset_amount_filled`: `Option<u64>`
  - `taker_fee`: `Option<u64>`
  - `maker_fee`: `Option<i64>`
  - `referrer_reward`: `Option<u32>`
  - `quote_asset_amount_surplus`: `Option<i64>`
  - `spot_fulfillment_method_fee`: `Option<u64>`
  - `taker`: `Option<Pubkey>`
  - `taker_order_id`: `Option<u32>`
  - `taker_order_direction`: `Option<PositionDirection>`
  - `taker_order_base_asset_amount`: `Option<u64>`
  - `taker_order_cumulative_base_asset_amount_filled`: `Option<u64>`
  - `taker_order_cumulative_quote_asset_amount_filled`: `Option<u64>`
  - `maker`: `Option<Pubkey>`
  - `maker_order_id`: `Option<u32>`
  - `maker_order_direction`: `Option<PositionDirection>`
  - `maker_order_base_asset_amount`: `Option<u64>`
  - `maker_order_cumulative_base_asset_amount_filled`: `Option<u64>`
  - `maker_order_cumulative_quote_asset_amount_filled`: `Option<u64>`
  - `oracle_price`: `i64`

### `OrderRecordEvent`
- **Source:** `instructions/order_record_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d681340385915025a`
- **Fields:**
  - `ts`: `i64`
  - `user`: `Pubkey`
  - `order`: `Order`

### `SettlePnlRecordEvent`
- **Source:** `instructions/settle_pnl_record_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d3944691a77c6d559`
- **Fields:**
  - `ts`: `i64`
  - `user`: `Pubkey`
  - `market_index`: `u16`
  - `pnl`: `i128`
  - `base_asset_amount`: `i64`
  - `quote_asset_amount_after`: `i64`
  - `quote_entry_amount`: `i64`
  - `settle_price`: `i64`
  - `explanation`: `SettlePnlExplanation`

### `SignedMsgOrderRecordEvent`
- **Source:** `instructions/signed_msg_order_record_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1dd3c519128e56711b`
- **Fields:**
  - `user`: `Pubkey`
  - `hash`: `String`
  - `matching_order_params`: `OrderParams`
  - `user_order_id`: `u32`
  - `signed_msg_order_max_slot`: `u64`
  - `signed_msg_order_uuid`: `[u8; 8]`
  - `ts`: `i64`

### `SpotInterestRecordEvent`
- **Source:** `instructions/spot_interest_record_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1db7bacbbae1bb5f82`
- **Fields:**
  - `ts`: `i64`
  - `market_index`: `u16`
  - `deposit_balance`: `u128`
  - `cumulative_deposit_interest`: `u128`
  - `borrow_balance`: `u128`
  - `cumulative_borrow_interest`: `u128`
  - `optimal_utilization`: `u32`
  - `optimal_borrow_rate`: `u32`
  - `max_borrow_rate`: `u32`

### `SpotMarketVaultDepositRecordEvent`
- **Source:** `instructions/spot_market_vault_deposit_record_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1db2d917bc7fbe2049`
- **Fields:**
  - `ts`: `i64`
  - `market_index`: `u16`
  - `deposit_balance`: `u128`
  - `cumulative_deposit_interest_before`: `u128`
  - `cumulative_deposit_interest_after`: `u128`
  - `deposit_token_amount_before`: `u64`
  - `amount`: `u64`

### `SwapRecordEvent`
- **Source:** `instructions/swap_record_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1da2bb7bc28a38faf1`
- **Fields:**
  - `ts`: `i64`
  - `user`: `Pubkey`
  - `amount_out`: `u64`
  - `amount_in`: `u64`
  - `out_market_index`: `u16`
  - `in_market_index`: `u16`
  - `out_oracle_price`: `i64`
  - `in_oracle_price`: `i64`
  - `fee`: `u64`

## Shared types

### `AMM`
- `oracle`: `Pubkey`
- `historical_oracle_data`: `HistoricalOracleData`
- `base_asset_amount_per_lp`: `i128`
- `quote_asset_amount_per_lp`: `i128`
- `fee_pool`: `PoolBalance`
- `base_asset_reserve`: `u128`
- `quote_asset_reserve`: `u128`
- `concentration_coef`: `u128`
- `min_base_asset_reserve`: `u128`
- `max_base_asset_reserve`: `u128`
- `sqrt_k`: `u128`
- `peg_multiplier`: `u128`
- `terminal_quote_asset_reserve`: `u128`
- `base_asset_amount_long`: `i128`
- `base_asset_amount_short`: `i128`
- `base_asset_amount_with_amm`: `i128`
- `base_asset_amount_with_unsettled_lp`: `i128`
- `max_open_interest`: `u128`
- `quote_asset_amount`: `i128`
- `quote_entry_amount_long`: `i128`
- `quote_entry_amount_short`: `i128`
- `quote_break_even_amount_long`: `i128`
- `quote_break_even_amount_short`: `i128`
- `user_lp_shares`: `u128`
- `last_funding_rate`: `i64`
- `last_funding_rate_long`: `i64`
- `last_funding_rate_short`: `i64`
- `last24h_avg_funding_rate`: `i64`
- `total_fee`: `i128`
- `total_mm_fee`: `i128`
- `total_exchange_fee`: `u128`
- `total_fee_minus_distributions`: `i128`
- `total_fee_withdrawn`: `u128`
- `total_liquidation_fee`: `u128`
- `cumulative_funding_rate_long`: `i128`
- `cumulative_funding_rate_short`: `i128`
- `total_social_loss`: `u128`
- `ask_base_asset_reserve`: `u128`
- `ask_quote_asset_reserve`: `u128`
- `bid_base_asset_reserve`: `u128`
- `bid_quote_asset_reserve`: `u128`
- `last_oracle_normalised_price`: `i64`
- `last_oracle_reserve_price_spread_pct`: `i64`
- `last_bid_price_twap`: `u64`
- `last_ask_price_twap`: `u64`
- `last_mark_price_twap`: `u64`
- `last_mark_price_twap5min`: `u64`
- `last_update_slot`: `u64`
- `last_oracle_conf_pct`: `u64`
- `net_revenue_since_last_funding`: `i64`
- `last_funding_rate_ts`: `i64`
- `funding_period`: `i64`
- `order_step_size`: `u64`
- `order_tick_size`: `u64`
- `min_order_size`: `u64`
- `max_position_size`: `u64`
- `volume24h`: `u64`
- `long_intensity_volume`: `u64`
- `short_intensity_volume`: `u64`
- `last_trade_ts`: `i64`
- `mark_std`: `u64`
- `oracle_std`: `u64`
- `last_mark_price_twap_ts`: `i64`
- `base_spread`: `u32`
- `max_spread`: `u32`
- `long_spread`: `u32`
- `short_spread`: `u32`
- `long_intensity_count`: `u32`
- `short_intensity_count`: `u32`
- `max_fill_reserve_fraction`: `u16`
- `max_slippage_ratio`: `u16`
- `curve_update_intensity`: `u8`
- `amm_jit_intensity`: `u8`
- `oracle_source`: `OracleSource`
- `last_oracle_valid`: `bool`
- `target_base_asset_amount_per_lp`: `i32`
- `per_lp_base`: `i8`
- `padding1`: `u8`
- `padding2`: `u16`
- `total_fee_earned_per_lp`: `u64`
- `net_unsettled_funding_pnl`: `i64`
- `quote_asset_amount_with_unsettled_lp`: `i64`
- `reference_price_offset`: `i32`
- `padding`: `[u8; 12]`

### `AMMAvailability`
- enum variants:
  - `Immediate`
  - `AfterMinDuration`
  - `Unavailable`

### `AMMLiquiditySplit`
- enum variants:
  - `ProtocolOwned`
  - `LPOwned`
  - `Shared`

### `AssetTier`
- enum variants:
  - `Collateral`
  - `Protected`
  - `Cross`
  - `Isolated`
  - `Unlisted`

### `AssetType`
- enum variants:
  - `Base`
  - `Quote`

### `ContractTier`
- enum variants:
  - `A`
  - `B`
  - `C`
  - `Speculative`
  - `HighlySpeculative`
  - `Isolated`

### `ContractType`
- enum variants:
  - `Perpetual`
  - `Future`
  - `Prediction`

### `DepositDirection`
- enum variants:
  - `Deposit`
  - `Withdraw`

### `DepositExplanation`
- enum variants:
  - `None`
  - `Transfer`
  - `Borrow`
  - `RepayBorrow`

### `DriftAction`
- enum variants:
  - `UpdateFunding`
  - `SettlePnl`
  - `TriggerOrder`
  - `FillOrderMatch`
  - `FillOrderAmm`
  - `Liquidate`
  - `MarginCalc`
  - `UpdateTwap`
  - `UpdateAMMCurve`
  - `OracleOrderPrice`

### `ExchangeStatus`
- enum variants:
  - `DepositPaused`
  - `WithdrawPaused`
  - `AmmPaused`
  - `FillPaused`
  - `LiqPaused`
  - `FundingPaused`
  - `SettlePnlPaused`
  - `AmmImmediateFillPaused`

### `FeeStructure`
- `fee_tiers`: `[FeeTier; 10]`
- `filler_reward_structure`: `OrderFillerRewardStructure`
- `referrer_reward_epoch_upper_bound`: `u64`
- `flat_filler_fee`: `u64`

### `FeeTier`
- `fee_numerator`: `u32`
- `fee_denominator`: `u32`
- `maker_rebate_numerator`: `u32`
- `maker_rebate_denominator`: `u32`
- `referrer_reward_numerator`: `u32`
- `referrer_reward_denominator`: `u32`
- `referee_fee_numerator`: `u32`
- `referee_fee_denominator`: `u32`

### `FillMode`
- enum variants:
  - `Fill`
  - `PlaceAndMake`
  - `PlaceAndTake(bool`
  - `u8)`
  - `Liquidation`

### `FuelOverflowStatus`
- enum variants:
  - `Exists`

### `HistoricalIndexData`
- `last_index_bid_price`: `u64`
- `last_index_ask_price`: `u64`
- `last_index_price_twap`: `u64`
- `last_index_price_twap5min`: `u64`
- `last_index_price_twap_ts`: `i64`

### `HistoricalOracleData`
- `last_oracle_price`: `i64`
- `last_oracle_conf`: `u64`
- `last_oracle_delay`: `i64`
- `last_oracle_price_twap`: `i64`
- `last_oracle_price_twap5min`: `i64`
- `last_oracle_price_twap_ts`: `i64`

### `InsuranceClaim`
- `revenue_withdraw_since_last_settle`: `i64`
- `max_revenue_withdraw_per_period`: `u64`
- `quote_max_insurance`: `u64`
- `quote_settled_insurance`: `u64`
- `last_revenue_withdraw_ts`: `i64`

### `InsuranceFund`
- `vault`: `Pubkey`
- `total_shares`: `u128`
- `user_shares`: `u128`
- `shares_base`: `u128`
- `unstaking_period`: `i64`
- `last_revenue_settle_ts`: `i64`
- `revenue_settle_period`: `i64`
- `total_factor`: `u32`
- `user_factor`: `u32`

### `InsuranceFundOperation`
- enum variants:
  - `Init`
  - `Add`
  - `RequestRemove`
  - `Remove`

### `LPAction`
- enum variants:
  - `AddLiquidity`
  - `RemoveLiquidity`
  - `SettleLiquidity`
  - `RemoveLiquidityDerisk`

### `LiquidateBorrowForPerpPnlRecord`
- `perp_market_index`: `u16`
- `market_oracle_price`: `i64`
- `pnl_transfer`: `u128`
- `liability_market_index`: `u16`
- `liability_price`: `i64`
- `liability_transfer`: `u128`

### `LiquidatePerpPnlForDepositRecord`
- `perp_market_index`: `u16`
- `market_oracle_price`: `i64`
- `pnl_transfer`: `u128`
- `asset_market_index`: `u16`
- `asset_price`: `i64`
- `asset_transfer`: `u128`

### `LiquidatePerpRecord`
- `market_index`: `u16`
- `oracle_price`: `i64`
- `base_asset_amount`: `i64`
- `quote_asset_amount`: `i64`
- `lp_shares`: `u64`
- `fill_record_id`: `u64`
- `user_order_id`: `u32`
- `liquidator_order_id`: `u32`
- `liquidator_fee`: `u64`
- `if_fee`: `u64`

### `LiquidateSpotRecord`
- `asset_market_index`: `u16`
- `asset_price`: `i64`
- `asset_transfer`: `u128`
- `liability_market_index`: `u16`
- `liability_price`: `i64`
- `liability_transfer`: `u128`
- `if_fee`: `u64`

### `LiquidationMultiplierType`
- enum variants:
  - `Discount`
  - `Premium`

### `LiquidationType`
- enum variants:
  - `LiquidatePerp`
  - `LiquidateSpot`
  - `LiquidateBorrowForPerpPnl`
  - `LiquidatePerpPnlForDeposit`
  - `PerpBankruptcy`
  - `SpotBankruptcy`

### `MarginCalculationMode`
- enum variants:
  - `Standard {`
  - `Liquidation {`

### `MarginMode`
- enum variants:
  - `Default`
  - `HighLeverage`

### `MarginRequirementType`
- enum variants:
  - `Initial`
  - `Fill`
  - `Maintenance`

### `MarketIdentifier`
- `market_type`: `MarketType`
- `market_index`: `u16`

### `MarketStatus`
- enum variants:
  - `Initialized`
  - `Active`
  - `FundingPaused`
  - `AmmPaused`
  - `FillPaused`
  - `WithdrawPaused`
  - `ReduceOnly`
  - `Settlement`
  - `Delisted`

### `MarketType`
- enum variants:
  - `Spot`
  - `Perp`

### `ModifyOrderId`
- enum variants:
  - `UserOrderId(u8)`
  - `OrderId(u32)`

### `ModifyOrderParams`
- `direction`: `Option<PositionDirection>`
- `base_asset_amount`: `Option<u64>`
- `price`: `Option<u64>`
- `reduce_only`: `Option<bool>`
- `post_only`: `Option<PostOnlyParam>`
- `immediate_or_cancel`: `Option<bool>`
- `max_ts`: `Option<i64>`
- `trigger_price`: `Option<u64>`
- `trigger_condition`: `Option<OrderTriggerCondition>`
- `oracle_price_offset`: `Option<i32>`
- `auction_duration`: `Option<u8>`
- `auction_start_price`: `Option<i64>`
- `auction_end_price`: `Option<i64>`
- `policy`: `Option<u8>`

### `ModifyOrderPolicy`
- enum variants:
  - `MustModify`
  - `ExcludePreviousFill`

### `OracleGuardRails`
- `price_divergence`: `PriceDivergenceGuardRails`
- `validity`: `ValidityGuardRails`

### `OracleSource`
- enum variants:
  - `Pyth`
  - `Switchboard`
  - `QuoteAsset`
  - `Pyth1K`
  - `Pyth1M`
  - `PythStableCoin`
  - `Prelaunch`
  - `PythPull`
  - `Pyth1KPull`
  - `Pyth1MPull`
  - `PythStableCoinPull`
  - `SwitchboardOnDemand`
  - `PythLazer`
  - `PythLazer1K`
  - `PythLazer1M`
  - `PythLazerStableCoin`

### `OracleValidity`
- enum variants:
  - `NonPositive`
  - `TooVolatile`
  - `TooUncertain`
  - `StaleForMargin`
  - `InsufficientDataPoints`
  - `StaleForAMM`
  - `Valid`

### `Order`
- `slot`: `u64`
- `price`: `u64`
- `base_asset_amount`: `u64`
- `base_asset_amount_filled`: `u64`
- `quote_asset_amount_filled`: `u64`
- `trigger_price`: `u64`
- `auction_start_price`: `i64`
- `auction_end_price`: `i64`
- `max_ts`: `i64`
- `oracle_price_offset`: `i32`
- `order_id`: `u32`
- `market_index`: `u16`
- `status`: `OrderStatus`
- `order_type`: `OrderType`
- `market_type`: `MarketType`
- `user_order_id`: `u8`
- `existing_position_direction`: `PositionDirection`
- `direction`: `PositionDirection`
- `reduce_only`: `bool`
- `post_only`: `bool`
- `immediate_or_cancel`: `bool`
- `trigger_condition`: `OrderTriggerCondition`
- `auction_duration`: `u8`
- `posted_slot_tail`: `u8`
- `padding`: `[u8; 2]`

### `OrderAction`
- enum variants:
  - `Place`
  - `Cancel`
  - `Fill`
  - `Trigger`
  - `Expire`

### `OrderActionExplanation`
- enum variants:
  - `None`
  - `InsufficientFreeCollateral`
  - `OraclePriceBreachedLimitPrice`
  - `MarketOrderFilledToLimitPrice`
  - `OrderExpired`
  - `Liquidation`
  - `OrderFilledWithAMM`
  - `OrderFilledWithAMMJit`
  - `OrderFilledWithMatch`
  - `OrderFilledWithMatchJit`
  - `MarketExpired`
  - `RiskingIncreasingOrder`
  - `ReduceOnlyOrderIncreasedPosition`
  - `OrderFillWithSerum`
  - `NoBorrowLiquidity`
  - `OrderFillWithPhoenix`
  - `OrderFilledWithAMMJitLPSplit`
  - `OrderFilledWithLPJit`
  - `DeriskLp`
  - `OrderFilledWithOpenbookV2`

### `OrderFillerRewardStructure`
- `reward_numerator`: `u32`
- `reward_denominator`: `u32`
- `time_based_reward_lower_bound`: `u128`

### `OrderParams`
- `order_type`: `OrderType`
- `market_type`: `MarketType`
- `direction`: `PositionDirection`
- `user_order_id`: `u8`
- `base_asset_amount`: `u64`
- `price`: `u64`
- `market_index`: `u16`
- `reduce_only`: `bool`
- `post_only`: `PostOnlyParam`
- `immediate_or_cancel`: `bool`
- `max_ts`: `Option<i64>`
- `trigger_price`: `Option<u64>`
- `trigger_condition`: `OrderTriggerCondition`
- `oracle_price_offset`: `Option<i32>`
- `auction_duration`: `Option<u8>`
- `auction_start_price`: `Option<i64>`
- `auction_end_price`: `Option<i64>`

### `OrderStatus`
- enum variants:
  - `Init`
  - `Open`
  - `Filled`
  - `Canceled`

### `OrderTriggerCondition`
- enum variants:
  - `Above`
  - `Below`
  - `TriggeredAbove`
  - `TriggeredBelow`

### `OrderType`
- enum variants:
  - `Market`
  - `Limit`
  - `TriggerMarket`
  - `TriggerLimit`
  - `Oracle`

### `PerpBankruptcyRecord`
- `market_index`: `u16`
- `pnl`: `i128`
- `if_payment`: `u128`
- `clawback_user`: `Option<Pubkey>`
- `clawback_user_payment`: `Option<u128>`
- `cumulative_funding_rate_delta`: `i128`

### `PerpFulfillmentMethod`
- enum variants:
  - `AMM(Option<u64>)`
  - `Match(Pubkey`
  - `u16`
  - `u64)`

### `PerpOperation`
- enum variants:
  - `UpdateFunding`
  - `AmmFill`
  - `Fill`
  - `SettlePnl`
  - `SettlePnlWithPosition`
  - `Liquidation`
  - `AmmImmediateFill`

### `PerpPosition`
- `last_cumulative_funding_rate`: `i64`
- `base_asset_amount`: `i64`
- `quote_asset_amount`: `i64`
- `quote_break_even_amount`: `i64`
- `quote_entry_amount`: `i64`
- `open_bids`: `i64`
- `open_asks`: `i64`
- `settled_pnl`: `i64`
- `lp_shares`: `u64`
- `last_base_asset_amount_per_lp`: `i64`
- `last_quote_asset_amount_per_lp`: `i64`
- `remainder_base_asset_amount`: `i32`
- `market_index`: `u16`
- `open_orders`: `u8`
- `per_lp_base`: `i8`

### `PlaceAndTakeOrderSuccessCondition`
- enum variants:
  - `PartialFill`
  - `FullFill`

### `PoolBalance`
- `scaled_balance`: `u128`
- `market_index`: `u16`
- `padding`: `[u8; 6]`

### `PositionDirection`
- enum variants:
  - `Long`
  - `Short`

### `PositionUpdateType`
- enum variants:
  - `Open`
  - `Increase`
  - `Reduce`
  - `Close`
  - `Flip`

### `PostOnlyParam`
- enum variants:
  - `None`
  - `MustPostOnly`
  - `TryPostOnly`
  - `Slide`

### `PrelaunchOracleParams`
- `perp_market_index`: `u16`
- `price`: `Option<i64>`
- `max_price`: `Option<i64>`

### `PriceDivergenceGuardRails`
- `mark_oracle_percent_divergence`: `u64`
- `oracle_twap5min_percent_divergence`: `u64`

### `ReferrerStatus`
- enum variants:
  - `IsReferrer`
  - `IsReferred`

### `SettlePnlExplanation`
- enum variants:
  - `None`
  - `ExpiredPosition`

### `SettlePnlMode`
- enum variants:
  - `MustSettle`
  - `TrySettle`

### `SignatureVerificationError`
- enum variants:
  - `InvalidEd25519InstructionProgramId`
  - `InvalidEd25519InstructionDataLength`
  - `InvalidSignatureIndex`
  - `InvalidSignatureOffset`
  - `InvalidPublicKeyOffset`
  - `InvalidMessageOffset`
  - `InvalidMessageDataSize`
  - `InvalidInstructionIndex`
  - `MessageOffsetOverflow`
  - `InvalidMessageHex`
  - `InvalidMessageData`
  - `LoadInstructionAtFailed`

### `SignedMsgOrderId`
- `uuid`: `[u8; 8]`
- `max_slot`: `u64`
- `order_id`: `u32`
- `padding`: `u32`

### `SignedMsgOrderParamsMessage`
- `signed_msg_order_params`: `OrderParams`
- `sub_account_id`: `u16`
- `slot`: `u64`
- `uuid`: `[u8; 8]`
- `take_profit_order_params`: `Option<SignedMsgTriggerOrderParams>`
- `stop_loss_order_params`: `Option<SignedMsgTriggerOrderParams>`

### `SignedMsgTriggerOrderParams`
- `trigger_price`: `u64`
- `base_asset_amount`: `u64`

### `SignedMsgUserOrdersFixed`
- `user_key`: `Pubkey`
- `padding`: `u32`
- `len`: `u32`

### `SpotBalanceType`
- enum variants:
  - `Deposit`
  - `Borrow`

### `SpotBankruptcyRecord`
- `market_index`: `u16`
- `borrow_amount`: `u128`
- `if_payment`: `u128`
- `cumulative_deposit_interest_delta`: `u128`

### `SpotFulfillmentConfigStatus`
- enum variants:
  - `Enabled`
  - `Disabled`

### `SpotFulfillmentMethod`
- enum variants:
  - `ExternalMarket`
  - `Match(Pubkey`
  - `u16)`

### `SpotFulfillmentType`
- enum variants:
  - `SerumV3`
  - `Match`
  - `PhoenixV1`
  - `OpenbookV2`

### `SpotOperation`
- enum variants:
  - `UpdateCumulativeInterest`
  - `Fill`
  - `Deposit`
  - `Withdraw`
  - `Liquidation`

### `SpotPosition`
- `scaled_balance`: `u64`
- `open_bids`: `i64`
- `open_asks`: `i64`
- `cumulative_deposits`: `i64`
- `market_index`: `u16`
- `balance_type`: `SpotBalanceType`
- `open_orders`: `u8`
- `padding`: `[u8; 4]`

### `StakeAction`
- enum variants:
  - `Stake`
  - `UnstakeRequest`
  - `UnstakeCancelRequest`
  - `Unstake`
  - `UnstakeTransfer`
  - `StakeTransfer`

### `SwapDirection`
- enum variants:
  - `Add`
  - `Remove`

### `SwapReduceOnly`
- enum variants:
  - `In`
  - `Out`

### `TwapPeriod`
- enum variants:
  - `FundingPeriod`
  - `FiveMin`

### `UpdatePerpMarketSummaryStatsParams`
- `quote_asset_amount_with_unsettled_lp`: `Option<i64>`
- `net_unsettled_funding_pnl`: `Option<i64>`
- `update_amm_summary_stats`: `Option<bool>`

### `UserFees`
- `total_fee_paid`: `u64`
- `total_fee_rebate`: `u64`
- `total_token_discount`: `u64`
- `total_referee_discount`: `u64`
- `total_referrer_reward`: `u64`
- `current_epoch_referrer_reward`: `u64`

### `UserStatus`
- enum variants:
  - `BeingLiquidated`
  - `Bankrupt`
  - `ReduceOnly`
  - `AdvancedLp`
  - `ProtectedMakerOrders`

### `ValidityGuardRails`
- `slots_before_stale_for_amm`: `i64`
- `slots_before_stale_for_margin`: `i64`
- `confidence_interval_max_size`: `u64`
- `too_volatile_ratio`: `i64`
