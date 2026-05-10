# Stake Program

- **Crate:** `carbon-stake-program-decoder`
- **Program ID:** `Stake11111111111111111111111111111111111111`
- **Decoder struct:** `StakeProgramDecoder`
- **Has accounts:** no
- **Has instructions:** yes
- **Has CPI events:** no
- **Discriminator style:** anchor 8-byte (note: native stake program normally uses u32 LE indices; these decoders use anchor-style sighash-form 8-byte discriminators)

## Instructions

### `Authorize`
- **Discriminator:** `0xadc166d2db897178`
- **Args:**
  - `new_authority`: `Pubkey`
  - `stake_authorize`: `StakeAuthorize`
- **Account variants:**
  - `3 accounts:` `stake`, `clock`, `authority`
- **Remaining accounts:** yes

### `AuthorizeChecked`
- **Discriminator:** `0x9361431ae66b2df2`
- **Args:**
  - `stake_authorize`: `StakeAuthorize`
- **Account variants:**
  - `4 accounts:` `stake`, `clock`, `authority`, `new_authority`
- **Remaining accounts:** yes

### `AuthorizeCheckedWithSeed`
- **Discriminator:** `0x0ee69aa5e1d1c2d2`
- **Args:**
  - `stake_authorize`: `StakeAuthorize`
  - `authority_seed`: `String`
  - `authority_owner`: `Pubkey`
- **Account variants:**
  - `4 accounts:` `stake`, `authority_base`, `clock`, `new_authority`
- **Remaining accounts:** yes

### `AuthorizeWithSeed`
- **Discriminator:** `0x0712d3294c53733d`
- **Args:**
  - `new_authority`: `Pubkey`
  - `stake_authorize`: `StakeAuthorize`
  - `authority_seed`: `String`
  - `authority_owner`: `Pubkey`
- **Account variants:**
  - `3 accounts:` `stake`, `authority_base`, `clock`
- **Remaining accounts:** yes

### `Deactivate`
- **Discriminator:** `0x2c7021ac711c8e0d`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `stake`, `clock`, `stake_authority`
- **Remaining accounts:** yes

### `DeactivateDelinquent`
- **Discriminator:** `0x0671c68ae4a39fdd`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `stake`, `vote`, `reference_vote`
- **Remaining accounts:** yes

### `DelegateStake`
- **Discriminator:** `0x326e5fb3c24b8cf6`
- **Args:** (none)
- **Account variants:**
  - `6 accounts:` `stake`, `vote`, `clock`, `stake_history`, `stake_config`, `stake_authority`
- **Remaining accounts:** yes

### `GetMinimumDelegation`
- **Discriminator:** `0xc541074997698569`
- **Args:** (none)
- **Account variants:**
  - `0 accounts:` (none)

### `Initialize`
- **Discriminator:** `0xafaf6d1f0d989bed`
- **Args:**
  - `authorized`: `Authorized`
  - `lockup`: `Lockup`
- **Account variants:**
  - `2 accounts:` `stake`, `rent`
- **Remaining accounts:** yes

### `InitializeChecked`
- **Discriminator:** `0xdb5a3aa18b58f61c`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `stake`, `rent`, `stake_authority`, `withdraw_authority`
- **Remaining accounts:** yes

### `Merge`
- **Discriminator:** `0x948dec2fae7e456f`
- **Args:** (none)
- **Account variants:**
  - `5 accounts:` `to`, `from`, `clock`, `stake_history`, `stake_authority`
- **Remaining accounts:** yes

### `SetLockup`
- **Discriminator:** `0x2caabd28807bfcc9`
- **Args:**
  - `unix_timestamp`: `Option<i64>`
  - `epoch`: `Option<u64>`
  - `custodian`: `Option<Pubkey>`
- **Account variants:**
  - `2 accounts:` `stake`, `authority`
- **Remaining accounts:** yes

### `SetLockupChecked`
- **Discriminator:** `0x169e0cb7765e9cff`
- **Args:**
  - `unix_timestamp`: `Option<i64>`
  - `epoch`: `Option<u64>`
- **Account variants:**
  - `2 accounts:` `stake`, `authority`
- **Remaining accounts:** yes

### `Split`
- **Discriminator:** `0x7cbd1b2bd8289342`
- **Args:**
  - `lamports`: `u64`
- **Account variants:**
  - `3 accounts:` `from`, `to`, `stake_authority`
- **Remaining accounts:** yes

### `Withdraw`
- **Discriminator:** `0xb712469c946da122`
- **Args:**
  - `lamports`: `u64`
- **Account variants:**
  - `5 accounts:` `from`, `to`, `clock`, `stake_history`, `withdraw_authority`
- **Remaining accounts:** yes

## Shared types

### `Authorized`
- `staker`: `Pubkey`
- `withdrawer`: `Pubkey`

### `Lockup`
- `unix_timestamp`: `i64`
- `epoch`: `u64`
- `custodian`: `Pubkey`

### `StakeAuthorize`
- enum variants: `Staker`, `Withdrawer`
