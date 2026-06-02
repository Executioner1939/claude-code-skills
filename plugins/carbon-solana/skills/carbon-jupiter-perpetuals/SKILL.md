---
name: carbon-jupiter-perpetuals
description: "Carbon decoder reference for Jupiter Perpetuals on Solana — program `PERPHjGBqRHArX4DySjwM6UJHiR3sWAatqfdBS2qQJu`, crate `carbon-jupiter-perpetuals-decoder` (39 instructions, 6 account types, 16 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"Jupiter Perpetuals\", \"jupiter-perpetuals\", \"carbon-jupiter-perpetuals-decoder\", \"PERPHjGBqRHArX4DySjwM6UJHiR3sWAatqfdBS2qQJu\", \"PerpetualsDecoder\", \"AddCustody\", \"AddLiquidity2\", \"AddPool\", \"ClosePositionRequest\", \"CreateDecreasePositionMarketRequest\", \"CreateDecreasePositionRequest2\", \"AddLiquidityEvent\", \"ClosePositionRequestEvent\", \"CreatePositionRequestEvent\", \"DecreasePositionEvent\", \"Custody\", \"Perpetuals\", \"Pool\", \"Position\"."
---

# Jupiter Perpetuals

- **Crate:** `carbon-jupiter-perpetuals-decoder`
- **Program ID:** `PERPHjGBqRHArX4DySjwM6UJHiR3sWAatqfdBS2qQJu`
- **Decoder struct:** `PerpetualsDecoder`
- **Has CPI events:** yes (in instructions/)

## Instructions

- `AddCustody`
- `AddLiquidity2`
- `AddPool`
- `ClosePositionRequest`
- `CreateDecreasePositionMarketRequest`
- `CreateDecreasePositionRequest2`
- `CreateIncreasePositionMarketRequest`
- `CreateTokenLedger`
- `CreateTokenMetadata`
- `DecreasePosition4`
- `DecreasePositionWithInternalSwap`
- `GetAddLiquidityAmountAndFee2`
- `GetAssetsUnderManagement2`
- `GetRemoveLiquidityAmountAndFee2`
- `IncreasePosition4`
- `IncreasePositionPreSwap`
- `IncreasePositionWithInternalSwap`
- `Init`
- `InstantCreateLimitOrder`
- `InstantCreateTpsl`
- `InstantDecreasePosition`
- `InstantIncreasePosition`
- `InstantUpdateLimitOrder`
- `InstantUpdateTpsl`
- `LiquidateFullPosition4`
- `OperatorSetCustodyConfig`
- `OperatorSetPoolConfig`
- `RefreshAssetsUnderManagement`
- `RemoveLiquidity2`
- `SetCustodyConfig`
- `SetPerpetualsConfig`
- `SetPoolConfig`
- `SetTestTime`
- `SetTokenLedger`
- `Swap2`
- `TestInit`
- `TransferAdmin`
- `UpdateDecreasePositionRequest2`
- `WithdrawFees2`

## Account types

- `Custody`
- `Perpetuals`
- `Pool`
- `Position`
- `PositionRequest`
- `TokenLedger`

## CPI events

- `AddLiquidityEvent`
- `ClosePositionRequestEvent`
- `CreatePositionRequestEvent`
- `DecreasePositionEvent`
- `DecreasePositionPostSwapEvent`
- `IncreasePositionEvent`
- `IncreasePositionPreSwapEvent`
- `InstantCreateLimitOrderEvent`
- `InstantCreateTpslEvent`
- `InstantDecreasePositionEvent`
- `InstantIncreasePositionEvent`
- `InstantUpdateTpslEvent`
- `LiquidateFullPositionEvent`
- `PoolSwapEvent`
- `PoolSwapExactOutEvent`
- `RemoveLiquidityEvent`

## Shared types

- `AddCustodyParams`
- `AddLiquidity2Params`
- `AddPoolParams`
- `AmountAndFee`
- `Assets`
- `ClosePositionRequestParams`
- `CreateDecreasePositionMarketRequestParams`
- `CreateDecreasePositionRequest2Params`
- `CreateIncreasePositionMarketRequestParams`
- `CreateTokenMetadataParams`
- `DecreasePosition4Params`
- `DecreasePositionWithInternalSwapParams`
- `Fees`
- `FundingRateState`
- `GetAddLiquidityAmountAndFee2Params`
- `GetAssetsUnderManagement2Params`
- `GetRemoveLiquidityAmountAndFee2Params`
- `IncreasePosition4Params`
- `IncreasePositionPreSwapParams`
- `IncreasePositionWithInternalSwapParams`
- `InitParams`
- `InstantCreateLimitOrderParams`
- `InstantCreateTpslParams`
- `InstantDecreasePositionParams`
- `InstantIncreasePositionParams`
- `InstantUpdateLimitOrderParams`
- `InstantUpdateTpslParams`
- `JumpRateState`
- `Limit`
- `LiquidateFullPosition4Params`
- `OperatorSetCustodyConfigParams`
- `OperatorSetPoolConfigParams`
- `OracleParams`
- `OraclePrice`
- `OracleType`
- `Permissions`
- `PoolApr`
- `PriceCalcMode`
- `PriceStaleTolerance`
- `PricingParams`
- `RefreshAssetsUnderManagementParams`
- `RemoveLiquidity2Params`
- `RequestChange`
- `RequestType`
- `SetCustodyConfigParams`
- `SetPerpetualsConfigParams`
- `SetPoolConfigParams`
- `SetTestTimeParams`
- `Side`
- `Swap2Params`
- `TestInitParams`
- `TransferAdminParams`
- `UpdateDecreasePositionRequest2Params`
- `WithdrawFees2Params`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list jupiter-perpetuals

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix jupiter-perpetuals <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account jupiter-perpetuals <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event jupiter-perpetuals <EventName>

# shared type fields
python3 "$CARBON" type jupiter-perpetuals <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path jupiter-perpetuals
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-jupiter-perpetuals-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
