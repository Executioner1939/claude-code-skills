# Vertigo

- **Crate:** `carbon-vertigo-decoder`
- **Program ID:** `vrTGoBuy5rYSxAfV3jaRJWHH6nN9WK4NRExGxsk1bCJ`
- **Decoder struct:** `VertigoDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in instructions/, *_event.rs)
- **Discriminator style:** anchor 8-byte (events use 16-byte anchor event discriminator)

## Account types

### `Pool`
- **Discriminator:** `0xf19a6d0411b16dbc`
- **Fields:**
  - `enabled`: `bool`
  - `owner`: `Pubkey`
  - `mint_a`: `Pubkey`
  - `mint_b`: `Pubkey`
  - `token_a_reserves`: `u128`
  - `token_b_reserves`: `u128`
  - `shift`: `u128`
  - `royalties`: `u64`
  - `vertigo_fees`: `u64`
  - `bump`: `u8`
  - `fee_params`: `FeeParams`

## Instructions

### `Buy`
- **Discriminator:** `0x66063d1201daebea`
- **Args:** `params`: `SwapParams`
- **Account variants:**
  - `13 accounts:` `pool, user, owner, mint_a, mint_b, user_ta_a, user_ta_b, vault_a, vault_b, token_program_a, token_program_b, system_program, program`

### `Sell`
- **Discriminator:** `0x33e685a4017f83ad`
- **Args:** `params`: `SwapParams`
- **Account variants:**
  - `13 accounts:` `pool, user, owner, mint_a, mint_b, user_ta_a, user_ta_b, vault_a, vault_b, token_program_a, token_program_b, system_program, program`

### `Create`
- **Discriminator:** `0x181ec828051c0777`
- **Args:** `params`: `CreateParams`
- **Account variants:**
  - `13 accounts:` `payer, owner, token_wallet_authority, mint_a, mint_b, token_wallet_b, pool, vault_a, vault_b, token_program_a, token_program_b, system_program, rent`

### `Claim`
- **Discriminator:** `0x3ec6d6c1d59f6cd2`
- **Args:** (none)
- **Account variants:**
  - `7 accounts:` `pool, system_program, claimer, mint_a, vault_a, receiver_ta_a, token_program_a`

### `QuoteBuy`
- **Discriminator:** `0x5309e76e921f280c`
- **Args:** `params`: `SwapParams`
- **Account variants:**
  - `6 accounts:` `pool, owner, user, mint_a, mint_b, program`

### `QuoteSell`
- **Discriminator:** `0x05b231ce8ce78391`
- **Args:** `params`: `SwapParams`
- **Account variants:**
  - `6 accounts:` `pool, owner, user, mint_a, mint_b, program`

## CPI events

### `BuyEvent`
- **Source:** `instructions/buy_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d67f4521f2cf57777`
- **Fields:**
  - `pool`: `Pubkey`
  - `user`: `Pubkey`
  - `amount_a`: `u64`
  - `amount_b`: `u64`
  - `new_reserves_a`: `u128`
  - `new_reserves_b`: `u128`
  - `fee_a`: `u64`

### `SellEvent`
- **Source:** `instructions/sell_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d3e2f370aa503dc2a`
- **Fields:**
  - `pool`: `Pubkey`
  - `user`: `Pubkey`
  - `amount_a`: `u64`
  - `amount_b`: `u64`
  - `new_reserves_a`: `u128`
  - `new_reserves_b`: `u128`
  - `fee_a`: `u64`

### `PoolCreatedEvent`
- **Source:** `instructions/pool_created_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1dca2c295868dc9d52`
- **Fields:** *(empty struct; payload extracted via shared `PoolCreated` type)*

## Shared types

### `FeeParams`
- `normalization_period`: `u64`
- `decay`: `f64`
- `reference`: `u64`
- `royalties_bps`: `u16`
- `privileged_swapper`: `Option<Pubkey>`

### `SwapParams`
- `amount`: `u64`
- `limit`: `u64`

### `CreateParams`
- `shift`: `u128`
- `initial_token_b_reserves`: `u64`
- `fee_params`: `FeeParams`

### `SwapResult`
- `new_reserves_a`: `u128`
- `new_reserves_b`: `u128`
- `amount_a`: `u64`
- `amount_b`: `u64`
- `fee_a`: `u64`

### `PoolCreated`
- `pool`: `Pubkey`
- `mint_a`: `Pubkey`
- `mint_b`: `Pubkey`
- `owner`: `Pubkey`
- `initial_token_reserves`: `u64`
- `shift`: `u128`
- `fee_params`: `FeeParams`

### `BuyEvent` / `SellEvent` (also as types)
- Same fields as the CPI event entries above.
