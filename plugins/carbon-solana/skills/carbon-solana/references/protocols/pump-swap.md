# Pump Swap

- **Crate:** `carbon-pump-swap-decoder`
- **Program ID:** `pAMMBay6oceH9fJKBRHGP5D4bD4sWpmSwMn52FMfXEA`
- **Decoder struct:** `PumpSwapDecoder`
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
  - `is_cashback_coin`: `bool`

### `FeeConfig`
- **Fields:**
  - `bump`: `u8`
  - `admin`: `Pubkey`
  - `flat_fees`: `Fees`
  - `fee_tiers`: `Vec<FeeTier>`

### `GlobalConfig`
- **Fields:**
  - `admin`: `Pubkey`
  - `lp_fee_basis_points`: `u64`
  - `protocol_fee_basis_points`: `u64`
  - `disable_flags`: `u8`
  - `protocol_fee_recipients`: `[Pubkey; 8]`
  - `coin_creator_fee_basis_points`: `u64`
  - `admin_set_coin_creator_authority`: `Pubkey`
  - `whitelist_pda`: `Pubkey`
  - `reserved_fee_recipient`: `Pubkey`
  - `mayhem_mode_enabled`: `bool`
  - `reserved_fee_recipients`: `[Pubkey; 7]`
  - `is_cashback_enabled`: `bool`

### `GlobalVolumeAccumulator`
- **Fields:**
  - `start_time`: `i64`
  - `end_time`: `i64`
  - `seconds_in_a_day`: `i64`
  - `mint`: `Pubkey`
  - `total_token_supply`: `[u64; 30]`
  - `sol_volumes`: `[u64; 30]`

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
  - `is_cashback_coin`: `bool`

### `SharingConfig`
- **Fields:**
  - `bump`: `u8`
  - `version`: `u8`
  - `status`: `ConfigStatus`
  - `mint`: `Pubkey`
  - `admin`: `Pubkey`
  - `admin_revoked`: `bool`
  - `shareholders`: `Vec<Shareholder>`

### `UserVolumeAccumulator`
- **Fields:**
  - `user`: `Pubkey`
  - `needs_claim`: `bool`
  - `total_unclaimed_tokens`: `u64`
  - `total_claimed_tokens`: `u64`
  - `current_sol_volume`: `u64`
  - `last_update_timestamp`: `i64`
  - `has_total_claimed_tokens`: `bool`
  - `cashback_earned`: `u64`
  - `total_cashback_claimed`: `u64`

## Instructions

### `AdminSetCoinCreator`
- **Discriminator:** `[242, 40, 117, 145, 73, 96, 105, 104]`
- **Doc:** Overrides the coin creator for a canonical pump pool.
- **Args:**
  - `coin_creator`: `Pubkey`
- **Account variants:**
  - `5 accounts:` `admin_set_coin_creator_authority`, `global_config`, `pool`, `event_authority`, `program`
- **Remaining accounts:** yes

### `AdminUpdateTokenIncentives`
- **Discriminator:** `[209, 11, 115, 87, 213, 23, 124, 204]`
- **Args:**
  - `start_time`: `i64`
  - `end_time`: `i64`
  - `seconds_in_a_day`: `i64`
  - `day_number`: `u64`
  - `token_supply_per_day`: `u64`
- **Account variants:**
  - `10 accounts:` `admin`, `global_config`, `global_volume_accumulator`, `mint`, `global_incentive_token_account`, `associated_token_program`, `system_program`, `token_program`, `event_authority`, `program`
- **Remaining accounts:** yes

### `Buy`
- **Discriminator:** `[102, 6, 61, 18, 1, 218, 235, 234]`
- **Doc:** For cashback coins, optionally pass user_volume_accumulator_wsol_ata as remaining_accounts[0].
- **Args:**
  - `base_amount_out`: `u64`
  - `max_quote_amount_in`: `u64`
  - `track_volume`: `OptionBool`
- **Account variants:**
  - `23 accounts:` `pool`, `user`, `global_config`, `base_mint`, `quote_mint`, `user_base_token_account`, `user_quote_token_account`, `pool_base_token_account`, `pool_quote_token_account`, `protocol_fee_recipient`, `protocol_fee_recipient_token_account`, `base_token_program`, `quote_token_program`, `system_program`, `associated_token_program`, `event_authority`, `program`, `coin_creator_vault_ata`, `coin_creator_vault_authority`, `global_volume_accumulator`, `user_volume_accumulator`, `fee_config`, `fee_program`
- **Remaining accounts:** yes

