# Marginfi V2

- **Crate:** `carbon-marginfi-v2-decoder`
- **Program ID:** `MFv2hWf31Z9kbCa1snEPYctwafyhdvnV7FZnsebVacA`
- **Decoder struct:** `MarginfiV2Decoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in instructions/)
- **Discriminator style:** anchor 8-byte

## Account types

### `Bank`
- **Fields:**
  - `mint`: `Pubkey`
  - `mint_decimals`: `u8`
  - `group`: `Pubkey`
  - `auto_padding_0`: `[u8; 7]`
  - `asset_share_value`: `WrappedI80F48`
  - `liability_share_value`: `WrappedI80F48`
  - `liquidity_vault`: `Pubkey`
  - `liquidity_vault_bump`: `u8`
  - `liquidity_vault_authority_bump`: `u8`
  - `insurance_vault`: `Pubkey`
  - `insurance_vault_bump`: `u8`
  - `insurance_vault_authority_bump`: `u8`
  - `auto_padding_1`: `[u8; 4]`
  - `collected_insurance_fees_outstanding`: `WrappedI80F48`
  - `fee_vault`: `Pubkey`
  - `fee_vault_bump`: `u8`
  - `fee_vault_authority_bump`: `u8`
  - `auto_padding_2`: `[u8; 6]`
  - `collected_group_fees_outstanding`: `WrappedI80F48`
  - `total_liability_shares`: `WrappedI80F48`
  - `total_asset_shares`: `WrappedI80F48`
  - `last_update`: `i64`
  - `config`: `BankConfig`
  - `emissions_flags`: `u64`
  - `emissions_rate`: `u64`
  - `emissions_remaining`: `WrappedI80F48`
  - `emissions_mint`: `Pubkey`
  - `padding0`: `[u128; 28]`
  - `padding1`: `[u128; 32]`

### `MarginfiAccount`
- **Fields:**
  - `group`: `Pubkey`
  - `authority`: `Pubkey`
  - `lending_account`: `LendingAccount`
  - `account_flags`: `u64`
  - `padding`: `[u64; 63]`

### `MarginfiGroup`
- **Fields:**
  - `admin`: `Pubkey`
  - `padding0`: `[u128; 32]`
  - `padding1`: `[u128; 32]`

## Instructions

### `LendingAccountBorrow`
- **Discriminator:** `0x047e74353005d41f`
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `8 accounts:` `marginfi_group`, `marginfi_account`, `signer`, `bank`, `destination_token_account`, `bank_liquidity_vault_authority`, `bank_liquidity_vault`, `token_program`

### `LendingAccountCloseBalance`
- **Discriminator:** `0xf5362904f3ca1f11`
- **Args:** (none)
- **Account variants:**
  - `4 accounts:` `marginfi_group`, `marginfi_account`, `signer`, `bank`

### `LendingAccountDeposit`
- **Discriminator:** `0xab5eeb675240d48c`
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `7 accounts:` `marginfi_group`, `marginfi_account`, `signer`, `bank`, `signer_token_account`, `bank_liquidity_vault`, `token_program`

### `LendingAccountEndFlashloan`
- **Discriminator:** `0x697cc96a9902089c`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `marginfi_account`, `signer`

### `LendingAccountLiquidate`
- **Discriminator:** `0xd6a997d5fba756db`
- **Args:**
  - `asset_amount`: `u64`
- **Account variants:**
  - `10 accounts:` `marginfi_group`, `asset_bank`, `liab_bank`, `liquidator_marginfi_account`, `signer`, `liquidatee_marginfi_account`, `bank_liquidity_vault_authority`, `bank_liquidity_vault`, `bank_insurance_vault`, `token_program`

### `LendingAccountRepay`
- **Discriminator:** `0x4fd1acb1de33ad97`
- **Args:**
  - `amount`: `u64`
  - `repay_all`: `Option<bool>`
- **Account variants:**
  - `7 accounts:` `marginfi_group`, `marginfi_account`, `signer`, `bank`, `signer_token_account`, `bank_liquidity_vault`, `token_program`

### `LendingAccountSettleEmissions`
- **Discriminator:** `0xa13a88aef2df9cb0`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `marginfi_account`, `bank`

### `LendingAccountStartFlashloan`
- **Discriminator:** `0x0e8321dc51bab46b`
- **Args:**
  - `end_index`: `u64`
- **Account variants:**
  - `3 accounts:` `marginfi_account`, `signer`, `ixs_sysvar`

### `LendingAccountWithdraw`
- **Discriminator:** `0x24484a13d2d2c0c0`
- **Args:**
  - `amount`: `u64`
  - `withdraw_all`: `Option<bool>`
- **Account variants:**
  - `8 accounts:` `marginfi_group`, `marginfi_account`, `signer`, `bank`, `destination_token_account`, `bank_liquidity_vault_authority`, `bank_liquidity_vault`, `token_program`

### `LendingAccountWithdrawEmissions`
- **Discriminator:** `0xea1654d676b08caa`
- **Args:** (none)
- **Account variants:**
  - `9 accounts:` `marginfi_group`, `marginfi_account`, `signer`, `bank`, `emissions_mint`, `emissions_auth`, `emissions_vault`, `destination_account`, `token_program`

### `LendingPoolAccrueBankInterest`
- **Discriminator:** `0x6cc91e572f4161bc`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `marginfi_group`, `bank`

### `LendingPoolAddBank`
- **Discriminator:** `0xd744484ed0da67b6`
- **Args:**
  - `bank_config`: `BankConfigCompact`
- **Account variants:**
  - `14 accounts:` `marginfi_group`, `admin`, `fee_payer`, `bank_mint`, `bank`, `liquidity_vault_authority`, `liquidity_vault`, `insurance_vault_authority`, `insurance_vault`, `fee_vault_authority`, `fee_vault`, `rent`, `token_program`, `system_program`

### `LendingPoolAddBankWithSeed`
- **Discriminator:** `0x4cd3d5ab754e9e4c`
- **Args:**
  - `bank_config`: `BankConfigCompact`
  - `bank_seed`: `u64`
- **Account variants:**
  - `14 accounts:` `marginfi_group`, `admin`, `fee_payer`, `bank_mint`, `bank`, `liquidity_vault_authority`, `liquidity_vault`, `insurance_vault_authority`, `insurance_vault`, `fee_vault_authority`, `fee_vault`, `rent`, `token_program`, `system_program`

### `LendingPoolCollectBankFees`
- **Discriminator:** `0xc905d774e65c4b96`
- **Args:** (none)
- **Account variants:**
  - `7 accounts:` `marginfi_group`, `bank`, `liquidity_vault_authority`, `liquidity_vault`, `insurance_vault`, `fee_vault`, `token_program`

### `LendingPoolConfigureBank`
- **Discriminator:** `0x79ad9c285d9438ed`
- **Args:**
  - `bank_config_opt`: `BankConfigOpt`
- **Account variants:**
  - `3 accounts:` `marginfi_group`, `admin`, `bank`

### `LendingPoolHandleBankruptcy`
- **Discriminator:** `0xa20b388b5a8046ad`
- **Args:** (none)
- **Account variants:**
  - `8 accounts:` `marginfi_group`, `admin`, `bank`, `marginfi_account`, `liquidity_vault`, `insurance_vault`, `insurance_vault_authority`, `token_program`

### `LendingPoolSetupEmissions`
- **Discriminator:** `0xce6178ac71cca946`
- **Args:**
  - `flags`: `u64`
  - `rate`: `u64`
  - `total_emissions`: `u64`
- **Account variants:**
  - `9 accounts:` `marginfi_group`, `admin`, `bank`, `emissions_mint`, `emissions_auth`, `emissions_token_account`, `emissions_funding_account`, `token_program`, `system_program`

### `LendingPoolUpdateEmissionsParameters`
- **Discriminator:** `0x37d5e0a89935c528`
- **Args:**
  - `emissions_flags`: `Option<u64>`
  - `emissions_rate`: `Option<u64>`
  - `additional_emissions`: `Option<u64>`
- **Account variants:**
  - `7 accounts:` `marginfi_group`, `admin`, `bank`, `emissions_mint`, `emissions_token_account`, `emissions_funding_account`, `token_program`

### `MarginfiAccountInitialize`
- **Discriminator:** `0x2b4e3dff9434f99a`
- **Args:** (none)
- **Account variants:**
  - `5 accounts:` `marginfi_group`, `marginfi_account`, `authority`, `fee_payer`, `system_program`

### `MarginfiGroupConfigure`
- **Discriminator:** `0x3ec7514e210dec3d`
- **Args:**
  - `config`: `GroupConfig`
- **Account variants:**
  - `2 accounts:` `marginfi_group`, `admin`

### `MarginfiGroupInitialize`
- **Discriminator:** `0xff43431a5e1f2214`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `marginfi_group`, `admin`, `system_program`

### `SetAccountFlag`
- **Discriminator:** `0x38ee12cfc1528aae`
- **Args:**
  - `flag`: `u64`
- **Account variants:**
  - `3 accounts:` `marginfi_group`, `marginfi_account`, `admin`

### `SetNewAccountAuthority`
- **Discriminator:** `0x99a23254b6c94ab3`
- **Args:** (none)
- **Account variants:**
  - `5 accounts:` `marginfi_account`, `marginfi_group`, `signer`, `new_authority`, `fee_payer`

### `UnsetAccountFlag`
- **Discriminator:** `0x385138555c31ff46`
- **Args:**
  - `flag`: `u64`
- **Account variants:**
  - `3 accounts:` `marginfi_group`, `marginfi_account`, `admin`

## CPI events

### `LendingAccountBorrowEvent`
- **Source:** `instructions/lending_account_borrow_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1ddf60510a9c631a3b`
- **Fields:**
  - `header`: `AccountEventHeader`
  - `bank`: `Pubkey`
  - `mint`: `Pubkey`
  - `amount`: `u64`

### `LendingAccountDepositEvent`
- **Source:** `instructions/lending_account_deposit_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1da136edd969f87a97`
- **Fields:**
  - `header`: `AccountEventHeader`
  - `bank`: `Pubkey`
  - `mint`: `Pubkey`
  - `amount`: `u64`

### `LendingAccountLiquidateEvent`
- **Source:** `instructions/lending_account_liquidate_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1da6a0f99ab72717f2`
- **Fields:**
  - `header`: `AccountEventHeader`
  - `liquidatee_marginfi_account`: `Pubkey`
  - `liquidatee_marginfi_account_authority`: `Pubkey`
  - `asset_bank`: `Pubkey`
  - `asset_mint`: `Pubkey`
  - `liability_bank`: `Pubkey`
  - `liability_mint`: `Pubkey`
  - `liquidatee_pre_health`: `f64`
  - `liquidatee_post_health`: `f64`
  - `pre_balances`: `LiquidationBalances`
  - `post_balances`: `LiquidationBalances`

### `LendingAccountRepayEvent`
- **Source:** `instructions/lending_account_repay_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d10dc376f07501019`
- **Fields:**
  - `header`: `AccountEventHeader`
  - `bank`: `Pubkey`
  - `mint`: `Pubkey`
  - `amount`: `u64`
  - `close_balance`: `bool`

### `LendingAccountWithdrawEvent`
- **Source:** `instructions/lending_account_withdraw_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d03dc94f321f93658`
- **Fields:**
  - `header`: `AccountEventHeader`
  - `bank`: `Pubkey`
  - `mint`: `Pubkey`
  - `amount`: `u64`
  - `close_balance`: `bool`

### `LendingPoolBankAccrueInterestEvent`
- **Source:** `instructions/lending_pool_bank_accrue_interest_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d6875bb9c6f9a6aba`
- **Fields:**
  - `header`: `GroupEventHeader`
  - `bank`: `Pubkey`
  - `mint`: `Pubkey`
  - `delta`: `u64`
  - `fees_collected`: `f64`
  - `insurance_collected`: `f64`

### `LendingPoolBankCollectFeesEvent`
- **Source:** `instructions/lending_pool_bank_collect_fees_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d657761faa9af9cfd`
- **Fields:**
  - `header`: `GroupEventHeader`
  - `bank`: `Pubkey`
  - `mint`: `Pubkey`
  - `group_fees_collected`: `f64`
  - `group_fees_outstanding`: `f64`
  - `insurance_fees_collected`: `f64`
  - `insurance_fees_outstanding`: `f64`

### `LendingPoolBankConfigureEvent`
- **Source:** `instructions/lending_pool_bank_configure_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1df623e96e5d98eb28`
- **Fields:**
  - `header`: `GroupEventHeader`
  - `bank`: `Pubkey`
  - `mint`: `Pubkey`
  - `config`: `BankConfigOpt`

### `LendingPoolBankCreateEvent`
- **Source:** `instructions/lending_pool_bank_create_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1decdcc93fef7e88f9`
- **Fields:**
  - `header`: `GroupEventHeader`
  - `bank`: `Pubkey`
  - `mint`: `Pubkey`

### `LendingPoolBankHandleBankruptcyEvent`
- **Source:** `instructions/lending_pool_bank_handle_bankruptcy_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1da64d298c245e0a39`
- **Fields:**
  - `header`: `AccountEventHeader`
  - `bank`: `Pubkey`
  - `mint`: `Pubkey`
  - `bad_debt`: `f64`
  - `covered_amount`: `f64`
  - `socialized_amount`: `f64`

### `MarginfiAccountCreateEvent`
- **Source:** `instructions/marginfi_account_create_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1db70575687ac74433`
- **Fields:**
  - `header`: `AccountEventHeader`

### `MarginfiAccountTransferAccountAuthorityEvent`
- **Source:** `instructions/marginfi_account_transfer_account_authority_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d703d8c84fb5c5aca`
- **Fields:**
  - `old_account_authority`: `Pubkey`
  - `new_account_authority`: `Pubkey`
  - `header`: `AccountEventHeader`

### `MarginfiGroupConfigureEvent`
- **Source:** `instructions/marginfi_group_configure_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1df168aca729c3c7aa`
- **Fields:**
  - `header`: `GroupEventHeader`
  - `config`: `GroupConfig`

### `MarginfiGroupCreateEvent`
- **Source:** `instructions/marginfi_group_create_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1de97d3d0e62f088fd`
- **Fields:**
  - `header`: `GroupEventHeader`

## Shared types

### `AccountEventHeader`
- `signer`: `Option<Pubkey>`
- `marginfi_account`: `Pubkey`
- `marginfi_account_authority`: `Pubkey`
- `marginfi_group`: `Pubkey`

### `Balance`
- `active`: `bool`
- `bank_pk`: `Pubkey`
- `auto_padding_0`: `[u8; 7]`
- `asset_shares`: `WrappedI80F48`
- `liability_shares`: `WrappedI80F48`
- `emissions_outstanding`: `WrappedI80F48`
- `last_update`: `u64`
- `padding`: `[u64; 1]`

### `BalanceDecreaseType` (enum)
- `Any`
- `WithdrawOnly`
- `BorrowOnly`
- `BypassBorrowLimit`

### `BalanceIncreaseType` (enum)
- `Any`
- `RepayOnly`
- `DepositOnly`
- `BypassDepositLimit`

### `BalanceSide` (enum)
- `Assets`
- `Liabilities`

### `BankConfig`
- `asset_weight_init`: `WrappedI80F48`
- `asset_weight_maint`: `WrappedI80F48`
- `liability_weight_init`: `WrappedI80F48`
- `liability_weight_maint`: `WrappedI80F48`
- `deposit_limit`: `u64`
- `interest_rate_config`: `InterestRateConfig`
- `operational_state`: `BankOperationalState`
- `oracle_setup`: `OracleSetup`
- `oracle_keys`: `[Pubkey; 5]`
- `auto_padding_0`: `[u8; 6]`
- `borrow_limit`: `u64`
- `risk_tier`: `RiskTier`
- `auto_padding_1`: `[u8; 7]`
- `total_asset_value_init_limit`: `u64`
- `padding`: `[u64; 5]`

### `BankConfigCompact`
- `asset_weight_init`: `WrappedI80F48`
- `asset_weight_maint`: `WrappedI80F48`
- `liability_weight_init`: `WrappedI80F48`
- `liability_weight_maint`: `WrappedI80F48`
- `deposit_limit`: `u64`
- `interest_rate_config`: `InterestRateConfigCompact`
- `operational_state`: `BankOperationalState`
- `oracle_setup`: `OracleSetup`
- `oracle_key`: `Pubkey`
- `auto_padding_0`: `[u8; 6]`
- `borrow_limit`: `u64`
- `risk_tier`: `RiskTier`
- `auto_padding_1`: `[u8; 7]`
- `total_asset_value_init_limit`: `u64`

### `BankConfigOpt`
- `asset_weight_init`: `Option<WrappedI80F48>`
- `asset_weight_maint`: `Option<WrappedI80F48>`
- `liability_weight_init`: `Option<WrappedI80F48>`
- `liability_weight_maint`: `Option<WrappedI80F48>`
- `deposit_limit`: `Option<u64>`
- `borrow_limit`: `Option<u64>`
- `operational_state`: `Option<BankOperationalState>`
- `oracle`: `Option<OracleConfig>`
- `interest_rate_config`: `Option<InterestRateConfigOpt>`
- `risk_tier`: `Option<RiskTier>`
- `total_asset_value_init_limit`: `Option<u64>`

### `BankOperationalState` (enum)
- `Paused`
- `Operational`
- `ReduceOnly`

### `BankVaultType` (enum)
- `Liquidity`
- `Insurance`
- `Fee`

### `GroupConfig`
- `admin`: `Option<Pubkey>`

### `GroupEventHeader`
- `signer`: `Option<Pubkey>`
- `marginfi_group`: `Pubkey`

### `InterestRateConfig`
- `optimal_utilization_rate`: `WrappedI80F48`
- `plateau_interest_rate`: `WrappedI80F48`
- `max_interest_rate`: `WrappedI80F48`
- `insurance_fee_fixed_apr`: `WrappedI80F48`
- `insurance_ir_fee`: `WrappedI80F48`
- `protocol_fixed_fee_apr`: `WrappedI80F48`
- `protocol_ir_fee`: `WrappedI80F48`
- `padding`: `[u128; 8]`

### `InterestRateConfigCompact`
- `optimal_utilization_rate`: `WrappedI80F48`
- `plateau_interest_rate`: `WrappedI80F48`
- `max_interest_rate`: `WrappedI80F48`
- `insurance_fee_fixed_apr`: `WrappedI80F48`
- `insurance_ir_fee`: `WrappedI80F48`
- `protocol_fixed_fee_apr`: `WrappedI80F48`
- `protocol_ir_fee`: `WrappedI80F48`

### `InterestRateConfigOpt`
- `optimal_utilization_rate`: `Option<WrappedI80F48>`
- `plateau_interest_rate`: `Option<WrappedI80F48>`
- `max_interest_rate`: `Option<WrappedI80F48>`
- `insurance_fee_fixed_apr`: `Option<WrappedI80F48>`
- `insurance_ir_fee`: `Option<WrappedI80F48>`
- `protocol_fixed_fee_apr`: `Option<WrappedI80F48>`
- `protocol_ir_fee`: `Option<WrappedI80F48>`

### `LendingAccount`
- `balances`: `[Balance; 16]`
- `padding`: `[u64; 8]`

### `LiquidationBalances`
- `liquidatee_asset_balance`: `f64`
- `liquidatee_liability_balance`: `f64`
- `liquidator_asset_balance`: `f64`
- `liquidator_liability_balance`: `f64`

### `OracleConfig`
- `setup`: `OracleSetup`
- `keys`: `[Pubkey; 5]`

### `OraclePriceType` (enum)
- `TimeWeighted`
- `RealTime`

### `OracleSetup` (enum)
- `None`
- `PythEma`
- `SwitchboardV2`

### `PriceBias` (enum)
- `Low`
- `High`

### `RequirementType` (enum)
- `Initial`
- `Maintenance`
- `Equity`

### `RiskRequirementType` (enum)
- `Initial`
- `Maintenance`
- `Equity`

### `RiskTier` (enum)
- `Collateral`
- `Isolated`

### `WrappedI80F48`
- `value`: `i128`
