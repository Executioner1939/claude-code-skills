# Heaven

- **Crate:** `carbon-heaven-decoder`
- **Program ID:** `HEAVENoP2qxoeuF8Dj2oT1GHEnu49U5mJYkdeC8BAX2o`
- **Decoder struct:** `HeavenDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in instructions/)
- **Discriminator style:** anchor 8-byte

## Account types

### `LiquidityPoolState`
- **Fields:**
  - `info`: `LiquidityPoolInfo`
  - `market_cap_based_fees`: `LiquidityPoolMarketCapBasedFees`
  - `reserve`: `LiquidityPoolReserve`
  - `lp_token`: `LiquidityPoolLpTokenInfo`
  - `protocol_trading_fees`: `u64`
  - `creator_trading_fees`: `u64`
  - `creator_trading_fees_claimed_by_creator`: `u64`
  - `creator_trading_fees_claimed_by_others`: `u64`
  - `liquidity_provider_trading_fees`: `u64`
  - `creator_trading_fee_protocol_fees`: `u64`
  - `reflection_trading_fees`: `u64`
  - `created_at_slot`: `u64`
  - `trading_volume_usd`: `f64`
  - `creator_trading_fee_trading_volume_threshold`: `f64`
  - `creator_trading_fee_trading_volume_threshold_reached_unix_timestamp`: `u64`
  - `token_a_vault`: `Pubkey`
  - `token_b_vault`: `Pubkey`
  - `protocol_config`: `Pubkey`
  - `key`: `Pubkey`
  - `token_a`: `LiquidityPoolTokenInfo`
  - `token_b`: `LiquidityPoolTokenInfo`
  - `allowlist`: `LiquidityPoolAllowlist`
  - `feature_flags`: `LiquidityPoolFeatureFlags`
  - `taxable_side`: `u8`
  - `taxable_side_type`: `u8`
  - `creator_trading_fee_distribution`: `u8`
  - `creator_trading_fee_claim_status`: `u8`
  - `fee_configuration_mode`: `u8`
  - `is_migrated`: `u8`
  - `pad`: `[u8; 13]`
  - `slot_offset_based_fees`: `LiquidityPoolSlotOffsetBasedFees`
  - `creator_trading_fee_receiver`: `Pubkey`

### `MsolTicketSolSpent`
- **Fields:**
  - `cost_basis`: `u64`
  - `msol_unstaked`: `u64`

### `ProtocolAdminState`
- **Fields:**
  - `current_protocol_admin`: `Pubkey`

### `ProtocolConfig`
- **Fields:**
  - `create_pool_fee`: `u64`
  - `initial_token_b_amount`: `f64`
  - `initial_token_a_amount`: `u64`
  - `unstaked_wsol_reserve`: `u64`
  - `total_sol_spent`: `u64`
  - `total_msol_received`: `u64`
  - `total_realized_profit`: `u64`
  - `pool_count`: `u64`
  - `max_supply_per_wallet`: `u64`
  - `creator_trading_fee_trading_volume_threshold`: `f64`
  - `market_cap_based_fees`: `LiquidityPoolMarketCapBasedFees`
  - `buffer_bps`: `u16`
  - `auto_staking_threshold_bps`: `u16`
  - `version`: `u16`
  - `protocol_config_state_bump`: `u8`
  - `allow_create_pool`: `u8`
  - `supported_pool_type`: `u8`
  - `default_leader_slot_window`: `u8`
  - `auto_staking_enabled`: `u8`
  - `leader_slot_window`: `u8`
  - `sandwich_resistence_enabled`: `u8`
  - `token_a_decimals`: `u8`
  - `migration_market_cap_threshold`: `u16`
  - `pad`: `[u8; 8]`
  - `max_creator_trading_fee`: `u32`
  - `slot_offset_based_fees`: `LiquidityPoolSlotOffsetBasedFees`

### `ProtocolOwnerState`
- **Fields:**
  - `current_protocol_owner`: `Pubkey`

## Instructions

### `AdminBorrowSol`
- **Discriminator:** `0xcc485fd7acc089fc`
- **Args:**
  - `version`: `u16`
  - `amount`: `u64`
- **Account variants:**
  - `10 accounts:` `token_program`, `associated_token_program`, `payer`, `admin`, `protocol_config_state`, `system_program`, `protocol_staking_admin_state`, `address_lookup_program`, `instruction_sysvar_account_info`, `temp_sol_holder`

### `AdminClaimMsol`
- **Discriminator:** `0x7c303cc7cb312429`
- **Args:**
  - `version`: `u16`
  - `ticket_number`: `u32`
- **Account variants:**
  - `10 accounts:` `token_program`, `associated_token_program`, `payer`, `admin`, `protocol_config_state`, `system_program`, `protocol_staking_admin_state`, `msol_ticket`, `msol_mint`, `msol_ticket_sol_spent`

### `AdminClaimStakingRewards`
- **Discriminator:** `0x18a3dcabe1dea6f8`
- **Args:**
  - `version`: `u16`
  - `amount`: `u64`
- **Account variants:**
  - `10 accounts:` `token_program`, `associated_token_program`, `payer`, `admin`, `protocol_config_state`, `protocol_config_wsol_vault`, `system_program`, `protocol_staking_admin_state`, `wsol_token_vault`, `wsol_mint`

### `AdminClaimStandardCreatorTradingFees`
- **Discriminator:** `0xb627a819603f4c11`
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `3 accounts:` `swap`, `protocol_admin`, `protocol_admin_state`

### `AdminDepositMsol`
- **Discriminator:** `0xcebdd0a61351ca30`
- **Args:**
  - `version`: `u16`
  - `amount`: `u64`
- **Account variants:**
  - `10 accounts:` `token_program`, `associated_token_program`, `payer`, `admin`, `protocol_config_state`, `system_program`, `protocol_staking_admin_state`, `address_lookup_program`, `instruction_sysvar_account_info`, `temp_sol_holder`

### `AdminMintMsol`
- **Discriminator:** `0x8cca39c361d5a813`
- **Args:**
  - `version`: `u16`
  - `amount`: `u64`
- **Account variants:**
  - `10 accounts:` `token_program`, `associated_token_program`, `payer`, `admin`, `protocol_config_state`, `system_program`, `protocol_staking_admin_state`, `address_lookup_program`, `instruction_sysvar_account_info`, `temp_sol_holder`

### `AdminRepaySol`
- **Discriminator:** `0x883d30e8a61acf2e`
- **Args:**
  - `version`: `u16`
  - `amount`: `u64`
- **Account variants:**
  - `10 accounts:` `token_program`, `associated_token_program`, `payer`, `admin`, `protocol_config_state`, `system_program`, `protocol_staking_admin_state`, `address_lookup_program`, `instruction_sysvar_account_info`, `temp_sol_holder`

### `AdminUnstakeMsol`
- **Discriminator:** `0xfdda8dfc2809079a`
- **Args:**
  - `version`: `u16`
  - `ticket_number`: `u32`
  - `amount`: `u64`
- **Account variants:**
  - `10 accounts:` `token_program`, `associated_token_program`, `payer`, `admin`, `protocol_config_state`, `system_program`, `protocol_staking_admin_state`, `msol_ticket`, `msol_mint`, `msol_ticket_sol_spent`

### `AdminUpdateStandardLiquidityPoolState`
- **Discriminator:** `0x63e4293fddf4c8c7`
- **Args:**
  - `update`: `AdminUpdateLiquidityPoolState`
- **Account variants:**
  - `4 accounts:` `liquidity_pool_state`, `protocol_config`, `protocol_admin`, `protocol_admin_state`

### `AdminWithdrawMsol`
- **Discriminator:** `0xf9db8d48d26ed863`
- **Args:**
  - `version`: `u16`
  - `amount`: `u64`
- **Account variants:**
  - `10 accounts:` `token_program`, `associated_token_program`, `payer`, `admin`, `protocol_config_state`, `system_program`, `protocol_staking_admin_state`, `address_lookup_program`, `instruction_sysvar_account_info`, `temp_sol_holder`

### `AdminWithdrawTransferFee`
- **Discriminator:** `0x754fa4cb7e4816f6`
- **Args:**
  - `protocol_config_version`: `u16`
- **Account variants:**
  - `6 accounts:` `token_program`, `mint`, `receiver`, `protocol_fee_admin_state`, `admin`, `protocol_config`

### `Buy`
- **Discriminator:** `0x66063d1201daebea`
- **Args:**
  - `params`: `BuyParams`
- **Account variants:**
  - `14 accounts:` `token_a_program`, `token_b_program`, `associated_token_program`, `system_program`, `liquidity_pool_state`, `user`, `token_a_mint`, `token_b_mint`, `user_token_a_vault`, `user_token_b_vault`, `token_a_vault`, `token_b_vault`, `protocol_config`, `instruction_sysvar_account_info`

### `ClaimStandardCreatorTradingFeeProtocolFees`
- **Discriminator:** `0x00c9e2e47f2d456e`
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `3 accounts:` `swap`, `protocol_admin`, `protocol_admin_state`

### `ClaimStandardCreatorTradingFees`
- **Discriminator:** `0xa559dd34aaf9226f`
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `14 accounts:` `token_a_program`, `token_b_program`, `associated_token_program`, `system_program`, `liquidity_pool_state`, `user`, `token_a_mint`, `token_b_mint`, `user_token_a_vault`, `user_token_b_vault`, `token_a_vault`, `token_b_vault`, `protocol_config`, `instruction_sysvar_account_info`

### `ClaimStandardProtocolTradingFees`
- **Discriminator:** `0x54ce8cf53fd440ed`
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `3 accounts:` `swap`, `protocol_admin`, `protocol_admin_state`

### `ClaimStandardReflectionTradingFees`
- **Discriminator:** `0x4694259366141e17`
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `3 accounts:` `swap`, `protocol_admin`, `protocol_admin_state`

### `CloseProtocolLookupTable`
- **Discriminator:** `0x4f48302777032a74`
- **Args:**
  - `version`: `u64`
- **Account variants:**
  - `7 accounts:` `payer`, `system_program`, `address_lookup_program`, `authority`, `lookup_table`, `protocol_owner_state`, `current_owner`

### `CreateOrUpdateProtocolFeeAdmin`
- **Discriminator:** `0x157eb014556f351f`
- **Args:** (none)
- **Account variants:**
  - `6 accounts:` `system_program`, `payer`, `current_owner`, `protocol_owner_state`, `new_admin`, `protocol_fee_admin_state`

### `CreateOrUpdateProtocolOwner`
- **Discriminator:** `0xaa7c802830698b94`
- **Args:** (none)
- **Account variants:**
  - `5 accounts:` `system_program`, `payer`, `current_owner`, `new_owner`, `protocol_owner_state`

### `CreateOrUpdateProtocolStakingAdmin`
- **Discriminator:** `0x04acc4d578321e89`
- **Args:** (none)
- **Account variants:**
  - `6 accounts:` `system_program`, `payer`, `current_owner`, `protocol_owner_state`, `new_admin`, `protocol_staking_admin_state`

### `CreateProtocolConfig`
- **Discriminator:** `0x7372186f0e3571fe`
- **Args:**
  - `version`: `u16`
  - `params`: `ProtocolConfigParams`
- **Account variants:**
  - `9 accounts:` `token_program`, `associated_token_program`, `payer`, `owner`, `protocol_config_state`, `system_program`, `protocol_owner_state`, `msol_token_vault`, `msol_mint`

### `CreateProtocolLookupTable`
- **Discriminator:** `0xf9036399a8f1f3e4`
- **Args:**
  - `version`: `u64`
- **Account variants:**
  - `7 accounts:` `payer`, `system_program`, `address_lookup_program`, `authority`, `lookup_table`, `protocol_owner_state`, `current_owner`

### `CreateStandardLiquidityPool`
- **Discriminator:** `0x2a2b7e38e70ad035`
- **Args:**
  - `protocol_config_version`: `u16`
  - `params`: `CreateStandardLiquidityPoolParams`
- **Account variants:**
  - `13 accounts:` `token_program`, `associated_token_program`, `system_program`, `user`, `payer`, `token_a_mint`, `token_b_mint`, `user_token_a_vault`, `token_a_vault`, `token_b_vault`, `liquidity_pool_state`, `protocol_config`, `token_a_program`

### `DeactivateProtocolLookupTable`
- **Discriminator:** `0xda0c583a962c9848`
- **Args:**
  - `version`: `u64`
- **Account variants:**
  - `7 accounts:` `payer`, `system_program`, `address_lookup_program`, `authority`, `lookup_table`, `protocol_owner_state`, `current_owner`

### `ExtendProtocolLookupTable`
- **Discriminator:** `0x07e3c6016b711f58`
- **Args:**
  - `version`: `u64`
  - `addresses`: `Vec<Pubkey>`
- **Account variants:**
  - `7 accounts:` `payer`, `system_program`, `address_lookup_program`, `authority`, `lookup_table`, `protocol_owner_state`, `current_owner`

### `InitializeProtocolLending`
- **Discriminator:** `0x00cdedf01b4f1b3b`
- **Args:**
  - `version`: `u16`
  - `recent_slot`: `u64`
- **Account variants:**
  - `10 accounts:` `token_program`, `associated_token_program`, `payer`, `admin`, `protocol_config_state`, `system_program`, `protocol_staking_admin_state`, `address_lookup_program`, `instruction_sysvar_account_info`, `temp_sol_holder`

### `RemainingAccountsStub`
- **Discriminator:** `0x208f535e17223bef`
- **Args:** (none)
- **Account variants:**
  - `23 accounts:` `create_protocol_config_remaining_accounts`, `kamino_lending_user_metadata`, `kamino_lending_init_obligation`, `kamino_lending_refresh_reserve`, `kamino_lending_refresh_obligation`, `refresh_msol_price_list`, `msol_liquid_staking`, `msol_liquid_staking_cpi`, `kamino_deposit_with_farm`, `kamino_deposit_with_farm_cpi`, `kamino_deposit_with_farm_client`, `kamino_borrow_with_farm`, `kamino_borrow_with_farm_cpi`, `kamino_borrow_with_farm_client`, `kamino_repay_with_farm`, `kamino_repay_with_farm_cpi`, `kamino_repay_with_farm_client`, `order_unstake_msol_client`, `order_unstake_msol_cpi`, `claim_msol_cpi`, `kamino_withdraw_with_farm`, `kamino_withdraw_with_farm_cpi`, `kamino_withdraw_with_farm_client`

### `Sell`
- **Discriminator:** `0x33e685a4017f83ad`
- **Args:**
  - `params`: `SellParams`
- **Account variants:**
  - `14 accounts:` `token_a_program`, `token_b_program`, `associated_token_program`, `system_program`, `liquidity_pool_state`, `user`, `token_a_mint`, `token_b_mint`, `user_token_a_vault`, `user_token_b_vault`, `token_a_vault`, `token_b_vault`, `protocol_config`, `instruction_sysvar_account_info`

### `SetProtocolSlotFees`
- **Discriminator:** `0xb552130f7ecd98f2`
- **Args:**
  - `version`: `u16`
  - `fee_type`: `FeeType`
  - `slot_fees`: `SlotFeeBracketsParams`
- **Account variants:**
  - `3 accounts:` `owner`, `protocol_config_state`, `protocol_owner_state`

### `UpdateAllowCreatePool`
- **Discriminator:** `0xdffce73e60dbf1d6`
- **Args:**
  - `version`: `u16`
  - `allow_create_pool`: `bool`
- **Account variants:**
  - `3 accounts:` `admin`, `protocol_config_state`, `protocol_admin_state`

### `UpdateCreatorTradingFeeReceiver`
- **Discriminator:** `0xf6e5c84f1f157819`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `swap`, `new_receiver`

### `UpdateProtocolConfig`
- **Discriminator:** `0xc5617b36dda80b87`
- **Args:**
  - `version`: `u16`
  - `params`: `ProtocolConfigParams`
- **Account variants:**
  - `3 accounts:` `owner`, `protocol_config_state`, `protocol_owner_state`

## CPI events

### `CreateLiquidityPoolEvent`
- **Source:** `instructions/create_liquidity_pool_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d74d8ef8dcfd3b27f`
- **Fields:**
  - `liquidity_pool_id`: `Pubkey`
  - `user`: `Pubkey`
  - `base_token_input_transfer_fee_amount`: `u64`
  - `quote_token_input_transfer_fee_amount`: `u64`
  - `base_token_input_amount`: `u64`
  - `quote_token_input_amount`: `u64`
  - `lp_token_output_amount`: `u64`
  - `locked_lp`: `bool`

### `CreateStandardLiquidityPoolEvent`
- **Source:** `instructions/create_standard_liquidity_pool_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1dbd3883904b3ff994`
- **Fields:**
  - `pool_id`: `Pubkey`
  - `payer`: `Pubkey`
  - `creator`: `Pubkey`
  - `mint`: `Pubkey`
  - `config_version`: `u16`
  - `initial_token_reserve`: `u64`
  - `initial_virtual_wsol_reserve`: `u64`

### `CreatingLiquidityPoolEvent`
- **Source:** `instructions/creating_liquidity_pool_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d348004a67ab054cf`
- **Fields:**
  - `id`: `Pubkey`
  - `base`: `Pubkey`
  - `quote`: `Pubkey`
  - `base_amount`: `u64`
  - `quote_amount`: `u64`

### `TradeEvent`
- **Source:** `instructions/trade_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1dbddb7fd34ee661ee`
- **Fields:**
  - `base_reserve`: `u64`
  - `quote_reserve`: `u64`
  - `total_creator_trading_fees`: `u64`
  - `total_fee_paid`: `u64`

### `UserDefinedEvent`
- **Source:** `instructions/user_defined_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d21156c14f1f4a783`
- **Fields:**
  - `liquidity_pool_id`: `Pubkey`
  - `instruction_name`: `String`
  - `base64_data`: `String`

## Shared types

### `AdminUpdateLiquidityPoolState`
- enum variants:
  - `CreatorTradingFeeClaimStatus(CreatorTradingFeeClaimStatus)`
  - `CreatorTradingFeeDistribution(CreatorTradingFeeDistribution)`
  - `CreatorTradingFeeReceiver(Pubkey)`
  - `FeeConfigurationMode(FeeConfigurationMode)`
  - `SlotOffsetBasedFees { fee_type: FeeType, fees: SlotFeeBrackets }`
  - `MarketCapBasedFees { fee_type: FeeType, fees: FeeBrackets }`
  - `ToggleSwapPermission(bool)`

### `BuyParams`
- `max_sol_spend`: `u64`
- `minimum_amount_out`: `u64`
- `encoded_user_defined_event_data`: `String`

### `CreateStandardLiquidityPoolParams`
- `encoded_user_defined_event_data`: `String`
- `initial_purchase_amount`: `u64`
- `max_sol_spend`: `u64`

### `CreatorTradingFeeClaimStatus`
- enum variants: `Unclaimed`, `Submitted`, `Processed`

### `CreatorTradingFeeDistribution`
- enum variants: `Community`, `Creator`, `Blocked`, `Shared`

### `FeeBracket`
- `market_cap_upper_bound`: `u64`
- `buy_fee_bps`: `u32`
- `sell_fee_bps`: `u32`

### `FeeBrackets`
- `brackets`: `[FeeBracket; 4]`
- `count`: `u8`
- `padding`: `[u8; 7]`

### `FeeConfigurationMode`
- enum variants: `Global`, `Local`

### `FeeType`
- enum variants: `ProtocolFee`, `LiquidityProviderFee`, `CreatorFee`, `CreatorFeeProtocolFee`, `ReflectionFee`

### `LiquidityPoolAllowlist`
- `swap`: `u8`
- `remove_liquidity`: `u8`
- `deposit_liquidity`: `u8`
- `same_slot_trading`: `u8`
- `update_creator_trading_fee`: `u8`
- `padding1`: `[u8; 2]`

### `LiquidityPoolFeatureFlags`
- `sandwich_resistant_mode`: `u8`
- `padding1`: `[u8; 7]`

### `LiquidityPoolInfo`
- `creator`: `Pubkey`
- `update_authority`: `Pubkey`
- `open_at`: `u64`
- `created_at`: `u64`
- `protocol_config_version`: `u16`
- `r_type`: `u8`
- `pool_authority_bump`: `u8`
- `temp_sol_holder_bump`: `u8`
- `pad`: `[u8; 3]`

### `LiquidityPoolLpTokenInfo`
- `supply`: `LiquidityPoolLpTokenSupply`
- `decimals`: `u8`
- `pad`: `[u8; 7]`

### `LiquidityPoolLpTokenSupply`
- `initial`: `u64`
- `total`: `u64`
- `unlocked`: `u64`
- `locked`: `u64`
- `burnt`: `u64`

### `LiquidityPoolMarketCapBasedFees`
- `protocol_trading_fee`: `FeeBrackets`
- `liquidity_provider_trading_fee`: `FeeBrackets`
- `creator_trading_fee`: `FeeBrackets`
- `creator_trading_fee_protocol_fee`: `FeeBrackets`
- `reflection_trading_fee`: `FeeBrackets`

### `LiquidityPoolReserve`
- `token_a`: `u64`
- `token_b`: `u64`
- `snapshot_slot`: `u64`
- `snapshot_a`: `u64`
- `snapshot_b`: `u64`
- `padding`: `u64`
- `initial_a`: `u64`
- `initial_b`: `u64`
- `leader_slot_window`: `u8`
- `pad`: `[u8; 7]`

### `LiquidityPoolSlotOffsetBasedFees`
- `protocol_trading_fee`: `SlotFeeBrackets`
- `liquidity_provider_trading_fee`: `SlotFeeBrackets`
- `creator_trading_fee`: `SlotFeeBrackets`
- `creator_trading_fee_protocol_fee`: `SlotFeeBrackets`
- `reflection_trading_fee`: `SlotFeeBrackets`
- `pad`: `[u8; 6]`

### `LiquidityPoolTokenInfo`
- `mint`: `Pubkey`
- `decimals`: `u8`
- `owner`: `Pubkey`

### `LiquidityPoolType`
- enum variants: `None`, `Pro`, `Standard`

### `ProtocolConfigParams`
- `create_pool_fee`: `u64`
- `allow_create_pool`: `bool`
- `supported_pool_type`: `LiquidityPoolType`
- `market_cap_based_fees`: `LiquidityPoolMarketCapBasedFees`
- `initial_token_b_amount`: `f64`
- `initial_token_a_amount`: `u64`
- `default_leader_slot_window`: `u8`
- `auto_staking_enabled`: `bool`
- `sandwich_resistence_enabled`: `bool`
- `buffer_bps`: `u16`
- `auto_staking_threshold_bps`: `u16`
- `token_a_decimals`: `u8`
- `max_creator_trading_fee`: `u32`
- `max_supply_per_wallet`: `u64`
- `creator_trading_fee_trading_volume_threshold`: `f64`
- `migration_market_cap_threshold`: `u16`

### `SellParams`
- `amount_in`: `u64`
- `minimum_amount_out`: `u64`
- `encoded_user_defined_event_data`: `String`

### `SlotFeeBracket`
- `buy_fee_bps`: `u16`
- `sell_fee_bps`: `u16`
- `slot_offset_upperbound`: `u16`

### `SlotFeeBrackets`
- `brackets`: `[SlotFeeBracket; 42]`
- `max_slot_offset`: `u16`
- `max_fee_bps`: `u16`
- `count`: `u8`
- `enabled`: `u8`
- `padding`: `[u8; 4]`

### `SlotFeeBracketsParams`
- `brackets`: `Vec<SlotFeeBracket>`
- `max_slot_offset`: `u16`
- `max_fee_bps`: `u16`
- `count`: `u8`
- `enabled`: `u8`
