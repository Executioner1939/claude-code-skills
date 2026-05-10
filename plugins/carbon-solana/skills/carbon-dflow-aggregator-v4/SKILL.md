---
name: carbon-dflow-aggregator-v4
description: Carbon decoder reference for DFlow Aggregator v4 on Solana — program `DF1ow4tspfHX9JwWJsAb9epbkA8hmpSEAtxXy1V27QBH`, crate `carbon-dflow-aggregator-v4-decoder` (16 instructions, 1 account types, 2 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "DFlow Aggregator V4", "dflow-aggregator-v4", "carbon-dflow-aggregator-v4-decoder", "DF1ow4tspfHX9JwWJsAb9epbkA8hmpSEAtxXy1V27QBH", "SwapOrchestratorDecoder", "DFlow Aggregator v4", "CloseOrder", "CpiEvent", "CreateReferralTokenAccountIdempotent", "FillOrder", "OpenOrder", "Swap", "FeeEventEvent", "SwapEventEvent", "Order".
---

# DFlow Aggregator V4

- **Crate:** `carbon-dflow-aggregator-v4-decoder`
- **Program ID:** `DF1ow4tspfHX9JwWJsAb9epbkA8hmpSEAtxXy1V27QBH`
- **Decoder struct:** `SwapOrchestratorDecoder`
- **Has CPI events:** yes (events/)

## Instructions

- `CloseOrder`
- `CpiEvent`
- `CreateReferralTokenAccountIdempotent`
- `FillOrder`
- `OpenOrder`
- `Swap`
- `Swap2`
- `Swap2WithDestination`
- `Swap2WithDestinationNative`
- `SwapWithDestination`
- `SwapWithDestinationNative`
- `TransferFee`
- `TransferSol`
- `TransferToSponsor`
- `UnwrapSol`
- `WrapSol`

## Account types

- `Order`

## CPI events

- `FeeEventEvent`
- `SwapEventEvent`

## Shared types

- `Action`
- `AlphaQSwapOptions`
- `ClearpoolsSwapOptions`
- `DFlowDynamicRouteV1Options`
- `DynamicRouteV1CandidateAction`
- `FeeEvent`
- `FillOrderParams`
- `GammaSwapOptions`
- `HeavenSwapOptions`
- `HumidiFiDynamicRouteV1Options`
- `HumidiFiSwapOptions`
- `LifinityV2SwapOptions`
- `ManifestSwapOptions`
- `MeteoraDammV1SwapOptions`
- `MeteoraDammV2SwapOptions`
- `MeteoraDbcSwapOptions`
- `MeteoraDlmmSwapOptions`
- `MeteoraDlmmSwapV2Options`
- `MozartDynamicRouteV1Options`
- `MozartSwapOptions`
- `NexusDynamicRouteV1Options`
- `NexusSwapOptions`
- `ObricV2DynamicRouteV1Options`
- `ObricV2SwapOptions`
- `OpenOrderParams`
- `OrchestratorFlags`
- `PhoenixSwapOptions`
- `PumpFunAmmBuyOptions`
- `PumpFunAmmSellOptions`
- `PumpFunBuyOptions`
- `PumpFunSellOptions`
- `RaydiumAmmSwapOptions`
- `RaydiumClmmSwapOptions`
- `RaydiumClmmSwapV2Options`
- `RaydiumCpSwapOptions`
- `RaydiumLaunchlabSwapOptions`
- `RecordId2Options`
- `RecordIdOptions`
- `RubiconDynamicRouteV1Options`
- `RubiconSwapOptions`
- `SarosDlmmSwapOptions`
- `Side`
- `SolFiDynamicRouteV1Options`
- `SolFiSwapOptions`
- `SolFiV2DynamicRouteV1Options`
- `SolFiV2SwapOptions`
- `StabbleStableSwapOptions`
- `Swap2Params`
- `SwapEvent`
- `SwapParams`
- `TesseraVDynamicRouteV1Options`
- `TesseraVSwapOptions`
- `TokenSwapOptions`
- `TransferFeeOptions`
- `WhirlpoolsSwapOptions`
- `WhirlpoolsSwapV2Options`
- `ZeroFiSwapOptions`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list dflow-aggregator-v4

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix dflow-aggregator-v4 <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account dflow-aggregator-v4 <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event dflow-aggregator-v4 <EventName>

# shared type fields
python3 "$CARBON" type dflow-aggregator-v4 <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path dflow-aggregator-v4
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-dflow-aggregator-v4-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
