---
name: carbon-bubblegum
description: "Carbon decoder reference for Metaplex Bubblegum (compressed NFTs) on Solana — program `BGUMAp9Gq7iTEuizy4pqaxsTyUCBK68MDfK752saRPUY`, crate `carbon-bubblegum-decoder` (35 instructions, 2 account types). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"Bubblegum\", \"bubblegum\", \"carbon-bubblegum-decoder\", \"BGUMAp9Gq7iTEuizy4pqaxsTyUCBK68MDfK752saRPUY\", \"BubblegumDecoder\", \"Metaplex Bubblegum (compressed NFTs)\", \"Burn\", \"BurnV2\", \"CancelRedeem\", \"CollectV2\", \"Compress\", \"CreateTree\", \"TreeConfig\", \"Voucher\"."
---

# Bubblegum

- **Crate:** `carbon-bubblegum-decoder`
- **Program ID:** `BGUMAp9Gq7iTEuizy4pqaxsTyUCBK68MDfK752saRPUY`
- **Decoder struct:** `BubblegumDecoder`
- **Has CPI events:** no

## Instructions

- `Burn`
- `BurnV2`
- `CancelRedeem`
- `CollectV2`
- `Compress`
- `CreateTree`
- `CreateTreeV2`
- `DecompressV1`
- `Delegate`
- `DelegateAndFreezeV2`
- `DelegateV2`
- `FreezeV2`
- `MintToCollectionV1`
- `MintV1`
- `MintV2`
- `Redeem`
- `SetAndVerifyCollection`
- `SetCollectionV2`
- `SetDecompressableState`
- `SetDecompressibleState`
- `SetNonTransferableV2`
- `SetTreeDelegate`
- `ThawAndRevokeV2`
- `ThawV2`
- `Transfer`
- `TransferV2`
- `UnverifyCollection`
- `UnverifyCreator`
- `UnverifyCreatorV2`
- `UpdateAssetDataV2`
- `UpdateMetadata`
- `UpdateMetadataV2`
- `VerifyCollection`
- `VerifyCreator`
- `VerifyCreatorV2`

## Account types

- `TreeConfig`
- `Voucher`

## Shared types

- `AssetDataSchema`
- `BubblegumEventType`
- `Collection`
- `Creator`
- `DecompressibleState`
- `InstructionName`
- `LeafSchema`
- `MetadataArgs`
- `MetadataArgsV2`
- `TokenProgramVersion`
- `TokenStandard`
- `UpdateArgs`
- `UseMethod`
- `Uses`
- `Version`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list bubblegum

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix bubblegum <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account bubblegum <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event bubblegum <EventName>

# shared type fields
python3 "$CARBON" type bubblegum <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path bubblegum
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-bubblegum-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
