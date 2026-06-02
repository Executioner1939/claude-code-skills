---
name: carbon-wavebreak
description: "Carbon decoder reference for Wavebreak on Solana — program `waveQX2yP3H1pVU8djGvEHmYg8uamQ84AuyGtpsrXTF`, crate `carbon-wavebreak-decoder` (34 instructions, 5 account types, 6 CPI events). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"Wavebreak\", \"wavebreak\", \"carbon-wavebreak-decoder\", \"waveQX2yP3H1pVU8djGvEHmYg8uamQ84AuyGtpsrXTF\", \"WavebreakDecoder\", \"PermissionConsumeTopLevel\", \"PermissionConsumeCpi\", \"PermissionConfigInitialize\", \"PermissionConfigUpdate\", \"PermissionConfigClose\", \"PermissionRevoke\", \"Event::BondingCurveCreated\", \"Event::TokenBought\", \"Event::TokenSold\", \"Event::TokenRefunded\", \"BondingCurve\", \"AuthorityConfig\", \"PermissionConfig\", \"ConsumedPermission\"."
---

# Wavebreak

- **Crate:** `carbon-wavebreak-decoder`
- **Program ID:** `waveQX2yP3H1pVU8djGvEHmYg8uamQ84AuyGtpsrXTF`
- **Decoder struct:** `WavebreakDecoder`
- **Has CPI events:** yes (in types/, single `Event` enum)

## Instructions

- `PermissionConsumeTopLevel`
- `PermissionConsumeCpi`
- `PermissionConfigInitialize`
- `PermissionConfigUpdate`
- `PermissionConfigClose`
- `PermissionRevoke`
- `PermissionRefund`
- `ReservedPermissionA`
- `TokenBuyExactIn`
- `TokenBuyExactOut`
- `TokenSellExactIn`
- `TokenSellExactOut`
- `TokenRefund`
- `ReservedTokenY`
- `AuthorityConfigInitialize`
- `AuthorityConfigGrant`
- `AuthorityConfigRevoke`
- `ReservedAuthorityConfigY`
- `MintConfigInitialize`
- `MintConfigClose`
- `MintConfigUpdate`
- `ReservedMintConfigY`
- `GraduateWhirlpool`
- `GraduateManual`
- `ReservedGraduateX`
- `CreateLockedlaunch`
- `CreateLaunch`
- `CreatePresale`
- `ReservedCreateY`
- `BondingCurveInitialize`
- `BondingCurveCollectFees`
- `BondingCurveGraduate`
- `BondingCurveClose`
- `ReservedBondingCurveX`

## Account types

- `BondingCurve`
- `AuthorityConfig`
- `PermissionConfig`
- `ConsumedPermission`
- `MintConfig`

## CPI events

- `Event::BondingCurveCreated`
- `Event::TokenBought`
- `Event::TokenSold`
- `Event::TokenRefunded`
- `Event::BondingCurveGraduated`
- `Event::BondingCurveClosed`

## Shared types

- `AccountDiscriminator`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list wavebreak

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix wavebreak <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account wavebreak <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event wavebreak <EventName>

# shared type fields
python3 "$CARBON" type wavebreak <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path wavebreak
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-wavebreak-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
