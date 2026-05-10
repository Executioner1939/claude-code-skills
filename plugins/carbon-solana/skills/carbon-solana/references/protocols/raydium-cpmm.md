# Raydium CPMM

- **Crate:** `carbon-raydium-cpmm-decoder`
- **Program ID:** `CPMMoo8L3F4NbTegBCKVNunggL7H1ZpdTHKxQB5qKP1C`
- **Decoder struct:** `RaydiumCpmmDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in instructions/)
- **Discriminator style:** anchor 8-byte

## Account types

### `AmmConfig`
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
  - `creator_fee_rate`: `u64`
  - `padding`: `[u64; 15]`

### `ObservationState`
- **Fields:**
  - `initialized`: `bool`
  - `observation_index`: `u16`
  - `pool_id`: `Pubkey`
  - `observations`: `[Observation; 100]`
  - `padding`: `[u64; 4]`

### `Permission`
- **Fields:**
  - `authority`: `Pubkey`
  - `padding`: `[u64; 30]`

### `PoolState`
- **Fields:**
  - `amm_config`: `Pubkey`
  - `pool_creator`: `Pubkey`
  - `token_0_vault`: `Pubkey`
  - `token_1_vault`: `Pubkey`
  - `lp_mint`: `Pubkey`
  - `token_0_mint`: `Pubkey`
  - `token_1_mint`: `Pubkey`
  - `token_0_program`: `Pubkey`
  - `token_1_program`: `Pubkey`
  - `observation_key`: `Pubkey`
  - `auth_bump`: `u8`
  - `status`: `u8`
  - `lp_mint_decimals`: `u8`
  - `mint_0_decimals`: `u8`
  - `mint_1_decimals`: `u8`
  - `lp_supply`: `u64`
  - `protocol_fees_token_0`: `u64`
  - `protocol_fees_token_1`: `u64`
  - `fund_fees_token_0`: `u64`
  - `fund_fees_token_1`: `u64`
  - `open_time`: `u64`
  - `recent_epoch`: `u64`
  - `creator_fee_on`: `u8`
  - `enable_creator_fee`: `bool`
  - `padding1`: `[u8; 6]`
  - `creator_fees_token_0`: `u64`
  - `creator_fees_token_1`: `u64`
  - `padding`: `[u64; 28]`

## Instructions

### `ClosePermissionPda`
- **Discriminator:** `0x9c5420764587467b`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `owner`, `permission_authority`, `permission`, `system_program`

### `CollectCreatorFee`
- **Discriminator:** `0x1416567bc61cdb84`
- **Args:** (none)
- **Account variants:**
  - `14 accounts:` `creator`, `authority`, `pool_state`, `amm_config`, `token_0_vault`, `token_1_vault`, `vault_0_mint`, `vault_1_mint`, `creator_token_0`, `creator_token_1`, `token_0_program`, `token_1_program`, `associated_token_program`, `system_program`

### `CollectFundFee`
- **Discriminator:** `0xa78a4e95dfc2067e`
- **Args:**
  - `amount_0_requested`: `u64`
  - `amount_1_requested`: `u64`
- **Account variants:**
  - `12 accounts:` `owner`, `authority`, `pool_state`, `amm_config`, `token_0_vault`, `token_1_vault`, `vault_0_mint`, `vault_1_mint`, `recipient_token_0_account`, `recipient_token_1_account`, `token_program`, `token_program_2022`

### `CollectProtocolFee`
- **Discriminator:** `0x8888fcddc2427e59`
- **Args:**
  - `amount_0_requested`: `u64`
  - `amount_1_requested`: `u64`
- **Account variants:**
  - `12 accounts:` `owner`, `authority`, `pool_state`, `amm_config`, `token_0_vault`, `token_1_vault`, `vault_0_mint`, `vault_1_mint`, `recipient_token_0_account`, `recipient_token_1_account`, `token_program`, `token_program_2022`

### `CreateAmmConfig`
- **Discriminator:** `0x8934edd4d7756c68`
- **Args:**
  - `index`: `u16`
  - `trade_fee_rate`: `u64`
  - `protocol_fee_rate`: `u64`
  - `fund_fee_rate`: `u64`
  - `create_pool_fee`: `u64`
  - `creator_fee_rate`: `u64`
- **Account variants:**
  - `3 accounts:` `owner`, `amm_config`, `system_program`

### `CreatePermissionPda`
- **Discriminator:** `0x878802d889a9b5ca`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `owner`, `permission_authority`, `permission`, `system_program`

### `Deposit`
- **Discriminator:** `0xf223c68952e1f2b6`
- **Args:**
  - `lp_token_amount`: `u64`
  - `maximum_token_0_amount`: `u64`
  - `maximum_token_1_amount`: `u64`
- **Account variants:**
  - `13 accounts:` `owner`, `authority`, `pool_state`, `owner_lp_token`, `token_0_account`, `token_1_account`, `token_0_vault`, `token_1_vault`, `token_program`, `token_program_2022`, `vault_0_mint`, `vault_1_mint`, `lp_mint`

### `Initialize`
- **Discriminator:** `0xafaf6d1f0d989bed`
- **Args:**
  - `init_amount_0`: `u64`
  - `init_amount_1`: `u64`
  - `open_time`: `u64`
- **Account variants:**
  - `20 accounts:` `creator`, `amm_config`, `authority`, `pool_state`, `token_0_mint`, `token_1_mint`, `lp_mint`, `creator_token_0`, `creator_token_1`, `creator_lp_token`, `token_0_vault`, `token_1_vault`, `create_pool_fee`, `observation_state`, `token_program`, `token_0_program`, `token_1_program`, `associated_token_program`, `system_program`, `rent`

### `InitializeWithPermission`
- **Discriminator:** `0x3f37fe4131b25979`
- **Args:**
  - `init_amount_0`: `u64`
  - `init_amount_1`: `u64`
  - `open_time`: `u64`
  - `creator_fee_on`: `CreatorFeeOn`
- **Account variants:**
  - `21 accounts:` `payer`, `creator`, `amm_config`, `authority`, `pool_state`, `token_0_mint`, `token_1_mint`, `lp_mint`, `payer_token_0`, `payer_token_1`, `payer_lp_token`, `token_0_vault`, `token_1_vault`, `create_pool_fee`, `observation_state`, `permission`, `token_program`, `token_0_program`, `token_1_program`, `associated_token_program`, `system_program`

### `SwapBaseInput`
- **Discriminator:** `0x8fbe5adac41e33de`
- **Args:**
  - `amount_in`: `u64`
  - `minimum_amount_out`: `u64`
- **Account variants:**
  - `13 accounts:` `payer`, `authority`, `amm_config`, `pool_state`, `input_token_account`, `output_token_account`, `input_vault`, `output_vault`, `input_token_program`, `output_token_program`, `input_token_mint`, `output_token_mint`, `observation_state`

### `SwapBaseOutput`
- **Discriminator:** `0x37d96256a34ab4ad`
- **Args:**
  - `max_amount_in`: `u64`
  - `amount_out`: `u64`
- **Account variants:**
  - `13 accounts:` `payer`, `authority`, `amm_config`, `pool_state`, `input_token_account`, `output_token_account`, `input_vault`, `output_vault`, `input_token_program`, `output_token_program`, `input_token_mint`, `output_token_mint`, `observation_state`

### `UpdateAmmConfig`
- **Discriminator:** `0x313cae889a1c74c8`
- **Args:**
  - `param`: `u8`
  - `value`: `u64`
- **Account variants:**
  - `2 accounts:` `owner`, `amm_config`

### `UpdatePoolStatus`
- **Discriminator:** `0x82576c062ee0757b`
- **Args:**
  - `status`: `u8`
- **Account variants:**
  - `2 accounts:` `authority`, `pool_state`

### `Withdraw`
- **Discriminator:** `0xb712469c946da122`
- **Args:**
  - `lp_token_amount`: `u64`
  - `minimum_token_0_amount`: `u64`
  - `minimum_token_1_amount`: `u64`
- **Account variants:**
  - `14 accounts:` `owner`, `authority`, `pool_state`, `owner_lp_token`, `token_0_account`, `token_1_account`, `token_0_vault`, `token_1_vault`, `token_program`, `token_program_2022`, `vault_0_mint`, `vault_1_mint`, `lp_mint`, `memo_program`

## CPI events

### `LpChangeEvent`
- **Source:** `instructions/lp_change_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d79a3cdc939da753c`
- **Fields:**
  - `pool_id`: `Pubkey`
  - `lp_amount_before`: `u64`
  - `token_0_vault_before`: `u64`
  - `token_1_vault_before`: `u64`
  - `token_0_amount`: `u64`
  - `token_1_amount`: `u64`
  - `token_0_transfer_fee`: `u64`
  - `token_1_transfer_fee`: `u64`
  - `change_type`: `u8`

### `SwapEvent`
- **Source:** `instructions/swap_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d40c6cde8260871e2`
- **Fields:**
  - `pool_id`: `Pubkey`
  - `input_vault_before`: `u64`
  - `output_vault_before`: `u64`
  - `input_amount`: `u64`
  - `output_amount`: `u64`
  - `input_transfer_fee`: `u64`
  - `output_transfer_fee`: `u64`
  - `base_input`: `bool`
  - `input_mint`: `Pubkey`
  - `output_mint`: `Pubkey`
  - `trade_fee`: `u64`
  - `creator_fee`: `u64`
  - `creator_fee_on_input`: `bool`

## Shared types

### `AmmConfig`
- `bump`: `u8`
- `disable_create_pool`: `bool`
- `index`: `u16`
- `trade_fee_rate`: `u64`
- `protocol_fee_rate`: `u64`
- `fund_fee_rate`: `u64`
- `create_pool_fee`: `u64`
- `protocol_owner`: `Pubkey`
- `fund_owner`: `Pubkey`
- `creator_fee_rate`: `u64`
- `padding`: `[u64; 15]`

### `CreatorFeeOn`
- enum variants: `BothToken`, `OnlyToken0`, `OnlyToken1`

### `Observation`
- `block_timestamp`: `u64`
- `cumulative_token_0_price_x32`: `u128`
- `cumulative_token_1_price_x32`: `u128`

### `ObservationState`
- `initialized`: `bool`
- `observation_index`: `u16`
- `pool_id`: `Pubkey`
- `observations`: `[Observation; 100]`
- `padding`: `[u64; 4]`

### `Permission`
- `authority`: `Pubkey`
- `padding`: `[u64; 30]`

### `PoolState`
- `amm_config`: `Pubkey`
- `pool_creator`: `Pubkey`
- `token_0_vault`: `Pubkey`
- `token_1_vault`: `Pubkey`
- `lp_mint`: `Pubkey`
- `token_0_mint`: `Pubkey`
- `token_1_mint`: `Pubkey`
- `token_0_program`: `Pubkey`
- `token_1_program`: `Pubkey`
- `observation_key`: `Pubkey`
- `auth_bump`: `u8`
- `status`: `u8`
- `lp_mint_decimals`: `u8`
- `mint_0_decimals`: `u8`
- `mint_1_decimals`: `u8`
- `lp_supply`: `u64`
- `protocol_fees_token_0`: `u64`
- `protocol_fees_token_1`: `u64`
- `fund_fees_token_0`: `u64`
- `fund_fees_token_1`: `u64`
- `open_time`: `u64`
- `recent_epoch`: `u64`
- `creator_fee_on`: `u8`
- `enable_creator_fee`: `bool`
- `padding1`: `[u8; 6]`
- `creator_fees_token_0`: `u64`
- `creator_fees_token_1`: `u64`
- `padding`: `[u64; 28]`
