# Fluxbeam

- **Crate:** `carbon-fluxbeam-decoder`
- **Program ID:** `FLUXubRmkEi2q6K3Y9kBPg9248ggaZVsoSFhtJHSrm1X`
- **Decoder struct:** `FluxbeamDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** no
- **Discriminator style:** raw byte/short

## Account types

### `SwapV1`
- **Fields:**
  - `_padding`: `u8`
  - `is_initialized`: `bool`
  - `bump_seed`: `u8`
  - `token_program_id`: `Pubkey`
  - `token_a`: `Pubkey`
  - `token_b`: `Pubkey`
  - `pool_mint`: `Pubkey`
  - `token_a_mint`: `Pubkey`
  - `token_b_mint`: `Pubkey`
  - `pool_fee_account`: `Pubkey`
  - `fees`: `Fees`
  - `swap_curve`: `SwapCurve`

## Instructions

### `DepositAllTokenTypes`
- **Discriminator:** `0x02`
- **Args:**
  - `pool_token_amount`: `u64`
  - `maximum_token_a_amount`: `u64`
  - `maximum_token_b_amount`: `u64`
- **Account variants:**
  - `14 accounts:` `swap`, `authority`, `user_transfer_authority`, `deposit_token_a`, `deposit_token_b`, `swap_token_a`, `swap_token_b`, `pool_mint`, `destination`, `token_a_mint`, `token_b_mint`, `token_a_program`, `token_b_program`, `token_program`

### `DepositSingleTokenTypeExactAmountIn`
- **Discriminator:** `0x04`
- **Args:**
  - `source_token_amount`: `u64`
  - `minimum_pool_token_amount`: `u64`
- **Account variants:**
  - `11 accounts:` `swap`, `authority`, `user_transfer_authority`, `source_token`, `swap_token_a`, `swap_token_b`, `pool_mint`, `destination`, `source_mint`, `token_a_program`, `token_b_program`

### `Initialize`
- **Discriminator:** `0x00`
- **Args:**
  - `fees`: `Fees`
  - `swap_curve`: `SwapCurve`
- **Account variants:**
  - `8 accounts:` `swap`, `authority`, `token_a`, `token_b`, `pool`, `fee`, `destination`, `token_program`

### `Swap`
- **Discriminator:** `0x01`
- **Args:**
  - `amount_in`: `u64`
  - `minimum_amount_out`: `u64`
- **Account variants:**
  - `15 accounts:` `swap`, `authority`, `user_transfer_authority`, `source`, `swap_source`, `swap_destination`, `destination`, `pool_mint`, `pool_fee`, `source_mint`, `destination_mint`, `source_token_program`, `destination_token_program`, `pool_token_program`, `swap_program`

### `WithdrawAllTokenTypes`
- **Discriminator:** `0x03`
- **Args:**
  - `pool_token_amount`: `u64`
  - `minimum_token_a_amount`: `u64`
  - `minimum_token_b_amount`: `u64`
- **Account variants:**
  - `15 accounts:` `swap`, `authority`, `user_transfer_authority`, `pool_mint`, `source`, `swap_token_a`, `swap_token_b`, `destination_token_a`, `destination_token_b`, `fee_account`, `token_a_mint`, `token_b_mint`, `pool_token_program`, `token_a_program`, `token_b_program`

### `WithdrawSingleTokenTypeExactAmountOut`
- **Discriminator:** `0x05`
- **Args:**
  - `destination_token_amount`: `u64`
  - `maximum_pool_token_amount`: `u64`
- **Account variants:**
  - `12 accounts:` `swap`, `authority`, `user_transfer_authority`, `pool_mint`, `pool_token_source`, `swap_token_a`, `swap_token_b`, `destination`, `fee_account`, `destination_mint`, `token_a_program`, `token_b_program`

## Shared types

### `ConstantPriceCurve`
- `token_b_price`: `u64`

### `ConstantProductCurve`
(empty struct)

### `CurveType`
- enum variants: `ConstantProduct`, `ConstantPrice`, `Offset`

### `Fees`
- `trade_fee_numerator`: `u64`
- `trade_fee_denominator`: `u64`
- `owner_trade_fee_numerator`: `u64`
- `owner_trade_fee_denominator`: `u64`
- `owner_withdraw_fee_numerator`: `u64`
- `owner_withdraw_fee_denominator`: `u64`
- `host_fee_numerator`: `u64`
- `host_fee_denominator`: `u64`

### `OffsetCurve`
- `token_b_offset`: `u64`

### `SwapCurve`
- `curve_type`: `CurveType`
- `calculator`: `[u8; 32]`
