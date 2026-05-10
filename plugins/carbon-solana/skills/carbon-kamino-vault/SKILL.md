---
name: carbon-kamino-vault
description: Carbon decoder reference for Kamino Vault on Solana — program `kvauTFR8qm1dhniz6pYuBZkuene3Hfrs1VQhVRgCNrr`, crate `carbon-kamino-vault-decoder` (12 instructions, 2 account types). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "Kamino Vault", "kamino-vault", "carbon-kamino-vault-decoder", "kvauTFR8qm1dhniz6pYuBZkuene3Hfrs1VQhVRgCNrr", "KaminoVaultDecoder", "Deposit", "GiveUpPendingFees", "InitVault", "InitializeSharesMetadata", "Invest", "UpdateAdmin", "Reserve", "VaultState".
---

# Kamino Vault

- **Crate:** `carbon-kamino-vault-decoder`
- **Program ID:** `kvauTFR8qm1dhniz6pYuBZkuene3Hfrs1VQhVRgCNrr`
- **Decoder struct:** `KaminoVaultDecoder`
- **Has CPI events:** no

## Instructions

- `Deposit`
- `GiveUpPendingFees`
- `InitVault`
- `InitializeSharesMetadata`
- `Invest`
- `UpdateAdmin`
- `UpdateReserveAllocation`
- `UpdateSharesMetadata`
- `UpdateVaultConfig`
- `Withdraw`
- `WithdrawFromAvailable`
- `WithdrawPendingFees`

## Account types

- `Reserve`
- `VaultState`

## Shared types

- `BigFractionBytes`
- `BorrowRateCurve`
- `CurvePoint`
- `LastUpdate`
- `PriceHeuristic`
- `PythConfiguration`
- `ReserveCollateral`
- `ReserveConfig`
- `ReserveFees`
- `ReserveLiquidity`
- `ScopeConfiguration`
- `SwitchboardConfiguration`
- `TokenInfo`
- `VaultAllocation`
- `VaultConfigField`
- `WithdrawalCaps`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list kamino-vault

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix kamino-vault <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account kamino-vault <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event kamino-vault <EventName>

# shared type fields
python3 "$CARBON" type kamino-vault <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path kamino-vault
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-kamino-vault-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
