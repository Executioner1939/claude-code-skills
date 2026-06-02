---
name: carbon-sharky
description: "Carbon decoder reference for Sharky (NFT lending) on Solana — program `SHARKobtfF1bHhxD2eqftjHBdVSCbKo9JtgK71FhELP`, crate `carbon-sharky-decoder` (18 instructions, 5 account types). Use when decoding, indexing, or analyzing this program with Carbon: looking up instruction args/discriminators/accounts, account struct fields, or CPI event schemas. Run the bundled `scripts/carbon.py` to extract details from the local cargo cache. Triggers on \"Sharky\", \"sharky\", \"carbon-sharky-decoder\", \"SHARKobtfF1bHhxD2eqftjHBdVSCbKo9JtgK71FhELP\", \"SharkyDecoder\", \"Sharky (NFT lending)\", \"CloseNftList\", \"CloseOrderBook\", \"CreateNftList\", \"CreateOrderBook\", \"CreateProgramVersion\", \"ExtendLoanV3\", \"EscrowPda\", \"Loan\", \"NftList\", \"OrderBook\"."
---

# Sharky

- **Crate:** `carbon-sharky-decoder`
- **Program ID:** `SHARKobtfF1bHhxD2eqftjHBdVSCbKo9JtgK71FhELP`
- **Decoder struct:** `SharkyDecoder`
- **Has CPI events:** no

## Instructions

- `CloseNftList`
- `CloseOrderBook`
- `CreateNftList`
- `CreateOrderBook`
- `CreateProgramVersion`
- `ExtendLoanV3`
- `ExtendLoanV3Compressed`
- `ForecloseLoanV3`
- `ForecloseLoanV3Compressed`
- `OfferLoan`
- `RepayLoanV3`
- `RepayLoanV3Compressed`
- `RescindLoan`
- `TakeLoanV3`
- `TakeLoanV3Compressed`
- `UpdateNftList`
- `UpdateOrderBook`
- `UpdateProgramVersion`

## Account types

- `EscrowPda`
- `Loan`
- `NftList`
- `OrderBook`
- `ProgramVersion`

## Shared types

- `APY`
- `BookLoanTerms`
- `CnftArgs`
- `LoanOffer`
- `LoanState`
- `LoanTerms`
- `LoanTermsSpec`
- `OrderBookType`
- `TakenLoan`
- `UpdateIndex`

## Pulling full details

The plugin's `scripts/carbon.py` extracts struct fields, discriminators, and
account variants directly from the decoder crate in your cargo registry cache.

```bash
# locate the script (it lives next to this plugin)
CARBON=$(find ~ -path '*/carbon-solana/scripts/carbon.py' -print -quit)

# list everything available for this protocol
python3 "$CARBON" list sharky

# instruction details (args, discriminator, account variants)
python3 "$CARBON" ix sharky <InstructionName>

# account struct fields (and size constant)
python3 "$CARBON" account sharky <AccountName>

# CPI event fields + discriminator
python3 "$CARBON" event sharky <EventName>

# shared type fields
python3 "$CARBON" type sharky <TypeName>

# print the resolved cargo-cache path
python3 "$CARBON" path sharky
```

Requires `ast-grep` and the crate to be present in `~/.cargo/registry/src/`
(any cargo project that depends on `carbon-sharky-decoder` will populate it after a
`cargo build` or `cargo fetch`). If neither is available, run
`cargo install ast-grep` and pull a project that uses Carbon.
