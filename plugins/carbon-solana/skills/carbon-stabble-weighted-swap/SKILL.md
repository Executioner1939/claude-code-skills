---
name: carbon-stabble-weighted-swap
description: Carbon decoder reference for Stabble Weighted Swap on Solana — program `swapFpHZwjELNnjvThjajtiVmkz3yPQEHjLtka2fwHW`, crate `carbon-stabble-weighted-swap-decoder` (13 instructions, 2 account types, 2 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "Stabble Weighted Swap", "stabble-weighted-swap", "carbon-stabble-weighted-swap-decoder", "swapFpHZwjELNnjvThjajtiVmkz3yPQEHjLtka2fwHW", "WeightedSwapDecoder", "AcceptOwner", "ChangeMaxSupply", "ChangeSwapFee", "Deposit", "Initialize", "Pause", "PoolBalanceUpdatedEvent", "PoolUpdatedEvent", "Pool", "Vault".
---

# Stabble Weighted Swap

- **Crate:** `carbon-stabble-weighted-swap-decoder`
- **Program ID:** `swapFpHZwjELNnjvThjajtiVmkz3yPQEHjLtka2fwHW`
- **Decoder struct:** `WeightedSwapDecoder`
- **Has CPI events:** yes (in instructions/)

## Instructions

- `AcceptOwner`
- `ChangeMaxSupply`
- `ChangeSwapFee`
- `Deposit`
- `Initialize`
- `Pause`
- `RejectOwner`
- `Shutdown`
- `Swap`
- `SwapV2`
- `TransferOwner`
- `Unpause`
- `Withdraw`

## Account types

- `Pool`
- `Vault`

## CPI events

- `PoolBalanceUpdatedEvent`
- `PoolUpdatedEvent`

## Shared types

- `Pool`
- `PoolBalanceUpdatedData`
- `PoolBalanceUpdatedEvent`
- `PoolToken`
- `PoolUpdatedData`
- `PoolUpdatedEvent`
- `Vault`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list stabble-weighted-swap

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix stabble-weighted-swap <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account stabble-weighted-swap <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event stabble-weighted-swap <EventName>

# shared type fields
python3 "$CARBON" type stabble-weighted-swap <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path stabble-weighted-swap
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-stabble-weighted-swap-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
