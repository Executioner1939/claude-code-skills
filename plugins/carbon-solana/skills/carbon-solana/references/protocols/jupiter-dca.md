# Jupiter DCA

- **Crate:** `carbon-jupiter-dca-decoder`
- **Program ID:** `DCA265Vj8a9CEuX1eb1LWRnDT7uK6q1xMipnNyatn23M`
- **Decoder struct:** `JupiterDcaDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in instructions/)
- **Discriminator style:** anchor 8-byte

## Account types

### `Dca`
- **Fields:**
  - `user`: `Pubkey`
  - `input_mint`: `Pubkey`
  - `output_mint`: `Pubkey`
  - `idx`: `u64`
  - `next_cycle_at`: `i64`
  - `in_deposited`: `u64`
  - `in_withdrawn`: `u64`
  - `out_withdrawn`: `u64`
  - `in_used`: `u64`
  - `out_received`: `u64`
  - `in_amount_per_cycle`: `u64`
  - `cycle_frequency`: `i64`
  - `next_cycle_amount_left`: `u64`
  - `in_account`: `Pubkey`
  - `out_account`: `Pubkey`
  - `min_out_amount`: `u64`
  - `max_out_amount`: `u64`
  - `keeper_in_balance_before_borrow`: `u64`
  - `dca_out_balance_before_swap`: `u64`
  - `created_at`: `i64`
  - `bump`: `u8`

## Instructions

### `CloseDca`
- **Discriminator:** `0x16072162a8b722f3`
- **Args:** (none)
- **Account variants:**
  - `13 accounts:` `user`, `dca`, `input_mint`, `output_mint`, `in_ata`, `out_ata`, `user_in_ata`, `user_out_ata`, `system_program`, `token_program`, `associated_token_program`, `event_authority`, `program`

### `Deposit`
- **Discriminator:** `0xf223c68952e1f2b6`
- **Args:**
  - `deposit_in`: `u64`
- **Account variants:**
  - `7 accounts:` `user`, `dca`, `in_ata`, `user_in_ata`, `token_program`, `event_authority`, `program`

### `EndAndClose`
- **Discriminator:** `0x537da645f7fc6785`
- **Args:** (none)
- **Account variants:**
  - `15 accounts:` `keeper`, `dca`, `input_mint`, `output_mint`, `in_ata`, `out_ata`, `user`, `user_out_ata`, `init_user_out_ata`, `intermediate_account`, `system_program`, `token_program`, `associated_token_program`, `event_authority`, `program`

### `FulfillDlmmFill`
- **Discriminator:** `0x01e676fb2db165bb`
- **Args:**
  - `repay_amount`: `u64`
- **Account variants:**
  - `15 accounts:` `keeper`, `dca`, `input_mint`, `output_mint`, `keeper_in_ata`, `in_ata`, `out_ata`, `fee_authority`, `fee_ata`, `instructions_sysvar`, `system_program`, `token_program`, `associated_token_program`, `event_authority`, `program`

### `FulfillFlashFill`
- **Discriminator:** `0x7340e24e21d369a2`
- **Args:**
  - `repay_amount`: `u64`
- **Account variants:**
  - `15 accounts:` `keeper`, `dca`, `input_mint`, `output_mint`, `keeper_in_ata`, `in_ata`, `out_ata`, `fee_authority`, `fee_ata`, `instructions_sysvar`, `system_program`, `token_program`, `associated_token_program`, `event_authority`, `program`

### `InitiateDlmmFill`
- **Discriminator:** `0x9bc150795b93febb`
- **Args:** (none)
- **Account variants:**
  - `10 accounts:` `keeper`, `dca`, `input_mint`, `keeper_in_ata`, `in_ata`, `out_ata`, `instructions_sysvar`, `system_program`, `token_program`, `associated_token_program`

### `InitiateFlashFill`
- **Discriminator:** `0x8fcd03bfa2d7f531`
- **Args:** (none)
- **Account variants:**
  - `10 accounts:` `keeper`, `dca`, `input_mint`, `keeper_in_ata`, `in_ata`, `out_ata`, `instructions_sysvar`, `system_program`, `token_program`, `associated_token_program`

### `OpenDca`
- **Discriminator:** `0x2441b93601d264a3`
- **Args:**
  - `application_idx`: `u64`
  - `in_amount`: `u64`
  - `in_amount_per_cycle`: `u64`
  - `cycle_frequency`: `i64`
  - `min_out_amount`: `Option<u64>`
  - `max_out_amount`: `Option<u64>`
  - `start_at`: `Option<i64>`
  - `close_wsol_in_ata`: `Option<bool>`
- **Account variants:**
  - `12 accounts:` `dca`, `user`, `input_mint`, `output_mint`, `user_ata`, `in_ata`, `out_ata`, `system_program`, `token_program`, `associated_token_program`, `event_authority`, `program`

### `OpenDcaV2`
- **Discriminator:** `0x8e772b6da2340bb1`
- **Args:**
  - `application_idx`: `u64`
  - `in_amount`: `u64`
  - `in_amount_per_cycle`: `u64`
  - `cycle_frequency`: `i64`
  - `min_out_amount`: `Option<u64>`
  - `max_out_amount`: `Option<u64>`
  - `start_at`: `Option<i64>`
- **Account variants:**
  - `13 accounts:` `dca`, `user`, `payer`, `input_mint`, `output_mint`, `user_ata`, `in_ata`, `out_ata`, `system_program`, `token_program`, `associated_token_program`, `event_authority`, `program`

### `Transfer`
- **Discriminator:** `0xa334c8e78c0345ba`
- **Args:** (none)
- **Account variants:**
  - `12 accounts:` `keeper`, `dca`, `user`, `output_mint`, `dca_out_ata`, `user_out_ata`, `intermediate_account`, `system_program`, `token_program`, `associated_token_program`, `event_authority`, `program`

### `Withdraw`
- **Discriminator:** `0xb712469c946da122`
- **Args:**
  - `withdraw_params`: `WithdrawParams`
- **Account variants:**
  - `12 accounts:` `user`, `dca`, `input_mint`, `output_mint`, `dca_ata`, `user_in_ata`, `user_out_ata`, `system_program`, `token_program`, `associated_token_program`, `event_authority`, `program`

### `WithdrawFees`
- **Discriminator:** `0xc6d4ab6d90d7ae59`
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `8 accounts:` `admin`, `mint`, `fee_authority`, `program_fee_ata`, `admin_fee_ata`, `system_program`, `token_program`, `associated_token_program`

## CPI events

### `ClosedEvent`
- **Source:** `instructions/closed_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d321f579b87dcc3ef`
- **Fields:**
  - `user_key`: `Pubkey`
  - `dca_key`: `Pubkey`
  - `in_deposited`: `u64`
  - `input_mint`: `Pubkey`
  - `output_mint`: `Pubkey`
  - `cycle_frequency`: `i64`
  - `in_amount_per_cycle`: `u64`
  - `created_at`: `i64`
  - `total_in_withdrawn`: `u64`
  - `total_out_withdrawn`: `u64`
  - `unfilled_amount`: `u64`
  - `user_closed`: `bool`

### `CollectedFeeEvent`
- **Source:** `instructions/collected_fee_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d2a88d874b5d16db5`
- **Fields:**
  - `user_key`: `Pubkey`
  - `dca_key`: `Pubkey`
  - `mint`: `Pubkey`
  - `amount`: `u64`

### `DepositEvent`
- **Source:** `instructions/deposit_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d3ecdf2aff4a98834`
- **Fields:**
  - `dca_key`: `Pubkey`
  - `amount`: `u64`

### `FilledEvent`
- **Source:** `instructions/filled_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d8604113fdd2db1ad`
- **Fields:**
  - `user_key`: `Pubkey`
  - `dca_key`: `Pubkey`
  - `input_mint`: `Pubkey`
  - `output_mint`: `Pubkey`
  - `in_amount`: `u64`
  - `out_amount`: `u64`
  - `fee_mint`: `Pubkey`
  - `fee`: `u64`

### `OpenedEvent`
- **Source:** `instructions/opened_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1da6ac61094d4cbd6d`
- **Fields:**
  - `user_key`: `Pubkey`
  - `dca_key`: `Pubkey`
  - `in_deposited`: `u64`
  - `input_mint`: `Pubkey`
  - `output_mint`: `Pubkey`
  - `cycle_frequency`: `i64`
  - `in_amount_per_cycle`: `u64`
  - `created_at`: `i64`

### `WithdrawEvent`
- **Source:** `instructions/withdraw_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1dc0f1c9d946965af7`
- **Fields:**
  - `dca_key`: `Pubkey`
  - `in_amount`: `u64`
  - `out_amount`: `u64`
  - `user_withdraw`: `bool`

## Shared types

### `WithdrawParams`
- `withdraw_amount`: `u64`
- `withdrawal`: `Withdrawal`

### `Withdrawal`
- enum variants: `In`, `Out`
