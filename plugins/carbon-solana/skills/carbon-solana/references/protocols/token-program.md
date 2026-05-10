# SPL Token Program

- **Crate:** `carbon-token-program-decoder`
- **Program ID:** `TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA`
- **Decoder struct:** `TokenProgramDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** no
- **Discriminator style:** raw byte

## Account types

Wraps `spl_token_interface::state::*` via SPL `Pack` (no Carbon discriminators):

### `Account`
- spl-token token account state.

### `Mint`
- spl-token mint state.

### `Multisig`
- spl-token multisig state.

## Instructions

### `InitializeMint`
- **Discriminator:** `0x00`
- **Args:**
  - `decimals`: `u8`
  - `mint_authority`: `Pubkey`
  - `freeze_authority`: `Option<Pubkey>`
- **Account variants:**
  - `2 accounts:` `mint, rent`

### `InitializeAccount`
- **Discriminator:** `0x01`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `account, mint, owner`

### `InitializeMultisig`
- **Discriminator:** `0x02`
- **Args:**
  - `m`: `u8`
- **Account variants:**
  - `2 accounts:` `account, rent`
- **Remaining accounts:** yes

### `Transfer`
- **Discriminator:** `0x03`
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `3 accounts:` `source, destination, authority`
- **Remaining accounts:** yes

### `Approve`
- **Discriminator:** `0x04`
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `3 accounts:` `source, delegate, owner`
- **Remaining accounts:** yes

### `Revoke`
- **Discriminator:** `0x05`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `source, owner`
- **Remaining accounts:** yes

### `SetAuthority`
- **Discriminator:** `0x06`
- **Args:**
  - `authority_type`: `AuthorityType`
  - `new_authority`: `Option<Pubkey>`
- **Account variants:**
  - `2 accounts:` `account, authority`
- **Remaining accounts:** yes

### `MintTo`
- **Discriminator:** `0x07`
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `3 accounts:` `mint, account, authority`
- **Remaining accounts:** yes

### `Burn`
- **Discriminator:** `0x08`
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `3 accounts:` `account, mint, owner`
- **Remaining accounts:** yes

### `CloseAccount`
- **Discriminator:** `0x09`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `account, destination, owner`
- **Remaining accounts:** yes

### `FreezeAccount`
- **Discriminator:** `0x0a`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `account, mint, authority`
- **Remaining accounts:** yes

### `ThawAccount`
- **Discriminator:** `0x0b`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `account, mint, authority`
- **Remaining accounts:** yes

### `TransferChecked`
- **Discriminator:** `0x0c`
- **Args:**
  - `amount`: `u64`
  - `decimals`: `u8`
- **Account variants:**
  - `4 accounts:` `source, mint, destination, authority`
- **Remaining accounts:** yes

### `ApproveChecked`
- **Discriminator:** `0x0d`
- **Args:**
  - `amount`: `u64`
  - `decimals`: `u8`
- **Account variants:**
  - `4 accounts:` `source, mint, delegate, owner`
- **Remaining accounts:** yes

### `MintToChecked`
- **Discriminator:** `0x0e`
- **Args:**
  - `amount`: `u64`
  - `decimals`: `u8`
- **Account variants:**
  - `3 accounts:` `mint, account, authority`
- **Remaining accounts:** yes

### `BurnChecked`
- **Discriminator:** `0x0f`
- **Args:**
  - `amount`: `u64`
  - `decimals`: `u8`
- **Account variants:**
  - `3 accounts:` `account, mint, owner`
- **Remaining accounts:** yes

### `InitializeAccount2`
- **Discriminator:** `0x10`
- **Args:**
  - `owner`: `Pubkey`
- **Account variants:**
  - `2 accounts:` `account, mint`

### `SyncNative`
- **Discriminator:** `0x11`
- **Args:** (none)
- **Account variants:**
  - `1 accounts:` `account`

### `InitializeAccount3`
- **Discriminator:** `0x12`
- **Args:**
  - `owner`: `Pubkey`
- **Account variants:**
  - `2 accounts:` `account, mint`

### `InitializeMultisig2`
- **Discriminator:** `0x13`
- **Args:**
  - `m`: `u8`
- **Account variants:**
  - `1 accounts:` `account`
- **Remaining accounts:** yes

### `InitializeMint2`
- **Discriminator:** `0x14`
- **Args:**
  - `decimals`: `u8`
  - `mint_authority`: `Pubkey`
  - `freeze_authority`: `Option<Pubkey>`
- **Account variants:**
  - `1 accounts:` `mint`

### `GetAccountDataSize`
- **Discriminator:** `0x15`
- **Args:** (none)
- **Account variants:**
  - `1 accounts:` `mint`

### `InitializeImmutableOwner`
- **Discriminator:** `0x16`
- **Args:** (none)
- **Account variants:**
  - `1 accounts:` `account`

### `AmountToUiAmount`
- **Discriminator:** `0x17`
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `1 accounts:` `mint`

### `UiAmountToAmount`
- **Discriminator:** `0x18`
- **Args:**
  - `ui_amount`: `String`
- **Account variants:**
  - `1 accounts:` `mint`

## Shared types

### `AuthorityType`
- enum: `MintTokens`, `FreezeAccount`, `AccountOwner`, `CloseAccount`

### `AccountState`
- enum: `Uninitialized`, `Initialized`, `Frozen`