### `BuyExactQuoteIn`
- **Discriminator:** `[198, 46, 21, 82, 180, 217, 232, 112]`
- **Doc:** Given a budget of spendable_quote_in, buy at least min_base_amount_out Fees will be deducted from spendable_quote_in f(quote) = tokens, where tokens >= min_base_amount_out Make sure the payer has enough SOL to cover creation of the following accounts (unless already created): - protocol_fee_recipient_token_account: rent.minimum_balance(TokenAccount::LEN) - coin_creator_vault_ata: rent.minimum_balance(TokenAccount::LEN) - user_volume_accumulator: rent.minimum_balance(UserVolumeAccumulator::LEN) For cashback coins, optionally pass user_volume_accumulator_wsol_ata as remaining_accounts[0].
- **Args:**
  - `spendable_quote_in`: `u64`
  - `min_base_amount_out`: `u64`
  - `track_volume`: `OptionBool`
- **Account variants:**
  - `23 accounts:` `pool`, `user`, `global_config`, `base_mint`, `quote_mint`, `user_base_token_account`, `user_quote_token_account`, `pool_base_token_account`, `pool_quote_token_account`, `protocol_fee_recipient`, `protocol_fee_recipient_token_account`, `base_token_program`, `quote_token_program`, `system_program`, `associated_token_program`, `event_authority`, `program`, `coin_creator_vault_ata`, `coin_creator_vault_authority`, `global_volume_accumulator`, `user_volume_accumulator`, `fee_config`, `fee_program`
- **Remaining accounts:** yes

### `ClaimCashback`
- **Discriminator:** `[37, 58, 35, 126, 190, 53, 228, 197]`
- **Args:** (none)
- **Account variants:**
  - `9 accounts:` `user`, `user_volume_accumulator`, `quote_mint`, `quote_token_program`, `user_volume_accumulator_wsol_token_account`, `user_wsol_token_account`, `system_program`, `event_authority`, `program`
- **Remaining accounts:** yes

### `ClaimTokenIncentives`
- **Discriminator:** `[16, 4, 71, 28, 204, 1, 40, 27]`
- **Args:** (none)
- **Account variants:**
  - `12 accounts:` `user`, `user_ata`, `global_volume_accumulator`, `global_incentive_token_account`, `user_volume_accumulator`, `mint`, `token_program`, `system_program`, `associated_token_program`, `event_authority`, `program`, `payer`
- **Remaining accounts:** yes

### `CloseUserVolumeAccumulator`
- **Discriminator:** `[249, 69, 164, 218, 150, 103, 84, 138]`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `user`, `user_volume_accumulator`, `event_authority`, `program`
- **Remaining accounts:** yes

### `CollectCoinCreatorFee`
- **Discriminator:** `[160, 57, 89, 42, 181, 139, 43, 66]`
- **Args:** (none)
- **Account variants:**
  - `8 accounts:` `quote_mint`, `quote_token_program`, `coin_creator`, `coin_creator_vault_authority`, `coin_creator_vault_ata`, `coin_creator_token_account`, `event_authority`, `program`
- **Remaining accounts:** yes

### `CpiEvent`
- **Discriminator:** `[228, 69, 165, 46, 81, 203, 154, 29]`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `program`, `event_authority`
- **Remaining accounts:** yes

### `CreateConfig`
- **Discriminator:** `[201, 207, 243, 114, 75, 111, 47, 189]`
- **Args:**
  - `lp_fee_basis_points`: `u64`
  - `protocol_fee_basis_points`: `u64`
  - `protocol_fee_recipients`: `[Pubkey; 8]`
  - `coin_creator_fee_basis_points`: `u64`
  - `admin_set_coin_creator_authority`: `Pubkey`
- **Account variants:**
  - `5 accounts:` `admin`, `global_config`, `system_program`, `event_authority`, `program`
- **Remaining accounts:** yes

### `CreatePool`
- **Discriminator:** `[233, 146, 209, 142, 207, 104, 64, 188]`
- **Args:**
  - `index`: `u16`
  - `base_amount_in`: `u64`
  - `quote_amount_in`: `u64`
  - `coin_creator`: `Pubkey`
  - `is_mayhem_mode`: `bool`
  - `is_cashback_coin`: `OptionBool`
- **Account variants:**
  - `18 accounts:` `pool`, `global_config`, `creator`, `base_mint`, `quote_mint`, `lp_mint`, `user_base_token_account`, `user_quote_token_account`, `user_pool_token_account`, `pool_base_token_account`, `pool_quote_token_account`, `system_program`, `token2022_program`, `base_token_program`, `quote_token_program`, `associated_token_program`, `event_authority`, `program`
- **Remaining accounts:** yes

### `Deposit`
- **Discriminator:** `[242, 35, 198, 137, 82, 225, 242, 182]`
- **Args:**
  - `lp_token_amount_out`: `u64`
  - `max_base_amount_in`: `u64`
  - `max_quote_amount_in`: `u64`
- **Account variants:**
  - `15 accounts:` `pool`, `global_config`, `user`, `base_mint`, `quote_mint`, `lp_mint`, `user_base_token_account`, `user_quote_token_account`, `user_pool_token_account`, `pool_base_token_account`, `pool_quote_token_account`, `token_program`, `token2022_program`, `event_authority`, `program`
- **Remaining accounts:** yes

