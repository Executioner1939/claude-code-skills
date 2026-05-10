# Pump Fees

- **Crate:** `carbon-pump-fees-decoder`
- **Program ID:** `pfeeUxB6jkeY1Hxd7CsFCAjcbHA9rWtchMGdZ6VojVZ`
- **Decoder struct:** `PumpFeesDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (events/)
- **Discriminator style:** anchor 8-byte

## Account types

### `BondingCurve`
- **Fields:**
  - `virtual_token_reserves`: `u64`
  - `virtual_sol_reserves`: `u64`
  - `real_token_reserves`: `u64`
  - `real_sol_reserves`: `u64`
  - `token_total_supply`: `u64`
  - `complete`: `bool`
  - `creator`: `Pubkey`
  - `is_mayhem_mode`: `bool`

### `FeeConfig`
- **Fields:**
  - `bump`: `u8`
  - `admin`: `Pubkey`
  - `flat_fees`: `Fees`
  - `fee_tiers`: `Vec<FeeTier>`

### `FeeProgramGlobal`
- **Fields:**
  - `bump`: `u8`
  - `authority`: `Pubkey`
  - `disable_flags`: `u8`
  - `social_claim_authority`: `Pubkey`
  - `claim_rate_limit`: `u64`
  - `reserved`: `[u8; 256]`

### `Global`
- **Fields:**
  - `initialized`: `bool`
  - `authority`: `Pubkey`
  - `fee_recipient`: `Pubkey`
  - `initial_virtual_token_reserves`: `u64`
  - `initial_virtual_sol_reserves`: `u64`
  - `initial_real_token_reserves`: `u64`
  - `token_total_supply`: `u64`
  - `fee_basis_points`: `u64`
  - `withdraw_authority`: `Pubkey`
  - `enable_migrate`: `bool`
  - `pool_migration_fee`: `u64`
  - `creator_fee_basis_points`: `u64`
  - `fee_recipients`: `[Pubkey; 7]`
  - `set_creator_authority`: `Pubkey`
  - `admin_set_creator_authority`: `Pubkey`
  - `create_v2_enabled`: `bool`
  - `whitelist_pda`: `Pubkey`
  - `reserved_fee_recipient`: `Pubkey`
  - `mayhem_mode_enabled`: `bool`
  - `reserved_fee_recipients`: `[Pubkey; 7]`

### `Pool`
- **Fields:**
  - `pool_bump`: `u8`
  - `index`: `u16`
  - `creator`: `Pubkey`
  - `base_mint`: `Pubkey`
  - `quote_mint`: `Pubkey`
  - `lp_mint`: `Pubkey`
  - `pool_base_token_account`: `Pubkey`
  - `pool_quote_token_account`: `Pubkey`
  - `lp_supply`: `u64`
  - `coin_creator`: `Pubkey`
  - `is_mayhem_mode`: `bool`

### `SharingConfig`
- **Fields:**
  - `bump`: `u8`
  - `version`: `u8`
  - `status`: `ConfigStatus`
  - `mint`: `Pubkey`
  - `admin`: `Pubkey`
  - `admin_revoked`: `bool`
  - `shareholders`: `Vec<Shareholder>`

### `SocialFeePda`
- **Fields:**
  - `bump`: `u8`
  - `version`: `u8`
  - `user_id`: `String`
  - `platform`: `u8`
  - `total_claimed`: `u64`
  - `last_claimed`: `u64`
  - `reserved`: `[u8; 128]`

## Instructions

### `ClaimSocialFeePda`
- **Discriminator:** `[225, 21, 251, 133, 161, 30, 199, 226]`
- **Args:**
  - `user_id`: `String`
  - `platform`: `u8`
- **Account variants:**
  - `6 accounts:` `recipient`, `social_fee_pda`, `fee_program_global`, `social_claim_authority`, `event_authority`, `program`
- **Remaining accounts:** yes

### `CpiEvent`
- **Discriminator:** `[228, 69, 165, 46, 81, 203, 154, 29]`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `program`, `event_authority`
- **Remaining accounts:** yes

### `CreateFeeSharingConfig`
- **Discriminator:** `[195, 78, 86, 76, 111, 52, 251, 213]`
- **Doc:** Create Fee Sharing Config.
- **Args:** (none)
- **Account variants:**
  - `13 accounts:` `event_authority`, `program`, `payer`, `global`, `mint`, `sharing_config`, `system_program`, `bonding_curve`, `pump_program`, `pump_event_authority`, `pool`, `pump_amm_program`, `pump_amm_event_authority`
- **Optional accounts:** `pool`, `pump_amm_program`, `pump_amm_event_authority`
- **Remaining accounts:** yes

### `CreateSocialFeePda`
- **Discriminator:** `[144, 224, 59, 211, 78, 248, 202, 220]`
- **Args:**
  - `user_id`: `String`
  - `platform`: `u8`
- **Account variants:**
  - `6 accounts:` `payer`, `social_fee_pda`, `system_program`, `fee_program_global`, `event_authority`, `program`
- **Remaining accounts:** yes

### `GetFees`
- **Discriminator:** `[231, 37, 126, 85, 207, 91, 63, 52]`
- **Doc:** Get Fees.
- **Args:**
  - `is_pump_pool`: `bool`
  - `market_cap_lamports`: `u128`
  - `trade_size_lamports`: `u64`
- **Account variants:**
  - `2 accounts:` `fee_config`, `config_program_id`
- **Remaining accounts:** yes

### `InitializeFeeConfig`
- **Discriminator:** `[62, 162, 20, 133, 121, 65, 145, 27]`
- **Doc:** Initialize FeeConfig admin.
- **Args:** (none)
- **Account variants:**
  - `6 accounts:` `admin`, `fee_config`, `system_program`, `config_program_id`, `event_authority`, `program`
- **Remaining accounts:** yes

### `InitializeFeeProgramGlobal`
- **Discriminator:** `[35, 215, 130, 84, 233, 56, 124, 167]`
- **Args:**
  - `social_claim_authority`: `Pubkey`
  - `disable_flags`: `u8`
  - `claim_rate_limit`: `u64`
- **Account variants:**
  - `6 accounts:` `authority`, `pump_global`, `fee_program_global`, `system_program`, `event_authority`, `program`
- **Remaining accounts:** yes

### `ResetFeeSharingConfig`
- **Discriminator:** `[10, 2, 182, 95, 16, 127, 129, 186]`
- **Doc:** Reset Fee Sharing Config, make sure to distribute all the fees before calling this.
- **Args:** (none)
- **Account variants:**
  - `7 accounts:` `authority`, `global`, `new_admin`, `mint`, `sharing_config`, `event_authority`, `program`
- **Remaining accounts:** yes

### `RevokeFeeSharingAuthority`
- **Discriminator:** `[18, 233, 158, 39, 185, 207, 58, 104]`
- **Doc:** Revoke Fee Sharing Authority.
- **Args:** (none)
- **Account variants:**
  - `6 accounts:` `authority`, `global`, `mint`, `sharing_config`, `event_authority`, `program`
- **Remaining accounts:** yes

### `SetAuthority`
- **Discriminator:** `[133, 250, 37, 21, 110, 163, 26, 121]`
- **Args:**
  - `new_authority`: `Pubkey`
- **Account variants:**
  - `4 accounts:` `authority`, `fee_program_global`, `event_authority`, `program`
- **Remaining accounts:** yes

### `SetClaimRateLimit`
- **Discriminator:** `[185, 211, 159, 174, 212, 49, 88, 4]`
- **Args:**
  - `claim_rate_limit`: `u64`
- **Account variants:**
  - `4 accounts:` `authority`, `fee_program_global`, `event_authority`, `program`
- **Remaining accounts:** yes

### `SetDisableFlags`
- **Discriminator:** `[194, 217, 112, 35, 114, 222, 51, 190]`
- **Args:**
  - `disable_flags`: `u8`
- **Account variants:**
  - `4 accounts:` `authority`, `fee_program_global`, `event_authority`, `program`
- **Remaining accounts:** yes

### `SetSocialClaimAuthority`
- **Discriminator:** `[147, 54, 184, 154, 136, 237, 185, 153]`
- **Args:**
  - `social_claim_authority`: `Pubkey`
- **Account variants:**
  - `4 accounts:` `authority`, `fee_program_global`, `event_authority`, `program`
- **Remaining accounts:** yes

### `TransferFeeSharingAuthority`
- **Discriminator:** `[202, 10, 75, 200, 164, 34, 210, 96]`
- **Doc:** Transfer Fee Sharing Authority.
- **Args:** (none)
- **Account variants:**
  - `7 accounts:` `authority`, `global`, `mint`, `sharing_config`, `new_admin`, `event_authority`, `program`
- **Remaining accounts:** yes

### `UpdateAdmin`
- **Discriminator:** `[161, 176, 40, 213, 60, 184, 179, 228]`
- **Doc:** Update admin (only callable by admin).
- **Args:** (none)
- **Account variants:**
  - `6 accounts:` `admin`, `fee_config`, `new_admin`, `config_program_id`, `event_authority`, `program`
- **Remaining accounts:** yes

### `UpdateFeeConfig`
- **Discriminator:** `[104, 184, 103, 242, 88, 151, 107, 20]`
- **Doc:** Set/Replace fee parameters entirely (only callable by admin).
- **Args:**
  - `fee_tiers`: `Vec<FeeTier>`
  - `flat_fees`: `Fees`
- **Account variants:**
  - `5 accounts:` `fee_config`, `admin`, `config_program_id`, `event_authority`, `program`
- **Remaining accounts:** yes

### `UpdateFeeShares`
- **Discriminator:** `[189, 13, 136, 99, 187, 164, 237, 35]`
- **Doc:** Update Fee Shares, make sure to distribute all the fees before calling this.
- **Args:**
  - `shareholders`: `Vec<Shareholder>`
- **Account variants:**
  - `18 accounts:` `event_authority`, `program`, `authority`, `global`, `mint`, `sharing_config`, `bonding_curve`, `pump_creator_vault`, `system_program`, `pump_program`, `pump_event_authority`, `pump_amm_program`, `amm_event_authority`, `wsol_mint`, `token_program`, `associated_token_program`, `coin_creator_vault_authority`, `coin_creator_vault_ata`
- **Remaining accounts:** yes

### `UpsertFeeTiers`
- **Discriminator:** `[227, 23, 150, 12, 77, 86, 94, 4]`
- **Doc:** Update or expand fee tiers (only callable by admin).
- **Args:**
  - `fee_tiers`: `Vec<FeeTier>`
  - `offset`: `u8`
- **Account variants:**
  - `5 accounts:` `fee_config`, `admin`, `config_program_id`, `event_authority`, `program`
- **Remaining accounts:** yes

## CPI events

### `CreateFeeSharingConfigEventEvent`
- **Source:** `events/create_fee_sharing_config_event.rs`
- **Discriminator:** `[133, 105, 170, 200, 184, 116, 251, 88]`
- **Fields:**
  - `timestamp`: `i64`
  - `mint`: `Pubkey`
  - `bonding_curve`: `Pubkey`
  - `pool`: `Option<Pubkey>`
  - `sharing_config`: `Pubkey`
  - `admin`: `Pubkey`
  - `initial_shareholders`: `Vec<Shareholder>`
  - `status`: `ConfigStatus`

### `InitializeFeeConfigEventEvent`
- **Source:** `events/initialize_fee_config_event.rs`
- **Discriminator:** `[89, 138, 244, 230, 10, 56, 226, 126]`
- **Fields:**
  - `timestamp`: `i64`
  - `admin`: `Pubkey`
  - `fee_config`: `Pubkey`

### `InitializeFeeProgramGlobalEventEvent`
- **Source:** `events/initialize_fee_program_global_event.rs`
- **Discriminator:** `[40, 233, 156, 78, 95, 0, 8, 199]`
- **Fields:**
  - `timestamp`: `i64`
  - `authority`: `Pubkey`
  - `social_claim_authority`: `Pubkey`
  - `disable_flags`: `u8`
  - `claim_rate_limit`: `u64`

### `ResetFeeSharingConfigEventEvent`
- **Source:** `events/reset_fee_sharing_config_event.rs`
- **Discriminator:** `[203, 204, 151, 226, 120, 55, 214, 243]`
- **Fields:**
  - `timestamp`: `i64`
  - `mint`: `Pubkey`
  - `sharing_config`: `Pubkey`
  - `old_admin`: `Pubkey`
  - `old_shareholders`: `Vec<Shareholder>`
  - `new_admin`: `Pubkey`
  - `new_shareholders`: `Vec<Shareholder>`

### `RevokeFeeSharingAuthorityEventEvent`
- **Source:** `events/revoke_fee_sharing_authority_event.rs`
- **Discriminator:** `[114, 23, 101, 60, 14, 190, 153, 62]`
- **Fields:**
  - `timestamp`: `i64`
  - `mint`: `Pubkey`
  - `sharing_config`: `Pubkey`
  - `admin`: `Pubkey`

### `SetAuthorityEventEvent`
- **Source:** `events/set_authority_event.rs`
- **Discriminator:** `[18, 175, 132, 66, 208, 201, 87, 242]`
- **Fields:**
  - `timestamp`: `i64`
  - `old_authority`: `Pubkey`
  - `new_authority`: `Pubkey`

### `SetClaimRateLimitEventEvent`
- **Source:** `events/set_claim_rate_limit_event.rs`
- **Discriminator:** `[13, 143, 143, 235, 181, 19, 51, 40]`
- **Fields:**
  - `timestamp`: `i64`
  - `claim_rate_limit`: `u64`

### `SetDisableFlagsEventEvent`
- **Source:** `events/set_disable_flags_event.rs`
- **Discriminator:** `[5, 8, 179, 65, 49, 55, 145, 126]`
- **Fields:**
  - `timestamp`: `i64`
  - `disable_flags`: `u8`

### `SetSocialClaimAuthorityEventEvent`
- **Source:** `events/set_social_claim_authority_event.rs`
- **Discriminator:** `[60, 118, 127, 132, 239, 52, 254, 14]`
- **Fields:**
  - `timestamp`: `i64`
  - `social_claim_authority`: `Pubkey`

### `SocialFeePdaClaimedEvent`
- **Source:** `events/social_fee_pda_claimed.rs`
- **Discriminator:** `[50, 18, 193, 65, 237, 210, 234, 236]`
- **Fields:**
  - `timestamp`: `i64`
  - `user_id`: `String`
  - `platform`: `u8`
  - `social_fee_pda`: `Pubkey`
  - `recipient`: `Pubkey`
  - `social_claim_authority`: `Pubkey`
  - `amount_claimed`: `u64`
  - `claimable_before`: `u64`
  - `lifetime_claimed`: `u64`
  - `recipient_balance_before`: `u64`
  - `recipient_balance_after`: `u64`

### `SocialFeePdaCreatedEvent`
- **Source:** `events/social_fee_pda_created.rs`
- **Discriminator:** `[183, 183, 218, 147, 24, 124, 137, 169]`
- **Fields:**
  - `timestamp`: `i64`
  - `user_id`: `String`
  - `platform`: `u8`
  - `social_fee_pda`: `Pubkey`
  - `created_by`: `Pubkey`

### `TransferFeeSharingAuthorityEventEvent`
- **Source:** `events/transfer_fee_sharing_authority_event.rs`
- **Discriminator:** `[124, 143, 198, 245, 77, 184, 8, 236]`
- **Fields:**
  - `timestamp`: `i64`
  - `mint`: `Pubkey`
  - `sharing_config`: `Pubkey`
  - `old_admin`: `Pubkey`
  - `new_admin`: `Pubkey`

### `UpdateAdminEventEvent`
- **Source:** `events/update_admin_event.rs`
- **Discriminator:** `[225, 152, 171, 87, 246, 63, 66, 234]`
- **Fields:**
  - `timestamp`: `i64`
  - `old_admin`: `Pubkey`
  - `new_admin`: `Pubkey`

### `UpdateFeeConfigEventEvent`
- **Source:** `events/update_fee_config_event.rs`
- **Discriminator:** `[90, 23, 65, 35, 62, 244, 188, 208]`
- **Fields:**
  - `timestamp`: `i64`
  - `admin`: `Pubkey`
  - `fee_config`: `Pubkey`
  - `fee_tiers`: `Vec<FeeTier>`
  - `flat_fees`: `Fees`

### `UpdateFeeSharesEventEvent`
- **Source:** `events/update_fee_shares_event.rs`
- **Discriminator:** `[21, 186, 196, 184, 91, 228, 225, 203]`
- **Fields:**
  - `timestamp`: `i64`
  - `mint`: `Pubkey`
  - `sharing_config`: `Pubkey`
  - `admin`: `Pubkey`
  - `new_shareholders`: `Vec<Shareholder>`

### `UpsertFeeTiersEventEvent`
- **Source:** `events/upsert_fee_tiers_event.rs`
- **Discriminator:** `[171, 89, 169, 187, 122, 186, 33, 204]`
- **Fields:**
  - `timestamp`: `i64`
  - `admin`: `Pubkey`
  - `fee_config`: `Pubkey`
  - `fee_tiers`: `Vec<FeeTier>`
  - `offset`: `u8`

## Shared types

### `ConfigStatus`
- enum variants: `Paused`, `Active`

### `CreateFeeSharingConfigEvent`
- `timestamp`: `i64`
- `mint`: `Pubkey`
- `bonding_curve`: `Pubkey`
- `pool`: `Option<Pubkey>`
- `sharing_config`: `Pubkey`
- `admin`: `Pubkey`
- `initial_shareholders`: `Vec<Shareholder>`
- `status`: `ConfigStatus`

### `FeeTier`
- `market_cap_lamports_threshold`: `u128`
- `fees`: `Fees`

### `Fees`
- `lp_fee_bps`: `u64`
- `protocol_fee_bps`: `u64`
- `creator_fee_bps`: `u64`

### `InitializeFeeConfigEvent`
- `timestamp`: `i64`
- `admin`: `Pubkey`
- `fee_config`: `Pubkey`

### `InitializeFeeProgramGlobalEvent`
- `timestamp`: `i64`
- `authority`: `Pubkey`
- `social_claim_authority`: `Pubkey`
- `disable_flags`: `u8`
- `claim_rate_limit`: `u64`

### `ResetFeeSharingConfigEvent`
- `timestamp`: `i64`
- `mint`: `Pubkey`
- `sharing_config`: `Pubkey`
- `old_admin`: `Pubkey`
- `old_shareholders`: `Vec<Shareholder>`
- `new_admin`: `Pubkey`
- `new_shareholders`: `Vec<Shareholder>`

### `RevokeFeeSharingAuthorityEvent`
- `timestamp`: `i64`
- `mint`: `Pubkey`
- `sharing_config`: `Pubkey`
- `admin`: `Pubkey`

### `SetAuthorityEvent`
- `timestamp`: `i64`
- `old_authority`: `Pubkey`
- `new_authority`: `Pubkey`

### `SetClaimRateLimitEvent`
- `timestamp`: `i64`
- `claim_rate_limit`: `u64`

### `SetDisableFlagsEvent`
- `timestamp`: `i64`
- `disable_flags`: `u8`

### `SetSocialClaimAuthorityEvent`
- `timestamp`: `i64`
- `social_claim_authority`: `Pubkey`

### `Shareholder`
- `address`: `Pubkey`
- `share_bps`: `u16`

### `SocialFeePdaClaimed`
- `timestamp`: `i64`
- `user_id`: `String`
- `platform`: `u8`
- `social_fee_pda`: `Pubkey`
- `recipient`: `Pubkey`
- `social_claim_authority`: `Pubkey`
- `amount_claimed`: `u64`
- `claimable_before`: `u64`
- `lifetime_claimed`: `u64`
- `recipient_balance_before`: `u64`
- `recipient_balance_after`: `u64`

### `SocialFeePdaCreated`
- `timestamp`: `i64`
- `user_id`: `String`
- `platform`: `u8`
- `social_fee_pda`: `Pubkey`
- `created_by`: `Pubkey`

### `TransferFeeSharingAuthorityEvent`
- `timestamp`: `i64`
- `mint`: `Pubkey`
- `sharing_config`: `Pubkey`
- `old_admin`: `Pubkey`
- `new_admin`: `Pubkey`

### `UpdateAdminEvent`
- `timestamp`: `i64`
- `old_admin`: `Pubkey`
- `new_admin`: `Pubkey`

### `UpdateFeeConfigEvent`
- `timestamp`: `i64`
- `admin`: `Pubkey`
- `fee_config`: `Pubkey`
- `fee_tiers`: `Vec<FeeTier>`
- `flat_fees`: `Fees`

### `UpdateFeeSharesEvent`
- `timestamp`: `i64`
- `mint`: `Pubkey`
- `sharing_config`: `Pubkey`
- `admin`: `Pubkey`
- `new_shareholders`: `Vec<Shareholder>`

### `UpsertFeeTiersEvent`
- `timestamp`: `i64`
- `admin`: `Pubkey`
- `fee_config`: `Pubkey`
- `fee_tiers`: `Vec<FeeTier>`
- `offset`: `u8`
