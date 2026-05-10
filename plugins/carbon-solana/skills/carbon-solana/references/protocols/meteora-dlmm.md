# Meteora DLMM

- **Crate:** `carbon-meteora-dlmm-decoder`
- **Program ID:** `LBUZKhRxPF3XUpBCjp4YzTKgLccjZhTSDM9YuVaPwxo`
- **Decoder struct:** `MeteoraDlmmDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in instructions/)
- **Discriminator style:** anchor 8-byte (events 16-byte)

## Account types

### `BinArray`
- **Discriminator:** `0x5c8e5cdc059446b5`
- **Fields:**
  - `index`: `i64`
  - `version`: `u8`
  - `padding`: `[u8; 7]`
  - `lb_pair`: `Pubkey`
  - `bins`: `[Bin; 70]`

### `BinArrayBitmapExtension`
- **Discriminator:** `0x506f7c7137ed1205`
- **Fields:**
  - `lb_pair`: `Pubkey`
  - `positive_bin_array_bitmap`: `[[u64; 8]; 12]`
  - `negative_bin_array_bitmap`: `[[u64; 8]; 12]`

### `ClaimFeeOperator`
- **Discriminator:** `0xa630865622c8bc96`
- **Fields:**
  - `operator`: `Pubkey`
  - `padding`: `[u8; 128]`

### `LbPair`
- **Discriminator:** `0x210b3162b565b10d`
- **Fields:**
  - `parameters`: `StaticParameters`
  - `v_parameters`: `VariableParameters`
  - `bump_seed`: `[u8; 1]`
  - `bin_step_seed`: `[u8; 2]`
  - `pair_type`: `u8`
  - `active_id`: `i32`
  - `bin_step`: `u16`
  - `status`: `u8`
  - `require_base_factor_seed`: `u8`
  - `base_factor_seed`: `[u8; 2]`
  - `activation_type`: `u8`
  - `creator_pool_on_off_control`: `u8`
  - `token_x_mint`: `Pubkey`
  - `token_y_mint`: `Pubkey`
  - `reserve_x`: `Pubkey`
  - `reserve_y`: `Pubkey`
  - `protocol_fee`: `ProtocolFee`
  - `padding1`: `[u8; 32]`
  - `reward_infos`: `[RewardInfo; 2]`
  - `oracle`: `Pubkey`
  - `bin_array_bitmap`: `[u64; 16]`
  - `last_updated_at`: `i64`
  - `padding2`: `[u8; 32]`
  - `pre_activation_swap_address`: `Pubkey`
  - `base_key`: `Pubkey`
  - `activation_point`: `u64`
  - `pre_activation_duration`: `u64`
  - `padding3`: `[u8; 8]`
  - `padding4`: `u64`
  - `creator`: `Pubkey`
  - `token_mint_x_program_flag`: `u8`
  - `token_mint_y_program_flag`: `u8`
  - `reserved`: `[u8; 22]`

### `Oracle`
- **Discriminator:** `0x8bc283b38cb3e5f4`
- **Fields:**
  - `idx`: `u64`
  - `active_size`: `u64`
  - `length`: `u64`

### `Position`
- **Discriminator:** `0xaabc8fe47a40f7d0`
- **Fields:**
  - `lb_pair`: `Pubkey`
  - `owner`: `Pubkey`
  - `liquidity_shares`: `[u64; 70]`
  - `reward_infos`: `[UserRewardInfo; 70]`
  - `fee_infos`: `[FeeInfo; 70]`
  - `lower_bin_id`: `i32`
  - `upper_bin_id`: `i32`
  - `last_updated_at`: `i64`
  - `total_claimed_fee_x_amount`: `u64`
  - `total_claimed_fee_y_amount`: `u64`
  - `total_claimed_rewards`: `[u64; 2]`
  - `reserved`: `[u8; 160]`

### `PositionV2`
- **Discriminator:** `0x75b0d4c7f5b485b6`
- **Fields:**
  - `lb_pair`: `Pubkey`
  - `owner`: `Pubkey`
  - `liquidity_shares`: `[u128; 70]`
  - `reward_infos`: `[UserRewardInfo; 70]`
  - `fee_infos`: `[FeeInfo; 70]`
  - `lower_bin_id`: `i32`
  - `upper_bin_id`: `i32`
  - `last_updated_at`: `i64`
  - `total_claimed_fee_x_amount`: `u64`
  - `total_claimed_fee_y_amount`: `u64`
  - `total_claimed_rewards`: `[u64; 2]`
  - `operator`: `Pubkey`
  - `lock_release_point`: `u64`
  - `padding0`: `u8`
  - `fee_owner`: `Pubkey`
  - `reserved`: `[u8; 87]`

### `PresetParameter`
- **Discriminator:** `0xf23ef422b5703aaa`
- **Fields:**
  - `bin_step`: `u16`
  - `base_factor`: `u16`
  - `filter_period`: `u16`
  - `decay_period`: `u16`
  - `reduction_factor`: `u16`
  - `variable_fee_control`: `u32`
  - `max_volatility_accumulator`: `u32`
  - `min_bin_id`: `i32`
  - `max_bin_id`: `i32`
  - `protocol_share`: `u16`

### `PresetParameter2`
- **Discriminator:** `0xabec9473a271deae`
- **Fields:**
  - `bin_step`: `u16`
  - `base_factor`: `u16`
  - `filter_period`: `u16`
  - `decay_period`: `u16`
  - `variable_fee_control`: `u32`
  - `max_volatility_accumulator`: `u32`
  - `reduction_factor`: `u16`
  - `protocol_share`: `u16`
  - `index`: `u16`
  - `base_fee_power_factor`: `u8`
  - `padding0`: `u8`
  - `padding1`: `[u64; 20]`

### `TokenBadge`
- **Discriminator:** `0x74dbcce5f974ff96`
- **Fields:**
  - `token_mint`: `Pubkey`
  - `padding`: `[u8; 128]`

## Instructions

### `AddLiquidity`
- **Discriminator:** `0xb59d59438fb63448`
- **Args:**
  - `liquidity_parameter`: `LiquidityParameter`
- **Account variants:**
  - `16 accounts:` `position`, `lb_pair`, `bin_array_bitmap_extension`, `user_token_x`, `user_token_y`, `reserve_x`, `reserve_y`, `token_x_mint`, `token_y_mint`, `bin_array_lower`, `bin_array_upper`, `sender`, `token_x_program`, `token_y_program`, `event_authority`, `program`
- **Remaining accounts:** yes

### `AddLiquidity2`
- **Discriminator:** `0xe4a24e1c46db7473`
- **Args:**
  - `liquidity_parameter`: `LiquidityParameter`
  - `remaining_accounts_info`: `RemainingAccountsInfo`
- **Account variants:**
  - `14 accounts:` `position`, `lb_pair`, `bin_array_bitmap_extension`, `user_token_x`, `user_token_y`, `reserve_x`, `reserve_y`, `token_x_mint`, `token_y_mint`, `sender`, `token_x_program`, `token_y_program`, `event_authority`, `program`

### `AddLiquidityByStrategy`
- **Discriminator:** `0x0703967f94283dc8`
- **Args:**
  - `liquidity_parameter`: `LiquidityParameterByStrategy`
- **Account variants:**
  - `16 accounts:` `position`, `lb_pair`, `bin_array_bitmap_extension`, `user_token_x`, `user_token_y`, `reserve_x`, `reserve_y`, `token_x_mint`, `token_y_mint`, `bin_array_lower`, `bin_array_upper`, `sender`, `token_x_program`, `token_y_program`, `event_authority`, `program`
- **Remaining accounts:** yes

### `AddLiquidityByStrategy2`
- **Discriminator:** `0x03dd95da6f8d76d5`
- **Args:**
  - `liquidity_parameter`: `LiquidityParameterByStrategy`
  - `remaining_accounts_info`: `RemainingAccountsInfo`
- **Account variants:**
  - `14 accounts:` `position`, `lb_pair`, `bin_array_bitmap_extension`, `user_token_x`, `user_token_y`, `reserve_x`, `reserve_y`, `token_x_mint`, `token_y_mint`, `sender`, `token_x_program`, `token_y_program`, `event_authority`, `program`
- **Remaining accounts:** yes

### `AddLiquidityByStrategyOneSide`
- **Discriminator:** `0x2905eeaf64e106cd`
- **Args:**
  - `liquidity_parameter`: `LiquidityParameterByStrategyOneSide`
- **Account variants:**
  - `12 accounts:` `position`, `lb_pair`, `bin_array_bitmap_extension`, `user_token`, `reserve`, `token_mint`, `bin_array_lower`, `bin_array_upper`, `sender`, `token_program`, `event_authority`, `program`
- **Remaining accounts:** yes

### `AddLiquidityByWeight`
- **Discriminator:** `0x1c8cee63e7a21595`
- **Args:**
  - `liquidity_parameter`: `LiquidityParameterByWeight`
- **Account variants:**
  - `16 accounts:` `position`, `lb_pair`, `bin_array_bitmap_extension`, `user_token_x`, `user_token_y`, `reserve_x`, `reserve_y`, `token_x_mint`, `token_y_mint`, `bin_array_lower`, `bin_array_upper`, `sender`, `token_x_program`, `token_y_program`, `event_authority`, `program`
- **Remaining accounts:** yes

### `AddLiquidityEvent`
- **Discriminator:** `0xe445a52e51cb9a1d1f5e7d5ae3343dba`
- **Args:**
  - `lb_pair`: `Pubkey`
  - `from`: `Pubkey`
  - `position`: `Pubkey`
  - `amounts`: `[u64; 2]`
  - `active_bin_id`: `i32`

### `AddLiquidityOneSide`
- **Discriminator:** `0x5e9b6797465fdca5`
- **Args:**
  - `liquidity_parameter`: `LiquidityOneSideParameter`
- **Account variants:**
  - `12 accounts:` `position`, `lb_pair`, `bin_array_bitmap_extension`, `user_token`, `reserve`, `token_mint`, `bin_array_lower`, `bin_array_upper`, `sender`, `token_program`, `event_authority`, `program`
- **Remaining accounts:** yes

### `AddLiquidityOneSidePrecise`
- **Discriminator:** `0xa1c26754ab47fa9a`
- **Args:**
  - `parameter`: `AddLiquiditySingleSidePreciseParameter`
- **Account variants:**
  - `12 accounts:` `position`, `lb_pair`, `bin_array_bitmap_extension`, `user_token`, `reserve`, `token_mint`, `bin_array_lower`, `bin_array_upper`, `sender`, `token_program`, `event_authority`, `program`
- **Remaining accounts:** yes

### `AddLiquidityOneSidePrecise2`
- **Discriminator:** `0x2133a3c975627de7`
- **Args:**
  - `liquidity_parameter`: `AddLiquiditySingleSidePreciseParameter2`
  - `remaining_accounts_info`: `RemainingAccountsInfo`
- **Account variants:**
  - `10 accounts:` `position`, `lb_pair`, `bin_array_bitmap_extension`, `user_token`, `reserve`, `token_mint`, `sender`, `token_program`, `event_authority`, `program`

### `ClaimFee`
- **Discriminator:** `0xa9204f8988e84689`
- **Args:** (none)
- **Account variants:**
  - `14 accounts:` `lb_pair`, `position`, `bin_array_lower`, `bin_array_upper`, `sender`, `reserve_x`, `reserve_y`, `user_token_x`, `user_token_y`, `token_x_mint`, `token_y_mint`, `token_program`, `event_authority`, `program`

### `ClaimFee2`
- **Discriminator:** `0x70bf65ab1c907fbb`
- **Args:**
  - `min_bin_id`: `i32`
  - `max_bin_id`: `i32`
  - `remaining_accounts_info`: `RemainingAccountsInfo`
- **Account variants:**
  - `14 accounts:` `lb_pair`, `position`, `sender`, `reserve_x`, `reserve_y`, `user_token_x`, `user_token_y`, `token_x_mint`, `token_y_mint`, `token_program_x`, `token_program_y`, `memo_program`, `event_authority`, `program`

### `ClaimFeeEvent`
- **Discriminator:** `0xe445a52e51cb9a1d4b7a9a308c4a7ba3`
- **Args:**
  - `lb_pair`: `Pubkey`
  - `position`: `Pubkey`
  - `owner`: `Pubkey`
  - `fee_x`: `u64`
  - `fee_y`: `u64`

### `ClaimReward`
- **Discriminator:** `0x955fb5f25e5a9ea2`
- **Args:**
  - `reward_index`: `u64`
- **Account variants:**
  - `11 accounts:` `lb_pair`, `position`, `bin_array_lower`, `bin_array_upper`, `sender`, `reward_vault`, `reward_mint`, `user_token_account`, `token_program`, `event_authority`, `program`

### `ClaimReward2`
- **Discriminator:** `0xbe037f77b2579db7`
- **Args:**
  - `reward_index`: `u64`
  - `min_bin_id`: `i32`
  - `max_bin_id`: `i32`
  - `remaining_accounts_info`: `RemainingAccountsInfo`
- **Account variants:**
  - `10 accounts:` `lb_pair`, `position`, `sender`, `reward_vault`, `reward_mint`, `user_token_account`, `token_program`, `memo_program`, `event_authority`, `program`

### `ClaimRewardEvent`
- **Discriminator:** `0xe445a52e51cb9a1d947486cc16ab555f`
- **Args:**
  - `lb_pair`: `Pubkey`
  - `position`: `Pubkey`
  - `owner`: `Pubkey`
  - `reward_index`: `u64`
  - `total_reward`: `u64`

### `CloseClaimProtocolFeeOperator`
- **Discriminator:** `0x082957235030791a`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `claim_fee_operator`, `rent_receiver`, `admin`

### `ClosePosition`
- **Discriminator:** `0x7b86510031446262`
- **Args:** (none)
- **Account variants:**
  - `8 accounts:` `position`, `lb_pair`, `bin_array_lower`, `bin_array_upper`, `sender`, `rent_receiver`, `event_authority`, `program`

### `ClosePosition2`
- **Discriminator:** `0xae5a2373ba2893e2`
- **Args:** (none)
- **Account variants:**
  - `5 accounts:` `position`, `sender`, `rent_receiver`, `event_authority`, `program`

### `ClosePositionIfEmpty`
- **Discriminator:** `0x3b7cd4765b986e9d`
- **Args:** (none)
- **Account variants:**
  - `5 accounts:` `position`, `sender`, `rent_receiver`, `event_authority`, `program`

### `ClosePresetParameter`
- **Discriminator:** `0x04949164861ab53d`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `preset_parameter`, `admin`, `rent_receiver`

### `ClosePresetParameter2`
- **Discriminator:** `0x27195f6b7411731c`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `preset_parameter`, `admin`, `rent_receiver`

### `CompositionFeeEvent`
- **Discriminator:** `0xe445a52e51cb9a1d80977b6a1166718e`
- **Args:**
  - `from`: `Pubkey`
  - `bin_id`: `i16`
  - `token_x_fee_amount`: `u64`
  - `token_y_fee_amount`: `u64`
  - `protocol_token_x_fee_amount`: `u64`
  - `protocol_token_y_fee_amount`: `u64`

### `CreateClaimProtocolFeeOperator`
- **Discriminator:** `0x331396fc699d305b`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `claim_fee_operator`, `operator`, `admin`, `system_program`

### `DecreasePositionLengthEvent`
- **Discriminator:** `0xe445a52e51cb9a1d3476eb55aca90f80`
- **Args:**
  - `lb_pair`: `Pubkey`
  - `position`: `Pubkey`
  - `owner`: `Pubkey`
  - `length_to_remove`: `u16`
  - `side`: `u8`

### `DynamicFeeParameterUpdateEvent`
- **Discriminator:** `0xe445a52e51cb9a1d5858b287c2925bf3`
- **Args:**
  - `lb_pair`: `Pubkey`
  - `filter_period`: `u16`
  - `decay_period`: `u16`
  - `reduction_factor`: `u16`
  - `variable_fee_control`: `u32`
  - `max_volatility_accumulator`: `u32`

### `FeeParameterUpdateEvent`
- **Discriminator:** `0xe445a52e51cb9a1d304cf17590d7f22c`
- **Args:**
  - `lb_pair`: `Pubkey`
  - `protocol_share`: `u16`
  - `base_factor`: `u16`

### `FundReward`
- **Discriminator:** `0xbc32f9a55d97263f`
- **Args:**
  - `reward_index`: `u64`
  - `amount`: `u64`
  - `carry_forward`: `bool`
  - `remaining_accounts_info`: `RemainingAccountsInfo`
- **Account variants:**
  - `9 accounts:` `lb_pair`, `reward_vault`, `reward_mint`, `funder_token_account`, `funder`, `bin_array`, `token_program`, `event_authority`, `program`

### `FundRewardEvent`
- **Discriminator:** `0xe445a52e51cb9a1df6e43a8291aa4fcc`
- **Args:**
  - `lb_pair`: `Pubkey`
  - `funder`: `Pubkey`
  - `reward_index`: `u64`
  - `amount`: `u64`

### `GoToABin`
- **Discriminator:** `0x9248aee028fd54ae`
- **Args:**
  - `bin_id`: `i32`
- **Account variants:**
  - `6 accounts:` `lb_pair`, `bin_array_bitmap_extension`, `from_bin_array`, `to_bin_array`, `event_authority`, `program`

### `GoToABinEvent`
- **Discriminator:** `0xe445a52e51cb9a1d3b8a4c448a83b043`
- **Args:**
  - `lb_pair`: `Pubkey`
  - `from_bin_id`: `i32`
  - `to_bin_id`: `i32`

### `IncreaseObservationEvent`
- **Discriminator:** `0xe445a52e51cb9a1d63f91179a69ccfd7`
- **Args:**
  - `oracle`: `Pubkey`
  - `new_observation_length`: `u64`

### `IncreaseOracleLength`
- **Discriminator:** `0xbe3d7d57674f9ead`
- **Args:**
  - `length_to_add`: `u64`
- **Account variants:**
  - `5 accounts:` `oracle`, `funder`, `system_program`, `event_authority`, `program`

### `IncreasePositionLengthEvent`
- **Discriminator:** `0xe445a52e51cb9a1d9def2acc1e38df2e`
- **Args:**
  - `lb_pair`: `Pubkey`
  - `position`: `Pubkey`
  - `owner`: `Pubkey`
  - `length_to_add`: `u16`
  - `side`: `u8`

### `InitializeBinArray`
- **Discriminator:** `0x235613b94ed44bd3`
- **Args:**
  - `index`: `i64`
- **Account variants:**
  - `4 accounts:` `lb_pair`, `bin_array`, `funder`, `system_program`

### `InitializeBinArrayBitmapExtension`
- **Discriminator:** `0x2f9de2b40cf02147`
- **Args:** (none)
- **Account variants:**
  - `5 accounts:` `lb_pair`, `bin_array_bitmap_extension`, `funder`, `system_program`, `rent`

### `InitializeCustomizablePermissionlessLbPair`
- **Discriminator:** `0x2e2729876fb7c840`
- **Args:**
  - `params`: `CustomizableParams`
- **Account variants:**
  - `14 accounts:` `lb_pair`, `bin_array_bitmap_extension`, `token_mint_x`, `token_mint_y`, `reserve_x`, `reserve_y`, `oracle`, `user_token_x`, `funder`, `token_program`, `system_program`, `user_token_y`, `event_authority`, `program`

### `InitializeCustomizablePermissionlessLbPair2`
- **Discriminator:** `0xf349817e3313f16b`
- **Args:**
  - `params`: `CustomizableParams`
- **Account variants:**
  - `17 accounts:` `lb_pair`, `bin_array_bitmap_extension`, `token_mint_x`, `token_mint_y`, `reserve_x`, `reserve_y`, `oracle`, `user_token_x`, `funder`, `token_badge_x`, `token_badge_y`, `token_program_x`, `token_program_y`, `system_program`, `user_token_y`, `event_authority`, `program`

### `InitializeLbPair`
- **Discriminator:** `0x2d9aedd2dd0fa65c`
- **Args:**
  - `active_id`: `i32`
  - `bin_step`: `u16`
- **Account variants:**
  - `14 accounts:` `lb_pair`, `bin_array_bitmap_extension`, `token_mint_x`, `token_mint_y`, `reserve_x`, `reserve_y`, `oracle`, `preset_parameter`, `funder`, `token_program`, `system_program`, `rent`, `event_authority`, `program`

### `InitializeLbPair2`
- **Discriminator:** `0x493b2478ed536cc6`
- **Args:**
  - `params`: `InitializeLbPair2Params`
- **Account variants:**
  - `16 accounts:` `lb_pair`, `bin_array_bitmap_extension`, `token_mint_x`, `token_mint_y`, `reserve_x`, `reserve_y`, `oracle`, `preset_parameter`, `funder`, `token_badge_x`, `token_badge_y`, `token_program_x`, `token_program_y`, `system_program`, `event_authority`, `program`

### `InitializePermissionLbPair`
- **Discriminator:** `0x6c66d555fb033515`
- **Args:**
  - `ix_data`: `InitPermissionPairIx`
- **Account variants:**
  - `17 accounts:` `base`, `lb_pair`, `bin_array_bitmap_extension`, `token_mint_x`, `token_mint_y`, `reserve_x`, `reserve_y`, `oracle`, `admin`, `token_badge_x`, `token_badge_y`, `token_program_x`, `token_program_y`, `system_program`, `rent`, `event_authority`, `program`

### `InitializePosition`
- **Discriminator:** `0xdbc0ea47bebf6650`
- **Args:**
  - `lower_bin_id`: `i32`
  - `width`: `i32`
- **Account variants:**
  - `8 accounts:` `payer`, `position`, `lb_pair`, `owner`, `system_program`, `rent`, `event_authority`, `program`

### `InitializePositionByOperator`
- **Discriminator:** `0xfbbdbef475fe2394`
- **Args:**
  - `lower_bin_id`: `i32`
  - `width`: `i32`
  - `fee_owner`: `Pubkey`
  - `lock_release_point`: `u64`
- **Account variants:**
  - `11 accounts:` `payer`, `base`, `position`, `lb_pair`, `owner`, `operator`, `operator_token_x`, `owner_token_x`, `system_program`, `event_authority`, `program`

### `InitializePositionPda`
- **Discriminator:** `0x2e527d92558de499`
- **Args:**
  - `lower_bin_id`: `i32`
  - `width`: `i32`
- **Account variants:**
  - `9 accounts:` `payer`, `base`, `position`, `lb_pair`, `owner`, `system_program`, `rent`, `event_authority`, `program`

### `InitializePresetParameter`
- **Discriminator:** `0x42bc47d3626d0eba`
- **Args:**
  - `ix`: `InitPresetParametersIx`
- **Account variants:**
  - `4 accounts:` `preset_parameter`, `admin`, `system_program`, `rent`

### `InitializePresetParameter2`
- **Discriminator:** `0xb807f0ab672fb779`
- **Args:**
  - `ix`: `InitPresetParameters2Ix`
- **Account variants:**
  - `3 accounts:` `preset_parameter`, `admin`, `system_program`

### `InitializeReward`
- **Discriminator:** `0x5f87c0c4f281e644`
- **Args:**
  - `reward_index`: `u64`
  - `reward_duration`: `u64`
  - `funder`: `Pubkey`
- **Account variants:**
  - `10 accounts:` `lb_pair`, `reward_vault`, `reward_mint`, `token_badge`, `admin`, `token_program`, `system_program`, `rent`, `event_authority`, `program`

### `InitializeRewardEvent`
- **Discriminator:** `0xe445a52e51cb9a1dd399583e953cb146`
- **Args:**
  - `lb_pair`: `Pubkey`
  - `reward_mint`: `Pubkey`
  - `funder`: `Pubkey`
  - `reward_index`: `u64`
  - `reward_duration`: `u64`

### `InitializeTokenBadge`
- **Discriminator:** `0xfd4dcd5f1be059df`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `token_mint`, `token_badge`, `admin`, `system_program`

### `LbPairCreateEvent`
- **Discriminator:** `0xe445a52e51cb9a1db94afc7d1bd7bc6f`
- **Args:**
  - `lb_pair`: `Pubkey`
  - `bin_step`: `u16`
  - `token_x`: `Pubkey`
  - `token_y`: `Pubkey`

### `MigrateBinArray`
- **Discriminator:** `0x11179fd365b829f1`
- **Args:** (none)
- **Account variants:**
  - `1 accounts:` `lb_pair`

### `MigratePosition`
- **Discriminator:** `0x0f843b32c706fb2e`
- **Args:** (none)
- **Account variants:**
  - `10 accounts:` `position_v2`, `position_v1`, `lb_pair`, `bin_array_lower`, `bin_array_upper`, `owner`, `system_program`, `rent_receiver`, `event_authority`, `program`

### `PositionCloseEvent`
- **Discriminator:** `0xe445a52e51cb9a1dffc4106b1cca3580`
- **Args:**
  - `position`: `Pubkey`
  - `owner`: `Pubkey`

### `PositionCreateEvent`
- **Discriminator:** `0xe445a52e51cb9a1d908efc549d352579`
- **Args:**
  - `lb_pair`: `Pubkey`
  - `position`: `Pubkey`
  - `owner`: `Pubkey`

### `RemoveAllLiquidity`
- **Discriminator:** `0x0a333d2370691855`
- **Args:** (none)
- **Account variants:**
  - `16 accounts:` `position`, `lb_pair`, `bin_array_bitmap_extension`, `user_token_x`, `user_token_y`, `reserve_x`, `reserve_y`, `token_x_mint`, `token_y_mint`, `bin_array_lower`, `bin_array_upper`, `sender`, `token_x_program`, `token_y_program`, `event_authority`, `program`

### `RemoveLiquidity`
- **Discriminator:** `0x5055d14818ceb16c`
- **Args:**
  - `bin_liquidity_removal`: `Vec<BinLiquidityReduction>`
- **Account variants:**
  - `16 accounts:` `position`, `lb_pair`, `bin_array_bitmap_extension`, `user_token_x`, `user_token_y`, `reserve_x`, `reserve_y`, `token_x_mint`, `token_y_mint`, `bin_array_lower`, `bin_array_upper`, `sender`, `token_x_program`, `token_y_program`, `event_authority`, `program`

### `RemoveLiquidity2`
- **Discriminator:** `0xe6d7527ff165e392`
- **Args:**
  - `bin_liquidity_removal`: `Vec<BinLiquidityReduction>`
  - `remaining_accounts_info`: `RemainingAccountsInfo`
- **Account variants:**
  - `15 accounts:` `position`, `lb_pair`, `bin_array_bitmap_extension`, `user_token_x`, `user_token_y`, `reserve_x`, `reserve_y`, `token_x_mint`, `token_y_mint`, `sender`, `token_x_program`, `token_y_program`, `memo_program`, `event_authority`, `program`

### `RemoveLiquidityByRange`
- **Discriminator:** `0x1a526698f04a691a`
- **Args:**
  - `from_bin_id`: `i32`
  - `to_bin_id`: `i32`
  - `bps_to_remove`: `u16`
- **Account variants:**
  - `16 accounts:` `position`, `lb_pair`, `bin_array_bitmap_extension`, `user_token_x`, `user_token_y`, `reserve_x`, `reserve_y`, `token_x_mint`, `token_y_mint`, `bin_array_lower`, `bin_array_upper`, `sender`, `token_x_program`, `token_y_program`, `event_authority`, `program`

### `RemoveLiquidityByRange2`
- **Discriminator:** `0xcc02c391359191cd`
- **Args:**
  - `from_bin_id`: `i32`
  - `to_bin_id`: `i32`
  - `bps_to_remove`: `u16`
  - `remaining_accounts_info`: `RemainingAccountsInfo`
- **Account variants:**
  - `15 accounts:` `position`, `lb_pair`, `bin_array_bitmap_extension`, `user_token_x`, `user_token_y`, `reserve_x`, `reserve_y`, `token_x_mint`, `token_y_mint`, `sender`, `token_x_program`, `token_y_program`, `memo_program`, `event_authority`, `program`

### `RemoveLiquidityEvent`
- **Discriminator:** `0xe445a52e51cb9a1d74f461e8671f983a`
- **Args:**
  - `lb_pair`: `Pubkey`
  - `from`: `Pubkey`
  - `position`: `Pubkey`
  - `amounts`: `[u64; 2]`
  - `active_bin_id`: `i32`

### `SetActivationPoint`
- **Discriminator:** `0x5bf90fa51a81fe7d`
- **Args:**
  - `activation_point`: `u64`
- **Account variants:**
  - `2 accounts:` `lb_pair`, `admin`

### `SetPairStatus`
- **Discriminator:** `0x43f8e7899a95d9ae`
- **Args:**
  - `status`: `u8`
- **Account variants:**
  - `2 accounts:` `lb_pair`, `admin`

### `SetPairStatusPermissionless`
- **Discriminator:** `0x4e3b98d346b72ed0`
- **Args:**
  - `status`: `u8`
- **Account variants:**
  - `2 accounts:` `lb_pair`, `creator`

### `SetPreActivationDuration`
- **Discriminator:** `0xa53dc9f4829f1664`
- **Args:**
  - `pre_activation_duration`: `u64`
- **Account variants:**
  - `2 accounts:` `lb_pair`, `creator`

### `SetPreActivationSwapAddress`
- **Discriminator:** `0x398b2f7bd850df0a`
- **Args:**
  - `pre_activation_swap_address`: `Pubkey`
- **Account variants:**
  - `2 accounts:` `lb_pair`, `creator`

### `Swap`
- **Discriminator:** `0xf8c69e91e17587c8`
- **Args:**
  - `amount_in`: `u64`
  - `min_amount_out`: `u64`
- **Account variants:**
  - `15 accounts:` `lb_pair`, `bin_array_bitmap_extension`, `reserve_x`, `reserve_y`, `user_token_in`, `user_token_out`, `token_x_mint`, `token_y_mint`, `oracle`, `host_fee_in`, `user`, `token_x_program`, `token_y_program`, `event_authority`, `program`

### `Swap2`
- **Discriminator:** `0x414b3f4ceb5b5b88`
- **Args:**
  - `amount_in`: `u64`
  - `min_amount_out`: `u64`
  - `remaining_accounts_info`: `RemainingAccountsInfo`
- **Account variants:**
  - `16 accounts:` `lb_pair`, `bin_array_bitmap_extension`, `reserve_x`, `reserve_y`, `user_token_in`, `user_token_out`, `token_x_mint`, `token_y_mint`, `oracle`, `host_fee_in`, `user`, `token_x_program`, `token_y_program`, `memo_program`, `event_authority`, `program`

### `SwapEvent`
- **Discriminator:** `0xe445a52e51cb9a1d516ce3becdd00ac4`
- **Args:**
  - `lb_pair`: `Pubkey`
  - `from`: `Pubkey`
  - `start_bin_id`: `i32`
  - `end_bin_id`: `i32`
  - `amount_in`: `u64`
  - `amount_out`: `u64`
  - `swap_for_y`: `bool`
  - `fee`: `u64`
  - `protocol_fee`: `u64`
  - `fee_bps`: `u128`
  - `host_fee`: `u64`

### `SwapExactOut`
- **Discriminator:** `0xfa49652126cf4bb8`
- **Args:**
  - `max_in_amount`: `u64`
  - `out_amount`: `u64`
- **Account variants:**
  - `15 accounts:` `lb_pair`, `bin_array_bitmap_extension`, `reserve_x`, `reserve_y`, `user_token_in`, `user_token_out`, `token_x_mint`, `token_y_mint`, `oracle`, `host_fee_in`, `user`, `token_x_program`, `token_y_program`, `event_authority`, `program`

### `SwapExactOut2`
- **Discriminator:** `0x2bd7f784893cf351`
- **Args:**
  - `max_in_amount`: `u64`
  - `out_amount`: `u64`
  - `remaining_accounts_info`: `RemainingAccountsInfo`
- **Account variants:**
  - `16 accounts:` `lb_pair`, `bin_array_bitmap_extension`, `reserve_x`, `reserve_y`, `user_token_in`, `user_token_out`, `token_x_mint`, `token_y_mint`, `oracle`, `host_fee_in`, `user`, `token_x_program`, `token_y_program`, `memo_program`, `event_authority`, `program`

### `SwapWithPriceImpact`
- **Discriminator:** `0x38ade6d0ade49ccd`
- **Args:**
  - `amount_in`: `u64`
  - `active_id`: `Option<i32>`
  - `max_price_impact_bps`: `u16`
- **Account variants:**
  - `15 accounts:` `lb_pair`, `bin_array_bitmap_extension`, `reserve_x`, `reserve_y`, `user_token_in`, `user_token_out`, `token_x_mint`, `token_y_mint`, `oracle`, `host_fee_in`, `user`, `token_x_program`, `token_y_program`, `event_authority`, `program`

### `SwapWithPriceImpact2`
- **Discriminator:** `0x4a62c0d6b1334b33`
- **Args:**
  - `amount_in`: `u64`
  - `active_id`: `Option<i32>`
  - `max_price_impact_bps`: `u16`
  - `remaining_accounts_info`: `RemainingAccountsInfo`
- **Account variants:**
  - `16 accounts:` `lb_pair`, `bin_array_bitmap_extension`, `reserve_x`, `reserve_y`, `user_token_in`, `user_token_out`, `token_x_mint`, `token_y_mint`, `oracle`, `host_fee_in`, `user`, `token_x_program`, `token_y_program`, `memo_program`, `event_authority`, `program`

### `TogglePairStatus`
- **Discriminator:** `0x3d7334172e0d1f90`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `lb_pair`, `admin`

### `UpdateBaseFeeParameters`
- **Discriminator:** `0x4ba8dfa110c3032f`
- **Args:**
  - `fee_parameter`: `BaseFeeParameter`
- **Account variants:**
  - `4 accounts:` `lb_pair`, `admin`, `event_authority`, `program`

### `UpdateDynamicFeeParameters`
- **Discriminator:** `0x5ca12ef6ffbd1616`
- **Args:**
  - `fee_parameter`: `DynamicFeeParameter`
- **Account variants:**
  - `4 accounts:` `lb_pair`, `admin`, `event_authority`, `program`

### `UpdateFeeParameters`
- **Discriminator:** `0x8080d05bf6351fb0`
- **Args:**
  - `fee_parameter`: `FeeParameter`
- **Account variants:**
  - `4 accounts:` `lb_pair`, `admin`, `event_authority`, `program`

### `UpdateFeesAndReward2`
- **Discriminator:** `0x208eb89a6741b858`
- **Args:**
  - `min_bin_id`: `i32`
  - `max_bin_id`: `i32`
- **Account variants:**
  - `3 accounts:` `position`, `lb_pair`, `owner`

### `UpdateFeesAndRewards`
- **Discriminator:** `0x9ae6fa0decd14bdf`
- **Args:** (none)
- **Account variants:**
  - `5 accounts:` `position`, `lb_pair`, `bin_array_lower`, `bin_array_upper`, `owner`

### `UpdatePositionLockReleasePointEvent`
- **Discriminator:** `0xe445a52e51cb9a1d85d642e0400c07bf`
- **Args:**
  - `position`: `Pubkey`
  - `current_point`: `u64`
  - `new_lock_release_point`: `u64`
  - `old_lock_release_point`: `u64`
  - `sender`: `Pubkey`

### `UpdatePositionOperator`
- **Discriminator:** `0xcab8678fb4bf74d9`
- **Args:**
  - `operator`: `Pubkey`
- **Account variants:**
  - `4 accounts:` `position`, `owner`, `event_authority`, `program`

### `UpdatePositionOperatorEvent`
- **Discriminator:** `0xe445a52e51cb9a1d277330ccf62f4239`
- **Args:**
  - `position`: `Pubkey`
  - `old_operator`: `Pubkey`
  - `new_operator`: `Pubkey`

### `UpdateRewardDuration`
- **Discriminator:** `0x8aaec4a9d5ebfe6b`
- **Args:**
  - `reward_index`: `u64`
  - `new_duration`: `u64`
- **Account variants:**
  - `5 accounts:` `lb_pair`, `admin`, `bin_array`, `event_authority`, `program`

### `UpdateRewardDurationEvent`
- **Discriminator:** `0xe445a52e51cb9a1ddff5e099311da3ac`
- **Args:**
  - `lb_pair`: `Pubkey`
  - `reward_index`: `u64`
  - `old_reward_duration`: `u64`
  - `new_reward_duration`: `u64`

### `UpdateRewardFunder`
- **Discriminator:** `0xd31c3020d7a02317`
- **Args:**
  - `reward_index`: `u64`
  - `new_funder`: `Pubkey`
- **Account variants:**
  - `4 accounts:` `lb_pair`, `admin`, `event_authority`, `program`

### `UpdateRewardFunderEvent`
- **Discriminator:** `0xe445a52e51cb9a1de0b2ae4afca555b4`
- **Args:**
  - `lb_pair`: `Pubkey`
  - `reward_index`: `u64`
  - `old_funder`: `Pubkey`
  - `new_funder`: `Pubkey`

### `WithdrawIneligibleReward`
- **Discriminator:** `0x94ce2ac3f7316708`
- **Args:**
  - `reward_index`: `u64`
  - `remaining_accounts_info`: `RemainingAccountsInfo`
- **Account variants:**
  - `10 accounts:` `lb_pair`, `reward_vault`, `reward_mint`, `funder_token_account`, `funder`, `bin_array`, `token_program`, `memo_program`, `event_authority`, `program`

### `WithdrawIneligibleRewardEvent`
- **Discriminator:** `0xe445a52e51cb9a1de7bd419566d79af4`
- **Args:**
  - `lb_pair`: `Pubkey`
  - `reward_mint`: `Pubkey`
  - `amount`: `u64`

### `WithdrawProtocolFee`
- **Discriminator:** `0x9ec99ebd215da267`
- **Args:**
  - `amount_x`: `u64`
  - `amount_y`: `u64`
  - `remaining_accounts_info`: `RemainingAccountsInfo`
- **Account variants:**
  - `12 accounts:` `lb_pair`, `reserve_x`, `reserve_y`, `token_x_mint`, `token_y_mint`, `receiver_token_x`, `receiver_token_y`, `claim_fee_operator`, `operator`, `token_x_program`, `token_y_program`, `memo_program`

## Shared types

### `AccountsType`
- enum: `TransferHookX`, `TransferHookY`, `TransferHookReward`

### `ActivationType`
- enum: `Slot`, `Timestamp`

### `AddLiquiditySingleSidePreciseParameter`
- `bins`: `Vec<CompressedBinDepositAmount>`
- `decompress_multiplier`: `u64`

### `AddLiquiditySingleSidePreciseParameter2`
- `bins`: `Vec<CompressedBinDepositAmount>`
- `decompress_multiplier`: `u64`
- `max_amount`: `u64`

### `BaseFeeParameter`
- `protocol_share`: `u16`
- `base_factor`: `u16`
- `base_fee_power_factor`: `u8`

### `Bin`
- `amount_x`: `u64`
- `amount_y`: `u64`
- `price`: `u128`
- `liquidity_supply`: `u128`
- `reward_per_token_stored`: `[u128; 2]`
- `fee_amount_x_per_token_stored`: `u128`
- `fee_amount_y_per_token_stored`: `u128`
- `amount_x_in`: `u128`
- `amount_y_in`: `u128`

### `BinLiquidityDistribution`
- `bin_id`: `i32`
- `distribution_x`: `u16`
- `distribution_y`: `u16`

### `BinLiquidityDistributionByWeight`
- `bin_id`: `i32`
- `weight`: `u16`

### `BinLiquidityReduction`
- `bin_id`: `i32`
- `bps_to_remove`: `u16`

### `CompressedBinDepositAmount`
- `bin_id`: `i32`
- `amount`: `u32`

### `CompressedBinDepositAmount2`
- `bin_id`: `i32`
- `amount`: `u32`

### `CustomizableParams`
- `active_id`: `i32`
- `bin_step`: `u16`
- `base_factor`: `u16`
- `activation_type`: `u8`
- `has_alpha_vault`: `bool`
- `activation_point`: `Option<u64>`
- `creator_pool_on_off_control`: `bool`
- `base_fee_power_factor`: `u8`
- `padding`: `[u8; 62]`

### `DynamicFeeParameter`
- `filter_period`: `u16`
- `decay_period`: `u16`
- `reduction_factor`: `u16`
- `variable_fee_control`: `u32`
- `max_volatility_accumulator`: `u32`

### `FeeInfo`
- `fee_x_per_token_complete`: `u128`
- `fee_y_per_token_complete`: `u128`
- `fee_x_pending`: `u64`
- `fee_y_pending`: `u64`

### `FeeParameter`
- `protocol_share`: `u16`
- `base_factor`: `u16`

### `InitPermissionPairIx`
- `active_id`: `i32`
- `bin_step`: `u16`
- `base_factor`: `u16`
- `base_fee_power_factor`: `u8`
- `activation_type`: `u8`
- `protocol_share`: `u16`

### `InitPresetParameters2Ix`
- `index`: `u16`
- `bin_step`: `u16`
- `base_factor`: `u16`
- `filter_period`: `u16`
- `decay_period`: `u16`
- `reduction_factor`: `u16`
- `variable_fee_control`: `u32`
- `max_volatility_accumulator`: `u32`
- `protocol_share`: `u16`
- `base_fee_power_factor`: `u8`

### `InitPresetParametersIx`
- `bin_step`: `u16`
- `base_factor`: `u16`
- `filter_period`: `u16`
- `decay_period`: `u16`
- `reduction_factor`: `u16`
- `variable_fee_control`: `u32`
- `max_volatility_accumulator`: `u32`
- `protocol_share`: `u16`

### `InitializeLbPair2Params`
- `active_id`: `i32`
- `padding`: `[u8; 96]`

### `LayoutVersion`
- enum: `V0`, `V1`

### `LiquidityOneSideParameter`
- `amount`: `u64`
- `active_id`: `i32`
- `max_active_bin_slippage`: `i32`
- `bin_liquidity_dist`: `Vec<BinLiquidityDistributionByWeight>`

### `LiquidityParameter`
- `amount_x`: `u64`
- `amount_y`: `u64`
- `bin_liquidity_dist`: `Vec<BinLiquidityDistribution>`

### `LiquidityParameterByStrategy`
- `amount_x`: `u64`
- `amount_y`: `u64`
- `active_id`: `i32`
- `max_active_bin_slippage`: `i32`
- `strategy_parameters`: `StrategyParameters`

### `LiquidityParameterByStrategyOneSide`
- `amount`: `u64`
- `active_id`: `i32`
- `max_active_bin_slippage`: `i32`
- `strategy_parameters`: `StrategyParameters`

### `LiquidityParameterByWeight`
- `amount_x`: `u64`
- `amount_y`: `u64`
- `active_id`: `i32`
- `max_active_bin_slippage`: `i32`
- `bin_liquidity_dist`: `Vec<BinLiquidityDistributionByWeight>`

### `Observation`
- `cumulative_active_bin_id`: `i128`
- `created_at`: `i64`
- `last_updated_at`: `i64`

### `PairStatus`
- enum: `Enabled`, `Disabled`

### `PairType`
- enum: `Permissionless`, `Permission`, `CustomizablePermissionless`, `PermissionlessV2`

### `ProtocolFee`
- `amount_x`: `u64`
- `amount_y`: `u64`

### `RemainingAccountsInfo`
- `slices`: `Vec<RemainingAccountsSlice>`

### `RemainingAccountsSlice`
- `accounts_type`: `AccountsType`
- `length`: `u8`

### `RewardInfo`
- `mint`: `Pubkey`
- `vault`: `Pubkey`
- `funder`: `Pubkey`
- `reward_duration`: `u64`
- `reward_duration_end`: `u64`
- `reward_rate`: `u128`
- `last_update_time`: `u64`
- `cumulative_seconds_with_empty_liquidity_reward`: `u64`

### `Rounding`
- enum: `Up`, `Down`

### `StaticParameters`
- `base_factor`: `u16`
- `filter_period`: `u16`
- `decay_period`: `u16`
- `reduction_factor`: `u16`
- `variable_fee_control`: `u32`
- `max_volatility_accumulator`: `u32`
- `min_bin_id`: `i32`
- `max_bin_id`: `i32`
- `protocol_share`: `u16`
- `base_fee_power_factor`: `u8`
- `padding`: `[u8; 5]`

### `StrategyParameters`
- `min_bin_id`: `i32`
- `max_bin_id`: `i32`
- `strategy_type`: `StrategyType`
- `parameteres`: `[u8; 64]`

### `StrategyType`
- enum: `SpotOneSide`, `CurveOneSide`, `BidAskOneSide`, `SpotBalanced`, `CurveBalanced`, `BidAskBalanced`, `SpotImBalanced`, `CurveImBalanced`, `BidAskImBalanced`

### `TokenProgramFlags`
- enum: `TokenProgram`, `TokenProgram2022`

### `UserRewardInfo`
- `reward_per_token_completes`: `[u128; 2]`
- `reward_pendings`: `[u64; 2]`

### `VariableParameters`
- `volatility_accumulator`: `u32`
- `volatility_reference`: `u32`
- `index_reference`: `i32`
- `padding`: `[u8; 4]`
- `last_update_timestamp`: `i64`
- `padding1`: `[u8; 8]`