### `Disable`
- **Discriminator:** `[185, 173, 187, 90, 216, 15, 238, 233]`
- **Args:**
  - `disable_create_pool`: `bool`
  - `disable_deposit`: `bool`
  - `disable_withdraw`: `bool`
  - `disable_buy`: `bool`
  - `disable_sell`: `bool`
- **Account variants:**
  - `4 accounts:` `admin`, `global_config`, `event_authority`, `program`
- **Remaining accounts:** yes

### `ExtendAccount`
- **Discriminator:** `[234, 102, 194, 203, 150, 72, 62, 229]`
- **Args:** (none)
- **Account variants:**
  - `5 accounts:` `account`, `user`, `system_program`, `event_authority`, `program`
- **Remaining accounts:** yes

### `InitUserVolumeAccumulator`
- **Discriminator:** `[94, 6, 202, 115, 255, 96, 232, 183]`
- **Args:** (none)
- **Account variants:**
  - `6 accounts:` `payer`, `user`, `user_volume_accumulator`, `system_program`, `event_authority`, `program`
- **Remaining accounts:** yes

### `MigratePoolCoinCreator`
- **Discriminator:** `[208, 8, 159, 4, 74, 175, 16, 58]`
- **Doc:** Migrate Pool Coin Creator to Sharing Config.
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `pool`, `sharing_config`, `event_authority`, `program`
- **Remaining accounts:** yes

### `Sell`
- **Discriminator:** `[51, 230, 133, 164, 1, 127, 131, 173]`
- **Args:**
  - `base_amount_in`: `u64`
  - `min_quote_amount_out`: `u64`
- **Account variants:**
  - `21 accounts:` `pool`, `user`, `global_config`, `base_mint`, `quote_mint`, `user_base_token_account`, `user_quote_token_account`, `pool_base_token_account`, `pool_quote_token_account`, `protocol_fee_recipient`, `protocol_fee_recipient_token_account`, `base_token_program`, `quote_token_program`, `system_program`, `associated_token_program`, `event_authority`, `program`, `coin_creator_vault_ata`, `coin_creator_vault_authority`, `fee_config`, `fee_program`
- **Remaining accounts:** yes

### `SetCoinCreator`
- **Discriminator:** `[210, 149, 128, 45, 188, 58, 78, 175]`
- **Doc:** Sets Pool::coin_creator from Metaplex metadata creator or BondingCurve::creator.
- **Args:** (none)
- **Account variants:**
  - `5 accounts:` `pool`, `metadata`, `bonding_curve`, `event_authority`, `program`
- **Remaining accounts:** yes

### `SetReservedFeeRecipients`
- **Discriminator:** `[111, 172, 162, 232, 114, 89, 213, 142]`
- **Args:**
  - `whitelist_pda`: `Pubkey`
- **Account variants:**
  - `4 accounts:` `global_config`, `admin`, `event_authority`, `program`
- **Remaining accounts:** yes

### `SyncUserVolumeAccumulator`
- **Discriminator:** `[86, 31, 192, 87, 163, 87, 79, 238]`
- **Args:** (none)
- **Account variants:**
  - `5 accounts:` `user`, `global_volume_accumulator`, `user_volume_accumulator`, `event_authority`, `program`
- **Remaining accounts:** yes

### `ToggleCashbackEnabled`
- **Discriminator:** `[115, 103, 224, 255, 189, 89, 86, 195]`
- **Args:**
  - `enabled`: `bool`
- **Account variants:**
  - `4 accounts:` `admin`, `global_config`, `event_authority`, `program`
- **Remaining accounts:** yes

### `ToggleMayhemMode`
- **Discriminator:** `[1, 9, 111, 208, 100, 31, 255, 163]`
- **Args:**
  - `enabled`: `bool`
- **Account variants:**
  - `4 accounts:` `admin`, `global_config`, `event_authority`, `program`
- **Remaining accounts:** yes

### `TransferCreatorFeesToPump`
- **Discriminator:** `[139, 52, 134, 85, 228, 229, 108, 241]`
- **Doc:** Transfer creator fees to pump creator vault If coin creator fees are currently below rent.minimum_balance(TokenAccount::LEN) The transfer will be skipped.
- **Args:** (none)
- **Account variants:**
  - `10 accounts:` `wsol_mint`, `token_program`, `system_program`, `associated_token_program`, `coin_creator`, `coin_creator_vault_authority`, `coin_creator_vault_ata`, `pump_creator_vault`, `event_authority`, `program`
- **Remaining accounts:** yes

### `UpdateAdmin`
- **Discriminator:** `[161, 176, 40, 213, 60, 184, 179, 228]`
- **Args:** (none)
- **Account variants:**
  - `5 accounts:` `admin`, `global_config`, `new_admin`, `event_authority`, `program`
- **Remaining accounts:** yes

