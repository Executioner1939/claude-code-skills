# Raydium Launchpad

- **Crate:** `carbon-raydium-launchpad-decoder`
- **Program ID:** `LanMV9sAd7wArD4vJFi2qDdfnVhFxYSUg6eADduJ3uj`
- **Decoder struct:** `RaydiumLaunchpadDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in instructions/)
- **Discriminator style:** anchor 8-byte

## Account types

### `GlobalConfig`
- **Fields:**
  - `epoch`: `u64`
  - `curve_type`: `u8`
  - `index`: `u16`
  - `migrate_fee`: `u64`
  - `trade_fee_rate`: `u64`
  - `max_share_fee_rate`: `u64`
  - `min_base_supply`: `u64`
  - `max_lock_rate`: `u64`
  - `min_base_sell_rate`: `u64`
  - `min_base_migrate_rate`: `u64`
  - `min_quote_fund_raising`: `u64`
  - `quote_mint`: `Pubkey`
  - `protocol_fee_owner`: `Pubkey`
  - `migrate_fee_owner`: `Pubkey`
  - `migrate_to_amm_wallet`: `Pubkey`
  - `migrate_to_cpswap_wallet`: `Pubkey`
  - `padding`: `[u64; 16]`

### `PlatformConfig`
- **Fields:**
  - `epoch`: `u64`
  - `platform_fee_wallet`: `Pubkey`
  - `platform_nft_wallet`: `Pubkey`
  - `platform_scale`: `u64`
  - `creator_scale`: `u64`
  - `burn_scale`: `u64`
  - `fee_rate`: `u64`
  - `name`: `[u8; 64]`
  - `web`: `[u8; 256]`
  - `img`: `[u8; 256]`
  - `cpswap_config`: `Pubkey`
  - `creator_fee_rate`: `u64`
  - `transfer_fee_extension_auth`: `Pubkey`
  - `padding`: `[u8; 180]`
  - `curve_params`: `Vec<PlatformCurveParam>`

### `PoolState`
- **Fields:**
  - `epoch`: `u64`
  - `auth_bump`: `u8`
  - `status`: `u8`
  - `base_decimals`: `u8`
  - `quote_decimals`: `u8`
  - `migrate_type`: `u8`
  - `supply`: `u64`
  - `total_base_sell`: `u64`
  - `virtual_base`: `u64`
  - `virtual_quote`: `u64`
  - `real_base`: `u64`
  - `real_quote`: `u64`
  - `total_quote_fund_raising`: `u64`
  - `quote_protocol_fee`: `u64`
  - `platform_fee`: `u64`
  - `migrate_fee`: `u64`
  - `vesting_schedule`: `VestingSchedule`
  - `global_config`: `Pubkey`
  - `platform_config`: `Pubkey`
  - `base_mint`: `Pubkey`
  - `quote_mint`: `Pubkey`
  - `base_vault`: `Pubkey`
  - `quote_vault`: `Pubkey`
  - `creator`: `Pubkey`
  - `token_program_flag`: `u8`
  - `amm_creator_fee_on`: `AmmCreatorFeeOn`
  - `padding`: `[u8; 62]`

### `VestingRecord`
- **Fields:**
  - `epoch`: `u64`
  - `pool`: `Pubkey`
  - `beneficiary`: `Pubkey`
  - `claimed_amount`: `u64`
  - `token_share_amount`: `u64`
  - `padding`: `[u64; 8]`

## Instructions

### `BuyExactIn`
- **Discriminator:** `0xfaea0d7bd59c13ec`
- **Args:**
  - `amount_in`: `u64`
  - `minimum_amount_out`: `u64`
  - `share_fee_rate`: `u64`
- **Account variants:**
  - `15 accounts:` `payer`, `authority`, `global_config`, `platform_config`, `pool_state`, `user_base_token`, `user_quote_token`, `base_vault`, `quote_vault`, `base_token_mint`, `quote_token_mint`, `base_token_program`, `quote_token_program`, `event_authority`, `program`

### `BuyExactOut`
- **Discriminator:** `0x18d3742869039938`
- **Args:**
  - `amount_out`: `u64`
  - `maximum_amount_in`: `u64`
  - `share_fee_rate`: `u64`
- **Account variants:**
  - `15 accounts:` `payer`, `authority`, `global_config`, `platform_config`, `pool_state`, `user_base_token`, `user_quote_token`, `base_vault`, `quote_vault`, `base_token_mint`, `quote_token_mint`, `base_token_program`, `quote_token_program`, `event_authority`, `program`

### `ClaimCreatorFee`
- **Discriminator:** `0x1a618acb84ab8dfc`
- **Args:** (none)
- **Account variants:**
  - `8 accounts:` `creator`, `fee_vault_authority`, `creator_fee_vault`, `recipient_token_account`, `quote_mint`, `token_program`, `system_program`, `associated_token_program`

### `ClaimPlatformFee`
- **Discriminator:** `0x9c27d0874ced3d48`
- **Args:** (none)
- **Account variants:**
  - `10 accounts:` `platform_fee_wallet`, `authority`, `pool_state`, `platform_config`, `quote_vault`, `recipient_token_account`, `quote_mint`, `token_program`, `system_program`, `associated_token_program`

### `ClaimPlatformFeeFromVault`
- **Discriminator:** `0x75f1c6a8f8da501d`
- **Args:** (none)
- **Account variants:**
  - `9 accounts:` `platform_fee_wallet`, `fee_vault_authority`, `platform_config`, `platform_fee_vault`, `recipient_token_account`, `quote_mint`, `token_program`, `system_program`, `associated_token_program`

### `ClaimVestedToken`
- **Discriminator:** `0x3121681ebd9d4f23`
- **Args:** (none)
- **Account variants:**
  - `10 accounts:` `beneficiary`, `authority`, `pool_state`, `vesting_record`, `base_vault`, `user_base_token`, `base_token_mint`, `base_token_program`, `system_program`, `associated_token_program`

### `CollectFee`
- **Discriminator:** `0x3cadf767045d8230`
- **Args:** (none)
- **Account variants:**
  - `8 accounts:` `owner`, `authority`, `pool_state`, `global_config`, `quote_vault`, `quote_mint`, `recipient_token_account`, `token_program`

### `CollectMigrateFee`
- **Discriminator:** `0xffba96dfeb76c9ba`
- **Args:** (none)
- **Account variants:**
  - `8 accounts:` `owner`, `authority`, `pool_state`, `global_config`, `quote_vault`, `quote_mint`, `recipient_token_account`, `token_program`

### `CreateConfig`
- **Discriminator:** `0xc9cff3724b6f2fbd`
- **Args:**
  - `curve_type`: `u8`
  - `index`: `u16`
  - `migrate_fee`: `u64`
  - `trade_fee_rate`: `u64`
- **Account variants:**
  - `8 accounts:` `owner`, `global_config`, `quote_token_mint`, `protocol_fee_owner`, `migrate_fee_owner`, `migrate_to_amm_wallet`, `migrate_to_cpswap_wallet`, `system_program`

### `CreatePlatformConfig`
- **Discriminator:** `0xb05ac4affd71dc14`
- **Args:**
  - `platform_params`: `PlatformParams`
- **Account variants:**
  - `7 accounts:` `platform_admin`, `platform_fee_wallet`, `platform_nft_wallet`, `platform_config`, `cpswap_config`, `system_program`, `transfer_fee_extension_authority`

### `CreateVestingAccount`
- **Discriminator:** `0x81b2020dd9ace6da`
- **Args:**
  - `share_amount`: `u64`
- **Account variants:**
  - `5 accounts:` `creator`, `beneficiary`, `pool_state`, `vesting_record`, `system_program`

### `Initialize`
- **Discriminator:** `0xafaf6d1f0d989bed`
- **Args:**
  - `base_mint_param`: `MintParams`
  - `curve_param`: `CurveParams`
  - `vesting_param`: `VestingParams`
- **Account variants:**
  - `18 accounts:` `payer`, `creator`, `global_config`, `platform_config`, `authority`, `pool_state`, `base_mint`, `quote_mint`, `base_vault`, `quote_vault`, `metadata_account`, `base_token_program`, `quote_token_program`, `metadata_program`, `system_program`, `rent_program`, `event_authority`, `program`

### `InitializeV2`
- **Discriminator:** `0x4399af27da102620`
- **Args:**
  - `base_mint_param`: `MintParams`
  - `curve_param`: `CurveParams`
  - `vesting_param`: `VestingParams`
  - `amm_fee_on`: `AmmCreatorFeeOn`
- **Account variants:**
  - `18 accounts:` `payer`, `creator`, `global_config`, `platform_config`, `authority`, `pool_state`, `base_mint`, `quote_mint`, `base_vault`, `quote_vault`, `metadata_account`, `base_token_program`, `quote_token_program`, `metadata_program`, `system_program`, `rent_program`, `event_authority`, `program`

### `InitializeWithToken2022`
- **Discriminator:** `0x25be7ede2c9aab11`
- **Args:**
  - `base_mint_param`: `MintParams`
  - `curve_param`: `CurveParams`
  - `vesting_param`: `VestingParams`
  - `amm_fee_on`: `AmmCreatorFeeOn`
  - `transfer_fee_extension_param`: `Option<TransferFeeExtensionParams>`
- **Account variants:**
  - `15 accounts:` `payer`, `creator`, `global_config`, `platform_config`, `authority`, `pool_state`, `base_mint`, `quote_mint`, `base_vault`, `quote_vault`, `base_token_program`, `quote_token_program`, `system_program`, `event_authority`, `program`

### `MigrateToAmm`
- **Discriminator:** `0xcf52c091fecf91df`
- **Args:**
  - `base_lot_size`: `u64`
  - `quote_lot_size`: `u64`
  - `market_vault_signer_nonce`: `u8`
- **Account variants:**
  - `32 accounts:` `payer`, `base_mint`, `quote_mint`, `openbook_program`, `market`, `request_queue`, `event_queue`, `bids`, `asks`, `market_vault_signer`, `market_base_vault`, `market_quote_vault`, `amm_program`, `amm_pool`, `amm_authority`, `amm_open_orders`, `amm_lp_mint`, `amm_base_vault`, `amm_quote_vault`, `amm_target_orders`, `amm_config`, `amm_create_fee_destination`, `authority`, `pool_state`, `global_config`, `base_vault`, `quote_vault`, `pool_lp_token`, `spl_token_program`, `associated_token_program`, `system_program`, `rent_program`

### `MigrateToCpswap`
- **Discriminator:** `0x885cc8671cda908c`
- **Args:** (none)
- **Account variants:**
  - `28 accounts:` `payer`, `base_mint`, `quote_mint`, `platform_config`, `cpswap_program`, `cpswap_pool`, `cpswap_authority`, `cpswap_lp_mint`, `cpswap_base_vault`, `cpswap_quote_vault`, `cpswap_config`, `cpswap_create_pool_fee`, `cpswap_observation`, `lock_program`, `lock_authority`, `lock_lp_vault`, `authority`, `pool_state`, `global_config`, `base_vault`, `quote_vault`, `pool_lp_token`, `base_token_program`, `quote_token_program`, `associated_token_program`, `system_program`, `rent_program`, `metadata_program`

### `RemovePlatformCurveParam`
- **Discriminator:** `0x1b1e3ea95de01891`
- **Args:**
  - `index`: `u8`
- **Account variants:**
  - `2 accounts:` `platform_admin`, `platform_config`

### `SellExactIn`
- **Discriminator:** `0x9527de9bd37c981a`
- **Args:**
  - `amount_in`: `u64`
  - `minimum_amount_out`: `u64`
  - `share_fee_rate`: `u64`
- **Account variants:**
  - `15 accounts:` `payer`, `authority`, `global_config`, `platform_config`, `pool_state`, `user_base_token`, `user_quote_token`, `base_vault`, `quote_vault`, `base_token_mint`, `quote_token_mint`, `base_token_program`, `quote_token_program`, `event_authority`, `program`

### `SellExactOut`
- **Discriminator:** `0x5fc8472208090ba6`
- **Args:**
  - `amount_out`: `u64`
  - `maximum_amount_in`: `u64`
  - `share_fee_rate`: `u64`
- **Account variants:**
  - `15 accounts:` `payer`, `authority`, `global_config`, `platform_config`, `pool_state`, `user_base_token`, `user_quote_token`, `base_vault`, `quote_vault`, `base_token_mint`, `quote_token_mint`, `base_token_program`, `quote_token_program`, `event_authority`, `program`

### `UpdateConfig`
- **Discriminator:** `0x1d9efcbf0a53db63`
- **Args:**
  - `param`: `u8`
  - `value`: `u64`
- **Account variants:**
  - `2 accounts:` `owner`, `global_config`

### `UpdatePlatformConfig`
- **Discriminator:** `0xc33c4c81922d438f`
- **Args:**
  - `param`: `PlatformConfigParam`
- **Account variants:**
  - `2 accounts:` `platform_admin`, `platform_config`

### `UpdatePlatformCurveParam`
- **Discriminator:** `0x8a908afadc800439`
- **Args:**
  - `index`: `u8`
  - `bonding_curve_param`: `BondingCurveParam`
- **Account variants:**
  - `4 accounts:` `platform_admin`, `platform_config`, `global_config`, `system_program`

## CPI events

### `ClaimVestedEvent`
- **Source:** `instructions/claim_vested_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d15c2725778d3e220`
- **Fields:**
  - `pool_state`: `Pubkey`
  - `beneficiary`: `Pubkey`
  - `claim_amount`: `u64`

### `CreateVestingEvent`
- **Source:** `instructions/create_vesting_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d96980bb334d2bf7d`
- **Fields:**
  - `pool_state`: `Pubkey`
  - `beneficiary`: `Pubkey`
  - `share_amount`: `u64`

### `PoolCreateEvent`
- **Source:** `instructions/pool_create_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d97d7e20976a173ae`
- **Fields:**
  - `pool_state`: `Pubkey`
  - `creator`: `Pubkey`
  - `config`: `Pubkey`
  - `base_mint_param`: `MintParams`
  - `curve_param`: `CurveParams`
  - `vesting_param`: `VestingParams`
  - `amm_fee_on`: `AmmCreatorFeeOn`

### `TradeEvent`
- **Source:** `instructions/trade_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1dbddb7fd34ee661ee`
- **Fields:**
  - `pool_state`: `Pubkey`
  - `total_base_sell`: `u64`
  - `virtual_base`: `u64`
  - `virtual_quote`: `u64`
  - `real_base_before`: `u64`
  - `real_quote_before`: `u64`
  - `real_base_after`: `u64`
  - `real_quote_after`: `u64`
  - `amount_in`: `u64`
  - `amount_out`: `u64`
  - `protocol_fee`: `u64`
  - `platform_fee`: `u64`
  - `creator_fee`: `u64`
  - `share_fee`: `u64`
  - `trade_direction`: `TradeDirection`
  - `pool_status`: `PoolStatus`
  - `exact_in`: `bool`

## Shared types

### `AmmCreatorFeeOn`
- enum variants: `QuoteToken`, `BothToken`

### `BondingCurveParam`
- `migrate_type`: `u8`
- `migrate_cpmm_fee_on`: `u8`
- `supply`: `u64`
- `total_base_sell`: `u64`
- `total_quote_fund_raising`: `u64`
- `total_locked_amount`: `u64`
- `cliff_period`: `u64`
- `unlock_period`: `u64`

### `ClaimVestedEvent`
- `pool_state`: `Pubkey`
- `beneficiary`: `Pubkey`
- `claim_amount`: `u64`

### `ConstantCurve`
- `supply`: `u64`
- `total_base_sell`: `u64`
- `total_quote_fund_raising`: `u64`
- `migrate_type`: `u8`

### `CreateVestingEvent`
- `pool_state`: `Pubkey`
- `beneficiary`: `Pubkey`
- `share_amount`: `u64`

### `CurveParams`
- enum variants: `Constant { data: ConstantCurve }`, `Fixed { data: FixedCurve }`, `Linear { data: LinearCurve }`

### `FixedCurve`
- `supply`: `u64`
- `total_quote_fund_raising`: `u64`
- `migrate_type`: `u8`

### `GlobalConfig`
- `epoch`: `u64`
- `curve_type`: `u8`
- `index`: `u16`
- `migrate_fee`: `u64`
- `trade_fee_rate`: `u64`
- `max_share_fee_rate`: `u64`
- `min_base_supply`: `u64`
- `max_lock_rate`: `u64`
- `min_base_sell_rate`: `u64`
- `min_base_migrate_rate`: `u64`
- `min_quote_fund_raising`: `u64`
- `quote_mint`: `Pubkey`
- `protocol_fee_owner`: `Pubkey`
- `migrate_fee_owner`: `Pubkey`
- `migrate_to_amm_wallet`: `Pubkey`
- `migrate_to_cpswap_wallet`: `Pubkey`
- `padding`: `[u64; 16]`

### `LinearCurve`
- `supply`: `u64`
- `total_quote_fund_raising`: `u64`
- `migrate_type`: `u8`

### `MigrateNftInfo`
- `platform_scale`: `u64`
- `creator_scale`: `u64`
- `burn_scale`: `u64`

### `MintParams`
- `decimals`: `u8`
- `name`: `String`
- `symbol`: `String`
- `uri`: `String`

### `PlatformConfig`
- `epoch`: `u64`
- `platform_fee_wallet`: `Pubkey`
- `platform_nft_wallet`: `Pubkey`
- `platform_scale`: `u64`
- `creator_scale`: `u64`
- `burn_scale`: `u64`
- `fee_rate`: `u64`
- `name`: `[u8; 64]`
- `web`: `[u8; 256]`
- `img`: `[u8; 256]`
- `cpswap_config`: `Pubkey`
- `creator_fee_rate`: `u64`
- `transfer_fee_extension_auth`: `Pubkey`
- `padding`: `[u8; 180]`
- `curve_params`: `Vec<PlatformCurveParam>`

### `PlatformConfigInfo`
- `fee_wallet`: `Pubkey`
- `nft_wallet`: `Pubkey`
- `migrate_nft_info`: `MigrateNftInfo`
- `fee_rate`: `u64`
- `name`: `String`
- `web`: `String`
- `img`: `String`
- `transfer_fee_extension_auth`: `Pubkey`
- `creator_fee_rate`: `u64`

### `PlatformConfigParam`
- enum variants: `FeeWallet(Pubkey)`, `NFTWallet(Pubkey)`, `MigrateNftInfo(MigrateNftInfo)`, `FeeRate(u64)`, `Name(String)`, `Web(String)`, `Img(String)`, `CpSwapConfig`, `AllInfo(PlatformConfigInfo)`

### `PlatformCurveParam`
- `epoch`: `u64`
- `index`: `u8`
- `global_config`: `Pubkey`
- `bonding_curve_param`: `BondingCurveParam`
- `padding`: `[u64; 50]`

### `PlatformParams`
- `migrate_nft_info`: `MigrateNftInfo`
- `fee_rate`: `u64`
- `name`: `String`
- `web`: `String`
- `img`: `String`
- `creator_fee_rate`: `u64`

### `PoolCreateEvent`
- `pool_state`: `Pubkey`
- `creator`: `Pubkey`
- `config`: `Pubkey`
- `base_mint_param`: `MintParams`
- `curve_param`: `CurveParams`
- `vesting_param`: `VestingParams`
- `amm_fee_on`: `AmmCreatorFeeOn`

### `PoolState`
- `epoch`: `u64`
- `auth_bump`: `u8`
- `status`: `u8`
- `base_decimals`: `u8`
- `quote_decimals`: `u8`
- `migrate_type`: `u8`
- `supply`: `u64`
- `total_base_sell`: `u64`
- `virtual_base`: `u64`
- `virtual_quote`: `u64`
- `real_base`: `u64`
- `real_quote`: `u64`
- `total_quote_fund_raising`: `u64`
- `quote_protocol_fee`: `u64`
- `platform_fee`: `u64`
- `migrate_fee`: `u64`
- `vesting_schedule`: `VestingSchedule`
- `global_config`: `Pubkey`
- `platform_config`: `Pubkey`
- `base_mint`: `Pubkey`
- `quote_mint`: `Pubkey`
- `base_vault`: `Pubkey`
- `quote_vault`: `Pubkey`
- `creator`: `Pubkey`
- `token_program_flag`: `u8`
- `amm_creator_fee_on`: `AmmCreatorFeeOn`
- `padding`: `[u8; 62]`

### `PoolStatus`
- enum variants: `Fund`, `Migrate`, `Trade`

### `TradeDirection`
- enum variants: `Buy`, `Sell`

### `TradeEvent`
- `pool_state`: `Pubkey`
- `total_base_sell`: `u64`
- `virtual_base`: `u64`
- `virtual_quote`: `u64`
- `real_base_before`: `u64`
- `real_quote_before`: `u64`
- `real_base_after`: `u64`
- `real_quote_after`: `u64`
- `amount_in`: `u64`
- `amount_out`: `u64`
- `protocol_fee`: `u64`
- `platform_fee`: `u64`
- `creator_fee`: `u64`
- `share_fee`: `u64`
- `trade_direction`: `TradeDirection`
- `pool_status`: `PoolStatus`
- `exact_in`: `bool`

### `TransferFeeExtensionParams`
- `transfer_fee_basis_points`: `u16`
- `maximum_fee`: `u64`

### `VestingParams`
- `total_locked_amount`: `u64`
- `cliff_period`: `u64`
- `unlock_period`: `u64`

### `VestingRecord`
- `epoch`: `u64`
- `pool`: `Pubkey`
- `beneficiary`: `Pubkey`
- `claimed_amount`: `u64`
- `token_share_amount`: `u64`
- `padding`: `[u64; 8]`

### `VestingSchedule`
- `total_locked_amount`: `u64`
- `cliff_period`: `u64`
- `unlock_period`: `u64`
- `start_time`: `u64`
- `allocated_share_amount`: `u64`
