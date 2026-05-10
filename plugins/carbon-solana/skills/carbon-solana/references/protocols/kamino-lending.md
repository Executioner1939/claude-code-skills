# Kamino Lending

- **Crate:** `carbon-kamino-lending-decoder`
- **Program ID:** `KLend2g3cP87fffoy8q1mQqGKjrxjC8boSyAYavgmjD`
- **Decoder struct:** `KaminoLendingDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** no
- **Discriminator style:** anchor 8-byte

## Account types

### `LendingMarket`
- **Fields:**
  - `version`: `u64`
  - `bump_seed`: `u64`
  - `lending_market_owner`: `Pubkey`
  - `lending_market_owner_cached`: `Pubkey`
  - `quote_currency`: `[u8; 32]`
  - `referral_fee_bps`: `u16`
  - `emergency_mode`: `u8`
  - `autodeleverage_enabled`: `u8`
  - `borrow_disabled`: `u8`
  - `price_refresh_trigger_to_max_age_pct`: `u8`
  - `liquidation_max_debt_close_factor_pct`: `u8`
  - `insolvency_risk_unhealthy_ltv_pct`: `u8`
  - `min_full_liquidation_value_threshold`: `u64`
  - `max_liquidatable_debt_market_value_at_once`: `u64`
  - `global_unhealthy_borrow_value`: `u64`
  - `global_allowed_borrow_value`: `u64`
  - `risk_council`: `Pubkey`
  - `reserved1`: `[u8; 8]`
  - `elevation_groups`: `[ElevationGroup; 32]`
  - `elevation_group_padding`: `[u64; 90]`
  - `min_net_value_in_obligation_sf`: `u128`
  - `min_value_skip_liquidation_ltv_bf_checks`: `u64`
  - `name`: `[u8; 32]`
  - `padding1`: `[u64; 173]`

### `Obligation`
- **Fields:**
  - `tag`: `u64`
  - `last_update`: `LastUpdate`
  - `lending_market`: `Pubkey`
  - `owner`: `Pubkey`
  - `deposits`: `[ObligationCollateral; 8]`
  - `lowest_reserve_deposit_liquidation_ltv`: `u64`
  - `deposited_value_sf`: `u128`
  - `borrows`: `[ObligationLiquidity; 5]`
  - `borrow_factor_adjusted_debt_value_sf`: `u128`
  - `borrowed_assets_market_value_sf`: `u128`
  - `allowed_borrow_value_sf`: `u128`
  - `unhealthy_borrow_value_sf`: `u128`
  - `deposits_asset_tiers`: `[u8; 8]`
  - `borrows_asset_tiers`: `[u8; 5]`
  - `elevation_group`: `u8`
  - `num_of_obsolete_reserves`: `u8`
  - `has_debt`: `u8`
  - `referrer`: `Pubkey`
  - `borrowing_disabled`: `u8`
  - `reserved`: `[u8; 7]`
  - `highest_borrow_factor_pct`: `u64`
  - `padding3`: `[u64; 126]`

### `ReferrerState`
- **Fields:**
  - `short_url`: `Pubkey`
  - `owner`: `Pubkey`

### `ReferrerTokenState`
- **Fields:**
  - `referrer`: `Pubkey`
  - `mint`: `Pubkey`
  - `amount_unclaimed_sf`: `u128`
  - `amount_cumulative_sf`: `u128`
  - `bump`: `u64`
  - `padding`: `[u64; 31]`

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
  - `config_padding`: `[u64; 117]`
  - `borrowed_amount_outside_elevation_group`: `u64`
  - `borrowed_amounts_against_this_reserve_in_elevation_groups`: `[u64; 32]`
  - `padding`: `[u64; 207]`

### `ShortUrl`
- **Fields:**
  - `referrer`: `Pubkey`
  - `short_url`: `String`

### `UserMetadata`
- **Fields:**
  - `referrer`: `Pubkey`
  - `bump`: `u64`
  - `user_lookup_table`: `Pubkey`
  - `owner`: `Pubkey`
  - `padding1`: `[u64; 51]`
  - `padding2`: `[u64; 64]`

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

### `BorrowObligationLiquidity`
- **Discriminator:** `0x797f12cc49f5e141`
- **Args:**
  - `liquidity_amount`: `u64`
- **Account variants:**
  - `12 accounts:` `owner`, `obligation`, `lending_market`, `lending_market_authority`, `borrow_reserve`, `borrow_reserve_liquidity_mint`, `reserve_source_liquidity`, `borrow_reserve_liquidity_fee_receiver`, `user_destination_liquidity`, `referrer_token_state`, `token_program`, `instruction_sysvar_account`

### `DeleteReferrerStateAndShortUrl`
- **Discriminator:** `0x99b9631ce4b3bb96`
- **Args:** (none)
- **Account variants:**
  - `5 accounts:` `referrer`, `referrer_state`, `short_url`, `rent`, `system_program`

### `DepositObligationCollateral`
- **Discriminator:** `0x6cd1044815167685`
- **Args:**
  - `collateral_amount`: `u64`
- **Account variants:**
  - `8 accounts:` `owner`, `obligation`, `lending_market`, `deposit_reserve`, `reserve_destination_collateral`, `user_source_collateral`, `token_program`, `instruction_sysvar_account`

### `DepositReserveLiquidity`
- **Discriminator:** `0xa9c91e7e06cd6644`
- **Args:**
  - `liquidity_amount`: `u64`
- **Account variants:**
  - `12 accounts:` `owner`, `reserve`, `lending_market`, `lending_market_authority`, `reserve_liquidity_mint`, `reserve_liquidity_supply`, `reserve_collateral_mint`, `user_source_liquidity`, `user_destination_collateral`, `collateral_token_program`, `liquidity_token_program`, `instruction_sysvar_account`

### `DepositReserveLiquidityAndObligationCollateral`
- **Discriminator:** `0x81c70402de271a2e`
- **Args:**
  - `liquidity_amount`: `u64`
- **Account variants:**
  - `14 accounts:` `owner`, `obligation`, `lending_market`, `lending_market_authority`, `reserve`, `reserve_liquidity_mint`, `reserve_liquidity_supply`, `reserve_collateral_mint`, `reserve_destination_deposit_collateral`, `user_source_liquidity`, `placeholder_user_destination_collateral`, `collateral_token_program`, `liquidity_token_program`, `instruction_sysvar_account`

### `FlashBorrowReserveLiquidity`
- **Discriminator:** `0x87e734a70734d4c1`
- **Args:**
  - `liquidity_amount`: `u64`
- **Account variants:**
  - `12 accounts:` `user_transfer_authority`, `lending_market_authority`, `lending_market`, `reserve`, `reserve_liquidity_mint`, `reserve_source_liquidity`, `user_destination_liquidity`, `reserve_liquidity_fee_receiver`, `referrer_token_state`, `referrer_account`, `sysvar_info`, `token_program`

### `FlashRepayReserveLiquidity`
- **Discriminator:** `0xb97500cb60f5b4ba`
- **Args:**
  - `liquidity_amount`: `u64`
  - `borrow_instruction_index`: `u8`
- **Account variants:**
  - `12 accounts:` `user_transfer_authority`, `lending_market_authority`, `lending_market`, `reserve`, `reserve_liquidity_mint`, `reserve_destination_liquidity`, `user_source_liquidity`, `reserve_liquidity_fee_receiver`, `referrer_token_state`, `referrer_account`, `sysvar_info`, `token_program`

### `IdlMissingTypes`
- **Discriminator:** `0x8250269950d4b6fd`
- **Args:**
  - `reserve_farm_kind`: `ReserveFarmKind`
  - `asset_tier`: `AssetTier`
  - `fee_calculation`: `FeeCalculation`
  - `reserve_status`: `ReserveStatus`
  - `update_config_mode`: `UpdateConfigMode`
  - `update_lending_market_config_value`: `UpdateLendingMarketConfigValue`
  - `update_lending_market_config_mode`: `UpdateLendingMarketMode`
- **Account variants:**
  - `3 accounts:` `lending_market_owner`, `lending_market`, `reserve`

### `InitFarmsForReserve`
- **Discriminator:** `0xda063ee90121e852`
- **Args:**
  - `mode`: `u8`
- **Account variants:**
  - `10 accounts:` `lending_market_owner`, `lending_market`, `lending_market_authority`, `reserve`, `farms_program`, `farms_global_config`, `farm_state`, `farms_vault_authority`, `rent`, `system_program`

### `InitLendingMarket`
- **Discriminator:** `0x22a2740e65895eef`
- **Args:**
  - `quote_currency`: `[u8; 32]`
- **Account variants:**
  - `5 accounts:` `lending_market_owner`, `lending_market`, `lending_market_authority`, `system_program`, `rent`

### `InitObligation`
- **Discriminator:** `0xfb0ae74c1b0b9f60`
- **Args:**
  - `args`: `InitObligationArgs`
- **Account variants:**
  - `9 accounts:` `obligation_owner`, `fee_payer`, `obligation`, `lending_market`, `seed1_account`, `seed2_account`, `owner_user_metadata`, `rent`, `system_program`

### `InitObligationFarmsForReserve`
- **Discriminator:** `0x883f0fbad398a8a4`
- **Args:**
  - `mode`: `u8`
- **Account variants:**
  - `11 accounts:` `payer`, `owner`, `obligation`, `lending_market_authority`, `reserve`, `reserve_farm_state`, `obligation_farm`, `lending_market`, `farms_program`, `rent`, `system_program`

### `InitReferrerStateAndShortUrl`
- **Discriminator:** `0xa513197f64371f5a`
- **Args:**
  - `short_url`: `String`
- **Account variants:**
  - `6 accounts:` `referrer`, `referrer_state`, `referrer_short_url`, `referrer_user_metadata`, `rent`, `system_program`

### `InitReferrerTokenState`
- **Discriminator:** `0x742d42943a0dda73`
- **Args:** (none)
- **Account variants:**
  - `7 accounts:` `payer`, `lending_market`, `reserve`, `referrer`, `referrer_token_state`, `rent`, `system_program`

### `InitReserve`
- **Discriminator:** `0x8af547e19904032b`
- **Args:** (none)
- **Account variants:**
  - `13 accounts:` `lending_market_owner`, `lending_market`, `lending_market_authority`, `reserve`, `reserve_liquidity_mint`, `reserve_liquidity_supply`, `fee_receiver`, `reserve_collateral_mint`, `reserve_collateral_supply`, `rent`, `liquidity_token_program`, `collateral_token_program`, `system_program`

### `InitUserMetadata`
- **Discriminator:** `0x75a9b045c5170fa2`
- **Args:**
  - `user_lookup_table`: `Pubkey`
- **Account variants:**
  - `6 accounts:` `owner`, `fee_payer`, `user_metadata`, `referrer_user_metadata`, `rent`, `system_program`

### `LiquidateObligationAndRedeemReserveCollateral`
- **Discriminator:** `0xb1479abce2854a37`
- **Args:**
  - `liquidity_amount`: `u64`
  - `min_acceptable_received_liquidity_amount`: `u64`
  - `max_allowed_ltv_override_percent`: `u64`
- **Account variants:**
  - `20 accounts:` `liquidator`, `obligation`, `lending_market`, `lending_market_authority`, `repay_reserve`, `repay_reserve_liquidity_mint`, `repay_reserve_liquidity_supply`, `withdraw_reserve`, `withdraw_reserve_liquidity_mint`, `withdraw_reserve_collateral_mint`, `withdraw_reserve_collateral_supply`, `withdraw_reserve_liquidity_supply`, `withdraw_reserve_liquidity_fee_receiver`, `user_source_liquidity`, `user_destination_collateral`, `user_destination_liquidity`, `collateral_token_program`, `repay_liquidity_token_program`, `withdraw_liquidity_token_program`, `instruction_sysvar_account`

### `MarkObligationForDeleveraging`
- **Discriminator:** `0xa423b6130074f37f`
- **Args:**
  - `autodeleverage_target_ltv_pct`: `u8`
- **Account variants:**
  - `3 accounts:` `risk_council`, `obligation`, `lending_market`

### `RedeemFees`
- **Discriminator:** `0xd727b429ad2ef8dc`
- **Args:** (none)
- **Account variants:**
  - `7 accounts:` `reserve`, `reserve_liquidity_mint`, `reserve_liquidity_fee_receiver`, `reserve_supply_liquidity`, `lending_market`, `lending_market_authority`, `token_program`

### `RedeemReserveCollateral`
- **Discriminator:** `0xea75b57db98edc1d`
- **Args:**
  - `collateral_amount`: `u64`
- **Account variants:**
  - `12 accounts:` `owner`, `lending_market`, `reserve`, `lending_market_authority`, `reserve_liquidity_mint`, `reserve_collateral_mint`, `reserve_liquidity_supply`, `user_source_collateral`, `user_destination_liquidity`, `collateral_token_program`, `liquidity_token_program`, `instruction_sysvar_account`

### `RefreshObligation`
- **Discriminator:** `0x218493e497c04859`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `lending_market`, `obligation`

### `RefreshObligationFarmsForReserve`
- **Discriminator:** `0x8c90fd150a4af803`
- **Args:**
  - `mode`: `u8`
- **Account variants:**
  - `10 accounts:` `crank`, `obligation`, `lending_market_authority`, `reserve`, `reserve_farm_state`, `obligation_farm_user_state`, `lending_market`, `farms_program`, `rent`, `system_program`

### `RefreshReserve`
- **Discriminator:** `0x02da8aeb4fc91966`
- **Args:** (none)
- **Account variants:**
  - `6 accounts:` `reserve`, `lending_market`, `pyth_oracle`, `switchboard_price_oracle`, `switchboard_twap_oracle`, `scope_prices`

### `RefreshReservesBatch`
- **Discriminator:** `0x906e1a67a2ccfc93`
- **Args:**
  - `skip_price_updates`: `bool`
- **Account variants:**
  - `0 accounts:` (none)

### `RepayAndWithdrawAndRedeem`
- **Discriminator:** `0x0236980394606dda`
- **Args:**
  - `repay_amount`: `u64`
  - `withdraw_collateral_amount`: `u64`
- **Account variants:**
  - `2 accounts:` `repay_accounts`, `withdraw_accounts`

### `RepayObligationLiquidity`
- **Discriminator:** `0x91b20de14cf09348`
- **Args:**
  - `liquidity_amount`: `u64`
- **Account variants:**
  - `9 accounts:` `owner`, `obligation`, `lending_market`, `repay_reserve`, `reserve_liquidity_mint`, `reserve_destination_liquidity`, `user_source_liquidity`, `token_program`, `instruction_sysvar_account`

### `RequestElevationGroup`
- **Discriminator:** `0x2477fb8122f00793`
- **Args:**
  - `elevation_group`: `u8`
- **Account variants:**
  - `3 accounts:` `owner`, `obligation`, `lending_market`

### `SocializeLoss`
- **Discriminator:** `0xf54b5b00ec611303`
- **Args:**
  - `liquidity_amount`: `u64`
- **Account variants:**
  - `5 accounts:` `risk_council`, `obligation`, `lending_market`, `reserve`, `instruction_sysvar_account`

### `UpdateLendingMarket`
- **Discriminator:** `0xd19d35d261b41f2d`
- **Args:**
  - `mode`: `u64`
  - `value`: `[u8; 72]`
- **Account variants:**
  - `2 accounts:` `lending_market_owner`, `lending_market`

### `UpdateLendingMarketOwner`
- **Discriminator:** `0x76e00a3ec4e6b859`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `lending_market_owner_cached`, `lending_market`

### `UpdateReserveConfig`
- **Discriminator:** `0x3d9464468f6b110d`
- **Args:**
  - `mode`: `u64`
  - `value`: `Vec<u8>`
  - `skip_validation`: `bool`
- **Account variants:**
  - `3 accounts:` `lending_market_owner`, `lending_market`, `reserve`

### `WithdrawObligationCollateral`
- **Discriminator:** `0x2574cd67f3c05cc6`
- **Args:**
  - `collateral_amount`: `u64`
- **Account variants:**
  - `9 accounts:` `owner`, `obligation`, `lending_market`, `lending_market_authority`, `withdraw_reserve`, `reserve_source_collateral`, `user_destination_collateral`, `token_program`, `instruction_sysvar_account`

### `WithdrawObligationCollateralAndRedeemReserveCollateral`
- **Discriminator:** `0x4b5d5ddc2296dac4`
- **Args:**
  - `collateral_amount`: `u64`
- **Account variants:**
  - `14 accounts:` `owner`, `obligation`, `lending_market`, `lending_market_authority`, `withdraw_reserve`, `reserve_liquidity_mint`, `reserve_source_collateral`, `reserve_collateral_mint`, `reserve_liquidity_supply`, `user_destination_liquidity`, `placeholder_user_destination_collateral`, `collateral_token_program`, `liquidity_token_program`, `instruction_sysvar_account`

### `WithdrawProtocolFee`
- **Discriminator:** `0x9ec99ebd215da267`
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `8 accounts:` `lending_market_owner`, `lending_market`, `reserve`, `reserve_liquidity_mint`, `lending_market_authority`, `fee_vault`, `lending_market_owner_ata`, `token_program`

### `WithdrawReferrerFees`
- **Discriminator:** `0xab7679c9e98c17e4`
- **Args:** (none)
- **Account variants:**
  - `9 accounts:` `referrer`, `referrer_token_state`, `reserve`, `reserve_liquidity_mint`, `reserve_supply_liquidity`, `referrer_token_account`, `lending_market`, `lending_market_authority`, `token_program`

## Shared types

### `AssetTier` (enum)
- `Regular`
- `IsolatedCollateral`
- `IsolatedDebt`

### `BigFractionBytes`
- `value`: `[u64; 4]`
- `padding`: `[u64; 2]`

### `BorrowRateCurve`
- `points`: `[CurvePoint; 11]`

### `CurvePoint`
- `utilization_rate_bps`: `u32`
- `borrow_rate_bps`: `u32`

### `ElevationGroup`
- `max_liquidation_bonus_bps`: `u16`
- `id`: `u8`
- `ltv_pct`: `u8`
- `liquidation_threshold_pct`: `u8`
- `allow_new_loans`: `u8`
- `max_reserves_as_collateral`: `u8`
- `padding0`: `u8`
- `debt_reserve`: `Pubkey`
- `padding1`: `[u64; 4]`

### `FeeCalculation` (enum)
- `Exclusive`
- `Inclusive`

### `InitObligationArgs`
- `tag`: `u8`
- `id`: `u8`

### `LastUpdate`
- `slot`: `u64`
- `stale`: `u8`
- `price_status`: `u8`
- `placeholder`: `[u8; 6]`

### `ObligationCollateral`
- `deposit_reserve`: `Pubkey`
- `deposited_amount`: `u64`
- `market_value_sf`: `u128`
- `borrowed_amount_against_this_collateral_in_elevation_group`: `u64`
- `padding`: `[u64; 9]`

### `ObligationLiquidity`
- `borrow_reserve`: `Pubkey`
- `cumulative_borrow_rate_bsf`: `BigFractionBytes`
- `padding`: `u64`
- `borrowed_amount_sf`: `u128`
- `market_value_sf`: `u128`
- `borrow_factor_adjusted_market_value_sf`: `u128`
- `borrowed_amount_outside_elevation_groups`: `u64`
- `padding2`: `[u64; 7]`

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
- `deleveraging_threshold_slots_per_bps`: `u64`
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
- `reserved1`: `[u8; 2]`
- `borrow_limit_outside_elevation_group`: `u64`
- `borrow_limit_against_this_collateral_in_elevation_group`: `[u64; 32]`

### `ReserveFarmKind` (enum)
- `Collateral`
- `Debt`

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
- `deposit_limit_crossed_slot`: `u64`
- `borrow_limit_crossed_slot`: `u64`
- `cumulative_borrow_rate_bsf`: `BigFractionBytes`
- `accumulated_protocol_fees_sf`: `u128`
- `accumulated_referrer_fees_sf`: `u128`
- `pending_referrer_fees_sf`: `u128`
- `absolute_referral_rate_sf`: `u128`
- `token_program`: `Pubkey`
- `padding2`: `[u64; 51]`
- `padding3`: `[u128; 32]`

### `ReserveStatus` (enum)
- `Active`
- `Obsolete`
- `Hidden`

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

### `UpdateConfigMode` (enum)
- `UpdateLoanToValuePct`
- `UpdateMaxLiquidationBonusBps`
- `UpdateLiquidationThresholdPct`
- `UpdateProtocolLiquidationFee`
- `UpdateProtocolTakeRate`
- `UpdateFeesBorrowFee`
- `UpdateFeesFlashLoanFee`
- `UpdateFeesReferralFeeBps`
- `UpdateDepositLimit`
- `UpdateBorrowLimit`
- `UpdateTokenInfoLowerHeuristic`
- `UpdateTokenInfoUpperHeuristic`
- `UpdateTokenInfoExpHeuristic`
- `UpdateTokenInfoTwapDivergence`
- `UpdateTokenInfoScopeTwap`
- `UpdateTokenInfoScopeChain`
- `UpdateTokenInfoName`
- `UpdateTokenInfoPriceMaxAge`
- `UpdateTokenInfoTwapMaxAge`
- `UpdateScopePriceFeed`
- `UpdatePythPrice`
- `UpdateSwitchboardFeed`
- `UpdateSwitchboardTwapFeed`
- `UpdateBorrowRateCurve`
- `UpdateEntireReserveConfig`
- `UpdateDebtWithdrawalCap`
- `UpdateDepositWithdrawalCap`
- `UpdateDebtWithdrawalCapCurrentTotal`
- `UpdateDepositWithdrawalCapCurrentTotal`
- `UpdateBadDebtLiquidationBonusBps`
- `UpdateMinLiquidationBonusBps`
- `DeleveragingMarginCallPeriod`
- `UpdateBorrowFactor`
- `UpdateAssetTier`
- `UpdateElevationGroup`
- `DeleveragingThresholdSlotsPerBps`
- `DeprecatedUpdateMultiplierSideBoost`
- `DeprecatedUpdateMultiplierTagBoost`
- `UpdateReserveStatus`
- `UpdateFarmCollateral`
- `UpdateFarmDebt`
- `UpdateDisableUsageAsCollateralOutsideEmode`
- `UpdateBlockBorrowingAboveUtilization`
- `UpdateBlockPriceUsage`
- `UpdateBorrowLimitOutsideElevationGroup`
- `UpdateBorrowLimitsInElevationGroupAgainstThisReserve`
- `UpdateHostFixedInterestRateBps`

### `UpdateLendingMarketConfigValue` (enum)
- `Bool(bool)`
- `U8(u8)`
- `U8Array([u8; 8])`
- `U16(u16)`
- `U64(u64)`
- `U128(u128)`
- `Pubkey(Pubkey)`
- `ElevationGroup(ElevationGroup)`
- `Name([u8; 32])`

### `UpdateLendingMarketMode` (enum)
- `UpdateOwner`
- `UpdateEmergencyMode`
- `UpdateLiquidationCloseFactor`
- `UpdateLiquidationMaxValue`
- `UpdateGlobalUnhealthyBorrow`
- `UpdateGlobalAllowedBorrow`
- `UpdateRiskCouncil`
- `UpdateMinFullLiquidationThreshold`
- `UpdateInsolvencyRiskLtv`
- `UpdateElevationGroup`
- `UpdateReferralFeeBps`
- `DeprecatedUpdateMultiplierPoints`
- `UpdatePriceRefreshTriggerToMaxAgePct`
- `UpdateAutodeleverageEnabled`
- `UpdateBorrowingDisabled`
- `UpdateMinNetValueObligationPostAction`
- `UpdateMinValueSkipPriorityLiqCheck`
- `UpdatePaddingFields`
- `UpdateName`

### `WithdrawalCaps`
- `config_capacity`: `i64`
- `current_total`: `i64`
- `last_interval_start_timestamp`: `u64`
- `config_interval_length_seconds`: `u64`
