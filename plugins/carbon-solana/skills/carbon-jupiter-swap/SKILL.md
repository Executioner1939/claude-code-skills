---
name: carbon-jupiter-swap
description: "Carbon decoder reference for Jupiter Swap (aggregator) on Solana — program `JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4`, crate `carbon-jupiter-swap-decoder` (17 instructions, 1 account types, 5 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"Jupiter Swap\", \"jupiter-swap\", \"carbon-jupiter-swap-decoder\", \"JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4\", \"JupiterSwapDecoder\", \"Jupiter Swap (aggregator)\", \"Claim\", \"ClaimToken\", \"CloseToken\", \"CpiEvent\", \"CreateTokenAccount\", \"CreateTokenLedger\", \"BestSwapOutAmountViolationEvent\", \"CandidateSwapResultsEvent\", \"FeeEventEvent\", \"SwapEventEvent\", \"TokenLedger\"."
---

# Jupiter Swap

- **Crate:** `carbon-jupiter-swap-decoder`
- **Program ID:** `JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4`
- **Decoder struct:** `JupiterSwapDecoder`
- **Has CPI events:** yes (events/)

## Instructions

- `Claim`
- `ClaimToken`
- `CloseToken`
- `CpiEvent`
- `CreateTokenAccount`
- `CreateTokenLedger`
- `ExactOutRoute`
- `ExactOutRouteV2`
- `Route`
- `RouteV2`
- `RouteWithTokenLedger`
- `SetTokenLedger`
- `SharedAccountsExactOutRoute`
- `SharedAccountsExactOutRouteV2`
- `SharedAccountsRoute`
- `SharedAccountsRouteV2`
- `SharedAccountsRouteWithTokenLedger`

## Account types

- `TokenLedger`

## CPI events

- `BestSwapOutAmountViolationEvent`
- `CandidateSwapResultsEvent`
- `FeeEventEvent`
- `SwapEventEvent`
- `SwapsEventEvent`

## Shared types

- `AccountsType`
- `BestSwapOutAmountViolation`
- `CandidateSwap`
- `CandidateSwapResult`
- `CandidateSwapResults`
- `DefiTunaAccountsType`
- `FeeEvent`
- `RemainingAccountsInfo`
- `RemainingAccountsSlice`
- `RoutePlanStep`
- `RoutePlanStepV2`
- `Side`
- `Swap`
- `SwapEvent`
- `SwapEventV2`
- `SwapsEvent`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list jupiter-swap

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix jupiter-swap <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account jupiter-swap <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event jupiter-swap <EventName>

# shared type fields
python3 "$CARBON" type jupiter-swap <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path jupiter-swap
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-jupiter-swap-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
