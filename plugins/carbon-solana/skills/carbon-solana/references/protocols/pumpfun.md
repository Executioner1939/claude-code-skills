# Pumpfun

- **Crate:** `carbon-pumpfun-decoder`
- **Program ID:** `6EF8rrecthR5Dkzon8Nwu78hRvfCKubJ14M5uBEwF6P`
- **Decoder struct:** `PumpfunDecoder`
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
  - `is_cashback_enabled`: `bool`

### `GlobalVolumeAccumulator`
- **Fields:**
  - `start_time`: `i64`
  - `end_time`: `i64`
  - `seconds_in_a_day`: `i64`
  - `mint`: `Pubkey`
  - `total_token_supply`: `[u64; 30]`
  - `sol_volumes`: `[u64; 30]`

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

### `AdminSetCreator`
- **Discriminator:** `[69, 25, 171, 142, 57, 239, 13, 4]`
- **Doc:** Allows Global::admin_set_creator_authority to override the bonding curve creator.
- **Args:**
  - `creator`: `Pubkey`
- **Account variants:**
  - `6 accounts:` `admin_set_creator_authority`, `global`, `mint`, `bonding_curve`, `event_authority`, `program`
- **Remaining accounts:** yes

### `AdminSetIdlAuthority`
- **Discriminator:** `[8, 217, 96, 231, 144, 104, 192, 5]`
- **Args:**
  - `idl_authority`: `Pubkey`
- **Account variants:**
  - `7 accounts:` `authority`, `global`, `idl_account`, `system_program`, `program_signer`, `event_authority`, `program`
- **Remaining accounts:** yes

### `AdminUpdateTokenIncentives`
- **Discriminator:** `[209, 11, 115, 87, 213, 23, 124, 204]`
- **Args:**
  - `start_time`: `i64`
  - `end_time`: `i64`
  - `seconds_in_a_day`: `i64`
  - `day_number`: `u64`
  - `pump_token_supply_per_day`: `u64`
- **Account variants:**
  - `10 accounts:` `authority`, `global`, `global_volume_accumulator`, `mint`, `global_incentive_token_account`, `associated_token_program`, `system_program`, `token_program`, `event_authority`, `program`
- **Remaining accounts:** yes

### `Buy`
- **Discriminator:** `[102, 6, 61, 18, 1, 218, 235, 234]`
- **Doc:** Buys tokens from a bonding curve.
- **Args:**
  - `amount`: `u64`
  - `max_sol_cost`: `u64`
  - `track_volume`: `OptionBool`
- **Account variants:**
  - `16 accounts:` `global`, `fee_recipient`, `mint`, `bonding_curve`, `associated_bonding_curve`, `associated_user`, `user`, `system_program`, `token_program`, `creator_vault`, `event_authority`, `program`, `global_volume_accumulator`, `user_volume_accumulator`, `fee_config`, `fee_program`
- **Remaining accounts:** yes

### `BuyExactSolIn`
- **Discriminator:** `[56, 252, 116, 8, 158, 223, 205, 95]`
- **Doc:** Given a budget of spendable SOL, buy at least min_tokens_out tokens.
- **Args:**
  - `spendable_sol_in`: `u64`
  - `min_tokens_out`: `u64`
  - `track_volume`: `OptionBool`
- **Account variants:**
  - `16 accounts:` `global`, `fee_recipient`, `mint`, `bonding_curve`, `associated_bonding_curve`, `associated_user`, `user`, `system_program`, `token_program`, `creator_vault`, `event_authority`, `program`, `global_volume_accumulator`, `user_volume_accumulator`, `fee_config`, `fee_program`
- **Remaining accounts:** yes

### `ClaimCashback`
- **Discriminator:** `[37, 58, 35, 126, 190, 53, 228, 197]`
- **Args:** (none)
- **Account variants:**
  - `5 accounts:` `user`, `user_volume_accumulator`, `system_program`, `event_authority`, `program`
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

