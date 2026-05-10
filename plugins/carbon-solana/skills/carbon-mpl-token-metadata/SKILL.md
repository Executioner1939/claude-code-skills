---
name: carbon-mpl-token-metadata
description: Carbon decoder reference for Metaplex Token Metadata on Solana — program `metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s`, crate `carbon-mpl-token-metadata-decoder` (58 instructions, 14 account types). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "Metaplex Token Metadata", "mpl-token-metadata", "carbon-mpl-token-metadata-decoder", "metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s", "TokenMetadataDecoder", "CreateMetadataAccount", "UpdateMetadataAccount", "DeprecatedCreateMasterEdition", "DeprecatedMintNewEditionFromMasterEditionViaPrintingToken", "UpdatePrimarySaleHappenedViaToken", "DeprecatedSetReservationList", "Metadata", "MasterEditionV1", "MasterEditionV2", "Edition".
---

# Metaplex Token Metadata

- **Crate:** `carbon-mpl-token-metadata-decoder`
- **Program ID:** `metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s`
- **Decoder struct:** `TokenMetadataDecoder`
- **Has CPI events:** no

## Instructions

- `CreateMetadataAccount`
- `UpdateMetadataAccount`
- `DeprecatedCreateMasterEdition`
- `DeprecatedMintNewEditionFromMasterEditionViaPrintingToken`
- `UpdatePrimarySaleHappenedViaToken`
- `DeprecatedSetReservationList`
- `DeprecatedCreateReservationList`
- `SignMetadata`
- `DeprecatedMintPrintingTokensViaToken`
- `DeprecatedMintPrintingTokens`
- `CreateMasterEdition`
- `MintNewEditionFromMasterEditionViaToken`
- `ConvertMasterEditionV1ToV2`
- `MintNewEditionFromMasterEditionViaVaultProxy`
- `PuffMetadata`
- `UpdateMetadataAccountV2`
- `CreateMetadataAccountV2`
- `CreateMasterEditionV3`
- `VerifyCollection`
- `Utilize`
- `ApproveUseAuthority`
- `RevokeUseAuthority`
- `UnverifyCollection`
- `ApproveCollectionAuthority`
- `RevokeCollectionAuthority`
- `SetAndVerifyCollection`
- `FreezeDelegatedAccount`
- `ThawDelegatedAccount`
- `RemoveCreatorVerification`
- `BurnNft`
- `VerifySizedCollectionItem`
- `UnverifySizedCollectionItem`
- `SetAndVerifySizedCollectionItem`
- `CreateMetadataAccountV3`
- `SetCollectionSize`
- `SetTokenStandard`
- `BubblegumSetCollectionSize`
- `BurnEditionNft`
- `CreateEscrowAccount`
- `CloseEscrowAccount`
- `TransferOutOfEscrow`
- `Burn`
- `Create`
- `Mint`
- `Delegate`
- `Revoke`
- `Lock`
- `Unlock`
- `Migrate`
- `Transfer`
- `Update`
- `Use`
- `Verify`
- `Unverify`
- `Collect`
- `Print`
- `Resize`
- `CloseAccounts`

## Account types

- `Metadata`
- `MasterEditionV1`
- `MasterEditionV2`
- `Edition`
- `EditionMarker`
- `EditionMarkerV2`
- `CollectionAuthorityRecord`
- `MetadataDelegateRecord`
- `HolderDelegateRecord`
- `UseAuthorityRecord`
- `TokenRecord`
- `TokenOwnedEscrow`
- `ReservationListV1`
- `ReservationListV2`

## Shared types

- `Key`
- `Data`
- `DataV2`
- `AssetData`
- `Creator`
- `Collection`
- `CollectionDetails`
- `CollectionToggle`
- `CollectionDetailsToggle`
- `Uses`
- `UseMethod`
- `UsesToggle`
- `RuleSetToggle`
- `ProgrammableConfig`
- `TokenStandard`
- `TokenState`
- `TokenDelegateRole`
- `MetadataDelegateRole`
- `HolderDelegateRole`
- `AuthorityType`
- `EscrowAuthority`
- `MigrationType`
- `PrintSupply`
- `Reservation`
- `ReservationV1`
- `Payload`
- `PayloadKey`
- `PayloadType`
- `SeedsVec`
- `ProofInfo`
- `AuthorizationData`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list mpl-token-metadata

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix mpl-token-metadata <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account mpl-token-metadata <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event mpl-token-metadata <EventName>

# shared type fields
python3 "$CARBON" type mpl-token-metadata <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path mpl-token-metadata
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-mpl-token-metadata-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
