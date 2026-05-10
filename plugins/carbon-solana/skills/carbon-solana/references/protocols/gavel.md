# Gavel

- **Crate:** `carbon-gavel-decoder`
- **Program ID:** `srAMMzfVHVAtgSJc8iH6CfKzuWuUTzLHVCE81QU1rgi`
- **Decoder struct:** `GavelDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in types/)
- **Discriminator style:** raw byte/short

## Account types

### `LpPositionAccount`
- **Fields:**
  - `authority`: `Pubkey`
  - `pool`: `Pubkey`
  - `status`: `u64`
  - `lp_position`: `LpPosition`

### `PoolAccount`
- **Fields:**
  - `pool_header`: `PoolHeader`
  - `amm`: `Amm`

## Instructions

### `AddLiquidity`
- **Discriminator:** `0x01`
- **Args:**
  - `params`: `AddLiquidityIxParams`
- **Account variants:**
  - `10 accounts:` `plasma_program`, `log_authority`, `pool`, `trader`, `lp_position`, `base_account`, `quote_account`, `base_vault`, `quote_vault`, `token_program`

### `InitializeLpPosition`
- **Discriminator:** `0x05`
- **Args:** (none)
- **Account variants:**
  - `7 accounts:` `plasma_program`, `log_authority`, `pool`, `payer`, `lp_position_owner`, `lp_position`, `system_program`

### `InitializePool`
- **Discriminator:** `0x06`
- **Args:**
  - `params`: `InitializePoolIxParams`
- **Account variants:**
  - `10 accounts:` `plasma_program`, `log_authority`, `pool`, `pool_creator`, `base_mint`, `quote_mint`, `base_vault`, `quote_vault`, `system_program`, `token_program`

### `Log`
- **Discriminator:** `0x08`
- **Args:** (none)
- **Account variants:**
  - `1 accounts:` `log_authority`

### `RemoveLiquidity`
- **Discriminator:** `0x02`
- **Args:**
  - `params`: `RemoveLiquidityIxParams`
- **Account variants:**
  - `10 accounts:` `plasma_program`, `log_authority`, `pool`, `trader`, `lp_position`, `base_account`, `quote_account`, `base_vault`, `quote_vault`, `token_program`

### `RenounceLiquidity`
- **Discriminator:** `0x03`
- **Args:**
  - `params`: `RenounceLiquidityIxParams`
- **Account variants:**
  - `5 accounts:` `plasma_program`, `log_authority`, `pool`, `trader`, `lp_position`

### `Swap`
- **Discriminator:** `0x00`
- **Args:**
  - `params`: `SwapIxParams`
- **Account variants:**
  - `9 accounts:` `plasma_program`, `log_authority`, `pool`, `trader`, `base_account`, `quote_account`, `base_vault`, `quote_vault`, `token_program`

### `TransferLiquidity`
- **Discriminator:** `0x09`
- **Args:** (none)
- **Account variants:**
  - `6 accounts:` `plasma_program`, `log_authority`, `pool`, `trader`, `src_lp_position`, `dst_lp_position`

### `WithdrawLpFees`
- **Discriminator:** `0x04`
- **Args:** (none)
- **Account variants:**
  - `9 accounts:` `plasma_program`, `log_authority`, `pool`, `trader`, `lp_position_owner`, `lp_position`, `quote_account`, `quote_vault`, `token_program`

### `WithdrawProtocolFees`
- **Discriminator:** `0x07`
- **Args:** (none)
- **Account variants:**
  - `7 accounts:` `plasma_program`, `log_authority`, `pool`, `protocol_fee_recipient`, `quote_account`, `quote_vault`, `token_program`

## CPI events

### `AddLiquidityEvent`
- **Source:** `types/add_liquidity_event.rs`
- **Fields:**
  - `pool_total_lp_shares`: `u64`
  - `pool_total_base_liquidity`: `u64`
  - `pool_total_quote_liquitidy`: `u64`
  - `snapshot_base_liquidity`: `u64`
  - `snapshot_quote_liquidity`: `u64`
  - `user_lp_shares_received`: `u64`
  - `user_lp_shares_available`: `u64`
  - `user_lp_shares_locked`: `u64`
  - `user_lp_shares_unlocked_for_withdrawal`: `u64`
  - `user_base_deposited`: `u64`
  - `user_quote_deposited`: `u64`
  - `user_total_withdrawable_base`: `u64`
  - `user_total_withdrawable_quote`: `u64`

### `InitializeLpPositionEvent`
- **Source:** `types/initialize_lp_position_event.rs`
- **Fields:**
  - `owner`: `Pubkey`

### `InitializePoolEvent`
- **Source:** `types/initialize_pool_event.rs`
- **Fields:**
  - `lp_fee_in_bps`: `u64`
  - `protocol_fee_in_pct`: `u64`
  - `fee_recipient_params`: `[ProtocolFeeRecipientParams; 3]`

### `RemoveLiquidityEvent`
- **Source:** `types/remove_liquidity_event.rs`
- **Fields:**
  - `pool_total_lp_shares`: `u64`
  - `pool_total_base_liquidity`: `u64`
  - `pool_total_quote_liquitidy`: `u64`
  - `snapshot_base_liquidity`: `u64`
  - `snapshot_quote_liquidity`: `u64`
  - `user_lp_shares_burned`: `u64`
  - `user_lp_shares_available`: `u64`
  - `user_lp_shares_locked`: `u64`
  - `user_lp_shares_unlocked_for_withdrawal`: `u64`
  - `user_base_withdrawn`: `u64`
  - `user_quote_withdrawn`: `u64`
  - `user_total_withdrawable_base`: `u64`
  - `user_total_withdrawable_quote`: `u64`

### `RenounceLiquidityEvent`
- **Source:** `types/renounce_liquidity_event.rs`
- **Fields:**
  - `allow_fee_withdrawal`: `bool`

### `SwapEvent`
- **Source:** `types/swap_event.rs`
- **Fields:**
  - `swap_sequence_number`: `u64`
  - `pre_base_liquidity`: `u64`
  - `pre_quote_liquidity`: `u64`
  - `post_base_liquidity`: `u64`
  - `post_quote_liquidity`: `u64`
  - `snapshot_base_liquidity`: `u64`
  - `snapshot_quote_liquidity`: `u64`
  - `swap_result`: `SwapResult`

### `WithdrawLpFeesEvent`
- **Source:** `types/withdraw_lp_fees_event.rs`
- **Fields:**
  - `fees_withdrawn`: `u64`

### `WithdrawProtocolFeesEvent`
- **Source:** `types/withdraw_protocol_fees_event.rs`
- **Fields:**
  - `protocol_fee_recipient`: `Pubkey`
  - `fees_withdrawn`: `u64`

## Shared types

### `AddLiquidityIxParams`
- `desired_base_amount_in`: `u64`
- `desired_quote_amount_in`: `u64`
- `initial_lp_shares`: `Option<u64>`

### `Amm`
- `fee_in_bps`: `u32`
- `protocol_allocation_in_pct`: `u32`
- `lp_vesting_window`: `u64`
- `reward_factor`: `u128`
- `total_lp_shares`: `u64`
- `slot_snapshot`: `u64`
- `base_reserves_snapshot`: `u64`
- `quote_reserves_snapshot`: `u64`
- `base_reserves`: `u64`
- `quote_reserves`: `u64`
- `cumulative_quote_lp_fees`: `u64`
- `cumulative_quote_protocol_fees`: `u64`

### `InitializePoolIxParams`
- `lp_fee_in_bps`: `u64`
- `protocol_lp_fee_allocation_in_pct`: `u64`
- `fee_recipients_params`: `[ProtocolFeeRecipientParams; 3]`
- `num_slots_to_vest_lp_shares`: `Option<u64>`

### `LpPosition`
- `reward_factor_snapshot`: `u128`
- `lp_shares`: `u64`
- `withdrawable_lp_shares`: `u64`
- `uncollected_fees`: `u64`
- `collected_fees`: `u64`
- `pending_shares_to_vest`: `PendingSharesToVest`

### `PendingSharesToVest`
- `deposit_slot`: `u64`
- `lp_shares_to_vest`: `u64`

### `PlasmaEvent`
- enum variants:
  - `Swap { header: PlasmaEventHeader, event: SwapEvent }`
  - `AddLiquidity { header: PlasmaEventHeader, event: AddLiquidityEvent }`
  - `RemoveLiquidity { header: PlasmaEventHeader, event: RemoveLiquidityEvent }`
  - `RenounceLiquidity { header: PlasmaEventHeader, event: RenounceLiquidityEvent }`
  - `WithdrawLpFees { header: PlasmaEventHeader, event: WithdrawLpFeesEvent }`
  - `InitializeLpPosition { header: PlasmaEventHeader, event: InitializeLpPositionEvent }`
  - `InitializePool { header: PlasmaEventHeader, event: InitializePoolEvent }`
  - `WithdrawProtocolFees { header: PlasmaEventHeader, event: WithdrawProtocolFeesEvent }`

### `PlasmaEventHeader`
- `sequence_number`: `u64`
- `slot`: `u64`
- `timestamp`: `i64`
- `pool`: `Pubkey`
- `signer`: `Pubkey`
- `base_decimals`: `u8`
- `quote_decimals`: `u8`

### `PoolHeader`
- `sequence_number`: `u64`
- `base_params`: `TokenParams`
- `quote_params`: `TokenParams`
- `fee_recipients`: `ProtocolFeeRecipients`
- `swap_sequence_number`: `u64`
- `padding`: `[u64; 12]`

### `ProtocolFeeRecipient`
- `recipient`: `Pubkey`
- `shares`: `u64`
- `total_accumulated_quote_fees`: `u64`
- `collected_quote_fees`: `u64`

### `ProtocolFeeRecipientParams`
- `recipient`: `Pubkey`
- `shares`: `u64`

### `ProtocolFeeRecipients`
- `recipients`: `[ProtocolFeeRecipient; 3]`
- `padding`: `[u64; 12]`

### `RemoveLiquidityIxParams`
- `lp_shares`: `u64`

### `RenounceLiquidityIxParams`
- `allow_fee_withdrawal`: `bool`

### `Side`
- enum variants: `Buy`, `Sell`

### `SwapIxParams`
- `side`: `Side`
- `swap_type`: `SwapType`

### `SwapResult`
- `side`: `Side`
- `base_matched`: `u64`
- `quote_matched`: `u64`
- `base_matched_as_limit_order`: `u64`
- `quote_matched_as_limit_order`: `u64`
- `base_matched_as_swap`: `u64`
- `quote_matched_as_swap`: `u64`
- `fee_in_quote`: `u64`

### `SwapType`
- enum variants:
  - `ExactIn { amount_in: u64, min_amount_out: u64 }`
  - `ExactOut { amount_out: u64, max_amount_in: u64 }`

### `TokenParams`
- `decimals`: `u32`
- `vault_bump`: `u32`
- `mint_key`: `Pubkey`
- `vault_key`: `Pubkey`
