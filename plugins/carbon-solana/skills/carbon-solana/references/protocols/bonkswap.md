# Bonkswap

- **Crate:** `carbon-bonkswap-decoder`
- **Program ID:** `BSwp6bEBihVLdqJRKGgzjcGLHkcTuzmSo1TQkHepzH8p`
- **Decoder struct:** `BonkswapDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** no
- **Discriminator style:** anchor 8-byte

## Account types

### `Farm`
- **Discriminator:** `[161, 156, 211, 253, 250, 64, 53, 250]`
- **Fields:**
  - `pool`: `Pubkey`
  - `tokens`: `[Pubkey; 3]`
  - `token_accounts`: `[Pubkey; 3]`
  - `supply`: `[Token; 3]`
  - `supply_left`: `[Token; 3]`
  - `accumulated_seconds_per_share`: `FixedPoint`
  - `offset_seconds_per_share`: `FixedPoint`
  - `start_time`: `u64`
  - `end_time`: `u64`
  - `last_update`: `u64`
  - `bump`: `u8`
  - `farm_type`: `FarmType`

### `Pool`
- **Discriminator:** `[241, 154, 109, 4, 17, 177, 109, 188]`
- **Fields:**
  - `token_x`: `Pubkey`
  - `token_y`: `Pubkey`
  - `pool_x_account`: `Pubkey`
  - `pool_y_account`: `Pubkey`
  - `admin`: `Pubkey`
  - `project_owner`: `Pubkey`
  - `token_x_reserve`: `Token`
  - `token_y_reserve`: `Token`
  - `self_shares`: `Token`
  - `all_shares`: `Token`
  - `buyback_amount_x`: `Token`
  - `buyback_amount_y`: `Token`
  - `project_amount_x`: `Token`
  - `project_amount_y`: `Token`
  - `mercanti_amount_x`: `Token`
  - `mercanti_amount_y`: `Token`
  - `lp_accumulator_x`: `FixedPoint`
  - `lp_accumulator_y`: `FixedPoint`
  - `const_k`: `Product`
  - `price`: `FixedPoint`
  - `lp_fee`: `FixedPoint`
  - `buyback_fee`: `FixedPoint`
  - `project_fee`: `FixedPoint`
  - `mercanti_fee`: `FixedPoint`
  - `farm_count`: `u64`
  - `bump`: `u8`

### `PoolV2`
- **Discriminator:** `[91, 12, 214, 87, 7, 185, 167, 55]`
- **Fields:**
  - `token_x`: `Pubkey`
  - `token_y`: `Pubkey`
  - `pool_x_account`: `Pubkey`
  - `pool_y_account`: `Pubkey`
  - `admin`: `Pubkey`
  - `project_owner`: `Pubkey`
  - `token_x_reserve`: `Token`
  - `token_y_reserve`: `Token`
  - `self_shares`: `Token`
  - `all_shares`: `Token`
  - `buyback_amount_x`: `Token`
  - `buyback_amount_y`: `Token`
  - `project_amount_x`: `Token`
  - `project_amount_y`: `Token`
  - `mercanti_amount_x`: `Token`
  - `mercanti_amount_y`: `Token`
  - `lp_accumulator_x`: `FixedPoint`
  - `lp_accumulator_y`: `FixedPoint`
  - `const_k`: `Product`
  - `price`: `FixedPoint`
  - `lp_fee`: `FixedPoint`
  - `buyback_fee`: `FixedPoint`
  - `project_fee`: `FixedPoint`
  - `mercanti_fee`: `FixedPoint`
  - `farm_count`: `u64`
  - `pool_bump`: `u8`
  - `lp_token`: `Pubkey`
  - `lp_token_mint_bump`: `u8`
  - `padding`: `[u64; 8]`

### `Provider`
- **Discriminator:** `[164, 180, 71, 17, 75, 216, 80, 195]`
- **Fields:**
  - `token_x`: `Pubkey`
  - `token_y`: `Pubkey`
  - `owner`: `Pubkey`
  - `shares`: `Token`
  - `last_fee_accumulator_x`: `FixedPoint`
  - `last_fee_accumulator_y`: `FixedPoint`
  - `last_seconds_per_share`: `FixedPoint`
  - `last_withdraw_time`: `u64`
  - `tokens_owed_x`: `Token`
  - `tokens_owed_y`: `Token`
  - `current_farm_count`: `u64`
  - `bump`: `u8`

### `State`
- **Discriminator:** `[216, 146, 107, 94, 104, 75, 182, 177]`
- **Fields:**
  - `admin`: `Pubkey`
  - `program_authority`: `Pubkey`
  - `bump`: `u8`
  - `nonce`: `u8`

## Instructions

### `AddSupply`
- **Discriminator:** `[80, 102, 70, 57, 235, 88, 239, 8]`
- **Args:**
  - `supply_marco`: `Token`
  - `supply_project_first`: `Token`
  - `supply_project_second`: `Token`
  - `duration`: `u64`
- **Account variants:**
  - `13 accounts:` `state`, `pool`, `farm`, `token_x`, `token_y`, `token_marco_account`, `token_project_first_account`, `token_project_second_account`, `admin_marco_account`, `admin_project_first_account`, `admin_project_second_account`, `admin`, `token_program`
- **Remaining accounts:** yes

### `AddTokens`
- **Discriminator:** `[28, 218, 30, 209, 175, 155, 153, 240]`
- **Args:**
  - `shares`: `Token`
  - `max_amount_x`: `Token`
  - `max_amount_y`: `Token`
- **Account variants:**
  - `25 accounts:` `state`, `pool`, `farm`, `provider`, `token_x`, `token_y`, `token_marco`, `token_project_first`, `token_project_second`, `owner_x_account`, `owner_y_account`, `pool_x_account`, `pool_y_account`, `owner_marco_account`, `owner_project_first_account`, `owner_project_second_account`, `token_marco_account`, `token_project_first_account`, `token_project_second_account`, `owner`, `program_authority`, `system_program`, `token_program`, `associated_token_program`, `rent`
- **Remaining accounts:** yes

### `ClosePool`
- **Discriminator:** `[140, 189, 209, 23, 239, 62, 239, 11]`
- **Args:** (none)
- **Account variants:**
  - `15 accounts:` `state`, `pool`, `farm`, `token_x`, `token_y`, `token_marco_account`, `token_project_first_account`, `token_project_second_account`, `pool_x_account`, `pool_y_account`, `buyback_x_account`, `buyback_y_account`, `admin`, `program_authority`, `token_program`
- **Remaining accounts:** yes

### `CreateDualFarm`
- **Discriminator:** `[42, 180, 103, 138, 206, 43, 208, 98]`
- **Args:**
  - `duration`: `u64`
  - `bump`: `u8`
- **Account variants:**
  - `16 accounts:` `state`, `pool`, `farm`, `token_x`, `token_y`, `token_marco`, `token_project_first`, `token_marco_account`, `token_project_first_account`, `admin_marco_account`, `admin_project_first_account`, `admin`, `program_authority`, `system_program`, `token_program`, `rent`
- **Remaining accounts:** yes

### `CreateFarm`
- **Discriminator:** `[74, 59, 128, 160, 87, 174, 153, 194]`
- **Args:**
  - `supply`: `Token`
  - `duration`: `u64`
  - `bump`: `u8`
- **Account variants:**
  - `13 accounts:` `state`, `pool`, `farm`, `token_x`, `token_y`, `token_marco`, `token_marco_account`, `admin_marco_account`, `admin`, `program_authority`, `system_program`, `token_program`, `rent`
- **Remaining accounts:** yes

### `CreatePool`
- **Discriminator:** `[233, 146, 209, 142, 207, 104, 64, 188]`
- **Args:**
  - `bump`: `u8`
- **Account variants:**
  - `14 accounts:` `state`, `pool`, `token_x`, `token_y`, `pool_x_account`, `pool_y_account`, `admin_x_account`, `admin_y_account`, `admin`, `project_owner`, `program_authority`, `system_program`, `token_program`, `rent`
- **Remaining accounts:** yes

### `CreateProvider`
- **Discriminator:** `[74, 53, 211, 174, 38, 168, 227, 177]`
- **Args:**
  - `bump`: `u8`
- **Account variants:**
  - `13 accounts:` `pool`, `farm`, `provider`, `token_x`, `token_y`, `pool_x_account`, `pool_y_account`, `owner_x_account`, `owner_y_account`, `owner`, `system_program`, `token_program`, `rent`
- **Remaining accounts:** yes

### `CreateState`
- **Discriminator:** `[214, 211, 209, 79, 107, 105, 247, 222]`
- **Args:**
  - `nonce`: `u8`
- **Account variants:**
  - `4 accounts:` `state`, `admin`, `program_authority`, `system_program`
- **Remaining accounts:** yes

### `CreateTripleFarm`
- **Discriminator:** `[154, 26, 180, 145, 18, 201, 135, 171]`
- **Args:**
  - `duration`: `u64`
  - `bump`: `u8`
- **Account variants:**
  - `19 accounts:` `state`, `pool`, `farm`, `token_x`, `token_y`, `token_marco`, `token_project_first`, `token_project_second`, `token_marco_account`, `token_project_first_account`, `token_project_second_account`, `admin_marco_account`, `admin_project_first_account`, `admin_project_second_account`, `admin`, `program_authority`, `system_program`, `token_program`, `rent`
- **Remaining accounts:** yes

### `ResetFarm`
- **Discriminator:** `[47, 77, 233, 117, 118, 55, 61, 113]`
- **Args:** (none)
- **Account variants:**
  - `17 accounts:` `state`, `pool`, `farm`, `token_x`, `token_y`, `token_marco`, `token_marco_account`, `token_project_first_account`, `token_project_second_account`, `admin_marco_account`, `admin_project_first_account`, `admin_project_second_account`, `admin`, `program_authority`, `system_program`, `token_program`, `rent`
- **Remaining accounts:** yes

### `Swap`
- **Discriminator:** `[248, 198, 158, 145, 225, 117, 135, 200]`
- **Args:**
  - `delta_in`: `Token`
  - `price_limit`: `FixedPoint`
  - `x_to_y`: `bool`
- **Account variants:**
  - `17 accounts:` `state`, `pool`, `token_x`, `token_y`, `pool_x_account`, `pool_y_account`, `swapper_x_account`, `swapper_y_account`, `swapper`, `referrer_x_account`, `referrer_y_account`, `referrer`, `program_authority`, `system_program`, `token_program`, `associated_token_program`, `rent`
- **Remaining accounts:** yes

### `UpdateFees`
- **Discriminator:** `[225, 27, 13, 6, 69, 84, 172, 191]`
- **Args:**
  - `new_buyback_fee`: `FixedPoint`
  - `new_project_fee`: `FixedPoint`
  - `new_provider_fee`: `FixedPoint`
  - `new_mercanti_fee`: `FixedPoint`
- **Account variants:**
  - `6 accounts:` `state`, `pool`, `token_x`, `token_y`, `admin`, `program_authority`
- **Remaining accounts:** yes

### `UpdateRewardTokens`
- **Discriminator:** `[249, 236, 71, 74, 104, 58, 225, 28]`
- **Args:** (none)
- **Account variants:**
  - `12 accounts:` `state`, `pool`, `farm`, `token_marco_account`, `token_project_first_account`, `token_project_second_account`, `token_marco`, `new_token_marco_account`, `admin`, `program_authority`, `system_program`, `token_program`
- **Remaining accounts:** yes

### `WithdrawBuyback`
- **Discriminator:** `[188, 75, 30, 198, 99, 43, 12, 54]`
- **Args:** (none)
- **Account variants:**
  - `14 accounts:` `state`, `pool`, `token_x`, `token_y`, `buyback_x_account`, `buyback_y_account`, `pool_x_account`, `pool_y_account`, `admin`, `program_authority`, `system_program`, `token_program`, `associated_token_program`, `rent`
- **Remaining accounts:** yes

### `WithdrawLpFee`
- **Discriminator:** `[149, 161, 2, 213, 195, 147, 42, 65]`
- **Args:** (none)
- **Account variants:**
  - `15 accounts:` `state`, `pool`, `provider`, `token_x`, `token_y`, `owner_x_account`, `owner_y_account`, `pool_x_account`, `pool_y_account`, `owner`, `program_authority`, `system_program`, `token_program`, `associated_token_program`, `rent`
- **Remaining accounts:** yes

### `WithdrawMercantiFee`
- **Discriminator:** `[253, 229, 129, 37, 47, 72, 11, 240]`
- **Args:** (none)
- **Account variants:**
  - `11 accounts:` `state`, `pool`, `token_x`, `token_y`, `mercanti_x_account`, `mercanti_y_account`, `pool_x_account`, `pool_y_account`, `admin`, `program_authority`, `token_program`
- **Remaining accounts:** yes

### `WithdrawProjectFee`
- **Discriminator:** `[130, 201, 142, 156, 159, 207, 168, 22]`
- **Args:** (none)
- **Account variants:**
  - `14 accounts:` `state`, `pool`, `token_x`, `token_y`, `project_owner_x_account`, `project_owner_y_account`, `pool_x_account`, `pool_y_account`, `project_owner`, `program_authority`, `system_program`, `token_program`, `associated_token_program`, `rent`
- **Remaining accounts:** yes

### `WithdrawRewards`
- **Discriminator:** `[10, 214, 219, 139, 205, 22, 251, 21]`
- **Args:** (none)
- **Account variants:**
  - `21 accounts:` `state`, `pool`, `farm`, `provider`, `token_x`, `token_y`, `token_marco`, `token_project_first`, `token_project_second`, `token_marco_account`, `token_project_first_account`, `token_project_second_account`, `owner_marco_account`, `owner_project_first_account`, `owner_project_second_account`, `owner`, `program_authority`, `system_program`, `token_program`, `associated_token_program`, `rent`
- **Remaining accounts:** yes

### `WithdrawShares`
- **Discriminator:** `[176, 104, 154, 105, 250, 80, 68, 244]`
- **Args:**
  - `shares`: `Token`
- **Account variants:**
  - `25 accounts:` `state`, `pool`, `farm`, `provider`, `token_x`, `token_y`, `token_marco`, `token_project_first`, `token_project_second`, `pool_x_account`, `pool_y_account`, `token_marco_account`, `token_project_first_account`, `token_project_second_account`, `owner_x_account`, `owner_y_account`, `owner_marco_account`, `owner_project_first_account`, `owner_project_second_account`, `owner`, `program_authority`, `system_program`, `token_program`, `associated_token_program`, `rent`
- **Remaining accounts:** yes

## Shared types

### `FarmType`
- Enum variants: `Single`, `Dual`, `Triple`

### `FixedPoint`
- `v`: `u128`

### `Product`
- `v`: `u128`

### `Token`
- `v`: `u64`
