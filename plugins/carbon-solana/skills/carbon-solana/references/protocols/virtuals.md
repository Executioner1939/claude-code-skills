# Virtuals

- **Crate:** `carbon-virtuals-decoder`
- **Program ID:** `5U3EU2ubXtK84QcRjWVmYt9RaDyA8gKxdUrPFXmZyaki`
- **Decoder struct:** `VirtualsDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in instructions/, *_event.rs)
- **Discriminator style:** anchor 8-byte (events use 16-byte anchor event discriminator)

## Account types

### `VirtualsPool`
- **Discriminator:** `0x477605cb05628774`
- **Fields:**
  - `creator`: `Pubkey`
  - `mint`: `Pubkey`
  - `virtual_y`: `u64`
  - `graduation_x`: `u64`
  - `state`: `PoolState`
  - `bump`: `u8`

## Instructions

### `Initialize`
- **Discriminator:** `0xafaf6d1f0d989bed`
- **Args:** (none)
- **Account variants:**
  - `9 accounts:` `payer, virtuals_mint, token_mint, vpool_virtuals_ata, vpool_token_ata, vpool, token_program, associated_token_program, system_program`

### `Launch`
- **Discriminator:** `0x99f15de116454a3d`
- **Args:**
  - `symbol`: `String`
  - `name`: `String`
  - `uri`: `String`
- **Account variants:**
  - `12 accounts:` `creator, creator_virtuals_ata, token_mint, platform_prototype, platform_prototype_virtuals_ata, vpool, token_metadata, metadata_program, token_program, associated_token_program, system_program, rent`

### `Buy`
- **Discriminator:** `0x66063d1201daebea`
- **Args:**
  - `amount`: `u64`
  - `max_amount_out`: `u64`
- **Account variants:**
  - `10 accounts:` `user, vpool, token_mint, user_virtuals_ata, user_token_ata, vpool_token_ata, platform_prototype, platform_prototype_virtuals_ata, vpool_virtuals_ata, token_program`

### `Sell`
- **Discriminator:** `0x33e685a4017f83ad`
- **Args:**
  - `amount`: `u64`
  - `min_amount_out`: `u64`
- **Account variants:**
  - `10 accounts:` `user, vpool, token_mint, user_virtuals_ata, user_token_ata, vpool_token_ata, platform_prototype, platform_prototype_virtuals_ata, vpool_virtuals_ata, token_program`

### `InitializeMeteoraAccounts`
- **Discriminator:** `0x350c769efdefb9d6`
- **Args:** (none)
- **Account variants:**
  - `36 accounts:` `vpool, meteora_deployer, meteora_deployer_virtuals_ata, meteora_deployer_token_ata, vpool_virtuals_ata, vpool_token_ata, lock_escrow, escrow_vault, pool, config, lp_mint, virtuals_mint, token_mint, virtuals_vault, token_vault, virtuals_token_vault, token_token_vault, virtuals_vault_lp_mint, token_vault_lp_mint, virtuals_vault_lp, token_vault_lp, pool_virtuals_ata, pool_token_ata, meteora_deployer_pool_lp, protocol_virtuals_fee, protocol_token_fee, payer, token_metadata, rent, mint_metadata, metadata_program, vault_program, token_program, associated_token_program, system_program, dynamic_amm_program`

### `CreateMeteoraPool`
- **Discriminator:** `0xf6fe2125e1b029e8`
- **Args:** (none)
- **Account variants:**
  - `36 accounts:` (same accounts as `InitializeMeteoraAccounts`)

### `ClaimFees`
- **Discriminator:** `0x52fbe99c0c34b8ca`
- **Args:** (none)
- **Account variants:**
  - `28 accounts:` `payer, vpool, virtuals_mint, token_mint, vpool_virtuals_ata, vpool_token_ata, platform, platform_virtuals_ata, platform_token_ata, creator_virtuals_ata, creator_token_ata, pool, lp_mint, lock_escrow, escrow_vault, token_program, virtuals_vault, token_vault, virtuals_token_vault, token_token_vault, virtuals_vault_lp_mint, token_vault_lp_mint, virtuals_vault_lp, token_vault_lp, vault_program, associated_token_program, system_program, dynamic_amm_program`

### `UpdatePoolCreator`
- **Discriminator:** `0x71e1a6b95ee7601c`
- **Args:** (none)
- **Account variants:**
  - `10 accounts:` `creator, new_creator, virtuals_mint, token_mint, new_creator_virtuals_ata, new_creator_token_ata, vpool, token_program, associated_token_program, system_program`

## CPI events

### `BuyEvent`
- **Source:** `instructions/buy_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d67f4521f2cf57777`
- **Fields:**
  - `buy_amount`: `u64`
  - `virtuals_amount`: `u64`

### `SellEvent`
- **Source:** `instructions/sell_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d3e2f370aa503dc2a`
- **Fields:**
  - `sell_amount`: `u64`
  - `virtuals_amount`: `u64`

### `LaunchEvent`
- **Source:** `instructions/launch_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d1bc12f82735cef5e`
- **Fields:**
  - `vpool`: `Pubkey`
  - `mint`: `Pubkey`
  - `creator`: `Pubkey`

### `GraduationEvent`
- **Source:** `instructions/graduation_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d0af6df7f30629537`
- **Fields:**
  - `vpool`: `Pubkey`
  - `mint`: `Pubkey`
  - `balance`: `u64`

## Shared types

### `PoolState`
- enum: `Initialized`, `Active`, `Graduated`, `Migrated`

### `BuyEvent` / `SellEvent` / `LaunchEvent` / `GraduationEvent` (also in types/)
- Same fields as the corresponding CPI event entries above.
