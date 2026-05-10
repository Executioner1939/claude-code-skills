# Sharky

- **Crate:** `carbon-sharky-decoder`
- **Program ID:** `SHARKobtfF1bHhxD2eqftjHBdVSCbKo9JtgK71FhELP`
- **Decoder struct:** `SharkyDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** no
- **Discriminator style:** anchor 8-byte

## Account types

### `EscrowPda`
- **Fields:**
  - `bump`: `u8`

### `Loan`
- **Fields:**
  - `version`: `u8`
  - `principal_lamports`: `u64`
  - `order_book`: `Pubkey`
  - `value_token_mint`: `Pubkey`
  - `escrow_bump_seed`: `u8`
  - `loan_state`: `LoanState`

### `NftList`
- **Fields:**
  - `version`: `u8`
  - `collection_name`: `String`

### `OrderBook`
- **Fields:**
  - `version`: `u8`
  - `order_book_type`: `OrderBookType`
  - `apy`: `APY`
  - `loan_terms`: `BookLoanTerms`
  - `fee_permillicentage`: `u16`
  - `fee_authority`: `Pubkey`

### `ProgramVersion`
- **Fields:**
  - `version`: `u8`
  - `bump`: `u8`
  - `updated`: `i64`

## Instructions

### `CloseNftList`
- **Discriminator:** `0x23087952da4efca2`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `nft_list`, `payer`
- **Remaining accounts:** yes

### `CloseOrderBook`
- **Discriminator:** `0xdb8649dbb4075ece`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `order_book`, `payer`
- **Remaining accounts:** yes

### `CreateNftList`
- **Discriminator:** `0xf326c64cac407f18`
- **Args:**
  - `collection_name`: `String`
- **Account variants:**
  - `2 accounts:` `nft_list`, `payer`
- **Remaining accounts:** yes

### `CreateOrderBook`
- **Discriminator:** `0x997209336444f0c5`
- **Args:**
  - `order_book_type`: `OrderBookType`
  - `apy`: `APY`
  - `loan_terms`: `BookLoanTerms`
  - `fee_permillicentage`: `u16`
  - `fee_authority`: `Pubkey`
- **Account variants:**
  - `3 accounts:` `order_book`, `payer`, `system_program`
- **Remaining accounts:** yes

### `CreateProgramVersion`
- **Discriminator:** `0x67d800ee5c6bdb79`
- **Args:**
  - `version`: `u8`
- **Account variants:**
  - `4 accounts:` `authority`, `program_version`, `system_program`, `rent`
- **Remaining accounts:** yes

### `ExtendLoanV3`
- **Discriminator:** `0x471b11834e493e5c`
- **Args:**
  - `expected_loan`: `String`
- **Account variants:**
  - `21 accounts:` `loan`, `new_loan`, `borrower`, `borrower_collateral_token_account`, `lender`, `new_lender`, `escrow`, `escrow_collateral_token_account`, `new_escrow`, `new_escrow_collateral_token_account`, `value_mint`, `collateral_mint`, `order_book`, `fee_authority`, `metadata`, `edition`, `system_program`, `token_program`, `associated_token_program`, `rent`, `mpl_token_metadata_program`
- **Remaining accounts:** yes

### `ExtendLoanV3Compressed`
- **Discriminator:** `0x94a14b578a22833e`
- **Args:**
  - `expected_loan`: `String`
  - `cnft_root`: `[u8; 32]`
  - `cnft_data_hash`: `[u8; 32]`
  - `cnft_creator_hash`: `[u8; 32]`
  - `cnft_nonce`: `u64`
  - `cnft_index`: `u32`
- **Account variants:**
  - `18 accounts:` `loan`, `new_loan`, `borrower`, `lender`, `new_lender`, `escrow`, `new_escrow`, `value_mint`, `order_book`, `fee_authority`, `tree_authority`, `log_wrapper`, `merkle_tree`, `system_program`, `token_program`, `mpl_bubblegum_program`, `compression_program`, `rent`
- **Remaining accounts:** yes

### `ForecloseLoanV3`
- **Discriminator:** `0x88b8323ab75c3fd8`
- **Args:** (none)
- **Account variants:**
  - `15 accounts:` `loan`, `escrow`, `escrow_collateral_token_account`, `collateral_mint`, `borrower`, `lender`, `lender_collateral_token_account`, `borrower_collateral_token_account`, `metadata`, `edition`, `system_program`, `token_program`, `associated_token_program`, `rent`, `mpl_token_metadata_program`
- **Remaining accounts:** yes

### `ForecloseLoanV3Compressed`
- **Discriminator:** `0xc2c105c17385e7c5`
- **Args:**
  - `cnft_root`: `[u8; 32]`
  - `cnft_data_hash`: `[u8; 32]`
  - `cnft_creator_hash`: `[u8; 32]`
  - `cnft_nonce`: `u64`
  - `cnft_index`: `u32`
- **Account variants:**
  - `12 accounts:` `loan`, `escrow`, `borrower`, `lender`, `tree_authority`, `log_wrapper`, `merkle_tree`, `system_program`, `token_program`, `mpl_bubblegum_program`, `compression_program`, `rent`
- **Remaining accounts:** yes

### `OfferLoan`
- **Discriminator:** `0x2c0c4c90d2d0ef55`
- **Args:**
  - `escrow_bump`: `u8`
  - `principal_lamports`: `u64`
  - `terms_choice`: `Option<LoanTermsSpec>`
- **Account variants:**
  - `11 accounts:` `lender`, `lender_value_token_account`, `value_mint`, `loan`, `escrow`, `escrow_token_account`, `order_book`, `system_program`, `token_program`, `associated_token_program`, `rent`
- **Remaining accounts:** yes

### `RepayLoanV3`
- **Discriminator:** `0x617b55364c103d9d`
- **Args:** (none)
- **Account variants:**
  - `17 accounts:` `loan`, `borrower`, `borrower_collateral_token_account`, `lender`, `escrow`, `escrow_collateral_token_account`, `value_mint`, `collateral_mint`, `order_book`, `fee_authority`, `metadata`, `edition`, `system_program`, `token_program`, `associated_token_program`, `rent`, `mpl_token_metadata_program`
- **Remaining accounts:** yes

### `RepayLoanV3Compressed`
- **Discriminator:** `0x9f9ff5a8bf9a6406`
- **Args:**
  - `cnft_root`: `[u8; 32]`
  - `cnft_data_hash`: `[u8; 32]`
  - `cnft_creator_hash`: `[u8; 32]`
  - `cnft_nonce`: `u64`
  - `cnft_index`: `u32`
- **Account variants:**
  - `15 accounts:` `loan`, `borrower`, `lender`, `escrow`, `value_mint`, `order_book`, `fee_authority`, `tree_authority`, `log_wrapper`, `merkle_tree`, `system_program`, `token_program`, `mpl_bubblegum_program`, `compression_program`, `rent`
- **Remaining accounts:** yes

### `RescindLoan`
- **Discriminator:** `0x4040a0d33324b19e`
- **Args:** (none)
- **Account variants:**
  - `8 accounts:` `loan`, `lender_value_token_account`, `lender`, `value_mint`, `escrow`, `escrow_token_account`, `system_program`, `token_program`
- **Remaining accounts:** yes

### `TakeLoanV3`
- **Discriminator:** `0xff73dc3a1a9d70b9`
- **Args:**
  - `expected_loan`: `String`
  - `nft_list_index`: `Option<u32>`
  - `skip_freezing_collateral`: `bool`
- **Account variants:**
  - `15 accounts:` `lender`, `borrower`, `borrower_collateral_token_account`, `collateral_mint`, `loan`, `escrow`, `escrow_collateral_token_account`, `order_book`, `metadata`, `edition`, `system_program`, `token_program`, `associated_token_program`, `rent`, `mpl_token_metadata_program`
- **Remaining accounts:** yes

### `TakeLoanV3Compressed`
- **Discriminator:** `0xf1726a4f1059e97d`
- **Args:**
  - `expected_loan`: `String`
  - `nft_list_index`: `Option<u32>`
  - `cnft_args`: `CnftArgs`
- **Account variants:**
  - `14 accounts:` `lender`, `borrower`, `loan`, `escrow`, `order_book`, `collateral_mint`, `tree_authority`, `log_wrapper`, `merkle_tree`, `system_program`, `token_program`, `mpl_bubblegum_program`, `compression_program`, `rent`
- **Remaining accounts:** yes

### `UpdateNftList`
- **Discriminator:** `0xd70d19bb0b5d228f`
- **Args:**
  - `mints`: `Vec<UpdateIndex>`
- **Account variants:**
  - `2 accounts:` `nft_list`, `payer`
- **Remaining accounts:** yes

### `UpdateOrderBook`
- **Discriminator:** `0x1f489fe8dc995a6d`
- **Args:**
  - `order_book_type`: `Option<OrderBookType>`
  - `apy`: `Option<APY>`
  - `loan_terms`: `Option<BookLoanTerms>`
  - `fee_permillicentage`: `Option<u16>`
  - `fee_authority`: `Option<Pubkey>`
- **Account variants:**
  - `2 accounts:` `order_book`, `payer`
- **Remaining accounts:** yes

### `UpdateProgramVersion`
- **Discriminator:** `0xeb84d7e1d52b2b26`
- **Args:**
  - `version`: `u8`
- **Account variants:**
  - `2 accounts:` `authority`, `program_version`
- **Remaining accounts:** yes

## Shared types

### `APY`
- enum variants: `Fixed { apy: u32 }`

### `BookLoanTerms`
- enum variants: `Fixed { terms: LoanTermsSpec }`, `LenderChooses`

### `CnftArgs`
- `cnft_root`: `[u8; 32]`
- `cnft_data_hash`: `[u8; 32]`
- `cnft_creator_hash`: `[u8; 32]`
- `cnft_nonce`: `u64`
- `cnft_index`: `u32`

### `LoanOffer`
- `lender_wallet`: `Pubkey`
- `terms_spec`: `LoanTermsSpec`
- `offer_time`: `i64`

### `LoanState`
- enum variants: `Offer { offer: LoanOffer }`, `Taken { taken: TakenLoan }`

### `LoanTerms`
- enum variants: `Time { start: i64, duration: u64, total_owed_lamports: u64 }`

### `LoanTermsSpec`
- enum variants: `Time { duration: u64 }`

### `OrderBookType`
- enum variants: `Collection { collection_key: Pubkey }`, `NFTList { list_account: Pubkey }`

### `TakenLoan`
- `nft_collateral_mint`: `Pubkey`
- `lender_note_mint`: `Pubkey`
- `borrower_note_mint`: `Pubkey`
- `apy`: `APY`
- `terms`: `LoanTerms`
- `is_collateral_frozen`: `u8`

### `UpdateIndex`
- `index`: `u32`
- `mint`: `Pubkey`
