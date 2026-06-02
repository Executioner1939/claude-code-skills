---
name: carbon-stake-program
description: "Carbon decoder reference for Solana Stake Program on Solana — program `Stake11111111111111111111111111111111111111`, crate `carbon-stake-program-decoder` (15 instructions). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"Stake Program\", \"stake-program\", \"carbon-stake-program-decoder\", \"Stake11111111111111111111111111111111111111\", \"StakeProgramDecoder\", \"Solana Stake Program\", \"Authorize\", \"AuthorizeChecked\", \"AuthorizeCheckedWithSeed\", \"AuthorizeWithSeed\", \"Deactivate\", \"DeactivateDelinquent\"."
---

# Stake Program

- **Crate:** `carbon-stake-program-decoder`
- **Program ID:** `Stake11111111111111111111111111111111111111`
- **Decoder struct:** `StakeProgramDecoder`
- **Has CPI events:** no

## Instructions

- `Authorize`
- `AuthorizeChecked`
- `AuthorizeCheckedWithSeed`
- `AuthorizeWithSeed`
- `Deactivate`
- `DeactivateDelinquent`
- `DelegateStake`
- `GetMinimumDelegation`
- `Initialize`
- `InitializeChecked`
- `Merge`
- `SetLockup`
- `SetLockupChecked`
- `Split`
- `Withdraw`

## Shared types

- `Authorized`
- `Lockup`
- `StakeAuthorize`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list stake-program

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix stake-program <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account stake-program <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event stake-program <EventName>

# shared type fields
python3 "$CARBON" type stake-program <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path stake-program
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-stake-program-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