### `CollectCreatorFee`
- **Discriminator:** `[20, 22, 86, 123, 198, 28, 219, 132]`
- **Doc:** Collects creator_fee from creator_vault to the coin creator account.
- **Args:** (none)
- **Account variants:**
  - `5 accounts:` `creator`, `creator_vault`, `system_program`, `event_authority`, `program`
- **Remaining accounts:** yes

### `CpiEvent`
- **Discriminator:** `[228, 69, 165, 46, 81, 203, 154, 29]`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `program`, `event_authority`
- **Remaining accounts:** yes

### `Create`
- **Discriminator:** `[24, 30, 200, 40, 5, 28, 7, 119]`
- **Doc:** Creates a new coin and bonding curve.
- **Args:**
  - `name`: `String`
  - `symbol`: `String`
  - `uri`: `String`
  - `creator`: `Pubkey`
- **Account variants:**
  - `14 accounts:` `mint`, `mint_authority`, `bonding_curve`, `associated_bonding_curve`, `global`, `mpl_token_metadata`, `metadata`, `user`, `system_program`, `token_program`, `associated_token_program`, `rent`, `event_authority`, `program`
- **Remaining accounts:** yes

### `CreateV2`
- **Discriminator:** `[214, 144, 76, 236, 95, 139, 49, 180]`
- **Doc:** Creates a new spl-22 coin and bonding curve.
- **Args:**
  - `name`: `String`
  - `symbol`: `String`
  - `uri`: `String`
  - `creator`: `Pubkey`
  - `is_mayhem_mode`: `bool`
  - `is_cashback_enabled`: `OptionBool`
- **Account variants:**
  - `16 accounts:` `mint`, `mint_authority`, `bonding_curve`, `associated_bonding_curve`, `global`, `user`, `system_program`, `token_program`, `associated_token_program`, `mayhem_program_id`, `global_params`, `sol_vault`, `mayhem_state`, `mayhem_token_vault`, `event_authority`, `program`
- **Remaining accounts:** yes

### `DistributeCreatorFees`
- **Discriminator:** `[165, 114, 103, 0, 121, 206, 247, 81]`
- **Doc:** Distributes creator fees to shareholders based on their share percentages The creator vault needs to have at least the minimum distributable amount to distribute fees This can be checked with the get_minimum_distributable_fee instruction.
- **Args:** (none)
- **Account variants:**
  - `7 accounts:` `mint`, `bonding_curve`, `sharing_config`, `creator_vault`, `system_program`, `event_authority`, `program`
- **Remaining accounts:** yes

### `ExtendAccount`
- **Discriminator:** `[234, 102, 194, 203, 150, 72, 62, 229]`
- **Doc:** Extends the size of program-owned accounts.
- **Args:** (none)
- **Account variants:**
  - `5 accounts:` `account`, `user`, `system_program`, `event_authority`, `program`
- **Remaining accounts:** yes

### `GetMinimumDistributableFee`
- **Discriminator:** `[117, 225, 127, 202, 134, 95, 68, 35]`
- **Doc:** Permissionless instruction to check the minimum required fees for distribution Returns the minimum required balance from the creator_vault and whether distribution can proceed.
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `mint`, `bonding_curve`, `sharing_config`, `creator_vault`
- **Remaining accounts:** yes

### `InitUserVolumeAccumulator`
- **Discriminator:** `[94, 6, 202, 115, 255, 96, 232, 183]`
- **Args:** (none)
- **Account variants:**
  - `6 accounts:` `payer`, `user`, `user_volume_accumulator`, `system_program`, `event_authority`, `program`
- **Remaining accounts:** yes

### `Initialize`
- **Discriminator:** `[175, 175, 109, 31, 13, 152, 155, 237]`
- **Doc:** Creates the global state.
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `global`, `user`, `system_program`
- **Remaining accounts:** yes

### `Migrate`
- **Discriminator:** `[155, 234, 231, 146, 236, 158, 162, 30]`
- **Doc:** Migrates liquidity to pump_amm if the bonding curve is complete.
- **Args:** (none)
- **Account variants:**
  - `24 accounts:` `global`, `withdraw_authority`, `mint`, `bonding_curve`, `associated_bonding_curve`, `user`, `system_program`, `token_program`, `pump_amm`, `pool`, `pool_authority`, `pool_authority_mint_account`, `pool_authority_wsol_account`, `amm_global_config`, `wsol_mint`, `lp_mint`, `user_pool_token_account`, `pool_base_token_account`, `pool_quote_token_account`, `token2022_program`, `associated_token_program`, `pump_amm_event_authority`, `event_authority`, `program`
