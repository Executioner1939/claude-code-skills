# Jupiter Lend

- **Crate:** `carbon-jupiter-lend-decoder`
- **Program ID:** `jupeiUmn818Jg1ekPURTpr4mFo29p46vygyykFJ3wZC`
- **Decoder struct:** `LiquidityDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (events/)
- **Discriminator style:** anchor 8-byte

## Account types

### `AuthorizationList`
- **Fields:**
  - `auth_users`: `Vec<Pubkey>`
  - `guardians`: `Vec<Pubkey>`
  - `user_classes`: `Vec<UserClass>`

### `Liquidity`
- **Fields:**
  - `authority`: `Pubkey`
  - `revenue_collector`: `Pubkey`
  - `status`: `bool`
  - `bump`: `u8`

### `RateModel`
- **Fields:**
  - `mint`: `Pubkey`
  - `version`: `u8`
  - `rate_at_zero`: `u16`
  - `kink1_utilization`: `u16`
  - `rate_at_kink1`: `u16`
  - `rate_at_max`: `u16`
  - `kink2_utilization`: `u16`
  - `rate_at_kink2`: `u16`

### `TokenReserve`
- **Fields:**
  - `mint`: `Pubkey`
  - `vault`: `Pubkey`
  - `borrow_rate`: `u16`
  - `fee_on_interest`: `u16`
  - `last_utilization`: `u16`
  - `last_update_timestamp`: `u64`
  - `supply_exchange_price`: `u64`
  - `borrow_exchange_price`: `u64`
  - `max_utilization`: `u16`
  - `total_supply_with_interest`: `u64`
  - `total_supply_interest_free`: `u64`
  - `total_borrow_with_interest`: `u64`
  - `total_borrow_interest_free`: `u64`
  - `total_claim_amount`: `u64`
  - `interacting_protocol`: `Pubkey`
  - `interacting_timestamp`: `u64`
  - `interacting_balance`: `u64`

### `UserBorrowPosition`
- **Fields:**
  - `protocol`: `Pubkey`
  - `mint`: `Pubkey`
  - `with_interest`: `u8`
  - `amount`: `u64`
  - `debt_ceiling`: `u64`
  - `last_update`: `u64`
  - `expand_pct`: `u16`
  - `expand_duration`: `u32`
  - `base_debt_ceiling`: `u64`
  - `max_debt_ceiling`: `u64`
  - `status`: `u8`

### `UserClaim`
- **Fields:**
  - `user`: `Pubkey`
  - `amount`: `u64`
  - `mint`: `Pubkey`

### `UserSupplyPosition`
- **Fields:**
  - `protocol`: `Pubkey`
  - `mint`: `Pubkey`
  - `with_interest`: `u8`
  - `amount`: `u64`
  - `withdrawal_limit`: `u128`
  - `last_update`: `u64`
  - `expand_pct`: `u16`
  - `expand_duration`: `u64`
  - `base_withdrawal_limit`: `u64`
  - `status`: `u8`

## Instructions

### `ChangeStatus`
- **Discriminator:** `[236, 145, 131, 228, 227, 17, 192, 255]`
- **Args:**
  - `status`: `bool`
- **Account variants:**
  - `3 accounts:` `authority`, `liquidity`, `auth_list`
- **Remaining accounts:** yes

### `Claim`
- **Discriminator:** `[62, 198, 214, 193, 213, 159, 108, 210]`
- **Args:**
  - `recipient`: `Pubkey`
- **Account variants:**
  - `9 accounts:` `user`, `liquidity`, `token_reserve`, `mint`, `recipient_token_account`, `vault`, `claim_account`, `token_program`, `associated_token_program`
- **Remaining accounts:** yes

### `CloseClaimAccount`
- **Discriminator:** `[241, 146, 203, 216, 58, 222, 91, 118]`
- **Args:**
  - `mint`: `Pubkey`
- **Account variants:**
  - `3 accounts:` `user`, `claim_account`, `system_program`
- **Remaining accounts:** yes

### `CollectRevenue`
- **Discriminator:** `[87, 96, 211, 36, 240, 43, 246, 87]`
- **Args:** (none)
- **Account variants:**
  - `11 accounts:` `authority`, `liquidity`, `auth_list`, `mint`, `revenue_collector_account`, `revenue_collector`, `token_reserve`, `vault`, `token_program`, `associated_token_program`, `system_program`
- **Remaining accounts:** yes

### `InitClaimAccount`
- **Discriminator:** `[112, 141, 47, 170, 42, 99, 144, 145]`
- **Args:**
  - `mint`: `Pubkey`
  - `user`: `Pubkey`
- **Account variants:**
  - `3 accounts:` `signer`, `claim_account`, `system_program`
- **Remaining accounts:** yes

### `InitLiquidity`
- **Discriminator:** `[95, 189, 216, 183, 188, 62, 244, 108]`
- **Args:**
  - `authority`: `Pubkey`
  - `revenue_collector`: `Pubkey`
- **Account variants:**
  - `4 accounts:` `signer`, `liquidity`, `auth_list`, `system_program`
- **Remaining accounts:** yes

### `InitNewProtocol`
- **Discriminator:** `[193, 147, 5, 32, 138, 135, 213, 158]`
- **Args:**
  - `supply_mint`: `Pubkey`
  - `borrow_mint`: `Pubkey`
  - `protocol`: `Pubkey`
- **Account variants:**
  - `5 accounts:` `authority`, `auth_list`, `user_supply_position`, `user_borrow_position`, `system_program`
- **Remaining accounts:** yes

### `InitTokenReserve`
- **Discriminator:** `[228, 235, 65, 129, 159, 15, 6, 84]`
- **Args:** (none)
- **Account variants:**
  - `10 accounts:` `authority`, `liquidity`, `auth_list`, `mint`, `vault`, `rate_model`, `token_reserve`, `token_program`, `associated_token_program`, `system_program`
- **Remaining accounts:** yes

### `Operate`
- **Discriminator:** `[217, 106, 208, 99, 116, 151, 42, 135]`
- **Args:**
  - `supply_amount`: `i128`
  - `borrow_amount`: `i128`
  - `withdraw_to`: `Pubkey`
  - `borrow_to`: `Pubkey`
  - `transfer_type`: `TransferType`
- **Account variants:**
  - `14 accounts:` `protocol`, `liquidity`, `token_reserve`, `mint`, `vault`, `user_supply_position`, `user_borrow_position`, `rate_model`, `withdraw_to_account`, `borrow_to_account`, `borrow_claim_account`, `withdraw_claim_account`, `token_program`, `associated_token_program`
- **Optional accounts:** `user_supply_position`, `user_borrow_position`, `withdraw_to_account`, `borrow_to_account`, `borrow_claim_account`, `withdraw_claim_account`
- **Remaining accounts:** yes

### `PauseUser`
- **Discriminator:** `[18, 63, 43, 94, 239, 53, 101, 14]`
- **Args:**
  - `protocol`: `Pubkey`
  - `supply_mint`: `Pubkey`
  - `borrow_mint`: `Pubkey`
  - `supply_status`: `Option<u8>`
  - `borrow_status`: `Option<u8>`
- **Account variants:**
  - `4 accounts:` `authority`, `auth_list`, `user_supply_position`, `user_borrow_position`
- **Remaining accounts:** yes

### `PreOperate`
- **Discriminator:** `[129, 205, 158, 155, 198, 155, 72, 133]`
- **Args:**
  - `mint`: `Pubkey`
- **Account variants:**
  - `8 accounts:` `protocol`, `liquidity`, `user_supply_position`, `user_borrow_position`, `vault`, `token_reserve`, `associated_token_program`, `token_program`
- **Optional accounts:** `user_supply_position`, `user_borrow_position`
- **Remaining accounts:** yes

### `UnpauseUser`
- **Discriminator:** `[71, 115, 128, 252, 182, 126, 234, 62]`
- **Args:**
  - `protocol`: `Pubkey`
  - `supply_mint`: `Pubkey`
  - `borrow_mint`: `Pubkey`
  - `supply_status`: `Option<u8>`
  - `borrow_status`: `Option<u8>`
- **Account variants:**
  - `4 accounts:` `authority`, `auth_list`, `user_supply_position`, `user_borrow_position`
- **Remaining accounts:** yes

### `UpdateAuthority`
- **Discriminator:** `[32, 46, 64, 28, 149, 75, 243, 88]`
- **Args:**
  - `new_authority`: `Pubkey`
- **Account variants:**
  - `3 accounts:` `authority`, `liquidity`, `auth_list`
- **Remaining accounts:** yes

### `UpdateAuths`
- **Discriminator:** `[93, 96, 178, 156, 57, 117, 253, 209]`
- **Args:**
  - `auth_status`: `Vec<AddressBool>`
- **Account variants:**
  - `3 accounts:` `authority`, `liquidity`, `auth_list`
- **Remaining accounts:** yes

### `UpdateExchangePrice`
- **Discriminator:** `[239, 244, 10, 248, 116, 25, 53, 150]`
- **Args:**
  - `mint`: `Pubkey`
- **Account variants:**
  - `2 accounts:` `token_reserve`, `rate_model`
- **Remaining accounts:** yes

### `UpdateGuardians`
- **Discriminator:** `[43, 62, 250, 138, 141, 117, 132, 97]`
- **Args:**
  - `guardian_status`: `Vec<AddressBool>`
- **Account variants:**
  - `3 accounts:` `authority`, `liquidity`, `auth_list`
- **Remaining accounts:** yes

### `UpdateRateDataV1`
- **Discriminator:** `[6, 20, 34, 122, 22, 150, 180, 22]`
- **Args:**
  - `rate_data`: `RateDataV1Params`
- **Account variants:**
  - `5 accounts:` `authority`, `auth_list`, `rate_model`, `mint`, `token_reserve`
- **Remaining accounts:** yes

### `UpdateRateDataV2`
- **Discriminator:** `[116, 73, 53, 146, 216, 45, 228, 124]`
- **Args:**
  - `rate_data`: `RateDataV2Params`
- **Account variants:**
  - `5 accounts:` `authority`, `auth_list`, `rate_model`, `mint`, `token_reserve`
- **Remaining accounts:** yes

### `UpdateRevenueCollector`
- **Discriminator:** `[167, 142, 124, 240, 220, 113, 141, 59]`
- **Args:**
  - `revenue_collector`: `Pubkey`
- **Account variants:**
  - `2 accounts:` `authority`, `liquidity`
- **Remaining accounts:** yes

### `UpdateTokenConfig`
- **Discriminator:** `[231, 122, 181, 79, 255, 79, 144, 167]`
- **Args:**
  - `token_config`: `TokenConfig`
- **Account variants:**
  - `5 accounts:` `authority`, `auth_list`, `rate_model`, `mint`, `token_reserve`
- **Remaining accounts:** yes

### `UpdateUserBorrowConfig`
- **Discriminator:** `[100, 176, 201, 174, 247, 2, 54, 168]`
- **Args:**
  - `user_borrow_config`: `UserBorrowConfig`
- **Account variants:**
  - `7 accounts:` `authority`, `protocol`, `auth_list`, `rate_model`, `mint`, `token_reserve`, `user_borrow_position`
- **Remaining accounts:** yes

### `UpdateUserClass`
- **Discriminator:** `[12, 206, 68, 135, 63, 212, 48, 119]`
- **Args:**
  - `user_class`: `Vec<AddressU8>`
- **Account variants:**
  - `2 accounts:` `authority`, `auth_list`
- **Remaining accounts:** yes

### `UpdateUserSupplyConfig`
- **Discriminator:** `[217, 239, 225, 218, 33, 49, 234, 183]`
- **Args:**
  - `user_supply_config`: `UserSupplyConfig`
- **Account variants:**
  - `7 accounts:` `authority`, `protocol`, `auth_list`, `rate_model`, `mint`, `token_reserve`, `user_supply_position`
- **Remaining accounts:** yes

### `UpdateUserWithdrawalLimit`
- **Discriminator:** `[162, 9, 186, 9, 213, 30, 173, 78]`
- **Args:**
  - `new_limit`: `u128`
  - `protocol`: `Pubkey`
  - `mint`: `Pubkey`
- **Account variants:**
  - `3 accounts:` `authority`, `auth_list`, `user_supply_position`
- **Remaining accounts:** yes

## CPI events

### `LogBorrowRateCapEvent`
- **Source:** `events/log_borrow_rate_cap.rs`
- **Discriminator:** `[156, 131, 232, 94, 254, 156, 14, 117]`
- **Fields:**
  - `token`: `Pubkey`

### `LogChangeStatusEvent`
- **Source:** `events/log_change_status.rs`
- **Discriminator:** `[89, 77, 37, 172, 141, 31, 74, 42]`
- **Fields:**
  - `new_status`: `bool`

### `LogClaimEvent`
- **Source:** `events/log_claim.rs`
- **Discriminator:** `[238, 50, 157, 85, 151, 58, 231, 45]`
- **Fields:**
  - `user`: `Pubkey`
  - `token`: `Pubkey`
  - `recipient`: `Pubkey`
  - `amount`: `u64`

### `LogCollectRevenueEvent`
- **Source:** `events/log_collect_revenue.rs`
- **Discriminator:** `[64, 198, 22, 194, 123, 87, 166, 82]`
- **Fields:**
  - `token`: `Pubkey`
  - `revenue_amount`: `u128`

### `LogOperateEvent`
- **Source:** `events/log_operate.rs`
- **Discriminator:** `[180, 8, 81, 71, 19, 132, 173, 8]`
- **Fields:**
  - `user`: `Pubkey`
  - `token`: `Pubkey`
  - `supply_amount`: `i128`
  - `borrow_amount`: `i128`
  - `withdraw_to`: `Pubkey`
  - `borrow_to`: `Pubkey`
  - `supply_exchange_price`: `u64`
  - `borrow_exchange_price`: `u64`

### `LogPauseUserEvent`
- **Source:** `events/log_pause_user.rs`
- **Discriminator:** `[100, 17, 114, 224, 180, 30, 52, 170]`
- **Fields:**
  - `user`: `Pubkey`
  - `mint`: `Pubkey`
  - `status`: `u8`

### `LogUnpauseUserEvent`
- **Source:** `events/log_unpause_user.rs`
- **Discriminator:** `[170, 91, 132, 96, 179, 77, 168, 26]`
- **Fields:**
  - `user`: `Pubkey`
  - `mint`: `Pubkey`
  - `status`: `u8`

### `LogUpdateAuthorityEvent`
- **Source:** `events/log_update_authority.rs`
- **Discriminator:** `[150, 152, 157, 143, 6, 135, 193, 101]`
- **Fields:**
  - `new_authority`: `Pubkey`

### `LogUpdateAuthsEvent`
- **Source:** `events/log_update_auths.rs`
- **Discriminator:** `[88, 80, 109, 48, 111, 203, 76, 251]`
- **Fields:**
  - `auth_status`: `Vec<AddressBool>`

### `LogUpdateExchangePricesEvent`
- **Source:** `events/log_update_exchange_prices.rs`
- **Discriminator:** `[190, 194, 69, 204, 30, 86, 181, 163]`
- **Fields:**
  - `token`: `Pubkey`
  - `supply_exchange_price`: `u128`
  - `borrow_exchange_price`: `u128`
  - `borrow_rate`: `u16`
  - `utilization`: `u16`

### `LogUpdateGuardiansEvent`
- **Source:** `events/log_update_guardians.rs`
- **Discriminator:** `[231, 28, 191, 51, 53, 140, 79, 142]`
- **Fields:**
  - `guardian_status`: `Vec<AddressBool>`

### `LogUpdateRateDataV1Event`
- **Source:** `events/log_update_rate_data_v1.rs`
- **Discriminator:** `[30, 102, 131, 192, 0, 30, 85, 223]`
- **Fields:**
  - `token`: `Pubkey`
  - `rate_data`: `RateDataV1Params`

### `LogUpdateRateDataV2Event`
- **Source:** `events/log_update_rate_data_v2.rs`
- **Discriminator:** `[206, 53, 195, 70, 113, 211, 92, 129]`
- **Fields:**
  - `token`: `Pubkey`
  - `rate_data`: `RateDataV2Params`

### `LogUpdateRevenueCollectorEvent`
- **Source:** `events/log_update_revenue_collector.rs`
- **Discriminator:** `[44, 143, 80, 250, 211, 147, 180, 159]`
- **Fields:**
  - `revenue_collector`: `Pubkey`

### `LogUpdateTokenConfigsEvent`
- **Source:** `events/log_update_token_configs.rs`
- **Discriminator:** `[24, 205, 191, 130, 47, 40, 233, 218]`
- **Fields:**
  - `token_config`: `TokenConfig`

### `LogUpdateUserBorrowConfigsEvent`
- **Source:** `events/log_update_user_borrow_configs.rs`
- **Discriminator:** `[210, 251, 242, 159, 205, 33, 154, 74]`
- **Fields:**
  - `user`: `Pubkey`
  - `token`: `Pubkey`
  - `user_borrow_config`: `UserBorrowConfig`

### `LogUpdateUserClassEvent`
- **Source:** `events/log_update_user_class.rs`
- **Discriminator:** `[185, 193, 106, 248, 11, 53, 0, 136]`
- **Fields:**
  - `user_class`: `Vec<AddressU8>`

### `LogUpdateUserSupplyConfigsEvent`
- **Source:** `events/log_update_user_supply_configs.rs`
- **Discriminator:** `[142, 160, 21, 90, 87, 88, 18, 51]`
- **Fields:**
  - `user`: `Pubkey`
  - `token`: `Pubkey`
  - `user_supply_config`: `UserSupplyConfig`

### `LogUpdateUserWithdrawalLimitEvent`
- **Source:** `events/log_update_user_withdrawal_limit.rs`
- **Discriminator:** `[114, 131, 152, 189, 120, 253, 88, 105]`
- **Fields:**
  - `user`: `Pubkey`
  - `token`: `Pubkey`
  - `new_limit`: `u128`

## Shared types

### `AddressBool`
- `addr`: `Pubkey`
- `value`: `bool`

### `AddressU8`
- `addr`: `Pubkey`
- `value`: `u8`

### `RateDataV1Params`
- **Doc:** struct to set borrow rate data for version 1
- `kink`: `u128`
- `rate_at_utilization_zero`: `u128`
- `rate_at_utilization_kink`: `u128`
- `rate_at_utilization_max`: `u128`

### `RateDataV2Params`
- **Doc:** struct to set borrow rate data for version 2
- `kink1`: `u128`
- `kink2`: `u128`
- `rate_at_utilization_zero`: `u128`
- `rate_at_utilization_kink1`: `u128`
- `rate_at_utilization_kink2`: `u128`
- `rate_at_utilization_max`: `u128`

### `TokenConfig`
- **Doc:** struct to set token config
- `token`: `Pubkey`
- `fee`: `u128`
- `max_utilization`: `u128`

### `TransferType`
- enum variants: `SKIP`, `DIRECT`, `CLAIM`

### `UserBorrowConfig`
- **Doc:** struct to set user borrow & payback config
- `mode`: `u8`
- `expand_percent`: `u128`
- `expand_duration`: `u128`
- `base_debt_ceiling`: `u128`
- `max_debt_ceiling`: `u128`

### `UserClass`
- `addr`: `Pubkey`
- `class`: `u8`

### `UserSupplyConfig`
- **Doc:** struct to set user supply & withdrawal config
- `mode`: `u8`
- `expand_percent`: `u128`
- `expand_duration`: `u128`
- `base_withdrawal_limit`: `u128`
