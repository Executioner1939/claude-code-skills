# SPL Token-2022

- **Crate:** `carbon-token-2022-decoder`
- **Program ID:** `TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb`
- **Decoder struct:** `Token2022Decoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** no
- **Discriminator style:** mixed (raw byte for base SPL ops; nested `[outer, inner]` for extensions; anchor 8-byte for token-metadata / token-group)

## Account types

Decoded via `spl_token_2022::extension::StateWithExtensions::unpack`:

### `Mint`
- `mint_authority`: `Option<Pubkey>`
- `supply`: `u64`
- `decimals`: `u8`
- `is_initialized`: `bool`
- `freeze_authority`: `Option<Pubkey>`
- `extensions`: `Option<Vec<Extension>>`

### `Token`
- `mint`: `Pubkey`
- `owner`: `Pubkey`
- `amount`: `u64`
- `delegate`: `Option<Pubkey>`
- `state`: `AccountState`
- `is_native`: `Option<u64>`
- `delegated_amount`: `u64`
- `close_authority`: `Option<Pubkey>`
- `extensions`: `Option<Vec<Extension>>`

### `Multisig`
- `m`: `u8`
- `n`: `u8`
- `is_initialized`: `bool`
- `signers`: `[Pubkey; 11]`

## Instructions

### Base SPL Token operations (single-byte discriminator)

### `InitializeMint`
- **Discriminator:** `[0]`
- **Args:** `decimals: u8`, `mint_authority: Pubkey`, `freeze_authority: Option<Pubkey>`
- **Account variants:** `2 accounts: mint, rent`
- **Remaining accounts:** yes

### `InitializeAccount`
- **Discriminator:** `[1]`
- **Args:** (none)
- **Account variants:** `4 accounts: account, mint, owner, rent`
- **Remaining accounts:** yes

### `InitializeMultisig`
- **Discriminator:** `[2]`
- **Args:** `m: u8`
- **Account variants:** `2 accounts: multisig, rent`
- **Remaining accounts:** yes

### `Transfer`
- **Discriminator:** `[3]`
- **Args:** `amount: u64`
- **Account variants:** `3 accounts: source, destination, authority`
- **Remaining accounts:** yes

### `Approve`
- **Discriminator:** `[4]`
- **Args:** `amount: u64`
- **Account variants:** `3 accounts: source, delegate, owner`
- **Remaining accounts:** yes

### `Revoke`
- **Discriminator:** `[5]`
- **Args:** (none)
- **Account variants:** `2 accounts: source, owner`
- **Remaining accounts:** yes

### `SetAuthority`
- **Discriminator:** `[6]`
- **Args:** `authority_type: AuthorityType`, `new_authority: Option<Pubkey>`
- **Account variants:** `2 accounts: owned, owner`
- **Remaining accounts:** yes

### `MintTo`
- **Discriminator:** `[7]`
- **Args:** `amount: u64`
- **Account variants:** `3 accounts: mint, token, mint_authority`
- **Remaining accounts:** yes

### `Burn`
- **Discriminator:** `[8]`
- **Args:** `amount: u64`
- **Account variants:** `3 accounts: account, mint, authority`
- **Remaining accounts:** yes

### `CloseAccount`
- **Discriminator:** `[9]`
- **Args:** (none)
- **Account variants:** `3 accounts: account, destination, owner`
- **Remaining accounts:** yes

### `FreezeAccount`
- **Discriminator:** `[10]`
- **Args:** (none)
- **Account variants:** `3 accounts: account, mint, owner`
- **Remaining accounts:** yes

### `ThawAccount`
- **Discriminator:** `[11]`
- **Args:** (none)
- **Account variants:** `3 accounts: account, mint, owner`
- **Remaining accounts:** yes

### `TransferChecked`
- **Discriminator:** `[12]`
- **Args:** `amount: u64`, `decimals: u8`
- **Account variants:** `4 accounts: source, mint, destination, authority`
- **Remaining accounts:** yes

### `ApproveChecked`
- **Discriminator:** `[13]`
- **Args:** `amount: u64`, `decimals: u8`
- **Account variants:** `4 accounts: source, mint, delegate, owner`
- **Remaining accounts:** yes

### `MintToChecked`
- **Discriminator:** `[14]`
- **Args:** `amount: u64`, `decimals: u8`
- **Account variants:** `3 accounts: mint, token, mint_authority`
- **Remaining accounts:** yes

### `BurnChecked`
- **Discriminator:** `[15]`
- **Args:** `amount: u64`, `decimals: u8`
- **Account variants:** `3 accounts: account, mint, authority`
- **Remaining accounts:** yes

### `InitializeAccount2`
- **Discriminator:** `[16]`
- **Args:** `owner: Pubkey`
- **Account variants:** `3 accounts: account, mint, rent`
- **Remaining accounts:** yes

### `SyncNative`
- **Discriminator:** `[17]`
- **Args:** (none)
- **Account variants:** `1 accounts: account`
- **Remaining accounts:** yes

### `InitializeAccount3`
- **Discriminator:** `[18]`
- **Args:** `owner: Pubkey`
- **Account variants:** `2 accounts: account, mint`
- **Remaining accounts:** yes

### `InitializeMultisig2`
- **Discriminator:** `[19]`
- **Args:** `m: u8`
- **Account variants:** `1 accounts: multisig`
- **Remaining accounts:** yes

### `InitializeMint2`
- **Discriminator:** `[20]`
- **Args:** `decimals: u8`, `mint_authority: Pubkey`, `freeze_authority: Option<Pubkey>`
- **Account variants:** `1 accounts: mint`
- **Remaining accounts:** yes

### `GetAccountDataSize`
- **Discriminator:** `[21]`
- **Args:** (none)
- **Account variants:** `1 accounts: mint`
- **Remaining accounts:** yes

### `InitializeImmutableOwner`
- **Discriminator:** `[22]`
- **Args:** (none)
- **Account variants:** `1 accounts: account`
- **Remaining accounts:** yes

### `AmountToUiAmount`
- **Discriminator:** `[23]`
- **Args:** `amount: u64`
- **Account variants:** `1 accounts: mint`
- **Remaining accounts:** yes

### `UiAmountToAmount`
- **Discriminator:** `[24]`
- **Args:** `ui_amount: String`
- **Account variants:** `1 accounts: mint`
- **Remaining accounts:** yes

### `InitializeMintCloseAuthority`
- **Discriminator:** `[25]`
- **Args:** `close_authority: Option<Pubkey>`
- **Account variants:** `1 accounts: mint`
- **Remaining accounts:** yes

### Transfer-fee extension (outer `26`)

### `InitializeTransferFeeConfig` (`[26, 0]`)
- **Args:** `transfer_fee_config_authority: Option<Pubkey>`, `withdraw_withheld_authority: Option<Pubkey>`, `transfer_fee_basis_points: u16`, `maximum_fee: u64`
- **Account variants:** `1 accounts: mint`

### `TransferCheckedWithFee` (`[26, 1]`)
- **Args:** `amount: u64`, `decimals: u8`, `fee: u64`
- **Account variants:** `4 accounts: source, mint, destination, authority`

### `WithdrawWithheldTokensFromMint` (`[26, 2]`)
- **Account variants:** `3 accounts: mint, fee_receiver, withdraw_withheld_authority`

### `WithdrawWithheldTokensFromAccounts` (`[26, 3]`)
- **Args:** `num_token_accounts: u8`
- **Account variants:** `3 accounts: mint, fee_receiver, withdraw_withheld_authority`

### `HarvestWithheldTokensToMint` (`[26, 4]`)
- **Account variants:** `1 accounts: mint`

### `SetTransferFee` (`[26, 5]`)
- **Args:** `transfer_fee_basis_points: u16`, `maximum_fee: u64`
- **Account variants:** `2 accounts: mint, transfer_fee_config_authority`

### Confidential-transfer extension (outer `27`)

### `InitializeConfidentialTransferMint` (`[27, 0]`)
- **Args:** `authority: Option<Pubkey>`, `auto_approve_new_accounts: bool`, `auditor_elgamal_pubkey: Option<Pubkey>`
- **Account variants:** `1 accounts: mint`

### `UpdateConfidentialTransferMint` (`[27, 1]`)
- **Args:** `auto_approve_new_accounts: bool`, `auditor_elgamal_pubkey: Option<Pubkey>`
- **Account variants:** `2 accounts: mint, authority`

### `ConfigureConfidentialTransferAccount` (`[27, 2]`)
- **Args:** `decryptable_zero_balance: DecryptableBalance`, `maximum_pending_balance_credit_counter: u64`, `proof_instruction_offset: i8`
- **Account variants:** `5 accounts: token, mint, instructions_sysvar_or_context_state, record, authority`
- **Optional accounts:** `record: Option<Pubkey>`

### `ApproveConfidentialTransferAccount` (`[27, 3]`)
- **Account variants:** `3 accounts: token, mint, authority`

### `EmptyConfidentialTransferAccount` (`[27, 4]`)
- **Args:** `proof_instruction_offset: i8`
- **Account variants:** `4 accounts: token, instructions_sysvar_or_context_state, record, authority`
- **Optional accounts:** `record`

### `ConfidentialDeposit` (`[27, 5]`)
- **Args:** `amount: u64`, `decimals: u8`
- **Account variants:** `3 accounts: token, mint, authority`

### `ConfidentialWithdraw` (`[27, 6]`)
- **Args:** `amount: u64`, `decimals: u8`, `new_decryptable_available_balance: DecryptableBalance`, `equality_proof_instruction_offset: i8`, `range_proof_instruction_offset: i8`
- **Account variants:** `6 accounts: token, mint, instructions_sysvar, equality_record, range_record, authority`
- **Optional accounts:** `instructions_sysvar`, `equality_record`, `range_record`

### `ConfidentialTransfer` (`[27, 7]`)
- **Args:** `new_source_decryptable_available_balance: DecryptableBalance`, `equality_proof_instruction_offset: i8`, `ciphertext_validity_proof_instruction_offset: i8`, `range_proof_instruction_offset: i8`
- **Account variants:** `8 accounts: source_token, mint, destination_token, instructions_sysvar, equality_record, ciphertext_validity_record, range_record, authority`
- **Optional accounts:** `instructions_sysvar`, `equality_record`, `ciphertext_validity_record`, `range_record`

### `ApplyConfidentialPendingBalance` (`[27, 8]`)
- **Args:** `expected_pending_balance_credit_counter: u64`, `new_decryptable_available_balance: DecryptableBalance`
- **Account variants:** `2 accounts: token, authority`

### `EnableConfidentialCredits` (`[27, 9]`)
- **Account variants:** `2 accounts: token, authority`

### `DisableConfidentialCredits` (`[27, 10]`)
- **Account variants:** `2 accounts: token, authority`

### `EnableNonConfidentialCredits` (`[27, 11]`)
- **Account variants:** `2 accounts: token, authority`

### `DisableNonConfidentialCredits` (`[27, 12]`)
- **Account variants:** `2 accounts: token, authority`

### `ConfidentialTransferWithFee` (`[27, 13]`)
- **Args:** `new_source_decryptable_available_balance: DecryptableBalance`, plus 5 proof offsets (`equality`, `transfer_amount_ciphertext_validity`, `fee_sigma`, `fee_ciphertext_validity`, `range`)
- **Account variants:** `10 accounts: source_token, mint, destination_token, instructions_sysvar, equality_record, transfer_amount_ciphertext_validity_record, fee_sigma_record, fee_ciphertext_validity_record, range_record, authority`
- **Optional accounts:** `instructions_sysvar`, `equality_record`, `transfer_amount_ciphertext_validity_record`, `fee_sigma_record`, `fee_ciphertext_validity_record`, `range_record`

### Default-account-state extension (outer `28`)

### `InitializeDefaultAccountState` (`[28, 0]`)
- **Args:** `state: AccountState`
- **Account variants:** `1 accounts: mint`

### `UpdateDefaultAccountState` (`[28, 1]`)
- **Args:** `state: AccountState`
- **Account variants:** `2 accounts: mint, freeze_authority`

### Reallocate (single byte)

### `Reallocate`
- **Discriminator:** `[29]`
- **Args:** `new_extension_types: Vec<ExtensionType>`
- **Account variants:** `4 accounts: token, payer, system_program, owner`

### Memo-transfers extension (outer `30`)

### `EnableMemoTransfers` (`[30, 0]`)
- **Account variants:** `2 accounts: token, owner`

### `DisableMemoTransfers` (`[30, 1]`)
- **Account variants:** `2 accounts: token, owner`

### Single-byte misc

### `CreateNativeMint`
- **Discriminator:** `[31]`
- **Account variants:** `3 accounts: payer, native_mint, system_program`

### `InitializeNonTransferableMint`
- **Discriminator:** `[32]`
- **Account variants:** `1 accounts: mint`

### Interest-bearing-mint extension (outer `33`)

### `InitializeInterestBearingMint` (`[33, 0]`)
- **Args:** `rate_authority: Option<Pubkey>`, `rate: i16`
- **Account variants:** `1 accounts: mint`

### `UpdateRateInterestBearingMint` (`[33, 1]`)
- **Args:** `rate: i16`
- **Account variants:** `2 accounts: mint, rate_authority`

### CPI guard extension (outer `34`)

### `EnableCpiGuard` (`[34, 0]`)
- **Account variants:** `2 accounts: token, owner`

### `DisableCpiGuard` (`[34, 1]`)
- **Account variants:** `2 accounts: token, owner`

### Single-byte

### `InitializePermanentDelegate`
- **Discriminator:** `[35]`
- **Args:** `delegate: Pubkey`
- **Account variants:** `1 accounts: mint`

### Transfer-hook extension (outer `36`)

### `InitializeTransferHook` (`[36, 0]`)
- **Args:** `authority: Option<Pubkey>`, `program_id: Option<Pubkey>`
- **Account variants:** `1 accounts: mint`

### `UpdateTransferHook` (`[36, 1]`)
- **Args:** `program_id: Option<Pubkey>`
- **Account variants:** `2 accounts: mint, authority`

### Confidential-transfer-fee extension (outer `37`)

### `InitializeConfidentialTransferFee` (`[37, 0]`)
- **Args:** `authority: Option<Pubkey>`, `withdraw_withheld_authority_el_gamal_pubkey: Option<Pubkey>`
- **Account variants:** `1 accounts: mint`

### `WithdrawWithheldTokensFromMintForConfidentialTransferFee` (`[37, 1]`)
- **Args:** `proof_instruction_offset: i8`, `new_decryptable_available_balance: DecryptableBalance`
- **Account variants:** `5 accounts: mint, destination, instructions_sysvar_or_context_state, record, authority`
- **Optional accounts:** `record`

### `WithdrawWithheldTokensFromAccountsForConfidentialTransferFee` (`[37, 2]`)
- **Args:** `num_token_accounts: u8`, `proof_instruction_offset: i8`, `new_decryptable_available_balance: DecryptableBalance`
- **Account variants:** `5 accounts: mint, destination, instructions_sysvar_or_context_state, record, authority`
- **Optional accounts:** `record`

### `HarvestWithheldTokensToMintForConfidentialTransferFee` (`[37, 3]`)
- **Account variants:** `1 accounts: mint`

### `EnableHarvestToMint` (`[37, 4]`)
- **Account variants:** `2 accounts: mint, authority`

### `DisableHarvestToMint` (`[37, 5]`)
- **Account variants:** `2 accounts: mint, authority`

### Single-byte

### `WithdrawExcessLamports`
- **Discriminator:** `[38]`
- **Account variants:** `3 accounts: source_account, destination_account, authority`

### Metadata-pointer extension (outer `39`)

### `InitializeMetadataPointer` (`[39, 0]`)
- **Args:** `authority: Option<Pubkey>`, `metadata_address: Option<Pubkey>`
- **Account variants:** `1 accounts: mint`

### `UpdateMetadataPointer` (`[39, 1]`)
- **Args:** `metadata_address: Option<Pubkey>`
- **Account variants:** `2 accounts: mint, metadata_pointer_authority`

### Group-pointer extension (outer `40`)

### `InitializeGroupPointer` (`[40, 0]`)
- **Args:** `authority: Option<Pubkey>`, `group_address: Option<Pubkey>`
- **Account variants:** `1 accounts: mint`

### `UpdateGroupPointer` (`[40, 1]`)
- **Args:** `group_address: Option<Pubkey>`
- **Account variants:** `2 accounts: mint, group_pointer_authority`

### Group-member-pointer extension (outer `41`)

### `InitializeGroupMemberPointer` (`[41, 0]`)
- **Args:** `authority: Option<Pubkey>`, `member_address: Option<Pubkey>`
- **Account variants:** `1 accounts: mint`

### `UpdateGroupMemberPointer` (`[41, 1]`)
- **Args:** `member_address: Option<Pubkey>`
- **Account variants:** `2 accounts: mint, group_member_pointer_authority`

### Scaled UI amount extension (outer `43`)

### `InitializeScaledUiAmountMint` (`[43, 0]`)
- **Args:** `authority: Option<Pubkey>`, `multiplier: f64`
- **Account variants:** `1 accounts: mint`

### `UpdateMultiplierScaledUiMint` (`[43, 1]`)
- **Args:** `multiplier: f64`, `effective_timestamp: i64`
- **Account variants:** `2 accounts: mint, authority`

### Pausable extension (outer `44`)

### `InitializePausableConfig` (`[44, 0]`)
- **Args:** `authority: Option<Pubkey>`
- **Account variants:** `1 accounts: mint`

### `Pause` (`[44, 1]`)
- **Account variants:** `2 accounts: mint, authority`

### `Resume` (`[44, 2]`)
- **Account variants:** `2 accounts: mint, authority`

### Anchor 8-byte discriminators (token-metadata / token-group)

### `InitializeTokenMetadata`
- **Discriminator:** `[210, 225, 30, 162, 88, 184, 77, 141]`
- **Args:** `name: String`, `symbol: String`, `uri: String`
- **Account variants:** `4 accounts: metadata, update_authority, mint, mint_authority`

### `UpdateTokenMetadataField`
- **Discriminator:** `[221, 233, 49, 45, 181, 202, 220, 200]`
- **Args:** `field: TokenMetadataField`, `value: String`
- **Account variants:** `2 accounts: metadata, update_authority`

### `RemoveTokenMetadataKey`
- **Discriminator:** `[234, 18, 32, 56, 89, 141, 37, 181]`
- **Args:** `idempotent: bool`, `key: String`
- **Account variants:** `2 accounts: metadata, update_authority`

### `UpdateTokenMetadataUpdateAuthority`
- **Discriminator:** `[215, 228, 166, 228, 84, 100, 86, 123]`
- **Args:** `new_update_authority: Option<Pubkey>`
- **Account variants:** `2 accounts: metadata, update_authority`

### `EmitTokenMetadata`
- **Discriminator:** `[250, 166, 180, 250, 13, 12, 184, 70]`
- **Args:** `start: Option<u64>`, `end: Option<u64>`
- **Account variants:** `1 accounts: metadata`

### `InitializeTokenGroup`
- **Discriminator:** `[121, 113, 108, 39, 54, 51, 0, 4]`
- **Args:** `update_authority: Option<Pubkey>`, `max_size: u64`
- **Account variants:** `3 accounts: group, mint, mint_authority`

### `UpdateTokenGroupMaxSize`
- **Discriminator:** `[108, 37, 171, 143, 248, 30, 18, 110]`
- **Args:** `max_size: u64`
- **Account variants:** `2 accounts: group, update_authority`

### `UpdateTokenGroupUpdateAuthority`
- **Discriminator:** `[161, 105, 88, 1, 237, 221, 216, 203]`
- **Args:** `new_update_authority: Option<Pubkey>`
- **Account variants:** `2 accounts: group, update_authority`

### `InitializeTokenGroupMember`
- **Discriminator:** `[152, 32, 222, 176, 223, 237, 116, 134]`
- **Account variants:** `5 accounts: member, member_mint, member_mint_authority, group, group_update_authority`

## Shared types

- `AccountState`: enum
- `AuthorityType`: enum
- `Extension`: tagged enum of extension states (TransferFee, ConfidentialTransfer, ConfidentialTransferFee, MetadataPointer, TokenMetadata, GroupPointer, TokenGroup, GroupMemberPointer, TokenGroupMember, MintCloseAuthority, NonTransferable, ImmutableOwner, MemoTransfer, CpiGuard, DefaultAccountState, InterestBearingMint, PermanentDelegate, TransferHook, ScaledUiAmount, Pausable, ...)
- `ExtensionType`: enum tag for `Extension`
- `DecryptableBalance`, `EncryptedBalance`: opaque cipher types
- `TokenMetadataField`: enum (`Name`, `Symbol`, `Uri`, `Key(String)`)
- `TransferFee`: amount + epoch helper struct
