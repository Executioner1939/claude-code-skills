# Swig

- **Crate:** `carbon-swig-decoder`
- **Program ID:** `swigypWHEksbC64pWKwah1WTeh9JXwx8H1rJHLdbQMB`
- **Decoder struct:** `SwigDecoder`
- **Has accounts:** no
- **Has instructions:** yes
- **Has CPI events:** no
- **Discriminator style:** raw byte

## Instructions

### `CreateV1`
- **Discriminator:** `[0]`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `swig, payer, swig_wallet_address, system_program`
- **Remaining accounts:** yes

### `AddAuthorityV1`
- **Discriminator:** `[1]`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `swig, payer, system_program`
- **Remaining accounts:** yes

### `RemoveAuthorityV1`
- **Discriminator:** `[2]`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `swig, payer, system_program`
- **Remaining accounts:** yes

### `UpdateAuthorityV1`
- **Discriminator:** `[3]`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `swig, payer, system_program`
- **Remaining accounts:** yes

### `SignV1`
- **Discriminator:** `[4]`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `swig, payer, system_program`
- **Remaining accounts:** yes

### `CreateSessionV1`
- **Discriminator:** `[5]`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `swig, payer, system_program`
- **Remaining accounts:** yes

### `CreateSubAccountV1`
- **Discriminator:** `[6]`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `swig, payer, sub_account, system_program`
- **Remaining accounts:** yes

### `WithdrawFromSubAccountV1`
- **Discriminator:** `[7]`
- **Args:** (none)
- **Account variants:**
  - `6 accounts:` `swig, payer, sub_account, authority, swig_wallet_address, system_program`
- **Remaining accounts:** yes

### `SubAccountSignV1`
- **Discriminator:** `[9]`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `swig, sub_account, system_program`
- **Remaining accounts:** yes

### `ToggleSubAccountV1`
- **Discriminator:** `[10]`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `swig, payer, sub_account`
- **Remaining accounts:** yes

### `SignV2`
- **Discriminator:** `[11]`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `swig, swig_wallet_address, system_program`
- **Remaining accounts:** yes

### `MigrateToWalletAddressV1`
- **Discriminator:** `[12]`
- **Args:** (none)
- **Account variants:**
  - `5 accounts:` `swig, authority, payer, swig_wallet_address, system_program`
- **Remaining accounts:** yes

### `TransferAssetsV1`
- **Discriminator:** `[13]`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `swig, swig_wallet_address, payer, system_program`
- **Remaining accounts:** yes
