---
name: carbon-meteora-vault
description: Carbon decoder reference for Meteora Vault on Solana — program `24Uqj9JCLxUeoC3hGfh5W3s9FM9uCHDS2SG3LYwBpyTi`, crate `carbon-meteora-vault-decoder` (22 instructions, 2 account types). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "Meteora Vault", "meteora-vault", "carbon-meteora-vault-decoder", "24Uqj9JCLxUeoC3hGfh5W3s9FM9uCHDS2SG3LYwBpyTi", "MeteoraVaultDecoder", "AddLiquidityEvent", "AddStrategy", "ClaimRewardEvent", "CollectDust", "Deposit", "DepositStrategy", "Strategy", "Vault".
---

# Meteora Vault

- **Crate:** `carbon-meteora-vault-decoder`
- **Program ID:** `24Uqj9JCLxUeoC3hGfh5W3s9FM9uCHDS2SG3LYwBpyTi`
- **Decoder struct:** `MeteoraVaultDecoder`
- **Has CPI events:** yes (in instructions/)

## Instructions

- `AddLiquidityEvent`
- `AddStrategy`
- `ClaimRewardEvent`
- `CollectDust`
- `Deposit`
- `DepositStrategy`
- `EnableVault`
- `Initialize`
- `InitializeStrategy`
- `PerformanceFeeEvent`
- `RemoveLiquidityEvent`
- `RemoveStrategy`
- `RemoveStrategy2`
- `ReportLossEvent`
- `SetOperator`
- `StrategyDepositEvent`
- `StrategyWithdrawEvent`
- `TotalAmountEvent`
- `Withdraw`
- `Withdraw2`
- `WithdrawDirectlyFromStrategy`
- `WithdrawStrategy`

## Account types

- `Strategy`
- `Vault`

## Shared types

- `LockedProfitTracker`
- `StrategyBumps`
- `StrategyType`
- `VaultBumps`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list meteora-vault

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix meteora-vault <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account meteora-vault <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event meteora-vault <EventName>

# shared type fields
python3 "$CARBON" type meteora-vault <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path meteora-vault
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-meteora-vault-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
