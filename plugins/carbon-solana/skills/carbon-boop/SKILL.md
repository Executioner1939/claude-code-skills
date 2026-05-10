---
name: carbon-boop
description: Carbon decoder reference for Boop launchpad on Solana — program `boop8hVGQGqehUK2iVEMEnMrL5RbjywRzHKBmBE7ry4`, crate `carbon-boop-decoder` (26 instructions, 4 account types, 23 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "Boop", "boop", "carbon-boop-decoder", "boop8hVGQGqehUK2iVEMEnMrL5RbjywRzHKBmBE7ry4", "BoopDecoder", "Boop launchpad", "AddOperators", "BuyToken", "CancelAuthorityTransfer", "CloseBondingCurveVault", "CollectMeteoraTradingFees", "CollectTradingFees", "AuthorityTransferCancelledEvent", "AuthorityTransferCompletedEvent", "AuthorityTransferInitiatedEvent", "BondingCurveDeployedEvent", "AmmConfig", "BondingCurve", "Config", "LockedCpLiquidityState".
---

# Boop

- **Crate:** `carbon-boop-decoder`
- **Program ID:** `boop8hVGQGqehUK2iVEMEnMrL5RbjywRzHKBmBE7ry4`
- **Decoder struct:** `BoopDecoder`
- **Has CPI events:** yes (in instructions/)

## Instructions

- `AddOperators`
- `BuyToken`
- `CancelAuthorityTransfer`
- `CloseBondingCurveVault`
- `CollectMeteoraTradingFees`
- `CollectTradingFees`
- `CompleteAuthorityTransfer`
- `CreateMeteoraPool`
- `CreateRaydiumPool`
- `CreateRaydiumRandomPool`
- `CreateToken`
- `CreateTokenFallback`
- `DeployBondingCurve`
- `DeployBondingCurveFallback`
- `DepositIntoRaydium`
- `Graduate`
- `Initialize`
- `InitiateAuthorityTransfer`
- `LockRaydiumLiquidity`
- `RemoveOperators`
- `SellToken`
- `SplitTradingFees`
- `SwapSolForTokensOnRaydium`
- `SwapTokensForSolOnRaydium`
- `TogglePaused`
- `UpdateConfig`

## Account types

- `AmmConfig`
- `BondingCurve`
- `Config`
- `LockedCpLiquidityState`

## CPI events

- `AuthorityTransferCancelledEvent`
- `AuthorityTransferCompletedEvent`
- `AuthorityTransferInitiatedEvent`
- `BondingCurveDeployedEvent`
- `BondingCurveDeployedFallbackEvent`
- `BondingCurveVaultClosedEvent`
- `ConfigUpdatedEvent`
- `LiquidityDepositedIntoRaydiumEvent`
- `OperatorsAddedEvent`
- `OperatorsRemovedEvent`
- `PausedToggledEvent`
- `RaydiumLiquidityLockedEvent`
- `RaydiumPoolCreatedEvent`
- `RaydiumRandomPoolCreatedEvent`
- `SwapSolForTokensOnRaydiumEvent`
- `SwapTokensForSolOnRaydiumEvent`
- `TokenBoughtEvent`
- `TokenCreatedEvent`
- `TokenCreatedFallbackEvent`
- `TokenGraduatedEvent`
- `TokenSoldEvent`
- `TradingFeesCollectedEvent`
- `TradingFeesSplitEvent`

## Shared types

- `BondingCurveStatus`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list boop

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix boop <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account boop <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event boop <EventName>

# shared type fields
python3 "$CARBON" type boop <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path boop
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-boop-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
