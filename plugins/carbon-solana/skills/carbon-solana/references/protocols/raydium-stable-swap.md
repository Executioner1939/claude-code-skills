# Raydium Stable Swap

- **Crate:** `carbon-raydium-stable-swap-decoder`
- **Program ID:** `5quBtoiQqxF9Jv6KYKctB59NT3gtJD2Y65kdnB1Uev3h`
- **Decoder struct:** `RaydiumStableSwapAmmDecoder`
- **Has accounts:** no
- **Has instructions:** yes
- **Has CPI events:** no
- **Discriminator style:** raw byte/short

## Instructions

### `Deposit`
- **Discriminator:** `0x03`
- **Args:**
  - `max_coin_amount`: `u64`
  - `max_pc_amount`: `u64`
  - `base_side`: `u64`
- **Account variants:**
  - `13 accounts:` `spl_token_program`, `amm_account`, `authority`, `amm_open_orders`, `amm_target_orders`, `pool_lp_mint`, `pool_token_coin`, `pool_token_pc`, `serum_market`, `user_coin_token`, `user_pc_token`, `user_lp_token`, `user_owner`
- **Remaining accounts:** yes

### `Initialize`
- **Discriminator:** `0x00`
- **Args:**
  - `nonce`: `u8`
  - `open_time`: `u64`
- **Account variants:**
  - `14 accounts:` `spl_token_program`, `amm_id`, `amm_authority`, `amm_open_orders`, `pool_lp_mint`, `coin_mint`, `pc_mint`, `pool_token_coin`, `pool_token_pc`, `withdraw_queue`, `token_dest_lp`, `token_temp_lp`, `serum_dex_program_id`, `serum_dex_market`
- **Remaining accounts:** yes

### `PreInitialize`
- **Discriminator:** `0x0a`
- **Args:**
  - `nonce`: `u8`
- **Account variants:**
  - `0 accounts:` (none)

### `SwapBaseIn`
- **Discriminator:** `0x09`
- **Args:**
  - `amount_in`: `u64`
  - `minimum_amount_out`: `u64`
- **Account variants:**
  - `18 accounts:` `spl_token_program`, `amm_account`, `authority`, `amm_open_orders`, `amm_target_orders`, `pool_token_coin`, `pool_token_pc`, `serum_dex_program_id`, `serum_market`, `bids`, `asks`, `event_q`, `coin_vault`, `pc_vault`, `vault_signer`, `user_source_token`, `user_destination_token`, `user_owner`
- **Remaining accounts:** yes

### `SwapBaseOut`
- **Discriminator:** `0x0b`
- **Args:**
  - `max_amount_in`: `u64`
  - `amount_out`: `u64`
- **Account variants:**
  - `18 accounts:` `spl_token_program`, `amm_account`, `authority`, `amm_open_orders`, `amm_target_orders`, `pool_token_coin`, `pool_token_pc`, `serum_dex_program_id`, `serum_market`, `bids`, `asks`, `event_q`, `coin_vault`, `pc_vault`, `vault_signer`, `user_source_token`, `user_destination_token`, `user_owner`
- **Remaining accounts:** yes

### `Withdraw`
- **Discriminator:** `0x04`
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `19 accounts:` `spl_token_program`, `amm_account`, `authority`, `amm_open_orders`, `amm_target_orders`, `pool_lp_mint`, `pool_token_coin`, `pool_token_pc`, `withdraw_queue`, `token_temp_lp`, `serum_dex_program_id`, `serum_market`, `coin_vault`, `pc_vault`, `vault_signer`, `user_lp_token`, `user_token_coin`, `user_token_pc`, `user_owner`
- **Remaining accounts:** yes
