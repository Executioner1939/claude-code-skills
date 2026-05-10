# Jupiter Limit Order 2

- **Crate:** `carbon-jupiter-limit-order-2-decoder`
- **Program ID:** `j1o2qRpjcyUwEvwtcfhEQefh773ZgjxcVRry7LDqg5X`
- **Decoder struct:** `JupiterLimitOrder2Decoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in instructions/)
- **Discriminator style:** anchor 8-byte

## Account types

### `Fee`
- **Fields:**
  - `normal_fee_bps`: `u16`
  - `stable_fee_bps`: `u16`

### `Order`
- **Fields:**
  - `maker`: `Pubkey`
  - `input_mint`: `Pubkey`
  - `output_mint`: `Pubkey`
  - `input_token_program`: `Pubkey`
  - `output_token_program`: `Pubkey`
  - `input_mint_reserve`: `Pubkey`
  - `unique_id`: `u64`
  - `ori_making_amount`: `u64`
  - `ori_taking_amount`: `u64`
  - `making_amount`: `u64`
  - `taking_amount`: `u64`
  - `borrow_making_amount`: `u64`
  - `expired_at`: `Option<i64>`
  - `fee_bps`: `u16`
  - `fee_account`: `Pubkey`
  - `created_at`: `i64`
  - `updated_at`: `i64`
  - `bump`: `u8`

## Instructions

### `CancelOrder`
- **Discriminator:** `0x5f81edf00831df84`
- **Args:** (none)
- **Account variants:**
  - `9 accounts:` `signer`, `maker`, `order`, `input_mint_reserve`, `maker_input_mint_account`, `input_mint`, `input_token_program`, `event_authority`, `program`

### `FlashFillOrder`
- **Discriminator:** `0xfc681286a44e128c`
- **Args:**
  - `params`: `FlashFillOrderParams`
- **Account variants:**
  - `13 accounts:` `taker`, `maker`, `order`, `input_mint_reserve`, `maker_output_mint_account`, `taker_output_mint_account`, `fee_account`, `input_token_program`, `output_mint`, `output_token_program`, `system_program`, `event_authority`, `program`

### `InitializeOrder`
- **Discriminator:** `0x856e4aaf709ff59f`
- **Args:**
  - `params`: `InitializeOrderParams`
- **Account variants:**
  - `15 accounts:` `payer`, `maker`, `order`, `input_mint_reserve`, `maker_input_mint_account`, `fee`, `referral`, `input_mint`, `output_mint`, `input_token_program`, `output_token_program`, `system_program`, `associated_token_program`, `event_authority`, `program`

### `PreFlashFillOrder`
- **Discriminator:** `0xf02f99440dbee12a`
- **Args:**
  - `params`: `PreFlashFillOrderParams`
- **Account variants:**
  - `7 accounts:` `taker`, `order`, `input_mint_reserve`, `taker_input_mint_account`, `input_mint`, `input_token_program`, `instruction`

### `UpdateFee`
- **Discriminator:** `0xe8fdc3f794d449de`
- **Args:**
  - `params`: `UpdateFeeParams`
- **Account variants:**
  - `3 accounts:` `admin`, `fee_authority`, `system_program`

### `WithdrawFee`
- **Discriminator:** `0x0e7ae7da1feedf96`
- **Args:** (none)
- **Account variants:**
  - `6 accounts:` `admin`, `fee_authority`, `program_fee_account`, `admin_token_acocunt`, `token_program`, `mint`

## CPI events

### `CancelOrderEvent`
- **Source:** `instructions/cancel_order_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1dae428d1104e0a24d`
- **Fields:**
  - `order_key`: `Pubkey`

### `CreateOrderEvent`
- **Source:** `instructions/create_order_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d318e48a6e61d5454`
- **Fields:**
  - `order_key`: `Pubkey`
  - `maker`: `Pubkey`
  - `input_mint`: `Pubkey`
  - `output_mint`: `Pubkey`
  - `input_token_program`: `Pubkey`
  - `output_token_program`: `Pubkey`
  - `making_amount`: `u64`
  - `taking_amount`: `u64`
  - `expired_at`: `Option<i64>`
  - `fee_bps`: `u16`
  - `fee_account`: `Pubkey`

### `TradeEvent`
- **Source:** `instructions/trade_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1dbddb7fd34ee661ee`
- **Fields:**
  - `order_key`: `Pubkey`
  - `taker`: `Pubkey`
  - `remaining_making_amount`: `u64`
  - `remaining_taking_amount`: `u64`
  - `making_amount`: `u64`
  - `taking_amount`: `u64`

## Shared types

### `FlashFillOrderParams`
- `max_taking_amount`: `u64`

### `InitializeOrderParams`
- `unique_id`: `u64`
- `making_amount`: `u64`
- `taking_amount`: `u64`
- `expired_at`: `Option<i64>`
- `fee_bps`: `Option<u16>`

### `PreFlashFillOrderParams`
- `making_amount`: `u64`

### `UpdateFeeParams`
- `normal_fee_bps`: `u16`
- `stable_fee_bps`: `u16`
