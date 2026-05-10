# Lifinity AMM V2

- **Crate:** `carbon-lifinity-amm-v2-decoder`
- **Program ID:** `2wT8Yq49kHgDzXuPxZSaeLaH1qbmGXtEyPy64bL7aD3c`
- **Decoder struct:** `LifinityAmmV2Decoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** no
- **Discriminator style:** anchor 8-byte

## Account types

### `Amm`
- **Fields:**
  - `initializer_key`: `Pubkey`
  - `initializer_deposit_token_account`: `Pubkey`
  - `initializer_receive_token_account`: `Pubkey`
  - `initializer_amount`: `u64`
  - `taker_amount`: `u64`
  - `is_initialized`: `bool`
  - `bump_seed`: `u8`
  - `freeze_trade`: `u8`
  - `freeze_deposit`: `u8`
  - `freeze_withdraw`: `u8`
  - `base_decimals`: `u8`
  - `token_program_id`: `Pubkey`
  - `token_a_account`: `Pubkey`
  - `token_b_account`: `Pubkey`
  - `pool_mint`: `Pubkey`
  - `token_a_mint`: `Pubkey`
  - `token_b_mint`: `Pubkey`
  - `fee_account`: `Pubkey`
  - `oracle_main_account`: `Pubkey`
  - `oracle_sub_account`: `Pubkey`
  - `oracle_pc_account`: `Pubkey`
  - `fees`: `AmmFees`
  - `curve`: `AmmCurve`
  - `config`: `AmmConfig`
  - `amm_p_temp1`: `Pubkey`
  - `amm_p_temp2`: `Pubkey`
  - `amm_p_temp3`: `Pubkey`
  - `amm_p_temp4`: `Pubkey`
  - `amm_p_temp5`: `Pubkey`

## Instructions

### `DepositAllTokenTypes`
- **Discriminator:** `0x205f453c4b4fcdee`
- **Args:**
  - `pool_token_amount`: `u64`
  - `maximum_token_a_amount`: `u64`
  - `maximum_token_b_amount`: `u64`
- **Account variants:**
  - `10 accounts:` `amm`, `authority`, `user_transfer_authority_info`, `source_a_info`, `source_b_info`, `token_a`, `token_b`, `pool_mint`, `destination`, `token_program`

### `Swap`
- **Discriminator:** `0xf8c69e91e17587c8`
- **Args:**
  - `amount_in`: `u64`
  - `minimum_amount_out`: `u64`
- **Account variants:**
  - `13 accounts:` `authority`, `amm`, `user_transfer_authority`, `source_info`, `destination_info`, `swap_source`, `swap_destination`, `pool_mint`, `fee_account`, `token_program`, `oracle_main_account`, `oracle_sub_account`, `oracle_pc_account`

### `WithdrawAllTokenTypes`
- **Discriminator:** `0xbdfe9caed209a4d8`
- **Args:**
  - `pool_token_amount`: `u64`
  - `minimum_token_a_amount`: `u64`
  - `minimum_token_b_amount`: `u64`
- **Account variants:**
  - `10 accounts:` `amm`, `authority`, `user_transfer_authority_info`, `source_info`, `token_a`, `token_b`, `pool_mint`, `dest_token_a_info`, `dest_token_b_info`, `token_program`

## Shared types

### `AmmConfig`
- `last_price`: `u64`
- `last_balanced_price`: `u64`
- `config_denominator`: `u64`
- `volume_x`: `u64`
- `volume_y`: `u64`
- `volume_x_in_y`: `u64`
- `deposit_cap`: `u64`
- `regression_target`: `u64`
- `oracle_type`: `u64`
- `oracle_status`: `u64`
- `oracle_main_slot_limit`: `u64`
- `oracle_sub_confidence_limit`: `u64`
- `oracle_sub_slot_limit`: `u64`
- `oracle_pc_confidence_limit`: `u64`
- `oracle_pc_slot_limit`: `u64`
- `std_spread`: `u64`
- `std_spread_buffer`: `u64`
- `spread_coefficient`: `u64`
- `price_buffer_coin`: `i64`
- `price_buffer_pc`: `i64`
- `rebalance_ratio`: `u64`
- `fee_trade`: `u64`
- `fee_platform`: `u64`
- `oracle_main_slot_buffer`: `u64`
- `config_temp4`: `u64`
- `config_temp5`: `u64`
- `config_temp6`: `u64`
- `config_temp7`: `u64`
- `config_temp8`: `u64`

### `AmmCurve`
- `curve_type`: `u8`
- `curve_parameters`: `u64`

### `AmmFees`
- `trade_fee_numerator`: `u64`
- `trade_fee_denominator`: `u64`
- `owner_trade_fee_numerator`: `u64`
- `owner_trade_fee_denominator`: `u64`
- `owner_withdraw_fee_numerator`: `u64`
- `owner_withdraw_fee_denominator`: `u64`
- `host_fee_numerator`: `u64`
- `host_fee_denominator`: `u64`

### `CurveType` (enum)
- `Standard`
- `ConstantProduct`
