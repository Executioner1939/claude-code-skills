# Meteora Pools

- **Crate:** `carbon-meteora-pools-decoder`
- **Program ID:** `Eo7WjKq67rjJQSZxS6z3YkapzY3eMj6Xy8X5EQVn5UaB`
- **Decoder struct:** `MeteoraPoolsDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in instructions/)
- **Discriminator style:** anchor 8-byte (events 16-byte)

## Account types

### `Config`
- **Fields:**
  - `pool_fees`: `PoolFees`
  - `activation_duration`: `u64`
  - `vault_config_key`: `Pubkey`
  - `pool_creator_authority`: `Pubkey`
  - `activation_type`: `u8`
  - `partner_fee_numerator`: `u64`
  - `padding`: `[u8; 219]`

### `LockEscrow`
- **Fields:**
  - `pool`: `Pubkey`
  - `owner`: `Pubkey`
  - `escrow_vault`: `Pubkey`
  - `bump`: `u8`
  - `total_locked_amount`: `u64`
  - `lp_per_token`: `u128`
  - `unclaimed_fee_pending`: `u64`
  - `a_fee`: `u64`
  - `b_fee`: `u64`

### `Pool`
- **Fields:**
  - `lp_mint`: `Pubkey`
  - `token_a_mint`: `Pubkey`
  - `token_b_mint`: `Pubkey`
  - `a_vault`: `Pubkey`
  - `b_vault`: `Pubkey`
  - `a_vault_lp`: `Pubkey`
  - `b_vault_lp`: `Pubkey`
  - `a_vault_lp_bump`: `u8`
  - `enabled`: `bool`
  - `protocol_token_a_fee`: `Pubkey`
  - `protocol_token_b_fee`: `Pubkey`
  - `fee_last_updated_at`: `u64`
  - `padding0`: `[u8; 24]`
  - `fees`: `PoolFees`
  - `pool_type`: `PoolType`
  - `stake`: `Pubkey`
  - `total_locked_lp`: `u64`
  - `bootstrapping`: `Bootstrapping`
  - `partner_info`: `PartnerInfo`
  - `padding`: `Padding`
  - `curve_type`: `CurveType`

## Instructions

### `AddBalanceLiquidity`
- **Discriminator:** `0xa8e3323ebdab54b0`
- **Args:**
  - `pool_token_amount`: `u64`
  - `maximum_token_a_amount`: `u64`
  - `maximum_token_b_amount`: `u64`
- **Account variants:**
  - `16 accounts:` `pool`, `lp_mint`, `user_pool_lp`, `a_vault_lp`, `b_vault_lp`, `a_vault`, `b_vault`, `a_vault_lp_mint`, `b_vault_lp_mint`, `a_token_vault`, `b_token_vault`, `user_a_token`, `user_b_token`, `user`, `vault_program`, `token_program`

### `AddImbalanceLiquidity`
- **Discriminator:** `0x4f237a54ad0f5dbf`
- **Args:**
  - `minimum_pool_token_amount`: `u64`
  - `token_a_amount`: `u64`
  - `token_b_amount`: `u64`
- **Account variants:**
  - `16 accounts:` `pool`, `lp_mint`, `user_pool_lp`, `a_vault_lp`, `b_vault_lp`, `a_vault`, `b_vault`, `a_vault_lp_mint`, `b_vault_lp_mint`, `a_token_vault`, `b_token_vault`, `user_a_token`, `user_b_token`, `user`, `vault_program`, `token_program`

### `AddLiquidityEvent`
- **Discriminator:** `0xe445a52e51cb9a1d1f5e7d5ae3343dba`
- **Args:**
  - `lp_mint_amount`: `u64`
  - `token_a_amount`: `u64`
  - `token_b_amount`: `u64`

### `BootstrapLiquidity`
- **Discriminator:** `0x04e4d747e1fd77ce`
- **Args:**
  - `token_a_amount`: `u64`
  - `token_b_amount`: `u64`
- **Account variants:**
  - `16 accounts:` `pool`, `lp_mint`, `user_pool_lp`, `a_vault_lp`, `b_vault_lp`, `a_vault`, `b_vault`, `a_vault_lp_mint`, `b_vault_lp_mint`, `a_token_vault`, `b_token_vault`, `user_a_token`, `user_b_token`, `user`, `vault_program`, `token_program`

### `BootstrapLiquidityEvent`
- **Discriminator:** `0xe445a52e51cb9a1d797f26885c370ef7`
- **Args:**
  - `lp_mint_amount`: `u64`
  - `token_a_amount`: `u64`
  - `token_b_amount`: `u64`
  - `pool`: `Pubkey`

### `ClaimFee`
- **Discriminator:** `0xa9204f8988e84689`
- **Args:**
  - `max_amount`: `u64`
- **Account variants:**
  - `18 accounts:` `pool`, `lp_mint`, `lock_escrow`, `owner`, `source_tokens`, `escrow_vault`, `token_program`, `a_token_vault`, `b_token_vault`, `a_vault`, `b_vault`, `a_vault_lp`, `b_vault_lp`, `a_vault_lp_mint`, `b_vault_lp_mint`, `user_a_token`, `user_b_token`, `vault_program`

### `ClaimFeeEvent`
- **Discriminator:** `0xe445a52e51cb9a1d4b7a9a308c4a7ba3`
- **Args:**
  - `pool`: `Pubkey`
  - `owner`: `Pubkey`
  - `amount`: `u64`
  - `a_fee`: `u64`
  - `b_fee`: `u64`

### `CloseConfig`
- **Discriminator:** `0x9109489d5f7d3d55`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `config`, `admin`, `rent_receiver`

### `CloseConfigEvent`
- **Discriminator:** `0xe445a52e51cb9a1df9b56c5904965aae`
- **Args:**
  - `config`: `Pubkey`

### `CreateConfig`
- **Discriminator:** `0xc9cff3724b6f2fbd`
- **Args:**
  - `config_parameters`: `ConfigParameters`
- **Account variants:**
  - `3 accounts:` `config`, `admin`, `system_program`

### `CreateConfigEvent`
- **Discriminator:** `0xe445a52e51cb9a1dc7980a1327279d68`
- **Args:**
  - `trade_fee_numerator`: `u64`
  - `protocol_trade_fee_numerator`: `u64`
  - `config`: `Pubkey`

### `CreateLockEscrow`
- **Discriminator:** `0x3657a51345e3dae0`
- **Args:** (none)
- **Account variants:**
  - `6 accounts:` `pool`, `lock_escrow`, `owner`, `lp_mint`, `payer`, `system_program`

### `CreateLockEscrowEvent`
- **Discriminator:** `0xe445a52e51cb9a1d4a5e6a8d3111626d`
- **Args:**
  - `pool`: `Pubkey`
  - `owner`: `Pubkey`

### `CreateMintMetadata`
- **Discriminator:** `0x0d46a829fa64945a`
- **Args:** (none)
- **Account variants:**
  - `7 accounts:` `pool`, `lp_mint`, `a_vault_lp`, `mint_metadata`, `metadata_program`, `system_program`, `payer`

### `EnableOrDisablePool`
- **Discriminator:** `0x8006e48337a134a9`
- **Args:**
  - `enable`: `bool`
- **Account variants:**
  - `2 accounts:` `pool`, `admin`

### `GetPoolInfo`
- **Discriminator:** `0x0930dc6516f04ec8`
- **Args:** (none)
- **Account variants:**
  - `8 accounts:` `pool`, `lp_mint`, `a_vault_lp`, `b_vault_lp`, `a_vault`, `b_vault`, `a_vault_lp_mint`, `b_vault_lp_mint`

### `InitializeCustomizablePermissionlessConstantProductPool`
- **Discriminator:** `0x9118acc2db7d03be`
- **Args:**
  - `token_a_amount`: `u64`
  - `token_b_amount`: `u64`
  - `params`: `CustomizableParams`
- **Account variants:**
  - `25 accounts:` `pool`, `lp_mint`, `token_a_mint`, `token_b_mint`, `a_vault`, `b_vault`, `a_token_vault`, `b_token_vault`, `a_vault_lp_mint`, `b_vault_lp_mint`, `a_vault_lp`, `b_vault_lp`, `payer_token_a`, `payer_token_b`, `payer_pool_lp`, `protocol_token_a_fee`, `protocol_token_b_fee`, `payer`, `rent`, `mint_metadata`, `metadata_program`, `vault_program`, `token_program`, `associated_token_program`, `system_program`

### `InitializePermissionedPool`
- **Discriminator:** `0x4d55b29d3230d47e`
- **Args:**
  - `curve_type`: `CurveType`
- **Account variants:**
  - `24 accounts:` `pool`, `lp_mint`, `token_a_mint`, `token_b_mint`, `a_vault`, `b_vault`, `a_vault_lp_mint`, `b_vault_lp_mint`, `a_vault_lp`, `b_vault_lp`, `admin_token_a`, `admin_token_b`, `admin_pool_lp`, `protocol_token_a_fee`, `protocol_token_b_fee`, `admin`, `fee_owner`, `rent`, `mint_metadata`, `metadata_program`, `vault_program`, `token_program`, `associated_token_program`, `system_program`

### `InitializePermissionlessConstantProductPoolWithConfig`
- **Discriminator:** `0x07a68aabceabecf4`
- **Args:**
  - `token_a_amount`: `u64`
  - `token_b_amount`: `u64`
- **Account variants:**
  - `26 accounts:` `pool`, `config`, `lp_mint`, `token_a_mint`, `token_b_mint`, `a_vault`, `b_vault`, `a_token_vault`, `b_token_vault`, `a_vault_lp_mint`, `b_vault_lp_mint`, `a_vault_lp`, `b_vault_lp`, `payer_token_a`, `payer_token_b`, `payer_pool_lp`, `protocol_token_a_fee`, `protocol_token_b_fee`, `payer`, `rent`, `mint_metadata`, `metadata_program`, `vault_program`, `token_program`, `associated_token_program`, `system_program`

### `InitializePermissionlessConstantProductPoolWithConfig2`
- **Discriminator:** `0x3095dc823d0b09b2`
- **Args:**
  - `token_a_amount`: `u64`
  - `token_b_amount`: `u64`
  - `activation_point`: `Option<u64>`
- **Account variants:**
  - `26 accounts:` `pool`, `config`, `lp_mint`, `token_a_mint`, `token_b_mint`, `a_vault`, `b_vault`, `a_token_vault`, `b_token_vault`, `a_vault_lp_mint`, `b_vault_lp_mint`, `a_vault_lp`, `b_vault_lp`, `payer_token_a`, `payer_token_b`, `payer_pool_lp`, `protocol_token_a_fee`, `protocol_token_b_fee`, `payer`, `rent`, `mint_metadata`, `metadata_program`, `vault_program`, `token_program`, `associated_token_program`, `system_program`

### `InitializePermissionlessPool`
- **Discriminator:** `0x76ad299dad486167`
- **Args:**
  - `curve_type`: `CurveType`
  - `token_a_amount`: `u64`
  - `token_b_amount`: `u64`
- **Account variants:**
  - `26 accounts:` `pool`, `lp_mint`, `token_a_mint`, `token_b_mint`, `a_vault`, `b_vault`, `a_token_vault`, `b_token_vault`, `a_vault_lp_mint`, `b_vault_lp_mint`, `a_vault_lp`, `b_vault_lp`, `payer_token_a`, `payer_token_b`, `payer_pool_lp`, `protocol_token_a_fee`, `protocol_token_b_fee`, `payer`, `fee_owner`, `rent`, `mint_metadata`, `metadata_program`, `vault_program`, `token_program`, `associated_token_program`, `system_program`

### `InitializePermissionlessPoolWithFeeTier`
- **Discriminator:** `0x06874493e552a971`
- **Args:**
  - `curve_type`: `CurveType`
  - `trade_fee_bps`: `u64`
  - `token_a_amount`: `u64`
  - `token_b_amount`: `u64`
- **Account variants:**
  - `26 accounts:` `pool`, `lp_mint`, `token_a_mint`, `token_b_mint`, `a_vault`, `b_vault`, `a_token_vault`, `b_token_vault`, `a_vault_lp_mint`, `b_vault_lp_mint`, `a_vault_lp`, `b_vault_lp`, `payer_token_a`, `payer_token_b`, `payer_pool_lp`, `protocol_token_a_fee`, `protocol_token_b_fee`, `payer`, `fee_owner`, `rent`, `mint_metadata`, `metadata_program`, `vault_program`, `token_program`, `associated_token_program`, `system_program`

### `Lock`
- **Discriminator:** `0x1513d02bed3eff57`
- **Args:**
  - `max_amount`: `u64`
- **Account variants:**
  - `13 accounts:` `pool`, `lp_mint`, `lock_escrow`, `owner`, `source_tokens`, `escrow_vault`, `token_program`, `a_vault`, `b_vault`, `a_vault_lp`, `b_vault_lp`, `a_vault_lp_mint`, `b_vault_lp_mint`

### `LockEvent`
- **Discriminator:** `0xe445a52e51cb9a1ddcb743d799cf38ea`
- **Args:**
  - `pool`: `Pubkey`
  - `owner`: `Pubkey`
  - `amount`: `u64`

### `MigrateFeeAccountEvent`
- **Discriminator:** `0xe445a52e51cb9a1ddfeae81afc69b47d`
- **Args:**
  - `pool`: `Pubkey`
  - `new_admin_token_a_fee`: `Pubkey`
  - `new_admin_token_b_fee`: `Pubkey`
  - `token_a_amount`: `u64`
  - `token_b_amount`: `u64`

### `OverrideCurveParam`
- **Discriminator:** `0x6256cc335e4745bb`
- **Args:**
  - `curve_type`: `CurveType`
- **Account variants:**
  - `2 accounts:` `pool`, `admin`

### `OverrideCurveParamEvent`
- **Discriminator:** `0xe445a52e51cb9a1df714a5f84b0536f6`
- **Args:**
  - `new_amp`: `u64`
  - `updated_timestamp`: `u64`
  - `pool`: `Pubkey`

### `PartnerClaimFee`
- **Discriminator:** `0x3935b01e7b463440`
- **Args:**
  - `max_amount_a`: `u64`
  - `max_amount_b`: `u64`
- **Account variants:**
  - `8 accounts:` `pool`, `a_vault_lp`, `protocol_token_a_fee`, `protocol_token_b_fee`, `partner_token_a`, `partner_token_b`, `token_program`, `partner_authority`

### `PartnerClaimFeesEvent`
- **Discriminator:** `0xe445a52e51cb9a1d87830a5e77d1ca30`
- **Args:**
  - `pool`: `Pubkey`
  - `fee_a`: `u64`
  - `fee_b`: `u64`
  - `partner`: `Pubkey`

### `PoolCreatedEvent`
- **Discriminator:** `0xe445a52e51cb9a1dca2c295868dc9d52`
- **Args:**
  - `lp_mint`: `Pubkey`
  - `token_a_mint`: `Pubkey`
  - `token_b_mint`: `Pubkey`
  - `pool_type`: `PoolType`
  - `pool`: `Pubkey`

### `PoolEnabledEvent`
- **Discriminator:** `0xe445a52e51cb9a1d02971253cc865cbf`
- **Args:**
  - `pool`: `Pubkey`
  - `enabled`: `bool`

### `PoolInfoEvent`
- **Discriminator:** `0xe445a52e51cb9a1dcf145761fbd4ea2d`
- **Args:**
  - `token_a_amount`: `u64`
  - `token_b_amount`: `u64`
  - `virtual_price`: `f64`
  - `current_timestamp`: `u64`

### `RemoveBalanceLiquidity`
- **Discriminator:** `0x856d2cb338ee7221`
- **Args:**
  - `pool_token_amount`: `u64`
  - `minimum_a_token_out`: `u64`
  - `minimum_b_token_out`: `u64`
- **Account variants:**
  - `16 accounts:` `pool`, `lp_mint`, `user_pool_lp`, `a_vault_lp`, `b_vault_lp`, `a_vault`, `b_vault`, `a_vault_lp_mint`, `b_vault_lp_mint`, `a_token_vault`, `b_token_vault`, `user_a_token`, `user_b_token`, `user`, `vault_program`, `token_program`

### `RemoveLiquidityEvent`
- **Discriminator:** `0xe445a52e51cb9a1d74f461e8671f983a`
- **Args:**
  - `lp_unmint_amount`: `u64`
  - `token_a_out_amount`: `u64`
  - `token_b_out_amount`: `u64`

### `RemoveLiquiditySingleSide`
- **Discriminator:** `0x5454b142feb90afb`
- **Args:**
  - `pool_token_amount`: `u64`
  - `minimum_out_amount`: `u64`
- **Account variants:**
  - `15 accounts:` `pool`, `lp_mint`, `user_pool_lp`, `a_vault_lp`, `b_vault_lp`, `a_vault`, `b_vault`, `a_vault_lp_mint`, `b_vault_lp_mint`, `a_token_vault`, `b_token_vault`, `user_destination_token`, `user`, `vault_program`, `token_program`

### `SetPoolFees`
- **Discriminator:** `0x662c9e36cd257e4e`
- **Args:**
  - `fees`: `PoolFees`
  - `new_partner_fee_numerator`: `u64`
- **Account variants:**
  - `2 accounts:` `pool`, `fee_operator`

### `SetPoolFeesEvent`
- **Discriminator:** `0xe445a52e51cb9a1df51ac6a458124b09`
- **Args:**
  - `trade_fee_numerator`: `u64`
  - `trade_fee_denominator`: `u64`
  - `protocol_trade_fee_numerator`: `u64`
  - `protocol_trade_fee_denominator`: `u64`
  - `pool`: `Pubkey`

### `SetWhitelistedVault`
- **Discriminator:** `0x0c945e2a373953f7`
- **Args:**
  - `whitelisted_vault`: `Pubkey`
- **Account variants:**
  - `2 accounts:` `pool`, `admin`

### `Swap`
- **Discriminator:** `0xf8c69e91e17587c8`
- **Args:**
  - `in_amount`: `u64`
  - `minimum_out_amount`: `u64`
- **Account variants:**
  - `15 accounts:` `pool`, `user_source_token`, `user_destination_token`, `a_vault`, `b_vault`, `a_token_vault`, `b_token_vault`, `a_vault_lp_mint`, `b_vault_lp_mint`, `a_vault_lp`, `b_vault_lp`, `protocol_token_fee`, `user`, `vault_program`, `token_program`

### `SwapEvent`
- **Discriminator:** `0xe445a52e51cb9a1d516ce3becdd00ac4`
- **Args:**
  - `in_amount`: `u64`
  - `out_amount`: `u64`
  - `trade_fee`: `u64`
  - `protocol_fee`: `u64`
  - `host_fee`: `u64`

### `TransferAdminEvent`
- **Discriminator:** `0xe445a52e51cb9a1de4a983f43d3841fe`
- **Args:**
  - `admin`: `Pubkey`
  - `new_admin`: `Pubkey`
  - `pool`: `Pubkey`

### `UpdateActivationPoint`
- **Discriminator:** `0x963e7ddbabdc1aed`
- **Args:**
  - `new_activation_point`: `u64`
- **Account variants:**
  - `2 accounts:` `pool`, `admin`

### `WithdrawProtocolFees`
- **Discriminator:** `0x0b44a56212d08649`
- **Args:** (none)
- **Account variants:**
  - `7 accounts:` `pool`, `a_vault_lp`, `protocol_token_a_fee`, `protocol_token_b_fee`, `treasury_token_a`, `treasury_token_b`, `token_program`

### `WithdrawProtocolFeesEvent`
- **Discriminator:** `0xe445a52e51cb9a1d1ef0cfc48bef4f1c`
- **Args:**
  - `pool`: `Pubkey`
  - `protocol_a_fee`: `u64`
  - `protocol_b_fee`: `u64`
  - `protocol_a_fee_owner`: `Pubkey`
  - `protocol_b_fee_owner`: `Pubkey`

## Shared types

### `ActivationType`
- enum: `Slot`, `Timestamp`

### `Bootstrapping`
- `activation_point`: `u64`
- `whitelisted_vault`: `Pubkey`
- `pool_creator`: `Pubkey`
- `activation_type`: `u8`

### `ConfigParameters`
- `trade_fee_numerator`: `u64`
- `protocol_trade_fee_numerator`: `u64`
- `activation_duration`: `u64`
- `vault_config_key`: `Pubkey`
- `pool_creator_authority`: `Pubkey`
- `activation_type`: `u8`
- `index`: `u64`
- `partner_fee_numerator`: `u64`

### `CurveType`
- enum:
  - `ConstantProduct`
  - `Stable { amp: u64, token_multiplier: TokenMultiplier, depeg: Depeg, last_amp_updated_timestamp: u64 }`

### `CustomizableParams`
- `trade_fee_numerator`: `u32`
- `activation_point`: `Option<u64>`
- `has_alpha_vault`: `bool`
- `activation_type`: `u8`
- `padding`: `[u8; 90]`

### `Depeg`
- `base_virtual_price`: `u64`
- `base_cache_updated`: `u64`
- `depeg_type`: `DepegType`

### `DepegType`
- enum: `None`, `Marinade`, `Lido`, `SplStake`

### `NewCurveType`
- enum:
  - `ConstantProduct`
  - `Stable { amp: u64, token_multiplier: TokenMultiplier, depeg: Depeg, last_amp_updated_timestamp: u64 }`
  - `NewCurve { field_one: u64, field_two: u64 }`

### `Padding`
- `padding0`: `[u8; 6]`
- `padding1`: `[u64; 21]`
- `padding2`: `[u64; 21]`

### `PartnerInfo`
- `fee_numerator`: `u64`
- `partner_authority`: `Pubkey`
- `pending_fee_a`: `u64`
- `pending_fee_b`: `u64`

### `PoolFees`
- `trade_fee_numerator`: `u64`
- `trade_fee_denominator`: `u64`
- `protocol_trade_fee_numerator`: `u64`
- `protocol_trade_fee_denominator`: `u64`

### `PoolType`
- enum: `Permissioned`, `Permissionless`

### `RoundDirection`
- enum: `Floor`, `Ceiling`

### `Rounding`
- enum: `Up`, `Down`

### `TokenMultiplier`
- `token_a_multiplier`: `u64`
- `token_b_multiplier`: `u64`
- `precision_factor`: `u8`

### `TradeDirection`
- enum: `AtoB`, `BtoA`
