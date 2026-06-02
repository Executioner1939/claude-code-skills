---
name: carbon-circle-message-transmitter-v2
description: "Carbon decoder reference for Circle CCTP v2 Message Transmitter on Solana — program `CCTPV2Sm4AdWt5296sk4P66VBZ7bEhcARwFaaS9YPbeC`, crate `carbon-circle-message-transmitter-v2-decoder` (15 instructions, 3 account types, 11 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"Circle Message Transmitter V2\", \"circle-message-transmitter-v2\", \"carbon-circle-message-transmitter-v2-decoder\", \"CCTPV2Sm4AdWt5296sk4P66VBZ7bEhcARwFaaS9YPbeC\", \"MessageTransmitterV2Decoder\", \"Circle CCTP v2 Message Transmitter\", \"AcceptOwnership\", \"DisableAttester\", \"EnableAttester\", \"Initialize\", \"IsNonceUsed\", \"Pause\", \"AttesterDisabledEvent\", \"AttesterEnabledEvent\", \"AttesterManagerUpdatedEvent\", \"MaxMessageBodySizeUpdatedEvent\", \"MessageSent\", \"MessageTransmitter\", \"UsedNonce\"."
---

# Circle Message Transmitter V2

- **Crate:** `carbon-circle-message-transmitter-v2-decoder`
- **Program ID:** `CCTPV2Sm4AdWt5296sk4P66VBZ7bEhcARwFaaS9YPbeC`
- **Decoder struct:** `MessageTransmitterV2Decoder`
- **Has CPI events:** yes (in instructions/)

## Instructions

- `AcceptOwnership`
- `DisableAttester`
- `EnableAttester`
- `Initialize`
- `IsNonceUsed`
- `Pause`
- `ReceiveMessage`
- `ReclaimEventAccount`
- `SendMessage`
- `SetMaxMessageBodySize`
- `SetSignatureThreshold`
- `TransferOwnership`
- `Unpause`
- `UpdateAttesterManager`
- `UpdatePauser`

## Account types

- `MessageSent`
- `MessageTransmitter`
- `UsedNonce`

## CPI events

- `AttesterDisabledEvent`
- `AttesterEnabledEvent`
- `AttesterManagerUpdatedEvent`
- `MaxMessageBodySizeUpdatedEvent`
- `MessageReceivedEvent`
- `OwnershipTransferStartedEvent`
- `OwnershipTransferredEvent`
- `PauseEvent`
- `PauserChangedEvent`
- `SignatureThresholdUpdatedEvent`
- `UnpauseEvent`

## Shared types

- `AcceptOwnershipParams`
- `AttesterDisabled`
- `AttesterEnabled`
- `AttesterManagerUpdated`
- `DisableAttesterParams`
- `EnableAttesterParams`
- `InitializeParams`
- `MaxMessageBodySizeUpdated`
- `MessageReceived`
- `OwnershipTransferStarted`
- `OwnershipTransferred`
- `Pause`
- `PauseParams`
- `PauserChanged`
- `ReceiveMessageParams`
- `ReclaimEventAccountParams`
- `SendMessageParams`
- `SetMaxMessageBodySizeParams`
- `SetSignatureThresholdParams`
- `SignatureThresholdUpdated`
- `TransferOwnershipParams`
- `Unpause`
- `UnpauseParams`
- `UpdateAttesterManagerParams`
- `UpdatePauserParams`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list circle-message-transmitter-v2

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix circle-message-transmitter-v2 <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account circle-message-transmitter-v2 <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event circle-message-transmitter-v2 <EventName>

# shared type fields
python3 "$CARBON" type circle-message-transmitter-v2 <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path circle-message-transmitter-v2
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-circle-message-transmitter-v2-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
