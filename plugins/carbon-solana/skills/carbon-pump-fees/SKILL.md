---
name: carbon-pump-fees
description: Carbon decoder reference for Pumpfun fee distribution on Solana — program `pfeeUxB6jkeY1Hxd7CsFCAjcbHA9rWtchMGdZ6VojVZ`, crate `carbon-pump-fees-decoder` (18 instructions, 7 account types, 16 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on "Pump Fees", "pump-fees", "carbon-pump-fees-decoder", "pfeeUxB6jkeY1Hxd7CsFCAjcbHA9rWtchMGdZ6VojVZ", "PumpFeesDecoder", "Pumpfun fee distribution", "ClaimSocialFeePda", "CpiEvent", "CreateFeeSharingConfig", "CreateSocialFeePda", "GetFees", "InitializeFeeConfig", "CreateFeeSharingConfigEventEvent", "InitializeFeeConfigEventEvent", "InitializeFeeProgramGlobalEventEvent", "ResetFeeSharingConfigEventEvent", "BondingCurve", "FeeConfig", "FeeProgramGlobal", "Global".
---

# Pump Fees

- **Crate:** `carbon-pump-fees-decoder`
- **Program ID:** `pfeeUxB6jkeY1Hxd7CsFCAjcbHA9rWtchMGdZ6VojVZ`
- **Decoder struct:** `PumpFeesDecoder`
- **Has CPI events:** yes (events/)

## Instructions

- `ClaimSocialFeePda`
- `CpiEvent`
- `CreateFeeSharingConfig`
- `CreateSocialFeePda`
- `GetFees`
- `InitializeFeeConfig`
- `InitializeFeeProgramGlobal`
- `ResetFeeSharingConfig`
- `RevokeFeeSharingAuthority`
- `SetAuthority`
- `SetClaimRateLimit`
- `SetDisableFlags`
- `SetSocialClaimAuthority`
- `TransferFeeSharingAuthority`
- `UpdateAdmin`
- `UpdateFeeConfig`
- `UpdateFeeShares`
- `UpsertFeeTiers`

## Account types

- `BondingCurve`
- `FeeConfig`
- `FeeProgramGlobal`
- `Global`
- `Pool`
- `SharingConfig`
- `SocialFeePda`

## CPI events

- `CreateFeeSharingConfigEventEvent`
- `InitializeFeeConfigEventEvent`
- `InitializeFeeProgramGlobalEventEvent`
- `ResetFeeSharingConfigEventEvent`
- `RevokeFeeSharingAuthorityEventEvent`
- `SetAuthorityEventEvent`
- `SetClaimRateLimitEventEvent`
- `SetDisableFlagsEventEvent`
- `SetSocialClaimAuthorityEventEvent`
- `SocialFeePdaClaimedEvent`
- `SocialFeePdaCreatedEvent`
- `TransferFeeSharingAuthorityEventEvent`
- `UpdateAdminEventEvent`
- `UpdateFeeConfigEventEvent`
- `UpdateFeeSharesEventEvent`
- `UpsertFeeTiersEventEvent`

## Shared types

- `ConfigStatus`
- `CreateFeeSharingConfigEvent`
- `FeeTier`
- `Fees`
- `InitializeFeeConfigEvent`
- `InitializeFeeProgramGlobalEvent`
- `ResetFeeSharingConfigEvent`
- `RevokeFeeSharingAuthorityEvent`
- `SetAuthorityEvent`
- `SetClaimRateLimitEvent`
- `SetDisableFlagsEvent`
- `SetSocialClaimAuthorityEvent`
- `Shareholder`
- `SocialFeePdaClaimed`
- `SocialFeePdaCreated`
- `TransferFeeSharingAuthorityEvent`
- `UpdateAdminEvent`
- `UpdateFeeConfigEvent`
- `UpdateFeeSharesEvent`
- `UpsertFeeTiersEvent`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list pump-fees

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix pump-fees <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account pump-fees <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event pump-fees <EventName>

# shared type fields
python3 "$CARBON" type pump-fees <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path pump-fees
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-pump-fees-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
