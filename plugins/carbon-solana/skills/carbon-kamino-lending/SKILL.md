---
name: carbon-kamino-lending
description: Carbon decoder reference for Kamino Lending on Solana — program `KLend2g3cP87fffoy8q1mQqGKjrxjC8boSyAYavgmjD`, crate `carbon-kamino-lending-decoder` (35 instructions, 8 account types). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "Kamino Lending", "kamino-lending", "carbon-kamino-lending-decoder", "KLend2g3cP87fffoy8q1mQqGKjrxjC8boSyAYavgmjD", "KaminoLendingDecoder", "BorrowObligationLiquidity", "DeleteReferrerStateAndShortUrl", "DepositObligationCollateral", "DepositReserveLiquidity", "DepositReserveLiquidityAndObligationCollateral", "FlashBorrowReserveLiquidity", "LendingMarket", "Obligation", "ReferrerState", "ReferrerTokenState".
---

# Kamino Lending

- **Crate:** `carbon-kamino-lending-decoder`
- **Program ID:** `KLend2g3cP87fffoy8q1mQqGKjrxjC8boSyAYavgmjD`
- **Decoder struct:** `KaminoLendingDecoder`
- **Has CPI events:** no

## Instructions

- `BorrowObligationLiquidity`
- `DeleteReferrerStateAndShortUrl`
- `DepositObligationCollateral`
- `DepositReserveLiquidity`
- `DepositReserveLiquidityAndObligationCollateral`
- `FlashBorrowReserveLiquidity`
- `FlashRepayReserveLiquidity`
- `IdlMissingTypes`
- `InitFarmsForReserve`
- `InitLendingMarket`
- `InitObligation`
- `InitObligationFarmsForReserve`
- `InitReferrerStateAndShortUrl`
- `InitReferrerTokenState`
- `InitReserve`
- `InitUserMetadata`
- `LiquidateObligationAndRedeemReserveCollateral`
- `MarkObligationForDeleveraging`
- `RedeemFees`
- `RedeemReserveCollateral`
- `RefreshObligation`
- `RefreshObligationFarmsForReserve`
- `RefreshReserve`
- `RefreshReservesBatch`
- `RepayAndWithdrawAndRedeem`
- `RepayObligationLiquidity`
- `RequestElevationGroup`
- `SocializeLoss`
- `UpdateLendingMarket`
- `UpdateLendingMarketOwner`
- `UpdateReserveConfig`
- `WithdrawObligationCollateral`
- `WithdrawObligationCollateralAndRedeemReserveCollateral`
- `WithdrawProtocolFee`
- `WithdrawReferrerFees`

## Account types

- `LendingMarket`
- `Obligation`
- `ReferrerState`
- `ReferrerTokenState`
- `Reserve`
- `ShortUrl`
- `UserMetadata`
- `UserState`

## Shared types

- `AssetTier`
- `BigFractionBytes`
- `BorrowRateCurve`
- `CurvePoint`
- `ElevationGroup`
- `FeeCalculation`
- `InitObligationArgs`
- `LastUpdate`
- `ObligationCollateral`
- `ObligationLiquidity`
- `PriceHeuristic`
- `PythConfiguration`
- `ReserveCollateral`
- `ReserveConfig`
- `ReserveFarmKind`
- `ReserveFees`
- `ReserveLiquidity`
- `ReserveStatus`
- `ScopeConfiguration`
- `SwitchboardConfiguration`
- `TokenInfo`
- `UpdateConfigMode`
- `UpdateLendingMarketConfigValue`
- `UpdateLendingMarketMode`
- `WithdrawalCaps`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list kamino-lending

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix kamino-lending <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account kamino-lending <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event kamino-lending <EventName>

# shared type fields
python3 "$CARBON" type kamino-lending <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path kamino-lending
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-kamino-lending-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
