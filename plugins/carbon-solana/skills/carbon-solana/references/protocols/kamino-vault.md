# Kamino Vault

- **Crate:** `carbon-kamino-vault-decoder`
- **Program ID:** `kvauTFR8qm1dhniz6pYuBZkuene3Hfrs1VQhVRgCNrr`
- **Decoder struct:** `KaminoVaultDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** no
- **Discriminator style:** anchor 8-byte

## Account types

### `Reserve`
- **Fields:**
  - `version`: `u64`
  - `last_update`: `LastUpdate`
  - `lending_market`: `Pubkey`
  - `farm_collateral`: `Pubkey`
  - `farm_debt`: `Pubkey`
  - `liquidity`: `ReserveLiquidity`
  - `reserve_liquidity_padding`: `[u64; 150]`
  - `collateral`: `ReserveCollateral`
  - `reserve_collateral_padding`: `[u64; 150]`
  - `config`: `ReserveConfig`
  - `config_padding`: `[u64; 116]`
  - `borrowed_amount_outside_elevation_group`: `u64`
  - `borrowed_amounts_against_this_reserve_in_elevation_groups`: `[u64; 32]`
  - `padding`: `[u64; 207]`

### `VaultState`
- **Fields:**
  - `admin_authority`: `Pubkey`
  - `base_vault_authority`: `Pubkey`
  - `base_vault_authority_bump`: `u64`
  - `token_mint`: `Pubkey`
  - `token_mint_decimals`: `u64`
  - `token_vault`: `Pubkey`
  - `token_program`: `Pubkey`
  - `shares_mint`: `Pubkey`
  - `shares_mint_decimals`: `u64`
  - `token_available`: `u64`
  - `shares_issued`: `u64`
  - `available_crank_funds`: `u64`
  - `padding0`: `u64`
  - `performance_fee_bps`: `u64`
  - `management_fee_bps`: `u64`
  - `last_fee_charge_timestamp`: `u64`
  - `prev_aum_sf`: `u128`
  - `pending_fees_sf`: `u128`
  - `vault_allocation_strategy`: `[VaultAllocation; 10]`
  - `min_deposit_amount`: `u64`
  - `min_withdraw_amount`: `u64`
  - `min_invest_amount`: `u64`
  - `min_invest_delay_slots`: `u64`
  - `crank_fund_fee_per_reserve`: `u64`
  - `pending_admin`: `Pubkey`
  - `cumulative_earned_interest_sf`: `u128`
  - `cumulative_mgmt_fees_sf`: `u128`
  - `cumulative_perf_fees_sf`: `u128`
  - `name`: `[u8; 40]`
  - `vault_lookup_table`: `Pubkey`
  - `vault_farm`: `Pubkey`
  - `padding2`: `[u128; 245]`

## Instructions

### `Deposit`
- **Discriminator:** `0xf223c68952e1f2b6`
- **Args:**
  - `max_amount`: `u64`
- **Account variants:**
  - `11 accounts:` `user`, `vault_state`, `token_vault`, `token_mint`, `base_vault_authority`, `shares_mint`, `user_token_ata`, `user_shares_ata`, `klend_program`, `token_program`, `shares_token_program`

### `GiveUpPendingFees`
- **Discriminator:** `0xb1c878866ed99351`
- **Args:**
  - `max_amount_to_give_up`: `u64`
- **Account variants:**
  - `3 accounts:` `admin_authority`, `vault_state`, `klend_program`

### `InitVault`
- **Discriminator:** `0x4d4f559621d9346a`
- **Args:** (none)
- **Account variants:**
  - `10 accounts:` `admin_authority`, `vault_state`, `base_vault_authority`, `token_vault`, `base_token_mint`, `shares_mint`, `system_program`, `rent`, `token_program`, `shares_token_program`

### `InitializeSharesMetadata`
- **Discriminator:** `0x030fac72c8008320`
- **Args:**
  - `name`: `String`
  - `symbol`: `String`
  - `uri`: `String`
- **Account variants:**
  - `8 accounts:` `admin_authority`, `vault_state`, `shares_mint`, `base_vault_authority`, `shares_metadata`, `system_program`, `rent`, `metadata_program`

### `Invest`
- **Discriminator:** `0x0df5b467feb67904`
- **Args:** (none)
- **Account variants:**
  - `16 accounts:` `payer`, `payer_token_account`, `vault_state`, `token_vault`, `token_mint`, `base_vault_authority`, `ctoken_vault`, `reserve`, `lending_market`, `lending_market_authority`, `reserve_liquidity_supply`, `reserve_collateral_mint`, `klend_program`, `reserve_collateral_token_program`, `token_program`, `instruction_sysvar_account`

### `UpdateAdmin`
- **Discriminator:** `0xa1b028d53cb8b3e4`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `pending_admin`, `vault_state`

### `UpdateReserveAllocation`
- **Discriminator:** `0x0536d5704be87525`
- **Args:**
  - `weight`: `u64`
  - `cap`: `u64`
- **Account variants:**
  - `9 accounts:` `admin_authority`, `vault_state`, `base_vault_authority`, `reserve_collateral_mint`, `reserve`, `ctoken_vault`, `reserve_collateral_token_program`, `system_program`, `rent`

### `UpdateSharesMetadata`
- **Discriminator:** `0x9b227aa5f589936b`
- **Args:**
  - `name`: `String`
  - `symbol`: `String`
  - `uri`: `String`
- **Account variants:**
  - `5 accounts:` `admin_authority`, `vault_state`, `base_vault_authority`, `shares_metadata`, `metadata_program`

### `UpdateVaultConfig`
- **Discriminator:** `0x7a0315de9effee9d`
- **Args:**
  - `entry`: `VaultConfigField`
  - `data`: `Vec<u8>`
- **Account variants:**
  - `3 accounts:` `admin_authority`, `vault_state`, `klend_program`

### `Withdraw`
- **Discriminator:** `0xb712469c946da122`
- **Args:**
  - `shares_amount`: `u64`
- **Account variants:**
  - `2 accounts:` `withdraw_from_available`, `withdraw_from_reserve_accounts`

### `WithdrawFromAvailable`
- **Discriminator:** `0x1383709baadc2239`
- **Args:**
  - `shares_amount`: `u64`
- **Account variants:**
  - `11 accounts:` `user`, `vault_state`, `token_vault`, `base_vault_authority`, `user_token_ata`, `token_mint`, `user_shares_ata`, `shares_mint`, `token_program`, `shares_token_program`, `klend_program`

### `WithdrawPendingFees`
- **Discriminator:** `0x83c2c88caff4d9b7`
- **Args:** (none)
- **Account variants:**
  - `16 accounts:` `admin_authority`, `vault_state`, `reserve`, `token_vault`, `ctoken_vault`, `base_vault_authority`, `token_ata`, `token_mint`, `lending_market`, `lending_market_authority`, `reserve_liquidity_supply`, `reserve_collateral_mint`, `klend_program`, `token_program`, `reserve_collateral_token_program`, `instruction_sysvar_account`

## Shared types

### `BigFractionBytes`
- `value`: `[u64; 4]`
- `padding`: `[u64; 2]`

### `BorrowRateCurve`
- `points`: `[CurvePoint; 11]`

### `CurvePoint`
- `utilization_rate_bps`: `u32`
- `borrow_rate_bps`: `u32`

### `LastUpdate`
- `slot`: `u64`
- `stale`: `u8`
- `price_status`: `u8`
- `placeholder`: `[u8; 6]`

### `PriceHeuristic`
- `lower`: `u64`
- `upper`: `u64`
- `exp`: `u64`

### `PythConfiguration`
- `price`: `Pubkey`

### `ReserveCollateral`
- `mint_pubkey`: `Pubkey`
- `mint_total_supply`: `u64`
- `supply_vault`: `Pubkey`
- `padding1`: `[u128; 32]`
- `padding2`: `[u128; 32]`

### `ReserveConfig`
- `status`: `u8`
- `asset_tier`: `u8`
- `host_fixed_interest_rate_bps`: `u16`
- `reserved2`: `[u8; 2]`
- `reserved3`: `[u8; 8]`
- `protocol_take_rate_pct`: `u8`
- `protocol_liquidation_fee_pct`: `u8`
- `loan_to_value_pct`: `u8`
- `liquidation_threshold_pct`: `u8`
- `min_liquidation_bonus_bps`: `u16`
- `max_liquidation_bonus_bps`: `u16`
- `bad_debt_liquidation_bonus_bps`: `u16`
- `deleveraging_margin_call_period_secs`: `u64`
- `deleveraging_threshold_secs_per_bps`: `u64`
- `fees`: `ReserveFees`
- `borrow_rate_curve`: `BorrowRateCurve`
- `borrow_factor_pct`: `u64`
- `deposit_limit`: `u64`
- `borrow_limit`: `u64`
- `token_info`: `TokenInfo`
- `deposit_withdrawal_cap`: `WithdrawalCaps`
- `debt_withdrawal_cap`: `WithdrawalCaps`
- `elevation_groups`: `[u8; 20]`
- `disable_usage_as_coll_outside_emode`: `u8`
- `utilization_limit_block_borrowing_above`: `u8`
- `autodeleverage_enabled`: `u8`
- `reserved1`: `[u8; 1]`
- `borrow_limit_outside_elevation_group`: `u64`
- `borrow_limit_against_this_collateral_in_elevation_group`: `[u64; 32]`
- `deleveraging_bonus_increase_bps_per_day`: `u64`

### `ReserveFees`
- `borrow_fee_sf`: `u64`
- `flash_loan_fee_sf`: `u64`
- `padding`: `[u8; 8]`

### `ReserveLiquidity`
- `mint_pubkey`: `Pubkey`
- `supply_vault`: `Pubkey`
- `fee_vault`: `Pubkey`
- `available_amount`: `u64`
- `borrowed_amount_sf`: `u128`
- `market_price_sf`: `u128`
- `market_price_last_updated_ts`: `u64`
- `mint_decimals`: `u64`
- `deposit_limit_crossed_timestamp`: `u64`
- `borrow_limit_crossed_timestamp`: `u64`
- `cumulative_borrow_rate_bsf`: `BigFractionBytes`
- `accumulated_protocol_fees_sf`: `u128`
- `accumulated_referrer_fees_sf`: `u128`
- `pending_referrer_fees_sf`: `u128`
- `absolute_referral_rate_sf`: `u128`
- `token_program`: `Pubkey`
- `padding2`: `[u64; 51]`
- `padding3`: `[u128; 32]`

### `ScopeConfiguration`
- `price_feed`: `Pubkey`
- `price_chain`: `[u16; 4]`
- `twap_chain`: `[u16; 4]`

### `SwitchboardConfiguration`
- `price_aggregator`: `Pubkey`
- `twap_aggregator`: `Pubkey`

### `TokenInfo`
- `name`: `[u8; 32]`
- `heuristic`: `PriceHeuristic`
- `max_twap_divergence_bps`: `u64`
- `max_age_price_seconds`: `u64`
- `max_age_twap_seconds`: `u64`
- `scope_configuration`: `ScopeConfiguration`
- `switchboard_configuration`: `SwitchboardConfiguration`
- `pyth_configuration`: `PythConfiguration`
- `block_price_usage`: `u8`
- `reserved`: `[u8; 7]`
- `padding`: `[u64; 19]`

### `VaultAllocation`
- `reserve`: `Pubkey`
- `ctoken_vault`: `Pubkey`
- `target_allocation_weight`: `u64`
- `token_allocation_cap`: `u64`
- `config_padding`: `[u64; 128]`
- `ctoken_allocation`: `u64`
- `last_invest_slot`: `u64`
- `token_target_allocation_sf`: `u128`
- `state_padding`: `[u64; 128]`

### `VaultConfigField` (enum)
- `PerformanceFeeBps`
- `ManagementFeeBps`
- `MinDepositAmount`
- `MinWithdrawAmount`
- `MinInvestAmount`
- `MinInvestDelaySlots`
- `CrankFundFeePerReserve`
- `PendingVaultAdmin`
- `Name`
- `LookupTable`
- `Farm`

### `WithdrawalCaps`
- `config_capacity`: `i64`
- `current_total`: `i64`
- `last_interval_start_timestamp`: `u64`
- `config_interval_length_seconds`: `u64`
