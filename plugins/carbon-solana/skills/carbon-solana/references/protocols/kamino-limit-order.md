# Kamino Limit Order

- **Crate:** `carbon-kamino-limit-order-decoder`
- **Program ID:** `LiMoM9rMhrdYrfzUCxQppvxCSG1FcrUK9G8uLq4A1GF`
- **Decoder struct:** `KaminoLimitOrderDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in instructions/)
- **Discriminator style:** anchor 8-byte

## Account types

### `GlobalConfig`
- **Fields:**
  - `emergency_mode`: `u8`
  - `flash_take_order_blocked`: `u8`
  - `new_orders_blocked`: `u8`
  - `orders_taking_blocked`: `u8`
  - `host_fee_bps`: `u16`
  - `is_order_taking_permissionless`: `u8`
  - `padding0`: `[u8; 1]`
  - `order_close_delay_seconds`: `u64`
  - `padding1`: `[u64; 9]`
  - `pda_authority_previous_lamports_balance`: `u64`
  - `total_tip_amount`: `u64`
  - `host_tip_amount`: `u64`
  - `pda_authority`: `Pubkey`
  - `pda_authority_bump`: `u64`
  - `admin_authority`: `Pubkey`
  - `admin_authority_cached`: `Pubkey`
  - `padding2`: `[u64; 243]`

### `Order`
- **Fields:**
  - `global_config`: `Pubkey`
  - `maker`: `Pubkey`
  - `input_mint`: `Pubkey`
  - `input_mint_program_id`: `Pubkey`
  - `output_mint`: `Pubkey`
  - `output_mint_program_id`: `Pubkey`
  - `initial_input_amount`: `u64`
  - `expected_output_amount`: `u64`
  - `remaining_input_amount`: `u64`
  - `filled_output_amount`: `u64`
  - `tip_amount`: `u64`
  - `number_of_fills`: `u64`
  - `order_type`: `u8`
  - `status`: `u8`
  - `in_vault_bump`: `u8`
  - `flash_ix_lock`: `u8`
  - `padding0`: `[u8; 4]`
  - `last_updated_timestamp`: `u64`
  - `flash_start_taker_output_balance`: `u64`
  - `padding`: `[u64; 19]`

## Instructions

### `CloseOrderAndClaimTip`
- **Discriminator:** `0xf41b0ce22df7e62b`
- **Args:** (none)
- **Account variants:**
  - `12 accounts:` `maker`, `order`, `global_config`, `pda_authority`, `input_mint`, `output_mint`, `maker_input_ata`, `input_vault`, `input_token_program`, `system_program`, `event_authority`, `program`

### `CreateOrder`
- **Discriminator:** `0x8d3625cfedd2fad7`
- **Args:**
  - `input_amount`: `u64`
  - `output_amount`: `u64`
  - `order_type`: `u8`
- **Account variants:**
  - `12 accounts:` `maker`, `global_config`, `pda_authority`, `order`, `input_mint`, `output_mint`, `maker_ata`, `input_vault`, `input_token_program`, `output_token_program`, `event_authority`, `program`

### `FlashTakeOrderEnd`
- **Discriminator:** `0xcef2d7bb8621e094`
- **Args:**
  - `input_amount`: `u64`
  - `min_output_amount`: `u64`
  - `tip_amount_permissionless_taking`: `u64`
- **Account variants:**
  - `23 accounts:` `taker`, `maker`, `global_config`, `pda_authority`, `order`, `input_mint`, `output_mint`, `input_vault`, `taker_input_ata`, `taker_output_ata`, `intermediary_output_token_account`, `maker_output_ata`, `express_relay`, `express_relay_metadata`, `sysvar_instructions`, `permission`, `config_router`, `input_token_program`, `output_token_program`, `system_program`, `rent`, `event_authority`, `program`

### `FlashTakeOrderStart`
- **Discriminator:** `0x7e35b00f276761f3`
- **Args:**
  - `input_amount`: `u64`
  - `min_output_amount`: `u64`
  - `tip_amount_permissionless_taking`: `u64`
- **Account variants:**
  - `23 accounts:` `taker`, `maker`, `global_config`, `pda_authority`, `order`, `input_mint`, `output_mint`, `input_vault`, `taker_input_ata`, `taker_output_ata`, `intermediary_output_token_account`, `maker_output_ata`, `express_relay`, `express_relay_metadata`, `sysvar_instructions`, `permission`, `config_router`, `input_token_program`, `output_token_program`, `system_program`, `rent`, `event_authority`, `program`

### `InitializeGlobalConfig`
- **Discriminator:** `0x71d87a83e1d11637`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `admin_authority`, `pda_authority`, `global_config`

### `InitializeVault`
- **Discriminator:** `0x30bfa32c47813fa4`
- **Args:** (none)
- **Account variants:**
  - `7 accounts:` `payer`, `global_config`, `pda_authority`, `mint`, `vault`, `token_program`, `system_program`

### `LogUserSwapBalances`
- **Discriminator:** `0x23765f4de72e8026`
- **Args:** (none)
- **Account variants:**
  - `7 accounts:` `maker`, `input_mint`, `output_mint`, `input_ta`, `output_ta`, `event_authority`, `program`

### `TakeOrder`
- **Discriminator:** `0xa3d014acdf41ffe4`
- **Args:**
  - `input_amount`: `u64`
  - `min_output_amount`: `u64`
  - `tip_amount_permissionless_taking`: `u64`
- **Account variants:**
  - `23 accounts:` `taker`, `maker`, `global_config`, `pda_authority`, `order`, `input_mint`, `output_mint`, `input_vault`, `taker_input_ata`, `taker_output_ata`, `intermediary_output_token_account`, `maker_output_ata`, `express_relay`, `express_relay_metadata`, `sysvar_instructions`, `permission`, `config_router`, `input_token_program`, `output_token_program`, `rent`, `system_program`, `event_authority`, `program`

### `UpdateGlobalConfig`
- **Discriminator:** `0xa45482bd6f3afac8`
- **Args:**
  - `mode`: `u16`
  - `value`: `[u8; 128]`
- **Account variants:**
  - `2 accounts:` `admin_authority`, `global_config`

### `UpdateGlobalConfigAdmin`
- **Discriminator:** `0xb85717c19ceeaf77`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `admin_authority_cached`, `global_config`

### `WithdrawHostTip`
- **Discriminator:** `0x8cf669a550558f12`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `admin_authority`, `global_config`, `pda_authority`, `system_program`

## CPI events

### `OrderDisplayEvent`
- **Source:** `instructions/order_display_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d5c65069ef898f13c`
- **Fields:**
  - `initial_input_amount`: `u64`
  - `expected_output_amount`: `u64`
  - `remaining_input_amount`: `u64`
  - `filled_output_amount`: `u64`
  - `tip_amount`: `u64`
  - `number_of_fills`: `u64`
  - `on_event_output_amount_filled`: `u64`
  - `on_event_tip_amount`: `u64`
  - `order_type`: `u8`
  - `status`: `u8`
  - `last_updated_timestamp`: `u64`

### `UserSwapBalancesEvent`
- **Source:** `instructions/user_swap_balances_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d496bcee1a13b400f`
- **Fields:**
  - `user_lamports`: `u64`
  - `input_ta_balance`: `u64`
  - `output_ta_balance`: `u64`

## Shared types

### `OrderStatus` (enum)
- `Active`
- `Filled`
- `Cancelled`

### `OrderType` (enum)
- `Vanilla`

### `UpdateGlobalConfigMode` (enum)
- `UpdateEmergencyMode`
- `UpdateFlashTakeOrderBlocked`
- `UpdateBlockNewOrders`
- `UpdateBlockOrderTaking`
- `UpdateHostFeeBps`
- `UpdateAdminAuthorityCached`
- `UpdateOrderTakingPermissionless`
- `UpdateOrderCloseDelaySeconds`

### `UpdateGlobalConfigValue` (enum)
- `Bool(bool)`
- `U16(u16)`
- `U64(u64)`
- `Pubkey(Pubkey)`
