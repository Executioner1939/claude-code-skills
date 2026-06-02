---
name: carbon-drift-v2
description: "Carbon decoder reference for Drift v2 (perpetuals) on Solana — program `dRiftyHA39MWEi3m9aunc5MzRF1JYuBsbn6VPcn33UH`, crate `carbon-drift-v2-decoder` (196 instructions, 17 account types, 19 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"Drift v2\", \"drift-v2\", \"carbon-drift-v2-decoder\", \"dRiftyHA39MWEi3m9aunc5MzRF1JYuBsbn6VPcn33UH\", \"DriftDecoder\", \"Drift v2 (perpetuals)\", \"AddInsuranceFundStake\", \"AddPerpLpShares\", \"AdminDisableUpdatePerpBidAskTwap\", \"BeginSwap\", \"CancelOrder\", \"CancelOrderByUserId\", \"CurveRecordEvent\", \"DeleteUserRecordEvent\", \"DepositRecordEvent\", \"FuelSeasonRecordEvent\", \"FuelOverflow\", \"HighLeverageModeConfig\", \"InsuranceFundStake\", \"OpenbookV2FulfillmentConfig\"."
---

# Drift v2

- **Crate:** `carbon-drift-v2-decoder`
- **Program ID:** `dRiftyHA39MWEi3m9aunc5MzRF1JYuBsbn6VPcn33UH`
- **Decoder struct:** `DriftDecoder`
- **Has CPI events:** yes (in instructions/)

## Instructions

