# Address Lookup Table

- **Crate:** `carbon-address-lookup-table-decoder`
- **Program ID:** `AddressLookupTab1e1111111111111111111111111`
- **Decoder struct:** `AddressLookupTableDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** no
- **Discriminator style:** raw u32 LE

## Account types

### `AddressLookupTable`
- **Fields:**
  - `meta`: `LookupTableMeta`
  - `addresses`: `LookupTableAddresses`

## Instructions

### `CloseLookupTable`
- **Discriminator:** `0x04000000` (u32 LE)
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `look_up_table`, `authority`, `lamports_recipient`

### `CreateLookupTable`
- **Discriminator:** `0x00000000` (u32 LE)
- **Args:**
  - `recent_slot`: `u64`
  - `bump_seed`: `u8`
- **Account variants:**
  - `4 accounts:` `look_up_table`, `authority`, `funder`, `system_program`

### `DeactivateLookupTable`
- **Discriminator:** `0x03000000` (u32 LE)
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `look_up_table`, `authority`

### `ExtendLookupTable`
- **Discriminator:** `0x02000000` (u32 LE)
- **Args:**
  - `new_addresses`: `Vec<Pubkey>`
- **Account variants:**
  - `4 accounts:` `look_up_table`, `authority`, `funder`, `system_program`

### `FreezeLookupTable`
- **Discriminator:** `0x01000000` (u32 LE)
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `look_up_table`, `authority`

## Shared types

### `LookupTableAddresses`
- `addresses`: `Vec<Pubkey>`

### `LookupTableMeta`
- `deactivation_slot`: `u64`
- `last_extended_slot`: `u64`
- `last_extended_slot_start_index`: `u8`
- `authority`: `Option<Pubkey>`
- `padding`: `u16`

### `ProgramState`
- Enum variants: `Uninitialized`, `LookupTable(LookupTableMeta)`
