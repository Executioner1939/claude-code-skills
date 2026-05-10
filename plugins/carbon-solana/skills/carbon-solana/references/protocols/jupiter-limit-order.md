# Jupiter Limit Order

- **Crate:** `carbon-jupiter-limit-order-decoder`
- **Program ID:** `jupoNjAxXgZ4rjzxzPMP4oxduvQsQtZzyknqvzYNrNu`
- **Decoder struct:** `JupiterLimitOrderDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in instructions/)
- **Discriminator style:** anchor 8-byte

## Account types

### `Fee`
- **Fields:**
  - `maker_fee`: `u64`
  - `maker_stable_fee`: `u64`
  - `taker_fee`: `u64`
  - `taker_stable_fee`: `u64`

### `Order`
- **Fields:**
  - `maker`: `Pubkey`
  - `input_mint`: `Pubkey`
  - `output_mint`: `Pubkey`
  - `waiting`: `bool`
  - `ori_making_amount`: `u64`
  - `ori_taking_amount`: `u64`
  - `making_amount`: `u64`
  - `taking_amount`: `u64`
  - `maker_input_account`: `Pubkey`
  - `maker_output_account`: `Pubkey`
  - `reserve`: `Pubkey`
  - `borrow_making_amount`: `u64`
  - `expired_at`: `Option<i64>`
  - `base`: `Pubkey`
  - `referral`: `Option<Pubkey>`

## Instructions

### `CancelExpiredOrder`
- **Discriminator:** `0xd87840eb9b13e563`
- **Args:** (none)
- **Account variants:**
  - `7 accounts:` `order`, `reserve`, `maker`, `maker_input_account`, `system_program`, `token_program`, `input_mint`

### `CancelOrder`
- **Discriminator:** `0x5f81edf00831df84`
- **Args:** (none)
- **Account variants:**
  - `7 accounts:` `order`, `reserve`, `maker`, `maker_input_account`, `system_program`, `token_program`, `input_mint`

### `FillOrder`
- **Discriminator:** `0xe87a7319c78f88a2`
- **Args:**
  - `making_amount`: `u64`
  - `max_taking_amount`: `u64`
- **Account variants:**
  - `12 accounts:` `order`, `reserve`, `maker`, `taker`, `taker_output_account`, `maker_output_account`, `taker_input_account`, `fee_authority`, `program_fee_account`, `referral`, `token_program`, `system_program`

### `FlashFillOrder`
- **Discriminator:** `0xfc681286a44e128c`
- **Args:**
  - `max_taking_amount`: `u64`
- **Account variants:**
  - `14 accounts:` `order`, `reserve`, `maker`, `taker`, `maker_output_account`, `taker_input_account`, `fee_authority`, `program_fee_account`, `referral`, `input_mint`, `input_mint_token_program`, `output_mint`, `output_mint_token_program`, `system_program`

### `InitFee`
- **Discriminator:** `0x0d09d36b3eace043`
- **Args:**
  - `maker_fee`: `u64`
  - `maker_stable_fee`: `u64`
  - `taker_fee`: `u64`
  - `taker_stable_fee`: `u64`
- **Account variants:**
  - `3 accounts:` `keeper`, `fee_authority`, `system_program`

### `InitializeOrder`
- **Discriminator:** `0x856e4aaf709ff59f`
- **Args:**
  - `making_amount`: `u64`
  - `taking_amount`: `u64`
  - `expired_at`: `Option<i64>`
- **Account variants:**
  - `12 accounts:` `base`, `maker`, `order`, `reserve`, `maker_input_account`, `input_mint`, `maker_output_account`, `referral`, `output_mint`, `system_program`, `token_program`, `rent`

### `PreFlashFillOrder`
- **Discriminator:** `0xf02f99440dbee12a`
- **Args:**
  - `making_amount`: `u64`
- **Account variants:**
  - `8 accounts:` `order`, `reserve`, `taker`, `taker_output_account`, `input_mint`, `input_mint_token_program`, `instruction`, `system_program`

### `UpdateFee`
- **Discriminator:** `0xe8fdc3f794d449de`
- **Args:**
  - `maker_fee`: `u64`
  - `maker_stable_fee`: `u64`
  - `taker_fee`: `u64`
  - `taker_stable_fee`: `u64`
- **Account variants:**
  - `2 accounts:` `keeper`, `fee_authority`

### `WithdrawFee`
- **Discriminator:** `0x0e7ae7da1feedf96`
- **Args:**
  - `amount`: `u64`
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
  - `in_amount`: `u64`
  - `out_amount`: `u64`
  - `expired_at`: `Option<i64>`

### `TradeEvent`
- **Source:** `instructions/trade_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1dbddb7fd34ee661ee`
- **Fields:**
  - `order_key`: `Pubkey`
  - `taker`: `Pubkey`
  - `remaining_in_amount`: `u64`
  - `remaining_out_amount`: `u64`
  - `in_amount`: `u64`
  - `out_amount`: `u64`