- **Remaining accounts:** yes

### `MigrateBondingCurveCreator`
- **Discriminator:** `[87, 124, 52, 191, 52, 38, 214, 232]`
- **Args:** (none)
- **Account variants:**
  - `5 accounts:` `mint`, `bonding_curve`, `sharing_config`, `event_authority`, `program`
- **Remaining accounts:** yes

### `Sell`
- **Discriminator:** `[51, 230, 133, 164, 1, 127, 131, 173]`
- **Doc:** Sells tokens into a bonding curve.
- **Args:**
  - `amount`: `u64`
  - `min_sol_output`: `u64`
- **Account variants:**
  - `14 accounts:` `global`, `fee_recipient`, `mint`, `bonding_curve`, `associated_bonding_curve`, `associated_user`, `user`, `system_program`, `creator_vault`, `token_program`, `event_authority`, `program`, `fee_config`, `fee_program`
- **Remaining accounts:** yes

### `SetCreator`
- **Discriminator:** `[254, 148, 255, 112, 207, 142, 170, 165]`
- **Doc:** Allows Global::set_creator_authority to set the bonding curve creator from Metaplex metadata or input argument.
- **Args:**
  - `creator`: `Pubkey`
- **Account variants:**
  - `7 accounts:` `set_creator_authority`, `global`, `mint`, `metadata`, `bonding_curve`, `event_authority`, `program`
- **Remaining accounts:** yes

### `SetMayhemVirtualParams`
- **Discriminator:** `[61, 169, 188, 191, 153, 149, 42, 97]`
- **Args:** (none)
- **Account variants:**
  - `8 accounts:` `sol_vault_authority`, `mayhem_token_vault`, `mint`, `global`, `bonding_curve`, `token_program`, `event_authority`, `program`
- **Remaining accounts:** yes

### `SetMetaplexCreator`
- **Discriminator:** `[138, 96, 174, 217, 48, 85, 197, 246]`
- **Doc:** Syncs the bonding curve creator with the Metaplex metadata creator if it exists.
- **Args:** (none)
- **Account variants:**
  - `5 accounts:` `mint`, `metadata`, `bonding_curve`, `event_authority`, `program`
- **Remaining accounts:** yes

### `SetParams`
- **Discriminator:** `[27, 234, 178, 52, 147, 2, 187, 141]`
- **Doc:** Sets the global state parameters.
- **Args:**
  - `initial_virtual_token_reserves`: `u64`
  - `initial_virtual_sol_reserves`: `u64`
  - `initial_real_token_reserves`: `u64`
  - `token_total_supply`: `u64`
  - `fee_basis_points`: `u64`
  - `withdraw_authority`: `Pubkey`
  - `enable_migrate`: `bool`
  - `pool_migration_fee`: `u64`
  - `creator_fee_basis_points`: `u64`
  - `set_creator_authority`: `Pubkey`
  - `admin_set_creator_authority`: `Pubkey`
- **Account variants:**
  - `4 accounts:` `global`, `authority`, `event_authority`, `program`
- **Remaining accounts:** yes

### `SetReservedFeeRecipients`
- **Discriminator:** `[111, 172, 162, 232, 114, 89, 213, 142]`
- **Args:**
  - `whitelist_pda`: `Pubkey`
- **Account variants:**
  - `4 accounts:` `global`, `authority`, `event_authority`, `program`
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
  - `4 accounts:` `global`, `authority`, `event_authority`, `program`
- **Remaining accounts:** yes

### `ToggleCreateV2`
- **Discriminator:** `[28, 255, 230, 240, 172, 107, 203, 171]`
- **Args:**
  - `enabled`: `bool`
- **Account variants:**
  - `4 accounts:` `global`, `authority`, `event_authority`, `program`
