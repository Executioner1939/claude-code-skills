# Raydium AMM v4

- **Crate:** `carbon-raydium-amm-v4-decoder`
- **Program ID:** `675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8`
- **Decoder struct:** `RaydiumAmmV4Decoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** no
- **Discriminator style:** raw byte/short

## Account types

### `AmmInfo`
- **Fields:**
  - `status`: `u64`
  - `nonce`: `u64`
  - `order_num`: `u64`
  - `depth`: `u64`
  - `coin_decimals`: `u64`
  - `pc_decimals`: `u64`
  - `state`: `u64`
  - `reset_flag`: `u64`
  - `min_size`: `u64`
  - `vol_max_cut_ratio`: `u64`
  - `amount_wave`: `u64`
  - `coin_lot_size`: `u64`
  - `pc_lot_size`: `u64`
  - `min_price_multiplier`: `u64`
  - `max_price_multiplier`: `u64`
  - `sys_decimal_value`: `u64`
  - `fees`: `Fees`
  - `out_put`: `OutPutData`
  - `token_coin`: `Pubkey`
  - `token_pc`: `Pubkey`
  - `coin_mint`: `Pubkey`
  - `pc_mint`: `Pubkey`
  - `lp_mint`: `Pubkey`
  - `open_orders`: `Pubkey`
  - `market`: `Pubkey`
  - `serum_dex`: `Pubkey`
  - `target_orders`: `Pubkey`
  - `withdraw_queue`: `Pubkey`
  - `token_temp_lp`: `Pubkey`
  - `amm_owner`: `Pubkey`
  - `lp_amount`: `u64`
  - `client_order_id`: `u64`
  - `padding`: `[u64; 2]`

### `Fees`
- **Fields:**
  - `min_separate_numerator`: `u64`
  - `min_separate_denominator`: `u64`
  - `trade_fee_numerator`: `u64`
  - `trade_fee_denominator`: `u64`
  - `pnl_numerator`: `u64`
  - `pnl_denominator`: `u64`
  - `swap_fee_numerator`: `u64`
  - `swap_fee_denominator`: `u64`

### `TargetOrders`
- **Fields:**
  - `owner`: `[u64; 4]`
  - `buy_orders`: `[TargetOrder; 50]`
  - `padding1`: `[u64; 8]`
  - `target_x`: `u128`
  - `target_y`: `u128`
  - `plan_x_buy`: `u128`
  - `plan_y_buy`: `u128`
  - `plan_x_sell`: `u128`
  - `plan_y_sell`: `u128`
  - `placed_x`: `u128`
  - `placed_y`: `u128`
  - `calc_pnl_x`: `u128`
  - `calc_pnl_y`: `u128`
  - `sell_orders`: `[TargetOrder; 50]`
  - `padding2`: `[u64; 6]`
  - `replace_buy_client_id`: `[u64; 10]`
  - `replace_sell_client_id`: `[u64; 10]`
  - `last_order_numerator`: `u64`
  - `last_order_denominator`: `u64`
  - `plan_orders_cur`: `u64`
  - `place_orders_cur`: `u64`
  - `valid_buy_order_num`: `u64`
  - `valid_sell_order_num`: `u64`
  - `padding3`: `[u64; 10]`
  - `free_slot_bits`: `u128`

## Instructions

### `AdminCancelOrders`
- **Discriminator:** `0x0d`
- **Args:**
  - `limit`: `u16`
- **Account variants:**
  - `17 accounts:` `token_program`, `amm`, `amm_authority`, `amm_open_orders`, `amm_target_orders`, `pool_coin_token_account`, `pool_pc_token_account`, `amm_owner_account`, `amm_config`, `serum_program`, `serum_market`, `serum_coin_vault_account`, `serum_pc_vault_account`, `serum_vault_signer`, `serum_event_q`, `serum_bids`, `serum_asks`

### `CreateConfigAccount`
- **Discriminator:** `0x0e`
- **Args:** (none)
- **Account variants:**
  - `5 accounts:` `admin`, `amm_config`, `owner`, `system_program`, `rent`

### `Deposit`
- **Discriminator:** `0x03`
- **Args:**
  - `max_coin_amount`: `u64`
  - `max_pc_amount`: `u64`
  - `base_side`: `u64`
- **Account variants:**
  - `14 accounts:` `token_program`, `amm`, `amm_authority`, `amm_open_orders`, `amm_target_orders`, `lp_mint_address`, `pool_coin_token_account`, `pool_pc_token_account`, `serum_market`, `user_coin_token_account`, `user_pc_token_account`, `user_lp_token_account`, `user_owner`, `serum_event_queue`

### `Initialize`
- **Discriminator:** `0x00`
- **Args:**
  - `nonce`: `u8`
  - `open_time`: `u64`
- **Account variants:**
  - `18 accounts:` `token_program`, `system_program`, `rent`, `amm`, `amm_authority`, `amm_open_orders`, `lp_mint_address`, `coin_mint_address`, `pc_mint_address`, `pool_coin_token_account`, `pool_pc_token_account`, `pool_withdraw_queue`, `pool_target_orders_account`, `user_lp_token_account`, `pool_temp_lp_token_account`, `serum_program`, `serum_market`, `user_wallet`

### `Initialize2`
- **Discriminator:** `0x01`
- **Args:**
  - `nonce`: `u8`
  - `open_time`: `u64`
  - `init_pc_amount`: `u64`
  - `init_coin_amount`: `u64`
- **Account variants:**
  - `21 accounts:` `token_program`, `spl_associated_token_account`, `system_program`, `rent`, `amm`, `amm_authority`, `amm_open_orders`, `lp_mint`, `coin_mint`, `pc_mint`, `pool_coin_token_account`, `pool_pc_token_account`, `pool_withdraw_queue`, `amm_target_orders`, `pool_temp_lp`, `serum_program`, `serum_market`, `user_wallet`, `user_token_coin`, `user_token_pc`, `user_lp_token_account`

### `MigrateToOpenBook`
- **Discriminator:** `0x05`
- **Args:** (none)
- **Account variants:**
  - `21 accounts:` `token_program`, `system_program`, `rent`, `amm`, `amm_authority`, `amm_open_orders`, `amm_token_coin`, `amm_token_pc`, `amm_target_orders`, `serum_program`, `serum_market`, `serum_bids`, `serum_asks`, `serum_event_queue`, `serum_coin_vault`, `serum_pc_vault`, `serum_vault_signer`, `new_amm_open_orders`, `new_serum_program`, `new_serum_market`, `admin`

### `MonitorStep`
- **Discriminator:** `0x02`
- **Args:**
  - `plan_order_limit`: `u16`
  - `place_order_limit`: `u16`
  - `cancel_order_limit`: `u16`
- **Account variants:**
  - `19 accounts:` `token_program`, `rent`, `clock`, `amm`, `amm_authority`, `amm_open_orders`, `amm_target_orders`, `pool_coin_token_account`, `pool_pc_token_account`, `pool_withdraw_queue`, `serum_program`, `serum_market`, `serum_coin_vault_account`, `serum_pc_vault_account`, `serum_vault_signer`, `serum_req_q`, `serum_event_q`, `serum_bids`, `serum_asks`

### `PreInitialize`
- **Discriminator:** `0x0a`
- **Args:**
  - `nonce`: `u8`
- **Account variants:**
  - `14 accounts:` `token_program`, `system_program`, `rent`, `amm_target_orders`, `pool_withdraw_queue`, `amm_authority`, `lp_mint_address`, `coin_mint_address`, `pc_mint_address`, `pool_coin_token_account`, `pool_pc_token_account`, `pool_temp_lp_token_account`, `serum_market`, `user_wallet`

### `SetParams`
- **Discriminator:** `0x06`
- **Args:**
  - `param`: `u8`
  - `value`: `Option<u64>`
  - `new_pubkey`: `Option<Pubkey>`
  - `fees`: `Option<Fees>`
  - `last_order_distance`: `Option<LastOrderDistance>`
  - `need_take_amounts`: `Option<NeedTake>`
- **Account variants:**
  - `16 accounts:` `token_program`, `amm`, `amm_authority`, `amm_open_orders`, `amm_target_orders`, `amm_coin_vault`, `amm_pc_vault`, `serum_program`, `serum_market`, `serum_coin_vault`, `serum_pc_vault`, `serum_vault_signer`, `serum_event_queue`, `serum_bids`, `serum_asks`, `amm_admin_account`
- **Optional accounts:** `new_amm_open_orders_account`

### `SimulateInfo`
- **Discriminator:** `0x0c`
- **Args:**
  - `param`: `u8`
  - `swap_base_in_value`: `Option<SwapInstructionBaseIn>`
  - `swap_base_out_value`: `Option<SwapInstructionBaseOut>`
- **Account variants:**
  - `8 accounts:` `amm`, `amm_authority`, `amm_open_orders`, `pool_coin_token_account`, `pool_pc_token_account`, `lp_mint_address`, `serum_market`, `serum_event_queue`

### `SwapBaseIn`
- **Discriminator:** `0x09`
- **Args:**
  - `amount_in`: `u64`
  - `minimum_amount_out`: `u64`
- **Account variants:**
  - `17 accounts:` `token_program`, `amm`, `amm_authority`, `amm_open_orders`, `pool_coin_token_account`, `pool_pc_token_account`, `serum_program`, `serum_market`, `serum_bids`, `serum_asks`, `serum_event_queue`, `serum_coin_vault_account`, `serum_pc_vault_account`, `serum_vault_signer`, `user_source_token_account`, `user_destination_token_account`, `user_source_owner`
  - `18 accounts:` `token_program`, `amm`, `amm_authority`, `amm_open_orders`, `amm_target_orders`, `pool_coin_token_account`, `pool_pc_token_account`, `serum_program`, `serum_market`, `serum_bids`, `serum_asks`, `serum_event_queue`, `serum_coin_vault_account`, `serum_pc_vault_account`, `serum_vault_signer`, `user_source_token_account`, `user_destination_token_account`, `user_source_owner`
- **Optional accounts:** `amm_target_orders`

### `SwapBaseInV2`
- **Discriminator:** `0x10`
- **Args:**
  - `amount_in`: `u64`
  - `minimum_amount_out`: `u64`
- **Account variants:**
  - `8 accounts:` `token_program`, `amm`, `amm_authority`, `amm_coin_token_account`, `amm_pc_token_account`, `user_source_token_account`, `user_destination_token_account`, `user_source_owner`

### `SwapBaseOut`
- **Discriminator:** `0x0b`
- **Args:**
  - `max_amount_in`: `u64`
  - `amount_out`: `u64`
- **Account variants:**
  - `17 accounts:` `token_program`, `amm`, `amm_authority`, `amm_open_orders`, `pool_coin_token_account`, `pool_pc_token_account`, `serum_program`, `serum_market`, `serum_bids`, `serum_asks`, `serum_event_queue`, `serum_coin_vault_account`, `serum_pc_vault_account`, `serum_vault_signer`, `user_source_token_account`, `user_destination_token_account`, `user_source_owner`
  - `18 accounts:` `token_program`, `amm`, `amm_authority`, `amm_open_orders`, `amm_target_orders`, `pool_coin_token_account`, `pool_pc_token_account`, `serum_program`, `serum_market`, `serum_bids`, `serum_asks`, `serum_event_queue`, `serum_coin_vault_account`, `serum_pc_vault_account`, `serum_vault_signer`, `user_source_token_account`, `user_destination_token_account`, `user_source_owner`
- **Optional accounts:** `amm_target_orders`

### `SwapBaseOutV2`
- **Discriminator:** `0x11`
- **Args:**
  - `max_amount_in`: `u64`
  - `amount_out`: `u64`
- **Account variants:**
  - `8 accounts:` `token_program`, `amm`, `amm_authority`, `amm_coin_token_account`, `amm_pc_token_account`, `user_source_token_account`, `user_destination_token_account`, `user_source_owner`

### `UpdateConfigAccount`
- **Discriminator:** `0x0f`
- **Args:**
  - `param`: `u8`
  - `owner`: `Pubkey`
- **Account variants:**
  - `2 accounts:` `admin`, `amm_config`

### `Withdraw`
- **Discriminator:** `0x04`
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `22 accounts:` `token_program`, `amm`, `amm_authority`, `amm_open_orders`, `amm_target_orders`, `lp_mint_address`, `pool_coin_token_account`, `pool_pc_token_account`, `pool_withdraw_queue`, `pool_temp_lp_token_account`, `serum_program`, `serum_market`, `serum_coin_vault_account`, `serum_pc_vault_account`, `serum_vault_signer`, `user_lp_token_account`, `user_coin_token_account`, `user_pc_token_account`, `user_owner`, `serum_event_q`, `serum_bids`, `serum_asks`

### `WithdrawPnl`
- **Discriminator:** `0x07`
- **Args:** (none)
- **Account variants:**
  - `17 accounts:` `token_program`, `amm`, `amm_config`, `amm_authority`, `amm_open_orders`, `pool_coin_token_account`, `pool_pc_token_account`, `coin_pnl_token_account`, `pc_pnl_token_account`, `pnl_owner_account`, `amm_target_orders`, `serum_program`, `serum_market`, `serum_event_queue`, `serum_coin_vault_account`, `serum_pc_vault_account`, `serum_vault_signer`

### `WithdrawSrm`
- **Discriminator:** `0x08`
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `6 accounts:` `token_program`, `amm`, `amm_owner_account`, `amm_authority`, `srm_token`, `dest_srm_token`

## Shared types

### `AmmConfig`
- `pnl_owner`: `Pubkey`
- `cancel_owner`: `Pubkey`
- `pending1`: `[u64; 28]`
- `pending2`: `[u64; 32]`

### `LastOrderDistance`
- `last_order_numerator`: `u64`
- `last_order_denominator`: `u64`

### `NeedTake`
- `need_take_pc`: `u64`
- `need_take_coin`: `u64`

### `OutPutData`
- `need_take_pnl_coin`: `u64`
- `need_take_pnl_pc`: `u64`
- `total_pnl_pc`: `u64`
- `total_pnl_coin`: `u64`
- `pool_open_time`: `u64`
- `punish_pc_amount`: `u64`
- `punish_coin_amount`: `u64`
- `orderbook_to_init_time`: `u64`
- `swap_coin_in_amount`: `u128`
- `swap_pc_out_amount`: `u128`
- `swap_take_pc_fee`: `u64`
- `swap_pc_in_amount`: `u128`
- `swap_coin_out_amount`: `u128`
- `swap_take_coin_fee`: `u64`

### `SwapInstructionBaseIn`
- `amount_in`: `u64`
- `minimum_amount_out`: `u64`

### `SwapInstructionBaseOut`
- `max_amount_in`: `u64`
- `amount_out`: `u64`

### `TargetOrder`
- `price`: `u64`
- `vol`: `u64`

### `WithdrawDestToken`
- `withdraw_amount`: `u64`
- `coin_amount`: `u64`
- `pc_amount`: `u64`
- `dest_token_coin`: `Pubkey`
- `dest_token_pc`: `Pubkey`

### `WithdrawQueue`
- `owner`: `[u64; 4]`
- `head`: `u64`
- `count`: `u64`
- `buf`: `[WithdrawDestToken; 64]`
