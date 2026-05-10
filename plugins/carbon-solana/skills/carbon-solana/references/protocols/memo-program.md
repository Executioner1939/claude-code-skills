# Memo Program

- **Crate:** `carbon-memo-program-decoder`
- **Program ID:** `spl_memo_interface::v3::ID` (SPL Memo program v3)
- **Decoder struct:** `MemoProgramDecoder`
- **Has accounts:** no
- **Has instructions:** yes
- **Has CPI events:** no
- **Discriminator style:** raw (passes through full instruction data)

## Instructions

### `Memo`
- **Doc:** Wraps the entire instruction data as the memo payload.
- **Args:**
  - `0`: `Vec<u8>` (tuple variant; raw instruction data)
