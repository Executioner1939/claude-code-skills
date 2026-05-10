# Moonshot

- **Crate:** `carbon-moonshot-decoder`
- **Program ID:** `MoonCVVNZFSYkqNXP6bxHLPL6QQJiMagDL3qcqUQTrG`
- **Decoder struct:** `MoonshotDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in instructions/)
- **Discriminator style:** anchor 8-byte

## Account types

### `ConfigAccount`
- **Fields:**
  - `migration_authority`: `Pubkey`
  - `backend_authority`: `Pubkey`
  - `config_authority`: `Pubkey`
  - `helio_fee`: `Pubkey`
  - `dex_fee`: `Pubkey`
  - `fee_bps`: `u16`
  - `dex_fee_share`: `u8`
  - `migration_fee`: `u64`
  - `marketcap_threshold`: `u64`
  - `marketcap_currency`: `Currency`
  - `min_supported_decimal_places`: `u8`
  - `max_supported_decimal_places`: `u8`
  - `min_supported_token_supply`: `u64`
  - `max_supported_token_supply`: `u64`
  - `bump`: `u8`
  - `coef_b`: `u32`
  - `_reserved`: `[u8; 192]`

### `CurveAccount`
- **Fields:**
  - `total_supply`: `u64`
  - `curve_amount`: `u64`
  - `mint`: `Pubkey`
  - `decimals`: `u8`
  - `collateral_currency`: `Currency`
  - `curve_type`: `CurveType`
  - `marketcap_threshold`: `u64`
  - `marketcap_currency`: `Currency`
  - `migration_fee`: `u64`
  - `coef_b`: `u32`
  - `bump`: `u8`
  - `migration_target`: `MigrationTarget`
  - `_reserved`: `[u8; 327]`

## Instructions

### `Buy`
- **Discriminator:** `0x66063d1201daebea`
- **Args:**
  - `data`: `TradeParams`
- **Account variants:**
  - `11 accounts:` `sender`, `sender_token_account`, `curve_account`, `curve_token_account`, `dex_fee`, `helio_fee`, `mint`, `config_account`, `token_program`, `associated_token_program`, `system_program`

### `ConfigInit`
- **Discriminator:** `0x0deca4ad6afda4b9`
- **Args:**
  - `data`: `ConfigParams`
- **Account variants:**
  - `3 accounts:` `config_authority`, `config_account`, `system_program`

### `ConfigUpdate`
- **Discriminator:** `0x50256d88528759f1`
- **Args:**
  - `data`: `ConfigParams`
- **Account variants:**
  - `2 accounts:` `config_authority`, `config_account`

### `MigrateFunds`
- **Discriminator:** `0x2ae50ae7bd3ec1ae`
- **Args:** (none)
- **Account variants:**
  - `12 accounts:` `backend_authority`, `migration_authority`, `curve_account`, `curve_token_account`, `migration_authority_token_account`, `mint`, `dex_fee_account`, `helio_fee_account`, `config_account`, `system_program`, `token_program`, `associated_token_program`

### `MigrationEvent`
- **Discriminator:** `0xe445a52e51cb9a1dffca4c935be74916`
- **Args:**
  - `tokens_migrated`: `u64`
  - `tokens_burned`: `u64`
  - `collateral_migrated`: `u64`
  - `fee`: `u64`
  - `label`: `String`

### `Sell`
- **Discriminator:** `0x33e685a4017f83ad`
- **Args:**
  - `data`: `TradeParams`
- **Account variants:**
  - `11 accounts:` `sender`, `sender_token_account`, `curve_account`, `curve_token_account`, `dex_fee`, `helio_fee`, `mint`, `config_account`, `token_program`, `associated_token_program`, `system_program`

### `TokenMint`
- **Discriminator:** `0x032ca4b87b0df5b3`
- **Args:**
  - `mint_params`: `TokenMintParams`
- **Account variants:**
  - `11 accounts:` `sender`, `backend_authority`, `curve_account`, `mint`, `mint_metadata`, `curve_token_account`, `config_account`, `token_program`, `associated_token_program`, `mpl_token_metadata`, `system_program`

### `TradeEvent`
- **Discriminator:** `0xe445a52e51cb9a1dbddb7fd34ee661ee`
- **Args:**
  - `amount`: `u64`
  - `collateral_amount`: `u64`
  - `dex_fee`: `u64`
  - `helio_fee`: `u64`
  - `allocation`: `u64`
  - `curve`: `Pubkey`
  - `cost_token`: `Pubkey`
  - `sender`: `Pubkey`
  - `trade_type`: `TradeType`
  - `label`: `String`

## Shared types

### `ConfigParams`
- `migration_authority`: `Option<Pubkey>`
- `backend_authority`: `Option<Pubkey>`
- `config_authority`: `Option<Pubkey>`
- `helio_fee`: `Option<Pubkey>`
- `dex_fee`: `Option<Pubkey>`
- `fee_bps`: `Option<u16>`
- `dex_fee_share`: `Option<u8>`
- `migration_fee`: `Option<u64>`
- `marketcap_threshold`: `Option<u64>`
- `marketcap_currency`: `Option<u8>`
- `min_supported_decimal_places`: `Option<u8>`
- `max_supported_decimal_places`: `Option<u8>`
- `min_supported_token_supply`: `Option<u64>`
- `max_supported_token_supply`: `Option<u64>`
- `coef_b`: `Option<u32>`

### `Currency`
- enum: `Sol`

### `CurveType`
- enum: `LinearV1`, `ConstantProductV1`

### `FixedSide`
- enum: `ExactIn`, `ExactOut`

### `MigrationTarget`
- enum: `Raydium`, `Meteora`

### `TokenMintParams`
- `name`: `PrefixString`
- `symbol`: `PrefixString`
- `uri`: `PrefixString`
- `decimals`: `u8`
- `collateral_currency`: `u8`
- `amount`: `u64`
- `curve_type`: `u8`
- `migration_target`: `u8`
- `_padding`: `[u8; 10]`

### `TradeParams`
- `token_amount`: `u64`
- `collateral_amount`: `u64`
- `fixed_side`: `u8`
- `slippage_bps`: `u64`

### `TradeType`
- enum: `Buy`, `Sell`
