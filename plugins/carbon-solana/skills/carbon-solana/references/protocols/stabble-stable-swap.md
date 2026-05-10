# Stabble Stable Swap

- **Crate:** `carbon-stabble-stable-swap-decoder`
- **Program ID:** `swapNyd8XiQwJ6ianp9snpu4brUqFxadzvHebnAXjJZ`
- **Decoder struct:** `StableSwapDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in instructions/)
- **Discriminator style:** anchor 8-byte

## Account types

### `Pool`
- **Fields:**
  - `owner`: `Pubkey`
  - `vault`: `Pubkey`
  - `mint`: `Pubkey`
  - `authority_bump`: `u8`
  - `is_active`: `bool`
  - `amp_initial_factor`: `u16`
  - `amp_target_factor`: `u16`
  - `ramp_start_ts`: `i64`
  - `ramp_stop_ts`: `i64`
  - `swap_fee`: `u64`
  - `tokens`: `Vec<PoolToken>`
  - `pending_owner`: `Option<Pubkey>`
  - `max_supply`: `u64`

### `Strategy`
- **Fields:**
  - `pool`: `Pubkey`
  - `is_active`: `bool`
  - `amp_min_factor`: `u16`
  - `amp_max_factor`: `u16`
  - `ramp_min_step`: `u16`
  - `ramp_max_step`: `u16`
  - `ramp_min_duration`: `u32`
  - `ramp_max_duration`: `u32`

### `Vault`
- **Fields:**
  - `admin`: `Pubkey`
  - `withdraw_authority`: `Pubkey`
  - `withdraw_authority_bump`: `u8`
  - `authority_bump`: `u8`
  - `is_active`: `bool`
  - `beneficiary`: `Pubkey`
  - `beneficiary_fee`: `u64`
  - `pending_admin`: `Option<Pubkey>`

## Instructions

### `AcceptOwner`
- **Discriminator:** `0xb017291c176f0804`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `pending_owner`, `pool`
- **Remaining accounts:** yes

### `ApproveStrategy`
- **Discriminator:** `0x078da23c47731a92`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `pool`, `vault`, `admin`, `strategy`
- **Remaining accounts:** yes

### `ChangeAmpFactor`
- **Discriminator:** `0x38eebd23c89d2a42`
- **Args:**
  - `new_amp_factor`: `u16`
  - `ramp_duration`: `u32`
- **Account variants:**
  - `3 accounts:` `pool`, `vault`, `admin`
- **Remaining accounts:** yes

### `ChangeMaxSupply`
- **Discriminator:** `0x5db000cd453f5750`
- **Args:**
  - `new_max_supply`: `u64`
- **Account variants:**
  - `2 accounts:` `owner`, `pool`
- **Remaining accounts:** yes

### `ChangeSwapFee`
- **Discriminator:** `0xe70f843384a540aa`
- **Args:**
  - `new_swap_fee`: `u64`
- **Account variants:**
  - `2 accounts:` `owner`, `pool`
- **Remaining accounts:** yes

### `CreateStrategy`
- **Discriminator:** `0x98a06b94f5be7fe0`
- **Args:**
  - `amp_min_factor`: `u16`
  - `amp_max_factor`: `u16`
  - `ramp_min_step`: `u16`
  - `ramp_max_step`: `u16`
  - `ramp_min_duration`: `u32`
  - `ramp_max_duration`: `u32`
- **Account variants:**
  - `2 accounts:` `owner_only`, `strategy`
- **Remaining accounts:** yes

### `Deposit`
- **Discriminator:** `0xf223c68952e1f2b6`
- **Args:**
  - `amounts`: `Vec<u64>`
  - `minimum_amount_out`: `u64`
- **Account variants:**
  - `9 accounts:` `user`, `user_pool_token`, `mint`, `pool`, `pool_authority`, `vault`, `vault_authority`, `token_program`, `token_program_2022`
- **Remaining accounts:** yes

### `ExecStrategy`
- **Discriminator:** `0xf92e37391f263d1b`
- **Args:**
  - `ramp_step`: `u16`
  - `ramp_duration`: `u32`
- **Account variants:**
  - `2 accounts:` `strategy`, `pool`
- **Remaining accounts:** yes

### `Initialize`
- **Discriminator:** `0xafaf6d1f0d989bed`
- **Args:**
  - `amp_factor`: `u16`
  - `swap_fee`: `u64`
  - `max_caps`: `Vec<u64>`
- **Account variants:**
  - `6 accounts:` `owner`, `mint`, `pool`, `pool_authority`, `withdraw_authority`, `vault`
- **Remaining accounts:** yes

### `Pause`
- **Discriminator:** `0xd316ddfb4a79c12f`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `owner`, `pool`
- **Remaining accounts:** yes

### `RejectOwner`
- **Discriminator:** `0xeecec6d733b285e4`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `pending_owner`, `pool`
- **Remaining accounts:** yes

### `Shutdown`
- **Discriminator:** `0x92ccf1d55615fdd3`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `owner`, `pool`
- **Remaining accounts:** yes

### `Swap`
- **Discriminator:** `0xf8c69e91e17587c8`
- **Args:**
  - `amount_in`: `Option<u64>`
  - `minimum_amount_out`: `u64`
- **Account variants:**
  - `12 accounts:` `user`, `user_token_in`, `user_token_out`, `vault_token_in`, `vault_token_out`, `beneficiary_token_out`, `pool`, `withdraw_authority`, `vault`, `vault_authority`, `vault_program`, `token_program`
- **Remaining accounts:** yes

### `SwapV2`
- **Discriminator:** `0x2b04ed0b1ac91e62`
- **Args:**
  - `amount_in`: `Option<u64>`
  - `minimum_amount_out`: `u64`
- **Account variants:**
  - `15 accounts:` `user`, `mint_in`, `mint_out`, `user_token_in`, `user_token_out`, `vault_token_in`, `vault_token_out`, `beneficiary_token_out`, `pool`, `withdraw_authority`, `vault`, `vault_authority`, `vault_program`, `token_program`, `token_2022_program`
- **Remaining accounts:** yes

### `TransferOwner`
- **Discriminator:** `0xf519ddaf6ae5e12d`
- **Args:**
  - `new_owner`: `Pubkey`
- **Account variants:**
  - `2 accounts:` `owner`, `pool`
- **Remaining accounts:** yes

### `Unpause`
- **Discriminator:** `0xa99004260a8dbcff`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `owner`, `pool`
- **Remaining accounts:** yes

### `Withdraw`
- **Discriminator:** `0xb712469c946da122`
- **Args:**
  - `amount`: `u64`
  - `minimum_amounts_out`: `Vec<u64>`
- **Account variants:**
  - `10 accounts:` `user`, `user_pool_token`, `mint`, `pool`, `withdraw_authority`, `vault`, `vault_authority`, `vault_program`, `token_program`, `token_program_2022`
- **Remaining accounts:** yes

## CPI events

### `PoolBalanceUpdatedEvent`
- **Source:** `instructions/pool_balance_updated_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1dac5272cf1b67d304`
- **Fields:**
  - `pubkey`: `Pubkey`
  - `data`: `PoolBalanceUpdatedData`

### `PoolUpdatedEvent`
- **Source:** `instructions/pool_updated_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d80275edde6de7f8d`
- **Fields:**
  - `pubkey`: `Pubkey`
  - `data`: `PoolUpdatedData`

## Shared types

### `Pool`
- `owner`: `Pubkey`
- `vault`: `Pubkey`
- `mint`: `Pubkey`
- `authority_bump`: `u8`
- `is_active`: `bool`
- `amp_initial_factor`: `u16`
- `amp_target_factor`: `u16`
- `ramp_start_ts`: `i64`
- `ramp_stop_ts`: `i64`
- `swap_fee`: `u64`
- `tokens`: `Vec<PoolToken>`
- `pending_owner`: `Option<Pubkey>`
- `max_supply`: `u64`

### `PoolBalanceUpdatedData`
- `balances`: `Vec<u64>`

### `PoolBalanceUpdatedEvent`
- `pubkey`: `Pubkey`
- `data`: `PoolBalanceUpdatedData`

### `PoolToken`
- `mint`: `Pubkey`
- `decimals`: `u8`
- `scaling_up`: `bool`
- `scaling_factor`: `u64`
- `balance`: `u64`

### `PoolUpdatedData`
- `is_active`: `bool`
- `amp_initial_factor`: `u16`
- `amp_target_factor`: `u16`
- `ramp_start_ts`: `i64`
- `ramp_stop_ts`: `i64`
- `swap_fee`: `u64`
- `max_supply`: `u64`

### `PoolUpdatedEvent`
- `pubkey`: `Pubkey`
- `data`: `PoolUpdatedData`

### `Strategy`
- `pool`: `Pubkey`
- `is_active`: `bool`
- `amp_min_factor`: `u16`
- `amp_max_factor`: `u16`
- `ramp_min_step`: `u16`
- `ramp_max_step`: `u16`
- `ramp_min_duration`: `u32`
- `ramp_max_duration`: `u32`

### `Vault`
- `admin`: `Pubkey`
- `withdraw_authority`: `Pubkey`
- `withdraw_authority_bump`: `u8`
- `authority_bump`: `u8`
- `is_active`: `bool`
- `beneficiary`: `Pubkey`
- `beneficiary_fee`: `u64`
- `pending_admin`: `Option<Pubkey>`
