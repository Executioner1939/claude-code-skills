---
name: carbon-raydium-amm-v4
description: "Carbon decoder reference for Raydium AMM v4 (constant product DEX) on Solana — program `675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8`, crate `carbon-raydium-amm-v4-decoder` (18 instructions, 3 account types). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"Raydium AMM v4\", \"raydium-amm-v4\", \"carbon-raydium-amm-v4-decoder\", \"675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8\", \"RaydiumAmmV4Decoder\", \"Raydium AMM v4 (constant product DEX)\", \"AdminCancelOrders\", \"CreateConfigAccount\", \"Deposit\", \"Initialize\", \"Initialize2\", \"MigrateToOpenBook\", \"AmmInfo\", \"Fees\", \"TargetOrders\"."
---

# Raydium AMM v4

- **Crate:** `carbon-raydium-amm-v4-decoder`
- **Program ID:** `675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8`
- **Decoder struct:** `RaydiumAmmV4Decoder`
- **Has CPI events:** no

## Instructions

- `AdminCancelOrders`
- `CreateConfigAccount`
- `Deposit`
- `Initialize`
- `Initialize2`
- `MigrateToOpenBook`
- `MonitorStep`
- `PreInitialize`
- `SetParams`
- `SimulateInfo`
- `SwapBaseIn`
- `SwapBaseInV2`
- `SwapBaseOut`
- `SwapBaseOutV2`
- `UpdateConfigAccount`
- `Withdraw`
- `WithdrawPnl`
- `WithdrawSrm`

## Account types

- `AmmInfo`
- `Fees`
- `TargetOrders`

## Shared types

- `AmmConfig`
- `LastOrderDistance`
- `NeedTake`
- `OutPutData`
- `SwapInstructionBaseIn`
- `SwapInstructionBaseOut`
- `TargetOrder`
- `WithdrawDestToken`
- `WithdrawQueue`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list raydium-amm-v4

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix raydium-amm-v4 <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account raydium-amm-v4 <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event raydium-amm-v4 <EventName>

# shared type fields
python3 "$CARBON" type raydium-amm-v4 <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path raydium-amm-v4
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-raydium-amm-v4-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
