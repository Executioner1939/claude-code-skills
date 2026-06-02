---
name: carbon-mpl-core
description: "Carbon decoder reference for Metaplex MPL Core on Solana — program `CoREENxT6tW1HoK8ypY1SxRMZTcVPm7R94rH4PZNhX7d`, crate `carbon-mpl-core-decoder` (32 instructions, 5 account types). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"Metaplex Core\", \"mpl-core\", \"carbon-mpl-core-decoder\", \"CoREENxT6tW1HoK8ypY1SxRMZTcVPm7R94rH4PZNhX7d\", \"MplCoreProgramDecoder\", \"Metaplex MPL Core\", \"CreateV1\", \"CreateCollectionV1\", \"AddPluginV1\", \"AddCollectionPluginV1\", \"RemovePluginV1\", \"RemoveCollectionPluginV1\", \"AssetV1\", \"CollectionV1\", \"HashedAssetV1\", \"PluginHeaderV1\"."
---

# Metaplex Core

- **Crate:** `carbon-mpl-core-decoder`
- **Program ID:** `CoREENxT6tW1HoK8ypY1SxRMZTcVPm7R94rH4PZNhX7d`
- **Decoder struct:** `MplCoreProgramDecoder`
- **Has CPI events:** no

## Instructions

- `CreateV1`
- `CreateCollectionV1`
- `AddPluginV1`
- `AddCollectionPluginV1`
- `RemovePluginV1`
- `RemoveCollectionPluginV1`
- `UpdatePluginV1`
- `UpdateCollectionPluginV1`
- `ApprovePluginAuthorityV1`
- `ApproveCollectionPluginAuthorityV1`
- `RevokePluginAuthorityV1`
- `RevokeCollectionPluginAuthorityV1`
- `BurnV1`
- `BurnCollectionV1`
- `TransferV1`
- `UpdateV1`
- `UpdateCollectionV1`
- `CompressV1`
- `DecompressV1`
- `Collect`
- `CreateV2`
- `CreateCollectionV2`
- `AddExternalPluginAdapterV1`
- `AddCollectionExternalPluginAdapterV1`
- `RemoveExternalPluginAdapterV1`
- `RemoveCollectionExternalPluginAdapterV1`
- `UpdateExternalPluginAdapterV1`
- `UpdateCollectionExternalPluginAdapterV1`
- `WriteExternalPluginAdapterDataV1`
- `WriteCollectionExternalPluginAdapterDataV1`
- `UpdateV2`
- `ExecuteV1`

## Account types

- `AssetV1`
- `CollectionV1`
- `HashedAssetV1`
- `PluginHeaderV1`
- `PluginRegistryV1`

## Shared types

- `Key`
- `UpdateAuthority`
- `Authority`
- `DataState`
- `Plugin`
- `PluginType`
- `ExternalPluginAdapter`
- `ExternalPluginAdapterType`
- `ExternalPluginAdapterKey`
- `ExternalPluginAdapterInitInfo`
- `ExternalPluginAdapterUpdateInfo`
- `ExternalPluginAdapterSchema`
- `LinkedDataKey`
- `RuleSet`
- `Seed`
- `ExtraAccount`
- `OracleValidation`
- `ValidationResult`
- `ExternalValidationResult`
- `ValidationResultsOffset`
- `HookableLifecycleEvent`
- `RegistryRecord`
- `ExternalRegistryRecord`
- `ExternalCheckResult`
- `PluginAuthorityPair`
- `Royalties`
- `Creator`
- `FreezeDelegate`
- `PermanentFreezeDelegate`
- `Edition`
- `MasterEdition`
- `UpdateDelegate`
- `Attribute`
- `Attributes`
- `Autograph`
- `AutographSignature`
- `VerifiedCreators`
- `VerifiedCreatorsSignature`
- `CompressionProof`
- `HashablePluginSchema`
- `HashedAssetSchema`
- `LifecycleHook`
- `LifecycleHookInitInfo`
- `LifecycleHookUpdateInfo`
- `LinkedLifecycleHook`
- `LinkedLifecycleHookInitInfo`
- `LinkedLifecycleHookUpdateInfo`
- `Oracle`
- `OracleInitInfo`
- `OracleUpdateInfo`
- `AppData`
- `AppDataInitInfo`
- `AppDataUpdateInfo`
- `LinkedAppData`
- `DataSection`
- `DataSectionInitInfo`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list mpl-core

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix mpl-core <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account mpl-core <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event mpl-core <EventName>

# shared type fields
python3 "$CARBON" type mpl-core <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path mpl-core
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-mpl-core-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
