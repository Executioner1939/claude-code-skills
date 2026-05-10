# Orca Whirlpool

- **Crate:** `carbon-orca-whirlpool-decoder`
- **Program ID:** `whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc`
- **Decoder struct:** `OrcaWhirlpoolDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in instructions/ as `*_event.rs`)
- **Discriminator style:** anchor 8-byte

## Account types

### `AdaptiveFeeTier`
- **Discriminator:** `0x931090742f92952e`
- **Fields:**
  - `whirlpools_config`: `Pubkey`
  - `fee_tier_index`: `u16`
  - `tick_spacing`: `u16`
  - `initialize_pool_authority`: `Pubkey`
  - `delegated_fee_authority`: `Pubkey`
  - `default_base_fee_rate`: `u16`
  - `filter_period`: `u16`
  - `decay_period`: `u16`
  - `reduction_factor`: `u16`
  - `adaptive_fee_control_factor`: `u32`
  - `max_volatility_accumulator`: `u32`
  - `tick_group_size`: `u16`
  - `major_swap_threshold_ticks`: `u16`

### `DynamicTickArray`
- **Discriminator:** `0x11d8f68ee1c7da38`
- **Fields:**
  - `start_tick_index`: `i32`
  - `whirlpool`: `Pubkey`
  - `tick_bitmap`: `u128`
  - `ticks`: `[DynamicTick; 88]`

### `FeeTier`
- **Discriminator:** `0x384b9f4c8e44be69`
- **Fields:**
  - `whirlpools_config`: `Pubkey`
  - `tick_spacing`: `u16`
  - `default_fee_rate`: `u16`

### `FixedTickArray`
- **Discriminator:** `0x4561bdbe6e0742bb`
- **Fields:**
  - `start_tick_index`: `i32`
  - `ticks`: `[Tick; 88]`
  - `whirlpool`: `Pubkey`

### `LockConfig`
- **Discriminator:** `0x6a2fee9f7c0ca0c0`
- **Fields:**
  - `position`: `Pubkey`
  - `position_owner`: `Pubkey`
  - `whirlpool`: `Pubkey`
  - `locked_timestamp`: `u64`
  - `lock_type`: `LockTypeLabel`

### `Oracle`
- **Discriminator:** `0x8bc283b38cb3e5f4`
- **Fields:**
  - `whirlpool`: `Pubkey`
  - `trade_enable_timestamp`: `u64`
  - `adaptive_fee_constants`: `AdaptiveFeeConstants`
  - `adaptive_fee_variables`: `AdaptiveFeeVariables`
  - `reserved`: `[u8; 128]`

### `Position`
- **Discriminator:** `0xaabc8fe47a40f7d0`
- **Fields:**
  - `whirlpool`: `Pubkey`
  - `position_mint`: `Pubkey`
  - `liquidity`: `u128`
  - `tick_lower_index`: `i32`
  - `tick_upper_index`: `i32`
  - `fee_growth_checkpoint_a`: `u128`
  - `fee_owed_a`: `u64`
  - `fee_growth_checkpoint_b`: `u128`
  - `fee_owed_b`: `u64`
  - `reward_infos`: `[PositionRewardInfo; 3]`

### `PositionBundle`
- **Discriminator:** `0x81a9af41b95f2064`
- **Fields:**
  - `position_bundle_mint`: `Pubkey`
  - `position_bitmap`: `[u8; 32]`

### `TokenBadge`
- **Discriminator:** `0x74dbcce5f974ff96`
- **Fields:**
  - `whirlpools_config`: `Pubkey`
  - `token_mint`: `Pubkey`

### `Whirlpool`
- **Discriminator:** `0x3f95d10ce1806309`
- **Fields:**
  - `whirlpools_config`: `Pubkey`
  - `whirlpool_bump`: `[u8; 1]`
  - `tick_spacing`: `u16`
  - `fee_tier_index_seed`: `[u8; 2]`
  - `fee_rate`: `u16`
  - `protocol_fee_rate`: `u16`
  - `liquidity`: `u128`
  - `sqrt_price`: `u128`
  - `tick_current_index`: `i32`
  - `protocol_fee_owed_a`: `u64`
  - `protocol_fee_owed_b`: `u64`
  - `token_mint_a`: `Pubkey`
  - `token_vault_a`: `Pubkey`
  - `fee_growth_global_a`: `u128`
  - `token_mint_b`: `Pubkey`
  - `token_vault_b`: `Pubkey`
  - `fee_growth_global_b`: `u128`
  - `reward_last_updated_timestamp`: `u64`
  - `reward_infos`: `[WhirlpoolRewardInfo; 3]`

### `WhirlpoolsConfig`
- **Discriminator:** `0x9d1431e0d957c1fe`
- **Fields:**
  - `fee_authority`: `Pubkey`
  - `collect_protocol_fees_authority`: `Pubkey`
  - `reward_emissions_super_authority`: `Pubkey`
  - `default_protocol_fee_rate`: `u16`

### `WhirlpoolsConfigExtension`
- **Discriminator:** `0x0263d7a3f01a993a`
- **Fields:**
  - `whirlpools_config`: `Pubkey`
  - `config_extension_authority`: `Pubkey`
  - `token_badge_authority`: `Pubkey`

## Instructions

### `InitializeConfig`
- **Discriminator:** `0xd07f1501c2bec446`
- **Args:** `fee_authority: Pubkey`, `collect_protocol_fees_authority: Pubkey`, `reward_emissions_super_authority: Pubkey`, `default_protocol_fee_rate: u16`
- **Account variants:** `3 accounts:` `config, funder, system_program`

### `InitializePool`
- **Discriminator:** `0x5fb40aac54aee828`
- **Args:** `bumps: WhirlpoolBumps`, `tick_spacing: u16`, `initial_sqrt_price: u128`
- **Account variants:** `11 accounts:` `whirlpools_config, token_mint_a, token_mint_b, funder, whirlpool, token_vault_a, token_vault_b, fee_tier, token_program, system_program, rent`

### `InitializePoolV2`
- **Discriminator:** `0xcf2d57f21b3fcc43`
- **Args:** `tick_spacing: u16`, `initial_sqrt_price: u128`
- **Account variants:** `14 accounts:` `whirlpools_config, token_mint_a, token_mint_b, token_badge_a, token_badge_b, funder, whirlpool, token_vault_a, token_vault_b, fee_tier, token_program_a, token_program_b, system_program, rent`

### `InitializePoolWithAdaptiveFee`
- **Discriminator:** `0x8f5e604cac7c77c7`
- **Args:** `initial_sqrt_price: u128`, `trade_enable_timestamp: Option<u64>`
- **Account variants:** `16 accounts:` `whirlpools_config, token_mint_a, token_mint_b, token_badge_a, token_badge_b, funder, initialize_pool_authority, whirlpool, oracle, token_vault_a, token_vault_b, adaptive_fee_tier, token_program_a, token_program_b, system_program, rent`

### `InitializeTickArray`
- **Discriminator:** `0x0bbcc1d68d5b95b8`
- **Args:** `start_tick_index: i32`
- **Account variants:** `4 accounts:` `whirlpool, funder, tick_array, system_program`

### `InitializeFeeTier`
- **Discriminator:** `0xb74a9ca070022a1e`
- **Args:** `tick_spacing: u16`, `default_fee_rate: u16`
- **Account variants:** `5 accounts:` `config, fee_tier, funder, fee_authority, system_program`

### `InitializeAdaptiveFeeTier`
- **Discriminator:** `0x4d63d0c88d7b7530`
- **Args:** `fee_tier_index: u16`, `tick_spacing: u16`, `initialize_pool_authority: Pubkey`, `delegated_fee_authority: Pubkey`, `default_base_fee_rate: u16`, `filter_period: u16`, `decay_period: u16`, `reduction_factor: u16`, `adaptive_fee_control_factor: u32`, `max_volatility_accumulator: u32`, `tick_group_size: u16`, `major_swap_threshold_ticks: u16`
- **Account variants:** `5 accounts:` `whirlpools_config, adaptive_fee_tier, funder, fee_authority, system_program`

### `InitializeReward`
- **Discriminator:** `0x5f87c0c4f281e644`
- **Args:** `reward_index: u8`
- **Account variants:** `8 accounts:` `reward_authority, funder, whirlpool, reward_mint, reward_vault, token_program, system_program, rent`

### `InitializeRewardV2`
- **Discriminator:** `0x5b014d32ebe58531`
- **Args:** `reward_index: u8`
- **Account variants:** `9 accounts:` `reward_authority, funder, whirlpool, reward_mint, reward_token_badge, reward_vault, reward_token_program, system_program, rent`

### `InitializeConfigExtension`
- **Discriminator:** `0x370935097239d134`
- **Account variants:** `5 accounts:` `config, config_extension, funder, fee_authority, system_program`

### `InitializeTokenBadge`
- **Discriminator:** `0xfd4dcd5f1be059df`
- **Account variants:** `7 accounts:` `whirlpools_config, whirlpools_config_extension, token_badge_authority, token_mint, token_badge, funder, system_program`

### `DeleteTokenBadge`
- **Discriminator:** `0x35924408127511b9`
- **Account variants:** `6 accounts:` `whirlpools_config, whirlpools_config_extension, token_badge_authority, token_mint, token_badge, receiver`

### `OpenPosition`
- **Discriminator:** `0x87802f4d0f98f031`
- **Args:** `bumps: OpenPositionBumps`, `tick_lower_index: i32`, `tick_upper_index: i32`
- **Account variants:** `10 accounts:` `funder, owner, position, position_mint, position_token_account, whirlpool, token_program, system_program, rent, associated_token_program`

### `OpenPositionWithMetadata`
- **Discriminator:** `0xf21d86303a6e0e3c`
- **Args:** `bumps: OpenPositionWithMetadataBumps`, `tick_lower_index: i32`, `tick_upper_index: i32`
- **Account variants:** `13 accounts:` `funder, owner, position, position_mint, position_metadata_account, position_token_account, whirlpool, token_program, system_program, rent, associated_token_program, metadata_program, metadata_update_auth`

### `OpenPositionWithTokenExtensions`
- **Discriminator:** `0xd42f5f5c726683fa`
- **Args:** `tick_lower_index: i32`, `tick_upper_index: i32`, `with_token_metadata_extension: bool`
- **Account variants:** `9 accounts:` `funder, owner, position, position_mint, position_token_account, whirlpool, system_program, associated_token_program, metadata_update_auth`

### `OpenBundledPosition`
- **Discriminator:** `0xa9717eabd5acd431`
- **Args:** `bundle_index: u16`, `tick_lower_index: i32`, `tick_upper_index: i32`
- **Account variants:** `8 accounts:` `bundled_position, position_bundle, position_bundle_token_account, position_bundle_authority, whirlpool, funder, system_program, rent`

### `InitializePositionBundle`
- **Discriminator:** `0x752df1951812c241`
- **Account variants:** `9 accounts:` `position_bundle, position_bundle_mint, position_bundle_token_account, position_bundle_owner, funder, token_program, system_program, rent, associated_token_program`

### `InitializePositionBundleWithMetadata`
- **Discriminator:** `0x5d7c10b3f98373f5`
- **Account variants:** `12 accounts:` `position_bundle, position_bundle_mint, position_bundle_metadata, position_bundle_token_account, position_bundle_owner, funder, metadata_update_auth, token_program, system_program, rent, associated_token_program, metadata_program`

### `IncreaseLiquidity`
- **Discriminator:** `0x2e9cf3760dcdfbb2`
- **Args:** `liquidity_amount: u128`, `token_max_a: u64`, `token_max_b: u64`
- **Account variants:** `11 accounts:` `whirlpool, token_program, position_authority, position, position_token_account, token_owner_account_a, token_owner_account_b, token_vault_a, token_vault_b, tick_array_lower, tick_array_upper`

### `IncreaseLiquidityV2`
- **Discriminator:** `0x851d59df45eeb00a`
- **Args:** `liquidity_amount: u128`, `token_max_a: u64`, `token_max_b: u64`, `remaining_accounts_info: Option<RemainingAccountsInfo>`
- **Account variants:** `15 accounts:` `whirlpool, token_program_a, token_program_b, memo_program, position_authority, position, position_token_account, token_mint_a, token_mint_b, token_owner_account_a, token_owner_account_b, token_vault_a, token_vault_b, tick_array_lower, tick_array_upper`

### `DecreaseLiquidity`
- **Discriminator:** `0xa026d06f685b2c01`
- **Args:** `liquidity_amount: u128`, `token_min_a: u64`, `token_min_b: u64`
- **Account variants:** same 11 as `IncreaseLiquidity`

### `DecreaseLiquidityV2`
- **Discriminator:** `0x3a7fbc3e4f52c460`
- **Args:** `liquidity_amount: u128`, `token_min_a: u64`, `token_min_b: u64`, `remaining_accounts_info: Option<RemainingAccountsInfo>`
- **Account variants:** same 15 as `IncreaseLiquidityV2`

### `UpdateFeesAndRewards`
- **Discriminator:** `0x9ae6fa0decd14bdf`
- **Account variants:** `4 accounts:` `whirlpool, position, tick_array_lower, tick_array_upper`

### `CollectFees`
- **Discriminator:** `0xa498cf631eba13b6`
- **Account variants:** `9 accounts:` `whirlpool, position_authority, position, position_token_account, token_owner_account_a, token_vault_a, token_owner_account_b, token_vault_b, token_program`

### `CollectFeesV2`
- **Discriminator:** `0xcf755fbfe5b4e20f`
- **Args:** `remaining_accounts_info: Option<RemainingAccountsInfo>`
- **Account variants:** `13 accounts:` `whirlpool, position_authority, position, position_token_account, token_mint_a, token_mint_b, token_owner_account_a, token_vault_a, token_owner_account_b, token_vault_b, token_program_a, token_program_b, memo_program`

### `CollectProtocolFees`
- **Discriminator:** `0x1643176296b246dc`
- **Account variants:** `8 accounts:` `whirlpools_config, whirlpool, collect_protocol_fees_authority, token_vault_a, token_vault_b, token_destination_a, token_destination_b, token_program`

### `CollectProtocolFeesV2`
- **Discriminator:** `0x6780de8672c816c8`
- **Args:** `remaining_accounts_info: Option<RemainingAccountsInfo>`
- **Account variants:** `12 accounts:` `whirlpools_config, whirlpool, collect_protocol_fees_authority, token_mint_a, token_mint_b, token_vault_a, token_vault_b, token_destination_a, token_destination_b, token_program_a, token_program_b, memo_program`

### `CollectReward`
- **Discriminator:** `0x4605845756ebb122`
- **Args:** `reward_index: u8`
- **Account variants:** `7 accounts:` `whirlpool, position_authority, position, position_token_account, reward_owner_account, reward_vault, token_program`

### `CollectRewardV2`
- **Discriminator:** `0xb16b25b4a01331d1`
- **Args:** `reward_index: u8`, `remaining_accounts_info: Option<RemainingAccountsInfo>`
- **Account variants:** `9 accounts:` `whirlpool, position_authority, position, position_token_account, reward_owner_account, reward_mint, reward_vault, reward_token_program, memo_program`

### `ClosePosition`
- **Discriminator:** `0x7b86510031446262`
- **Account variants:** `6 accounts:` `position_authority, receiver, position, position_mint, position_token_account, token_program`

### `ClosePositionWithTokenExtensions`
- **Discriminator:** `0x01b6873b9b1963df`
- **Account variants:** `5 accounts:` `position_authority, receiver, position, position_mint, position_token_account`

### `CloseBundledPosition`
- **Discriminator:** `0x2924d8f51b556743`
- **Args:** `bundle_index: u16`
- **Account variants:** `5 accounts:` `bundled_position, position_bundle, position_bundle_token_account, position_bundle_authority, receiver`

### `DeletePositionBundle`
- **Discriminator:** `0x64196302d9ef7cad`
- **Account variants:** `6 accounts:` `position_bundle, position_bundle_mint, position_bundle_token_account, position_bundle_owner, receiver, token_program`

### `LockPosition`
- **Discriminator:** `0xe33e02fcf70aabb9`
- **Args:** `lock_type: LockType`
- **Account variants:** `8 accounts:` `funder, position_authority, position, position_mint, position_token_account, lock_config, whirlpool, system_program`

### `TransferLockedPosition`
- **Discriminator:** `0xb379e52e438ac28a`
- **Account variants:** `7 accounts:` `position_authority, receiver, position, position_mint, position_token_account, destination_token_account, lock_config`

### `ResetPositionRange`
- **Discriminator:** `0xa47bb48dc264a0af`
- **Args:** `new_tick_lower_index: i32`, `new_tick_upper_index: i32`
- **Account variants:** `6 accounts:` `funder, position_authority, whirlpool, position, position_token_account, system_program`

### `Swap`
- **Discriminator:** `0xf8c69e91e17587c8`
- **Args:** `amount: u64`, `other_amount_threshold: u64`, `sqrt_price_limit: u128`, `amount_specified_is_input: bool`, `a_to_b: bool`
- **Account variants:** `8 accounts:` `token_program, token_authority, whirlpool, token_owner_account_a, token_vault_a, token_owner_account_b, token_vault_b, oracle`

### `SwapV2`
- **Discriminator:** `0x2b04ed0b1ac91e62`
- **Args:** `amount: u64`, `other_amount_threshold: u64`, `sqrt_price_limit: u128`, `amount_specified_is_input: bool`, `a_to_b: bool`, `remaining_accounts_info: Option<RemainingAccountsInfo>`
- **Account variants:** `12 accounts:` `token_program_a, token_program_b, memo_program, token_authority, whirlpool, token_mint_a, token_mint_b, token_owner_account_a, token_vault_a, token_owner_account_b, token_vault_b, oracle`

### `TwoHopSwap`
- **Discriminator:** `0xc360ed6c44a2dbe6`
- **Args:** `amount: u64`, `other_amount_threshold: u64`, `amount_specified_is_input: bool`, `a_to_b_one: bool`, `a_to_b_two: bool`, `sqrt_price_limit_one: u128`, `sqrt_price_limit_two: u128`
- **Account variants:** `14 accounts:` `token_program, token_authority, whirlpool_one, whirlpool_two, token_owner_account_one_a, token_vault_one_a, token_owner_account_one_b, token_vault_one_b, token_owner_account_two_a, token_vault_two_a, token_owner_account_two_b, token_vault_two_b, oracle_one, oracle_two`

### `TwoHopSwapV2`
- **Discriminator:** `0xba8fd11dfe02c275`
- **Args:** Same as `TwoHopSwap` plus `remaining_accounts_info: Option<RemainingAccountsInfo>`
- **Account variants:** `17 accounts:` `whirlpool_one, whirlpool_two, token_mint_input, token_mint_intermediate, token_mint_output, token_program_input, token_program_intermediate, token_program_output, token_owner_account_input, token_vault_one_input, token_vault_one_intermediate, token_vault_two_intermediate, token_vault_two_output, token_owner_account_output, token_authority, oracle_one, oracle_two, memo_program`

### `SetCollectProtocolFeesAuthority`
- **Discriminator:** `0x22965df48be1e943`
- **Account variants:** `3 accounts:` `whirlpools_config, collect_protocol_fees_authority, new_collect_protocol_fees_authority`

### `SetConfigExtensionAuthority`
- **Discriminator:** `0x2c5ef17418bc3c8f`
- **Account variants:** `4 accounts:` `whirlpools_config, whirlpools_config_extension, config_extension_authority, new_config_extension_authority`

### `SetDefaultBaseFeeRate`
- **Discriminator:** `0xe54254fba486b707`
- **Args:** `default_base_fee_rate: u16`
- **Account variants:** `3 accounts:` `whirlpools_config, adaptive_fee_tier, fee_authority`

### `SetDefaultFeeRate`
- **Discriminator:** `0x76d7d69db6e5d0e4`
- **Args:** `default_fee_rate: u16`
- **Account variants:** `3 accounts:` `whirlpools_config, fee_tier, fee_authority`

### `SetDefaultProtocolFeeRate`
- **Discriminator:** `0x6bcdf9e297235600`
- **Args:** `default_protocol_fee_rate: u16`
- **Account variants:** `2 accounts:` `whirlpools_config, fee_authority`

### `SetDelegatedFeeAuthority`
- **Discriminator:** `0xc1eae7938a39037a`
- **Account variants:** `4 accounts:` `whirlpools_config, adaptive_fee_tier, fee_authority, new_delegated_fee_authority`

### `SetFeeAuthority`
- **Discriminator:** `0x1f013257ed656184`
- **Account variants:** `3 accounts:` `whirlpools_config, fee_authority, new_fee_authority`

### `SetFeeRate`
- **Discriminator:** `0x35f38941088c9e06`
- **Args:** `fee_rate: u16`
- **Account variants:** `3 accounts:` `whirlpools_config, whirlpool, fee_authority`

### `SetFeeRateByDelegatedFeeAuthority`
- **Discriminator:** `0x7979367283e6a268`
- **Args:** `fee_rate: u16`
- **Account variants:** `3 accounts:` `whirlpool, adaptive_fee_tier, delegated_fee_authority`

### `SetInitializePoolAuthority`
- **Discriminator:** `0x7d2b7feb951a6aec`
- **Account variants:** `4 accounts:` `whirlpools_config, adaptive_fee_tier, fee_authority, new_initialize_pool_authority`

### `SetPresetAdaptiveFeeConstants`
- **Discriminator:** `0x84b94294535886c6`
- **Args:** `filter_period: u16`, `decay_period: u16`, `reduction_factor: u16`, `adaptive_fee_control_factor: u32`, `max_volatility_accumulator: u32`, `tick_group_size: u16`, `major_swap_threshold_ticks: u16`
- **Account variants:** `3 accounts:` `whirlpools_config, adaptive_fee_tier, fee_authority`

### `SetProtocolFeeRate`
- **Discriminator:** `0x5f0704329a4f9c83`
- **Args:** `protocol_fee_rate: u16`
- **Account variants:** `3 accounts:` `whirlpools_config, whirlpool, fee_authority`

### `SetRewardAuthority`
- **Discriminator:** `0x2227b7fc531c557f`
- **Args:** `reward_index: u8`
- **Account variants:** `3 accounts:` `whirlpool, reward_authority, new_reward_authority`

### `SetRewardAuthorityBySuperAuthority`
- **Discriminator:** `0xf09ac9c6945d3819`
- **Args:** `reward_index: u8`
- **Account variants:** `4 accounts:` `whirlpools_config, whirlpool, reward_emissions_super_authority, new_reward_authority`

### `SetRewardEmissions`
- **Discriminator:** `0x0dc556a86db01bf4`
- **Args:** `reward_index: u8`
- **Account variants:** `3 accounts:` `whirlpool, reward_authority, reward_vault`

### `SetRewardEmissionsV2`
- **Discriminator:** `0x72e44820c130a066`
- **Args:** `reward_index: u8`
- **Account variants:** `3 accounts:` `whirlpool, reward_authority, reward_vault`

### `SetRewardEmissionsSuperAuthority`
- **Discriminator:** `0xcf05c8d17a3852b7`
- **Account variants:** `3 accounts:` `whirlpools_config, reward_emissions_super_authority, new_reward_emissions_super_authority`

### `SetTokenBadgeAuthority`
- **Discriminator:** `0xcfca0420cd4f0db2`
- **Account variants:** `4 accounts:` `whirlpools_config, whirlpools_config_extension, config_extension_authority, new_token_badge_authority`

## CPI events

### `LiquidityDecreasedEvent`
- **Source:** `instructions/liquidity_decreased_event.rs`
- **Discriminator:** `0xa601244770cab5ab`
- **Fields:**
  - `whirlpool`: `Pubkey`
  - `position`: `Pubkey`
  - `tick_lower_index`: `i32`
  - `tick_upper_index`: `i32`
  - `liquidity`: `u128`
  - `token_a_amount`: `u64`
  - `token_b_amount`: `u64`
  - `token_a_transfer_fee`: `u64`
  - `token_b_transfer_fee`: `u64`

### `LiquidityIncreasedEvent`
- **Source:** `instructions/liquidity_increased_event.rs`
- **Discriminator:** `0x1e0790b566fe9ba1`
- **Fields:** Same as `LiquidityDecreasedEvent`.

### `PoolInitializedEvent`
- **Source:** `instructions/pool_initialized_event.rs`
- **Discriminator:** `0x6476ad570cc6fee5`
- **Fields:**
  - `whirlpool`: `Pubkey`
  - `whirlpools_config`: `Pubkey`
  - `token_mint_a`: `Pubkey`
  - `token_mint_b`: `Pubkey`
  - `tick_spacing`: `u16`
  - `token_program_a`: `Pubkey`
  - `token_program_b`: `Pubkey`
  - `decimals_a`: `u8`
  - `decimals_b`: `u8`
  - `initial_sqrt_price`: `u128`

### `TradedEvent`
- **Source:** `instructions/traded_event.rs`
- **Discriminator:** `0xe1ca49af932ba096`
- **Fields:**
  - `whirlpool`: `Pubkey`
  - `a_to_b`: `bool`
  - `pre_sqrt_price`: `u128`
  - `post_sqrt_price`: `u128`
  - `input_amount`: `u64`
  - `output_amount`: `u64`
  - `input_transfer_fee`: `u64`
  - `output_transfer_fee`: `u64`
  - `lp_fee`: `u64`
  - `protocol_fee`: `u64`

## Shared types

### `Tick`
- `initialized`: `bool`
- `liquidity_net`: `i128`
- `liquidity_gross`: `u128`
- `fee_growth_outside_a`: `u128`
- `fee_growth_outside_b`: `u128`
- `reward_growths_outside`: `[u128; 3]`

### `DynamicTick` (enum)
- `Uninitialized | Initialized(DynamicTickData)`

### `PositionRewardInfo`
- `growth_inside_checkpoint`: `u128`
- `amount_owed`: `u64`

### `WhirlpoolRewardInfo`
- `mint`: `Pubkey`
- `vault`: `Pubkey`
- `authority`: `Pubkey`
- `emissions_per_second_x64`: `u128`
- `growth_global_x64`: `u128`

### `AdaptiveFeeConstants`
- `filter_period`: `u16`
- `decay_period`: `u16`
- `reduction_factor`: `u16`
- `adaptive_fee_control_factor`: `u32`
- `max_volatility_accumulator`: `u32`
- `tick_group_size`: `u16`
- `major_swap_threshold_ticks`: `u16`
- `reserved`: `[u8; 16]`

### `AdaptiveFeeVariables`
- `last_reference_update_timestamp`: `u64`
- `last_major_swap_timestamp`: `u64`
- `volatility_reference`: `u32`
- `tick_group_index_reference`: `i32`
- `volatility_accumulator`: `u32`
- `reserved`: `[u8; 16]`

### `WhirlpoolBumps`
- `whirlpool_bump`: `u8`

### `OpenPositionBumps`
- `position_bump`: `u8`

### `OpenPositionWithMetadataBumps`
- `position_bump`: `u8`
- `metadata_bump`: `u8`

### `RemainingAccountsInfo`
- `slices`: `Vec<RemainingAccountsSlice>`

### `RemainingAccountsSlice`
- `accounts_type`: `AccountsType`
- `length`: `u8`

### `AccountsType` (enum)
- `TransferHookA | TransferHookB | TransferHookReward | TransferHookInput | TransferHookIntermediate | TransferHookOutput | SupplementalTickArrays | SupplementalTickArraysOne | SupplementalTickArraysTwo`

### `LockType` (enum)
- `Permanent`

### `LockTypeLabel` (enum)
- `Permanent`
