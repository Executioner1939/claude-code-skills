# Metaplex Core

- **Crate:** `carbon-mpl-core-decoder`
- **Program ID:** `CoREENxT6tW1HoK8ypY1SxRMZTcVPm7R94rH4PZNhX7d`
- **Decoder struct:** `MplCoreProgramDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** no
- **Discriminator style:** mixed (8-byte for accounts, raw byte for instructions)

## Account types

### `AssetV1`
- **Discriminator:** `0xe011749de6d41eda`
- **Fields:**
  - `key`: `Key`
  - `owner`: `Pubkey`
  - `update_authority`: `UpdateAuthority`
  - `name`: `String`
  - `uri`: `String`
  - `seq`: `Option<u64>`

### `CollectionV1`
- **Discriminator:** `0xf1e9caaec3d4e560`
- **Fields:**
  - `key`: `Key`
  - `update_authority`: `Pubkey`
  - `name`: `String`
  - `uri`: `String`
  - `num_minted`: `u32`
  - `current_size`: `u32`

### `HashedAssetV1`
- **Discriminator:** `0xc56d2e767fef7e32`
- **Fields:**
  - `key`: `Key`
  - `hash`: `[u8; 32]`

### `PluginHeaderV1`
- **Discriminator:** `0xed32a5d026fd9998`
- **Fields:**
  - `key`: `Key`
  - `plugin_registry_offset`: `u64`

### `PluginRegistryV1`
- **Discriminator:** `0xa916f6dce5e5a4cc`
- **Fields:**
  - `key`: `Key`
  - `registry`: `Vec<RegistryRecord>`
  - `external_registry`: `Vec<ExternalRegistryRecord>`

## Instructions

### `CreateV1`
- **Discriminator:** `0x00`
- **Args:**
  - `create_v1_args`: `CreateV1Args`
- **Account variants:**
  - `8 accounts:` `asset, collection, authority, payer, owner, update_authority, system_program, log_wrapper`

### `CreateCollectionV1`
- **Discriminator:** `0x01`
- **Args:**
  - `create_collection_v1_args`: `CreateCollectionV1Args`
- **Account variants:**
  - `4 accounts:` `collection, update_authority, payer, system_program`

### `AddPluginV1`
- **Discriminator:** `0x02`
- **Args:**
  - `add_plugin_v1_args`: `AddPluginV1Args`
- **Account variants:**
  - `6 accounts:` `asset, collection, payer, authority, system_program, log_wrapper`

### `AddCollectionPluginV1`
- **Discriminator:** `0x03`
- **Args:**
  - `add_collection_plugin_v1_args`: `AddCollectionPluginV1Args`
- **Account variants:**
  - `5 accounts:` `collection, payer, authority, system_program, log_wrapper`

### `RemovePluginV1`
- **Discriminator:** `0x04`
- **Args:**
  - `remove_plugin_v1_args`: `RemovePluginV1Args`
- **Account variants:**
  - `6 accounts:` `asset, collection, payer, authority, system_program, log_wrapper`

### `RemoveCollectionPluginV1`
- **Discriminator:** `0x05`
- **Args:**
  - `remove_collection_plugin_v1_args`: `RemoveCollectionPluginV1Args`
- **Account variants:**
  - `5 accounts:` `collection, payer, authority, system_program, log_wrapper`

### `UpdatePluginV1`
- **Discriminator:** `0x06`
- **Args:**
  - `update_plugin_v1_args`: `UpdatePluginV1Args`
- **Account variants:**
  - `6 accounts:` `asset, collection, payer, authority, system_program, log_wrapper`

### `UpdateCollectionPluginV1`
- **Discriminator:** `0x07`
- **Args:**
  - `update_collection_plugin_v1_args`: `UpdateCollectionPluginV1Args`
- **Account variants:**
  - `5 accounts:` `collection, payer, authority, system_program, log_wrapper`

### `ApprovePluginAuthorityV1`
- **Discriminator:** `0x08`
- **Args:**
  - `approve_plugin_authority_v1_args`: `ApprovePluginAuthorityV1Args`
- **Account variants:**
  - `6 accounts:` `asset, collection, payer, authority, system_program, log_wrapper`

### `ApproveCollectionPluginAuthorityV1`
- **Discriminator:** `0x09`
- **Args:**
  - `approve_collection_plugin_authority_v1_args`: `ApproveCollectionPluginAuthorityV1Args`
- **Account variants:**
  - `5 accounts:` `collection, payer, authority, system_program, log_wrapper`

### `RevokePluginAuthorityV1`
- **Discriminator:** `0x0a`
- **Args:**
  - `revoke_plugin_authority_v1_args`: `RevokePluginAuthorityV1Args`
- **Account variants:**
  - `6 accounts:` `asset, collection, payer, authority, system_program, log_wrapper`

### `RevokeCollectionPluginAuthorityV1`
- **Discriminator:** `0x0b`
- **Args:**
  - `revoke_collection_plugin_authority_v1_args`: `RevokeCollectionPluginAuthorityV1Args`
- **Account variants:**
  - `5 accounts:` `collection, payer, authority, system_program, log_wrapper`

### `BurnV1`
- **Discriminator:** `0x0c`
- **Args:**
  - `burn_v1_args`: `BurnV1Args`
- **Account variants:**
  - `6 accounts:` `asset, collection, payer, authority, system_program, log_wrapper`

### `BurnCollectionV1`
- **Discriminator:** `0x0d`
- **Args:**
  - `burn_collection_v1_args`: `BurnCollectionV1Args`
- **Account variants:**
  - `4 accounts:` `collection, payer, authority, log_wrapper`

### `TransferV1`
- **Discriminator:** `0x0e`
- **Args:**
  - `transfer_v1_args`: `TransferV1Args`
- **Account variants:**
  - `7 accounts:` `asset, collection, payer, authority, new_owner, system_program, log_wrapper`

### `UpdateV1`
- **Discriminator:** `0x0f`
- **Args:**
  - `update_v1_args`: `UpdateV1Args`
- **Account variants:**
  - `6 accounts:` `asset, collection, payer, authority, system_program, log_wrapper`

### `UpdateCollectionV1`
- **Discriminator:** `0x10`
- **Args:**
  - `update_collection_v1_args`: `UpdateCollectionV1Args`
- **Account variants:**
  - `6 accounts:` `collection, payer, authority, new_update_authority, system_program, log_wrapper`

### `CompressV1`
- **Discriminator:** `0x11`
- **Args:**
  - `compress_v1_args`: `CompressV1Args`
- **Account variants:**
  - `6 accounts:` `asset, collection, payer, authority, system_program, log_wrapper`

### `DecompressV1`
- **Discriminator:** `0x12`
- **Args:**
  - `decompress_v1_args`: `DecompressV1Args`
- **Account variants:**
  - `6 accounts:` `asset, collection, payer, authority, system_program, log_wrapper`

### `Collect`
- **Discriminator:** `0x13`
- **Args:**
  - `(none)`
- **Account variants:**
  - `2 accounts:` `recipient1, recipient2`

### `CreateV2`
- **Discriminator:** `0x14`
- **Args:**
  - `create_v2_args`: `CreateV2Args`
- **Account variants:**
  - `8 accounts:` `asset, collection, authority, payer, owner, update_authority, system_program, log_wrapper`

### `CreateCollectionV2`
- **Discriminator:** `0x15`
- **Args:**
  - `create_collection_v2_args`: `CreateCollectionV2Args`
- **Account variants:**
  - `4 accounts:` `collection, update_authority, payer, system_program`

### `AddExternalPluginAdapterV1`
- **Discriminator:** `0x16`
- **Args:**
  - `add_external_plugin_adapter_v1_args`: `AddExternalPluginAdapterV1Args`
- **Account variants:**
  - `6 accounts:` `asset, collection, payer, authority, system_program, log_wrapper`

### `AddCollectionExternalPluginAdapterV1`
- **Discriminator:** `0x17`
- **Args:**
  - `add_collection_external_plugin_adapter_v1_args`: `AddCollectionExternalPluginAdapterV1Args`
- **Account variants:**
  - `5 accounts:` `collection, payer, authority, system_program, log_wrapper`

### `RemoveExternalPluginAdapterV1`
- **Discriminator:** `0x18`
- **Args:**
  - `remove_external_plugin_adapter_v1_args`: `RemoveExternalPluginAdapterV1Args`
- **Account variants:**
  - `6 accounts:` `asset, collection, payer, authority, system_program, log_wrapper`

### `RemoveCollectionExternalPluginAdapterV1`
- **Discriminator:** `0x19`
- **Args:**
  - `remove_collection_external_plugin_adapter_v1_args`: `RemoveCollectionExternalPluginAdapterV1Args`
- **Account variants:**
  - `5 accounts:` `collection, payer, authority, system_program, log_wrapper`

### `UpdateExternalPluginAdapterV1`
- **Discriminator:** `0x1a`
- **Args:**
  - `update_external_plugin_adapter_v1_args`: `UpdateExternalPluginAdapterV1Args`
- **Account variants:**
  - `6 accounts:` `asset, collection, payer, authority, system_program, log_wrapper`

### `UpdateCollectionExternalPluginAdapterV1`
- **Discriminator:** `0x1b`
- **Args:**
  - `update_collection_external_plugin_adapter_v1_args`: `UpdateCollectionExternalPluginAdapterV1Args`
- **Account variants:**
  - `5 accounts:` `collection, payer, authority, system_program, log_wrapper`

### `WriteExternalPluginAdapterDataV1`
- **Discriminator:** `0x1c`
- **Args:**
  - `write_external_plugin_adapter_data_v1_args`: `WriteExternalPluginAdapterDataV1Args`
- **Account variants:**
  - `7 accounts:` `asset, collection, payer, authority, buffer, system_program, log_wrapper`

### `WriteCollectionExternalPluginAdapterDataV1`
- **Discriminator:** `0x1d`
- **Args:**
  - `write_collection_external_plugin_adapter_data_v1_args`: `WriteCollectionExternalPluginAdapterDataV1Args`
- **Account variants:**
  - `6 accounts:` `collection, payer, authority, buffer, system_program, log_wrapper`

### `UpdateV2`
- **Discriminator:** `0x1e`
- **Args:**
  - `update_v2_args`: `UpdateV2Args`
- **Account variants:**
  - `7 accounts:` `asset, collection, payer, authority, new_collection, system_program, log_wrapper`

### `ExecuteV1`
- **Discriminator:** `0x1f`
- **Args:**
  - `execute_v1_args`: `ExecuteV1Args`
- **Account variants:**
  - `7 accounts:` `asset, collection, asset_signer, payer, authority, system_program, program_id`

## Shared types

### `Key` (enum)
- `Uninitialized | AssetV1 | HashedAssetV1 | PluginHeaderV1 | PluginRegistryV1 | CollectionV1`

### `UpdateAuthority` (enum)
- `None | Address(Pubkey) | Collection(Pubkey)`

### `Authority` (enum)
- `None | Owner | UpdateAuthority | Address { address: Pubkey }`

### `DataState` (enum)
- `AccountState | LedgerState`

### `Plugin` (enum)
- Variants: `Royalties(Royalties) | FreezeDelegate(FreezeDelegate) | BurnDelegate(BurnDelegate) | TransferDelegate(TransferDelegate) | UpdateDelegate(UpdateDelegate) | PermanentFreezeDelegate(PermanentFreezeDelegate) | Attributes(Attributes) | PermanentTransferDelegate(PermanentTransferDelegate) | PermanentBurnDelegate(PermanentBurnDelegate) | Edition(Edition) | MasterEdition(MasterEdition) | AddBlocker(AddBlocker) | ImmutableMetadata(ImmutableMetadata) | VerifiedCreators(VerifiedCreators) | Autograph(Autograph)`

### `PluginType` (enum)
- Variants: `Royalties | FreezeDelegate | BurnDelegate | TransferDelegate | UpdateDelegate | PermanentFreezeDelegate | Attributes | PermanentTransferDelegate | PermanentBurnDelegate | Edition | MasterEdition | AddBlocker | ImmutableMetadata | VerifiedCreators | Autograph`

### `ExternalPluginAdapter` (enum)
- `LifecycleHook(LifecycleHook) | Oracle(Oracle) | AppData(AppData) | LinkedLifecycleHook(LinkedLifecycleHook) | LinkedAppData(LinkedAppData) | DataSection(DataSection)`

### `ExternalPluginAdapterType` (enum)
- `LifecycleHook | Oracle | AppData | LinkedLifecycleHook | LinkedAppData | DataSection`

### `ExternalPluginAdapterKey` (enum)
- `LifecycleHook(Pubkey) | Oracle(Pubkey) | AppData(Authority) | LinkedLifecycleHook(Pubkey) | LinkedAppData(Authority) | DataSection(LinkedDataKey)`

### `ExternalPluginAdapterInitInfo` (enum)
- `LifecycleHook(LifecycleHookInitInfo) | Oracle(OracleInitInfo) | AppData(AppDataInitInfo) | LinkedLifecycleHook(LinkedLifecycleHookInitInfo) | LinkedAppData(LinkedAppDataInitInfo) | DataSection(DataSectionInitInfo)`

### `ExternalPluginAdapterUpdateInfo` (enum)
- `LifecycleHook(LifecycleHookUpdateInfo) | Oracle(OracleUpdateInfo) | AppData(AppDataUpdateInfo) | LinkedLifecycleHook(LinkedLifecycleHookUpdateInfo) | LinkedAppData(LinkedAppDataUpdateInfo)`

### `ExternalPluginAdapterSchema` (enum)
- `Binary | Json | MsgPack`

### `LinkedDataKey` (enum)
- `LinkedLifecycleHook(Pubkey) | LinkedAppData(Authority)`

### `RuleSet` (enum)
- `None | ProgramAllowList(Vec<Pubkey>) | ProgramDenyList(Vec<Pubkey>)`

### `Seed` (enum)
- `Collection | Owner | Recipient | Asset | Address(Pubkey) | Bytes(Vec<u8>)`

### `ExtraAccount` (enum)
- `PreconfiguredProgram { is_signer, is_writable } | PreconfiguredCollection | PreconfiguredOwner | PreconfiguredRecipient | PreconfiguredAsset | CustomPda { seeds: Vec<Seed>, custom_program_id: Option<Pubkey>, ... } | Address { address: Pubkey, is_signer, is_writable }`

### `OracleValidation` (enum)
- `Uninitialized | V1 { create: ExternalValidationResult, transfer: ExternalValidationResult, burn: ExternalValidationResult, update: ExternalValidationResult }`

### `ValidationResult` (enum)
- `Approved | Rejected | Pass | ForceApproved`

### `ExternalValidationResult` (enum)
- `Approved | Rejected | Pass`

### `ValidationResultsOffset` (enum)
- `NoOffset | Anchor | Custom(u64)`

### `HookableLifecycleEvent` (enum)
- `Create | Transfer | Burn | Update`

### `RegistryRecord`
- `plugin_type`: `PluginType`
- `authority`: `Authority`
- `offset`: `u64`

### `ExternalRegistryRecord`
- `plugin_type`: `ExternalPluginAdapterType`
- `authority`: `Authority`
- `lifecycle_checks`: `Option<Vec<(HookableLifecycleEvent, ExternalCheckResult)>>`
- `offset`: `u64`
- `data_offset`: `Option<u64>`
- `data_len`: `Option<u64>`

### `ExternalCheckResult`
- `flags`: `u32`

### `PluginAuthorityPair`
- `plugin`: `Plugin`
- `authority`: `Option<Authority>`

### `Royalties`
- `basis_points`: `u16`
- `creators`: `Vec<Creator>`
- `rule_set`: `RuleSet`

### `Creator`
- `address`: `Pubkey`
- `percentage`: `u8`

### `FreezeDelegate`
- `frozen`: `bool`

### `PermanentFreezeDelegate`
- `frozen`: `bool`

### `Edition`
- `number`: `u32`

### `MasterEdition`
- `max_supply`: `Option<u32>`
- `name`: `Option<String>`
- `uri`: `Option<String>`

### `UpdateDelegate`
- `additional_delegates`: `Vec<Pubkey>`

### `Attribute`
- `key`: `String`
- `value`: `String`

### `Attributes`
- `attribute_list`: `Vec<Attribute>`

### `Autograph`
- `signatures`: `Vec<AutographSignature>`

### `AutographSignature`
- `address`: `Pubkey`
- `message`: `String`

### `VerifiedCreators`
- `signatures`: `Vec<VerifiedCreatorsSignature>`

### `VerifiedCreatorsSignature`
- `address`: `Pubkey`
- `verified`: `bool`

### `CompressionProof`
- `owner`: `Pubkey`
- `update_authority`: `UpdateAuthority`
- `name`: `String`
- `uri`: `String`
- `seq`: `u64`
- `plugins`: `Vec<HashablePluginSchema>`

### `HashablePluginSchema`
- `index`: `u64`
- `authority`: `Authority`
- `plugin`: `Plugin`

### `HashedAssetSchema`
- `asset_hash`: `[u8; 32]`
- `plugin_hashes`: `Vec<[u8; 32]>`

### `LifecycleHook`
- `hooked_program`: `Pubkey`
- `extra_accounts`: `Option<Vec<ExtraAccount>>`
- `data_authority`: `Option<Authority>`
- `schema`: `ExternalPluginAdapterSchema`

### `LifecycleHookInitInfo`
- `hooked_program`: `Pubkey`
- `init_plugin_authority`: `Option<Authority>`
- `lifecycle_checks`: `Vec<(HookableLifecycleEvent, ExternalCheckResult)>`
- `extra_accounts`: `Option<Vec<ExtraAccount>>`
- `data_authority`: `Option<Authority>`
- `schema`: `Option<ExternalPluginAdapterSchema>`

### `LifecycleHookUpdateInfo`
- `lifecycle_checks`: `Option<Vec<(HookableLifecycleEvent, ExternalCheckResult)>>`
- `extra_accounts`: `Option<Vec<ExtraAccount>>`
- `schema`: `Option<ExternalPluginAdapterSchema>`

### `LinkedLifecycleHook`
- Same fields as `LifecycleHook`.

### `LinkedLifecycleHookInitInfo`
- Same fields as `LifecycleHookInitInfo`.

### `LinkedLifecycleHookUpdateInfo`
- Same fields as `LifecycleHookUpdateInfo`.

### `Oracle`
- `base_address`: `Pubkey`
- `base_address_config`: `Option<ExtraAccount>`
- `results_offset`: `ValidationResultsOffset`

### `OracleInitInfo`
- `base_address`: `Pubkey`
- `init_plugin_authority`: `Option<Authority>`
- `lifecycle_checks`: `Vec<(HookableLifecycleEvent, ExternalCheckResult)>`
- `base_address_config`: `Option<ExtraAccount>`
- `results_offset`: `Option<ValidationResultsOffset>`

### `OracleUpdateInfo`
- `lifecycle_checks`: `Option<Vec<(HookableLifecycleEvent, ExternalCheckResult)>>`
- `base_address_config`: `Option<ExtraAccount>`
- `results_offset`: `Option<ValidationResultsOffset>`

### `AppData`
- `data_authority`: `Authority`
- `schema`: `ExternalPluginAdapterSchema`

### `AppDataInitInfo`
- `data_authority`: `Authority`
- `init_plugin_authority`: `Option<Authority>`
- `schema`: `Option<ExternalPluginAdapterSchema>`

### `AppDataUpdateInfo`
- `schema`: `Option<ExternalPluginAdapterSchema>`

### `LinkedAppData` / `LinkedAppDataInitInfo` / `LinkedAppDataUpdateInfo`
- Same shape as `AppData` / `AppDataInitInfo` / `AppDataUpdateInfo`.

### `DataSection`
- `parent_key`: `LinkedDataKey`
- `schema`: `ExternalPluginAdapterSchema`

### `DataSectionInitInfo`
- `parent_key`: `LinkedDataKey`
- `schema`: `ExternalPluginAdapterSchema`

### Empty marker structs
- `AddBlocker`, `BurnDelegate`, `TransferDelegate`, `PermanentBurnDelegate`, `PermanentTransferDelegate`, `ImmutableMetadata`, `CompressV1Args`, `DataSectionUpdateInfo` *(unit/empty structs)*

### Args structs (instruction payloads)
- `AddPluginV1Args { plugin: Plugin, init_authority: Option<Authority> }`
- `AddCollectionPluginV1Args { plugin: Plugin, init_authority: Option<Authority> }`
- `AddExternalPluginAdapterV1Args { init_info: ExternalPluginAdapterInitInfo }`
- `AddCollectionExternalPluginAdapterV1Args { init_info: ExternalPluginAdapterInitInfo }`
- `ApprovePluginAuthorityV1Args { plugin_type: PluginType, new_authority: Authority }`
- `ApproveCollectionPluginAuthorityV1Args { plugin_type: PluginType, new_authority: Authority }`
- `BurnV1Args { compression_proof: Option<CompressionProof> }`
- `BurnCollectionV1Args { compression_proof: Option<CompressionProof> }`
- `CreateV1Args { data_state: DataState, name: String, uri: String, plugins: Option<Vec<PluginAuthorityPair>> }`
- `CreateV2Args { data_state, name, uri, plugins, external_plugin_adapters: Option<Vec<ExternalPluginAdapterInitInfo>> }`
- `CreateCollectionV1Args { name: String, uri: String, plugins: Option<Vec<PluginAuthorityPair>> }`
- `CreateCollectionV2Args { name, uri, plugins, external_plugin_adapters: Option<Vec<ExternalPluginAdapterInitInfo>> }`
- `DecompressV1Args { compression_proof: CompressionProof }`
- `ExecuteV1Args { instruction_data: Vec<u8> }`
- `RemovePluginV1Args { plugin_type: PluginType }`
- `RemoveCollectionPluginV1Args { plugin_type: PluginType }`
- `RemoveExternalPluginAdapterV1Args { key: ExternalPluginAdapterKey }`
- `RemoveCollectionExternalPluginAdapterV1Args { key: ExternalPluginAdapterKey }`
- `RevokePluginAuthorityV1Args { plugin_type: PluginType }`
- `RevokeCollectionPluginAuthorityV1Args { plugin_type: PluginType }`
- `TransferV1Args { compression_proof: Option<CompressionProof> }`
- `UpdatePluginV1Args { plugin: Plugin }`
- `UpdateCollectionPluginV1Args { plugin: Plugin }`
- `UpdateV1Args { new_name: Option<String>, new_uri: Option<String>, new_update_authority: Option<UpdateAuthority> }`
- `UpdateV2Args { new_name, new_uri, new_update_authority }`
- `UpdateCollectionV1Args { new_name: Option<String>, new_uri: Option<String> }`
- `UpdateExternalPluginAdapterV1Args { key: ExternalPluginAdapterKey, update_info: ExternalPluginAdapterUpdateInfo }`
- `UpdateCollectionExternalPluginAdapterV1Args { key, update_info }`
- `WriteExternalPluginAdapterDataV1Args { key: ExternalPluginAdapterKey, data: Option<Vec<u8>> }`
- `WriteCollectionExternalPluginAdapterDataV1Args { key, data }`