- `AddInsuranceFundStake`
- `AddPerpLpShares`
- `AdminDisableUpdatePerpBidAskTwap`
- `BeginSwap`
- `CancelOrder`
- `CancelOrderByUserId`
- `CancelOrders`
- `CancelOrdersByIds`
- `CancelRequestRemoveInsuranceFundStake`
- `DeleteInitializedPerpMarket`
- `DeleteInitializedSpotMarket`
- `DeletePrelaunchOracle`
- `DeleteSignedMsgUserOrders`
- `DeleteUser`
- `Deposit`
- `DepositIntoPerpMarketFeePool`
- `DepositIntoSpotMarketRevenuePool`
- `DepositIntoSpotMarketVault`
- `DisableUserHighLeverageMode`
- `EnableUserHighLeverageMode`
- `EndSwap`
- `FillPerpOrder`
- `FillSpotOrder`
- `ForceCancelOrders`
- `ForceDeleteUser`
- `InitUserFuel`
- `Initialize`
- `InitializeFuelOverflow`
- `InitializeHighLeverageModeConfig`
- `InitializeInsuranceFundStake`
- `InitializeOpenbookV2FulfillmentConfig`
- `InitializePerpMarket`
- `InitializePhoenixFulfillmentConfig`
- `InitializePredictionMarket`
- `InitializePrelaunchOracle`
- `InitializeProtectedMakerModeConfig`
- `InitializeProtocolIfSharesTransferConfig`
- `InitializePythLazerOracle`
- `InitializePythPullOracle`
- `InitializeReferrerName`
- `InitializeSerumFulfillmentConfig`
- `InitializeSignedMsgUserOrders`
- `InitializeSpotMarket`
- `InitializeUser`
- `InitializeUserStats`
- `LiquidateBorrowForPerpPnl`
- `LiquidatePerp`
- `LiquidatePerpPnlForDeposit`
- `LiquidatePerpWithFill`
- `LiquidateSpot`
- `LiquidateSpotWithSwapBegin`
- `LiquidateSpotWithSwapEnd`
- `LogUserBalances`
- `ModifyOrder`
- `ModifyOrderByUserId`
- `MoveAmmPrice`
- `OpenbookV2FulfillmentConfigStatus`
- `PauseSpotMarketDepositWithdraw`
- `PhoenixFulfillmentConfigStatus`
- `PlaceAndMakePerpOrder`
- `PlaceAndMakeSignedMsgPerpOrder`
- `PlaceAndMakeSpotOrder`
- `PlaceAndTakePerpOrder`
- `PlaceAndTakeSpotOrder`
- `PlaceOrders`
- `PlacePerpOrder`
- `PlaceSignedMsgTakerOrder`
- `PlaceSpotOrder`
- `PostMultiPythPullOracleUpdatesAtomic`
- `PostPythLazerOracleUpdate`
- `PostPythPullOracleUpdateAtomic`
- `RecenterPerpMarketAmm`
- `ReclaimRent`
- `RemoveInsuranceFundStake`
- `RemovePerpLpShares`
- `RemovePerpLpSharesInExpiringMarket`
- `RepegAmmCurve`
- `RequestRemoveInsuranceFundStake`
- `ResetFuelSeason`
- `ResetPerpMarketAmmOracleTwap`
- `ResizeSignedMsgUserOrders`
- `ResolvePerpBankruptcy`
- `ResolvePerpPnlDeficit`
- `ResolveSpotBankruptcy`
- `RevertFill`
- `SetUserStatusToBeingLiquidated`
- `SettleExpiredMarket`
- `SettleExpiredMarketPoolsToRevenuePool`
- `SettleFundingPayment`
- `SettleLp`
- `SettleMultiplePnls`
- `SettlePnl`
- `SettleRevenueToInsuranceFund`
- `SweepFuel`
- `TransferDeposit`
- `TransferPools`
- `TransferProtocolIfShares`
- `TriggerOrder`
- `UpdateAdmin`
- `UpdateAmmJitIntensity`
- `UpdateAmms`
- `UpdateDiscountMint`
- `UpdateExchangeStatus`
- `UpdateFundingRate`
- `UpdateHighLeverageModeConfig`
- `UpdateInitialPctToLiquidate`
- `UpdateInsuranceFundUnstakingPeriod`
- `UpdateK`
- `UpdateLiquidationDuration`
- `UpdateLiquidationMarginBufferRatio`
- `UpdateLpCooldownTime`
- `UpdateOracleGuardRails`
- `UpdatePerpAuctionDuration`
- `UpdatePerpBidAskTwap`
- `UpdatePerpFeeStructure`
- `UpdatePerpMarketAmmOracleTwap`
- `UpdatePerpMarketAmmSummaryStats`
- `UpdatePerpMarketBaseSpread`
- `UpdatePerpMarketConcentrationCoef`
- `UpdatePerpMarketContractTier`
- `UpdatePerpMarketCurveUpdateIntensity`
- `UpdatePerpMarketExpiry`
- `UpdatePerpMarketFeeAdjustment`
- `UpdatePerpMarketFuel`
- `UpdatePerpMarketFundingPeriod`
- `UpdatePerpMarketHighLeverageMarginRatio`
- `UpdatePerpMarketImfFactor`
- `UpdatePerpMarketLiquidationFee`
- `UpdatePerpMarketMarginRatio`
- `UpdatePerpMarketMaxFillReserveFraction`
- `UpdatePerpMarketMaxImbalances`
- `UpdatePerpMarketMaxOpenInterest`
- `UpdatePerpMarketMaxSlippageRatio`
- `UpdatePerpMarketMaxSpread`
- `UpdatePerpMarketMinOrderSize`
- `UpdatePerpMarketName`
- `UpdatePerpMarketNumberOfUsers`
- `UpdatePerpMarketOracle`
- `UpdatePerpMarketPausedOperations`
- `UpdatePerpMarketPerLpBase`
- `UpdatePerpMarketStatus`
- `UpdatePerpMarketStepSizeAndTickSize`
- `UpdatePerpMarketTargetBaseAssetAmountPerLp`
- `UpdatePerpMarketUnrealizedAssetWeight`
- `UpdatePrelaunchOracle`
- `UpdatePrelaunchOracleParams`
- `UpdateProtectedMakerModeConfig`
- `UpdateProtocolIfSharesTransferConfig`
- `UpdatePythPullOracle`
- `UpdateSerumFulfillmentConfigStatus`
- `UpdateSerumVault`
- `UpdateSpotAuctionDuration`
- `UpdateSpotFeeStructure`
- `UpdateSpotMarketAssetTier`
- `UpdateSpotMarketBorrowRate`
- `UpdateSpotMarketCumulativeInterest`
- `UpdateSpotMarketExpiry`
- `UpdateSpotMarketFeeAdjustment`
- `UpdateSpotMarketFuel`
- `UpdateSpotMarketIfFactor`
- `UpdateSpotMarketIfPausedOperations`
- `UpdateSpotMarketLiquidationFee`
- `UpdateSpotMarketMarginWeights`
- `UpdateSpotMarketMaxTokenBorrows`
- `UpdateSpotMarketMaxTokenDeposits`
- `UpdateSpotMarketMinOrderSize`
- `UpdateSpotMarketName`
- `UpdateSpotMarketOracle`
- `UpdateSpotMarketOrdersEnabled`
- `UpdateSpotMarketPausedOperations`
- `UpdateSpotMarketPoolId`
- `UpdateSpotMarketRevenueSettlePeriod`
- `UpdateSpotMarketScaleInitialAssetWeightStart`
- `UpdateSpotMarketStatus`
- `UpdateSpotMarketStepSizeAndTickSize`
- `UpdateStateMaxInitializeUserFee`
- `UpdateStateMaxNumberOfSubAccounts`
- `UpdateStateSettlementDuration`
- `UpdateUserAdvancedLp`
- `UpdateUserCustomMarginRatio`
- `UpdateUserDelegate`
- `UpdateUserFuelBonus`
- `UpdateUserGovTokenInsuranceStake`
- `UpdateUserGovTokenInsuranceStakeDevnet`
- `UpdateUserIdle`
- `UpdateUserMarginTradingEnabled`
- `UpdateUserName`
- `UpdateUserOpenOrdersCount`
- `UpdateUserPoolId`
- `UpdateUserProtectedMakerOrders`
- `UpdateUserQuoteAssetInsuranceStake`
- `UpdateUserReduceOnly`
- `UpdateUserStatsReferrerStatus`
- `UpdateWhitelistMint`
- `UpdateWithdrawGuardThreshold`
- `Withdraw`

