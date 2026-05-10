# SPL Associated Token Account

- **Crate:** `carbon-associated-token-account-decoder`
- **Program ID:** `ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL`
- **Decoder struct:** `SplAssociatedTokenAccountDecoder`
- **Has accounts:** no
- **Has instructions:** yes
- **Has CPI events:** no
- **Discriminator style:** raw byte

## Instructions

### `Create`
- **Discriminator:** `0x00`
- **Args:** (none)
- **Account variants:**
  - `6 accounts:` `funding_address`, `associated_account_address`, `wallet_address`, `token_mint_address`, `system_program`, `token_program`

### `CreateIdempotent`
- **Discriminator:** `0x01`
- **Args:** (none)
- **Account variants:**
  - `6 accounts:` `funding_address`, `associated_account_address`, `wallet_address`, `token_mint_address`, `system_program`, `token_program`

### `RecoverNested`
- **Discriminator:** `0x02`
- **Args:** (none)
- **Account variants:**
  - `7 accounts:` `nested_associated_account_address`, `nested_token_mint_address`, `destination_associated_account_address`, `owner_associated_account_address`, `owner_token_mint_address`, `wallet_address`, `token_program`
