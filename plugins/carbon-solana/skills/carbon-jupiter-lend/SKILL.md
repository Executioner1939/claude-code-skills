---
name: carbon-jupiter-lend
description: Carbon decoder reference for Jupiter Lend on Solana — program `jupeiUmn818Jg1ekPURTpr4mFo29p46vygyykFJ3wZC`, crate `carbon-jupiter-lend-decoder` (24 instructions, 7 account types, 19 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "Jupiter Lend", "jupiter-lend", "carbon-jupiter-lend-decoder", "jupeiUmn818Jg1ekPURTpr4mFo29p46vygyykFJ3wZC", "LiquidityDecoder", "ChangeStatus", "Claim", "CloseClaimAccount", "CollectRevenue", "InitClaimAccount", "InitLiquidity", "LogBorrowRateCapEvent", "LogChangeStatusEvent", "LogClaimEvent", "LogCollectRevenueEvent", "AuthorizationList", "Liquidity", "RateModel", "TokenReserve".
---

# Jupiter Lend

- **Crate:** `carbon-jupiter-lend-decoder`
- **Program ID:** `jupeiUmn818Jg1ekPURTpr4mFo29p46vygyykFJ3wZC`
- **Decoder struct:** `LiquidityDecoder`
- **Has CPI events:** yes (events/)

## Instructions

- `ChangeStatus`
- `Claim`
- `CloseClaimAccount`
- `CollectRevenue`
- `InitClaimAccount`
- `InitLiquidity`
- `InitNewProtocol`
- `InitTokenReserve`
- `Operate`
- `PauseUser`
- `PreOperate`
- `UnpauseUser`
- `UpdateAuthority`
- `UpdateAuths`
- `UpdateExchangePrice`
- `UpdateGuardians`
- `UpdateRateDataV1`
- `UpdateRateDataV2`
- `UpdateRevenueCollector`
- `UpdateTokenConfig`
- `UpdateUserBorrowConfig`
- `UpdateUserClass`
- `UpdateUserSupplyConfig`
- `UpdateUserWithdrawalLimit`

## Account types

- `AuthorizationList`
- `Liquidity`
- `RateModel`
- `TokenReserve`
- `UserBorrowPosition`
- `UserClaim`
- `UserSupplyPosition`

## CPI events

- `LogBorrowRateCapEvent`
- `LogChangeStatusEvent`
- `LogClaimEvent`
- `LogCollectRevenueEvent`
- `LogOperateEvent`
- `LogPauseUserEvent`
- `LogUnpauseUserEvent`
- `LogUpdateAuthorityEvent`
- `LogUpdateAuthsEvent`
- `LogUpdateExchangePricesEvent`
- `LogUpdateGuardiansEvent`
- `LogUpdateRateDataV1Event`
- `LogUpdateRateDataV2Event`
- `LogUpdateRevenueCollectorEvent`
- `LogUpdateTokenConfigsEvent`
- `LogUpdateUserBorrowConfigsEvent`
- `LogUpdateUserClassEvent`
- `LogUpdateUserSupplyConfigsEvent`
- `LogUpdateUserWithdrawalLimitEvent`

## Shared types

- `AddressBool`
- `AddressU8`
- `RateDataV1Params`
- `RateDataV2Params`
- `TokenConfig`
- `TransferType`
- `UserBorrowConfig`
- `UserClass`
- `UserSupplyConfig`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list jupiter-lend

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix jupiter-lend <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account jupiter-lend <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event jupiter-lend <EventName>

# shared type fields
python3 "$CARBON" type jupiter-lend <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path jupiter-lend
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-jupiter-lend-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