## Account types

- `FuelOverflow`
- `HighLeverageModeConfig`
- `InsuranceFundStake`
- `OpenbookV2FulfillmentConfig`
- `PerpMarket`
- `PhoenixV1FulfillmentConfig`
- `PrelaunchOracle`
- `ProtectedMakerModeConfig`
- `ProtocolIfSharesTransferConfig`
- `PythLazerOracle`
- `ReferrerName`
- `SerumV3FulfillmentConfig`
- `SignedMsgUserOrders`
- `SpotMarket`
- `State`
- `User`
- `UserStats`

## CPI events

- `CurveRecordEvent`
- `DeleteUserRecordEvent`
- `DepositRecordEvent`
- `FuelSeasonRecordEvent`
- `FuelSweepRecordEvent`
- `FundingPaymentRecordEvent`
- `FundingRateRecordEvent`
- `InsuranceFundRecordEvent`
- `InsuranceFundStakeRecordEvent`
- `LiquidationRecordEvent`
- `LpRecordEvent`
- `NewUserRecordEvent`
- `OrderActionRecordEvent`
- `OrderRecordEvent`
- `SettlePnlRecordEvent`
- `SignedMsgOrderRecordEvent`
- `SpotInterestRecordEvent`
- `SpotMarketVaultDepositRecordEvent`
- `SwapRecordEvent`

## Shared types

- `AMM`
- `AMMAvailability`
- `AMMLiquiditySplit`
- `AssetTier`
- `AssetType`
- `ContractTier`
- `ContractType`
- `DepositDirection`
- `DepositExplanation`
- `DriftAction`
- `ExchangeStatus`
- `FeeStructure`
- `FeeTier`
- `FillMode`
- `FuelOverflowStatus`
- `HistoricalIndexData`
- `HistoricalOracleData`
- `InsuranceClaim`
- `InsuranceFund`
- `InsuranceFundOperation`
- `LPAction`
- `LiquidateBorrowForPerpPnlRecord`
- `LiquidatePerpPnlForDepositRecord`
- `LiquidatePerpRecord`
- `LiquidateSpotRecord`
- `LiquidationMultiplierType`
- `LiquidationType`
- `MarginCalculationMode`
- `MarginMode`
- `MarginRequirementType`
- `MarketIdentifier`
- `MarketStatus`
- `MarketType`
- `ModifyOrderId`
- `ModifyOrderParams`
- `ModifyOrderPolicy`
- `OracleGuardRails`
- `OracleSource`
- `OracleValidity`
- `Order`
- `OrderAction`
- `OrderActionExplanation`
- `OrderFillerRewardStructure`
- `OrderParams`
- `OrderStatus`
- `OrderTriggerCondition`
- `OrderType`
- `PerpBankruptcyRecord`
- `PerpFulfillmentMethod`
- `PerpOperation`
- `PerpPosition`
- `PlaceAndTakeOrderSuccessCondition`
- `PoolBalance`
- `PositionDirection`
- `PositionUpdateType`
- `PostOnlyParam`
- `PrelaunchOracleParams`
- `PriceDivergenceGuardRails`
- `ReferrerStatus`
- `SettlePnlExplanation`
- `SettlePnlMode`
- `SignatureVerificationError`
- `SignedMsgOrderId`
- `SignedMsgOrderParamsMessage`
- `SignedMsgTriggerOrderParams`
- `SignedMsgUserOrdersFixed`
- `SpotBalanceType`
- `SpotBankruptcyRecord`
- `SpotFulfillmentConfigStatus`
- `SpotFulfillmentMethod`
- `SpotFulfillmentType`
- `SpotOperation`
- `SpotPosition`
- `StakeAction`
- `SwapDirection`
- `SwapReduceOnly`
- `TwapPeriod`
- `UpdatePerpMarketSummaryStatsParams`
- `UserFees`
- `UserStatus`
- `ValidityGuardRails`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list drift-v2

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix drift-v2 <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account drift-v2 <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event drift-v2 <EventName>

# shared type fields
python3 "$CARBON" type drift-v2 <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path drift-v2
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-drift-v2-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
