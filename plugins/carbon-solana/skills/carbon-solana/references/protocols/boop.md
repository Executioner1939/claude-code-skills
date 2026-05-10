# Boop

- **Crate:** `carbon-boop-decoder`
- **Program ID:** `boop8hVGQGqehUK2iVEMEnMrL5RbjywRzHKBmBE7ry4`
- **Decoder struct:** `BoopDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in instructions/)
- **Discriminator style:** anchor 8-byte

## Account types

### `AmmConfig`
- **Discriminator:** `0xdaf42168cbcb2b6f`
- **Fields:**
  - `bump`: `u8`
  - `disable_create_pool`: `bool`
  - `index`: `u16`
  - `trade_fee_rate`: `u64`
  - `protocol_fee_rate`: `u64`
  - `fund_fee_rate`: `u64`
  - `create_pool_fee`: `u64`
  - `protocol_owner`: `Pubkey`
  - `fund_owner`: `Pubkey`
  - `padding`: `[u64; 16]`

### `BondingCurve`
- **Discriminator:** `0x17b7f83760d8ac60`
- **Fields:**
  - `creator`: `Pubkey`
  - `mint`: `Pubkey`
  - `virtual_sol_reserves`: `u64`
  - `virtual_token_reserves`: `u64`
  - `graduation_target`: `u64`
  - `graduation_fee`: `u64`
  - `sol_reserves`: `u64`
  - `token_reserves`: `u64`
  - `damping_term`: `u8`
  - `swap_fee_basis_points`: `u8`
  - `token_for_stakers_basis_points`: `u16`
  - `status`: `BondingCurveStatus`

### `Config`
- **Discriminator:** `0x9b0caae01efacc82`
- **Fields:**
  - `is_paused`: `bool`
  - `authority`: `Pubkey`
  - `pending_authority`: `Pubkey`
  - `operators`: `Vec<Pubkey>`
  - `protocol_fee_recipient`: `Pubkey`
  - `token_distributor`: `Pubkey`
  - `virtual_sol_reserves`: `u64`
  - `virtual_token_reserves`: `u64`
  - `graduation_target`: `u64`
  - `graduation_fee`: `u64`
  - `damping_term`: `u8`
  - `token_for_stakers_basis_points`: `u16`
  - `swap_fee_basis_points`: `u8`
  - `token_amount_for_raydium_liquidity`: `u64`
  - `max_graduation_price_deviation_basis_points`: `u16`
  - `max_swap_amount_for_pool_price_correction_basis_points`: `u16`

### `LockedCpLiquidityState`
- **Discriminator:** `0x190aeec5cfea4916`
- **Fields:**
  - `locked_lp_amount`: `u64`
  - `claimed_lp_amount`: `u64`
  - `unclaimed_lp_amount`: `u64`
  - `last_lp`: `u64`
  - `last_k`: `u128`
  - `recent_epoch`: `u64`
  - `pool_id`: `Pubkey`
  - `fee_nft_mint`: `Pubkey`
  - `locked_owner`: `Pubkey`
  - `locked_lp_mint`: `Pubkey`
  - `padding`: `[u64; 8]`

## Instructions

### `AddOperators`
- **Discriminator:** `0xa5c73ed651360496`
- **Args:**
  - `operators`: `Vec<Pubkey>`
- **Account variants:**
  - `3 accounts:` `config`, `authority`, `system_program`

### `BuyToken`
- **Discriminator:** `0x8a7f0e5b26577369`
- **Args:**
  - `buy_amount`: `u64`
  - `amount_out_min`: `u64`
- **Account variants:**
  - `13 accounts:` `mint`, `bonding_curve`, `trading_fees_vault`, `bonding_curve_vault`, `bonding_curve_sol_vault`, `recipient_token_account`, `buyer`, `config`, `vault_authority`, `wsol`, `system_program`, `token_program`, `associated_token_program`

### `CancelAuthorityTransfer`
- **Discriminator:** `0x5e837db8b7187de5`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `authority`, `config`, `system_program`

### `CloseBondingCurveVault`
- **Discriminator:** `0xbd47bdef71423bbd`
- **Args:** (none)
- **Account variants:**
  - `12 accounts:` `config`, `operator`, `vault_authority`, `bonding_curve`, `bonding_curve_vault`, `mint`, `recipient_token_account`, `recipient`, `token_program`, `system_program`, `associated_token_program`, `rent`

### `CollectMeteoraTradingFees`
- **Discriminator:** `0xf95f7e5b51a253fa`
- **Args:** (none)
- **Account variants:**
  - `18 accounts:` `operator`, `protocol_fee_recipient`, `config`, `pool_authority`, `pool`, `position`, `token_a_account`, `token_b_account`, `token_a_vault`, `token_b_vault`, `token_a_mint`, `token_b_mint`, `position_nft_account`, `vault_authority`, `token_program`, `associated_token_program`, `event_authority`, `cp_amm_program`

### `CollectTradingFees`
- **Discriminator:** `0xbd26cdea514d1901`
- **Args:** (none)
- **Account variants:**
  - `24 accounts:` `operator`, `protocol_fee_recipient`, `config`, `lock_program`, `vault_authority`, `authority`, `fee_nft_account`, `locked_liquidity`, `cpmm_program`, `cp_authority`, `pool_state`, `lp_mint`, `recipient_token_0_account`, `recipient_token_1_account`, `token_0_vault`, `token_1_vault`, `vault_0_mint`, `vault_1_mint`, `locked_lp_vault`, `system_program`, `associated_token_program`, `token_program`, `token_program_2022`, `memo_program`

### `CompleteAuthorityTransfer`
- **Discriminator:** `0x51e95b84af1f978d`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `pending_authority`, `config`, `system_program`

### `CreateMeteoraPool`
- **Discriminator:** `0xf6fe2125e1b029e8`
- **Args:** (none)
- **Account variants:**
  - `21 accounts:` `operator`, `config`, `vault_authority`, `cp_amm_config`, `pool_authority`, `pool`, `position`, `position_nft_mint`, `position_nft_account`, `token_a_mint`, `token_b_mint`, `token_a_vault`, `token_b_vault`, `bonding_curve`, `bonding_curve_vault`, `bonding_curve_wsol_vault`, `token_program`, `token_2022_program`, `system_program`, `event_authority`, `cp_amm_program`

### `CreateRaydiumPool`
- **Discriminator:** `0x412d774dccb25402`
- **Args:** (none)
- **Account variants:**
  - `22 accounts:` `cpmm_program`, `amm_config`, `authority`, `pool_state`, `token_0_mint`, `token_1_mint`, `lp_mint`, `vault_authority`, `bonding_curve`, `bonding_curve_vault`, `bonding_curve_wsol_vault`, `creator_lp_token`, `token_0_vault`, `token_1_vault`, `create_pool_fee`, `observation_state`, `operator`, `config`, `token_program`, `associated_token_program`, `system_program`, `rent`

### `CreateRaydiumRandomPool`
- **Discriminator:** `0x4e2cad1d84b404ac`
- **Args:** (none)
- **Account variants:**
  - `22 accounts:` `cpmm_program`, `amm_config`, `authority`, `pool_state`, `token_0_mint`, `token_1_mint`, `lp_mint`, `vault_authority`, `bonding_curve`, `bonding_curve_vault`, `bonding_curve_wsol_vault`, `creator_lp_token`, `token_0_vault`, `token_1_vault`, `create_pool_fee`, `observation_state`, `operator`, `config`, `token_program`, `associated_token_program`, `system_program`, `rent`

### `CreateToken`
- **Discriminator:** `0x5434cce4188cea4b`
- **Args:**
  - `salt`: `u64`
  - `name`: `String`
  - `symbol`: `String`
  - `uri`: `String`
- **Account variants:**
  - `8 accounts:` `config`, `metadata`, `mint`, `payer`, `rent`, `system_program`, `token_program`, `token_metadata_program`

### `CreateTokenFallback`
- **Discriminator:** `0xfdb87ec7ebe8aca2`
- **Args:**
  - `salt`: `u64`
  - `name`: `String`
  - `symbol`: `String`
  - `uri`: `String`
- **Account variants:**
  - `8 accounts:` `config`, `metadata`, `mint`, `payer`, `rent`, `system_program`, `token_program`, `token_metadata_program`

### `DeployBondingCurve`
- **Discriminator:** `0xb459c74ca8ecd98a`
- **Args:**
  - `creator`: `Pubkey`
  - `salt`: `u64`
- **Account variants:**
  - `10 accounts:` `mint`, `vault_authority`, `bonding_curve`, `bonding_curve_sol_vault`, `bonding_curve_vault`, `config`, `payer`, `system_program`, `token_program`, `associated_token_program`

### `DeployBondingCurveFallback`
- **Discriminator:** `0x35e6ac544dae163d`
- **Args:**
  - `creator`: `Pubkey`
  - `salt`: `u64`
- **Account variants:**
  - `10 accounts:` `mint`, `vault_authority`, `bonding_curve`, `bonding_curve_sol_vault`, `bonding_curve_vault`, `config`, `payer`, `system_program`, `token_program`, `associated_token_program`

### `DepositIntoRaydium`
- **Discriminator:** `0xa859631e753158e0`
- **Args:**
  - `lp_token_amount`: `u64`
  - `maximum_token_0_amount`: `u64`
  - `maximum_token_1_amount`: `u64`
- **Account variants:**
  - `21 accounts:` `config`, `amm_config`, `operator`, `operator_wsol_account`, `vault_authority`, `authority`, `pool_state`, `token_0_vault`, `token_1_vault`, `bonding_curve_vault`, `bonding_curve_wsol_vault`, `token_program`, `token_program_2022`, `system_program`, `associated_token_program`, `lp_mint`, `cpmm_program`, `owner_lp_token`, `bonding_curve`, `token_0_mint`, `token_1_mint`

### `Graduate`
- **Discriminator:** `0x2debe1b511da4082`
- **Args:** (none)
- **Account variants:**
  - `15 accounts:` `mint`, `wsol`, `protocol_fee_recipient`, `token_distributor`, `token_distributor_token_account`, `vault_authority`, `bonding_curve_sol_vault`, `bonding_curve`, `bonding_curve_vault`, `bonding_curve_wsol_account`, `operator`, `config`, `system_program`, `token_program`, `associated_token_program`

### `Initialize`
- **Discriminator:** `0xafaf6d1f0d989bed`
- **Args:**
  - `protocol_fee_recipient`: `Pubkey`
  - `token_distributor`: `Pubkey`
- **Account variants:**
  - `3 accounts:` `config`, `authority`, `system_program`

### `InitiateAuthorityTransfer`
- **Discriminator:** `0xd22b65d7778c6ada`
- **Args:**
  - `new_authority`: `Pubkey`
- **Account variants:**
  - `3 accounts:` `authority`, `config`, `system_program`

### `LockRaydiumLiquidity`
- **Discriminator:** `0xadff94067a638c16`
- **Args:** (none)
- **Account variants:**
  - `22 accounts:` `lock_program`, `vault_authority`, `authority`, `fee_nft_owner`, `fee_nft_mint`, `fee_nft_account`, `pool_state`, `locked_liquidity`, `lp_mint`, `liquidity_owner_lp`, `locked_lp_vault`, `token_0_vault`, `token_1_vault`, `operator`, `config`, `bonding_curve`, `metadata_account`, `rent`, `system_program`, `token_program`, `associated_token_program`, `metadata_program`

### `RemoveOperators`
- **Discriminator:** `0x2a145953de25046d`
- **Args:**
  - `operators`: `Vec<Pubkey>`
- **Account variants:**
  - `3 accounts:` `config`, `authority`, `system_program`

### `SellToken`
- **Discriminator:** `0x6d3d28bbe6b087ae`
- **Args:**
  - `sell_amount`: `u64`
  - `amount_out_min`: `u64`
- **Account variants:**
  - `12 accounts:` `mint`, `bonding_curve`, `trading_fees_vault`, `bonding_curve_vault`, `bonding_curve_sol_vault`, `seller_token_account`, `seller`, `recipient`, `config`, `system_program`, `token_program`, `associated_token_program`

### `SplitTradingFees`
- **Discriminator:** `0x607ee12fb9d5323a`
- **Args:** (none)
- **Account variants:**
  - `24 accounts:` `operator`, `mint`, `wsol`, `config`, `vault_authority`, `bonding_curve`, `trading_fees_vault`, `fee_splitter_program`, `system_program`, `token_program`, `associated_token_program`, `fee_splitter_config`, `fee_splitter_creator_vault`, `fee_splitter_vault_authority`, `fee_splitter_creator_vault_authority`, `fee_splitter_staking_mint`, `fee_splitter_wsol_vault`, `fee_splitter_creator_vault_authority_wsol_vault`, `fee_splitter_treasury_wsol_vault`, `fee_splitter_team_wsol_vault`, `fee_splitter_reward_pool`, `fee_splitter_reward_pool_staking_vault`, `fee_splitter_reward_pool_reward_vault`, `fee_splitter_reward_pool_program`

### `SwapSolForTokensOnRaydium`
- **Discriminator:** `0x6bf883ef98ea3623`
- **Args:**
  - `amount_in`: `u64`
  - `minimum_amount_out`: `u64`
- **Account variants:**
  - `16 accounts:` `config`, `bonding_curve`, `amm_config`, `operator`, `vault_authority`, `authority`, `pool_state`, `input_vault`, `output_vault`, `bonding_curve_vault`, `bonding_curve_wsol_vault`, `output_token_mint`, `input_token_mint`, `token_program`, `cp_swap_program`, `observation_state`

### `SwapTokensForSolOnRaydium`
- **Discriminator:** `0xd8ac82942262d7a3`
- **Args:**
  - `amount_in`: `u64`
  - `minimum_amount_out`: `u64`
- **Account variants:**
  - `16 accounts:` `config`, `bonding_curve`, `amm_config`, `operator`, `vault_authority`, `authority`, `pool_state`, `input_vault`, `output_vault`, `bonding_curve_vault`, `bonding_curve_wsol_vault`, `input_token_mint`, `output_token_mint`, `token_program`, `cp_swap_program`, `observation_state`

### `TogglePaused`
- **Discriminator:** `0x365393c67b61da48`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `authority`, `config`

### `UpdateConfig`
- **Discriminator:** `0x1d9efcbf0a53db63`
- **Args:**
  - `new_protocol_fee_recipient`: `Pubkey`
  - `new_virtual_sol_reserves`: `u64`
  - `new_virtual_token_reserves`: `u64`
  - `new_graduation_target`: `u64`
  - `new_graduation_fee`: `u64`
  - `new_damping_term`: `u8`
  - `new_swap_fee_basis_points`: `u8`
  - `new_token_for_stakers_basis_points`: `u16`
  - `new_token_amount_for_raydium_liquidity`: `u64`
  - `new_max_graduation_price_deviation_basis_points`: `u16`
  - `new_max_swap_amount_for_pool_price_correction_basis_points`: `u16`
- **Account variants:**
  - `3 accounts:` `config`, `authority`, `system_program`

## CPI events

### `AuthorityTransferCancelledEvent`
- **Source:** `instructions/authority_transfer_cancelled_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1dc0798ce0e5600d8f`
- **Fields:** (none)

### `AuthorityTransferCompletedEvent`
- **Source:** `instructions/authority_transfer_completed_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1da384d980f35c5af9`
- **Fields:**
  - `old_authority`: `Pubkey`
  - `new_authority`: `Pubkey`

### `AuthorityTransferInitiatedEvent`
- **Source:** `instructions/authority_transfer_initiated_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d79f65f9be56d94cd`
- **Fields:**
  - `old_authority`: `Pubkey`
  - `new_authority`: `Pubkey`

### `BondingCurveDeployedEvent`
- **Source:** `instructions/bonding_curve_deployed_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1de150b222d927b894`
- **Fields:**
  - `mint`: `Pubkey`
  - `creator`: `Pubkey`

### `BondingCurveDeployedFallbackEvent`
- **Source:** `instructions/bonding_curve_deployed_fallback_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d6afcf373c79ff71f`
- **Fields:**
  - `mint`: `Pubkey`
  - `creator`: `Pubkey`

### `BondingCurveVaultClosedEvent`
- **Source:** `instructions/bonding_curve_vault_closed_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1db9249c52bda4cf4f`
- **Fields:**
  - `mint`: `Pubkey`
  - `recipient`: `Pubkey`
  - `amount`: `u64`

### `ConfigUpdatedEvent`
- **Source:** `instructions/config_updated_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1df59e81633c64d6dc`
- **Fields:**
  - `protocol_fee_recipient`: `Pubkey`
  - `virtual_sol_reserves`: `u64`
  - `virtual_token_reserves`: `u64`
  - `graduation_target`: `u64`
  - `graduation_fee`: `u64`
  - `damping_term`: `u8`
  - `swap_fee_basis_points`: `u8`
  - `token_for_stakers_basis_points`: `u16`
  - `token_amount_for_raydium_liquidity`: `u64`
  - `max_graduation_price_deviation_basis_points`: `u16`
  - `max_swap_amount_for_pool_price_correction_basis_points`: `u16`

### `LiquidityDepositedIntoRaydiumEvent`
- **Source:** `instructions/liquidity_deposited_into_raydium_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1dec32611bc665f814`
- **Fields:**
  - `pool_state`: `Pubkey`
  - `mint`: `Pubkey`
  - `lp_token_amount`: `u64`
  - `tokens_deposited`: `u64`
  - `wsol_deposited`: `u64`

### `OperatorsAddedEvent`
- **Source:** `instructions/operators_added_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1df73a7038cbba7098`
- **Fields:**
  - `operators`: `Vec<Pubkey>`

### `OperatorsRemovedEvent`
- **Source:** `instructions/operators_removed_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d2c484b46972a3559`
- **Fields:**
  - `operators`: `Vec<Pubkey>`

### `PausedToggledEvent`
- **Source:** `instructions/paused_toggled_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d8fdee4e006e640b0`
- **Fields:**
  - `is_paused`: `bool`

### `RaydiumLiquidityLockedEvent`
- **Source:** `instructions/raydium_liquidity_locked_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1dacbd08f189af3b64`
- **Fields:**
  - `pool_state`: `Pubkey`
  - `mint`: `Pubkey`
  - `lp_amount`: `u64`

### `RaydiumPoolCreatedEvent`
- **Source:** `instructions/raydium_pool_created_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1daab215d754de2265`
- **Fields:**
  - `pool_state`: `Pubkey`
  - `mint`: `Pubkey`

### `RaydiumRandomPoolCreatedEvent`
- **Source:** `instructions/raydium_random_pool_created_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d98fb80989eeb5335`
- **Fields:**
  - `pool_state`: `Pubkey`
  - `mint`: `Pubkey`

### `SwapSolForTokensOnRaydiumEvent`
- **Source:** `instructions/swap_sol_for_tokens_on_raydium_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1df70108a6dd747162`
- **Fields:**
  - `mint`: `Pubkey`
  - `amount_in`: `u64`
  - `amount_out`: `u64`

### `SwapTokensForSolOnRaydiumEvent`
- **Source:** `instructions/swap_tokens_for_sol_on_raydium_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d4cf9dda241467620`
- **Fields:**
  - `mint`: `Pubkey`
  - `amount_in`: `u64`
  - `amount_out`: `u64`

### `TokenBoughtEvent`
- **Source:** `instructions/token_bought_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d4759de7cd7c0e68a`
- **Fields:**
  - `mint`: `Pubkey`
  - `amount_in`: `u64`
  - `amount_out`: `u64`
  - `swap_fee`: `u64`
  - `buyer`: `Pubkey`
  - `recipient`: `Pubkey`

### `TokenCreatedEvent`
- **Source:** `instructions/token_created_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d607a718a32e39539`
- **Fields:**
  - `name`: `String`
  - `symbol`: `String`
  - `uri`: `String`

### `TokenCreatedFallbackEvent`
- **Source:** `instructions/token_created_fallback_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d9dca235ca5a32738`
- **Fields:**
  - `name`: `String`
  - `symbol`: `String`
  - `uri`: `String`

### `TokenGraduatedEvent`
- **Source:** `instructions/token_graduated_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d49746f1a5cd9928d`
- **Fields:**
  - `mint`: `Pubkey`
  - `sol_for_liquidity`: `u64`
  - `graduation_fee`: `u64`
  - `token_for_distributor`: `u64`

### `TokenSoldEvent`
- **Source:** `instructions/token_sold_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1dccefb64df1334d42`
- **Fields:**
  - `mint`: `Pubkey`
  - `amount_in`: `u64`
  - `amount_out`: `u64`
  - `swap_fee`: `u64`
  - `seller`: `Pubkey`
  - `recipient`: `Pubkey`

### `TradingFeesCollectedEvent`
- **Source:** `instructions/trading_fees_collected_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1de13f1a3786f3d2cb`
- **Fields:**
  - `pool_state`: `Pubkey`
  - `mint`: `Pubkey`

### `TradingFeesSplitEvent`
- **Source:** `instructions/trading_fees_split_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d713c9f11fdae877a`
- **Fields:**
  - `amount`: `u64`
  - `creator`: `Pubkey`

## Shared types

### `BondingCurveStatus`
- Enum variants: `Trading`, `Graduated`, `PoolPriceCorrected`, `LiquidityProvisioned`, `LiquidityLocked`
