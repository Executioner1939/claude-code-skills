---
name: carbon-heaven
description: Carbon decoder reference for Heaven on Solana — program `HEAVENoP2qxoeuF8Dj2oT1GHEnu49U5mJYkdeC8BAX2o`, crate `carbon-heaven-decoder` (32 instructions, 5 account types, 5 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "Heaven", "heaven", "carbon-heaven-decoder", "HEAVENoP2qxoeuF8Dj2oT1GHEnu49U5mJYkdeC8BAX2o", "HeavenDecoder", "AdminBorrowSol", "AdminClaimMsol", "AdminClaimStakingRewards", "AdminClaimStandardCreatorTradingFees", "AdminDepositMsol", "AdminMintMsol", "CreateLiquidityPoolEvent", "CreateStandardLiquidityPoolEvent", "CreatingLiquidityPoolEvent", "TradeEvent", "LiquidityPoolState", "MsolTicketSolSpent", "ProtocolAdminState", "ProtocolConfig".
---

# Heaven

- **Crate:** `carbon-heaven-decoder`
- **Program ID:** `HEAVENoP2qxoeuF8Dj2oT1GHEnu49U5mJYkdeC8BAX2o`
- **Decoder struct:** `HeavenDecoder`
- **Has CPI events:** yes (in instructions/)

## Instructions

- `AdminBorrowSol`
- `AdminClaimMsol`
- `AdminClaimStakingRewards`
- `AdminClaimStandardCreatorTradingFees`
- `AdminDepositMsol`
- `AdminMintMsol`
- `AdminRepaySol`
- `AdminUnstakeMsol`
- `AdminUpdateStandardLiquidityPoolState`
- `AdminWithdrawMsol`
- `AdminWithdrawTransferFee`
- `Buy`
- `ClaimStandardCreatorTradingFeeProtocolFees`
- `ClaimStandardCreatorTradingFees`
- `ClaimStandardProtocolTradingFees`
- `ClaimStandardReflectionTradingFees`
- `CloseProtocolLookupTable`
- `CreateOrUpdateProtocolFeeAdmin`
- `CreateOrUpdateProtocolOwner`
- `CreateOrUpdateProtocolStakingAdmin`
- `CreateProtocolConfig`
- `CreateProtocolLookupTable`
- `CreateStandardLiquidityPool`
- `DeactivateProtocolLookupTable`
- `ExtendProtocolLookupTable`
- `InitializeProtocolLending`
- `RemainingAccountsStub`
- `Sell`
- `SetProtocolSlotFees`
- `UpdateAllowCreatePool`
- `UpdateCreatorTradingFeeReceiver`
- `UpdateProtocolConfig`

## Account types

- `LiquidityPoolState`
- `MsolTicketSolSpent`
- `ProtocolAdminState`
- `ProtocolConfig`
- `ProtocolOwnerState`

## CPI events

- `CreateLiquidityPoolEvent`
- `CreateStandardLiquidityPoolEvent`
- `CreatingLiquidityPoolEvent`
- `TradeEvent`
- `UserDefinedEvent`

## Shared types

- `AdminUpdateLiquidityPoolState`
- `BuyParams`
- `CreateStandardLiquidityPoolParams`
- `CreatorTradingFeeClaimStatus`
- `CreatorTradingFeeDistribution`
- `FeeBracket`
- `FeeBrackets`
- `FeeConfigurationMode`
- `FeeType`
- `LiquidityPoolAllowlist`
- `LiquidityPoolFeatureFlags`
- `LiquidityPoolInfo`
- `LiquidityPoolLpTokenInfo`
- `LiquidityPoolLpTokenSupply`
- `LiquidityPoolMarketCapBasedFees`
- `LiquidityPoolReserve`
- `LiquidityPoolSlotOffsetBasedFees`
- `LiquidityPoolTokenInfo`
- `LiquidityPoolType`
- `ProtocolConfigParams`
- `SellParams`
- `SlotFeeBracket`
- `SlotFeeBrackets`
- `SlotFeeBracketsParams`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list heaven

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix heaven <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account heaven <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event heaven <EventName>

# shared type fields
python3 "$CARBON" type heaven <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path heaven
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-heaven-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
