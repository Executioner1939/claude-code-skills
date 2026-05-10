# Circle Message Transmitter V2

- **Crate:** `carbon-circle-message-transmitter-v2-decoder`
- **Program ID:** `CCTPV2Sm4AdWt5296sk4P66VBZ7bEhcARwFaaS9YPbeC`
- **Decoder struct:** `MessageTransmitterV2Decoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in instructions/)
- **Discriminator style:** anchor 8-byte

## Account types

### `MessageSent`
- **Discriminator:** `0x83648538a6e1973c`
- **Fields:**
  - `rent_payer`: `Pubkey`
  - `created_at`: `i64`
  - `message`: `Vec<u8>`

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

### `UsedNonce`
- **Discriminator:** `0xd4de9dfc8247b3ee`
- **Fields:**
  - `is_used`: `bool`

## Instructions

### `AcceptOwnership`
- **Discriminator:** `0xac172b0deed55596`
- **Args:**
  - `params`: `AcceptOwnershipParams`
- **Account variants:**
  - `4 accounts:` `pending_owner`, `message_transmitter`, `event_authority`, `program`

### `DisableAttester`
- **Discriminator:** `0x3dab835fac0fe3e5`
- **Args:**
  - `params`: `DisableAttesterParams`
- **Account variants:**
  - `6 accounts:` `payer`, `attester_manager`, `message_transmitter`, `system_program`, `event_authority`, `program`

### `EnableAttester`
- **Discriminator:** `0x020bc173059404c6`
- **Args:**
  - `params`: `EnableAttesterParams`
- **Account variants:**
  - `6 accounts:` `payer`, `attester_manager`, `message_transmitter`, `system_program`, `event_authority`, `program`

### `Initialize`
- **Discriminator:** `0xafaf6d1f0d989bed`
- **Args:**
  - `params`: `InitializeParams`
- **Account variants:**
  - `8 accounts:` `payer`, `upgrade_authority`, `message_transmitter`, `message_transmitter_program_data`, `message_transmitter_program`, `system_program`, `event_authority`, `program`

### `IsNonceUsed`
- **Discriminator:** `0x90486b9423da1fbb`
- **Args:** (none)
- **Account variants:**
  - `1 accounts:` `used_nonce`

### `Pause`
- **Discriminator:** `0xd316ddfb4a79c12f`
- **Args:**
  - `params`: `PauseParams`
- **Account variants:**
  - `4 accounts:` `pauser`, `message_transmitter`, `event_authority`, `program`

### `ReceiveMessage`
- **Discriminator:** `0x26907fe11fe1ee19`
- **Args:**
  - `params`: `ReceiveMessageParams`
- **Account variants:**
  - `9 accounts:` `payer`, `caller`, `authority_pda`, `message_transmitter`, `used_nonce`, `receiver`, `system_program`, `event_authority`, `program`

### `ReclaimEventAccount`
- **Discriminator:** `0x5ec6b49f83ec0fae`
- **Args:**
  - `params`: `ReclaimEventAccountParams`
- **Account variants:**
  - `3 accounts:` `payee`, `message_transmitter`, `message_sent_event_data`

### `SendMessage`
- **Discriminator:** `0x392822b2bd0a411a`
- **Args:**
  - `params`: `SendMessageParams`
- **Account variants:**
  - `6 accounts:` `event_rent_payer`, `sender_authority_pda`, `message_transmitter`, `message_sent_event_data`, `sender_program`, `system_program`

### `SetMaxMessageBodySize`
- **Discriminator:** `0xa8b20875d9a7db1f`
- **Args:**
  - `params`: `SetMaxMessageBodySizeParams`
- **Account variants:**
  - `4 accounts:` `owner`, `message_transmitter`, `event_authority`, `program`

### `SetSignatureThreshold`
- **Discriminator:** `0xa3139aa852d1d6db`
- **Args:**
  - `params`: `SetSignatureThresholdParams`
- **Account variants:**
  - `4 accounts:` `attester_manager`, `message_transmitter`, `event_authority`, `program`

### `TransferOwnership`
- **Discriminator:** `0x41b1d749352d632f`
- **Args:**
  - `params`: `TransferOwnershipParams`
- **Account variants:**
  - `4 accounts:` `owner`, `message_transmitter`, `event_authority`, `program`

### `Unpause`
- **Discriminator:** `0xa99004260a8dbcff`
- **Args:**
  - `params`: `UnpauseParams`
- **Account variants:**
  - `4 accounts:` `pauser`, `message_transmitter`, `event_authority`, `program`

### `UpdateAttesterManager`
- **Discriminator:** `0xaff5b26855b34710`
- **Args:**
  - `params`: `UpdateAttesterManagerParams`
- **Account variants:**
  - `4 accounts:` `owner`, `message_transmitter`, `event_authority`, `program`

### `UpdatePauser`
- **Discriminator:** `0x8cabd38439c910fe`
- **Args:**
  - `params`: `UpdatePauserParams`
- **Account variants:**
  - `4 accounts:` `owner`, `message_transmitter`, `event_authority`, `program`

## CPI events

### `AttesterDisabledEvent`
- **Source:** `instructions/attester_disabled_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1dba88ba0ee50279d3`
- **Fields:** (none)

### `AttesterEnabledEvent`
- **Source:** `instructions/attester_enabled_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d58390e8505db3ebe`
- **Fields:** (none)

### `AttesterManagerUpdatedEvent`
- **Source:** `instructions/attester_manager_updated_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d0561bf6c2cbd4558`
- **Fields:** (none)

### `MaxMessageBodySizeUpdatedEvent`
- **Source:** `instructions/max_message_body_size_updated_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d86ce976f890ba0e1`
- **Fields:** (none)

### `MessageReceivedEvent`
- **Source:** `instructions/message_received_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1de7442f4dadf19da6`
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

### `SignatureThresholdUpdatedEvent`
- **Source:** `instructions/signature_threshold_updated_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d9c6367c80f267abd`
- **Fields:** (none)

### `UnpauseEvent`
- **Source:** `instructions/unpause_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1df195685ac788db92`
- **Fields:** (none)

## Shared types

### `AcceptOwnershipParams`
- (no fields)

### `AttesterDisabled`
- `attester`: `Pubkey`

### `AttesterEnabled`
- `attester`: `Pubkey`

### `AttesterManagerUpdated`
- `previous_attester_manager`: `Pubkey`
- `new_attester_manager`: `Pubkey`

### `DisableAttesterParams`
- `attester`: `Pubkey`

### `EnableAttesterParams`
- `new_attester`: `Pubkey`

### `InitializeParams`
- `local_domain`: `u32`
- `attester`: `Pubkey`
- `max_message_body_size`: `u64`
- `version`: `u32`

### `MaxMessageBodySizeUpdated`
- `new_max_message_body_size`: `u64`

### `MessageReceived`
- `caller`: `Pubkey`
- `source_domain`: `u32`
- `nonce`: `[u8; 32]`
- `sender`: `Pubkey`
- `finality_threshold_executed`: `u32`
- `message_body`: `Vec<u8>`

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

### `ReceiveMessageParams`
- `message`: `Vec<u8>`
- `attestation`: `Vec<u8>`

### `ReclaimEventAccountParams`
- `attestation`: `Vec<u8>`
- `destination_message`: `Vec<u8>`

### `SendMessageParams`
- `destination_domain`: `u32`
- `recipient`: `Pubkey`
- `destination_caller`: `Pubkey`
- `min_finality_threshold`: `u32`
- `message_body`: `Vec<u8>`

### `SetMaxMessageBodySizeParams`
- `new_max_message_body_size`: `u64`

### `SetSignatureThresholdParams`
- `new_signature_threshold`: `u32`

### `SignatureThresholdUpdated`
- `old_signature_threshold`: `u32`
- `new_signature_threshold`: `u32`

### `TransferOwnershipParams`
- `new_owner`: `Pubkey`

### `Unpause`
- (no fields)

### `UnpauseParams`
- (no fields)

### `UpdateAttesterManagerParams`
- `new_attester_manager`: `Pubkey`

### `UpdatePauserParams`
- `new_pauser`: `Pubkey`
