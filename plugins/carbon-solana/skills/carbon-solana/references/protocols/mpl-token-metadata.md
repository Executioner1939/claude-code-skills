# Metaplex Token Metadata

- **Crate:** `carbon-mpl-token-metadata-decoder`
- **Program ID:** `metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s`
- **Decoder struct:** `TokenMetadataDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** no
- **Discriminator style:** raw byte (instructions); accounts disambiguated by leading `Key` enum variant

## Account types

Account structs share a leading `key: Key` discriminator (`Key` enum variant identifies the type — see `Key` in shared types).

### `Metadata`
- **Fields:**
  - `key`: `Key`
  - `update_authority`: `Pubkey`
  - `mint`: `Pubkey`
  - `data`: `Data`
  - `primary_sale_happened`: `bool`
  - `is_mutable`: `bool`
  - `edition_nonce`: `Option<u8>`
  - `token_standard`: `Option<TokenStandard>`
  - `collection`: `Option<Collection>`
  - `uses`: `Option<Uses>`
  - `collection_details`: `Option<CollectionDetails>`
  - `programmable_config`: `Option<ProgrammableConfig>`

### `MasterEditionV1`
- **Fields:**
  - `key`: `Key`
  - `supply`: `u64`
  - `max_supply`: `Option<u64>`
  - `printing_mint`: `Pubkey`
  - `one_time_printing_authorization_mint`: `Pubkey`

### `MasterEditionV2`
- **Fields:**
  - `key`: `Key`
  - `supply`: `u64`
  - `max_supply`: `Option<u64>`

### `Edition`
- **Fields:**
  - `key`: `Key`
  - `parent`: `Pubkey`
  - `edition`: `u64`

### `EditionMarker`
- **Fields:**
  - `key`: `Key`
  - `ledger`: `[u8; 31]`

### `EditionMarkerV2`
- **Fields:**
  - `key`: `Key`
  - `ledger`: `Vec<u8>`

### `CollectionAuthorityRecord`
- **Fields:**
  - `key`: `Key`
  - `bump`: `u8`
  - `update_authority`: `Option<Pubkey>`

### `MetadataDelegateRecord`
- **Fields:**
  - `key`: `Key`
  - `bump`: `u8`
  - `mint`: `Pubkey`
  - `delegate`: `Pubkey`
  - `update_authority`: `Pubkey`

### `HolderDelegateRecord`
- **Fields:** (same shape as `MetadataDelegateRecord`)
  - `key`: `Key`, `bump`: `u8`, `mint`: `Pubkey`, `delegate`: `Pubkey`, `update_authority`: `Pubkey`

### `UseAuthorityRecord`
- **Fields:**
  - `key`: `Key`
  - `allowed_uses`: `u64`
  - `bump`: `u8`

### `TokenRecord`
- **Fields:**
  - `key`: `Key`
  - `bump`: `u8`
  - `state`: `TokenState`
  - `rule_set_revision`: `Option<u64>`
  - `delegate`: `Option<Pubkey>`
  - `delegate_role`: `Option<TokenDelegateRole>`
  - `locked_transfer`: `Option<Pubkey>`

### `TokenOwnedEscrow`
- **Fields:**
  - `key`: `Key`
  - `base_token`: `Pubkey`
  - `authority`: `EscrowAuthority`
  - `bump`: `u8`

### `ReservationListV1`
- **Fields:**
  - `key`: `Key`
  - `master_edition`: `Pubkey`
  - `supply_snapshot`: `Option<u64>`
  - `reservations`: `Vec<ReservationV1>`

### `ReservationListV2`
- **Fields:**
  - `key`: `Key`
  - `master_edition`: `Pubkey`
  - `supply_snapshot`: `Option<u64>`
  - `reservations`: `Vec<Reservation>`
  - `total_reservation_spots`: `u64`
  - `current_reservation_spots`: `u64`

## Instructions

### `CreateMetadataAccount`
- **Discriminator:** `0x00`
- **Account variants:** `7 accounts:` `metadata, mint, mint_authority, payer, update_authority, system_program, rent`

### `UpdateMetadataAccount`
- **Discriminator:** `0x01`
- **Account variants:** `2 accounts:` `metadata, update_authority`

### `DeprecatedCreateMasterEdition`
- **Discriminator:** `0x02`
- **Account variants:** `13 accounts:` `edition, mint, printing_mint, one_time_printing_authorization_mint, update_authority, printing_mint_authority, mint_authority, metadata, payer, token_program, system_program, rent, one_time_printing_authorization_mint_authority`

### `DeprecatedMintNewEditionFromMasterEditionViaPrintingToken`
- **Discriminator:** `0x03`
- **Account variants:** `15 accounts + optional reservation_list:` `metadata, edition, master_edition, mint, mint_authority, printing_mint, master_token_account, edition_marker, burn_authority, payer, master_update_authority, master_metadata, token_program, system_program, rent, reservation_list?`
- **Optional accounts:** `reservation_list`

### `UpdatePrimarySaleHappenedViaToken`
- **Discriminator:** `0x04`
- **Account variants:** `3 accounts:` `metadata, owner, token`

### `DeprecatedSetReservationList`
- **Discriminator:** `0x05`
- **Account variants:** `3 accounts:` `master_edition, reservation_list, resource`

### `DeprecatedCreateReservationList`
- **Discriminator:** `0x06`
- **Account variants:** `8 accounts:` `reservation_list, payer, update_authority, master_edition, resource, metadata, system_program, rent`

### `SignMetadata`
- **Discriminator:** `0x07`
- **Account variants:** `2 accounts:` `metadata, creator`

### `DeprecatedMintPrintingTokensViaToken`
- **Discriminator:** `0x08`
- **Account variants:** `8 accounts:` `destination, token, one_time_printing_authorization_mint, printing_mint, burn_authority, metadata, master_edition, token_program, rent`

### `DeprecatedMintPrintingTokens`
- **Discriminator:** `0x09`
- **Account variants:** `7 accounts:` `destination, printing_mint, update_authority, metadata, master_edition, token_program, rent`

### `CreateMasterEdition`
- **Discriminator:** `0x0a`
- **Account variants:** `9 accounts:` `edition, mint, update_authority, mint_authority, payer, metadata, token_program, system_program, rent`

### `MintNewEditionFromMasterEditionViaToken`
- **Discriminator:** `0x0b`
- **Args:** `MintNewEditionFromMasterEditionViaTokenArgs`
- **Account variants:** `13 accounts + optional rent:` `new_metadata, new_edition, master_edition, new_mint, edition_mark_pda, new_mint_authority, payer, token_account_owner, token_account, new_metadata_update_authority, metadata, token_program, system_program, rent?`
- **Optional accounts:** `rent`

### `ConvertMasterEditionV1ToV2`
- **Discriminator:** `0x0c`
- **Account variants:** `3 accounts:` `master_edition, one_time_auth, printing_mint`

### `MintNewEditionFromMasterEditionViaVaultProxy`
- **Discriminator:** `0x0d`
- **Args:** `MintNewEditionFromMasterEditionViaTokenArgs`
- **Account variants:** `16 accounts + optional rent:` `new_metadata, new_edition, master_edition, new_mint, edition_mark_pda, new_mint_authority, payer, vault_authority, safety_deposit_store, safety_deposit_box, vault, new_metadata_update_authority, metadata, token_program, token_vault_program, system_program, rent?`
- **Optional accounts:** `rent`

### `PuffMetadata`
- **Discriminator:** `0x0e`
- **Account variants:** `1 account:` `metadata`

### `UpdateMetadataAccountV2`
- **Discriminator:** `0x0f`
- **Args:** `UpdateMetadataAccountArgsV2`
- **Account variants:** `2 accounts:` `metadata, update_authority`

### `CreateMetadataAccountV2`
- **Discriminator:** `0x10`
- **Account variants:** `6 accounts + optional rent:` `metadata, mint, mint_authority, payer, update_authority, system_program, rent?`
- **Optional accounts:** `rent`

### `CreateMasterEditionV3`
- **Discriminator:** `0x11`
- **Args:** `create_master_edition_args: CreateMasterEditionArgs`
- **Account variants:** `8 accounts + optional rent:` `edition, mint, update_authority, mint_authority, payer, metadata, token_program, system_program, rent?`
- **Optional accounts:** `rent`

### `VerifyCollection`
- **Discriminator:** `0x12`
- **Account variants:** `7 accounts:` `metadata, collection_authority, payer, collection_mint, collection, collection_master_edition_account, collection_authority_record?`
- **Optional accounts:** `collection_authority_record`

### `Utilize`
- **Discriminator:** `0x13`
- **Args:** `utilize_args: UtilizeArgs`
- **Account variants:** `9 accounts + optional use_authority_record, burner:` `metadata, token_account, mint, use_authority, owner, token_program, ata_program, system_program, rent, use_authority_record?, burner?`
- **Optional accounts:** `use_authority_record`, `burner`

### `ApproveUseAuthority`
- **Discriminator:** `0x14`
- **Args:** `approve_use_authority_args: ApproveUseAuthorityArgs`
- **Account variants:** `10 accounts + optional rent:` `use_authority_record, owner, payer, user, owner_token_account, metadata, mint, burner, token_program, system_program, rent?`
- **Optional accounts:** `rent`

### `RevokeUseAuthority`
- **Discriminator:** `0x15`
- **Account variants:** `8 accounts + optional rent:` `use_authority_record, owner, user, owner_token_account, mint, metadata, token_program, system_program, rent?`
- **Optional accounts:** `rent`

### `UnverifyCollection`
- **Discriminator:** `0x16`
- **Account variants:** `5 accounts + optional collection_authority_record:` `metadata, collection_authority, collection_mint, collection, collection_master_edition_account, collection_authority_record?`
- **Optional accounts:** `collection_authority_record`

### `ApproveCollectionAuthority`
- **Discriminator:** `0x17`
- **Account variants:** `7 accounts + optional rent:` `collection_authority_record, new_collection_authority, update_authority, payer, metadata, mint, system_program, rent?`
- **Optional accounts:** `rent`

### `RevokeCollectionAuthority`
- **Discriminator:** `0x18`
- **Account variants:** `5 accounts:` `collection_authority_record, delegate_authority, revoke_authority, metadata, mint`

### `SetAndVerifyCollection`
- **Discriminator:** `0x19`
- **Account variants:** `7 accounts + optional collection_authority_record:` `metadata, collection_authority, payer, update_authority, collection_mint, collection, collection_master_edition_account, collection_authority_record?`
- **Optional accounts:** `collection_authority_record`

### `FreezeDelegatedAccount`
- **Discriminator:** `0x1a`
- **Account variants:** `5 accounts:` `delegate, token_account, edition, mint, token_program`

### `ThawDelegatedAccount`
- **Discriminator:** `0x1b`
- **Account variants:** `5 accounts:` `delegate, token_account, edition, mint, token_program`

### `RemoveCreatorVerification`
- **Discriminator:** `0x1c`
- **Account variants:** `2 accounts:` `metadata, creator`

### `BurnNft`
- **Discriminator:** `0x1d`
- **Account variants:** `6 accounts + optional collection_metadata:` `metadata, owner, mint, token_account, master_edition_account, spl_token_program, collection_metadata?`
- **Optional accounts:** `collection_metadata`

### `VerifySizedCollectionItem`
- **Discriminator:** `0x1e`
- **Account variants:** `7 accounts + optional collection_authority_record:` `metadata, collection_authority, payer, collection_mint, collection, collection_master_edition_account, collection_authority_record?`
- **Optional accounts:** `collection_authority_record`

### `UnverifySizedCollectionItem`
- **Discriminator:** `0x1f`
- **Account variants:** `7 accounts + optional collection_authority_record:` `metadata, collection_authority, payer, collection_mint, collection, collection_master_edition_account, collection_authority_record?`
- **Optional accounts:** `collection_authority_record`

### `SetAndVerifySizedCollectionItem`
- **Discriminator:** `0x20`
- **Account variants:** same as `SetAndVerifyCollection`

### `CreateMetadataAccountV3`
- **Discriminator:** `0x21`
- **Account variants:** `6 accounts + optional rent:` `metadata, mint, mint_authority, payer, update_authority, system_program, rent?`
- **Optional accounts:** `rent`

### `SetCollectionSize`
- **Discriminator:** `0x22`
- **Args:** `set_collection_size_args: SetCollectionSizeArgs`
- **Account variants:** `3 accounts + optional collection_authority_record:` `collection_metadata, collection_authority, collection_mint, collection_authority_record?`
- **Optional accounts:** `collection_authority_record`

### `SetTokenStandard`
- **Discriminator:** `0x23`
- **Account variants:** `3 accounts + optional edition:` `metadata, update_authority, mint, edition?`
- **Optional accounts:** `edition`

### `BubblegumSetCollectionSize`
- **Discriminator:** `0x24`
- **Args:** `set_collection_size_args: SetCollectionSizeArgs`
- **Account variants:** `4 accounts + optional collection_authority_record:` `collection_metadata, collection_authority, collection_mint, bubblegum_signer, collection_authority_record?`
- **Optional accounts:** `collection_authority_record`

### `BurnEditionNft`
- **Discriminator:** `0x25`
- **Account variants:** `10 accounts:` `metadata, owner, print_edition_mint, master_edition_mint, print_edition_token_account, master_edition_token_account, master_edition_account, print_edition_account, edition_marker_account, spl_token_program`

### `CreateEscrowAccount`
- **Discriminator:** `0x26`
- **Account variants:** `8 accounts + optional authority:` `escrow, metadata, mint, token_account, edition, payer, system_program, sysvar_instructions, authority?`
- **Optional accounts:** `authority`

### `CloseEscrowAccount`
- **Discriminator:** `0x27`
- **Account variants:** `8 accounts:` `escrow, metadata, mint, token_account, edition, payer, system_program, sysvar_instructions`

### `TransferOutOfEscrow`
- **Discriminator:** `0x28`
- **Args:** `transfer_out_of_escrow_args: TransferOutOfEscrowArgs`
- **Account variants:** `12 accounts + optional authority:` `escrow, metadata, payer, attribute_mint, attribute_src, attribute_dst, escrow_mint, escrow_account, system_program, ata_program, token_program, sysvar_instructions, authority?`
- **Optional accounts:** `authority`

### `Burn`
- **Discriminator:** `0x29`
- **Args:** `burn_args: BurnArgs`
- **Account variants:**
  - `authority, collection_metadata?, metadata, edition?, mint, token, master_edition?, master_edition_mint?, master_edition_token?, edition_marker?, token_record?, system_program, sysvar_instructions, spl_token_program`
- **Optional accounts:** `collection_metadata`, `edition`, `master_edition`, `master_edition_mint`, `master_edition_token`, `edition_marker`, `token_record`

### `Create`
- **Discriminator:** `0x2a`
- **Args:** `create_args: CreateArgs`
- **Account variants:**
  - `metadata, master_edition?, mint, authority, payer, update_authority, system_program, sysvar_instructions, spl_token_program?`
- **Optional accounts:** `master_edition`, `spl_token_program`

### `Mint`
- **Discriminator:** `0x2b`
- **Args:** `mint_args: MintArgs`
- **Account variants:**
  - `token, token_owner?, metadata, master_edition?, token_record?, mint, authority, delegate_record?, payer, system_program, sysvar_instructions, spl_token_program, spl_ata_program, authorization_rules_program?, authorization_rules?`
- **Optional accounts:** `token_owner`, `master_edition`, `token_record`, `delegate_record`, `authorization_rules_program`, `authorization_rules`

### `Delegate`
- **Discriminator:** `0x2c`
- **Args:** `delegate_args: DelegateArgs`
- **Account variants:**
  - `delegate_record?, delegate, metadata, master_edition?, token_record?, mint, token?, authority, payer, system_program, sysvar_instructions, spl_token_program?, authorization_rules_program?, authorization_rules?`
- **Optional accounts:** `delegate_record`, `master_edition`, `token_record`, `token`, `spl_token_program`, `authorization_rules_program`, `authorization_rules`

### `Revoke`
- **Discriminator:** `0x2d`
- **Args:** `revoke_args: RevokeArgs`
- **Account variants:** same shape as `Delegate` (with `revoke_args`)
- **Optional accounts:** same as `Delegate`

### `Lock`
- **Discriminator:** `0x2e`
- **Args:** `lock_args: LockArgs`
- **Account variants:**
  - `authority, token_owner?, token, mint, metadata, edition?, token_record?, payer, system_program, sysvar_instructions, spl_token_program?, authorization_rules_program?, authorization_rules?`
- **Optional accounts:** `token_owner`, `edition`, `token_record`, `spl_token_program`, `authorization_rules_program`, `authorization_rules`

### `Unlock`
- **Discriminator:** `0x2f`
- **Args:** `unlock_args: UnlockArgs`
- **Account variants:** same shape as `Lock`
- **Optional accounts:** same as `Lock`

### `Migrate`
- **Discriminator:** `0x30`
- **Account variants:**
  - `metadata, edition, token, token_owner, mint, payer, authority, collection_metadata, delegate_record, token_record, system_program, sysvar_instructions, spl_token_program, authorization_rules_program?, authorization_rules?`
- **Optional accounts:** `authorization_rules_program`, `authorization_rules`

### `Transfer`
- **Discriminator:** `0x31`
- **Args:** `transfer_args: TransferArgs`
- **Account variants:**
  - `token, token_owner, destination, destination_owner, mint, metadata, edition?, owner_token_record?, destination_token_record?, authority, payer, system_program, sysvar_instructions, spl_token_program, spl_ata_program, authorization_rules_program?, authorization_rules?`
- **Optional accounts:** `edition`, `owner_token_record`, `destination_token_record`, `authorization_rules_program`, `authorization_rules`

### `Update`
- **Discriminator:** `0x32`
- **Args:** `update_args: UpdateArgs`
- **Account variants:**
  - `authority, delegate_record?, token?, mint, metadata, edition?, payer, system_program, sysvar_instructions, authorization_rules_program?, authorization_rules?`
- **Optional accounts:** `delegate_record`, `token`, `edition`, `authorization_rules_program`, `authorization_rules`

### `Use`
- **Discriminator:** `0x33`
- **Args:** `use_args: UseArgs`
- **Account variants:**
  - `authority, delegate_record?, token?, mint, metadata, edition?, payer, system_program, sysvar_instructions, spl_token_program?, authorization_rules_program?, authorization_rules?`
- **Optional accounts:** `delegate_record`, `token`, `edition`, `spl_token_program`, `authorization_rules_program`, `authorization_rules`

### `Verify`
- **Discriminator:** `0x34`
- **Args:** `verification_args: VerificationArgs`
- **Account variants:**
  - `authority, delegate_record?, metadata, collection_mint?, collection_metadata?, collection_master_edition?, system_program, sysvar_instructions`
- **Optional accounts:** `delegate_record`, `collection_mint`, `collection_metadata`, `collection_master_edition`

### `Unverify`
- **Discriminator:** `0x35`
- **Args:** `verification_args: VerificationArgs`
- **Account variants:**
  - `authority, delegate_record?, metadata, collection_mint?, collection_metadata?, system_program, sysvar_instructions`
- **Optional accounts:** `delegate_record`, `collection_mint`, `collection_metadata`

### `Collect`
- **Discriminator:** `0x36`
- **Account variants:** `2 accounts:` `authority, recipient`

### `Print`
- **Discriminator:** `0x37`
- **Args:** `print_args: PrintArgs`
- **Account variants:**
  - `edition_metadata, edition, edition_mint, edition_token_account_owner, edition_token_account, edition_mint_authority, edition_token_record?, master_edition, edition_marker_pda, payer, master_token_account_owner, master_token_account, master_metadata, update_authority, spl_token_program, spl_ata_program, sysvar_instructions, system_program`
- **Optional accounts:** `edition_token_record`

### `Resize`
- **Discriminator:** `0x38`
- **Account variants:**
  - `metadata, edition, mint, payer, authority?, token?, system_program`
- **Optional accounts:** `authority`, `token`

### `CloseAccounts`
- **Discriminator:** `0x39`
- **Account variants:** `5 accounts:` `metadata, edition, mint, authority, destination`

## Shared types

### `Key` (enum)
- `Uninitialized | EditionV1 | MasterEditionV1 | ReservationListV1 | MetadataV1 | ReservationListV2 | MasterEditionV2 | EditionMarker | UseAuthorityRecord | CollectionAuthorityRecord | TokenOwnedEscrow | TokenRecord | MetadataDelegate | EditionMarkerV2 | HolderDelegate`

### `Data`
- `name`: `String`
- `symbol`: `String`
- `uri`: `String`
- `seller_fee_basis_points`: `u16`
- `creators`: `Option<Vec<Creator>>`

### `DataV2`
- `name`, `symbol`, `uri`, `seller_fee_basis_points`, `creators`, `collection: Option<Collection>`, `uses: Option<Uses>`

### `AssetData`
- `name`, `symbol`, `uri`, `seller_fee_basis_points`, `creators: Option<Vec<Creator>>`, `primary_sale_happened: bool`, `is_mutable: bool`, `token_standard: TokenStandard`, `collection: Option<Collection>`, `uses: Option<Uses>`, `collection_details: Option<CollectionDetails>`, `rule_set: Option<Pubkey>`

### `Creator`
- `address`: `Pubkey`
- `verified`: `bool`
- `share`: `u8`

### `Collection`
- `verified`: `bool`
- `key`: `Pubkey`

### `CollectionDetails` (enum)
- `V1 { size: u64 } | V2 { padding: [u8; 8] }`

### `CollectionToggle` (enum)
- `None | Clear | Set(Collection)`

### `CollectionDetailsToggle` (enum)
- `None | Clear | Set(CollectionDetails)`

### `Uses`
- `use_method`: `UseMethod`
- `remaining`: `u64`
- `total`: `u64`

### `UseMethod` (enum)
- `Burn | Multiple | Single`

### `UsesToggle` (enum)
- `None | Clear | Set(Uses)`

### `RuleSetToggle` (enum)
- `None | Clear | Set(Pubkey)`

### `ProgrammableConfig` (enum)
- `V1 { rule_set: Option<Pubkey> }`

### `TokenStandard` (enum)
- `NonFungible | FungibleAsset | Fungible | NonFungibleEdition | ProgrammableNonFungible | ProgrammableNonFungibleEdition`

### `TokenState` (enum)
- `Unlocked | Locked | Listed`

### `TokenDelegateRole` (enum)
- `Sale | Transfer | Utility | Staking | Standard | LockedTransfer | Migration`

### `MetadataDelegateRole` (enum)
- `AuthorityItem | Collection | Use | Data | ProgrammableConfig | DataItem | CollectionItem | ProgrammableConfigItem`

### `HolderDelegateRole` (enum)
- `PrintDelegate`

### `AuthorityType` (enum)
- `None | Metadata | Holder | MetadataDelegate | TokenDelegate`

### `EscrowAuthority` (enum)
- `TokenOwner | Creator(Pubkey)`

### `MigrationType` (enum)
- `CollectionV1 | ProgrammableV1`

### `PrintSupply` (enum)
- `Zero | Limited(u64) | Unlimited`

### `Reservation`
- `address`: `Pubkey`
- `spots_remaining`: `u64`
- `total_spots`: `u64`

### `ReservationV1`
- `address`: `Pubkey`
- `spots_remaining`: `u8`
- `total_spots`: `u8`

### `Payload`
- `map`: `HashMap<String, PayloadType>`

### `PayloadKey` (enum)
- `Amount | Authority | AuthoritySeeds | Delegate | DelegateSeeds | Destination | DestinationSeeds | Holder | Source | SourceSeeds`

### `PayloadType` (enum)
- `Pubkey(Pubkey) | Seeds(SeedsVec) | MerkleProof(ProofInfo) | Number(u64)`

### `SeedsVec`
- `seeds`: `Vec<Vec<u8>>`

### `ProofInfo`
- `proof`: `Vec<[u8; 32]>`

### `AuthorizationData`
- `payload`: `Payload`

### Args structs / enums (instruction payloads)
- `ApproveUseAuthorityArgs { number_of_uses: u64 }`
- `BurnArgs { V1 { amount: u64 } }`
- `CreateArgs { V1 { asset_data: AssetData, decimals: Option<u8>, print_supply: Option<PrintSupply> } }`
- `CreateMasterEditionArgs { max_supply: Option<u64> }`
- `CreateMetadataAccountArgsV3 { data: DataV2, is_mutable: bool, collection_details: Option<CollectionDetails> }`
- `DelegateArgs` enum: `CollectionV1, SaleV1 { amount }, TransferV1 { amount }, DataV1, UtilityV1 { amount }, StakingV1 { amount }, StandardV1 { amount }`, etc. — each variant carries optional `authorization_data: Option<AuthorizationData>`.
- `RevokeArgs` enum: `CollectionV1 | SaleV1 | TransferV1 | DataV1 | UtilityV1 | StakingV1 | StandardV1 | LockedTransferV1 | ProgrammableConfigV1 | MigrationV1 | AuthorityItemV1 | DataItemV1 | CollectionItemV1 | ProgrammableConfigItemV1 | PrintDelegateV1`
- `LockArgs / UnlockArgs / UseArgs { V1 { authorization_data } }`
- `MintArgs { V1 { amount: u64, authorization_data: Option<AuthorizationData> } }`
- `MintNewEditionFromMasterEditionViaTokenArgs { edition: u64 }`
- `PrintArgs { V1 { edition: u64 } | V2 { edition: u64 } }`
- `SetCollectionSizeArgs { size: u64 }`
- `TransferArgs { V1 { amount: u64, authorization_data: Option<AuthorizationData> } }`
- `TransferOutOfEscrowArgs { amount: u64 }`
- `UpdateArgs` enum: `V1 { ... }` and `AsUpdateAuthorityV2 { ... }` with fields `new_update_authority, data, primary_sale_happened, is_mutable, collection: CollectionToggle, collection_details: CollectionDetailsToggle, uses: UsesToggle, rule_set: RuleSetToggle, authorization_data` (V2 also includes `token_standard: Option<TokenStandard>`)
- `UpdateMetadataAccountArgsV2 { data: Option<DataV2>, update_authority: Option<Pubkey>, primary_sale_happened: Option<bool>, is_mutable: Option<bool> }`
- `UtilizeArgs { number_of_uses: u64 }`
- `VerificationArgs { CreatorV1 | CollectionV1 }`
