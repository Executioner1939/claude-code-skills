---
name: carbon-token-2022
description: Carbon decoder reference for SPL Token-2022 program on Solana — program `TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb`, crate `carbon-token-2022-decoder` (87 instructions, 3 account types). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "SPL Token-2022", "token-2022", "carbon-token-2022-decoder", "TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb", "Token2022Decoder", "SPL Token-2022 program", "InitializeMint", "InitializeAccount", "InitializeMultisig", "Transfer", "Approve", "Revoke", "Mint", "Token", "Multisig".
---

# SPL Token-2022

- **Crate:** `carbon-token-2022-decoder`
- **Program ID:** `TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb`
- **Decoder struct:** `Token2022Decoder`
- **Has CPI events:** no

## Instructions

- `InitializeMint`
- `InitializeAccount`
- `InitializeMultisig`
- `Transfer`
- `Approve`
- `Revoke`
- `SetAuthority`
- `MintTo`
- `Burn`
- `CloseAccount`
- `FreezeAccount`
- `ThawAccount`
- `TransferChecked`
- `ApproveChecked`
- `MintToChecked`
- `BurnChecked`
- `InitializeAccount2`
- `SyncNative`
- `InitializeAccount3`
- `InitializeMultisig2`
- `InitializeMint2`
- `GetAccountDataSize`
- `InitializeImmutableOwner`
- `AmountToUiAmount`
- `UiAmountToAmount`
- `InitializeMintCloseAuthority`
- `InitializeTransferFeeConfig`
- `TransferCheckedWithFee`
- `WithdrawWithheldTokensFromMint`
- `WithdrawWithheldTokensFromAccounts`
- `HarvestWithheldTokensToMint`
- `SetTransferFee`
- `InitializeConfidentialTransferMint`
- `UpdateConfidentialTransferMint`
- `ConfigureConfidentialTransferAccount`
- `ApproveConfidentialTransferAccount`
- `EmptyConfidentialTransferAccount`
- `ConfidentialDeposit`
- `ConfidentialWithdraw`
- `ConfidentialTransfer`
- `ApplyConfidentialPendingBalance`
- `EnableConfidentialCredits`
- `DisableConfidentialCredits`
- `EnableNonConfidentialCredits`
- `DisableNonConfidentialCredits`
- `ConfidentialTransferWithFee`
- `InitializeDefaultAccountState`
- `UpdateDefaultAccountState`
- `Reallocate`
- `EnableMemoTransfers`
- `DisableMemoTransfers`
- `CreateNativeMint`
- `InitializeNonTransferableMint`
- `InitializeInterestBearingMint`
- `UpdateRateInterestBearingMint`
- `EnableCpiGuard`
- `DisableCpiGuard`
- `InitializePermanentDelegate`
- `InitializeTransferHook`
- `UpdateTransferHook`
- `InitializeConfidentialTransferFee`
- `WithdrawWithheldTokensFromMintForConfidentialTransferFee`
- `WithdrawWithheldTokensFromAccountsForConfidentialTransferFee`
- `HarvestWithheldTokensToMintForConfidentialTransferFee`
- `EnableHarvestToMint`
- `DisableHarvestToMint`
- `WithdrawExcessLamports`
- `InitializeMetadataPointer`
- `UpdateMetadataPointer`
- `InitializeGroupPointer`
- `UpdateGroupPointer`
- `InitializeGroupMemberPointer`
- `UpdateGroupMemberPointer`
- `InitializeScaledUiAmountMint`
- `UpdateMultiplierScaledUiMint`
- `InitializePausableConfig`
- `Pause`
- `Resume`
- `InitializeTokenMetadata`
- `UpdateTokenMetadataField`
- `RemoveTokenMetadataKey`
- `UpdateTokenMetadataUpdateAuthority`
- `EmitTokenMetadata`
- `InitializeTokenGroup`
- `UpdateTokenGroupMaxSize`
- `UpdateTokenGroupUpdateAuthority`
- `InitializeTokenGroupMember`

## Account types

- `Mint`
- `Token`
- `Multisig`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list token-2022

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix token-2022 <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account token-2022 <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event token-2022 <EventName>

# shared type fields
python3 "$CARBON" type token-2022 <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path token-2022
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-token-2022-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