### `UpdateFeeConfig`
- **Discriminator:** `[104, 184, 103, 242, 88, 151, 107, 20]`
- **Args:**
  - `lp_fee_basis_points`: `u64`
  - `protocol_fee_basis_points`: `u64`
  - `protocol_fee_recipients`: `[Pubkey; 8]`
  - `coin_creator_fee_basis_points`: `u64`
  - `admin_set_coin_creator_authority`: `Pubkey`
- **Account variants:**
  - `4 accounts:` `admin`, `global_config`, `event_authority`, `program`
- **Remaining accounts:** yes

### `Withdraw`
- **Discriminator:** `[183, 18, 70, 156, 148, 109, 161, 34]`
- **Args:**
  - `lp_token_amount_in`: `u64`
  - `min_base_amount_out`: `u64`
  - `min_quote_amount_out`: `u64`
- **Account variants:**
  - `15 accounts:` `pool`, `global_config`, `user`, `base_mint`, `quote_mint`, `lp_mint`, `user_base_token_account`, `user_quote_token_account`, `user_pool_token_account`, `pool_base_token_account`, `pool_quote_token_account`, `token_program`, `token2022_program`, `event_authority`, `program`
- **Remaining accounts:** yes

## CPI events

### `AdminSetCoinCreatorEventEvent`
- **Source:** `events/admin_set_coin_creator_event.rs`
- **Discriminator:** `[45, 220, 93, 24, 25, 97, 172, 104]`
- **Fields:**
  - `timestamp`: `i64`
  - `admin_set_coin_creator_authority`: `Pubkey`
  - `base_mint`: `Pubkey`
  - `pool`: `Pubkey`
  - `old_coin_creator`: `Pubkey`
  - `new_coin_creator`: `Pubkey`

### `AdminUpdateTokenIncentivesEventEvent`
- **Source:** `events/admin_update_token_incentives_event.rs`
- **Discriminator:** `[147, 250, 108, 120, 247, 29, 67, 222]`
- **Fields:**
  - `start_time`: `i64`
  - `end_time`: `i64`
  - `day_number`: `u64`
  - `token_supply_per_day`: `u64`
  - `mint`: `Pubkey`
  - `seconds_in_a_day`: `i64`
  - `timestamp`: `i64`

### `BuyEventEvent`
- **Source:** `events/buy_event.rs`
- **Discriminator:** `[103, 244, 82, 31, 44, 245, 119, 119]`
- **Fields:**
  - `timestamp`: `i64`
  - `base_amount_out`: `u64`
  - `max_quote_amount_in`: `u64`
  - `user_base_token_reserves`: `u64`
  - `user_quote_token_reserves`: `u64`
  - `pool_base_token_reserves`: `u64`
  - `pool_quote_token_reserves`: `u64`
  - `quote_amount_in`: `u64`
  - `lp_fee_basis_points`: `u64`
  - `lp_fee`: `u64`
  - `protocol_fee_basis_points`: `u64`
  - `protocol_fee`: `u64`
  - `quote_amount_in_with_lp_fee`: `u64`
  - `user_quote_amount_in`: `u64`
  - `pool`: `Pubkey`
  - `user`: `Pubkey`
  - `user_base_token_account`: `Pubkey`
  - `user_quote_token_account`: `Pubkey`
  - `protocol_fee_recipient`: `Pubkey`
  - `protocol_fee_recipient_token_account`: `Pubkey`
  - `coin_creator`: `Pubkey`
  - `coin_creator_fee_basis_points`: `u64`
  - `coin_creator_fee`: `u64`
  - `track_volume`: `bool`
  - `total_unclaimed_tokens`: `u64`
  - `total_claimed_tokens`: `u64`
  - `current_sol_volume`: `u64`
  - `last_update_timestamp`: `i64`
  - `min_base_amount_out`: `u64`
  - `ix_name`: `String`
  - `cashback_fee_basis_points`: `u64`
  - `cashback`: `u64`

### `ClaimCashbackEventEvent`
- **Source:** `events/claim_cashback_event.rs`
- **Discriminator:** `[226, 214, 246, 33, 7, 242, 147, 229]`
- **Fields:**
  - `user`: `Pubkey`
  - `amount`: `u64`
  - `timestamp`: `i64`
  - `total_claimed`: `u64`
  - `total_cashback_earned`: `u64`

### `ClaimTokenIncentivesEventEvent`
- **Source:** `events/claim_token_incentives_event.rs`
- **Discriminator:** `[79, 172, 246, 49, 205, 91, 206, 232]`
- **Fields:**
  - `user`: `Pubkey`
  - `mint`: `Pubkey`
  - `amount`: `u64`
  - `timestamp`: `i64`
  - `total_claimed_tokens`: `u64`
  - `current_sol_volume`: `u64`

### `CloseUserVolumeAccumulatorEventEvent`
- **Source:** `events/close_user_volume_accumulator_event.rs`
- **Discriminator:** `[146, 159, 189, 172, 146, 88, 56, 244]`
- **Fields:**
  - `user`: `Pubkey`
  - `timestamp`: `i64`
  - `total_unclaimed_tokens`: `u64`
  - `total_claimed_tokens`: `u64`
  - `current_sol_volume`: `u64`
  - `last_update_timestamp`: `i64`

