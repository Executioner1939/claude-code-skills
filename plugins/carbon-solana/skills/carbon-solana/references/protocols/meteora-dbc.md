# Meteora Dynamic Bonding Curve (DBC)

- **Crate:** `carbon-meteora-dbc-decoder`
- **Program ID:** `dbcij3LWUppWqq96dh6gJWwBifmcGfLSB5D4DuSMaqN`
- **Decoder struct:** `DynamicBondingCurveDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in instructions/)
- **Discriminator style:** anchor 8-byte (events 16-byte)

## Account types

### `ClaimFeeOperator`
- **Discriminator:** `0xa630865622c8bc96`
- **Fields:**
  - `operator`: `Pubkey`
  - `padding`: `[u8; 128]`

### `Config`
- **Discriminator:** `0x9b0caae01efacc82`
- **Fields:**
  - `pool_fees`: `PoolFees`
  - `activation_duration`: `u64`
  - `vault_config_key`: `Pubkey`
  - `pool_creator_authority`: `Pubkey`
  - `activation_type`: `u8`
  - `partner_fee_numerator`: `u64`
  - `padding`: `[u8; 219]`

### `LockEscrow`
- **Discriminator:** `0xbe6a7906c8b6154b`
- **Fields:**
  - `pool`: `Pubkey`
  - `owner`: `Pubkey`
  - `escrow_vault`: `Pubkey`
  - `bump`: `u8`
  - `total_locked_amount`: `u64`
  - `lp_per_token`: `u128`
  - `unclaimed_fee_pending`: `u64`
  - `a_fee`: `u64`
  - `b_fee`: `u64`

### `MeteoraDammMigrationMetadata`
- **Discriminator:** `0x119b8dd7cf04859c`
- **Fields:**
  - `virtual_pool`: `Pubkey`
  - `padding_0`: `[u8; 32]`
  - `partner`: `Pubkey`
  - `lp_mint`: `Pubkey`
  - `partner_locked_lp`: `u64`
  - `partner_lp`: `u64`
  - `creator_locked_lp`: `u64`
  - `creator_lp`: `u64`
  - `_padding_0`: `u8`
  - `creator_locked_status`: `u8`
  - `partner_locked_status`: `u8`
  - `creator_claim_status`: `u8`
  - `partner_claim_status`: `u8`
  - `padding`: `[u8; 107]`

### `MeteoraDammV2Metadata`
- **Discriminator:** `0x68dddbcb0a8efaa3`
- **Fields:**
  - `virtual_pool`: `Pubkey`
  - `padding_0`: `[u8; 32]`
  - `partner`: `Pubkey`
  - `padding`: `[u8; 126]`

### `PartnerMetadata`
- **Discriminator:** `0x4444821310d1629c`
- **Fields:**
  - `fee_claimer`: `Pubkey`
  - `padding`: `[u128; 6]`
  - `name`: `String`
  - `website`: `String`
  - `logo`: `String`

### `PoolConfig`
- **Discriminator:** `0x1a6c0e7b74e6812b`
- **Fields:**
  - `quote_mint`: `Pubkey`
  - `fee_claimer`: `Pubkey`
  - `leftover_receiver`: `Pubkey`
  - `pool_fees`: `PoolFeesConfig`
  - `collect_fee_mode`: `u8`
  - `migration_option`: `u8`
  - `activation_type`: `u8`
  - `token_decimal`: `u8`
  - `version`: `u8`
  - `token_type`: `u8`
  - `quote_token_flag`: `u8`
  - `partner_locked_lp_percentage`: `u8`
  - `partner_lp_percentage`: `u8`
  - `creator_locked_lp_percentage`: `u8`
  - `creator_lp_percentage`: `u8`
  - `migration_fee_option`: `u8`
  - `fixed_token_supply_flag`: `u8`
  - `creator_trading_fee_percentage`: `u8`
  - `token_update_authority`: `u8`
  - `migration_fee_percentage`: `u8`
  - `creator_migration_fee_percentage`: `u8`
  - `padding_0`: `[u8; 7]`
  - `swap_base_amount`: `u64`
  - `migration_quote_threshold`: `u64`
  - `migration_base_threshold`: `u64`
  - `migration_sqrt_price`: `u128`
  - `locked_vesting_config`: `LockedVestingConfig`
  - `pre_migration_token_supply`: `u64`
  - `post_migration_token_supply`: `u64`
  - `migrated_collect_fee_mode`: `u8`
  - `migrated_dynamic_fee`: `u8`
  - `migrated_pool_fee_bps`: `u16`
  - `padding_1`: `[u8; 12]`
  - `padding_2`: `u128`
  - `sqrt_start_price`: `u128`
  - `curve`: `[LiquidityDistributionConfig; 20]`

### `VirtualPool`
- **Discriminator:** `0xd5e005d16245775c`
- **Fields:**
  - `volatility_tracker`: `VolatilityTracker`
  - `config`: `Pubkey`
  - `creator`: `Pubkey`
  - `base_mint`: `Pubkey`
  - `base_vault`: `Pubkey`
  - `quote_vault`: `Pubkey`
  - `base_reserve`: `u64`
  - `quote_reserve`: `u64`
  - `protocol_base_fee`: `u64`
  - `protocol_quote_fee`: `u64`
  - `partner_base_fee`: `u64`
  - `partner_quote_fee`: `u64`
  - `sqrt_price`: `u128`
  - `activation_point`: `u64`
  - `pool_type`: `u8`
  - `is_migrated`: `u8`
  - `is_partner_withdraw_surplus`: `u8`
  - `is_protocol_withdraw_surplus`: `u8`
  - `migration_progress`: `u8`
  - `is_withdraw_leftover`: `u8`
  - `is_creator_withdraw_surplus`: `u8`
  - `migration_fee_withdraw_status`: `u8`
  - `metrics`: `PoolMetrics`
  - `finish_curve_timestamp`: `u64`
  - `creator_base_fee`: `u64`
  - `creator_quote_fee`: `u64`
  - `padding_1`: `[u64; 7]`

### `VirtualPoolMetadata`
- **Discriminator:** `0xd92552fa2b2fe4fe`
- **Fields:**
  - `virtual_pool`: `Pubkey`
  - `padding`: `[u128; 6]`
  - `name`: `String`
  - `website`: `String`
  - `logo`: `String`

## Instructions

### `ClaimCreatorTradingFee`
- **Discriminator:** `0x52dcfabd03556b2d`
- **Args:**
  - `max_base_amount`: `u64`
  - `max_quote_amount`: `u64`
- **Account variants:**
  - `13 accounts:` `pool_authority`, `pool`, `token_a_account`, `token_b_account`, `base_vault`, `quote_vault`, `base_mint`, `quote_mint`, `creator`, `token_base_program`, `token_quote_program`, `event_authority`, `program`

### `ClaimProtocolFee`
- **Discriminator:** `0xa5e4853063f9ff21`
- **Args:** (none)
- **Account variants:**
  - `15 accounts:` `pool_authority`, `config`, `pool`, `base_vault`, `quote_vault`, `base_mint`, `quote_mint`, `token_base_account`, `token_quote_account`, `claim_fee_operator`, `operator`, `token_base_program`, `token_quote_program`, `event_authority`, `program`

### `ClaimTradingFee`
- **Discriminator:** `0x08ec5931987db151`
- **Args:**
  - `max_amount_a`: `u64`
  - `max_amount_b`: `u64`
- **Account variants:**
  - `14 accounts:` `pool_authority`, `config`, `pool`, `token_a_account`, `token_b_account`, `base_vault`, `quote_vault`, `base_mint`, `quote_mint`, `fee_claimer`, `token_base_program`, `token_quote_program`, `event_authority`, `program`

### `CloseClaimFeeOperator`
- **Discriminator:** `0x268652d85f7c1163`
- **Args:** (none)
- **Account variants:**
  - `5 accounts:` `claim_fee_operator`, `rent_receiver`, `admin`, `event_authority`, `program`

### `CreateClaimFeeOperator`
- **Discriminator:** `0xa93ecf6b3abba26d`
- **Args:** (none)
- **Account variants:**
  - `6 accounts:` `claim_fee_operator`, `operator`, `admin`, `system_program`, `event_authority`, `program`

### `CreateConfig`
- **Discriminator:** `0xc9cff3724b6f2fbd`
- **Args:**
  - `config_parameters`: `ConfigParameters`
- **Account variants:**
  - `8 accounts:` `config`, `fee_claimer`, `leftover_receiver`, `quote_mint`, `payer`, `system_program`, `event_authority`, `program`

### `CreateLocker`
- **Discriminator:** `0xa75a899a4b2f1154`
- **Args:** (none)
- **Account variants:**
  - `14 accounts:` `virtual_pool`, `config`, `pool_authority`, `base_vault`, `base_mint`, `base`, `creator`, `escrow`, `escrow_token`, `payer`, `token_program`, `locker_program`, `locker_event_authority`, `system_program`

### `CreatePartnerMetadata`
- **Discriminator:** `0xc0a8eabfbce2e3ff`
- **Args:**
  - `metadata`: `CreatePartnerMetadataParameters`
- **Account variants:**
  - `6 accounts:` `partner_metadata`, `payer`, `fee_claimer`, `system_program`, `event_authority`, `program`

### `CreateVirtualPoolMetadata`
- **Discriminator:** `0x2d61bb67fe6d7c86`
- **Args:**
  - `metadata`: `CreateVirtualPoolMetadataParameters`
- **Account variants:**
  - `7 accounts:` `virtual_pool`, `virtual_pool_metadata`, `creator`, `payer`, `system_program`, `event_authority`, `program`

### `CreatorWithdrawSurplus`
- **Discriminator:** `0xa50389071c864c50`
- **Args:** (none)
- **Account variants:**
  - `10 accounts:` `pool_authority`, `config`, `virtual_pool`, `token_quote_account`, `quote_vault`, `quote_mint`, `creator`, `token_quote_program`, `event_authority`, `program`

### `EvtClaimCreatorTradingFeeEvent`
- **Discriminator:** `0xe445a52e51cb9a1d9ae4d7ca859bd68a`
- **Args:**
  - `pool`: `Pubkey`
  - `token_base_amount`: `u64`
  - `token_quote_amount`: `u64`

### `EvtClaimProtocolFeeEvent`
- **Discriminator:** `0xe445a52e51cb9a1dbaf44bfbbc0d1921`
- **Args:**
  - `pool`: `Pubkey`
  - `token_base_amount`: `u64`
  - `token_quote_amount`: `u64`

### `EvtClaimTradingFeeEvent`
- **Discriminator:** `0xe445a52e51cb9a1d1a5375f05cca70fe`
- **Args:**
  - `pool`: `Pubkey`
  - `token_base_amount`: `u64`
  - `token_quote_amount`: `u64`

### `EvtCloseClaimFeeOperatorEvent`
- **Discriminator:** `0xe445a52e51cb9a1d6f2725376ed8c217`
- **Args:**
  - `claim_fee_operator`: `Pubkey`
  - `operator`: `Pubkey`

### `EvtCreateClaimFeeOperatorEvent`
- **Discriminator:** `0xe445a52e51cb9a1d1506997844741cb1`
- **Args:**
  - `operator`: `Pubkey`

### `EvtCreateConfigEvent`
- **Discriminator:** `0xe445a52e51cb9a1d83cfb4aeb449a536`
- **Args:**
  - `config`: `Pubkey`
  - `quote_mint`: `Pubkey`
  - `fee_claimer`: `Pubkey`
  - `owner`: `Pubkey`
  - `pool_fees`: `PoolFeeParameters`
  - `collect_fee_mode`: `u8`
  - `migration_option`: `u8`
  - `activation_type`: `u8`
  - `token_decimal`: `u8`
  - `token_type`: `u8`
  - `partner_locked_lp_percentage`: `u8`
  - `partner_lp_percentage`: `u8`
  - `creator_locked_lp_percentage`: `u8`
  - `creator_lp_percentage`: `u8`
  - `swap_base_amount`: `u64`
  - `migration_quote_threshold`: `u64`
  - `migration_base_amount`: `u64`
  - `sqrt_start_price`: `u128`
  - `locked_vesting`: `LockedVestingParams`
  - `migration_fee_option`: `u8`
  - `fixed_token_supply_flag`: `u8`
  - `pre_migration_token_supply`: `u64`
  - `post_migration_token_supply`: `u64`
  - `curve`: `Vec<LiquidityDistributionParameters>`

### `EvtCreateConfigV2Event`
- **Discriminator:** `0xe445a52e51cb9a1da34a42bb77c31a90`
- **Args:**
  - `config`: `Pubkey`
  - `quote_mint`: `Pubkey`
  - `fee_claimer`: `Pubkey`
  - `leftover_receiver`: `Pubkey`
  - `config_parameters`: `ConfigParameters`

### `EvtCreateDammV2MigrationMetadataEvent`
- **Discriminator:** `0xe445a52e51cb9a1d676f84a88cfd9672`
- **Args:**
  - `virtual_pool`: `Pubkey`

### `EvtCreateMeteoraMigrationMetadataEvent`
- **Discriminator:** `0xe445a52e51cb9a1d63a7853fd68faf8b`
- **Args:**
  - `virtual_pool`: `Pubkey`

### `EvtCreatorWithdrawSurplusEvent`
- **Discriminator:** `0xe445a52e51cb9a1d9849150f4257359d`
- **Args:**
  - `pool`: `Pubkey`
  - `surplus_amount`: `u64`

### `EvtCurveCompleteEvent`
- **Discriminator:** `0xe445a52e51cb9a1de5e756549c864b18`
- **Args:**
  - `pool`: `Pubkey`
  - `config`: `Pubkey`
  - `base_reserve`: `u64`
  - `quote_reserve`: `u64`

### `EvtInitializePoolEvent`
- **Discriminator:** `0xe445a52e51cb9a1de432f655cb428625`
- **Args:**
  - `pool`: `Pubkey`
  - `config`: `Pubkey`
  - `creator`: `Pubkey`
  - `base_mint`: `Pubkey`
  - `pool_type`: `u8`
  - `activation_point`: `u64`

### `EvtPartnerMetadataEvent`
- **Discriminator:** `0xe445a52e51cb9a1dc87f06370d200896`
- **Args:**
  - `partner_metadata`: `Pubkey`
  - `fee_claimer`: `Pubkey`

### `EvtPartnerWithdrawMigrationFeeEvent`
- **Discriminator:** `0xe445a52e51cb9a1db5697f4308bb7839`
- **Args:**
  - `pool`: `Pubkey`
  - `fee`: `u64`

### `EvtPartnerWithdrawSurplusEvent`
- **Discriminator:** `0xe445a52e51cb9a1dc3389809e8482316`
- **Args:**
  - `pool`: `Pubkey`
  - `surplus_amount`: `u64`

### `EvtProtocolWithdrawSurplusEvent`
- **Discriminator:** `0xe445a52e51cb9a1d6d6f1cdd86c3e6cb`
- **Args:**
  - `pool`: `Pubkey`
  - `surplus_amount`: `u64`

### `EvtSwap2Event`
- **Discriminator:** `0xe445a52e51cb9a1dbd4233a826507599`
- **Args:**
  - `pool`: `Pubkey`
  - `config`: `Pubkey`
  - `trade_direction`: `u8`
  - `has_referral`: `bool`
  - `swap_parameters`: `SwapParameters2`
  - `swap_result`: `SwapResult2`
  - `quote_reserve_amount`: `u64`
  - `migration_threshold`: `u64`
  - `current_timestamp`: `u64`

### `EvtSwapEvent`
- **Discriminator:** `0xe445a52e51cb9a1d1b3c15d58aaabb93`
- **Args:**
  - `pool`: `Pubkey`
  - `config`: `Pubkey`
  - `trade_direction`: `u8`
  - `has_referral`: `bool`
  - `params`: `SwapParameters`
  - `swap_result`: `SwapResult`
  - `amount_in`: `u64`
  - `current_timestamp`: `u64`

### `EvtUpdatePoolCreatorEvent`
- **Discriminator:** `0xe445a52e51cb9a1d6be1a5ed5b9ed5dc`
- **Args:**
  - `pool`: `Pubkey`
  - `creator`: `Pubkey`
  - `new_creator`: `Pubkey`

### `EvtVirtualPoolMetadataEvent`
- **Discriminator:** `0xe445a52e51cb9a1dbc12484cc35b264a`
- **Args:**
  - `virtual_pool_metadata`: `Pubkey`
  - `virtual_pool`: `Pubkey`

### `EvtWithdrawLeftoverEvent`
- **Discriminator:** `0xe445a52e51cb9a1dbfbd688f6f9c5ee5`
- **Args:**
  - `pool`: `Pubkey`
  - `leftover_receiver`: `Pubkey`
  - `leftover_amount`: `u64`

### `EvtWithdrawMigrationFeeEvent`
- **Discriminator:** `0xe445a52e51cb9a1d1acb5455a11764d6`
- **Args:**
  - `pool`: `Pubkey`
  - `fee`: `u64`
  - `flag`: `u8`

### `InitializeVirtualPoolWithSplToken`
- **Discriminator:** `0x8c55d7b06636684f`
- **Args:**
  - `params`: `InitializePoolParameters`
- **Account variants:**
  - `16 accounts:` `config`, `pool_authority`, `creator`, `base_mint`, `quote_mint`, `pool`, `base_vault`, `quote_vault`, `mint_metadata`, `metadata_program`, `payer`, `token_quote_program`, `token_program`, `system_program`, `event_authority`, `program`

### `InitializeVirtualPoolWithToken2022`
- **Discriminator:** `0xa976334e916edc9b`
- **Args:**
  - `params`: `InitializePoolParameters`
- **Account variants:**
  - `14 accounts:` `config`, `pool_authority`, `creator`, `base_mint`, `quote_mint`, `pool`, `base_vault`, `quote_vault`, `payer`, `token_quote_program`, `token_program`, `system_program`, `event_authority`, `program`

### `MigrateMeteoraDamm`
- **Discriminator:** `0x1b013016b43f76d9`
- **Args:** (none)
- **Account variants:**
  - `30 accounts:` `virtual_pool`, `migration_metadata`, `config`, `pool_authority`, `pool`, `damm_config`, `lp_mint`, `token_a_mint`, `token_b_mint`, `a_vault`, `b_vault`, `a_token_vault`, `b_token_vault`, `a_vault_lp_mint`, `b_vault_lp_mint`, `a_vault_lp`, `b_vault_lp`, `base_vault`, `quote_vault`, `virtual_pool_lp`, `protocol_token_a_fee`, `protocol_token_b_fee`, `payer`, `rent`, `mint_metadata`, `metadata_program`, `amm_program`, `vault_program`, `token_program`, `associated_token_program`, `system_program`

### `MigrateMeteoraDammClaimLpToken`
- **Discriminator:** `0x8b85021e5b917f9a`
- **Args:** (none)
- **Account variants:**
  - `9 accounts:` `virtual_pool`, `migration_metadata`, `pool_authority`, `lp_mint`, `source_token`, `destination_token`, `owner`, `sender`, `token_program`

### `MigrateMeteoraDammLockLpToken`
- **Discriminator:** `0xb137ee9dfb58a52a`
- **Args:** (none)
- **Account variants:**
  - `16 accounts:` `virtual_pool`, `migration_metadata`, `pool_authority`, `pool`, `lp_mint`, `lock_escrow`, `owner`, `source_tokens`, `escrow_vault`, `amm_program`, `a_vault`, `b_vault`, `a_vault_lp`, `b_vault_lp`, `a_vault_lp_mint`, `b_vault_lp_mint`, `token_program`

### `MigrationDammV2`
- **Discriminator:** `0x9ca9e66735e45040`
- **Args:** (none)
- **Account variants:**
  - `25 accounts:` `virtual_pool`, `migration_metadata`, `config`, `pool_authority`, `pool`, `first_position_nft_mint`, `first_position_nft_account`, `first_position`, `second_position_nft_mint`, `second_position_nft_account`, `second_position`, `damm_pool_authority`, `amm_program`, `base_mint`, `quote_mint`, `token_a_vault`, `token_b_vault`, `base_vault`, `quote_vault`, `payer`, `token_base_program`, `token_quote_program`, `token_2022_program`, `damm_event_authority`, `system_program`

### `MigrationDammV2CreateMetadata`
- **Discriminator:** `0x6dbd1324c3b7de52`
- **Args:** (none)
- **Account variants:**
  - `7 accounts:` `virtual_pool`, `config`, `migration_metadata`, `payer`, `system_program`, `event_authority`, `program`

### `MigrationMeteoraDammCreateMetadata`
- **Discriminator:** `0x2f5e7e73dde2c285`
- **Args:** (none)
- **Account variants:**
  - `7 accounts:` `virtual_pool`, `config`, `migration_metadata`, `payer`, `system_program`, `event_authority`, `program`

### `PartnerWithdrawSurplus`
- **Discriminator:** `0xa8ad4864c962265c`
- **Args:** (none)
- **Account variants:**
  - `10 accounts:` `pool_authority`, `config`, `virtual_pool`, `token_quote_account`, `quote_vault`, `quote_mint`, `fee_claimer`, `token_quote_program`, `event_authority`, `program`

### `ProtocolWithdrawSurplus`
- **Discriminator:** `0x3688e18aacb6d6a7`
- **Args:** (none)
- **Account variants:**
  - `9 accounts:` `pool_authority`, `config`, `virtual_pool`, `token_quote_account`, `quote_vault`, `quote_mint`, `token_quote_program`, `event_authority`, `program`

### `Swap`
- **Discriminator:** `0xf8c69e91e17587c8`
- **Args:**
  - `params`: `SwapParameters`
- **Account variants:**
  - `15 accounts:` `pool_authority`, `config`, `pool`, `input_token_account`, `output_token_account`, `base_vault`, `quote_vault`, `base_mint`, `quote_mint`, `payer`, `token_base_program`, `token_quote_program`, `referral_token_account`, `event_authority`, `program`

### `Swap2`
- **Discriminator:** `0x414b3f4ceb5b5b88`
- **Args:**
  - `params`: `SwapParameters2`
- **Account variants:**
  - `15 accounts:` `pool_authority`, `config`, `pool`, `input_token_account`, `output_token_account`, `base_vault`, `quote_vault`, `base_mint`, `quote_mint`, `payer`, `token_base_program`, `token_quote_program`, `referral_token_account`, `event_authority`, `program`

### `TransferPoolCreator`
- **Discriminator:** `0x1407a9213a93a621`
- **Args:** (none)
- **Account variants:**
  - `6 accounts:` `virtual_pool`, `config`, `creator`, `new_creator`, `event_authority`, `program`

### `WithdrawLeftover`
- **Discriminator:** `0x14c6caedebf3b742`
- **Args:** (none)
- **Account variants:**
  - `10 accounts:` `pool_authority`, `config`, `virtual_pool`, `token_base_account`, `base_vault`, `base_mint`, `leftover_receiver`, `token_base_program`, `event_authority`, `program`

### `WithdrawMigrationFee`
- **Discriminator:** `0xed8e2d178106dea2`
- **Args:**
  - `flag`: `u8`
- **Account variants:**
  - `10 accounts:` `pool_authority`, `config`, `virtual_pool`, `token_quote_account`, `quote_vault`, `quote_mint`, `sender`, `token_quote_program`, `event_authority`, `program`

## Shared types

### `BaseFeeConfig`
- `cliff_fee_numerator`: `u64`
- `second_factor`: `u64`
- `third_factor`: `u64`
- `first_factor`: `u16`
- `base_fee_mode`: `u8`
- `padding_0`: `[u8; 5]`

### `BaseFeeParameters`
- `cliff_fee_numerator`: `u64`
- `first_factor`: `u16`
- `second_factor`: `u64`
- `third_factor`: `u64`
- `base_fee_mode`: `u8`

### `ConfigParameters`
- `pool_fees`: `PoolFeeParameters`
- `collect_fee_mode`: `u8`
- `migration_option`: `u8`
- `activation_type`: `u8`
- `token_type`: `u8`
- `token_decimal`: `u8`
- `partner_lp_percentage`: `u8`
- `partner_locked_lp_percentage`: `u8`
- `creator_lp_percentage`: `u8`
- `creator_locked_lp_percentage`: `u8`
- `migration_quote_threshold`: `u64`
- `sqrt_start_price`: `u128`
- `locked_vesting`: `LockedVestingParams`
- `migration_fee_option`: `u8`
- `token_supply`: `Option<TokenSupplyParams>`
- `creator_trading_fee_percentage`: `u8`
- `token_update_authority`: `u8`
- `migration_fee`: `MigrationFee`
- `migrated_pool_fee`: `MigratedPoolFee`
- `padding`: `[u64; 7]`
- `curve`: `Vec<LiquidityDistributionParameters>`

### `CreatePartnerMetadataParameters`
- `padding`: `[u8; 96]`
- `name`: `String`
- `website`: `String`
- `logo`: `String`

### `CreateVirtualPoolMetadataParameters`
- `padding`: `[u8; 96]`
- `name`: `String`
- `website`: `String`
- `logo`: `String`

### `DynamicFeeConfig`
- `initialized`: `u8`
- `padding`: `[u8; 7]`
- `max_volatility_accumulator`: `u32`
- `variable_fee_control`: `u32`
- `bin_step`: `u16`
- `filter_period`: `u16`
- `decay_period`: `u16`
- `reduction_factor`: `u16`
- `padding2`: `[u8; 8]`
- `bin_step_u128`: `u128`

### `DynamicFeeParameters`
- `bin_step`: `u16`
- `bin_step_u128`: `u128`
- `filter_period`: `u16`
- `decay_period`: `u16`
- `reduction_factor`: `u16`
- `max_volatility_accumulator`: `u32`
- `variable_fee_control`: `u32`

### `InitializePoolParameters`
- `name`: `String`
- `symbol`: `String`
- `uri`: `String`

### `LiquidityDistributionConfig`
- `sqrt_price`: `u128`
- `liquidity`: `u128`

### `LiquidityDistributionParameters`
- `sqrt_price`: `u128`
- `liquidity`: `u128`

### `LockedVestingConfig`
- `amount_per_period`: `u64`
- `cliff_duration_from_migration_time`: `u64`
- `frequency`: `u64`
- `number_of_period`: `u64`
- `cliff_unlock_amount`: `u64`
- `padding`: `u64`

### `LockedVestingParams`
- `amount_per_period`: `u64`
- `cliff_duration_from_migration_time`: `u64`
- `frequency`: `u64`
- `number_of_period`: `u64`
- `cliff_unlock_amount`: `u64`

### `MigratedPoolFee`
- `collect_fee_mode`: `u8`
- `dynamic_fee`: `u8`
- `pool_fee_bps`: `u16`

### `MigrationFee`
- `fee_percentage`: `u8`
- `creator_fee_percentage`: `u8`

### `PoolFeeParameters`
- `base_fee`: `BaseFeeParameters`
- `dynamic_fee`: `Option<DynamicFeeParameters>`

### `PoolFees`
- `trade_fee_numerator`: `u64`
- `trade_fee_denominator`: `u64`
- `protocol_trade_fee_numerator`: `u64`
- `protocol_trade_fee_denominator`: `u64`

### `PoolFeesConfig`
- `base_fee`: `BaseFeeConfig`
- `dynamic_fee`: `DynamicFeeConfig`
- `padding_0`: `[u64; 5]`
- `padding_1`: `[u8; 6]`
- `protocol_fee_percent`: `u8`
- `referral_fee_percent`: `u8`

### `PoolMetrics`
- `total_protocol_base_fee`: `u64`
- `total_protocol_quote_fee`: `u64`
- `total_trading_base_fee`: `u64`
- `total_trading_quote_fee`: `u64`

### `SwapParameters`
- `amount_in`: `u64`
- `minimum_amount_out`: `u64`

### `SwapParameters2`
- `amount_0`: `u64`
- `amount_1`: `u64`
- `swap_mode`: `u8`

### `SwapResult`
- `actual_input_amount`: `u64`
- `output_amount`: `u64`
- `next_sqrt_price`: `u128`
- `trading_fee`: `u64`
- `protocol_fee`: `u64`
- `referral_fee`: `u64`

### `SwapResult2`
- `included_fee_input_amount`: `u64`
- `excluded_fee_input_amount`: `u64`
- `amount_left`: `u64`
- `output_amount`: `u64`
- `next_sqrt_price`: `u128`
- `trading_fee`: `u64`
- `protocol_fee`: `u64`
- `referral_fee`: `u64`

### `TokenSupplyParams`
- `pre_migration_token_supply`: `u64`
- `post_migration_token_supply`: `u64`

### `VolatilityTracker`
- `last_update_timestamp`: `u64`
- `padding`: `[u8; 8]`
- `sqrt_price_reference`: `u128`
- `volatility_accumulator`: `u128`
- `volatility_reference`: `u128`
