---
name: carbon-circle-token-messenger-v2
description: "Carbon decoder reference for Circle CCTP v2 Token Messenger on Solana — program `CCTPV2vPZJS2u2BBsUoscuikbYjnpFmbFsvVuJdgUMQe`, crate `carbon-circle-token-messenger-v2-decoder` (25 instructions, 7 account types, 22 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"Circle Token Messenger V2\", \"circle-token-messenger-v2\", \"carbon-circle-token-messenger-v2-decoder\", \"CCTPV2vPZJS2u2BBsUoscuikbYjnpFmbFsvVuJdgUMQe\", \"TokenMessengerMinterV2Decoder\", \"Circle CCTP v2 Token Messenger\", \"AcceptOwnership\", \"AddLocalToken\", \"AddRemoteTokenMessenger\", \"BurnTokenCustody\", \"DenylistAccount\", \"DepositForBurn\", \"DenylistedEvent\", \"DenylisterChangedEvent\", \"DepositForBurnEvent\", \"FeeRecipientSetEvent\", \"DenylistedAccount\", \"LocalToken\", \"MessageTransmitter\", \"RemoteTokenMessenger\"."
---

# Circle Token Messenger V2

- **Crate:** `carbon-circle-token-messenger-v2-decoder`
- **Program ID:** `CCTPV2vPZJS2u2BBsUoscuikbYjnpFmbFsvVuJdgUMQe`
- **Decoder struct:** `TokenMessengerMinterV2Decoder`
- **Has CPI events:** yes (in instructions/)

## Instructions

- `AcceptOwnership`
- `AddLocalToken`
- `AddRemoteTokenMessenger`
- `BurnTokenCustody`
- `DenylistAccount`
- `DepositForBurn`
- `DepositForBurnWithHook`
- `HandleReceiveFinalizedMessage`
- `HandleReceiveUnfinalizedMessage`
- `Initialize`
- `LinkTokenPair`
- `Pause`
- `RemoveLocalToken`
- `RemoveRemoteTokenMessenger`
- `SetFeeRecipient`
- `SetMaxBurnAmountPerMessage`
- `SetMinFee`
- `SetMinFeeController`
- `SetTokenController`
- `TransferOwnership`
- `UndenylistAccount`
- `UnlinkTokenPair`
- `Unpause`
- `UpdateDenylister`
- `UpdatePauser`

## Account types

- `DenylistedAccount`
- `LocalToken`
- `MessageTransmitter`
- `RemoteTokenMessenger`
- `TokenMessenger`
- `TokenMinter`
- `TokenPair`

## CPI events

- `DenylistedEvent`
- `DenylisterChangedEvent`
- `DepositForBurnEvent`
- `FeeRecipientSetEvent`
- `LocalTokenAddedEvent`
- `LocalTokenRemovedEvent`
- `MinFeeControllerSetEvent`
- `MinFeeSetEvent`
- `MintAndWithdrawEvent`
- `OwnershipTransferStartedEvent`
- `OwnershipTransferredEvent`
- `PauseEvent`
- `PauserChangedEvent`
- `RemoteTokenMessengerAddedEvent`
- `RemoteTokenMessengerRemovedEvent`
- `SetBurnLimitPerMessageEvent`
- `SetTokenControllerEvent`
- `TokenCustodyBurnedEvent`
- `TokenPairLinkedEvent`
- `TokenPairUnlinkedEvent`
- `UnDenylistedEvent`
- `UnpauseEvent`

## Shared types

- `AcceptOwnershipParams`
- `AddLocalTokenParams`
- `AddRemoteTokenMessengerParams`
- `BurnTokenCustodyParams`
- `DenylistParams`
- `Denylisted`
- `DenylisterChanged`
- `DepositForBurn`
- `DepositForBurnParams`
- `DepositForBurnWithHookParams`
- `FeeRecipientSet`
- `HandleReceiveMessageParams`
- `InitializeParams`
- `LinkTokenPairParams`
- `LocalTokenAdded`
- `LocalTokenRemoved`
- `MinFeeControllerSet`
- `MinFeeSet`
- `MintAndWithdraw`
- `OwnershipTransferStarted`
- `OwnershipTransferred`
- `Pause`
- `PauseParams`
- `PauserChanged`
- `RemoteTokenMessengerAdded`
- `RemoteTokenMessengerRemoved`
- `RemoveLocalTokenParams`
- `RemoveRemoteTokenMessengerParams`
- `SetBurnLimitPerMessage`
- `SetFeeRecipientParams`
- `SetMaxBurnAmountPerMessageParams`
- `SetMinFeeControllerParams`
- `SetMinFeeParams`
- `SetTokenController`
- `SetTokenControllerParams`
- `TokenCustodyBurned`
- `TokenPairLinked`
- `TokenPairUnlinked`
- `TransferOwnershipParams`
- `UnDenylisted`
- `UndenylistParams`
- `UninkTokenPairParams`
- `Unpause`
- `UnpauseParams`
- `UpdateDenylisterParams`
- `UpdatePauserParams`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list circle-token-messenger-v2

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix circle-token-messenger-v2 <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account circle-token-messenger-v2 <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event circle-token-messenger-v2 <EventName>

# shared type fields
python3 "$CARBON" type circle-token-messenger-v2 <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path circle-token-messenger-v2
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-circle-token-messenger-v2-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