- **Remaining accounts:** yes

### `ToggleMayhemMode`
- **Discriminator:** `[1, 9, 111, 208, 100, 31, 255, 163]`
- **Args:**
  - `enabled`: `bool`
- **Account variants:**
  - `4 accounts:` `global`, `authority`, `event_authority`, `program`
- **Remaining accounts:** yes

### `UpdateGlobalAuthority`
- **Discriminator:** `[227, 181, 74, 196, 208, 21, 97, 213]`
- **Args:** (none)
- **Account variants:**
  - `5 accounts:` `global`, `authority`, `new_authority`, `event_authority`, `program`
- **Remaining accounts:** yes

## CPI events

### `AdminSetCreatorEventEvent`
- **Source:** `events/admin_set_creator_event.rs`
- **Discriminator:** `[64, 69, 192, 104, 29, 30, 25, 107]`
- **Fields:**
  - `timestamp`: `i64`
  - `admin_set_creator_authority`: `Pubkey`
  - `mint`: `Pubkey`
  - `bonding_curve`: `Pubkey`
  - `old_creator`: `Pubkey`
  - `new_creator`: `Pubkey`

### `AdminSetIdlAuthorityEventEvent`
- **Source:** `events/admin_set_idl_authority_event.rs`
- **Discriminator:** `[245, 59, 70, 34, 75, 185, 109, 92]`
- **Fields:**
  - `idl_authority`: `Pubkey`

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

### `CollectCreatorFeeEventEvent`
- **Source:** `events/collect_creator_fee_event.rs`
- **Discriminator:** `[122, 2, 127, 1, 14, 191, 12, 175]`
- **Fields:**
  - `timestamp`: `i64`
  - `creator`: `Pubkey`
  - `creator_fee`: `u64`

### `CompleteEventEvent`
- **Source:** `events/complete_event.rs`
- **Discriminator:** `[95, 114, 97, 156, 212, 46, 152, 8]`
- **Fields:**
  - `user`: `Pubkey`
  - `mint`: `Pubkey`
  - `bonding_curve`: `Pubkey`
  - `timestamp`: `i64`

### `CompletePumpAmmMigrationEventEvent`
- **Source:** `events/complete_pump_amm_migration_event.rs`
- **Discriminator:** `[189, 233, 93, 185, 92, 148, 234, 148]`
- **Fields:**
  - `user`: `Pubkey`
  - `mint`: `Pubkey`
  - `mint_amount`: `u64`
  - `sol_amount`: `u64`
  - `pool_migration_fee`: `u64`
  - `bonding_curve`: `Pubkey`
  - `timestamp`: `i64`
  - `pool`: `Pubkey`

### `CreateEventEvent`
- **Source:** `events/create_event.rs`
- **Discriminator:** `[27, 114, 169, 77, 222, 235, 99, 118]`
- **Fields:**
  - `name`: `String`
  - `symbol`: `String`
  - `uri`: `String`
  - `mint`: `Pubkey`
  - `bonding_curve`: `Pubkey`
  - `user`: `Pubkey`
  - `creator`: `Pubkey`
  - `timestamp`: `i64`
  - `virtual_token_reserves`: `u64`
  - `virtual_sol_reserves`: `u64`
  - `real_token_reserves`: `u64`
  - `token_total_supply`: `u64`
  - `token_program`: `Pubkey`
  - `is_mayhem_mode`: `bool`
  - `is_cashback_enabled`: `bool`

### `DistributeCreatorFeesEventEvent`
- **Source:** `events/distribute_creator_fees_event.rs`
- **Discriminator:** `[165, 55, 129, 112, 4, 179, 202, 40]`
- **Fields:**
  - `timestamp`: `i64`
  - `mint`: `Pubkey`
  - `bonding_curve`: `Pubkey`
  - `sharing_config`: `Pubkey`
  - `admin`: `Pubkey`
  - `shareholders`: `Vec<Shareholder>`
  - `distributed`: `u64`