### `CollectCoinCreatorFeeEventEvent`
- **Source:** `events/collect_coin_creator_fee_event.rs`
- **Discriminator:** `[232, 245, 194, 238, 234, 218, 58, 89]`
- **Fields:**
  - `timestamp`: `i64`
  - `coin_creator`: `Pubkey`
  - `coin_creator_fee`: `u64`
  - `coin_creator_vault_ata`: `Pubkey`
  - `coin_creator_token_account`: `Pubkey`

### `CreateConfigEventEvent`
- **Source:** `events/create_config_event.rs`
- **Discriminator:** `[107, 52, 89, 129, 55, 226, 81, 22]`
- **Fields:**
  - `timestamp`: `i64`
  - `admin`: `Pubkey`
  - `lp_fee_basis_points`: `u64`
  - `protocol_fee_basis_points`: `u64`
  - `protocol_fee_recipients`: `[Pubkey; 8]`
  - `coin_creator_fee_basis_points`: `u64`
  - `admin_set_coin_creator_authority`: `Pubkey`

### `CreatePoolEventEvent`
- **Source:** `events/create_pool_event.rs`
- **Discriminator:** `[177, 49, 12, 210, 160, 118, 167, 116]`
- **Fields:**
  - `timestamp`: `i64`
  - `index`: `u16`
  - `creator`: `Pubkey`
  - `base_mint`: `Pubkey`
  - `quote_mint`: `Pubkey`
  - `base_mint_decimals`: `u8`
  - `quote_mint_decimals`: `u8`
  - `base_amount_in`: `u64`
  - `quote_amount_in`: `u64`
  - `pool_base_amount`: `u64`
  - `pool_quote_amount`: `u64`
  - `minimum_liquidity`: `u64`
  - `initial_liquidity`: `u64`
  - `lp_token_amount_out`: `u64`
  - `pool_bump`: `u8`
  - `pool`: `Pubkey`
  - `lp_mint`: `Pubkey`
  - `user_base_token_account`: `Pubkey`
  - `user_quote_token_account`: `Pubkey`
  - `coin_creator`: `Pubkey`
  - `is_mayhem_mode`: `bool`

### `DepositEventEvent`
- **Source:** `events/deposit_event.rs`
- **Discriminator:** `[120, 248, 61, 83, 31, 142, 107, 144]`
- **Fields:**
  - `timestamp`: `i64`
  - `lp_token_amount_out`: `u64`
  - `max_base_amount_in`: `u64`
  - `max_quote_amount_in`: `u64`
  - `user_base_token_reserves`: `u64`
  - `user_quote_token_reserves`: `u64`
  - `pool_base_token_reserves`: `u64`
  - `pool_quote_token_reserves`: `u64`
  - `base_amount_in`: `u64`
  - `quote_amount_in`: `u64`
  - `lp_mint_supply`: `u64`
  - `pool`: `Pubkey`
  - `user`: `Pubkey`
  - `user_base_token_account`: `Pubkey`
  - `user_quote_token_account`: `Pubkey`
  - `user_pool_token_account`: `Pubkey`

### `DisableEventEvent`
- **Source:** `events/disable_event.rs`
- **Discriminator:** `[107, 253, 193, 76, 228, 202, 27, 104]`
- **Fields:**
  - `timestamp`: `i64`
  - `admin`: `Pubkey`
  - `disable_create_pool`: `bool`
  - `disable_deposit`: `bool`
  - `disable_withdraw`: `bool`
  - `disable_buy`: `bool`
  - `disable_sell`: `bool`

### `ExtendAccountEventEvent`
- **Source:** `events/extend_account_event.rs`
- **Discriminator:** `[97, 97, 215, 144, 93, 146, 22, 124]`
- **Fields:**
  - `timestamp`: `i64`
  - `account`: `Pubkey`
  - `user`: `Pubkey`
  - `current_size`: `u64`
  - `new_size`: `u64`

### `InitUserVolumeAccumulatorEventEvent`
- **Source:** `events/init_user_volume_accumulator_event.rs`
- **Discriminator:** `[134, 36, 13, 72, 232, 101, 130, 216]`
- **Fields:**
  - `payer`: `Pubkey`
  - `user`: `Pubkey`
  - `timestamp`: `i64`

### `MigratePoolCoinCreatorEventEvent`
- **Source:** `events/migrate_pool_coin_creator_event.rs`
- **Discriminator:** `[170, 221, 82, 199, 147, 165, 247, 46]`
- **Fields:**
  - `timestamp`: `i64`
  - `base_mint`: `Pubkey`
  - `pool`: `Pubkey`
  - `sharing_config`: `Pubkey`
  - `old_coin_creator`: `Pubkey`
  - `new_coin_creator`: `Pubkey`

