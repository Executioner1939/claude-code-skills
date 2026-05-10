# Wavebreak

- **Crate:** `carbon-wavebreak-decoder`
- **Program ID:** `waveQX2yP3H1pVU8djGvEHmYg8uamQ84AuyGtpsrXTF`
- **Decoder struct:** `WavebreakDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in types/, single `Event` enum)
- **Discriminator style:** raw byte (single-byte first-byte tag)

## Account types

All carry an embedded `discriminator: AccountDiscriminator` enum (Uninitialized=0, Closed=1, BondingCurve=2, AuthorityConfig=3, PermissionConfig=4, ConsumedPermission=5, MintConfig=6).

### `BondingCurve`
- **Discriminator:** `0x02`
- **Fields:**
  - `discriminator`: `AccountDiscriminator`
  - `base_mint`, `quote_mint`, `creator`: `Pubkey`
  - `retain_mint_authority`: `bool`
  - `buy_requires_permission`: `bool`
  - `buy_permission_bitmap`: `[u8; 32]`
  - `sell_requires_permission`: `bool`
  - `sell_permission_bitmap`: `[u8; 32]`
  - `quote_fee_bps`, `base_fee_bps`: `u16`
  - `control_points`: `[u16; 4]`
  - `start_price`, `end_price`: `u128`
  - `quote_amount`, `base_amount`: `u64`
  - `launch_slot`, `creator_reward`, `graduation_target`, `graduation_slot`, `graduation_reward`: `u64`
  - `max_buy_amount`, `max_sell_amount`: `u64`
  - `swap_fee_bps`, `base_allocation_bps`: `u16`
  - `graduation_methods`: `[GraduationMethodData; 8]`
  - `min_reserve_bps`: `u16`
  - `padding1`: `[u8; 2]`
  - `preminted_supply`: `u64`
  - `padding2`: `[u8; 728]`

### `AuthorityConfig`
- **Discriminator:** `0x03`
- **Fields:**
  - `discriminator`: `AccountDiscriminator`
  - `authorities`: `[ProgramAuthority; 64]`

### `PermissionConfig`
- **Discriminator:** `0x04`
- **Fields:**
  - `discriminator`: `AccountDiscriminator`
  - `consumer_program`: `Pubkey`
  - `allowed_signers`: `[PermissionSigner; 3]`
  - `padding`: `[u8; 124]`

### `ConsumedPermission`
- **Discriminator:** `0x05`
- **Fields:**
  - `discriminator`: `AccountDiscriminator`
  - `padding1`: `[u8; 7]`
  - `safe_to_close_slot`: `u64`
  - `refund_destination`: `Pubkey`
  - `padding2`: `[u8; 16]`

### `MintConfig`
- **Discriminator:** `0x06`
- **Fields:**
  - `discriminator`: `AccountDiscriminator`
  - `instruction_discriminator`: `u8`
  - `quote_mint`: `Pubkey`
  - `create_requires_permission`: `bool`, `create_permission_bitmap`: `[u8; 32]`
  - `default_buy_requires_permission`: `bool`, `default_buy_permission_bitmap`: `[u8; 32]`
  - `default_sell_requires_permission`: `bool`, `default_sell_permission_bitmap`: `[u8; 32]`
  - `padding1`: `[u8; 3]`
  - `default_creator_reward`, `default_graduation_reward`, `default_graduation_target`, `default_max_buy_amount`, `default_max_sell_amount`: `u64`
  - `default_start_price`, `default_end_price`: `u128`
  - `default_control_points`: `[u16; 4]`
  - `default_swap_fee_bps`, `default_quote_fee_bps`, `default_base_fee_bps`: `u16`
  - `padding2`: `[u8; 1826]`

## Instructions

### Permission

### `PermissionConsumeTopLevel` (`0x00`)
- **Args:** `permission_message: PermissionMessage`, `permission_signature: PermissionSignature`
- **Accounts (5):** `consumer, permission_config, consumed_permission, system_program, instructions`

### `PermissionConsumeCpi` (`0x01`)
- **Args:** `permission_message: PermissionMessage`, `permission_signature: PermissionSignature`, `consumer_program_authority_seeds: Vec<Vec<u8>>`
- **Accounts (5):** `consumer, consumer_program_authority, permission_config, consumed_permission, system_program`

### `PermissionConfigInitialize` (`0x02`)
- **Args:** `permission_authority: PermissionSigner`, `consumer_program: Pubkey`
- **Accounts (4):** `authority, permission_config, authority_config, system_program`

### `PermissionConfigUpdate` (`0x03`)
- **Args:** `update: PermissionConfigUpdateType`
- **Accounts (3):** `authority, permission_config, authority_config`

### `PermissionConfigClose` (`0x04`)
- **Accounts (3):** `authority, permission_config, authority_config`

### `PermissionRevoke` (`0x05`)
- **Args:** `permission_message: PermissionMessage`, `permission_signature: PermissionSignature`
- **Accounts (4):** `funder, permission_config, consumed_permission, system_program`

### `PermissionRefund` (`0x06`)
- **Accounts (2):** `consumed_permission, refund_destination`

### `ReservedPermissionA` (`0x07`)
- **Accounts:** (none)

### Token swap / refund

### `TokenBuyExactIn` (`0x08`)
- **Args:** `amount_in: u64`, `allow_partial_fill: bool`, `price_threshold: Option<(u64, u64)>`
- **Accounts (11):** `buyer, bonding_curve, base_mint, base_ata, quote_mint, quote_vault, quote_ata, system_program, ata_program, base_token_program, quote_token_program`

### `TokenBuyExactOut` (`0x09`)
- **Args:** `amount_out: u64`, `allow_partial_fill: bool`, `price_threshold: Option<(u64, u64)>`
- **Accounts (11):** same shape as `TokenBuyExactIn`

### `TokenSellExactIn` (`0x0a`)
- **Args:** `amount_in: u64`, `allow_partial_fill: bool`, `price_threshold: Option<(u64, u64)>`
- **Accounts (11):** `seller, bonding_curve, base_mint, base_ata, quote_mint, quote_vault, quote_ata, system_program, ata_program, base_token_program, quote_token_program`

### `TokenSellExactOut` (`0x0b`)
- **Args:** `amount_out: u64`, `allow_partial_fill: bool`, `price_threshold: Option<(u64, u64)>`
- **Accounts (11):** same shape as `TokenSellExactIn`

### `TokenRefund` (`0x0c`)
- **Accounts (10):** `signer, bonding_curve, quote_mint, quote_vault, signer_quote_ata, base_mint, signer_base_ata, system_program, base_token_program, quote_token_program, ata_program`

### `ReservedTokenY` (`0x0d`), `ReservedTokenZ` (`0x0e`), `ReservedTokenA` (`0x0f`)
- **Accounts:** (none)

### Authority config

### `AuthorityConfigInitialize` (`0x10`)
- **Accounts (3):** `authority, authority_config, system_program`

### `AuthorityConfigGrant` (`0x11`)
- **Args:** `account: Pubkey`, `privileges: Vec<Privilege>`
- **Accounts (2):** `authority, authority_config`

### `AuthorityConfigRevoke` (`0x12`)
- **Args:** `account: Pubkey`, `privileges: Vec<Privilege>`
- **Accounts (2):** `authority, authority_config`

### `ReservedAuthorityConfigY` (`0x13`), `Z` (`0x14`), `A` (`0x15`), `B` (`0x16`), `C` (`0x17`)
- **Accounts:** (none)

### Mint config

### `MintConfigInitialize` (`0x18`)
- **Args:** `token_mint: Pubkey`, `instruction_discriminator: u8`
- **Accounts (4):** `authority, mint_config, authority_config, system_program`

### `MintConfigClose` (`0x19`)
- **Accounts (3):** `authority, mint_config, authority_config`

### `MintConfigUpdate` (`0x1a`)
- **Args:** `update: MintConfigUpdateType`
- **Accounts (3):** `authority, mint_config, authority_config`

### `ReservedMintConfigY` (`0x1b`), `Z` (`0x1c`), `A` (`0x1d`), `B` (`0x1e`), `C` (`0x1f`)
- **Accounts:** (none)

### Graduate

### `GraduateWhirlpool` (`0x20`)
- **Accounts (33):** `signer, lp_authority, bonding_curve, quote_mint, quote_vault, signer_quote_ata, lp_authority_quote_ata, whirlpool_quote_vault, base_mint, base_vault, lp_authority_base_ata, whirlpool_base_vault, whirlpool_config, fee_tier, whirlpool, oracle, position, position_mint, position_token_account, lp_authority_token_account, lower_tick_array, upper_tick_array, quote_token_badge, base_token_badge, whirlpool_init_authority, whirlpool_update_authority, lock_config, system_program, ata_program, quote_token_program, base_token_program, memo_program, whirlpool_program, rent`

### `GraduateManual` (`0x21`)
- **Accounts (13):** `signer, destination, bonding_curve, quote_mint, quote_vault, signer_quote_ata, destination_quote_ata, base_mint, destination_base_ata, system_program, ata_program, quote_token_program, base_token_program`

### `ReservedGraduateX` (`0x22`), `Y` (`0x23`), `Z` (`0x24`), `A` (`0x25`), `B` (`0x26`), `C` (`0x27`)
- **Accounts:** (none)

### Create

### `CreateLockedlaunch` (`0x28`)
- **Args:** `name: String`, `symbol: String`, `uri: String`
- **Accounts (12):** `creator, bonding_curve, base_mint, quote_mint, quote_vault, mint_config, metadata, system_program, base_token_program, quote_token_program, ata_program, metaplex_program`

### `CreateLaunch` (`0x29`)
- **Args:** `name: String`, `symbol: String`, `uri: String`, `start_price: Option<u128>`, `end_price: Option<u128>`, `control_points: Option<[u16; 4]>`, `graduation_target: Option<u64>`, `graduation_methods: Option<[GraduationMethod; 8]>`, `launch_slot: Option<u64>`, `graduation_slot: Option<u64>`, plus additional override fields
- **Accounts (12):** same shape as `CreateLockedlaunch`

### `CreatePresale` (`0x2a`)
- **Args:** `name: String`, `symbol: String`, `uri: String`, `token_price: Option<u128>`, `graduation_target: Option<u64>`, `graduation_methods: Option<[GraduationMethod; 8]>`, `launch_slot: Option<u64>`, `graduation_slot: Option<u64>`, `min_reserve_bps: Option<u16>`, `base_allocation_bps: Option<u16>`, plus additional override fields
- **Accounts (12):** same shape as `CreateLockedlaunch`

### `ReservedCreateY` (`0x2b`), `Z` (`0x2c`), `A` (`0x2d`), `B` (`0x2e`), `C` (`0x2f`)
- **Accounts:** (none)

### Bonding curve

### `BondingCurveInitialize` (`0x30`)
- **Args:** `start_price: u128`, `end_price: u128`, `control_points: [u16; 4]`, `graduation_methods: [GraduationMethod; 8]`, `swap_fee_bps: u16`, `quote_fee_bps: u16`, `base_fee_bps: u16`, `launch_slot: u64`, `creator_reward: u64`, plus additional config fields
- **Accounts (10):** `authority, bonding_curve, base_mint, quote_mint, quote_vault, authority_config, system_program, base_token_program, quote_token_program, ata_program`

### `BondingCurveCollectFees` (`0x31`)
- **Accounts (11):** `signer, fee_authority, fee_authority_ata, bonding_curve, base_mint, quote_mint, quote_vault, authority_config, system_program, ata_program, quote_token_program`

### `BondingCurveGraduate` (`0x32`)
- **Accounts (17):** `signer, creator, fee_authority, bonding_curve, authority_config, quote_mint, quote_vault, signer_quote_ata, creator_quote_ata, fee_authority_quote_ata, base_mint, creator_base_ata, fee_authority_base_ata, system_program, ata_program, quote_token_program, base_token_program`

### `BondingCurveClose` (`0x33`)
- **Accounts (13):** `authority, creator, fee_authority, bonding_curve, quote_mint, quote_vault, fee_authority_quote_ata, base_mint, authority_config, quote_token_program, base_token_program, system_program, ata_program`

### `ReservedBondingCurveX` (`0x34`), `Y` (`0x35`), `Z` (`0x36`), `A` (`0x37`)
- **Accounts:** (none)

## CPI events

The decoder exposes a single `Event` enum in `types/event.rs` (no per-discriminator `[]` tags — variants tag-less Borsh enum).

### `Event::BondingCurveCreated`
- **Source:** `types/event.rs`
- **Fields:**
  - `creation_type`: `BondingCurveCreationType`
  - `base_mint`, `quote_mint`, `creator`: `Pubkey`
  - `start_price`, `end_price`: `u128`
  - `control_points`: `[u16; 4]`
  - `swap_fee_bps`, `quote_fee_bps`, `base_fee_bps`, `base_allocation_bps`, `min_reserve_bps`: `u16`
  - `launch_slot`, `creator_reward`, `graduation_target`, `graduation_slot`, `graduation_reward`, `max_buy_amount`, `max_sell_amount`: `u64`
  - `graduation_methods`: `Box<[GraduationMethodData; 8]>`
  - `retain_mint_authority`, `buy_requires_permission`, `sell_requires_permission`: `bool`
  - `buy_permission_bitmap`, `sell_permission_bitmap`: `[u8; 32]`
  - `quote_token_program`, `base_token_program`: `Pubkey`
  - `quote_token_decimals`, `base_token_decimals`: `u8`

### `Event::TokenBought`
- **Fields:**
  - `buyer`, `base_mint`, `quote_mint`: `Pubkey`
  - `amount_in`, `amount_out`: `u64`
  - `price_before`, `price_after`: `u128`
  - `quote_amount_before`, `quote_amount_after`, `base_amount_before`, `base_amount_after`, `protocol_fee`: `u64`

### `Event::TokenSold`
- **Fields:** same as `TokenBought` with `seller` instead of `buyer`.

### `Event::TokenRefunded`
- **Fields:**
  - `signer`, `base_mint`, `quote_mint`: `Pubkey`
  - `price`: `u128`
  - `quote_amount`, `base_amount`: `u64`

### `Event::BondingCurveGraduated`
- **Fields:**
  - `graduator`, `base_mint`, `quote_mint`: `Pubkey`
  - `final_price`: `u128`
  - `graduation_methods`: `Box<[GraduationMethodData; 8]>`

### `Event::BondingCurveClosed`
- **Fields:**
  - `bonding_curve`: `Pubkey`

## Shared types

### `AccountDiscriminator`
- enum: `Uninitialized`, `Closed`, `BondingCurve`, `AuthorityConfig`, `PermissionConfig`, `ConsumedPermission`, `MintConfig`

### Other types in `types/`
- `BondingCurveCreationType`, `GraduationMethod`, `GraduationMethodData`, `GraduationMethodLabel`
- `LockConfig`, `LockTypeLabel`
- `MintConfigUpdateType`, `PermissionConfigUpdateType`
- `PermissionMessage`, `PermissionSignature`, `PermissionSigner`
- `Privilege`, `ProgramAuthority`
- `PositionRewardInfo`
- `TokenAccount`, `TokenAccountState`, `TokenMetadata`, `TokenMetadataPointer`, `TokenMint`
- Whirlpool helpers: `Whirlpool`, `WhirlpoolAdaptiveFeeTier`, `WhirlpoolConfig`, `WhirlpoolFeeTier`, `WhirlpoolPosition`, `WhirlpoolRewardInfo`, `WhirlpoolTickArray`
- Metaplex helpers: `MetaplexCollection`, `MetaplexCollectionDetails`, `MetaplexCreator`, `MetaplexData`, `MetaplexMetadata`, `MetaplexProgrammableConfig`, `MetaplexTokenStandard`, `MetaplexUseMethod`, `MetaplexUses`
