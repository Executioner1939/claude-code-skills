# Solayer Restaking Program

- **Crate:** `carbon-solayer-restaking-program-decoder`
- **Program ID:** `sSo1iU21jBrU9VaJ8PJib1MtorefUV4fzC9GURa2KNn`
- **Decoder struct:** `SolayerRestakingProgramDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** no
- **Discriminator style:** anchor 8-byte

## Account types

### `RestakingPool`
- **Fields:**
  - `lst_mint`: `Pubkey`
  - `rst_mint`: `Pubkey`
  - `bump`: `u8`

## Instructions

### `BatchThawLstAccounts`
- **Discriminator:** `0xb7ae4d28b686cad5`
- **Args:** (none)
- **Account variants:**
  - `8 accounts:` `signer`, `solayer_admin`, `lst_mint`, `rst_mint`, `pool`, `associated_token_program`, `token_program`, `system_program`
- **Remaining accounts:** yes

### `Initialize`
- **Discriminator:** `0xafaf6d1f0d989bed`
- **Args:** (none)
- **Account variants:**
  - `9 accounts:` `signer`, `solayer_admin`, `lst_mint`, `lst_vault`, `rst_mint`, `pool`, `associated_token_program`, `token_program`, `system_program`
- **Remaining accounts:** yes

### `Restake`
- **Discriminator:** `0x61a1f1a70620d535`
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `10 accounts:` `signer`, `lst_mint`, `lst_ata`, `rst_ata`, `rst_mint`, `vault`, `pool`, `associated_token_program`, `token_program`, `system_program`
- **Remaining accounts:** yes

### `Unrestake`
- **Discriminator:** `0x0ab1a1eefa257818`
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `10 accounts:` `signer`, `lst_mint`, `lst_ata`, `rst_ata`, `rst_mint`, `vault`, `pool`, `associated_token_program`, `token_program`, `system_program`
- **Remaining accounts:** yes