### `ReservedFeeRecipientsEventEvent`
- **Source:** `events/reserved_fee_recipients_event.rs`
- **Discriminator:** `[43, 188, 250, 18, 221, 75, 187, 95]`
- **Fields:**
  - `timestamp`: `i64`
  - `reserved_fee_recipient`: `Pubkey`
  - `reserved_fee_recipients`: `[Pubkey; 7]`

### `SellEventEvent`
- **Source:** `events/sell_event.rs`
- **Discriminator:** `[62, 47, 55, 10, 165, 3, 220, 42]`
- **Fields:**
  - `timestamp`: `i64`
  - `base_amount_in`: `u64`
  - `min_quote_amount_out`: `u64`
  - `user_base_token_reserves`: `u64`
  - `user_quote_token_reserves`: `u64`
  - `pool_base_token_reserves`: `u64`
  - `pool_quote_token_reserves`: `u64`
  - `quote_amount_out`: `u64`
  - `lp_fee_basis_points`: `u64`
  - `lp_fee`: `u64`
  - `protocol_fee_basis_points`: `u64`
  - `protocol_fee`: `u64`
  - `quote_amount_out_without_lp_fee`: `u64`
  - `user_quote_amount_out`: `u64`
  - `pool`: `Pubkey`
  - `user`: `Pubkey`
  - `user_base_token_account`: `Pubkey`
  - `user_quote_token_account`: `Pubkey`
  - `protocol_fee_recipient`: `Pubkey`
  - `protocol_fee_recipient_token_account`: `Pubkey`
  - `coin_creator`: `Pubkey`
  - `coin_creator_fee_basis_points`: `u64`
  - `coin_creator_fee`: `u64`
  - `cashback_fee_basis_points`: `u64`
  - `cashback`: `u64`

### `SetBondingCurveCoinCreatorEventEvent`
- **Source:** `events/set_bonding_curve_coin_creator_event.rs`
- **Discriminator:** `[242, 231, 235, 102, 65, 99, 189, 211]`
- **Fields:**
  - `timestamp`: `i64`
  - `base_mint`: `Pubkey`
  - `pool`: `Pubkey`
  - `bonding_curve`: `Pubkey`
  - `coin_creator`: `Pubkey`

### `SetMetaplexCoinCreatorEventEvent`
- **Source:** `events/set_metaplex_coin_creator_event.rs`
- **Discriminator:** `[150, 107, 199, 123, 124, 207, 102, 228]`
- **Fields:**
  - `timestamp`: `i64`
  - `base_mint`: `Pubkey`
  - `pool`: `Pubkey`
  - `metadata`: `Pubkey`
  - `coin_creator`: `Pubkey`

### `SyncUserVolumeAccumulatorEventEvent`
- **Source:** `events/sync_user_volume_accumulator_event.rs`
- **Discriminator:** `[197, 122, 167, 124, 116, 81, 91, 255]`
- **Fields:**
  - `user`: `Pubkey`
  - `total_claimed_tokens_before`: `u64`
  - `total_claimed_tokens_after`: `u64`
  - `timestamp`: `i64`

### `UpdateAdminEventEvent`
- **Source:** `events/update_admin_event.rs`
- **Discriminator:** `[225, 152, 171, 87, 246, 63, 66, 234]`
- **Fields:**
  - `timestamp`: `i64`
  - `admin`: `Pubkey`
  - `new_admin`: `Pubkey`

### `UpdateFeeConfigEventEvent`
- **Source:** `events/update_fee_config_event.rs`
- **Discriminator:** `[90, 23, 65, 35, 62, 244, 188, 208]`
- **Fields:**
  - `timestamp`: `i64`
  - `admin`: `Pubkey`
  - `lp_fee_basis_points`: `u64`
  - `protocol_fee_basis_points`: `u64`
  - `protocol_fee_recipients`: `[Pubkey; 8]`
  - `coin_creator_fee_basis_points`: `u64`
  - `admin_set_coin_creator_authority`: `Pubkey`

### `WithdrawEventEvent`
- **Source:** `events/withdraw_event.rs`
- **Discriminator:** `[22, 9, 133, 26, 160, 44, 71, 192]`
- **Fields:**
  - `timestamp`: `i64`
  - `lp_token_amount_in`: `u64`
  - `min_base_amount_out`: `u64`
  - `min_quote_amount_out`: `u64`
  - `user_base_token_reserves`: `u64`
  - `user_quote_token_reserves`: `u64`
  - `pool_base_token_reserves`: `u64`
  - `pool_quote_token_reserves`: `u64`
  - `base_amount_out`: `u64`
  - `quote_amount_out`: `u64`
  - `lp_mint_supply`: `u64`
  - `pool`: `Pubkey`
  - `user`: `Pubkey`
  - `user_base_token_account`: `Pubkey`
  - `user_quote_token_account`: `Pubkey`
  - `user_pool_token_account`: `Pubkey`