### `ExtendAccountEventEvent`
- **Source:** `events/extend_account_event.rs`
- **Discriminator:** `[97, 97, 215, 144, 93, 146, 22, 124]`
- **Fields:**
  - `account`: `Pubkey`
  - `user`: `Pubkey`
  - `current_size`: `u64`
  - `new_size`: `u64`
  - `timestamp`: `i64`

### `InitUserVolumeAccumulatorEventEvent`
- **Source:** `events/init_user_volume_accumulator_event.rs`
- **Discriminator:** `[134, 36, 13, 72, 232, 101, 130, 216]`
- **Fields:**
  - `payer`: `Pubkey`
  - `user`: `Pubkey`
  - `timestamp`: `i64`

### `MigrateBondingCurveCreatorEventEvent`
- **Source:** `events/migrate_bonding_curve_creator_event.rs`
- **Discriminator:** `[155, 167, 104, 220, 213, 108, 243, 3]`
- **Fields:**
  - `timestamp`: `i64`
  - `mint`: `Pubkey`
  - `bonding_curve`: `Pubkey`
  - `sharing_config`: `Pubkey`
  - `old_creator`: `Pubkey`
  - `new_creator`: `Pubkey`

### `MinimumDistributableFeeEventEvent`
- **Source:** `events/minimum_distributable_fee_event.rs`
- **Discriminator:** `[168, 216, 132, 239, 235, 182, 49, 52]`
- **Fields:**
  - `minimum_required`: `u64`
  - `distributable_fees`: `u64`
  - `can_distribute`: `bool`

### `ReservedFeeRecipientsEventEvent`
- **Source:** `events/reserved_fee_recipients_event.rs`
- **Discriminator:** `[43, 188, 250, 18, 221, 75, 187, 95]`
- **Fields:**
  - `timestamp`: `i64`
  - `reserved_fee_recipient`: `Pubkey`
  - `reserved_fee_recipients`: `[Pubkey; 7]`

### `SetCreatorEventEvent`
- **Source:** `events/set_creator_event.rs`
- **Discriminator:** `[237, 52, 123, 37, 245, 251, 72, 210]`
- **Fields:**
  - `timestamp`: `i64`
  - `mint`: `Pubkey`
  - `bonding_curve`: `Pubkey`
  - `creator`: `Pubkey`

### `SetMetaplexCreatorEventEvent`
- **Source:** `events/set_metaplex_creator_event.rs`
- **Discriminator:** `[142, 203, 6, 32, 127, 105, 191, 162]`
- **Fields:**
  - `timestamp`: `i64`
  - `mint`: `Pubkey`
  - `bonding_curve`: `Pubkey`
  - `metadata`: `Pubkey`
  - `creator`: `Pubkey`

### `SetParamsEventEvent`
- **Source:** `events/set_params_event.rs`
- **Discriminator:** `[223, 195, 159, 246, 62, 48, 143, 131]`
- **Fields:**
  - `initial_virtual_token_reserves`: `u64`
  - `initial_virtual_sol_reserves`: `u64`
  - `initial_real_token_reserves`: `u64`
  - `final_real_sol_reserves`: `u64`
  - `token_total_supply`: `u64`
  - `fee_basis_points`: `u64`
  - `withdraw_authority`: `Pubkey`
  - `enable_migrate`: `bool`
  - `pool_migration_fee`: `u64`
  - `creator_fee_basis_points`: `u64`
  - `fee_recipients`: `[Pubkey; 8]`
  - `timestamp`: `i64`
  - `set_creator_authority`: `Pubkey`
  - `admin_set_creator_authority`: `Pubkey`

### `SyncUserVolumeAccumulatorEventEvent`
- **Source:** `events/sync_user_volume_accumulator_event.rs`
- **Discriminator:** `[197, 122, 167, 124, 116, 81, 91, 255]`
- **Fields:**
  - `user`: `Pubkey`
  - `total_claimed_tokens_before`: `u64`
  - `total_claimed_tokens_after`: `u64`
  - `timestamp`: `i64`

