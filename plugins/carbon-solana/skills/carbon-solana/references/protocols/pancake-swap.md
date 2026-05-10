# Pancake Swap

- **Crate:** `carbon-pancake-swap-decoder`
- **Program ID:** `HpNfyc2Saw7RKkQd8nEL4khUcuPhQ7WwY1B2qjx8jxFq`
- **Decoder struct:** `PancakeSwapDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in instructions/)
- **Discriminator style:** anchor 8-byte

## Account types

### `AmmConfig`
- **Fields:**
  - `bump`: `u8`
  - `index`: `u16`
  - `owner`: `Pubkey`
  - `protocol_fee_rate`: `u32`
  - `trade_fee_rate`: `u32`
  - `tick_spacing`: `u16`
  - `fund_fee_rate`: `u32`
  - `padding_u32`: `u32`
  - `fund_owner`: `Pubkey`
  - `padding`: `[u64; 3]`

### `ObservationState`
- **Fields:**
  - `initialized`: `bool`
  - `recent_epoch`: `u64`
  - `observation_index`: `u16`
  - `pool_id`: `Pubkey`
  - `observations`: `[Observation; 100]`
  - `padding`: `[u64; 4]`

### `OperationState`
- **Fields:**
  - `bump`: `u8`
  - `operation_owners`: `[Pubkey; 10]`
  - `whitelist_mints`: `[Pubkey; 100]`

### `PermissionlessFarmSwitch`
- **Fields:**
  - `bump`: `u8`
  - `is_on`: `bool`

### `PersonalPositionState`
- **Fields:**
  - `bump`: `[u8; 1]`
  - `nft_mint`: `Pubkey`
  - `pool_id`: `Pubkey`
  - `tick_lower_index`: `i32`
  - `tick_upper_index`: `i32`
  - `liquidity`: `u128`
  - `fee_growth_inside_0_last_x64`: `u128`
  - `fee_growth_inside_1_last_x64`: `u128`
  - `token_fees_owed_0`: `u64`
  - `token_fees_owed_1`: `u64`
  - `reward_infos`: `[PositionRewardInfo; 3]`
  - `recent_epoch`: `u64`
  - `padding`: `[u64; 7]`

### `PoolState`
- **Fields:**
  - `bump`: `[u8; 1]`
  - `amm_config`: `Pubkey`
  - `owner`: `Pubkey`
  - `token_mint_0`: `Pubkey`
  - `token_mint_1`: `Pubkey`
  - `token_vault_0`: `Pubkey`
  - `token_vault_1`: `Pubkey`
  - `observation_key`: `Pubkey`
  - `mint_decimals_0`: `u8`
  - `mint_decimals_1`: `u8`
  - `tick_spacing`: `u16`
  - `liquidity`: `u128`
  - `sqrt_price_x64`: `u128`
  - `tick_current`: `i32`
  - `padding3`: `u16`
  - `padding4`: `u16`
  - `fee_growth_global_0_x64`: `u128`
  - `fee_growth_global_1_x64`: `u128`
  - `protocol_fees_token_0`: `u64`
  - `protocol_fees_token_1`: `u64`
  - `swap_in_amount_token_0`: `u128`
  - `swap_out_amount_token_1`: `u128`
  - `swap_in_amount_token_1`: `u128`
  - `swap_out_amount_token_0`: `u128`
  - `status`: `u8`
  - `padding`: `[u8; 7]`
  - `reward_infos`: `[RewardInfo; 3]`
  - `tick_array_bitmap`: `[u64; 16]`
  - `total_fees_token_0`: `u64`
  - `total_fees_claimed_token_0`: `u64`
  - `total_fees_token_1`: `u64`
  - `total_fees_claimed_token_1`: `u64`
  - `fund_fees_token_0`: `u64`
  - `fund_fees_token_1`: `u64`
  - `open_time`: `u64`
  - `recent_epoch`: `u64`
  - `padding1`: `[u64; 24]`
  - `padding2`: `[u64; 32]`

### `ProtocolPositionState`
- **Fields:**
  - `bump`: `u8`
  - `pool_id`: `Pubkey`
  - `tick_lower_index`: `i32`
  - `tick_upper_index`: `i32`
  - `liquidity`: `u128`
  - `fee_growth_inside_0_last_x64`: `u128`
  - `fee_growth_inside_1_last_x64`: `u128`
  - `token_fees_owed_0`: `u64`
  - `token_fees_owed_1`: `u64`
  - `reward_growth_inside`: `[u128; 3]`
  - `recent_epoch`: `u64`
  - `padding`: `[u64; 7]`

### `SupportMintAssociated`
- **Fields:**
  - `bump`: `u8`
  - `mint`: `Pubkey`
  - `padding`: `[u64; 8]`

### `TickArrayBitmapExtension`
- **Fields:**
  - `pool_id`: `Pubkey`
  - `positive_tick_array_bitmap`: `[[u64; 8]; 14]`
  - `negative_tick_array_bitmap`: `[[u64; 8]; 14]`

### `TickArrayState`
- **Fields:**
  - `pool_id`: `Pubkey`
  - `start_tick_index`: `i32`
  - `ticks`: `[TickState; 60]`
  - `initialized_tick_count`: `u8`
  - `recent_epoch`: `u64`
  - `padding`: `[u8; 107]`

## Instructions

### `ClosePosition`
- **Discriminator:** `0x7b86510031446262`
- **Args:** (none)
- **Account variants:**
  - `6 accounts:` `nft_owner`, `position_nft_mint`, `position_nft_account`, `personal_position`, `system_program`, `token_program`

### `CollectFundFee`
- **Discriminator:** `0xa78a4e95dfc2067e`
- **Args:**
  - `amount_0_requested`: `u64`
  - `amount_1_requested`: `u64`
- **Account variants:**
  - `11 accounts:` `owner`, `pool_state`, `amm_config`, `token_vault_0`, `token_vault_1`, `vault_0_mint`, `vault_1_mint`, `recipient_token_account_0`, `recipient_token_account_1`, `token_program`, `token_program_2022`

### `CollectProtocolFee`
- **Discriminator:** `0x8888fcddc2427e59`
- **Args:**
  - `amount_0_requested`: `u64`
  - `amount_1_requested`: `u64`
- **Account variants:**
  - `11 accounts:` `owner`, `pool_state`, `amm_config`, `token_vault_0`, `token_vault_1`, `vault_0_mint`, `vault_1_mint`, `recipient_token_account_0`, `recipient_token_account_1`, `token_program`, `token_program_2022`

### `CollectRemainingRewards`
- **Discriminator:** `0x12eda6c52210d590`
- **Args:**
  - `reward_index`: `u8`
- **Account variants:**
  - `8 accounts:` `reward_funder`, `funder_token_account`, `pool_state`, `reward_token_vault`, `reward_vault_mint`, `token_program`, `token_program_2022`, `memo_program`

### `CreateAmmConfig`
- **Discriminator:** `0x8934edd4d7756c68`
- **Args:**
  - `index`: `u16`
  - `tick_spacing`: `u16`
  - `trade_fee_rate`: `u32`
  - `protocol_fee_rate`: `u32`
  - `fund_fee_rate`: `u32`
- **Account variants:**
  - `3 accounts:` `owner`, `amm_config`, `system_program`

### `CreateOperationAccount`
- **Discriminator:** `0x3f5794216d230868`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `owner`, `operation_state`, `system_program`

### `CreatePermissionlessFarmSwitch`
- **Discriminator:** `0x58f2c646f106c4fb`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `owner`, `permissionless_farm_switch`, `system_program`

### `CreatePool`
- **Discriminator:** `0xe992d18ecf6840bc`
- **Args:**
  - `sqrt_price_x64`: `u128`
  - `open_time`: `u64`
- **Account variants:**
  - `13 accounts:` `pool_creator`, `amm_config`, `pool_state`, `token_mint_0`, `token_mint_1`, `token_vault_0`, `token_vault_1`, `observation_state`, `tick_array_bitmap`, `token_program_0`, `token_program_1`, `system_program`, `rent`

### `CreateSupportMintAssociated`
- **Discriminator:** `0x11fb415c88f20ea9`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `owner`, `token_mint`, `support_mint_associated`, `system_program`

### `DecreaseLiquidity`
- **Discriminator:** `0xa026d06f685b2c01`
- **Args:**
  - `liquidity`: `u128`
  - `amount_0_min`: `u64`
  - `amount_1_min`: `u64`
- **Account variants:**
  - `12 accounts:` `nft_owner`, `nft_account`, `personal_position`, `pool_state`, `protocol_position`, `token_vault_0`, `token_vault_1`, `tick_array_lower`, `tick_array_upper`, `recipient_token_account_0`, `recipient_token_account_1`, `token_program`

### `DecreaseLiquidityV2`
- **Discriminator:** `0x3a7fbc3e4f52c460`
- **Args:**
  - `liquidity`: `u128`
  - `amount_0_min`: `u64`
  - `amount_1_min`: `u64`
- **Account variants:**
  - `16 accounts:` `nft_owner`, `nft_account`, `personal_position`, `pool_state`, `protocol_position`, `token_vault_0`, `token_vault_1`, `tick_array_lower`, `tick_array_upper`, `recipient_token_account_0`, `recipient_token_account_1`, `token_program`, `token_program_2022`, `memo_program`, `vault_0_mint`, `vault_1_mint`

### `IncreaseLiquidity`
- **Discriminator:** `0x2e9cf3760dcdfbb2`
- **Args:**
  - `liquidity`: `u128`
  - `amount_0_max`: `u64`
  - `amount_1_max`: `u64`
- **Account variants:**
  - `12 accounts:` `nft_owner`, `nft_account`, `pool_state`, `protocol_position`, `personal_position`, `tick_array_lower`, `tick_array_upper`, `token_account_0`, `token_account_1`, `token_vault_0`, `token_vault_1`, `token_program`

### `IncreaseLiquidityV2`
- **Discriminator:** `0x851d59df45eeb00a`
- **Args:**
  - `liquidity`: `u128`
  - `amount_0_max`: `u64`
  - `amount_1_max`: `u64`
  - `base_flag`: `Option<bool>`
- **Account variants:**
  - `15 accounts:` `nft_owner`, `nft_account`, `pool_state`, `protocol_position`, `personal_position`, `tick_array_lower`, `tick_array_upper`, `token_account_0`, `token_account_1`, `token_vault_0`, `token_vault_1`, `token_program`, `token_program_2022`, `vault_0_mint`, `vault_1_mint`

### `InitializeReward`
- **Discriminator:** `0x5f87c0c4f281e644`
- **Args:**
  - `param`: `InitializeRewardParam`
- **Account variants:**
  - `11 accounts:` `reward_funder`, `funder_token_account`, `amm_config`, `pool_state`, `operation_state`, `permissionless_farm_switch`, `reward_token_mint`, `reward_token_vault`, `reward_token_program`, `system_program`, `rent`

### `OpenPosition`
- **Discriminator:** `0x87802f4d0f98f031`
- **Args:**
  - `tick_lower_index`: `i32`
  - `tick_upper_index`: `i32`
  - `tick_array_lower_start_index`: `i32`
  - `tick_array_upper_start_index`: `i32`
  - `liquidity`: `u128`
  - `amount_0_max`: `u64`
  - `amount_1_max`: `u64`
- **Account variants:**
  - `19 accounts:` `payer`, `position_nft_owner`, `position_nft_mint`, `position_nft_account`, `metadata_account`, `pool_state`, `protocol_position`, `tick_array_lower`, `tick_array_upper`, `personal_position`, `token_account_0`, `token_account_1`, `token_vault_0`, `token_vault_1`, `rent`, `system_program`, `token_program`, `associated_token_program`, `metadata_program`

### `OpenPositionV2`
- **Discriminator:** `0x4db84ad67056f1c7`
- **Args:**
  - `tick_lower_index`: `i32`
  - `tick_upper_index`: `i32`
  - `tick_array_lower_start_index`: `i32`
  - `tick_array_upper_start_index`: `i32`
  - `liquidity`: `u128`
  - `amount_0_max`: `u64`
  - `amount_1_max`: `u64`
  - `with_metadata`: `bool`
  - `base_flag`: `Option<bool>`
- **Account variants:**
  - `22 accounts:` `payer`, `position_nft_owner`, `position_nft_mint`, `position_nft_account`, `metadata_account`, `pool_state`, `protocol_position`, `tick_array_lower`, `tick_array_upper`, `personal_position`, `token_account_0`, `token_account_1`, `token_vault_0`, `token_vault_1`, `rent`, `system_program`, `token_program`, `associated_token_program`, `metadata_program`, `token_program_2022`, `vault_0_mint`, `vault_1_mint`

### `OpenPositionWithToken22Nft`
- **Discriminator:** `0x4dffae527d1dc92e`
- **Args:**
  - `tick_lower_index`: `i32`
  - `tick_upper_index`: `i32`
  - `tick_array_lower_start_index`: `i32`
  - `tick_array_upper_start_index`: `i32`
  - `liquidity`: `u128`
  - `amount_0_max`: `u64`
  - `amount_1_max`: `u64`
  - `with_metadata`: `bool`
  - `base_flag`: `Option<bool>`
- **Account variants:**
  - `20 accounts:` `payer`, `position_nft_owner`, `position_nft_mint`, `position_nft_account`, `pool_state`, `protocol_position`, `tick_array_lower`, `tick_array_upper`, `personal_position`, `token_account_0`, `token_account_1`, `token_vault_0`, `token_vault_1`, `rent`, `system_program`, `token_program`, `associated_token_program`, `token_program_2022`, `vault_0_mint`, `vault_1_mint`

### `SetRewardParams`
- **Discriminator:** `0x7034a74b20c9d389`
- **Args:**
  - `reward_index`: `u8`
  - `emissions_per_second_x64`: `u128`
  - `open_time`: `u64`
  - `end_time`: `u64`
- **Account variants:**
  - `6 accounts:` `authority`, `amm_config`, `pool_state`, `operation_state`, `token_program`, `token_program_2022`

### `Swap`
- **Discriminator:** `0xf8c69e91e17587c8`
- **Args:**
  - `amount`: `u64`
  - `other_amount_threshold`: `u64`
  - `sqrt_price_limit_x64`: `u128`
  - `is_base_input`: `bool`
- **Account variants:**
  - `10 accounts:` `payer`, `amm_config`, `pool_state`, `input_token_account`, `output_token_account`, `input_vault`, `output_vault`, `observation_state`, `token_program`, `tick_array`

### `SwapRouterBaseIn`
- **Discriminator:** `0x457d73daf5baf2c4`
- **Args:**
  - `amount_in`: `u64`
  - `amount_out_minimum`: `u64`
- **Account variants:**
  - `6 accounts:` `payer`, `input_token_account`, `input_token_mint`, `token_program`, `token_program_2022`, `memo_program`

### `SwapV2`
- **Discriminator:** `0x2b04ed0b1ac91e62`
- **Args:**
  - `amount`: `u64`
  - `other_amount_threshold`: `u64`
  - `sqrt_price_limit_x64`: `u128`
  - `is_base_input`: `bool`
- **Account variants:**
  - `13 accounts:` `payer`, `amm_config`, `pool_state`, `input_token_account`, `output_token_account`, `input_vault`, `output_vault`, `observation_state`, `token_program`, `token_program_2022`, `memo_program`, `input_vault_mint`, `output_vault_mint`

### `TogglePermissionlessFarmSwitch`
- **Discriminator:** `0x967036e9eea10756`
- **Args:**
  - `is_on`: `bool`
- **Account variants:**
  - `3 accounts:` `owner`, `permissionless_farm_switch`, `system_program`

### `TransferRewardOwner`
- **Discriminator:** `0x07160c53f22b3079`
- **Args:**
  - `new_owner`: `Pubkey`
- **Account variants:**
  - `2 accounts:` `authority`, `pool_state`

### `UpdateAmmConfig`
- **Discriminator:** `0x313cae889a1c74c8`
- **Args:**
  - `param`: `u8`
  - `value`: `u32`
- **Account variants:**
  - `2 accounts:` `owner`, `amm_config`

### `UpdateOperationAccount`
- **Discriminator:** `0x7f467728bce33d07`
- **Args:**
  - `param`: `u8`
  - `keys`: `Vec<Pubkey>`
- **Account variants:**
  - `3 accounts:` `owner`, `operation_state`, `system_program`

### `UpdatePoolStatus`
- **Discriminator:** `0x82576c062ee0757b`
- **Args:**
  - `status`: `u8`
- **Account variants:**
  - `2 accounts:` `authority`, `pool_state`

### `UpdateRewardInfos`
- **Discriminator:** `0xa3ace0340b9a6adf`
- **Args:** (none)
- **Account variants:**
  - `1 accounts:` `pool_state`

## CPI events

### `CollectPersonalFeeEvent`
- **Source:** `instructions/collect_personal_fee_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1da6ae69c051a15369`
- **Fields:**
  - `position_nft_mint`: `Pubkey`
  - `recipient_token_account_0`: `Pubkey`
  - `recipient_token_account_1`: `Pubkey`
  - `amount_0`: `u64`
  - `amount_1`: `u64`

### `CollectProtocolFeeEvent`
- **Source:** `instructions/collect_protocol_fee_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1dce57114f2d29d53d`
- **Fields:**
  - `pool_state`: `Pubkey`
  - `recipient_token_account_0`: `Pubkey`
  - `recipient_token_account_1`: `Pubkey`
  - `amount_0`: `u64`
  - `amount_1`: `u64`

### `ConfigChangeEvent`
- **Source:** `instructions/config_change_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1df7bd07776a705f97`
- **Fields:**
  - `index`: `u16`
  - `owner`: `Pubkey`
  - `protocol_fee_rate`: `u32`
  - `trade_fee_rate`: `u32`
  - `tick_spacing`: `u16`
  - `fund_fee_rate`: `u32`
  - `fund_owner`: `Pubkey`

### `CreatePersonalPositionEvent`
- **Source:** `instructions/create_personal_position_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d641e57f9c4df9ace`
- **Fields:**
  - `pool_state`: `Pubkey`
  - `minter`: `Pubkey`
  - `nft_owner`: `Pubkey`
  - `tick_lower_index`: `i32`
  - `tick_upper_index`: `i32`
  - `liquidity`: `u128`
  - `deposit_amount_0`: `u64`
  - `deposit_amount_1`: `u64`
  - `deposit_amount_0_transfer_fee`: `u64`
  - `deposit_amount_1_transfer_fee`: `u64`

### `DecreaseLiquidityEvent`
- **Source:** `instructions/decrease_liquidity_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d3ade563a44325538`
- **Fields:**
  - `position_nft_mint`: `Pubkey`
  - `liquidity`: `u128`
  - `decrease_amount_0`: `u64`
  - `decrease_amount_1`: `u64`
  - `fee_amount_0`: `u64`
  - `fee_amount_1`: `u64`
  - `reward_amounts`: `[u64; 3]`
  - `transfer_fee_0`: `u64`
  - `transfer_fee_1`: `u64`

### `IncreaseLiquidityEvent`
- **Source:** `instructions/increase_liquidity_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d314f69d420221e54`
- **Fields:**
  - `position_nft_mint`: `Pubkey`
  - `liquidity`: `u128`
  - `amount_0`: `u64`
  - `amount_1`: `u64`
  - `amount_0_transfer_fee`: `u64`
  - `amount_1_transfer_fee`: `u64`

### `LiquidityCalculateEvent`
- **Source:** `instructions/liquidity_calculate_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1ded7094e63954b4a2`
- **Fields:**
  - `pool_liquidity`: `u128`
  - `pool_sqrt_price_x64`: `u128`
  - `pool_tick`: `i32`
  - `calc_amount_0`: `u64`
  - `calc_amount_1`: `u64`
  - `trade_fee_owed_0`: `u64`
  - `trade_fee_owed_1`: `u64`
  - `transfer_fee_0`: `u64`
  - `transfer_fee_1`: `u64`

### `LiquidityChangeEvent`
- **Source:** `instructions/liquidity_change_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d7ef0afce9e58996b`
- **Fields:**
  - `pool_state`: `Pubkey`
  - `tick`: `i32`
  - `tick_lower`: `i32`
  - `tick_upper`: `i32`
  - `liquidity_before`: `u128`
  - `liquidity_after`: `u128`

### `PoolCreatedEvent`
- **Source:** `instructions/pool_created_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d195e4b2f7063353f`
- **Fields:**
  - `token_mint_0`: `Pubkey`
  - `token_mint_1`: `Pubkey`
  - `tick_spacing`: `u16`
  - `pool_state`: `Pubkey`
  - `sqrt_price_x64`: `u128`
  - `tick`: `i32`
  - `token_vault_0`: `Pubkey`
  - `token_vault_1`: `Pubkey`

### `SwapEvent`
- **Source:** `instructions/swap_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d40c6cde8260871e2`
- **Fields:**
  - `pool_state`: `Pubkey`
  - `sender`: `Pubkey`
  - `token_account_0`: `Pubkey`
  - `token_account_1`: `Pubkey`
  - `amount_0`: `u64`
  - `transfer_fee_0`: `u64`
  - `amount_1`: `u64`
  - `transfer_fee_1`: `u64`
  - `zero_for_one`: `bool`
  - `sqrt_price_x64`: `u128`
  - `liquidity`: `u128`
  - `tick`: `i32`

### `UpdateRewardInfosEvent`
- **Source:** `instructions/update_reward_infos_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d6d7fba4e724125ec`
- **Fields:**
  - `reward_growth_global_x64`: `[u128; 3]`

## Shared types

### `AmmConfig`
- `bump`: `u8`
- `index`: `u16`
- `owner`: `Pubkey`
- `protocol_fee_rate`: `u32`
- `trade_fee_rate`: `u32`
- `tick_spacing`: `u16`
- `fund_fee_rate`: `u32`
- `padding_u32`: `u32`
- `fund_owner`: `Pubkey`
- `padding`: `[u64; 3]`

### `CollectPersonalFeeEvent`
- `position_nft_mint`: `Pubkey`
- `recipient_token_account_0`: `Pubkey`
- `recipient_token_account_1`: `Pubkey`
- `amount_0`: `u64`
- `amount_1`: `u64`

### `CollectProtocolFeeEvent`
- `pool_state`: `Pubkey`
- `recipient_token_account_0`: `Pubkey`
- `recipient_token_account_1`: `Pubkey`
- `amount_0`: `u64`
- `amount_1`: `u64`

### `ConfigChangeEvent`
- `index`: `u16`
- `owner`: `Pubkey`
- `protocol_fee_rate`: `u32`
- `trade_fee_rate`: `u32`
- `tick_spacing`: `u16`
- `fund_fee_rate`: `u32`
- `fund_owner`: `Pubkey`

### `CreatePersonalPositionEvent`
- `pool_state`: `Pubkey`
- `minter`: `Pubkey`
- `nft_owner`: `Pubkey`
- `tick_lower_index`: `i32`
- `tick_upper_index`: `i32`
- `liquidity`: `u128`
- `deposit_amount_0`: `u64`
- `deposit_amount_1`: `u64`
- `deposit_amount_0_transfer_fee`: `u64`
- `deposit_amount_1_transfer_fee`: `u64`

### `DecreaseLiquidityEvent`
- `position_nft_mint`: `Pubkey`
- `liquidity`: `u128`
- `decrease_amount_0`: `u64`
- `decrease_amount_1`: `u64`
- `fee_amount_0`: `u64`
- `fee_amount_1`: `u64`
- `reward_amounts`: `[u64; 3]`
- `transfer_fee_0`: `u64`
- `transfer_fee_1`: `u64`

### `IncreaseLiquidityEvent`
- `position_nft_mint`: `Pubkey`
- `liquidity`: `u128`
- `amount_0`: `u64`
- `amount_1`: `u64`
- `amount_0_transfer_fee`: `u64`
- `amount_1_transfer_fee`: `u64`

### `InitializeRewardParam`
- `open_time`: `u64`
- `end_time`: `u64`
- `emissions_per_second_x64`: `u128`

### `LiquidityCalculateEvent`
- `pool_liquidity`: `u128`
- `pool_sqrt_price_x64`: `u128`
- `pool_tick`: `i32`
- `calc_amount_0`: `u64`
- `calc_amount_1`: `u64`
- `trade_fee_owed_0`: `u64`
- `trade_fee_owed_1`: `u64`
- `transfer_fee_0`: `u64`
- `transfer_fee_1`: `u64`

### `LiquidityChangeEvent`
- `pool_state`: `Pubkey`
- `tick`: `i32`
- `tick_lower`: `i32`
- `tick_upper`: `i32`
- `liquidity_before`: `u128`
- `liquidity_after`: `u128`

### `Observation`
- `block_timestamp`: `u32`
- `tick_cumulative`: `i64`
- `padding`: `[u64; 4]`

### `ObservationState`
- `initialized`: `bool`
- `recent_epoch`: `u64`
- `observation_index`: `u16`
- `pool_id`: `Pubkey`
- `observations`: `[Observation; 100]`
- `padding`: `[u64; 4]`

### `OperationState`
- `bump`: `u8`
- `operation_owners`: `[Pubkey; 10]`
- `whitelist_mints`: `[Pubkey; 100]`

### `PermissionlessFarmSwitch`
- `bump`: `u8`
- `is_on`: `bool`

### `PersonalPositionState`
- `bump`: `[u8; 1]`
- `nft_mint`: `Pubkey`
- `pool_id`: `Pubkey`
- `tick_lower_index`: `i32`
- `tick_upper_index`: `i32`
- `liquidity`: `u128`
- `fee_growth_inside_0_last_x64`: `u128`
- `fee_growth_inside_1_last_x64`: `u128`
- `token_fees_owed_0`: `u64`
- `token_fees_owed_1`: `u64`
- `reward_infos`: `[PositionRewardInfo; 3]`
- `recent_epoch`: `u64`
- `padding`: `[u64; 7]`

### `PoolCreatedEvent`
- `token_mint_0`: `Pubkey`
- `token_mint_1`: `Pubkey`
- `tick_spacing`: `u16`
- `pool_state`: `Pubkey`
- `sqrt_price_x64`: `u128`
- `tick`: `i32`
- `token_vault_0`: `Pubkey`
- `token_vault_1`: `Pubkey`

### `PoolState`
- `bump`: `[u8; 1]`
- `amm_config`: `Pubkey`
- `owner`: `Pubkey`
- `token_mint_0`: `Pubkey`
- `token_mint_1`: `Pubkey`
- `token_vault_0`: `Pubkey`
- `token_vault_1`: `Pubkey`
- `observation_key`: `Pubkey`
- `mint_decimals_0`: `u8`
- `mint_decimals_1`: `u8`
- `tick_spacing`: `u16`
- `liquidity`: `u128`
- `sqrt_price_x64`: `u128`
- `tick_current`: `i32`
- `padding3`: `u16`
- `padding4`: `u16`
- `fee_growth_global_0_x64`: `u128`
- `fee_growth_global_1_x64`: `u128`
- `protocol_fees_token_0`: `u64`
- `protocol_fees_token_1`: `u64`
- `swap_in_amount_token_0`: `u128`
- `swap_out_amount_token_1`: `u128`
- `swap_in_amount_token_1`: `u128`
- `swap_out_amount_token_0`: `u128`
- `status`: `u8`
- `padding`: `[u8; 7]`
- `reward_infos`: `[RewardInfo; 3]`
- `tick_array_bitmap`: `[u64; 16]`
- `total_fees_token_0`: `u64`
- `total_fees_claimed_token_0`: `u64`
- `total_fees_token_1`: `u64`
- `total_fees_claimed_token_1`: `u64`
- `fund_fees_token_0`: `u64`
- `fund_fees_token_1`: `u64`
- `open_time`: `u64`
- `recent_epoch`: `u64`
- `padding1`: `[u64; 24]`
- `padding2`: `[u64; 32]`

### `PositionRewardInfo`
- `growth_inside_last_x64`: `u128`
- `reward_amount_owed`: `u64`

### `ProtocolPositionState`
- `bump`: `u8`
- `pool_id`: `Pubkey`
- `tick_lower_index`: `i32`
- `tick_upper_index`: `i32`
- `liquidity`: `u128`
- `fee_growth_inside_0_last_x64`: `u128`
- `fee_growth_inside_1_last_x64`: `u128`
- `token_fees_owed_0`: `u64`
- `token_fees_owed_1`: `u64`
- `reward_growth_inside`: `[u128; 3]`
- `recent_epoch`: `u64`
- `padding`: `[u64; 7]`

### `RewardInfo`
- `reward_state`: `u8`
- `open_time`: `u64`
- `end_time`: `u64`
- `last_update_time`: `u64`
- `emissions_per_second_x64`: `u128`
- `reward_total_emissioned`: `u64`
- `reward_claimed`: `u64`
- `token_mint`: `Pubkey`
- `token_vault`: `Pubkey`
- `authority`: `Pubkey`
- `reward_growth_global_x64`: `u128`

### `SupportMintAssociated`
- `bump`: `u8`
- `mint`: `Pubkey`
- `padding`: `[u64; 8]`

### `SwapEvent`
- `pool_state`: `Pubkey`
- `sender`: `Pubkey`
- `token_account_0`: `Pubkey`
- `token_account_1`: `Pubkey`
- `amount_0`: `u64`
- `transfer_fee_0`: `u64`
- `amount_1`: `u64`
- `transfer_fee_1`: `u64`
- `zero_for_one`: `bool`
- `sqrt_price_x64`: `u128`
- `liquidity`: `u128`
- `tick`: `i32`

### `TickArrayBitmapExtension`
- `pool_id`: `Pubkey`
- `positive_tick_array_bitmap`: `[[u64; 8]; 14]`
- `negative_tick_array_bitmap`: `[[u64; 8]; 14]`

### `TickArrayState`
- `pool_id`: `Pubkey`
- `start_tick_index`: `i32`
- `ticks`: `[TickState; 60]`
- `initialized_tick_count`: `u8`
- `recent_epoch`: `u64`
- `padding`: `[u8; 107]`

### `TickState`
- `tick`: `i32`
- `liquidity_net`: `i128`
- `liquidity_gross`: `u128`
- `fee_growth_outside_0_x64`: `u128`
- `fee_growth_outside_1_x64`: `u128`
- `reward_growths_outside_x64`: `[u128; 3]`
- `padding`: `[u32; 13]`

### `UpdateRewardInfosEvent`
- `reward_growth_global_x64`: `[u128; 3]`