## Shared types

### `AdminSetCoinCreatorEvent`
- `timestamp`: `i64`
- `admin_set_coin_creator_authority`: `Pubkey`
- `base_mint`: `Pubkey`
- `pool`: `Pubkey`
- `old_coin_creator`: `Pubkey`
- `new_coin_creator`: `Pubkey`

### `AdminUpdateTokenIncentivesEvent`
- `start_time`: `i64`
- `end_time`: `i64`
- `day_number`: `u64`
- `token_supply_per_day`: `u64`
- `mint`: `Pubkey`
- `seconds_in_a_day`: `i64`
- `timestamp`: `i64`

### `BuyEvent`
- `timestamp`: `i64`
- `base_amount_out`: `u64`
- `max_quote_amount_in`: `u64`
- `user_base_token_reserves`: `u64`
- `user_quote_token_reserves`: `u64`
- `pool_base_token_reserves`: `u64`
- `pool_quote_token_reserves`: `u64`
- `quote_amount_in`: `u64`
- `lp_fee_basis_points`: `u64`
- `lp_fee`: `u64`
- `protocol_fee_basis_points`: `u64`
- `protocol_fee`: `u64`
- `quote_amount_in_with_lp_fee`: `u64`
- `user_quote_amount_in`: `u64`
- `pool`: `Pubkey`
- `user`: `Pubkey`
- `user_base_token_account`: `Pubkey`
- `user_quote_token_account`: `Pubkey`
- `protocol_fee_recipient`: `Pubkey`
- `protocol_fee_recipient_token_account`: `Pubkey`
- `coin_creator`: `Pubkey`
- `coin_creator_fee_basis_points`: `u64`
- `coin_creator_fee`: `u64`
- `track_volume`: `bool`
- `total_unclaimed_tokens`: `u64`
- `total_claimed_tokens`: `u64`
- `current_sol_volume`: `u64`
- `last_update_timestamp`: `i64`
- `min_base_amount_out`: `u64`
- `ix_name`: `String`
- `cashback_fee_basis_points`: `u64`
- `cashback`: `u64`

### `ClaimCashbackEvent`
- `user`: `Pubkey`
- `amount`: `u64`
- `timestamp`: `i64`
- `total_claimed`: `u64`
- `total_cashback_earned`: `u64`

### `ClaimTokenIncentivesEvent`
- `user`: `Pubkey`
- `mint`: `Pubkey`
- `amount`: `u64`
- `timestamp`: `i64`
- `total_claimed_tokens`: `u64`
- `current_sol_volume`: `u64`

### `CloseUserVolumeAccumulatorEvent`
- `user`: `Pubkey`
- `timestamp`: `i64`
- `total_unclaimed_tokens`: `u64`
- `total_claimed_tokens`: `u64`
- `current_sol_volume`: `u64`
- `last_update_timestamp`: `i64`

### `CollectCoinCreatorFeeEvent`
- `timestamp`: `i64`
- `coin_creator`: `Pubkey`
- `coin_creator_fee`: `u64`
- `coin_creator_vault_ata`: `Pubkey`
- `coin_creator_token_account`: `Pubkey`

### `ConfigStatus`
- enum variants: `Paused`, `Active`

### `CreateConfigEvent`
- `timestamp`: `i64`
- `admin`: `Pubkey`
- `lp_fee_basis_points`: `u64`
- `protocol_fee_basis_points`: `u64`
- `protocol_fee_recipients`: `[Pubkey; 8]`
- `coin_creator_fee_basis_points`: `u64`
- `admin_set_coin_creator_authority`: `Pubkey`

### `CreatePoolEvent`
- `timestamp`: `i64`
- `index`: `u16`
- `creator`: `Pubkey`
- `base_mint`: `Pubkey`
- `quote_mint`: `Pubkey`
- `base_mint_decimals`: `u8`
- `quote_mint_decimals`: `u8`
- `base_amount_in`: `u64`
- `quote_amount_in`: `u64`
- `pool_base_amount`: `u64`
- `pool_quote_amount`: `u64`
- `minimum_liquidity`: `u64`
- `initial_liquidity`: `u64`
- `lp_token_amount_out`: `u64`
- `pool_bump`: `u8`
- `pool`: `Pubkey`
- `lp_mint`: `Pubkey`
- `user_base_token_account`: `Pubkey`
- `user_quote_token_account`: `Pubkey`
- `coin_creator`: `Pubkey`
- `is_mayhem_mode`: `bool`

### `DepositEvent`
- `timestamp`: `i64`
- `lp_token_amount_out`: `u64`
- `max_base_amount_in`: `u64`
- `max_quote_amount_in`: `u64`
- `user_base_token_reserves`: `u64`
- `user_quote_token_reserves`: `u64`
- `pool_base_token_reserves`: `u64`
- `pool_quote_token_reserves`: `u64`
- `base_amount_in`: `u64`
- `quote_amount_in`: `u64`
- `lp_mint_supply`: `u64`
- `pool`: `Pubkey`
- `user`: `Pubkey`
- `user_base_token_account`: `Pubkey`
- `user_quote_token_account`: `Pubkey`
- `user_pool_token_account`: `Pubkey`

