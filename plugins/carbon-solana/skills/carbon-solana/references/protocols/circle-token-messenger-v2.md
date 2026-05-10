# Circle Token Messenger V2

- **Crate:** `carbon-circle-token-messenger-v2-decoder`
- **Program ID:** `CCTPV2vPZJS2u2BBsUoscuikbYjnpFmbFsvVuJdgUMQe`
- **Decoder struct:** `TokenMessengerMinterV2Decoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in instructions/)
- **Discriminator style:** anchor 8-byte

## Account types

### `DenylistedAccount`
- **Discriminator:** `0xba3ad4ef66839d92`
- **Fields:**
  - `account`: `Pubkey`

### `LocalToken`
- **Discriminator:** `0x9f833aaac15480b6`
- **Fields:**
  - `custody`: `Pubkey`
  - `mint`: `Pubkey`
  - `burn_limit_per_message`: `u64`
  - `messages_sent`: `u64`
  - `messages_received`: `u64`
  - `amount_sent`: `u128`
  - `amount_received`: `u128`
  - `bump`: `u8`
  - `custody_bump`: `u8`

### `MessageTransmitter`
- **Discriminator:** `0x4728b48e13cb23fc`
- **Fields:**
  - `owner`: `Pubkey`
  - `pending_owner`: `Pubkey`
  - `attester_manager`: `Pubkey`
  - `pauser`: `Pubkey`
  - `paused`: `bool`
  - `local_domain`: `u32`
  - `version`: `u32`
  - `signature_threshold`: `u32`
  - `enabled_attesters`: `Vec<Pubkey>`
  - `max_message_body_size`: `u64`

### `RemoteTokenMessenger`
- **Discriminator:** `0x6973ae225fe98afc`
- **Fields:**
  - `domain`: `u32`
  - `token_messenger`: `Pubkey`

### `TokenMessenger`
- **Discriminator:** `0xa204f23493f3dd60`
- **Fields:**
  - `denylister`: `Pubkey`
  - `owner`: `Pubkey`
  - `pending_owner`: `Pubkey`
  - `message_body_version`: `u32`
  - `authority_bump`: `u8`
  - `fee_recipient`: `Pubkey`
  - `min_fee_controller`: `Pubkey`
  - `min_fee`: `u32`

### `TokenMinter`
- **Discriminator:** `0x7a85543f399fabce`
- **Fields:**
  - `token_controller`: `Pubkey`
  - `pauser`: `Pubkey`
  - `paused`: `bool`
  - `bump`: `u8`

### `TokenPair`
- **Discriminator:** `0x11d62db0e595c547`
- **Fields:**
  - `remote_domain`: `u32`
  - `remote_token`: `Pubkey`
  - `local_token`: `Pubkey`
  - `bump`: `u8`

## Instructions

### `AcceptOwnership`
- **Discriminator:** `0xac172b0deed55596`
- **Args:**
  - `params`: `AcceptOwnershipParams`
- **Account variants:**
  - `4 accounts:` `pending_owner`, `token_messenger`, `event_authority`, `program`

### `AddLocalToken`
- **Discriminator:** `0xd5c7cd12627c49c6`
- **Args:**
  - `params`: `AddLocalTokenParams`
- **Account variants:**
  - `10 accounts:` `payer`, `token_controller`, `token_minter`, `local_token`, `custody_token_account`, `local_token_mint`, `token_program`, `system_program`, `event_authority`, `program`

### `AddRemoteTokenMessenger`
- **Discriminator:** `0x0c95aca56fca1821`
- **Args:**
  - `params`: `AddRemoteTokenMessengerParams`
- **Account variants:**
  - `7 accounts:` `payer`, `owner`, `token_messenger`, `remote_token_messenger`, `system_program`, `event_authority`, `program`

### `BurnTokenCustody`
- **Discriminator:** `0xe988b4af70293e47`
- **Args:**
  - `params`: `BurnTokenCustodyParams`
- **Account variants:**
  - `9 accounts:` `payee`, `token_controller`, `token_minter`, `local_token`, `custody_token_account`, `custody_token_mint`, `token_program`, `event_authority`, `program`

### `DenylistAccount`
- **Discriminator:** `0x6574c57051f94bc2`
- **Args:**
  - `params`: `DenylistParams`
- **Account variants:**
  - `7 accounts:` `payer`, `denylister`, `token_messenger`, `denylist_account`, `system_program`, `event_authority`, `program`

### `DepositForBurn`
- **Discriminator:** `0xd73c3d2e723780b0`
- **Args:**
  - `params`: `DepositForBurnParams`
- **Account variants:**
  - `18 accounts:` `owner`, `event_rent_payer`, `sender_authority_pda`, `burn_token_account`, `denylist_account`, `message_transmitter`, `token_messenger`, `remote_token_messenger`, `token_minter`, `local_token`, `burn_token_mint`, `message_sent_event_data`, `message_transmitter_program`, `token_messenger_minter_program`, `token_program`, `system_program`, `event_authority`, `program`

### `DepositForBurnWithHook`
- **Discriminator:** `0x6ff53e83cc6cdf9b`
- **Args:**
  - `params`: `DepositForBurnWithHookParams`
- **Account variants:**
  - `18 accounts:` `owner`, `event_rent_payer`, `sender_authority_pda`, `burn_token_account`, `denylist_account`, `message_transmitter`, `token_messenger`, `remote_token_messenger`, `token_minter`, `local_token`, `burn_token_mint`, `message_sent_event_data`, `message_transmitter_program`, `token_messenger_minter_program`, `token_program`, `system_program`, `event_authority`, `program`

### `HandleReceiveFinalizedMessage`
- **Discriminator:** `0xbafcef4656b46e5f`
- **Args:**
  - `params`: `HandleReceiveMessageParams`
- **Account variants:**
  - `12 accounts:` `authority_pda`, `token_messenger`, `remote_token_messenger`, `token_minter`, `local_token`, `token_pair`, `fee_recipient_token_account`, `recipient_token_account`, `custody_token_account`, `token_program`, `event_authority`, `program`

### `HandleReceiveUnfinalizedMessage`
- **Discriminator:** `0xc8a9af14c83ab63d`
- **Args:**
  - `params`: `HandleReceiveMessageParams`
- **Account variants:**
  - `12 accounts:` `authority_pda`, `token_messenger`, `remote_token_messenger`, `token_minter`, `local_token`, `token_pair`, `fee_recipient_token_account`, `recipient_token_account`, `custody_token_account`, `token_program`, `event_authority`, `program`

### `Initialize`
- **Discriminator:** `0xafaf6d1f0d989bed`
- **Args:**
  - `params`: `InitializeParams`
- **Account variants:**
  - `10 accounts:` `payer`, `upgrade_authority`, `authority_pda`, `token_messenger`, `token_minter`, `token_messenger_minter_program_data`, `token_messenger_minter_program`, `system_program`, `event_authority`, `program`

### `LinkTokenPair`
- **Discriminator:** `0x44a218687d2e820c`
- **Args:**
  - `params`: `LinkTokenPairParams`
- **Account variants:**
  - `7 accounts:` `payer`, `token_controller`, `token_minter`, `token_pair`, `system_program`, `event_authority`, `program`

### `Pause`
- **Discriminator:** `0xd316ddfb4a79c12f`
- **Args:**
  - `params`: `PauseParams`
- **Account variants:**
  - `4 accounts:` `pauser`, `token_minter`, `event_authority`, `program`

### `RemoveLocalToken`
- **Discriminator:** `0x1b2b42aabc2c6d61`
- **Args:**
  - `params`: `RemoveLocalTokenParams`
- **Account variants:**
  - `9 accounts:` `payee`, `token_controller`, `token_minter`, `local_token`, `custody_token_account`, `custody_token_mint`, `token_program`, `event_authority`, `program`

### `RemoveRemoteTokenMessenger`
- **Discriminator:** `0x41724255a962b192`
- **Args:**
  - `params`: `RemoveRemoteTokenMessengerParams`
- **Account variants:**
  - `6 accounts:` `payee`, `owner`, `token_messenger`, `remote_token_messenger`, `event_authority`, `program`

### `SetFeeRecipient`
- **Discriminator:** `0xe312d72aedf69742`
- **Args:**
  - `params`: `SetFeeRecipientParams`
- **Account variants:**
  - `4 accounts:` `owner`, `token_messenger`, `event_authority`, `program`

### `SetMaxBurnAmountPerMessage`
- **Discriminator:** `0x1e8091f046ed6dcf`
- **Args:**
  - `params`: `SetMaxBurnAmountPerMessageParams`
- **Account variants:**
  - `5 accounts:` `token_controller`, `token_minter`, `local_token`, `event_authority`, `program`

### `SetMinFee`
- **Discriminator:** `0x72c6230329c4c2f6`
- **Args:**
  - `params`: `SetMinFeeParams`
- **Account variants:**
  - `4 accounts:` `min_fee_controller`, `token_messenger`, `event_authority`, `program`

### `SetMinFeeController`
- **Discriminator:** `0xc38e4a54ea5eb471`
- **Args:**
  - `params`: `SetMinFeeControllerParams`
- **Account variants:**
  - `4 accounts:` `owner`, `token_messenger`, `event_authority`, `program`

### `SetTokenController`
- **Discriminator:** `0x5806620a4f3b0f18`
- **Args:**
  - `params`: `SetTokenControllerParams`
- **Account variants:**
  - `5 accounts:` `owner`, `token_messenger`, `token_minter`, `event_authority`, `program`

### `TransferOwnership`
- **Discriminator:** `0x41b1d749352d632f`
- **Args:**
  - `params`: `TransferOwnershipParams`
- **Account variants:**
  - `4 accounts:` `owner`, `token_messenger`, `event_authority`, `program`

### `UndenylistAccount`
- **Discriminator:** `0x39242ba83eac2127`
- **Args:**
  - `params`: `UndenylistParams`
- **Account variants:**
  - `7 accounts:` `payer`, `denylister`, `token_messenger`, `denylist_account`, `system_program`, `event_authority`, `program`

### `UnlinkTokenPair`
- **Discriminator:** `0x34c6647268ae553a`
- **Args:**
  - `params`: `UninkTokenPairParams`
- **Account variants:**
  - `6 accounts:` `payee`, `token_controller`, `token_minter`, `token_pair`, `event_authority`, `program`

### `Unpause`
- **Discriminator:** `0xa99004260a8dbcff`
- **Args:**
  - `params`: `UnpauseParams`
- **Account variants:**
  - `4 accounts:` `pauser`, `token_minter`, `event_authority`, `program`

### `UpdateDenylister`
- **Discriminator:** `0xc142c6c954390ede`
- **Args:**
  - `params`: `UpdateDenylisterParams`
- **Account variants:**
  - `4 accounts:` `owner`, `token_messenger`, `event_authority`, `program`

### `UpdatePauser`
- **Discriminator:** `0x8cabd38439c910fe`
- **Args:**
  - `params`: `UpdatePauserParams`
- **Account variants:**
  - `5 accounts:` `owner`, `token_messenger`, `token_minter`, `event_authority`, `program`

## CPI events

### `DenylistedEvent`
- **Source:** `instructions/denylisted_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d1491adc8b611ea9a`
- **Fields:** (none)

### `DenylisterChangedEvent`
- **Source:** `instructions/denylister_changed_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1df9aa51b4b9af8a48`
- **Fields:** (none)

### `DepositForBurnEvent`
- **Source:** `instructions/deposit_for_burn_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d90fc9192064aa7eb`
- **Fields:** (none)

### `FeeRecipientSetEvent`
- **Source:** `instructions/fee_recipient_set_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d638c5023f5b0b36e`
- **Fields:** (none)

### `LocalTokenAddedEvent`
- **Source:** `instructions/local_token_added_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d9208e0967aad1727`
- **Fields:** (none)

### `LocalTokenRemovedEvent`
- **Source:** `instructions/local_token_removed_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1db5cc015f023242d2`
- **Fields:** (none)

### `MinFeeControllerSetEvent`
- **Source:** `instructions/min_fee_controller_set_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1def0c7a69e7720dc4`
- **Fields:** (none)

### `MinFeeSetEvent`
- **Source:** `instructions/min_fee_set_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d3c7f65e6d881bc62`
- **Fields:** (none)

### `MintAndWithdrawEvent`
- **Source:** `instructions/mint_and_withdraw_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d4b43e546a27e0047`
- **Fields:** (none)

### `OwnershipTransferStartedEvent`
- **Source:** `instructions/ownership_transfer_started_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1db7fdeff68cb38569`
- **Fields:** (none)

### `OwnershipTransferredEvent`
- **Source:** `instructions/ownership_transferred_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1dac3dcdb7fa322662`
- **Fields:** (none)

### `PauseEvent`
- **Source:** `instructions/pause_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1dc2fbe8c4765f6fdb`
- **Fields:** (none)

### `PauserChangedEvent`
- **Source:** `instructions/pauser_changed_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d8e9d9e577f087737`
- **Fields:** (none)

### `RemoteTokenMessengerAddedEvent`
- **Source:** `instructions/remote_token_messenger_added_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1dfb1d3ff43072d2af`
- **Fields:** (none)

### `RemoteTokenMessengerRemovedEvent`
- **Source:** `instructions/remote_token_messenger_removed_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1dff798927e67d0b1e`
- **Fields:** (none)

### `SetBurnLimitPerMessageEvent`
- **Source:** `instructions/set_burn_limit_per_message_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d629858bff51e1bd1`
- **Fields:** (none)

### `SetTokenControllerEvent`
- **Source:** `instructions/set_token_controller_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1dc12cf353e64878d8`
- **Fields:** (none)

### `TokenCustodyBurnedEvent`
- **Source:** `instructions/token_custody_burned_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1ddb8f6be2434bb22e`
- **Fields:** (none)

### `TokenPairLinkedEvent`
- **Source:** `instructions/token_pair_linked_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d020eb1409b5dc48d`
- **Fields:** (none)

### `TokenPairUnlinkedEvent`
- **Source:** `instructions/token_pair_unlinked_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d4ee8e6d0b4d4f648`
- **Fields:** (none)

### `UnDenylistedEvent`
- **Source:** `instructions/un_denylisted_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d9627e314a2b405f2`
- **Fields:** (none)

### `UnpauseEvent`
- **Source:** `instructions/unpause_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1df195685ac788db92`
- **Fields:** (none)

## Shared types

### `AcceptOwnershipParams`
- (no fields)

### `AddLocalTokenParams`
- (no fields)

### `AddRemoteTokenMessengerParams`
- `domain`: `u32`
- `token_messenger`: `Pubkey`

### `BurnTokenCustodyParams`
- `amount`: `u64`

### `DenylistParams`
- `account`: `Pubkey`

### `Denylisted`
- `account`: `Pubkey`

### `DenylisterChanged`
- `old_denylister`: `Pubkey`
- `new_denylister`: `Pubkey`

### `DepositForBurn`
- `burn_token`: `Pubkey`
- `amount`: `u64`
- `depositor`: `Pubkey`
- `mint_recipient`: `Pubkey`
- `destination_domain`: `u32`
- `destination_token_messenger`: `Pubkey`
- `destination_caller`: `Pubkey`
- `max_fee`: `u64`
- `min_finality_threshold`: `u32`
- `hook_data`: `Vec<u8>`

### `DepositForBurnParams`
- `amount`: `u64`
- `destination_domain`: `u32`
- `mint_recipient`: `Pubkey`
- `destination_caller`: `Pubkey`
- `max_fee`: `u64`
- `min_finality_threshold`: `u32`

### `DepositForBurnWithHookParams`
- `amount`: `u64`
- `destination_domain`: `u32`
- `mint_recipient`: `Pubkey`
- `destination_caller`: `Pubkey`
- `max_fee`: `u64`
- `min_finality_threshold`: `u32`
- `hook_data`: `Vec<u8>`

### `FeeRecipientSet`
- `new_fee_recipient`: `Pubkey`

### `HandleReceiveMessageParams`
- `remote_domain`: `u32`
- `sender`: `Pubkey`
- `finality_threshold_executed`: `u32`
- `message_body`: `Vec<u8>`
- `authority_bump`: `u8`

### `InitializeParams`
- `token_controller`: `Pubkey`
- `denylister`: `Pubkey`
- `fee_recipient`: `Pubkey`
- `min_fee_controller`: `Pubkey`
- `min_fee`: `u32`
- `message_body_version`: `u32`

### `LinkTokenPairParams`
- `local_token`: `Pubkey`
- `remote_domain`: `u32`
- `remote_token`: `Pubkey`

### `LocalTokenAdded`
- `custody`: `Pubkey`
- `mint`: `Pubkey`

### `LocalTokenRemoved`
- `custody`: `Pubkey`
- `mint`: `Pubkey`

### `MinFeeControllerSet`
- `new_min_fee_controller`: `Pubkey`

### `MinFeeSet`
- `new_min_fee`: `u32`

### `MintAndWithdraw`
- `mint_recipient`: `Pubkey`
- `amount`: `u64`
- `mint_token`: `Pubkey`
- `fee_collected`: `u64`

### `OwnershipTransferStarted`
- `previous_owner`: `Pubkey`
- `new_owner`: `Pubkey`

### `OwnershipTransferred`
- `previous_owner`: `Pubkey`
- `new_owner`: `Pubkey`

### `Pause`
- (no fields)

### `PauseParams`
- (no fields)

### `PauserChanged`
- `new_address`: `Pubkey`

### `RemoteTokenMessengerAdded`
- `domain`: `u32`
- `token_messenger`: `Pubkey`

### `RemoteTokenMessengerRemoved`
- `domain`: `u32`
- `token_messenger`: `Pubkey`

### `RemoveLocalTokenParams`
- (no fields)

### `RemoveRemoteTokenMessengerParams`
- (no fields)

### `SetBurnLimitPerMessage`
- `token`: `Pubkey`
- `burn_limit_per_message`: `u64`

### `SetFeeRecipientParams`
- `new_fee_recipient`: `Pubkey`

### `SetMaxBurnAmountPerMessageParams`
- `burn_limit_per_message`: `u64`

### `SetMinFeeControllerParams`
- `new_min_fee_controller`: `Pubkey`

### `SetMinFeeParams`
- `new_min_fee`: `u32`

### `SetTokenController`
- `token_controller`: `Pubkey`

### `SetTokenControllerParams`
- `token_controller`: `Pubkey`

### `TokenCustodyBurned`
- `custody_token_account`: `Pubkey`
- `amount`: `u64`

### `TokenPairLinked`
- `local_token`: `Pubkey`
- `remote_domain`: `u32`
- `remote_token`: `Pubkey`

### `TokenPairUnlinked`
- `local_token`: `Pubkey`
- `remote_domain`: `u32`
- `remote_token`: `Pubkey`

### `TransferOwnershipParams`
- `new_owner`: `Pubkey`

### `UnDenylisted`
- `account`: `Pubkey`

### `UndenylistParams`
- `account`: `Pubkey`

### `UninkTokenPairParams`
- (no fields)

### `Unpause`
- (no fields)

### `UnpauseParams`
- (no fields)

### `UpdateDenylisterParams`
- `new_denylister`: `Pubkey`

### `UpdatePauserParams`
- `new_pauser`: `Pubkey`
