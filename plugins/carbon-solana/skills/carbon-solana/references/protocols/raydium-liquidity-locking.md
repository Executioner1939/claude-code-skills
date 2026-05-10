# Raydium Liquidity Locking

- **Crate:** `carbon-raydium-liquidity-locking-decoder`
- **Program ID:** `LockrWmn6K5twhz3y9w1dQERbmgSaRkfnTeTKbpofwE`
- **Decoder struct:** `RaydiumLiquidityLockingDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in instructions/)
- **Discriminator style:** anchor 8-byte

## Account types

### `LockedClmmPositionState`
- **Fields:**
  - `bump`: `[u8; 1]`
  - `position_owner`: `Pubkey`
  - `pool_id`: `Pubkey`
  - `position_id`: `Pubkey`
  - `locked_nft_account`: `Pubkey`
  - `fee_nft_mint`: `Pubkey`
  - `recent_epoch`: `u64`
  - `padding`: `[u64; 8]`

### `LockedCpLiquidityState`
- **Fields:**
  - `locked_lp_amount`: `u64`
  - `claimed_lp_amount`: `u64`
  - `unclaimed_lp_amount`: `u64`
  - `last_lp`: `u64`
  - `last_k`: `u128`
  - `recent_epoch`: `u64`
  - `pool_id`: `Pubkey`
  - `fee_nft_mint`: `Pubkey`
  - `locked_owner`: `Pubkey`
  - `locked_lp_mint`: `Pubkey`
  - `padding`: `[u64; 8]`

## Instructions

### `CollectClmmFeesAndRewards`
- **Discriminator:** `0x1048fac60ea2d413`
- **Args:** (none)
- **Account variants:**
  - `20 accounts:` `authority`, `fee_nft_owner`, `fee_nft_account`, `locked_position`, `clmm_program`, `locked_nft_account`, `personal_position`, `pool_state`, `protocol_position`, `token0_vault`, `token1_vault`, `tick_array_lower`, `tick_array_upper`, `recipient_token0_account`, `recipient_token1_account`, `token_program`, `token_program2022`, `memo_program`, `vault0_mint`, `vault1_mint`
- **Remaining accounts:** yes

### `CollectCpFees`
- **Discriminator:** `0x081e33c7d1b8f785`
- **Args:**
  - `fee_lp_amount`: `u64`
- **Account variants:**
  - `18 accounts:` `authority`, `fee_nft_owner`, `fee_nft_account`, `locked_liquidity`, `cp_swap_program`, `cp_authority`, `pool_state`, `lp_mint`, `recipient_token0_account`, `recipient_token1_account`, `token0_vault`, `token1_vault`, `vault0_mint`, `vault1_mint`, `locked_lp_vault`, `token_program`, `token_program2022`, `memo_program`
- **Remaining accounts:** yes

### `LockClmmPosition`
- **Discriminator:** `0xbc25b38352965449`
- **Args:**
  - `with_metadata`: `bool`
- **Account variants:**
  - `18 accounts:` `authority`, `payer`, `position_nft_owner`, `fee_nft_owner`, `position_nft_account`, `personal_position`, `position_nft_mint`, `locked_nft_account`, `locked_position`, `fee_nft_mint`, `fee_nft_account`, `metadata_account`, `metadata_program`, `associated_token_program`, `rent`, `fee_nft_token_program`, `locked_nft_token_program`, `system_program`
- **Remaining accounts:** yes

### `LockCpLiquidity`
- **Discriminator:** `0xd89d1d4e26331f1a`
- **Args:**
  - `lp_amount`: `u64`
  - `with_metadata`: `bool`
- **Account variants:**
  - `19 accounts:` `authority`, `payer`, `liquidity_owner`, `fee_nft_owner`, `fee_nft_mint`, `fee_nft_account`, `pool_state`, `locked_liquidity`, `lp_mint`, `liquidity_owner_lp`, `locked_lp_vault`, `token0_vault`, `token1_vault`, `metadata_account`, `rent`, `system_program`, `token_program`, `associated_token_program`, `metadata_program`
- **Remaining accounts:** yes

## CPI events

### `SettleCpFeeEvent`
- **Source:** `instructions/settle_cp_fee_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d1d4ea505f6a75bf4`
- **Fields:**
  - `delta_amount`: `u64`
  - `unclaimed_amount`: `u64`
  - `locked_amount`: `u64`
  - `curr_pool_lp`: `u64`
  - `last_pool_lp`: `u64`
  - `curr_k`: `u128`
  - `last_k`: `u128`
