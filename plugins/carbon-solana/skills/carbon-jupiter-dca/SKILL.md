---
name: carbon-jupiter-dca
description: "Carbon decoder reference for Jupiter DCA (dollar-cost averaging) on Solana — program `DCA265Vj8a9CEuX1eb1LWRnDT7uK6q1xMipnNyatn23M`, crate `carbon-jupiter-dca-decoder` (12 instructions, 1 account types, 6 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"Jupiter DCA\", \"jupiter-dca\", \"carbon-jupiter-dca-decoder\", \"DCA265Vj8a9CEuX1eb1LWRnDT7uK6q1xMipnNyatn23M\", \"JupiterDcaDecoder\", \"Jupiter DCA (dollar-cost averaging)\", \"CloseDca\", \"Deposit\", \"EndAndClose\", \"FulfillDlmmFill\", \"FulfillFlashFill\", \"InitiateDlmmFill\", \"ClosedEvent\", \"CollectedFeeEvent\", \"DepositEvent\", \"FilledEvent\", \"Dca\"."
---

# Jupiter DCA

- **Crate:** `carbon-jupiter-dca-decoder`
- **Program ID:** `DCA265Vj8a9CEuX1eb1LWRnDT7uK6q1xMipnNyatn23M`
- **Decoder struct:** `JupiterDcaDecoder`
- **Has CPI events:** yes (in instructions/)

## Instructions

- `CloseDca`
- `Deposit`
- `EndAndClose`
- `FulfillDlmmFill`
- `FulfillFlashFill`
- `InitiateDlmmFill`
- `InitiateFlashFill`
- `OpenDca`
- `OpenDcaV2`
- `Transfer`
- `Withdraw`
- `WithdrawFees`

## Account types

- `Dca`

## CPI events

- `ClosedEvent`
- `CollectedFeeEvent`
- `DepositEvent`
- `FilledEvent`
- `OpenedEvent`
- `WithdrawEvent`

## Shared types

- `WithdrawParams`
- `Withdrawal`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list jupiter-dca

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix jupiter-dca <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account jupiter-dca <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event jupiter-dca <EventName>

# shared type fields
python3 "$CARBON" type jupiter-dca <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path jupiter-dca
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-jupiter-dca-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
