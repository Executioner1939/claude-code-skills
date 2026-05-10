# SPL Name Service

- **Crate:** `carbon-name-service-decoder`
- **Program ID:** `namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX`
- **Decoder struct:** `NameDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** no
- **Discriminator style:** mixed (8-byte for accounts, raw byte for instructions)

## Account types

### `NameRecordHeader`
- **Discriminator:** `0x319893826f292f59`
- **Fields:**
  - `parent_name`: `Pubkey`
  - `owner`: `Pubkey`
  - `class`: `Pubkey`

## Instructions

### `Create`
- **Discriminator:** `0x00`
- **Args:**
  - `hashed_name`: `Vec<u8>`
  - `lamports`: `u64`
  - `space`: `u32`
- **Account variants:**
  - `6 accounts:` `system_program, funding_account, name_record, account_class, parent_name_record, parent_name_record_class`

### `Update`
- **Discriminator:** `0x01`
- **Args:**
  - `offset`: `u32`
  - `data`: `Vec<u8>`
- **Account variants:**
  - `3 accounts:` `name_record, owner, parent_name_record`

### `Transfer`
- **Discriminator:** `0x02`
- **Args:**
  - `new_owner`: `Pubkey`
- **Account variants:**
  - `3 accounts:` `name_record, owner, parent_name_record`

### `Delete`
- **Discriminator:** `0x03`
- **Args:**
  - `(none)`
- **Account variants:**
  - `3 accounts:` `name_record, owner, refund_account`

### `Realloc`
- **Discriminator:** `0x04`
- **Args:**
  - `space`: `u32`
- **Account variants:**
  - `4 accounts:` `system_program, payer, name_record, owner`
