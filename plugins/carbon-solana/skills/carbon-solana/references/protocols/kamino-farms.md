# Kamino Farms

- **Crate:** `carbon-kamino-farms-decoder`
- **Program ID:** `FarmsPZpWu9i7Kky8tPN37rs2TpmMrAZrC7S7vJa91Hr`
- **Decoder struct:** `KaminoFarmsDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** no
- **Discriminator style:** anchor 8-byte

## Account types

### `FarmState`
- **Fields:**
  - `farm_admin`: `Pubkey`
  - `global_config`: `Pubkey`
  - `token`: `TokenInfo`
  - `reward_infos`: `[RewardInfo; 10]`
  - `num_reward_tokens`: `u64`
  - `num_users`: `u64`
  - `total_staked_amount`: `u64`
  - `farm_vault`: `Pubkey`
  - `farm_vaults_authority`: `Pubkey`
  - `farm_vaults_authority_bump`: `u64`
  - `delegate_authority`: `Pubkey`
  - `time_unit`: `u8`
  - `is_farm_frozen`: `u8`
  - `is_farm_delegated`: `u8`
  - `padding0`: `[u8; 5]`
  - `withdraw_authority`: `Pubkey`
  - `deposit_warmup_period`: `u32`
  - `withdrawal_cooldown_period`: `u32`
  - `total_active_stake_scaled`: `u128`
  - `total_pending_stake_scaled`: `u128`
  - `total_pending_amount`: `u64`
  - `slashed_amount_current`: `u64`
  - `slashed_amount_cumulative`: `u64`
  - `slashed_amount_spill_address`: `Pubkey`
  - `locking_mode`: `u64`
  - `locking_start_timestamp`: `u64`
  - `locking_duration`: `u64`
  - `locking_early_withdrawal_penalty_bps`: `u64`
  - `deposit_cap_amount`: `u64`
  - `scope_prices`: `Pubkey`
  - `scope_oracle_price_id`: `u64`
  - `scope_oracle_max_age`: `u64`
  - `pending_farm_admin`: `Pubkey`
  - `strategy_id`: `Pubkey`
  - `delegated_rps_admin`: `Pubkey`
  - `vault_id`: `Pubkey`
  - `padding`: `[u64; 78]`

### `GlobalConfig`
- **Fields:**
  - `global_admin`: `Pubkey`
  - `treasury_fee_bps`: `u64`
  - `treasury_vaults_authority`: `Pubkey`
  - `treasury_vaults_authority_bump`: `u64`
  - `pending_global_admin`: `Pubkey`
  - `padding1`: `[u128; 126]`

### `OraclePrices`
- **Fields:**
  - `oracle_mappings`: `Pubkey`
  - `prices`: `[DatedPrice; 512]`

### `UserState`
- **Fields:**
  - `user_id`: `u64`
  - `farm_state`: `Pubkey`
  - `owner`: `Pubkey`
  - `is_farm_delegated`: `u8`
  - `padding0`: `[u8; 7]`
  - `rewards_tally_scaled`: `[u128; 10]`
  - `rewards_issued_unclaimed`: `[u64; 10]`
  - `last_claim_ts`: `[u64; 10]`
  - `active_stake_scaled`: `u128`
  - `pending_deposit_stake_scaled`: `u128`
  - `pending_deposit_stake_ts`: `u64`
  - `pending_withdrawal_unstake_scaled`: `u128`
  - `pending_withdrawal_unstake_ts`: `u64`
  - `bump`: `u64`
  - `delegatee`: `Pubkey`
  - `last_stake_ts`: `u64`
  - `padding1`: `[u64; 50]`

## Instructions

### `AddRewards`
- **Discriminator:** `0x58ba19e326895117`
- **Args:**
  - `amount`: `u64`
  - `reward_index`: `u64`
- **Account variants:**
  - `8 accounts:` `payer`, `farm_state`, `reward_mint`, `reward_vault`, `farm_vaults_authority`, `payer_reward_token_ata`, `scope_prices`, `token_program`

### `DepositToFarmVault`
- **Discriminator:** `0x83a6405e6cd572b7`
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `5 accounts:` `depositor`, `farm_state`, `farm_vault`, `depositor_ata`, `token_program`

### `HarvestReward`
- **Discriminator:** `0x44c8e4e9b820e2bc`
- **Args:**
  - `reward_index`: `u64`
- **Account variants:**
  - `11 accounts:` `owner`, `user_state`, `farm_state`, `global_config`, `reward_mint`, `user_reward_ata`, `rewards_vault`, `rewards_treasury_vault`, `farm_vaults_authority`, `scope_prices`, `token_program`

### `IdlMissingTypes`
- **Discriminator:** `0x8250269950d4b6fd`
- **Args:**
  - `global_config_option_kind`: `GlobalConfigOption`
  - `farm_config_option_kind`: `FarmConfigOption`
  - `time_unit`: `TimeUnit`
  - `locking_mode`: `LockingMode`
  - `reward_type`: `RewardType`
- **Account variants:**
  - `2 accounts:` `global_admin`, `global_config`

### `InitializeFarm`
- **Discriminator:** `0xfc1cb9acf44a75a5`
- **Args:** (none)
- **Account variants:**
  - `9 accounts:` `farm_admin`, `farm_state`, `global_config`, `farm_vault`, `farm_vaults_authority`, `token_mint`, `token_program`, `system_program`, `rent`

### `InitializeFarmDelegated`
- **Discriminator:** `0xfa546519334dcc5b`
- **Args:** (none)
- **Account variants:**
  - `7 accounts:` `farm_admin`, `farm_delegate`, `farm_state`, `global_config`, `farm_vaults_authority`, `system_program`, `rent`

### `InitializeGlobalConfig`
- **Discriminator:** `0x71d87a83e1d11637`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `global_admin`, `global_config`, `treasury_vaults_authority`, `system_program`

### `InitializeReward`
- **Discriminator:** `0x5f87c0c4f281e644`
- **Args:** (none)
- **Account variants:**
  - `11 accounts:` `farm_admin`, `farm_state`, `global_config`, `reward_mint`, `reward_vault`, `reward_treasury_vault`, `farm_vaults_authority`, `treasury_vaults_authority`, `token_program`, `system_program`, `rent`

### `InitializeUser`
- **Discriminator:** `0x6f11b9fa3c7a26fe`
- **Args:** (none)
- **Account variants:**
  - `8 accounts:` `authority`, `payer`, `owner`, `delegatee`, `user_state`, `farm_state`, `system_program`, `rent`

### `RefreshFarm`
- **Discriminator:** `0xd6838ab790c2ac2a`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `farm_state`, `scope_prices`

### `RefreshUserState`
- **Discriminator:** `0x01870c3ef38c4d6c`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `user_state`, `farm_state`, `scope_prices`

### `RewardUserOnce`
- **Discriminator:** `0xdb8939165eba6072`
- **Args:**
  - `reward_index`: `u64`
  - `amount`: `u64`
- **Account variants:**
  - `3 accounts:` `farm_admin`, `farm_state`, `user_state`

### `SetStakeDelegated`
- **Discriminator:** `0x49abb84b1e38c6df`
- **Args:**
  - `new_amount`: `u64`
- **Account variants:**
  - `3 accounts:` `delegate_authority`, `user_state`, `farm_state`

### `Stake`
- **Discriminator:** `0xceb0ca12c8d1b36c`
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `8 accounts:` `owner`, `user_state`, `farm_state`, `farm_vault`, `user_ata`, `token_mint`, `scope_prices`, `token_program`

### `TransferOwnership`
- **Discriminator:** `0x41b1d749352d632f`
- **Args:**
  - `new_owner`: `Pubkey`
- **Account variants:**
  - `2 accounts:` `owner`, `user_state`

### `Unstake`
- **Discriminator:** `0x5a5f6b2acd7c32e1`
- **Args:**
  - `stake_shares_scaled`: `u128`
- **Account variants:**
  - `4 accounts:` `owner`, `user_state`, `farm_state`, `scope_prices`

### `UpdateFarmAdmin`
- **Discriminator:** `0x142588137aef2482`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `pending_farm_admin`, `farm_state`

### `UpdateFarmConfig`
- **Discriminator:** `0xd6b0bcf4cb3be6cf`
- **Args:**
  - `mode`: `u16`
  - `data`: `Vec<u8>`
- **Account variants:**
  - `3 accounts:` `signer`, `farm_state`, `scope_prices`

### `UpdateGlobalConfig`
- **Discriminator:** `0xa45482bd6f3afac8`
- **Args:**
  - `mode`: `u8`
  - `value`: `[u8; 32]`
- **Account variants:**
  - `2 accounts:` `global_admin`, `global_config`

### `UpdateGlobalConfigAdmin`
- **Discriminator:** `0xb85717c19ceeaf77`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `pending_global_admin`, `global_config`

### `WithdrawFromFarmVault`
- **Discriminator:** `0x165280fa564f7c4e`
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `6 accounts:` `withdraw_authority`, `farm_state`, `withdrawer_token_account`, `farm_vault`, `farm_vaults_authority`, `token_program`

### `WithdrawReward`
- **Discriminator:** `0xbfbbb0890919bbf4`
- **Args:**
  - `amount`: `u64`
  - `reward_index`: `u64`
- **Account variants:**
  - `8 accounts:` `farm_admin`, `farm_state`, `reward_mint`, `reward_vault`, `farm_vaults_authority`, `admin_reward_token_ata`, `scope_prices`, `token_program`

### `WithdrawSlashedAmount`
- **Discriminator:** `0xcad9434aac168cd8`
- **Args:** (none)
- **Account variants:**
  - `6 accounts:` `crank`, `farm_state`, `slashed_amount_spill_address`, `farm_vault`, `farm_vaults_authority`, `token_program`

### `WithdrawTreasury`
- **Discriminator:** `0x283f7a9e90d85360`
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `7 accounts:` `global_admin`, `global_config`, `reward_mint`, `reward_treasury_vault`, `treasury_vault_authority`, `withdraw_destination_token_account`, `token_program`

### `WithdrawUnstakedDeposits`
- **Discriminator:** `0x2466bb31dc248443`
- **Args:** (none)
- **Account variants:**
  - `7 accounts:` `owner`, `user_state`, `farm_state`, `user_ata`, `farm_vault`, `farm_vaults_authority`, `token_program`

## Shared types

### `DatedPrice`
- `price`: `Price`
- `last_updated_slot`: `u64`
- `unix_timestamp`: `u64`
- `reserved`: `[u64; 2]`
- `reserved2`: `[u16; 3]`
- `index`: `u16`

### `FarmConfigOption` (enum)
- `UpdateRewardRps`
- `UpdateRewardMinClaimDuration`
- `WithdrawAuthority`
- `DepositWarmupPeriod`
- `WithdrawCooldownPeriod`
- `RewardType`
- `RpsDecimals`
- `LockingMode`
- `LockingStartTimestamp`
- `LockingDuration`
- `LockingEarlyWithdrawalPenaltyBps`
- `DepositCapAmount`
- `SlashedAmountSpillAddress`
- `ScopePricesAccount`
- `ScopeOraclePriceId`
- `ScopeOracleMaxAge`
- `UpdateRewardScheduleCurvePoints`
- `UpdatePendingFarmAdmin`
- `UpdateStrategyId`
- `UpdateDelegatedRpsAdmin`
- `UpdateVaultId`

### `GlobalConfigOption` (enum)
- `SetPendingGlobalAdmin`
- `SetTreasuryFeeBps`

### `LockingMode` (enum)
- `None`
- `Continuous`
- `WithExpiry`

### `Price`
- `value`: `u64`
- `exp`: `u64`

### `RewardInfo`
- `token`: `TokenInfo`
- `rewards_vault`: `Pubkey`
- `rewards_available`: `u64`
- `reward_schedule_curve`: `RewardScheduleCurve`
- `min_claim_duration_seconds`: `u64`
- `last_issuance_ts`: `u64`
- `rewards_issued_unclaimed`: `u64`
- `rewards_issued_cumulative`: `u64`
- `reward_per_share_scaled`: `u128`
- `placeholder0`: `u64`
- `reward_type`: `u8`
- `rewards_per_second_decimals`: `u8`
- `padding0`: `[u8; 6]`
- `padding1`: `[u64; 20]`

### `RewardPerTimeUnitPoint`
- `ts_start`: `u64`
- `reward_per_time_unit`: `u64`

### `RewardScheduleCurve`
- `points`: `[RewardPerTimeUnitPoint; 20]`

### `RewardType` (enum)
- `Proportional`
- `Constant`

### `TimeUnit` (enum)
- `Seconds`
- `Slots`

### `TokenInfo`
- `mint`: `Pubkey`
- `decimals`: `u64`
- `token_program`: `Pubkey`
- `padding`: `[u64; 6]`
