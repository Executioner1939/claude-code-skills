# OKX DEX Aggregator

- **Crate:** `carbon-okx-dex-decoder`
- **Program ID:** `6m2CDdhRgxpH4WjvdzxAYbGxwdGUz5MziiL5jek2kBma`
- **Decoder struct:** `OkxDexDecoder`
- **Has accounts:** no
- **Has instructions:** yes
- **Has CPI events:** yes (in instructions/ as `swap_event.rs` and types/ as `swap_event.rs`)
- **Discriminator style:** anchor 8-byte

## Instructions

### `Swap`
- **Discriminator:** `0xf8c69e91e17587c8`
- **Args:**
  - `data`: `SwapArgs`
- **Account variants:**
  - `5 accounts:` `payer, source_token_account, destination_token_account, source_mint, destination_mint`

### `Swap2`
- **Discriminator:** `0x414b3f4ceb5b5b88`
- **Args:**
  - `data`: `SwapArgs`
  - `order_id`: `u64`
- **Account variants:**
  - `5 accounts:` `payer, source_token_account, destination_token_account, source_mint, destination_mint`

### `ProxySwap`
- **Discriminator:** `0x132c829448382cee`
- **Args:**
  - `data`: `SwapArgs`
  - `order_id`: `u64`
- **Account variants:**
  - `12 accounts:` `payer, source_token_account, destination_token_account, source_mint, destination_mint, sa_authority, source_token_sa, destination_token_sa, source_token_program, destination_token_program, associated_token_program, system_program`

### `CommissionSolSwap`
- **Discriminator:** `0x5180864972492d5e`
- **Args:**
  - `data`: `CommissionSwapArgs`
- **Account variants:**
  - `7 accounts:` `payer, source_token_account, destination_token_account, source_mint, destination_mint, commission_account, system_program`

### `CommissionSolSwap2`
- **Discriminator:** `0x71841f4a63a93992`
- **Args:**
  - `data`: `CommissionSwapArgs`
  - `order_id`: `u64`
- **Account variants:**
  - `7 accounts:` `payer, source_token_account, destination_token_account, source_mint, destination_mint, commission_account, system_program`

### `CommissionSplSwap`
- **Discriminator:** `0xeb47d3c472c78f5c`
- **Args:**
  - `data`: `CommissionSwapArgs`
- **Account variants:**
  - `7 accounts:` `payer, source_token_account, destination_token_account, source_mint, destination_mint, commission_token_account, token_program`

### `CommissionSplSwap2`
- **Discriminator:** `0xad834e2696a57b0f`
- **Args:**
  - `data`: `CommissionSwapArgs`
  - `order_id`: `u64`
- **Account variants:**
  - `7 accounts:` `payer, source_token_account, destination_token_account, source_mint, destination_mint, commission_token_account, token_program`

### `CommissionSolProxySwap`
- **Discriminator:** `0x1e21d05b1f9d2512`
- **Args:**
  - `data`: `SwapArgs`
  - `commission_rate`: `u16`
  - `commission_direction`: `bool`
  - `order_id`: `u64`
- **Account variants:**
  - `13 accounts:` `payer, source_token_account, destination_token_account, source_mint, destination_mint, commission_account, sa_authority, source_token_sa, destination_token_sa, source_token_program, destination_token_program, associated_token_program, system_program`

### `CommissionSplProxySwap`
- **Discriminator:** `0x60430c9781a41247`
- **Args:**
  - `data`: `SwapArgs`
  - `commission_rate`: `u16`
  - `commission_direction`: `bool`
  - `order_id`: `u64`
- **Account variants:**
  - `13 accounts:` `payer, source_token_account, destination_token_account, source_mint, destination_mint, commission_token_account, sa_authority, source_token_sa, destination_token_sa, source_token_program, destination_token_program, associated_token_program, system_program`

### `FromSwapLog`
- **Discriminator:** `0x85ba0f691f4c1f70`
- **Args:**
  - `args`: `SwapArgs`
  - `bridge_to_args`: `BridgeToArgs`
  - `offset`: `u8`
  - `len`: `u8`
- **Account variants:**
  - `10 accounts:` `payer, source_token_account, destination_token_account, source_mint, destination_mint, bridge_program, associated_token_program, token_program, token_2022_program, system_program`

### `CommissionSolFromSwap`
- **Discriminator:** `0x813b450a844c2314`
- **Args:**
  - `args`: `SwapArgs`
  - `commission_rate`: `u16`
  - `bridge_to_args`: `BridgeToArgs`
  - `offset`: `u8`
  - `len`: `u8`
- **Account variants:**
  - `11 accounts:` `payer, source_token_account, destination_token_account, source_mint, destination_mint, bridge_program, associated_token_program, token_program, token_2022_program, system_program, commission_account`

### `CommissionSplFromSwap`
- **Discriminator:** `0x054d9032dee4e9ab`
- **Args:**
  - `args`: `SwapArgs`
  - `commission_rate`: `u16`
  - `bridge_to_args`: `BridgeToArgs`
  - `offset`: `u8`
  - `len`: `u8`
- **Account variants:**
  - `11 accounts:` `payer, source_token_account, destination_token_account, source_mint, destination_mint, bridge_program, associated_token_program, token_program, token_2022_program, system_program, commission_token_account`

## CPI events

### `SwapEvent`
- **Source:** `instructions/swap_event.rs` (also `types/swap_event.rs`)
- **Discriminator:** `0xe445a52e51cb9a1d40c6cde8260871e2`
- **Fields:**
  - `dex`: `Dex`
  - `amount_in`: `u64`
  - `amount_out`: `u64`

## Shared types

### `SwapArgs`
- `amount_in`: `u64`
- `expect_amount_out`: `u64`
- `min_return`: `u64`
- `amounts`: `Vec<u64>`
- `routes`: `Vec<Vec<Route>>`

### `CommissionSwapArgs`
- `amount_in`: `u64`
- `expect_amount_out`: `u64`
- `min_return`: `u64`
- `amounts`: `Vec<u64>`
- `routes`: `Vec<Vec<Route>>`
- `commission_rate`: `u16`
- `commission_direction`: `bool`

### `BridgeToArgs`
- `adaptor_id`: `AdaptorID`
- `to`: `Vec<u8>`
- `order_id`: `u64`
- `to_chain_id`: `u64`
- `amount`: `u64`
- `swap_type`: `SwapType`
- `data`: `Vec<u8>`
- `ext_data`: `Vec<u8>`

### `Route`
- `dexes`: `Vec<Dex>`
- `weights`: `Vec<u8>`

### `Dex` (enum)
- `SplTokenSwap | StableSwap | Whirlpool | MeteoraDynamicpool | RaydiumSwap | RaydiumStableSwap | RaydiumClmmSwap | AldrinExchangeV1 | AldrinExchangeV2 | LifinityV1 | LifinityV2 | RaydiumClmmSwapV2 | FluxBeam | MeteoraDlmm | RaydiumCpmmSwap | OpenBookV2 | WhirlpoolV2 | Phoenix | ObricV2 | SanctumAddLiq | SanctumRemoveLiq | SanctumNonWsolSwap | SanctumWsolSwap`

### `AdaptorID` (enum)
- `Bridge0..Bridge17 | Cctp | Bridge19..Bridge20 | Wormhole | Meson | Bridge23..Bridge33 | Debridgedln`

### `SwapType` (enum)
- `BRIDGE | SWAPANDBRIDGE`
