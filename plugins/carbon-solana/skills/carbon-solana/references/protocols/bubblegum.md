# Bubblegum

- **Crate:** `carbon-bubblegum-decoder`
- **Program ID:** `BGUMAp9Gq7iTEuizy4pqaxsTyUCBK68MDfK752saRPUY`
- **Decoder struct:** `BubblegumDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** no
- **Discriminator style:** anchor 8-byte

## Account types

### `TreeConfig`
- **Discriminator:** `0x7af5aff8ab2200cf`
- **Fields:**
  - `tree_creator`: `Pubkey`
  - `tree_delegate`: `Pubkey`
  - `total_mint_capacity`: `u64`
  - `num_minted`: `u64`
  - `is_public`: `bool`
  - `is_decompressible`: `DecompressibleState`
  - `version`: `Version`

### `Voucher`
- **Discriminator:** `0xbfcc95ead5a50d41`
- **Fields:**
  - `leaf_schema`: `LeafSchema`
  - `index`: `u32`
  - `merkle_tree`: `Pubkey`

## Instructions

### `Burn`
- **Discriminator:** `0x746e1d386bdb2a5d`
- **Args:**
  - `root`: `[u8; 32]`
  - `data_hash`: `[u8; 32]`
  - `creator_hash`: `[u8; 32]`
  - `nonce`: `u64`
  - `index`: `u32`
- **Account variants:**
  - `7 accounts:` `tree_authority`, `leaf_owner`, `leaf_delegate`, `merkle_tree`, `log_wrapper`, `compression_program`, `system_program`

### `BurnV2`
- **Discriminator:** `0x73d222f0e88fb710`
- **Args:**
  - `root`: `[u8; 32]`
  - `data_hash`: `[u8; 32]`
  - `creator_hash`: `[u8; 32]`
  - `asset_data_hash`: `Option<[u8; 32]>`
  - `flags`: `Option<u8>`
  - `nonce`: `u64`
  - `index`: `u32`
- **Account variants:**
  - `12 accounts:` `tree_authority`, `payer`, `authority`, `leaf_owner`, `leaf_delegate`, `merkle_tree`, `core_collection`, `mpl_core_cpi_signer`, `log_wrapper`, `compression_program`, `mpl_core_program`, `system_program`

### `CancelRedeem`
- **Discriminator:** `0x6f4ce83227af30f2`
- **Args:**
  - `root`: `[u8; 32]`
- **Account variants:**
  - `7 accounts:` `tree_authority`, `leaf_owner`, `merkle_tree`, `voucher`, `log_wrapper`, `compression_program`, `system_program`

### `CollectV2`
- **Discriminator:** `0x150b9f2f04c36a38`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `tree_authority`, `destination`

### `Compress`
- **Discriminator:** `0x52c1b075b01573fd`
- **Args:** (none)
- **Account variants:**
  - `14 accounts:` `tree_authority`, `leaf_owner`, `leaf_delegate`, `merkle_tree`, `token_account`, `mint`, `metadata`, `master_edition`, `payer`, `log_wrapper`, `compression_program`, `token_program`, `token_metadata_program`, `system_program`

### `CreateTree`
- **Discriminator:** `0xa553888e59ca2fdc`
- **Args:**
  - `max_depth`: `u32`
  - `max_buffer_size`: `u32`
  - `public`: `Option<bool>`
- **Account variants:**
  - `7 accounts:` `tree_authority`, `merkle_tree`, `payer`, `tree_creator`, `log_wrapper`, `compression_program`, `system_program`

### `CreateTreeV2`
- **Discriminator:** `0x37635fd78ecbe3cd`
- **Args:**
  - `max_depth`: `u32`
  - `max_buffer_size`: `u32`
  - `public`: `Option<bool>`
- **Account variants:**
  - `7 accounts:` `tree_authority`, `merkle_tree`, `payer`, `tree_creator`, `log_wrapper`, `compression_program`, `system_program`

### `DecompressV1`
- **Discriminator:** `0x36554c46e4faa451`
- **Args:**
  - `metadata`: `MetadataArgs`
- **Account variants:**
  - `13 accounts:` `voucher`, `leaf_owner`, `token_account`, `mint`, `mint_authority`, `metadata`, `master_edition`, `system_program`, `sysvar_rent`, `token_metadata_program`, `token_program`, `associated_token_program`, `log_wrapper`

### `Delegate`
- **Discriminator:** `0x5a934bb255580489`
- **Args:**
  - `root`: `[u8; 32]`
  - `data_hash`: `[u8; 32]`
  - `creator_hash`: `[u8; 32]`
  - `nonce`: `u64`
  - `index`: `u32`
- **Account variants:**
  - `8 accounts:` `tree_authority`, `leaf_owner`, `previous_leaf_delegate`, `new_leaf_delegate`, `merkle_tree`, `log_wrapper`, `compression_program`, `system_program`

### `DelegateAndFreezeV2`
- **Discriminator:** `0x11e523dabef1fa7b`
- **Args:**
  - `root`: `[u8; 32]`
  - `data_hash`: `[u8; 32]`
  - `creator_hash`: `[u8; 32]`
  - `collection_hash`: `Option<[u8; 32]>`
  - `asset_data_hash`: `Option<[u8; 32]>`
  - `flags`: `Option<u8>`
  - `nonce`: `u64`
  - `index`: `u32`
- **Account variants:**
  - `9 accounts:` `tree_authority`, `payer`, `leaf_owner`, `previous_leaf_delegate`, `new_leaf_delegate`, `merkle_tree`, `log_wrapper`, `compression_program`, `system_program`

### `DelegateV2`
- **Discriminator:** `0x5f577d8cb58380e3`
- **Args:**
  - `root`: `[u8; 32]`
  - `data_hash`: `[u8; 32]`
  - `creator_hash`: `[u8; 32]`
  - `collection_hash`: `Option<[u8; 32]>`
  - `asset_data_hash`: `Option<[u8; 32]>`
  - `flags`: `Option<u8>`
  - `nonce`: `u64`
  - `index`: `u32`
- **Account variants:**
  - `9 accounts:` `tree_authority`, `payer`, `leaf_owner`, `previous_leaf_delegate`, `new_leaf_delegate`, `merkle_tree`, `log_wrapper`, `compression_program`, `system_program`

### `FreezeV2`
- **Discriminator:** `0xc897f46610c3ff03`
- **Args:**
  - `root`: `[u8; 32]`
  - `data_hash`: `[u8; 32]`
  - `creator_hash`: `[u8; 32]`
  - `asset_data_hash`: `Option<[u8; 32]>`
  - `flags`: `Option<u8>`
  - `nonce`: `u64`
  - `index`: `u32`
- **Account variants:**
  - `10 accounts:` `tree_authority`, `payer`, `authority`, `leaf_owner`, `leaf_delegate`, `merkle_tree`, `core_collection`, `log_wrapper`, `compression_program`, `system_program`

### `MintToCollectionV1`
- **Discriminator:** `0x9912b22fc59e560f`
- **Args:**
  - `metadata_args`: `MetadataArgs`
- **Account variants:**
  - `16 accounts:` `tree_authority`, `leaf_owner`, `leaf_delegate`, `merkle_tree`, `payer`, `tree_delegate`, `collection_authority`, `collection_authority_record_pda`, `collection_mint`, `collection_metadata`, `edition_account`, `bubblegum_signer`, `log_wrapper`, `compression_program`, `token_metadata_program`, `system_program`

### `MintV1`
- **Discriminator:** `0x9162c076b8937668`
- **Args:**
  - `message`: `MetadataArgs`
- **Account variants:**
  - `9 accounts:` `tree_authority`, `leaf_owner`, `leaf_delegate`, `merkle_tree`, `payer`, `tree_delegate`, `log_wrapper`, `compression_program`, `system_program`

### `MintV2`
- **Discriminator:** `0x78791792ad6ec7cd`
- **Args:**
  - `metadata_args`: `MetadataArgsV2`
  - `asset_data`: `Option<Vec<u8>>`
  - `asset_data_schema`: `Option<AssetDataSchema>`
- **Account variants:**
  - `13 accounts:` `tree_authority`, `payer`, `tree_delegate`, `collection_authority`, `leaf_owner`, `leaf_delegate`, `merkle_tree`, `core_collection`, `mpl_core_cpi_signer`, `log_wrapper`, `compression_program`, `mpl_core_program`, `system_program`

### `Redeem`
- **Discriminator:** `0xb80c569546c461e1`
- **Args:**
  - `root`: `[u8; 32]`
  - `data_hash`: `[u8; 32]`
  - `creator_hash`: `[u8; 32]`
  - `nonce`: `u64`
  - `index`: `u32`
- **Account variants:**
  - `8 accounts:` `tree_authority`, `leaf_owner`, `leaf_delegate`, `merkle_tree`, `voucher`, `log_wrapper`, `compression_program`, `system_program`

### `SetAndVerifyCollection`
- **Discriminator:** `0xebf279d89eeab4ea`
- **Args:**
  - `root`: `[u8; 32]`
  - `data_hash`: `[u8; 32]`
  - `creator_hash`: `[u8; 32]`
  - `nonce`: `u64`
  - `index`: `u32`
  - `message`: `MetadataArgs`
  - `collection`: `Pubkey`
- **Account variants:**
  - `16 accounts:` `tree_authority`, `leaf_owner`, `leaf_delegate`, `merkle_tree`, `payer`, `tree_delegate`, `collection_authority`, `collection_authority_record_pda`, `collection_mint`, `collection_metadata`, `edition_account`, `bubblegum_signer`, `log_wrapper`, `compression_program`, `token_metadata_program`, `system_program`

### `SetCollectionV2`
- **Discriminator:** `0xe5233d5b0f0e63a0`
- **Args:**
  - `root`: `[u8; 32]`
  - `asset_data_hash`: `Option<[u8; 32]>`
  - `flags`: `Option<u8>`
  - `nonce`: `u64`
  - `index`: `u32`
  - `message`: `MetadataArgsV2`
- **Account variants:**
  - `14 accounts:` `tree_authority`, `payer`, `authority`, `new_collection_authority`, `leaf_owner`, `leaf_delegate`, `merkle_tree`, `core_collection`, `new_core_collection`, `mpl_core_cpi_signer`, `log_wrapper`, `compression_program`, `mpl_core_program`, `system_program`

### `SetDecompressableState`
- **Discriminator:** `0x1287eea8f6c33d73`
- **Args:**
  - `decompressable_state`: `DecompressibleState`
- **Account variants:**
  - `2 accounts:` `tree_authority`, `tree_creator`

### `SetDecompressibleState`
- **Discriminator:** `0x52689806956f640d`
- **Args:**
  - `decompressable_state`: `DecompressibleState`
- **Account variants:**
  - `2 accounts:` `tree_authority`, `tree_creator`

### `SetNonTransferableV2`
- **Discriminator:** `0xb58dce3af2c798a8`
- **Args:**
  - `root`: `[u8; 32]`
  - `data_hash`: `[u8; 32]`
  - `creator_hash`: `[u8; 32]`
  - `asset_data_hash`: `Option<[u8; 32]>`
  - `flags`: `Option<u8>`
  - `nonce`: `u64`
  - `index`: `u32`
- **Account variants:**
  - `10 accounts:` `tree_authority`, `payer`, `authority`, `leaf_owner`, `leaf_delegate`, `merkle_tree`, `core_collection`, `log_wrapper`, `compression_program`, `system_program`

### `SetTreeDelegate`
- **Discriminator:** `0xfd764225be319a66`
- **Args:** (none)
- **Account variants:**
  - `5 accounts:` `tree_authority`, `tree_creator`, `new_tree_delegate`, `merkle_tree`, `system_program`

### `ThawAndRevokeV2`
- **Discriminator:** `0x56d6be25a7041c74`
- **Args:**
  - `root`: `[u8; 32]`
  - `data_hash`: `[u8; 32]`
  - `creator_hash`: `[u8; 32]`
  - `collection_hash`: `Option<[u8; 32]>`
  - `asset_data_hash`: `Option<[u8; 32]>`
  - `flags`: `Option<u8>`
  - `nonce`: `u64`
  - `index`: `u32`
- **Account variants:**
  - `8 accounts:` `tree_authority`, `payer`, `leaf_delegate`, `leaf_owner`, `merkle_tree`, `log_wrapper`, `compression_program`, `system_program`

### `ThawV2`
- **Discriminator:** `0x6085655d52dc92bf`
- **Args:**
  - `root`: `[u8; 32]`
  - `data_hash`: `[u8; 32]`
  - `creator_hash`: `[u8; 32]`
  - `asset_data_hash`: `Option<[u8; 32]>`
  - `flags`: `Option<u8>`
  - `nonce`: `u64`
  - `index`: `u32`
- **Account variants:**
  - `10 accounts:` `tree_authority`, `payer`, `authority`, `leaf_owner`, `leaf_delegate`, `merkle_tree`, `core_collection`, `log_wrapper`, `compression_program`, `system_program`

### `Transfer`
- **Discriminator:** `0xa334c8e78c0345ba`
- **Args:**
  - `root`: `[u8; 32]`
  - `data_hash`: `[u8; 32]`
  - `creator_hash`: `[u8; 32]`
  - `nonce`: `u64`
  - `index`: `u32`
- **Account variants:**
  - `8 accounts:` `tree_authority`, `leaf_owner`, `leaf_delegate`, `new_leaf_owner`, `merkle_tree`, `log_wrapper`, `compression_program`, `system_program`

### `TransferV2`
- **Discriminator:** `0x772806ebeaddf831`
- **Args:**
  - `root`: `[u8; 32]`
  - `data_hash`: `[u8; 32]`
  - `creator_hash`: `[u8; 32]`
  - `asset_data_hash`: `Option<[u8; 32]>`
  - `flags`: `Option<u8>`
  - `nonce`: `u64`
  - `index`: `u32`
- **Account variants:**
  - `11 accounts:` `tree_authority`, `payer`, `authority`, `leaf_owner`, `leaf_delegate`, `new_leaf_owner`, `merkle_tree`, `core_collection`, `log_wrapper`, `compression_program`, `system_program`

### `UnverifyCollection`
- **Discriminator:** `0xfafb2a6a2989baa8`
- **Args:**
  - `root`: `[u8; 32]`
  - `data_hash`: `[u8; 32]`
  - `creator_hash`: `[u8; 32]`
  - `nonce`: `u64`
  - `index`: `u32`
  - `message`: `MetadataArgs`
- **Account variants:**
  - `16 accounts:` `tree_authority`, `leaf_owner`, `leaf_delegate`, `merkle_tree`, `payer`, `tree_delegate`, `collection_authority`, `collection_authority_record_pda`, `collection_mint`, `collection_metadata`, `edition_account`, `bubblegum_signer`, `log_wrapper`, `compression_program`, `token_metadata_program`, `system_program`

### `UnverifyCreator`
- **Discriminator:** `0x6bb2392769737098`
- **Args:**
  - `root`: `[u8; 32]`
  - `data_hash`: `[u8; 32]`
  - `creator_hash`: `[u8; 32]`
  - `nonce`: `u64`
  - `index`: `u32`
  - `message`: `MetadataArgs`
- **Account variants:**
  - `9 accounts:` `tree_authority`, `leaf_owner`, `leaf_delegate`, `merkle_tree`, `payer`, `creator`, `log_wrapper`, `compression_program`, `system_program`

### `UnverifyCreatorV2`
- **Discriminator:** `0xae701d8ee664ef07`
- **Args:**
  - `root`: `[u8; 32]`
  - `asset_data_hash`: `Option<[u8; 32]>`
  - `flags`: `Option<u8>`
  - `nonce`: `u64`
  - `index`: `u32`
  - `message`: `MetadataArgsV2`
- **Account variants:**
  - `9 accounts:` `tree_authority`, `payer`, `creator`, `leaf_owner`, `leaf_delegate`, `merkle_tree`, `log_wrapper`, `compression_program`, `system_program`

### `UpdateAssetDataV2`
- **Discriminator:** `0x3b386f2b5f0e0b3d`
- **Args:**
  - `root`: `[u8; 32]`
  - `data_hash`: `[u8; 32]`
  - `creator_hash`: `[u8; 32]`
  - `previous_asset_data_hash`: `Option<[u8; 32]>`
  - `flags`: `Option<u8>`
  - `nonce`: `u64`
  - `index`: `u32`
  - `new_asset_data`: `Option<Vec<u8>>`
  - `new_asset_data_schema`: `Option<AssetDataSchema>`
- **Account variants:**
  - `10 accounts:` `tree_authority`, `payer`, `authority`, `leaf_owner`, `leaf_delegate`, `merkle_tree`, `core_collection`, `log_wrapper`, `compression_program`, `system_program`

### `UpdateMetadata`
- **Discriminator:** `0xaab62bef614ee1ba`
- **Args:**
  - `root`: `[u8; 32]`
  - `nonce`: `u64`
  - `index`: `u32`
  - `current_metadata`: `MetadataArgs`
  - `update_args`: `UpdateArgs`
- **Account variants:**
  - `13 accounts:` `tree_authority`, `authority`, `collection_mint`, `collection_metadata`, `collection_authority_record_pda`, `leaf_owner`, `leaf_delegate`, `payer`, `merkle_tree`, `log_wrapper`, `compression_program`, `token_metadata_program`, `system_program`

### `UpdateMetadataV2`
- **Discriminator:** `0x2b67592a79f23e48`
- **Args:**
  - `root`: `[u8; 32]`
  - `asset_data_hash`: `Option<[u8; 32]>`
  - `flags`: `Option<u8>`
  - `nonce`: `u64`
  - `index`: `u32`
  - `current_metadata`: `MetadataArgsV2`
  - `update_args`: `UpdateArgs`
- **Account variants:**
  - `10 accounts:` `tree_authority`, `payer`, `authority`, `leaf_owner`, `leaf_delegate`, `merkle_tree`, `core_collection`, `log_wrapper`, `compression_program`, `system_program`

### `VerifyCollection`
- **Discriminator:** `0x387165fd4f377aa9`
- **Args:**
  - `root`: `[u8; 32]`
  - `data_hash`: `[u8; 32]`
  - `creator_hash`: `[u8; 32]`
  - `nonce`: `u64`
  - `index`: `u32`
  - `message`: `MetadataArgs`
- **Account variants:**
  - `16 accounts:` `tree_authority`, `leaf_owner`, `leaf_delegate`, `merkle_tree`, `payer`, `tree_delegate`, `collection_authority`, `collection_authority_record_pda`, `collection_mint`, `collection_metadata`, `edition_account`, `bubblegum_signer`, `log_wrapper`, `compression_program`, `token_metadata_program`, `system_program`

### `VerifyCreator`
- **Discriminator:** `0x34116084470455c2`
- **Args:**
  - `root`: `[u8; 32]`
  - `data_hash`: `[u8; 32]`
  - `creator_hash`: `[u8; 32]`
  - `nonce`: `u64`
  - `index`: `u32`
  - `message`: `MetadataArgs`
- **Account variants:**
  - `9 accounts:` `tree_authority`, `leaf_owner`, `leaf_delegate`, `merkle_tree`, `payer`, `creator`, `log_wrapper`, `compression_program`, `system_program`

### `VerifyCreatorV2`
- **Discriminator:** `0x558a8c2a16f17666`
- **Args:**
  - `root`: `[u8; 32]`
  - `asset_data_hash`: `Option<[u8; 32]>`
  - `flags`: `Option<u8>`
  - `nonce`: `u64`
  - `index`: `u32`
  - `message`: `MetadataArgsV2`
- **Account variants:**
  - `9 accounts:` `tree_authority`, `payer`, `creator`, `leaf_owner`, `leaf_delegate`, `merkle_tree`, `log_wrapper`, `compression_program`, `system_program`

## Shared types

### `AssetDataSchema`
- Enum variants: `Binary`, `Json`, `MsgPack`

### `BubblegumEventType`
- Enum variants: `Uninitialized`, `LeafSchemaEvent`

### `Collection`
- `verified`: `bool`
- `key`: `Pubkey`

### `Creator`
- `address`: `Pubkey`
- `verified`: `bool`
- `share`: `u8`

### `DecompressibleState`
- Enum variants: `Enabled`, `Disabled`

### `InstructionName`
- Enum variants: `Unknown`, `MintV1`, `Redeem`, `CancelRedeem`, `Transfer`, `Delegate`, `DecompressV1`, `Compress`, `Burn`, `CreateTree`, `VerifyCreator`, `UnverifyCreator`, `VerifyCollection`, `UnverifyCollection`, `SetAndVerifyCollection`, `MintToCollectionV1`, `SetDecompressibleState`, `UpdateMetadata`, `BurnV2`, `CollectV2`, `CreateTreeV2`, `DelegateAndFreezeV2`, `DelegateV2`, `FreezeV2`, `MintV2`, `SetCollectionV2`, `SetNonTransferableV2`, `ThawAndRevokeV2`, `ThawV2`, `TransferV2`, `UnverifyCreatorV2`, `UpdateAssetDataV2`, `UpdateMetadataV2`, `VerifyCreatorV2`

### `LeafSchema`
- Enum variants:
  - `V1 { id: Pubkey, owner: Pubkey, delegate: Pubkey, nonce: u64, data_hash: [u8; 32], creator_hash: [u8; 32] }`
  - `V2 { id: Pubkey, owner: Pubkey, delegate: Pubkey, nonce: u64, data_hash: [u8; 32], creator_hash: [u8; 32], collection_hash: [u8; 32], asset_data_hash: [u8; 32], flags: u8 }`

### `MetadataArgs`
- `name`: `String`
- `symbol`: `String`
- `uri`: `String`
- `seller_fee_basis_points`: `u16`
- `primary_sale_happened`: `bool`
- `is_mutable`: `bool`
- `edition_nonce`: `Option<u8>`
- `token_standard`: `Option<TokenStandard>`
- `collection`: `Option<Collection>`
- `uses`: `Option<Uses>`
- `token_program_version`: `TokenProgramVersion`
- `creators`: `Vec<Creator>`

### `MetadataArgsV2`
- `name`: `String`
- `symbol`: `String`
- `uri`: `String`
- `seller_fee_basis_points`: `u16`
- `primary_sale_happened`: `bool`
- `is_mutable`: `bool`
- `token_standard`: `Option<TokenStandard>`
- `creators`: `Vec<Creator>`
- `collection`: `Option<Pubkey>`

### `TokenProgramVersion`
- Enum variants: `Original`, `Token2022`

### `TokenStandard`
- Enum variants: `NonFungible`, `FungibleAsset`, `Fungible`, `NonFungibleEdition`

### `UpdateArgs`
- `name`: `Option<String>`
- `symbol`: `Option<String>`
- `uri`: `Option<String>`
- `creators`: `Option<Vec<Creator>>`
- `seller_fee_basis_points`: `Option<u16>`
- `primary_sale_happened`: `Option<bool>`
- `is_mutable`: `Option<bool>`

### `UseMethod`
- Enum variants: `Burn`, `Multiple`, `Single`

### `Uses`
- `use_method`: `UseMethod`
- `remaining`: `u64`
- `total`: `u64`

### `Version`
- Enum variants: `V1`, `V2`
