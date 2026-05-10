# Marinade Finance

- **Crate:** `carbon-marinade-finance-decoder`
- **Program ID:** `MarBmsSgKXdrN1egZf5sqe1TMai9K1rChYNDJgjq7aD`
- **Decoder struct:** `MarinadeFinanceDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in instructions/)
- **Discriminator style:** anchor 8-byte (events use 16-byte event discriminator)

## Account types

### `State`
- **Fields:**
  - `msol_mint`: `Pubkey`
  - `admin_authority`: `Pubkey`
  - `operational_sol_account`: `Pubkey`
  - `treasury_msol_account`: `Pubkey`
  - `reserve_bump_seed`: `u8`
  - `msol_mint_authority_bump_seed`: `u8`
  - `rent_exempt_for_token_acc`: `u64`
  - `reward_fee`: `Fee`
  - `stake_system`: `StakeSystem`
  - `validator_system`: `ValidatorSystem`
  - `liq_pool`: `LiqPool`
  - `available_reserve_balance`: `u64`
  - `msol_supply`: `u64`
  - `msol_price`: `u64`
  - `circulating_ticket_count`: `u64`
  - `circulating_ticket_balance`: `u64`
  - `lent_from_reserve`: `u64`
  - `min_deposit`: `u64`
  - `min_withdraw`: `u64`
  - `staking_sol_cap`: `u64`
  - `emergency_cooling_down`: `u64`
  - `pause_authority`: `Pubkey`
  - `paused`: `bool`
  - `delayed_unstake_fee`: `FeeCents`
  - `withdraw_stake_account_fee`: `FeeCents`
  - `withdraw_stake_account_enabled`: `bool`
  - `last_stake_move_epoch`: `u64`
  - `stake_moved`: `u64`
  - `max_stake_moved_per_epoch`: `Fee`

### `TicketAccountData`
- **Fields:**
  - `state_address`: `Pubkey`
  - `beneficiary`: `Pubkey`
  - `lamports_amount`: `u64`
  - `created_epoch`: `u64`

## Instructions

### `AddLiquidity`
- **Discriminator:** `0xb59d59438fb63448`
- **Args:**
  - `lamports`: `u64`
- **Account variants:**
  - `9 accounts:` `state`, `lp_mint`, `lp_mint_authority`, `liq_pool_msol_leg`, `liq_pool_sol_leg_pda`, `transfer_from`, `mint_to`, `system_program`, `token_program`

### `AddLiquidityEvent`
- **Discriminator:** `0xe445a52e51cb9a1d1bb299ba2fc48c2d`
- **Args:**
  - `state`: `Pubkey`
  - `sol_owner`: `Pubkey`
  - `user_sol_balance`: `u64`
  - `user_lp_balance`: `u64`
  - `sol_leg_balance`: `u64`
  - `lp_supply`: `u64`
  - `sol_added_amount`: `u64`
  - `lp_minted`: `u64`
  - `total_virtual_staked_lamports`: `u64`
  - `msol_supply`: `u64`

### `AddValidator`
- **Discriminator:** `0xfa7135368d75d7b9`
- **Args:**
  - `score`: `u32`
- **Account variants:**
  - `9 accounts:` `state`, `manager_authority`, `validator_list`, `validator_vote`, `duplication_flag`, `rent_payer`, `clock`, `rent`, `system_program`

### `AddValidatorEvent`
- **Discriminator:** `0xe445a52e51cb9a1dbee7aaf40ee38142`
- **Args:**
  - `state`: `Pubkey`
  - `validator`: `Pubkey`
  - `index`: `u32`
  - `score`: `u32`

### `ChangeAuthority`
- **Discriminator:** `0x326a426863769158`
- **Args:**
  - `data`: `ChangeAuthorityData`
- **Account variants:**
  - `2 accounts:` `state`, `admin_authority`

### `ChangeAuthorityEvent`
- **Discriminator:** `0xe445a52e51cb9a1de46f2318bb4ee08a`
- **Args:**
  - `state`: `Pubkey`
  - `admin_change`: `Option<PubkeyValueChange>`
  - `validator_manager_change`: `Option<PubkeyValueChange>`
  - `operational_sol_account_change`: `Option<PubkeyValueChange>`
  - `treasury_msol_account_change`: `Option<PubkeyValueChange>`
  - `pause_authority_change`: `Option<PubkeyValueChange>`

### `Claim`
- **Discriminator:** `0x3ec6d6c1d59f6cd2`
- **Args:** (none)
- **Account variants:**
  - `6 accounts:` `state`, `reserve_pda`, `ticket_account`, `transfer_sol_to`, `clock`, `system_program`

### `ClaimEvent`
- **Discriminator:** `0xe445a52e51cb9a1d5d0f46aa308cd4db`
- **Args:**
  - `state`: `Pubkey`
  - `epoch`: `u64`
  - `ticket`: `Pubkey`
  - `beneficiary`: `Pubkey`
  - `circulating_ticket_balance`: `u64`
  - `circulating_ticket_count`: `u64`
  - `reserve_balance`: `u64`
  - `user_balance`: `u64`
  - `amount`: `u64`

### `ConfigLp`
- **Discriminator:** `0x0a18a8775630e111`
- **Args:**
  - `params`: `ConfigLpParams`
- **Account variants:**
  - `2 accounts:` `state`, `admin_authority`

### `ConfigLpEvent`
- **Discriminator:** `0xe445a52e51cb9a1d9fccc08a4491e094`
- **Args:**
  - `state`: `Pubkey`
  - `min_fee_change`: `Option<FeeValueChange>`
  - `max_fee_change`: `Option<FeeValueChange>`
  - `liquidity_target_change`: `Option<U64ValueChange>`
  - `treasury_cut_change`: `Option<FeeValueChange>`

### `ConfigMarinade`
- **Discriminator:** `0x43032272beb9113e`
- **Args:**
  - `params`: `ConfigMarinadeParams`
- **Account variants:**
  - `2 accounts:` `state`, `admin_authority`

### `ConfigMarinadeEvent`
- **Discriminator:** `0xe445a52e51cb9a1d9fa4f5725efd0309`
- **Args:**
  - `state`: `Pubkey`
  - `rewards_fee_change`: `Option<FeeValueChange>`
  - `slots_for_stake_delta_change`: `Option<U64ValueChange>`
  - `min_stake_change`: `Option<U64ValueChange>`
  - `min_deposit_change`: `Option<U64ValueChange>`
  - `min_withdraw_change`: `Option<U64ValueChange>`
  - `staking_sol_cap_change`: `Option<U64ValueChange>`
  - `liquidity_sol_cap_change`: `Option<U64ValueChange>`
  - `withdraw_stake_account_enabled_change`: `Option<BoolValueChange>`
  - `delayed_unstake_fee_change`: `Option<FeeCentsValueChange>`
  - `withdraw_stake_account_fee_change`: `Option<FeeCentsValueChange>`
  - `max_stake_moved_per_epoch_change`: `Option<FeeValueChange>`

### `ConfigValidatorSystem`
- **Discriminator:** `0x1b5a61d111730728`
- **Args:**
  - `extra_runs`: `u32`
- **Account variants:**
  - `2 accounts:` `state`, `manager_authority`

### `DeactivateStake`
- **Discriminator:** `0xa59ee561a8dcbbe1`
- **Args:**
  - `stake_index`: `u32`
  - `validator_index`: `u32`
- **Account variants:**
  - `14 accounts:` `state`, `reserve_pda`, `validator_list`, `stake_list`, `stake_account`, `stake_deposit_authority`, `split_stake_account`, `split_stake_rent_payer`, `clock`, `rent`, `epoch_schedule`, `stake_history`, `system_program`, `stake_program`

### `DeactivateStakeEvent`
- **Discriminator:** `0xe445a52e51cb9a1d0236b8da4eb5a375`
- **Args:**
  - `state`: `Pubkey`
  - `epoch`: `u64`
  - `stake_index`: `u32`
  - `stake_account`: `Pubkey`
  - `last_update_stake_delegation`: `u64`
  - `split_stake_account`: `Option<SplitStakeAccountInfo>`
  - `validator_index`: `u32`
  - `validator_vote`: `Pubkey`
  - `total_stake_target`: `u64`
  - `validator_stake_target`: `u64`
  - `total_active_balance`: `u64`
  - `delayed_unstake_cooling_down`: `u64`
  - `validator_active_balance`: `u64`
  - `total_unstake_delta`: `u64`
  - `unstaked_amount`: `u64`

### `Deposit`
- **Discriminator:** `0xf223c68952e1f2b6`
- **Args:**
  - `lamports`: `u64`
- **Account variants:**
  - `11 accounts:` `state`, `msol_mint`, `liq_pool_sol_leg_pda`, `liq_pool_msol_leg`, `liq_pool_msol_leg_authority`, `reserve_pda`, `transfer_from`, `mint_to`, `msol_mint_authority`, `system_program`, `token_program`

### `DepositEvent`
- **Discriminator:** `0xe445a52e51cb9a1d78f83d531f8e6b90`
- **Args:**
  - `state`: `Pubkey`
  - `sol_owner`: `Pubkey`
  - `user_sol_balance`: `u64`
  - `user_msol_balance`: `u64`
  - `sol_leg_balance`: `u64`
  - `msol_leg_balance`: `u64`
  - `reserve_balance`: `u64`
  - `sol_swapped`: `u64`
  - `msol_swapped`: `u64`
  - `sol_deposited`: `u64`
  - `msol_minted`: `u64`
  - `total_virtual_staked_lamports`: `u64`
  - `msol_supply`: `u64`

### `DepositStakeAccount`
- **Discriminator:** `0x6e827329a466023b`
- **Args:**
  - `validator_index`: `u32`
- **Account variants:**
  - `15 accounts:` `state`, `validator_list`, `stake_list`, `stake_account`, `stake_authority`, `duplication_flag`, `rent_payer`, `msol_mint`, `mint_to`, `msol_mint_authority`, `clock`, `rent`, `system_program`, `token_program`, `stake_program`

### `DepositStakeAccountEvent`
- **Discriminator:** `0xe445a52e51cb9a1de7cb76604b7446e4`
- **Args:**
  - `state`: `Pubkey`
  - `stake`: `Pubkey`
  - `delegated`: `u64`
  - `withdrawer`: `Pubkey`
  - `stake_index`: `u32`
  - `validator`: `Pubkey`
  - `validator_index`: `u32`
  - `validator_active_balance`: `u64`
  - `total_active_balance`: `u64`
  - `user_msol_balance`: `u64`
  - `msol_minted`: `u64`
  - `total_virtual_staked_lamports`: `u64`
  - `msol_supply`: `u64`

### `EmergencyPauseEvent`
- **Discriminator:** `0xe445a52e51cb9a1d9ff1c0e81dd03315`
- **Args:**
  - `state`: `Pubkey`

### `EmergencyUnstake`
- **Discriminator:** `0x7b45a8c3b7d5c7d6`
- **Args:**
  - `stake_index`: `u32`
  - `validator_index`: `u32`
- **Account variants:**
  - `8 accounts:` `state`, `validator_manager_authority`, `validator_list`, `stake_list`, `stake_account`, `stake_deposit_authority`, `clock`, `stake_program`

### `Initialize`
- **Discriminator:** `0xafaf6d1f0d989bed`
- **Args:**
  - `data`: `InitializeData`
- **Account variants:**
  - `10 accounts:` `state`, `reserve_pda`, `stake_list`, `validator_list`, `msol_mint`, `operational_sol_account`, `liq_pool`, `treasury_msol_account`, `clock`, `rent`

### `InitializeEvent`
- **Discriminator:** `0xe445a52e51cb9a1dceafa9d0f1d223dd`
- **Args:**
  - `state`: `Pubkey`
  - `params`: `InitializeData`
  - `stake_list`: `Pubkey`
  - `validator_list`: `Pubkey`
  - `msol_mint`: `Pubkey`
  - `operational_sol_account`: `Pubkey`
  - `lp_mint`: `Pubkey`
  - `lp_msol_leg`: `Pubkey`
  - `treasury_msol_account`: `Pubkey`

### `LiquidUnstake`
- **Discriminator:** `0x1e1e77f0bfe30c10`
- **Args:**
  - `msol_amount`: `u64`
- **Account variants:**
  - `10 accounts:` `state`, `msol_mint`, `liq_pool_sol_leg_pda`, `liq_pool_msol_leg`, `treasury_msol_account`, `get_msol_from`, `get_msol_from_authority`, `transfer_sol_to`, `system_program`, `token_program`

### `LiquidUnstakeEvent`
- **Discriminator:** `0xe445a52e51cb9a1dad05930f050ec274`
- **Args:**
  - `state`: `Pubkey`
  - `msol_owner`: `Pubkey`
  - `liq_pool_sol_balance`: `u64`
  - `liq_pool_msol_balance`: `u64`
  - `treasury_msol_balance`: `Option<u64>`
  - `user_msol_balance`: `u64`
  - `user_sol_balance`: `u64`
  - `msol_amount`: `u64`
  - `msol_fee`: `u64`
  - `treasury_msol_cut`: `u64`
  - `sol_amount`: `u64`
  - `lp_liquidity_target`: `u64`
  - `lp_max_fee`: `Fee`
  - `lp_min_fee`: `Fee`
  - `treasury_cut`: `Fee`

### `MergeStakes`
- **Discriminator:** `0xd8248de1f34e7ded`
- **Args:**
  - `destination_stake_index`: `u32`
  - `source_stake_index`: `u32`
  - `validator_index`: `u32`
- **Account variants:**
  - `11 accounts:` `state`, `stake_list`, `validator_list`, `destination_stake`, `source_stake`, `stake_deposit_authority`, `stake_withdraw_authority`, `operational_sol_account`, `clock`, `stake_history`, `stake_program`

### `MergeStakesEvent`
- **Discriminator:** `0xe445a52e51cb9a1d499c45e9200e9641`
- **Args:**
  - `state`: `Pubkey`
  - `epoch`: `u64`
  - `destination_stake_index`: `u32`
  - `destination_stake_account`: `Pubkey`
  - `last_update_destination_stake_delegation`: `u64`
  - `source_stake_index`: `u32`
  - `source_stake_account`: `Pubkey`
  - `last_update_source_stake_delegation`: `u64`
  - `validator_index`: `u32`
  - `validator_vote`: `Pubkey`
  - `extra_delegated`: `u64`
  - `returned_stake_rent`: `u64`
  - `validator_active_balance`: `u64`
  - `total_active_balance`: `u64`
  - `operational_sol_balance`: `u64`

### `OrderUnstake`
- **Discriminator:** `0x61a7906b75be8024`
- **Args:**
  - `msol_amount`: `u64`
- **Account variants:**
  - `8 accounts:` `state`, `msol_mint`, `burn_msol_from`, `burn_msol_authority`, `new_ticket_account`, `clock`, `rent`, `token_program`

### `OrderUnstakeEvent`
- **Discriminator:** `0xe445a52e51cb9a1de43f9bf984a08771`
- **Args:**
  - `state`: `Pubkey`
  - `ticket_epoch`: `u64`
  - `ticket`: `Pubkey`
  - `beneficiary`: `Pubkey`
  - `circulating_ticket_balance`: `u64`
  - `circulating_ticket_count`: `u64`
  - `user_msol_balance`: `u64`
  - `burned_msol_amount`: `u64`
  - `sol_amount`: `u64`
  - `fee_bp_cents`: `u32`
  - `total_virtual_staked_lamports`: `u64`
  - `msol_supply`: `u64`

### `PartialUnstake`
- **Discriminator:** `0x37f1cddd2d72cda3`
- **Args:**
  - `stake_index`: `u32`
  - `validator_index`: `u32`
  - `desired_unstake_amount`: `u64`
- **Account variants:**
  - `14 accounts:` `state`, `validator_manager_authority`, `validator_list`, `stake_list`, `stake_account`, `stake_deposit_authority`, `reserve_pda`, `split_stake_account`, `split_stake_rent_payer`, `clock`, `rent`, `stake_history`, `system_program`, `stake_program`

### `Pause`
- **Discriminator:** `0xd316ddfb4a79c12f`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `state`, `pause_authority`

### `ReallocStakeList`
- **Discriminator:** `0x0c247c1b806055c7`
- **Args:**
  - `capacity`: `u32`
- **Account variants:**
  - `5 accounts:` `state`, `admin_authority`, `stake_list`, `rent_funds`, `system_program`

### `ReallocStakeListEvent`
- **Discriminator:** `0xe445a52e51cb9a1dc18110f3b183f817`
- **Args:**
  - `state`: `Pubkey`
  - `count`: `u32`
  - `new_capacity`: `u32`

### `ReallocValidatorList`
- **Discriminator:** `0xd73bda855d8a3c7b`
- **Args:**
  - `capacity`: `u32`
- **Account variants:**
  - `5 accounts:` `state`, `admin_authority`, `validator_list`, `rent_funds`, `system_program`

### `ReallocValidatorListEvent`
- **Discriminator:** `0xe445a52e51cb9a1d46bff2a4389c820d`
- **Args:**
  - `state`: `Pubkey`
  - `count`: `u32`
  - `new_capacity`: `u32`

### `Redelegate`
- **Discriminator:** `0xd45233a0e4507423`
- **Args:**
  - `stake_index`: `u32`
  - `source_validator_index`: `u32`
  - `dest_validator_index`: `u32`
- **Account variants:**
  - `15 accounts:` `state`, `validator_list`, `stake_list`, `stake_account`, `stake_deposit_authority`, `reserve_pda`, `split_stake_account`, `split_stake_rent_payer`, `dest_validator_account`, `redelegate_stake_account`, `clock`, `stake_history`, `stake_config`, `system_program`, `stake_program`

### `RedelegateEvent`
- **Discriminator:** `0xe445a52e51cb9a1df14b87adccd74843`
- **Args:**
  - `state`: `Pubkey`
  - `epoch`: `u64`
  - `stake_index`: `u32`
  - `stake_account`: `Pubkey`
  - `last_update_delegation`: `u64`
  - `source_validator_index`: `u32`
  - `source_validator_vote`: `Pubkey`
  - `source_validator_score`: `u32`
  - `source_validator_balance`: `u64`
  - `source_validator_stake_target`: `u64`
  - `dest_validator_index`: `u32`
  - `dest_validator_vote`: `Pubkey`
  - `dest_validator_score`: `u32`
  - `dest_validator_balance`: `u64`
  - `dest_validator_stake_target`: `u64`
  - `redelegate_amount`: `u64`
  - `split_stake_account`: `Option<SplitStakeAccountInfo>`
  - `redelegate_stake_index`: `u32`
  - `redelegate_stake_account`: `Pubkey`

### `RemoveLiquidity`
- **Discriminator:** `0x5055d14818ceb16c`
- **Args:**
  - `tokens`: `u64`
- **Account variants:**
  - `11 accounts:` `state`, `lp_mint`, `burn_from`, `burn_from_authority`, `transfer_sol_to`, `transfer_msol_to`, `liq_pool_sol_leg_pda`, `liq_pool_msol_leg`, `liq_pool_msol_leg_authority`, `system_program`, `token_program`

### `RemoveLiquidityEvent`
- **Discriminator:** `0xe445a52e51cb9a1d8dc7b67b9f5ed766`
- **Args:**
  - `state`: `Pubkey`
  - `sol_leg_balance`: `u64`
  - `msol_leg_balance`: `u64`
  - `user_lp_balance`: `u64`
  - `user_sol_balance`: `u64`
  - `user_msol_balance`: `u64`
  - `lp_mint_supply`: `u64`
  - `lp_burned`: `u64`
  - `sol_out_amount`: `u64`
  - `msol_out_amount`: `u64`

### `RemoveValidator`
- **Discriminator:** `0x1960d39ba10ea8bc`
- **Args:**
  - `index`: `u32`
  - `validator_vote`: `Pubkey`
- **Account variants:**
  - `5 accounts:` `state`, `manager_authority`, `validator_list`, `duplication_flag`, `operational_sol_account`

### `RemoveValidatorEvent`
- **Discriminator:** `0xe445a52e51cb9a1d43a4bec09c9ca8d2`
- **Args:**
  - `state`: `Pubkey`
  - `validator`: `Pubkey`
  - `index`: `u32`
  - `operational_sol_balance`: `u64`

### `Resume`
- **Discriminator:** `0x01a633aa7f208dce`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `state`, `pause_authority`

### `ResumeEvent`
- **Discriminator:** `0xe445a52e51cb9a1d6175b77375e008e5`
- **Args:**
  - `state`: `Pubkey`

### `SetValidatorScore`
- **Discriminator:** `0x6529ce21d86f194e`
- **Args:**
  - `index`: `u32`
  - `validator_vote`: `Pubkey`
  - `score`: `u32`
- **Account variants:**
  - `3 accounts:` `state`, `manager_authority`, `validator_list`

### `SetValidatorScoreEvent`
- **Discriminator:** `0xe445a52e51cb9a1d3a35edb2ee99559c`
- **Args:**
  - `state`: `Pubkey`
  - `validator`: `Pubkey`
  - `index`: `u32`
  - `score_change`: `U32ValueChange`

### `StakeReserve`
- **Discriminator:** `0x57d917b3cd197181`
- **Args:**
  - `validator_index`: `u32`
- **Account variants:**
  - `15 accounts:` `state`, `validator_list`, `stake_list`, `validator_vote`, `reserve_pda`, `stake_account`, `stake_deposit_authority`, `rent_payer`, `clock`, `epoch_schedule`, `rent`, `stake_history`, `stake_config`, `system_program`, `stake_program`

### `StakeReserveEvent`
- **Discriminator:** `0xe445a52e51cb9a1d707595b94d77be6a`
- **Args:**
  - `state`: `Pubkey`
  - `epoch`: `u64`
  - `stake_index`: `u32`
  - `stake_account`: `Pubkey`
  - `validator_index`: `u32`
  - `validator_vote`: `Pubkey`
  - `total_stake_target`: `u64`
  - `validator_stake_target`: `u64`
  - `reserve_balance`: `u64`
  - `total_active_balance`: `u64`
  - `validator_active_balance`: `u64`
  - `total_stake_delta`: `u64`
  - `amount`: `u64`

### `UpdateActive`
- **Discriminator:** `0x0443514088f55d98`
- **Args:**
  - `stake_index`: `u32`
  - `validator_index`: `u32`
- **Account variants:**
  - `2 accounts:` `common`, `validator_list`

### `UpdateActiveEvent`
- **Discriminator:** `0xe445a52e51cb9a1dfb12804bd050ae8c`
- **Args:**
  - `state`: `Pubkey`
  - `epoch`: `u64`
  - `stake_index`: `u32`
  - `stake_account`: `Pubkey`
  - `validator_index`: `u32`
  - `validator_vote`: `Pubkey`
  - `delegation_change`: `U64ValueChange`
  - `delegation_growth_msol_fees`: `Option<u64>`
  - `extra_lamports`: `u64`
  - `extra_msol_fees`: `Option<u64>`
  - `validator_active_balance`: `u64`
  - `total_active_balance`: `u64`
  - `msol_price_change`: `U64ValueChange`
  - `reward_fee_used`: `Fee`
  - `total_virtual_staked_lamports`: `u64`
  - `msol_supply`: `u64`

### `UpdateDeactivated`
- **Discriminator:** `0x10e883739c64ef32`
- **Args:**
  - `stake_index`: `u32`
- **Account variants:**
  - `3 accounts:` `common`, `operational_sol_account`, `system_program`

### `UpdateDeactivatedEvent`
- **Discriminator:** `0xe445a52e51cb9a1dfc9fb193b671ba5e`
- **Args:**
  - `state`: `Pubkey`
  - `epoch`: `u64`
  - `stake_index`: `u32`
  - `stake_account`: `Pubkey`
  - `balance_without_rent_exempt`: `u64`
  - `last_update_delegated_lamports`: `u64`
  - `msol_fees`: `Option<u64>`
  - `msol_price_change`: `U64ValueChange`
  - `reward_fee_used`: `Fee`
  - `operational_sol_balance`: `u64`
  - `total_virtual_staked_lamports`: `u64`
  - `msol_supply`: `u64`

### `WithdrawStakeAccount`
- **Discriminator:** `0xd355b841b7b1e9d9`
- **Args:**
  - `stake_index`: `u32`
  - `validator_index`: `u32`
  - `msol_amount`: `u64`
  - `beneficiary`: `Pubkey`
- **Account variants:**
  - `16 accounts:` `state`, `msol_mint`, `burn_msol_from`, `burn_msol_authority`, `treasury_msol_account`, `validator_list`, `stake_list`, `stake_withdraw_authority`, `stake_deposit_authority`, `stake_account`, `split_stake_account`, `split_stake_rent_payer`, `clock`, `system_program`, `token_program`, `stake_program`

### `WithdrawStakeAccountEvent`
- **Discriminator:** `0xe445a52e51cb9a1d83ee27301e1ba51c`
- **Args:**
  - `state`: `Pubkey`
  - `epoch`: `u64`
  - `stake`: `Pubkey`
  - `last_update_stake_delegation`: `u64`
  - `stake_index`: `u32`
  - `validator`: `Pubkey`
  - `validator_index`: `u32`
  - `user_msol_balance`: `u64`
  - `user_msol_auth`: `Pubkey`
  - `msol_burned`: `u64`
  - `msol_fees`: `u64`
  - `split_stake`: `Pubkey`
  - `beneficiary`: `Pubkey`
  - `split_lamports`: `u64`
  - `fee_bp_cents`: `u32`
  - `total_virtual_staked_lamports`: `u64`
  - `msol_supply`: `u64`

## Shared types

### `BoolValueChange`
- `old`: `bool`
- `new`: `bool`

### `ChangeAuthorityData`
- `admin`: `Option<Pubkey>`
- `validator_manager`: `Option<Pubkey>`
- `operational_sol_account`: `Option<Pubkey>`
- `treasury_msol_account`: `Option<Pubkey>`
- `pause_authority`: `Option<Pubkey>`

### `ConfigLpParams`
- `min_fee`: `Option<Fee>`
- `max_fee`: `Option<Fee>`
- `liquidity_target`: `Option<u64>`
- `treasury_cut`: `Option<Fee>`

### `ConfigMarinadeParams`
- `rewards_fee`: `Option<Fee>`
- `slots_for_stake_delta`: `Option<u64>`
- `min_stake`: `Option<u64>`
- `min_deposit`: `Option<u64>`
- `min_withdraw`: `Option<u64>`
- `staking_sol_cap`: `Option<u64>`
- `liquidity_sol_cap`: `Option<u64>`
- `withdraw_stake_account_enabled`: `Option<bool>`
- `delayed_unstake_fee`: `Option<FeeCents>`
- `withdraw_stake_account_fee`: `Option<FeeCents>`
- `max_stake_moved_per_epoch`: `Option<Fee>`

### `Fee`
- `basis_points`: `u32`

### `FeeCents`
- `bp_cents`: `u32`

### `FeeCentsValueChange`
- `old`: `FeeCents`
- `new`: `FeeCents`

### `FeeValueChange`
- `old`: `Fee`
- `new`: `Fee`

### `InitializeData`
- `admin_authority`: `Pubkey`
- `validator_manager_authority`: `Pubkey`
- `min_stake`: `u64`
- `rewards_fee`: `Fee`
- `liq_pool`: `LiqPoolInitializeData`
- `additional_stake_record_space`: `u32`
- `additional_validator_record_space`: `u32`
- `slots_for_stake_delta`: `u64`
- `pause_authority`: `Pubkey`

### `LiqPool`
- `lp_mint`: `Pubkey`
- `lp_mint_authority_bump_seed`: `u8`
- `sol_leg_bump_seed`: `u8`
- `msol_leg_authority_bump_seed`: `u8`
- `msol_leg`: `Pubkey`
- `lp_liquidity_target`: `u64`
- `lp_max_fee`: `Fee`
- `lp_min_fee`: `Fee`
- `treasury_cut`: `Fee`
- `lp_supply`: `u64`
- `lent_from_sol_leg`: `u64`
- `liquidity_sol_cap`: `u64`

### `LiqPoolInitializeData`
- `lp_liquidity_target`: `u64`
- `lp_max_fee`: `Fee`
- `lp_min_fee`: `Fee`
- `lp_treasury_cut`: `Fee`

### `List`
- `account`: `Pubkey`
- `item_size`: `u32`
- `count`: `u32`
- `reserved1`: `Pubkey`
- `reserved2`: `u32`

### `PubkeyValueChange`
- `old`: `Pubkey`
- `new`: `Pubkey`

### `SplitStakeAccountInfo`
- `account`: `Pubkey`
- `index`: `u32`

### `StakeList`
- (empty struct)

### `StakeRecord`
- `stake_account`: `Pubkey`
- `last_update_delegated_lamports`: `u64`
- `last_update_epoch`: `u64`
- `is_emergency_unstaking`: `u8`

### `StakeSystem`
- `stake_list`: `List`
- `delayed_unstake_cooling_down`: `u64`
- `stake_deposit_bump_seed`: `u8`
- `stake_withdraw_bump_seed`: `u8`
- `slots_for_stake_delta`: `u64`
- `last_stake_delta_epoch`: `u64`
- `min_stake`: `u64`
- `extra_stake_delta_runs`: `u32`

### `U32ValueChange`
- `old`: `u32`
- `new`: `u32`

### `U64ValueChange`
- `old`: `u64`
- `new`: `u64`

### `ValidatorList`
- (empty struct)

### `ValidatorRecord`
- `validator_account`: `Pubkey`
- `active_balance`: `u64`
- `score`: `u32`
- `last_stake_delta_epoch`: `u64`
- `duplication_flag_bump_seed`: `u8`

### `ValidatorSystem`
- `validator_list`: `List`
- `manager_authority`: `Pubkey`
- `total_validator_score`: `u32`
- `total_active_balance`: `u64`
- `auto_add_validator_enabled`: `u8`
