---
name: carbon-meteora-pools
description: Carbon decoder reference for Meteora Pools on Solana — program `Eo7WjKq67rjJQSZxS6z3YkapzY3eMj6Xy8X5EQVn5UaB`, crate `carbon-meteora-pools-decoder` (44 instructions, 3 account types). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "Meteora Pools", "meteora-pools", "carbon-meteora-pools-decoder", "Eo7WjKq67rjJQSZxS6z3YkapzY3eMj6Xy8X5EQVn5UaB", "MeteoraPoolsDecoder", "AddBalanceLiquidity", "AddImbalanceLiquidity", "AddLiquidityEvent", "BootstrapLiquidity", "BootstrapLiquidityEvent", "ClaimFee", "Config", "LockEscrow", "Pool".
---

# Meteora Pools

- **Crate:** `carbon-meteora-pools-decoder`
- **Program ID:** `Eo7WjKq67rjJQSZxS6z3YkapzY3eMj6Xy8X5EQVn5UaB`
- **Decoder struct:** `MeteoraPoolsDecoder`
- **Has CPI events:** yes (in instructions/)

## Instructions

- `AddBalanceLiquidity`
- `AddImbalanceLiquidity`
- `AddLiquidityEvent`
- `BootstrapLiquidity`
- `BootstrapLiquidityEvent`
- `ClaimFee`
- `ClaimFeeEvent`
- `CloseConfig`
- `CloseConfigEvent`
- `CreateConfig`
- `CreateConfigEvent`
- `CreateLockEscrow`
- `CreateLockEscrowEvent`
- `CreateMintMetadata`
- `EnableOrDisablePool`
- `GetPoolInfo`
- `InitializeCustomizablePermissionlessConstantProductPool`
- `InitializePermissionedPool`
- `InitializePermissionlessConstantProductPoolWithConfig`
- `InitializePermissionlessConstantProductPoolWithConfig2`
- `InitializePermissionlessPool`
- `InitializePermissionlessPoolWithFeeTier`
- `Lock`
- `LockEvent`
- `MigrateFeeAccountEvent`
- `OverrideCurveParam`
- `OverrideCurveParamEvent`
- `PartnerClaimFee`
- `PartnerClaimFeesEvent`
- `PoolCreatedEvent`
- `PoolEnabledEvent`
- `PoolInfoEvent`
- `RemoveBalanceLiquidity`
- `RemoveLiquidityEvent`
- `RemoveLiquiditySingleSide`
- `SetPoolFees`
- `SetPoolFeesEvent`
- `SetWhitelistedVault`
- `Swap`
- `SwapEvent`
- `TransferAdminEvent`
- `UpdateActivationPoint`
- `WithdrawProtocolFees`
- `WithdrawProtocolFeesEvent`

## Account types

- `Config`
- `LockEscrow`
- `Pool`

## Shared types

- `ActivationType`
- `Bootstrapping`
- `ConfigParameters`
- `CurveType`
- `CustomizableParams`
- `Depeg`
- `DepegType`
- `NewCurveType`
- `Padding`
- `PartnerInfo`
- `PoolFees`
- `PoolType`
- `RoundDirection`
- `Rounding`
- `TokenMultiplier`
- `TradeDirection`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list meteora-pools

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix meteora-pools <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account meteora-pools <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event meteora-pools <EventName>

# shared type fields
python3 "$CARBON" type meteora-pools <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path meteora-pools
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-meteora-pools-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
