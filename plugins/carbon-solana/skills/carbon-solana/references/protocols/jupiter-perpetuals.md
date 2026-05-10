# Jupiter Perpetuals

- **Crate:** `carbon-jupiter-perpetuals-decoder`
- **Program ID:** `PERPHjGBqRHArX4DySjwM6UJHiR3sWAatqfdBS2qQJu`
- **Decoder struct:** `PerpetualsDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in instructions/)
- **Discriminator style:** anchor 8-byte

## Account types

### `Custody`
- **Fields:**
  - `pool`: `Pubkey`
  - `mint`: `Pubkey`
  - `token_account`: `Pubkey`
  - `decimals`: `u8`
  - `is_stable`: `bool`
  - `oracle`: `OracleParams`
  - `pricing`: `PricingParams`
  - `permissions`: `Permissions`
  - `target_ratio_bps`: `u64`
  - `assets`: `Assets`
  - `funding_rate_state`: `FundingRateState`
  - `bump`: `u8`
  - `token_account_bump`: `u8`
  - `increase_position_bps`: `u64`
  - `decrease_position_bps`: `u64`
  - `max_position_size_usd`: `u64`
  - `doves_oracle`: `Pubkey`
  - `jump_rate_state`: `JumpRateState`

### `Perpetuals`
- **Fields:**
  - `permissions`: `Permissions`
  - `pools`: `Vec<Pubkey>`
  - `admin`: `Pubkey`
  - `transfer_authority_bump`: `u8`
  - `perpetuals_bump`: `u8`
  - `inception_time`: `i64`

### `Pool`
- **Fields:**
  - `name`: `String`
  - `custodies`: `Vec<Pubkey>`
  - `aum_usd`: `u128`
  - `limit`: `Limit`
  - `fees`: `Fees`
  - `pool_apr`: `PoolApr`
  - `max_request_execution_sec`: `i64`
  - `bump`: `u8`
  - `lp_token_bump`: `u8`
  - `inception_time`: `i64`

### `Position`
- **Fields:**
  - `owner`: `Pubkey`
  - `pool`: `Pubkey`
  - `custody`: `Pubkey`
  - `collateral_custody`: `Pubkey`
  - `open_time`: `i64`
  - `update_time`: `i64`
  - `side`: `Side`
  - `price`: `u64`
  - `size_usd`: `u64`
  - `collateral_usd`: `u64`
  - `realised_pnl_usd`: `i64`
  - `cumulative_interest_snapshot`: `u128`
  - `locked_amount`: `u64`
  - `bump`: `u8`

### `PositionRequest`
- **Fields:**
  - `owner`: `Pubkey`
  - `pool`: `Pubkey`
  - `custody`: `Pubkey`
  - `position`: `Pubkey`
  - `mint`: `Pubkey`
  - `open_time`: `i64`
  - `update_time`: `i64`
  - `size_usd_delta`: `u64`
  - `collateral_delta`: `u64`
  - `request_change`: `RequestChange`
  - `request_type`: `RequestType`
  - `side`: `Side`
  - `price_slippage`: `Option<u64>`
  - `jupiter_minimum_out`: `Option<u64>`
  - `pre_swap_amount`: `Option<u64>`
  - `trigger_price`: `Option<u64>`
  - `trigger_above_threshold`: `Option<bool>`
  - `entire_position`: `Option<bool>`
  - `executed`: `bool`
  - `counter`: `u64`
  - `bump`: `u8`
  - `referral`: `Option<Pubkey>`

### `TokenLedger`
- **Fields:**
  - `token_account`: `Pubkey`
  - `amount`: `u64`

## Instructions

### `AddCustody`
- **Discriminator:** `0xf7fe7e111a06d775`
- **Args:**
  - `params`: `AddCustodyParams`
- **Account variants:**
  - `10 accounts:` `admin`, `transfer_authority`, `perpetuals`, `pool`, `custody`, `custody_token_account`, `custody_token_mint`, `system_program`, `token_program`, `rent`

### `AddLiquidity2`
- **Discriminator:** `0xe4a24e1c46db7473`
- **Args:**
  - `params`: `AddLiquidity2Params`
- **Account variants:**
  - `14 accounts:` `owner`, `funding_account`, `lp_token_account`, `transfer_authority`, `perpetuals`, `pool`, `custody`, `custody_doves_price_account`, `custody_pythnet_price_account`, `custody_token_account`, `lp_token_mint`, `token_program`, `event_authority`, `program`

### `AddPool`
- **Discriminator:** `0x73e6d4d3af3127a9`
- **Args:**
  - `params`: `AddPoolParams`
- **Account variants:**
  - `8 accounts:` `admin`, `transfer_authority`, `perpetuals`, `pool`, `lp_token_mint`, `system_program`, `token_program`, `rent`

### `ClosePositionRequest`
- **Discriminator:** `0x2869d9bcdc2d6d6e`
- **Args:**
  - `params`: `ClosePositionRequestParams`
- **Account variants:**
  - `10 accounts:` `keeper`, `owner`, `owner_ata`, `pool`, `position_request`, `position_request_ata`, `position`, `token_program`, `event_authority`, `program`

### `CreateDecreasePositionMarketRequest`
- **Discriminator:** `0x4ac6c356c163014f`
- **Args:**
  - `params`: `CreateDecreasePositionMarketRequestParams`
- **Account variants:**
  - `16 accounts:` `owner`, `receiving_account`, `perpetuals`, `pool`, `position`, `position_request`, `position_request_ata`, `custody`, `collateral_custody`, `desired_mint`, `referral`, `token_program`, `associated_token_program`, `system_program`, `event_authority`, `program`

### `CreateDecreasePositionRequest2`
- **Discriminator:** `0x6940c952fa0e6d4d`
- **Args:**
  - `params`: `CreateDecreasePositionRequest2Params`
- **Account variants:**
  - `18 accounts:` `owner`, `receiving_account`, `perpetuals`, `pool`, `position`, `position_request`, `position_request_ata`, `custody`, `custody_doves_price_account`, `custody_pythnet_price_account`, `collateral_custody`, `desired_mint`, `referral`, `token_program`, `associated_token_program`, `system_program`, `event_authority`, `program`

### `CreateIncreasePositionMarketRequest`
- **Discriminator:** `0xb855c71869ab9c38`
- **Args:**
  - `params`: `CreateIncreasePositionMarketRequestParams`
- **Account variants:**
  - `16 accounts:` `owner`, `funding_account`, `perpetuals`, `pool`, `position`, `position_request`, `position_request_ata`, `custody`, `collateral_custody`, `input_mint`, `referral`, `token_program`, `associated_token_program`, `system_program`, `event_authority`, `program`

### `CreateTokenLedger`
- **Discriminator:** `0xe8f2c5fdf08f8134`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `token_ledger`, `payer`, `system_program`

### `CreateTokenMetadata`
- **Discriminator:** `0xdd50b02599bca044`
- **Args:**
  - `params`: `CreateTokenMetadataParams`
- **Account variants:**
  - `9 accounts:` `admin`, `perpetuals`, `pool`, `transfer_authority`, `metadata`, `lp_token_mint`, `token_metadata_program`, `system_program`, `rent`

### `DecreasePosition4`
- **Discriminator:** `0xb9a172af609403aa`
- **Args:**
  - `params`: `DecreasePosition4Params`
- **Account variants:**
  - `18 accounts:` `keeper`, `owner`, `transfer_authority`, `perpetuals`, `pool`, `position_request`, `position_request_ata`, `position`, `custody`, `custody_doves_price_account`, `custody_pythnet_price_account`, `collateral_custody`, `collateral_custody_doves_price_account`, `collateral_custody_pythnet_price_account`, `collateral_custody_token_account`, `token_program`, `event_authority`, `program`

### `DecreasePositionWithInternalSwap`
- **Discriminator:** `0x8311996e77646126`
- **Args:**
  - `params`: `DecreasePositionWithInternalSwapParams`
- **Account variants:**
  - `22 accounts:` `keeper`, `owner`, `transfer_authority`, `perpetuals`, `pool`, `position_request`, `position_request_ata`, `position`, `custody`, `custody_doves_price_account`, `custody_pythnet_price_account`, `collateral_custody`, `collateral_custody_doves_price_account`, `collateral_custody_pythnet_price_account`, `collateral_custody_token_account`, `dispensing_custody`, `dispensing_custody_doves_price_account`, `dispensing_custody_pythnet_price_account`, `dispensing_custody_token_account`, `token_program`, `event_authority`, `program`

### `GetAddLiquidityAmountAndFee2`
- **Discriminator:** `0x6d9d37a908510476`
- **Args:**
  - `params`: `GetAddLiquidityAmountAndFee2Params`
- **Account variants:**
  - `6 accounts:` `perpetuals`, `pool`, `custody`, `custody_doves_price_account`, `custody_pythnet_price_account`, `lp_token_mint`

### `GetAssetsUnderManagement2`
- **Discriminator:** `0xc1d20df971951d54`
- **Args:**
  - `params`: `GetAssetsUnderManagement2Params`
- **Account variants:**
  - `2 accounts:` `perpetuals`, `pool`

### `GetRemoveLiquidityAmountAndFee2`
- **Discriminator:** `0xb73b486edff3968e`
- **Args:**
  - `params`: `GetRemoveLiquidityAmountAndFee2Params`
- **Account variants:**
  - `6 accounts:` `perpetuals`, `pool`, `custody`, `custody_doves_price_account`, `custody_pythnet_price_account`, `lp_token_mint`

### `IncreasePosition4`
- **Discriminator:** `0x439335172b391043`
- **Args:**
  - `params`: `IncreasePosition4Params`
- **Account variants:**
  - `16 accounts:` `keeper`, `perpetuals`, `pool`, `position_request`, `position_request_ata`, `position`, `custody`, `custody_doves_price_account`, `custody_pythnet_price_account`, `collateral_custody`, `collateral_custody_doves_price_account`, `collateral_custody_pythnet_price_account`, `collateral_custody_token_account`, `token_program`, `event_authority`, `program`

### `IncreasePositionPreSwap`
- **Discriminator:** `0x1a88e1d916155314`
- **Args:**
  - `params`: `IncreasePositionPreSwapParams`
- **Account variants:**
  - `11 accounts:` `keeper`, `keeper_ata`, `position_request`, `position_request_ata`, `position`, `collateral_custody`, `collateral_custody_token_account`, `instruction`, `token_program`, `event_authority`, `program`

### `IncreasePositionWithInternalSwap`
- **Discriminator:** `0x72376a8cc7dd2070`
- **Args:**
  - `params`: `IncreasePositionWithInternalSwapParams`
- **Account variants:**
  - `20 accounts:` `keeper`, `perpetuals`, `pool`, `position_request`, `position_request_ata`, `position`, `custody`, `custody_doves_price_account`, `custody_pythnet_price_account`, `collateral_custody`, `collateral_custody_doves_price_account`, `collateral_custody_pythnet_price_account`, `collateral_custody_token_account`, `receiving_custody`, `receiving_custody_doves_price_account`, `receiving_custody_pythnet_price_account`, `receiving_custody_token_account`, `token_program`, `event_authority`, `program`

### `Init`
- **Discriminator:** `0xdc3bcfec6cfa2f64`
- **Args:**
  - `params`: `InitParams`
- **Account variants:**
  - `8 accounts:` `upgrade_authority`, `admin`, `transfer_authority`, `perpetuals`, `perpetuals_program`, `perpetuals_program_data`, `system_program`, `token_program`

### `InstantCreateLimitOrder`
- **Discriminator:** `0xc225c37b287f7e9c`
- **Args:**
  - `params`: `InstantCreateLimitOrderParams`
- **Account variants:**
  - `20 accounts:` `keeper`, `api_keeper`, `owner`, `funding_account`, `perpetuals`, `pool`, `position`, `position_request`, `position_request_ata`, `custody`, `custody_doves_price_account`, `custody_pythnet_price_account`, `collateral_custody`, `input_mint`, `referral`, `token_program`, `associated_token_program`, `system_program`, `event_authority`, `program`

### `InstantCreateTpsl`
- **Discriminator:** `0x7562427f1e3249b9`
- **Args:**
  - `params`: `InstantCreateTpslParams`
- **Account variants:**
  - `20 accounts:` `keeper`, `api_keeper`, `owner`, `receiving_account`, `perpetuals`, `pool`, `position`, `position_request`, `position_request_ata`, `custody`, `custody_doves_price_account`, `custody_pythnet_price_account`, `collateral_custody`, `desired_mint`, `referral`, `token_program`, `associated_token_program`, `system_program`, `event_authority`, `program`

### `InstantDecreasePosition`
- **Discriminator:** `0x2e17f02c1e8a5e8c`
- **Args:**
  - `params`: `InstantDecreasePositionParams`
- **Account variants:**
  - `22 accounts:` `keeper`, `api_keeper`, `owner`, `receiving_account`, `transfer_authority`, `perpetuals`, `pool`, `position`, `custody`, `custody_doves_price_account`, `custody_pythnet_price_account`, `collateral_custody`, `collateral_custody_doves_price_account`, `collateral_custody_pythnet_price_account`, `collateral_custody_token_account`, `desired_mint`, `referral`, `token_program`, `associated_token_program`, `system_program`, `event_authority`, `program`

### `InstantIncreasePosition`
- **Discriminator:** `0xa47e44b6dfa640b7`
- **Args:**
  - `params`: `InstantIncreasePositionParams`
- **Account variants:**
  - `20 accounts:` `keeper`, `api_keeper`, `owner`, `funding_account`, `perpetuals`, `pool`, `position`, `custody`, `custody_doves_price_account`, `custody_pythnet_price_account`, `collateral_custody`, `collateral_custody_doves_price_account`, `collateral_custody_pythnet_price_account`, `collateral_custody_token_account`, `token_ledger`, `referral`, `token_program`, `system_program`, `event_authority`, `program`

### `InstantUpdateLimitOrder`
- **Discriminator:** `0x88f5e53a798d0ccf`
- **Args:**
  - `params`: `InstantUpdateLimitOrderParams`
- **Account variants:**
  - `10 accounts:` `keeper`, `api_keeper`, `owner`, `perpetuals`, `pool`, `position`, `position_request`, `custody`, `custody_doves_price_account`, `custody_pythnet_price_account`

### `InstantUpdateTpsl`
- **Discriminator:** `0x90e47225a5f26f65`
- **Args:**
  - `params`: `InstantUpdateTpslParams`
- **Account variants:**
  - `12 accounts:` `keeper`, `api_keeper`, `owner`, `perpetuals`, `pool`, `position`, `position_request`, `custody`, `custody_doves_price_account`, `custody_pythnet_price_account`, `event_authority`, `program`

### `LiquidateFullPosition4`
- **Discriminator:** `0x40b05833a8bc9caf`
- **Args:**
  - `params`: `LiquidateFullPosition4Params`
- **Account variants:**
  - `13 accounts:` `signer`, `perpetuals`, `pool`, `position`, `custody`, `custody_doves_price_account`, `custody_pythnet_price_account`, `collateral_custody`, `collateral_custody_doves_price_account`, `collateral_custody_pythnet_price_account`, `collateral_custody_token_account`, `event_authority`, `program`

### `OperatorSetCustodyConfig`
- **Discriminator:** `0xa6895ccc91e018da`
- **Args:**
  - `params`: `OperatorSetCustodyConfigParams`
- **Account variants:**
  - `2 accounts:` `operator`, `custody`

### `OperatorSetPoolConfig`
- **Discriminator:** `0x4cc95012c75cf669`
- **Args:**
  - `params`: `OperatorSetPoolConfigParams`
- **Account variants:**
  - `2 accounts:` `operator`, `pool`

### `RefreshAssetsUnderManagement`
- **Discriminator:** `0xa200d737e10fb900`
- **Args:**
  - `params`: `RefreshAssetsUnderManagementParams`
- **Account variants:**
  - `3 accounts:` `keeper`, `perpetuals`, `pool`

### `RemoveLiquidity2`
- **Discriminator:** `0xe6d7527ff165e392`
- **Args:**
  - `params`: `RemoveLiquidity2Params`
- **Account variants:**
  - `14 accounts:` `owner`, `receiving_account`, `lp_token_account`, `transfer_authority`, `perpetuals`, `pool`, `custody`, `custody_doves_price_account`, `custody_pythnet_price_account`, `custody_token_account`, `lp_token_mint`, `token_program`, `event_authority`, `program`

### `SetCustodyConfig`
- **Discriminator:** `0x8561828fd7e524b0`
- **Args:**
  - `params`: `SetCustodyConfigParams`
- **Account variants:**
  - `3 accounts:` `admin`, `perpetuals`, `custody`

### `SetPerpetualsConfig`
- **Discriminator:** `0x504815bf1d792d6f`
- **Args:**
  - `params`: `SetPerpetualsConfigParams`
- **Account variants:**
  - `2 accounts:` `admin`, `perpetuals`

### `SetPoolConfig`
- **Discriminator:** `0xd857417d716eb978`
- **Args:**
  - `params`: `SetPoolConfigParams`
- **Account variants:**
  - `3 accounts:` `admin`, `perpetuals`, `pool`

### `SetTestTime`
- **Discriminator:** `0xf2e7b1fb7e919f68`
- **Args:**
  - `params`: `SetTestTimeParams`
- **Account variants:**
  - `2 accounts:` `admin`, `perpetuals`

### `SetTokenLedger`
- **Discriminator:** `0xe455b9704e4f4d02`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `token_ledger`, `token_account`, `token_program`

### `Swap2`
- **Discriminator:** `0x414b3f4ceb5b5b88`
- **Args:**
  - `params`: `Swap2Params`
- **Account variants:**
  - `17 accounts:` `owner`, `funding_account`, `receiving_account`, `transfer_authority`, `perpetuals`, `pool`, `receiving_custody`, `receiving_custody_doves_price_account`, `receiving_custody_pythnet_price_account`, `receiving_custody_token_account`, `dispensing_custody`, `dispensing_custody_doves_price_account`, `dispensing_custody_pythnet_price_account`, `dispensing_custody_token_account`, `token_program`, `event_authority`, `program`

### `TestInit`
- **Discriminator:** `0x30335c7a51137029`
- **Args:**
  - `params`: `TestInitParams`
- **Account variants:**
  - `6 accounts:` `upgrade_authority`, `admin`, `transfer_authority`, `perpetuals`, `system_program`, `token_program`

### `TransferAdmin`
- **Discriminator:** `0x2af2426ae40a6f9c`
- **Args:**
  - `params`: `TransferAdminParams`
- **Account variants:**
  - `3 accounts:` `admin`, `new_admin`, `perpetuals`

### `UpdateDecreasePositionRequest2`
- **Discriminator:** `0x90c8f9ff6cd9f974`
- **Args:**
  - `params`: `UpdateDecreasePositionRequest2Params`
- **Account variants:**
  - `8 accounts:` `owner`, `perpetuals`, `pool`, `position`, `position_request`, `custody`, `custody_doves_price_account`, `custody_pythnet_price_account`

### `WithdrawFees2`
- **Discriminator:** `0xfc808f91e1dd9fcf`
- **Args:**
  - `params`: `WithdrawFees2Params`
- **Account variants:**
  - `10 accounts:` `keeper`, `transfer_authority`, `perpetuals`, `pool`, `custody`, `custody_token_account`, `custody_doves_price_account`, `custody_pythnet_price_account`, `receiving_token_account`, `token_program`

## CPI events

### `AddLiquidityEvent`
- **Source:** `instructions/add_liquidity_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d1bb299ba2fc48c2d`
- **Fields:**
  - `custody_key`: `Pubkey`
  - `pool_key`: `Pubkey`
  - `token_amount_in`: `u64`
  - `pre_pool_amount_usd`: `u128`
  - `token_amount_usd`: `u64`
  - `fee_bps`: `u64`
  - `token_amount_after_fee`: `u64`
  - `mint_amount_usd`: `u64`
  - `lp_amount`: `u64`
  - `post_pool_amount_usd`: `u128`

### `ClosePositionRequestEvent`
- **Source:** `instructions/close_position_request_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d15225c9ee01db4f3`
- **Fields:**
  - `entire_position`: `Option<bool>`
  - `executed`: `bool`
  - `request_change`: `u8`
  - `request_type`: `u8`
  - `side`: `u8`
  - `position_request_key`: `Pubkey`
  - `owner`: `Pubkey`
  - `mint`: `Pubkey`
  - `amount`: `u64`

### `CreatePositionRequestEvent`
- **Source:** `instructions/create_position_request_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d02ee5e3569d32eba`
- **Fields:**
  - `owner`: `Pubkey`
  - `pool`: `Pubkey`
  - `position_key`: `Pubkey`
  - `position_side`: `u8`
  - `position_mint`: `Pubkey`
  - `position_custody`: `Pubkey`
  - `position_collateral_mint`: `Pubkey`
  - `position_collateral_custody`: `Pubkey`
  - `position_request_key`: `Pubkey`
  - `position_request_mint`: `Pubkey`
  - `size_usd_delta`: `u64`
  - `collateral_delta`: `u64`
  - `price_slippage`: `Option<u64>`
  - `jupiter_minimum_out`: `Option<u64>`
  - `pre_swap_amount`: `Option<u64>`
  - `request_change`: `u8`
  - `open_time`: `i64`
  - `referral`: `Option<Pubkey>`

### `DecreasePositionEvent`
- **Source:** `instructions/decrease_position_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d409c2b4a6d83107f`
- **Fields:**
  - `position_key`: `Pubkey`
  - `position_side`: `u8`
  - `position_custody`: `Pubkey`
  - `position_collateral_custody`: `Pubkey`
  - `position_size_usd`: `u64`
  - `position_mint`: `Pubkey`
  - `position_request_key`: `Pubkey`
  - `position_request_mint`: `Pubkey`
  - `position_request_change`: `u8`
  - `position_request_type`: `u8`
  - `has_profit`: `bool`
  - `pnl_delta`: `u64`
  - `owner`: `Pubkey`
  - `pool`: `Pubkey`
  - `size_usd_delta`: `u64`
  - `transfer_amount_usd`: `u64`
  - `transfer_token`: `Option<u64>`
  - `price`: `u64`
  - `price_slippage`: `Option<u64>`
  - `fee_usd`: `u64`
  - `open_time`: `i64`
  - `referral`: `Option<Pubkey>`

### `DecreasePositionPostSwapEvent`
- **Source:** `instructions/decrease_position_post_swap_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d17d210e962f55952`
- **Fields:**
  - `position_request_key`: `Pubkey`
  - `swap_amount`: `u64`
  - `jupiter_minimum_out`: `Option<u64>`

### `IncreasePositionEvent`
- **Source:** `instructions/increase_position_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1df5715534d6bb9984`
- **Fields:**
  - `position_key`: `Pubkey`
  - `position_side`: `u8`
  - `position_custody`: `Pubkey`
  - `position_collateral_custody`: `Pubkey`
  - `position_size_usd`: `u64`
  - `position_mint`: `Pubkey`
  - `position_request_key`: `Pubkey`
  - `position_request_mint`: `Pubkey`
  - `position_request_change`: `u8`
  - `position_request_type`: `u8`
  - `position_request_collateral_delta`: `u64`
  - `owner`: `Pubkey`
  - `pool`: `Pubkey`
  - `size_usd_delta`: `u64`
  - `collateral_usd_delta`: `u64`
  - `collateral_token_delta`: `u64`
  - `price`: `u64`
  - `price_slippage`: `Option<u64>`
  - `fee_token`: `u64`
  - `fee_usd`: `u64`
  - `open_time`: `i64`
  - `referral`: `Option<Pubkey>`

### `IncreasePositionPreSwapEvent`
- **Source:** `instructions/increase_position_pre_swap_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1ded6b098b164b04d5`
- **Fields:**
  - `position_request_key`: `Pubkey`
  - `transfer_amount`: `u64`
  - `collateral_custody_pre_swap_amount`: `u64`

### `InstantCreateLimitOrderEvent`
- **Source:** `instructions/instant_create_limit_order_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d0aa3557381e050c0`
- **Fields:**
  - `owner`: `Pubkey`
  - `pool`: `Pubkey`
  - `position_key`: `Pubkey`
  - `position_side`: `u8`
  - `position_mint`: `Pubkey`
  - `position_custody`: `Pubkey`
  - `position_collateral_mint`: `Pubkey`
  - `position_collateral_custody`: `Pubkey`
  - `position_request_key`: `Pubkey`
  - `position_request_mint`: `Pubkey`
  - `size_usd_delta`: `u64`
  - `collateral_delta`: `u64`
  - `open_time`: `i64`

### `InstantCreateTpslEvent`
- **Source:** `instructions/instant_create_tpsl_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1df236065f188d67c6`
- **Fields:**
  - `owner`: `Pubkey`
  - `pool`: `Pubkey`
  - `position_key`: `Pubkey`
  - `position_side`: `u8`
  - `position_mint`: `Pubkey`
  - `position_custody`: `Pubkey`
  - `position_collateral_custody`: `Pubkey`
  - `position_request_key`: `Pubkey`
  - `position_request_mint`: `Pubkey`
  - `size_usd_delta`: `u64`
  - `collateral_delta`: `u64`
  - `entire_position`: `bool`
  - `open_time`: `i64`

### `InstantDecreasePositionEvent`
- **Source:** `instructions/instant_decrease_position_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1dabad6a19efbe3a3b`
- **Fields:**
  - `position_key`: `Pubkey`
  - `position_side`: `u8`
  - `position_custody`: `Pubkey`
  - `position_collateral_custody`: `Pubkey`
  - `position_size_usd`: `u64`
  - `position_mint`: `Pubkey`
  - `desired_mint`: `Pubkey`
  - `has_profit`: `bool`
  - `pnl_delta`: `u64`
  - `owner`: `Pubkey`
  - `pool`: `Pubkey`
  - `size_usd_delta`: `u64`
  - `transfer_amount_usd`: `u64`
  - `transfer_token`: `u64`
  - `price`: `u64`
  - `price_slippage`: `u64`
  - `fee_usd`: `u64`
  - `open_time`: `i64`
  - `referral`: `Option<Pubkey>`

### `InstantIncreasePositionEvent`
- **Source:** `instructions/instant_increase_position_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1dcdec3904d16a5745`
- **Fields:**
  - `position_key`: `Pubkey`
  - `position_side`: `u8`
  - `position_custody`: `Pubkey`
  - `position_collateral_custody`: `Pubkey`
  - `position_size_usd`: `u64`
  - `position_mint`: `Pubkey`
  - `owner`: `Pubkey`
  - `pool`: `Pubkey`
  - `size_usd_delta`: `u64`
  - `collateral_usd_delta`: `u64`
  - `collateral_token_delta`: `u64`
  - `price`: `u64`
  - `price_slippage`: `u64`
  - `fee_token`: `u64`
  - `fee_usd`: `u64`
  - `open_time`: `i64`
  - `referral`: `Option<Pubkey>`

### `InstantUpdateTpslEvent`
- **Source:** `instructions/instant_update_tpsl_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1db1162f2578f61165`
- **Fields:**
  - `owner`: `Pubkey`
  - `pool`: `Pubkey`
  - `position_key`: `Pubkey`
  - `position_side`: `u8`
  - `position_mint`: `Pubkey`
  - `position_custody`: `Pubkey`
  - `position_collateral_custody`: `Pubkey`
  - `position_request_key`: `Pubkey`
  - `position_request_mint`: `Pubkey`
  - `size_usd_delta`: `u64`
  - `collateral_delta`: `u64`
  - `entire_position`: `bool`
  - `update_time`: `i64`

### `LiquidateFullPositionEvent`
- **Source:** `instructions/liquidate_full_position_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d806547a880485654`
- **Fields:**
  - `position_key`: `Pubkey`
  - `position_side`: `u8`
  - `position_custody`: `Pubkey`
  - `position_collateral_custody`: `Pubkey`
  - `position_collateral_mint`: `Pubkey`
  - `position_mint`: `Pubkey`
  - `position_size_usd`: `u64`
  - `has_profit`: `bool`
  - `pnl_delta`: `u64`
  - `owner`: `Pubkey`
  - `pool`: `Pubkey`
  - `transfer_amount_usd`: `u64`
  - `transfer_token`: `u64`
  - `price`: `u64`
  - `fee_usd`: `u64`
  - `liquidation_fee_usd`: `u64`
  - `open_time`: `i64`

### `PoolSwapEvent`
- **Source:** `instructions/pool_swap_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d286bd41adf8827dc`
- **Fields:**
  - `receiving_custody_key`: `Pubkey`
  - `dispensing_custody_key`: `Pubkey`
  - `pool_key`: `Pubkey`
  - `amount_in`: `u64`
  - `amount_out`: `u64`
  - `swap_usd_amount`: `u64`
  - `amount_out_after_fees`: `u64`
  - `fee_bps`: `u64`
  - `owner_key`: `Pubkey`
  - `receiving_account_key`: `Pubkey`

### `PoolSwapExactOutEvent`
- **Source:** `instructions/pool_swap_exact_out_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d79760b0bc6428e73`
- **Fields:**
  - `receiving_custody_key`: `Pubkey`
  - `dispensing_custody_key`: `Pubkey`
  - `pool_key`: `Pubkey`
  - `amount_in`: `u64`
  - `amount_in_after_fees`: `u64`
  - `amount_out`: `u64`
  - `swap_usd_amount`: `u64`
  - `fee_bps`: `u64`
  - `owner_key`: `Pubkey`
  - `receiving_account_key`: `Pubkey`

### `RemoveLiquidityEvent`
- **Source:** `instructions/remove_liquidity_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d8dc7b67b9f5ed766`
- **Fields:**
  - `custody_key`: `Pubkey`
  - `pool_key`: `Pubkey`
  - `lp_amount_in`: `u64`
  - `remove_amount_usd`: `u64`
  - `fee_bps`: `u64`
  - `remove_token_amount`: `u64`
  - `token_amount_after_fee`: `u64`
  - `post_pool_amount_usd`: `u128`

## Shared types

### `AddCustodyParams`
- `is_stable`: `bool`
- `oracle`: `OracleParams`
- `pricing`: `PricingParams`
- `permissions`: `Permissions`
- `hourly_funding_dbps`: `u64`
- `target_ratio_bps`: `u64`
- `increase_position_bps`: `u64`
- `decrease_position_bps`: `u64`
- `doves_oracle`: `Pubkey`
- `max_position_size_usd`: `u64`
- `jump_rate`: `JumpRateState`

### `AddLiquidity2Params`
- `token_amount_in`: `u64`
- `min_lp_amount_out`: `u64`
- `token_amount_pre_swap`: `Option<u64>`

### `AddPoolParams`
- `name`: `String`
- `limit`: `Limit`
- `fees`: `Fees`
- `max_request_execution_sec`: `i64`

### `AmountAndFee`
- `amount`: `u64`
- `fee`: `u64`
- `fee_bps`: `u64`

### `Assets`
- `fees_reserves`: `u64`
- `owned`: `u64`
- `locked`: `u64`
- `guaranteed_usd`: `u64`
- `global_short_sizes`: `u64`
- `global_short_average_prices`: `u64`

### `ClosePositionRequestParams`
- (empty struct)

### `CreateDecreasePositionMarketRequestParams`
- `collateral_usd_delta`: `u64`
- `size_usd_delta`: `u64`
- `price_slippage`: `u64`
- `jupiter_minimum_out`: `Option<u64>`
- `entire_position`: `Option<bool>`
- `counter`: `u64`

### `CreateDecreasePositionRequest2Params`
- `collateral_usd_delta`: `u64`
- `size_usd_delta`: `u64`
- `request_type`: `RequestType`
- `price_slippage`: `Option<u64>`
- `jupiter_minimum_out`: `Option<u64>`
- `trigger_price`: `Option<u64>`
- `trigger_above_threshold`: `Option<bool>`
- `entire_position`: `Option<bool>`
- `counter`: `u64`

### `CreateIncreasePositionMarketRequestParams`
- `size_usd_delta`: `u64`
- `collateral_token_delta`: `u64`
- `side`: `Side`
- `price_slippage`: `u64`
- `jupiter_minimum_out`: `Option<u64>`
- `counter`: `u64`

### `CreateTokenMetadataParams`
- `name`: `String`
- `symbol`: `String`
- `uri`: `String`

### `DecreasePosition4Params`
- (empty struct)

### `DecreasePositionWithInternalSwapParams`
- (empty struct)

### `Fees`
- `swap_multiplier`: `u64`
- `stable_swap_multiplier`: `u64`
- `add_remove_liquidity_bps`: `u64`
- `swap_bps`: `u64`
- `tax_bps`: `u64`
- `stable_swap_bps`: `u64`
- `stable_swap_tax_bps`: `u64`
- `liquidation_reward_bps`: `u64`
- `protocol_share_bps`: `u64`

### `FundingRateState`
- `cumulative_interest_rate`: `u128`
- `last_update`: `i64`
- `hourly_funding_dbps`: `u64`

### `GetAddLiquidityAmountAndFee2Params`
- `token_amount_in`: `u64`

### `GetAssetsUnderManagement2Params`
- `mode`: `Option<PriceCalcMode>`

### `GetRemoveLiquidityAmountAndFee2Params`
- `lp_amount_in`: `u64`

### `IncreasePosition4Params`
- (empty struct)

### `IncreasePositionPreSwapParams`
- (empty struct)

### `IncreasePositionWithInternalSwapParams`
- (empty struct)

### `InitParams`
- `allow_swap`: `bool`
- `allow_add_liquidity`: `bool`
- `allow_remove_liquidity`: `bool`
- `allow_increase_position`: `bool`
- `allow_decrease_position`: `bool`
- `allow_collateral_withdrawal`: `bool`
- `allow_liquidate_position`: `bool`

### `InstantCreateLimitOrderParams`
- `size_usd_delta`: `u64`
- `collateral_token_delta`: `u64`
- `side`: `Side`
- `trigger_price`: `u64`
- `trigger_above_threshold`: `bool`
- `counter`: `u64`
- `request_time`: `i64`

### `InstantCreateTpslParams`
- `collateral_usd_delta`: `u64`
- `size_usd_delta`: `u64`
- `trigger_price`: `u64`
- `trigger_above_threshold`: `bool`
- `entire_position`: `bool`
- `counter`: `u64`
- `request_time`: `i64`

### `InstantDecreasePositionParams`
- `collateral_usd_delta`: `u64`
- `size_usd_delta`: `u64`
- `price_slippage`: `u64`
- `entire_position`: `Option<bool>`
- `request_time`: `i64`

### `InstantIncreasePositionParams`
- `size_usd_delta`: `u64`
- `collateral_token_delta`: `Option<u64>`
- `side`: `Side`
- `price_slippage`: `u64`
- `request_time`: `i64`

### `InstantUpdateLimitOrderParams`
- `size_usd_delta`: `u64`
- `trigger_price`: `u64`
- `request_time`: `i64`

### `InstantUpdateTpslParams`
- `size_usd_delta`: `u64`
- `trigger_price`: `u64`
- `request_time`: `i64`

### `JumpRateState`
- `min_rate_bps`: `u64`
- `max_rate_bps`: `u64`
- `target_rate_bps`: `u64`
- `target_utilization_rate`: `u64`

### `Limit`
- `max_aum_usd`: `u128`
- `token_weightage_buffer_bps`: `u128`
- `buffer`: `u64`

### `LiquidateFullPosition4Params`
- (empty struct)

### `OperatorSetCustodyConfigParams`
- `pricing`: `PricingParams`
- `hourly_funding_dbps`: `u64`
- `target_ratio_bps`: `u64`
- `increase_position_bps`: `u64`
- `decrease_position_bps`: `u64`
- `max_position_size_usd`: `u64`
- `jump_rate`: `JumpRateState`

### `OperatorSetPoolConfigParams`
- `fees`: `Fees`
- `limit`: `Limit`
- `max_request_execution_sec`: `i64`

### `OracleParams`
- `oracle_account`: `Pubkey`
- `oracle_type`: `OracleType`
- `max_price_error`: `u64`
- `max_price_age_sec`: `u32`

### `OraclePrice`
- `price`: `u64`
- `exponent`: `i32`

### `OracleType` (enum)
- `None`
- `Test`
- `Pyth`

### `Permissions`
- `allow_swap`: `bool`
- `allow_add_liquidity`: `bool`
- `allow_remove_liquidity`: `bool`
- `allow_increase_position`: `bool`
- `allow_decrease_position`: `bool`
- `allow_collateral_withdrawal`: `bool`
- `allow_liquidate_position`: `bool`

### `PoolApr`
- `last_updated`: `i64`
- `fee_apr_bps`: `u64`
- `realized_fee_usd`: `u64`

### `PriceCalcMode` (enum)
- `Min`
- `Max`
- `Ignore`

### `PriceStaleTolerance` (enum)
- `Strict`
- `Loose`

### `PricingParams`
- `trade_impact_fee_scalar`: `u64`
- `buffer`: `u64`
- `swap_spread`: `u64`
- `max_leverage`: `u64`
- `max_global_long_sizes`: `u64`
- `max_global_short_sizes`: `u64`

### `RefreshAssetsUnderManagementParams`
- (empty struct)

### `RemoveLiquidity2Params`
- `lp_amount_in`: `u64`
- `min_amount_out`: `u64`

### `RequestChange` (enum)
- `None`
- `Increase`
- `Decrease`

### `RequestType` (enum)
- `Market`
- `Trigger`

### `SetCustodyConfigParams`
- `oracle`: `OracleParams`
- `pricing`: `PricingParams`
- `permissions`: `Permissions`
- `hourly_funding_dbps`: `u64`
- `target_ratio_bps`: `u64`
- `increase_position_bps`: `u64`
- `decrease_position_bps`: `u64`
- `doves_oracle`: `Pubkey`
- `max_position_size_usd`: `u64`
- `jump_rate`: `JumpRateState`

### `SetPerpetualsConfigParams`
- `permissions`: `Permissions`

### `SetPoolConfigParams`
- `fees`: `Fees`
- `limit`: `Limit`
- `max_request_execution_sec`: `i64`

### `SetTestTimeParams`
- `time`: `i64`

### `Side` (enum)
- `None`
- `Long`
- `Short`

### `Swap2Params`
- `amount_in`: `u64`
- `min_amount_out`: `u64`

### `TestInitParams`
- `allow_swap`: `bool`
- `allow_add_liquidity`: `bool`
- `allow_remove_liquidity`: `bool`
- `allow_increase_position`: `bool`
- `allow_decrease_position`: `bool`
- `allow_collateral_withdrawal`: `bool`
- `allow_liquidate_position`: `bool`

### `TransferAdminParams`
- (empty struct)

### `UpdateDecreasePositionRequest2Params`
- `size_usd_delta`: `u64`
- `trigger_price`: `u64`

### `WithdrawFees2Params`
- (empty struct)