### `TradeEventEvent`
- **Source:** `events/trade_event.rs`
- **Discriminator:** `[189, 219, 127, 211, 78, 230, 97, 238]`
- **Fields:**
  - `mint`: `Pubkey`
  - `sol_amount`: `u64`
  - `token_amount`: `u64`
  - `is_buy`: `bool`
  - `user`: `Pubkey`
  - `timestamp`: `i64`
  - `virtual_sol_reserves`: `u64`
  - `virtual_token_reserves`: `u64`
  - `real_sol_reserves`: `u64`
  - `real_token_reserves`: `u64`
  - `fee_recipient`: `Pubkey`
  - `fee_basis_points`: `u64`
  - `fee`: `u64`
  - `creator`: `Pubkey`
  - `creator_fee_basis_points`: `u64`
  - `creator_fee`: `u64`
  - `track_volume`: `bool`
  - `total_unclaimed_tokens`: `u64`
  - `total_claimed_tokens`: `u64`
  - `current_sol_volume`: `u64`
  - `last_update_timestamp`: `i64`
  - `ix_name`: `String`
  - `mayhem_mode`: `bool`
  - `cashback_fee_basis_points`: `u64`
  - `cashback`: `u64`

### `UpdateGlobalAuthorityEventEvent`
- **Source:** `events/update_global_authority_event.rs`
- **Discriminator:** `[182, 195, 137, 42, 35, 206, 207, 247]`
- **Fields:**
  - `global`: `Pubkey`
  - `authority`: `Pubkey`
  - `new_authority`: `Pubkey`
  - `timestamp`: `i64`

### `UpdateMayhemVirtualParamsEventEvent`
- **Source:** `events/update_mayhem_virtual_params_event.rs`
- **Discriminator:** `[117, 123, 228, 182, 161, 168, 220, 214]`
- **Fields:**
  - `timestamp`: `i64`
  - `mint`: `Pubkey`
  - `virtual_token_reserves`: `u64`
  - `virtual_sol_reserves`: `u64`
  - `new_virtual_token_reserves`: `u64`
  - `new_virtual_sol_reserves`: `u64`
  - `real_token_reserves`: `u64`
  - `real_sol_reserves`: `u64`

## Shared types

### `AdminSetCreatorEvent`
- `timestamp`: `i64`
- `admin_set_creator_authority`: `Pubkey`
- `mint`: `Pubkey`
- `bonding_curve`: `Pubkey`
- `old_creator`: `Pubkey`
- `new_creator`: `Pubkey`

### `AdminSetIdlAuthorityEvent`
- `idl_authority`: `Pubkey`

### `AdminUpdateTokenIncentivesEvent`
- `start_time`: `i64`
- `end_time`: `i64`
- `day_number`: `u64`
- `token_supply_per_day`: `u64`
- `mint`: `Pubkey`
- `seconds_in_a_day`: `i64`
- `timestamp`: `i64`

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

### `CollectCreatorFeeEvent`
- `timestamp`: `i64`
- `creator`: `Pubkey`
- `creator_fee`: `u64`

### `CompleteEvent`
- `user`: `Pubkey`
- `mint`: `Pubkey`
- `bonding_curve`: `Pubkey`
- `timestamp`: `i64`

### `CompletePumpAmmMigrationEvent`
- `user`: `Pubkey`
- `mint`: `Pubkey`
- `mint_amount`: `u64`
- `sol_amount`: `u64`
- `pool_migration_fee`: `u64`
- `bonding_curve`: `Pubkey`
- `timestamp`: `i64`
- `pool`: `Pubkey`

### `ConfigStatus`
- enum variants: `Paused`, `Active`

### `CreateEvent`
- `name`: `String`
- `symbol`: `String`
- `uri`: `String`
- `mint`: `Pubkey`
- `bonding_curve`: `Pubkey`
- `user`: `Pubkey`
- `creator`: `Pubkey`
- `timestamp`: `i64`
- `virtual_token_reserves`: `u64`
- `virtual_sol_reserves`: `u64`
- `real_token_reserves`: `u64`
- `token_total_supply`: `u64`
- `token_program`: `Pubkey`
- `is_mayhem_mode`: `bool`
- `is_cashback_enabled`: `bool`

