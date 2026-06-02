---
name: carbon-stabble-stable-swap
description: "Carbon decoder reference for Stabble Stable Swap on Solana — program `swapNyd8XiQwJ6ianp9snpu4brUqFxadzvHebnAXjJZ`, crate `carbon-stabble-stable-swap-decoder` (17 instructions, 3 account types, 2 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"Stabble Stable Swap\", \"stabble-stable-swap\", \"carbon-stabble-stable-swap-decoder\", \"swapNyd8XiQwJ6ianp9snpu4brUqFxadzvHebnAXjJZ\", \"StableSwapDecoder\", \"AcceptOwner\", \"ApproveStrategy\", \"ChangeAmpFactor\", \"ChangeMaxSupply\", \"ChangeSwapFee\", \"CreateStrategy\", \"PoolBalanceUpdatedEvent\", \"PoolUpdatedEvent\", \"Pool\", \"Strategy\", \"Vault\"."
---

# Stabble Stable Swap

- **Crate:** `carbon-stabble-stable-swap-decoder`
- **Program ID:** `swapNyd8XiQwJ6ianp9snpu4brUqFxadzvHebnAXjJZ`
- **Decoder struct:** `StableSwapDecoder`
- **Has CPI events:** yes (in instructions/)

## Instructions

- `AcceptOwner`
- `ApproveStrategy`
- `ChangeAmpFactor`
- `ChangeMaxSupply`
- `ChangeSwapFee`
- `CreateStrategy`
- `Deposit`
- `ExecStrategy`
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
- `Strategy`
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
- `Strategy`
- `Vault`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list stabble-stable-swap

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix stabble-stable-swap <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account stabble-stable-swap <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event stabble-stable-swap <EventName>

# shared type fields
python3 "$CARBON" type stabble-stable-swap <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path stabble-stable-swap
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-stabble-stable-swap-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
