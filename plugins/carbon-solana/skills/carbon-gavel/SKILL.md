---
name: carbon-gavel
description: Carbon decoder reference for Gavel on Solana — program `srAMMzfVHVAtgSJc8iH6CfKzuWuUTzLHVCE81QU1rgi`, crate `carbon-gavel-decoder` (10 instructions, 2 account types, 8 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "Gavel", "gavel", "carbon-gavel-decoder", "srAMMzfVHVAtgSJc8iH6CfKzuWuUTzLHVCE81QU1rgi", "GavelDecoder", "AddLiquidity", "InitializeLpPosition", "InitializePool", "Log", "RemoveLiquidity", "RenounceLiquidity", "AddLiquidityEvent", "InitializeLpPositionEvent", "InitializePoolEvent", "RemoveLiquidityEvent", "LpPositionAccount", "PoolAccount".
---

# Gavel

- **Crate:** `carbon-gavel-decoder`
- **Program ID:** `srAMMzfVHVAtgSJc8iH6CfKzuWuUTzLHVCE81QU1rgi`
- **Decoder struct:** `GavelDecoder`
- **Has CPI events:** yes (in types/)

## Instructions

- `AddLiquidity`
- `InitializeLpPosition`
- `InitializePool`
- `Log`
- `RemoveLiquidity`
- `RenounceLiquidity`
- `Swap`
- `TransferLiquidity`
- `WithdrawLpFees`
- `WithdrawProtocolFees`

## Account types

- `LpPositionAccount`
- `PoolAccount`

## CPI events

- `AddLiquidityEvent`
- `InitializeLpPositionEvent`
- `InitializePoolEvent`
- `RemoveLiquidityEvent`
- `RenounceLiquidityEvent`
- `SwapEvent`
- `WithdrawLpFeesEvent`
- `WithdrawProtocolFeesEvent`

## Shared types

- `AddLiquidityIxParams`
- `Amm`
- `InitializePoolIxParams`
- `LpPosition`
- `PendingSharesToVest`
- `PlasmaEvent`
- `PlasmaEventHeader`
- `PoolHeader`
- `ProtocolFeeRecipient`
- `ProtocolFeeRecipientParams`
- `ProtocolFeeRecipients`
- `RemoveLiquidityIxParams`
- `RenounceLiquidityIxParams`
- `Side`
- `SwapIxParams`
- `SwapResult`
- `SwapType`
- `TokenParams`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list gavel

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix gavel <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account gavel <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event gavel <EventName>

# shared type fields
python3 "$CARBON" type gavel <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path gavel
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-gavel-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