### `DistributeCreatorFeesEvent`
- `timestamp`: `i64`
- `mint`: `Pubkey`
- `bonding_curve`: `Pubkey`
- `sharing_config`: `Pubkey`
- `admin`: `Pubkey`
- `shareholders`: `Vec<Shareholder>`
- `distributed`: `u64`

### `ExtendAccountEvent`
- `account`: `Pubkey`
- `user`: `Pubkey`
- `current_size`: `u64`
- `new_size`: `u64`
- `timestamp`: `i64`

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

### `MigrateBondingCurveCreatorEvent`
- `timestamp`: `i64`
- `mint`: `Pubkey`
- `bonding_curve`: `Pubkey`
- `sharing_config`: `Pubkey`
- `old_creator`: `Pubkey`
- `new_creator`: `Pubkey`

### `MinimumDistributableFeeEvent`
- `minimum_required`: `u64`
- `distributable_fees`: `u64`
- `can_distribute`: `bool`

### `OptionBool`
(empty struct)

### `ReservedFeeRecipientsEvent`
- `timestamp`: `i64`
- `reserved_fee_recipient`: `Pubkey`
- `reserved_fee_recipients`: `[Pubkey; 7]`

### `SetCreatorEvent`
- `timestamp`: `i64`
- `mint`: `Pubkey`
- `bonding_curve`: `Pubkey`
- `creator`: `Pubkey`

### `SetMetaplexCreatorEvent`
- `timestamp`: `i64`
- `mint`: `Pubkey`
- `bonding_curve`: `Pubkey`
- `metadata`: `Pubkey`
- `creator`: `Pubkey`

### `SetParamsEvent`
- `initial_virtual_token_reserves`: `u64`
- `initial_virtual_sol_reserves`: `u64`
- `initial_real_token_reserves`: `u64`
- `final_real_sol_reserves`: `u64`
- `token_total_supply`: `u64`
- `fee_basis_points`: `u64`
- `withdraw_authority`: `Pubkey`
- `enable_migrate`: `bool`
- `pool_migration_fee`: `u64`
- `creator_fee_basis_points`: `u64`
- `fee_recipients`: `[Pubkey; 8]`
- `timestamp`: `i64`
- `set_creator_authority`: `Pubkey`
- `admin_set_creator_authority`: `Pubkey`

### `Shareholder`
- `address`: `Pubkey`
- `share_bps`: `u16`

### `SyncUserVolumeAccumulatorEvent`
- `user`: `Pubkey`
- `total_claimed_tokens_before`: `u64`
- `total_claimed_tokens_after`: `u64`
- `timestamp`: `i64`

### `TradeEvent`
- `mint`: `Pubkey`
- `sol_amount`: `u64`
- `token_amount`: `u64`
- `is_buy`: `bool`
- `user`: `Pubkey`
- `timestamp`: `i64`
- `virtual_sol_reserves`: `u64`
- `virtual_token_reserves`: `u64`
- `real_sol_reserves`: `u64`
- `real_token_reserves`: `u64`
- `fee_recipient`: `Pubkey`
- `fee_basis_points`: `u64`
- `fee`: `u64`
- `creator`: `Pubkey`
- `creator_fee_basis_points`: `u64`
- `creator_fee`: `u64`
- `track_volume`: `bool`
- `total_unclaimed_tokens`: `u64`
- `total_claimed_tokens`: `u64`
- `current_sol_volume`: `u64`
- `last_update_timestamp`: `i64`
- `ix_name`: `String`
- `mayhem_mode`: `bool`
- `cashback_fee_basis_points`: `u64`
- `cashback`: `u64`

### `UpdateGlobalAuthorityEvent`
- `global`: `Pubkey`
- `authority`: `Pubkey`
- `new_authority`: `Pubkey`
- `timestamp`: `i64`

### `UpdateMayhemVirtualParamsEvent`
- `timestamp`: `i64`
- `mint`: `Pubkey`
- `virtual_token_reserves`: `u64`
- `virtual_sol_reserves`: `u64`
- `new_virtual_token_reserves`: `u64`
- `new_virtual_sol_reserves`: `u64`
- `real_token_reserves`: `u64`
- `real_sol_reserves`: `u64`
