# System Program

- **Crate:** `carbon-system-program-decoder`
- **Program ID:** `11111111111111111111111111111111`
- **Decoder struct:** `SystemProgramDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** no
- **Discriminator style:** raw (u32 LE)

## Account types

### `Nonce`
- **Discriminator:** `0x216d14bf0b25e522`
- **Fields:**
  - `version`: `NonceVersion`
  - `state`: `NonceState`
  - `authority`: `Pubkey`
  - `blockhash`: `Pubkey`
  - `lamports_per_signature`: `u64`

### `Legacy`
- **Fields:** *(unit struct; matches empty system-owned accounts)*

## Instructions

### `CreateAccount`
- **Discriminator:** `0x00000000` (u32 LE)
- **Args:**
  - `lamports`: `u64`
  - `space`: `u64`
  - `program_address`: `Pubkey`
- **Account variants:**
  - `2 accounts:` `payer, new_account`

### `Assign`
- **Discriminator:** `0x01000000` (u32 LE)
- **Args:**
  - `program_address`: `Pubkey`
- **Account variants:**
  - `1 accounts:` `account`

### `TransferSol`
- **Discriminator:** `0x02000000` (u32 LE)
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `2 accounts:` `source, destination`

### `CreateAccountWithSeed`
- **Discriminator:** `0x03000000` (u32 LE)
- **Args:**
  - `base`: `Pubkey`
  - `seed`: `U64PrefixString`
  - `amount`: `u64`
  - `space`: `u64`
  - `program_address`: `Pubkey`
- **Account variants:**
  - `3 accounts:` `payer, new_account, base_account`

### `AdvanceNonceAccount`
- **Discriminator:** `0x04000000` (u32 LE)
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `nonce_account, recent_blockhashes_sysvar, nonce_authority`

### `WithdrawNonceAccount`
- **Discriminator:** `0x05000000` (u32 LE)
- **Args:**
  - `withdraw_amount`: `u64`
- **Account variants:**
  - `5 accounts:` `nonce_account, recipient_account, recent_blockhashes_sysvar, rent_sysvar, nonce_authority`

### `InitializeNonceAccount`
- **Discriminator:** `0x06000000` (u32 LE)
- **Args:**
  - `nonce_authority`: `Pubkey`
- **Account variants:**
  - `3 accounts:` `nonce_account, recent_blockhashes_sysvar, rent_sysvar`

### `AuthorizeNonceAccount`
- **Discriminator:** `0x07000000` (u32 LE)
- **Args:**
  - `new_nonce_authority`: `Pubkey`
- **Account variants:**
  - `2 accounts:` `nonce_account, nonce_authority`

### `Allocate`
- **Discriminator:** `0x08000000` (u32 LE)
- **Args:**
  - `space`: `u64`
- **Account variants:**
  - `1 accounts:` `new_account`

### `AllocateWithSeed`
- **Discriminator:** `0x09000000` (u32 LE)
- **Args:**
  - `base`: `Pubkey`
  - `seed`: `U64PrefixString`
  - `space`: `u64`
  - `program_address`: `Pubkey`
- **Account variants:**
  - `2 accounts:` `new_account, base_account`

### `AssignWithSeed`
- **Discriminator:** `0x0a000000` (u32 LE)
- **Args:**
  - `base`: `Pubkey`
  - `seed`: `U64PrefixString`
  - `program_address`: `Pubkey`
- **Account variants:**
  - `2 accounts:` `account, base_account`

### `TransferSolWithSeed`
- **Discriminator:** `0x0b000000` (u32 LE)
- **Args:**
  - `amount`: `u64`
  - `from_seed`: `U64PrefixString`
  - `from_owner`: `Pubkey`
- **Account variants:**
  - `3 accounts:` `source, base_account, destination`

### `UpgradeNonceAccount`
- **Discriminator:** `0x0c000000` (u32 LE)
- **Args:** (none)
- **Account variants:**
  - `1 accounts:` `nonce_account`

## Shared types

### `NonceVersion`
- enum: `Legacy`, `Current`

### `NonceState`
- enum: `Uninitialized`, `Initialized`