### `DisableEvent`
- `timestamp`: `i64`
- `admin`: `Pubkey`
- `disable_create_pool`: `bool`
- `disable_deposit`: `bool`
- `disable_withdraw`: `bool`
- `disable_buy`: `bool`
- `disable_sell`: `bool`

### `ExtendAccountEvent`
- `timestamp`: `i64`
- `account`: `Pubkey`
- `user`: `Pubkey`
- `current_size`: `u64`
- `new_size`: `u64`

### `FeeTier`
- `market_cap_lamports_threshold`: `u128`
- `fees`: `Fees`

### `Fees`
- `lp_fee_bps`: `u64`
- `protocol_fee_bps`: `u64`
- `creator_fee_bps`: `u64`

### `InitUserVolumeAccumulatorEvent`
- `payer`: `Pubkey`
- `user`: `Pubkey`
- `timestamp`: `i64`

### `MigratePoolCoinCreatorEvent`
- `timestamp`: `i64`
- `base_mint`: `Pubkey`
- `pool`: `Pubkey`
- `sharing_config`: `Pubkey`
- `old_coin_creator`: `Pubkey`
- `new_coin_creator`: `Pubkey`

### `OptionBool`
(empty struct)

### `ReservedFeeRecipientsEvent`
- `timestamp`: `i64`
- `reserved_fee_recipient`: `Pubkey`
- `reserved_fee_recipients`: `[Pubkey; 7]`

### `SellEvent`
- `timestamp`: `i64`
- `base_amount_in`: `u64`
- `min_quote_amount_out`: `u64`
- `user_base_token_reserves`: `u64`
- `user_quote_token_reserves`: `u64`
- `pool_base_token_reserves`: `u64`
- `pool_quote_token_reserves`: `u64`
- `quote_amount_out`: `u64`
- `lp_fee_basis_points`: `u64`
- `lp_fee`: `u64`
- `protocol_fee_basis_points`: `u64`
- `protocol_fee`: `u64`
- `quote_amount_out_without_lp_fee`: `u64`
- `user_quote_amount_out`: `u64`
- `pool`: `Pubkey`
- `user`: `Pubkey`
- `user_base_token_account`: `Pubkey`
- `user_quote_token_account`: `Pubkey`
- `protocol_fee_recipient`: `Pubkey`
- `protocol_fee_recipient_token_account`: `Pubkey`
- `coin_creator`: `Pubkey`
- `coin_creator_fee_basis_points`: `u64`
- `coin_creator_fee`: `u64`
- `cashback_fee_basis_points`: `u64`
- `cashback`: `u64`

### `SetBondingCurveCoinCreatorEvent`
- `timestamp`: `i64`
- `base_mint`: `Pubkey`
- `pool`: `Pubkey`
- `bonding_curve`: `Pubkey`
- `coin_creator`: `Pubkey`

### `SetMetaplexCoinCreatorEvent`
- `timestamp`: `i64`
- `base_mint`: `Pubkey`
- `pool`: `Pubkey`
- `metadata`: `Pubkey`
- `coin_creator`: `Pubkey`

### `Shareholder`
- `address`: `Pubkey`
- `share_bps`: `u16`

### `SyncUserVolumeAccumulatorEvent`
- `user`: `Pubkey`
- `total_claimed_tokens_before`: `u64`
- `total_claimed_tokens_after`: `u64`
- `timestamp`: `i64`

### `UpdateAdminEvent`
- `timestamp`: `i64`
- `admin`: `Pubkey`
- `new_admin`: `Pubkey`

### `UpdateFeeConfigEvent`
- `timestamp`: `i64`
- `admin`: `Pubkey`
- `lp_fee_basis_points`: `u64`
- `protocol_fee_basis_points`: `u64`
- `protocol_fee_recipients`: `[Pubkey; 8]`
- `coin_creator_fee_basis_points`: `u64`
- `admin_set_coin_creator_authority`: `Pubkey`

### `WithdrawEvent`
- `timestamp`: `i64`
- `lp_token_amount_in`: `u64`
- `min_base_amount_out`: `u64`
- `min_quote_amount_out`: `u64`
- `user_base_token_reserves`: `u64`
- `user_quote_token_reserves`: `u64`
- `pool_base_token_reserves`: `u64`
- `pool_quote_token_reserves`: `u64`
- `base_amount_out`: `u64`
- `quote_amount_out`: `u64`
- `lp_mint_supply`: `u64`
- `pool`: `Pubkey`
- `user`: `Pubkey`
- `user_base_token_account`: `Pubkey`
- `user_quote_token_account`: `Pubkey`
- `user_pool_token_account`: `Pubkey`
