# Meteora Vault

- **Crate:** `carbon-meteora-vault-decoder`
- **Program ID:** `24Uqj9JCLxUeoC3hGfh5W3s9FM9uCHDS2SG3LYwBpyTi`
- **Decoder struct:** `MeteoraVaultDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in instructions/)
- **Discriminator style:** anchor 8-byte (events 16-byte)

## Account types

### `Strategy`
- **Fields:**
  - `reserve`: `Pubkey`
  - `collateral_vault`: `Pubkey`
  - `strategy_type`: `StrategyType`
  - `current_liquidity`: `u64`
  - `bumps`: `[u8; 10]`
  - `vault`: `Pubkey`
  - `is_disable`: `u8`

### `Vault`
- **Fields:**
  - `enabled`: `u8`
  - `bumps`: `VaultBumps`
  - `total_amount`: `u64`
  - `token_vault`: `Pubkey`
  - `fee_vault`: `Pubkey`
  - `token_mint`: `Pubkey`
  - `lp_mint`: `Pubkey`
  - `strategies`: `[Pubkey; 30]`
  - `base`: `Pubkey`
  - `admin`: `Pubkey`
  - `operator`: `Pubkey`
  - `locked_profit_tracker`: `LockedProfitTracker`

## Instructions

### `AddLiquidityEvent`
- **Discriminator:** `0xe445a52e51cb9a1d1f5e7d5ae3343dba`
- **Args:**
  - `lp_mint_amount`: `u64`
  - `token_amount`: `u64`

### `AddStrategy`
- **Discriminator:** `0x407b7fe3c0eac614`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `vault`, `strategy`, `admin`

### `ClaimRewardEvent`
- **Discriminator:** `0xe445a52e51cb9a1d947486cc16ab555f`
- **Args:**
  - `strategy_type`: `StrategyType`
  - `token_amount`: `u64`
  - `mint_account`: `Pubkey`

### `CollectDust`
- **Discriminator:** `0xf6951552a04afef0`
- **Args:** (none)
- **Account variants:**
  - `5 accounts:` `vault`, `token_vault`, `token_admin`, `admin`, `token_program`

### `Deposit`
- **Discriminator:** `0xf223c68952e1f2b6`
- **Args:**
  - `token_amount`: `u64`
  - `minimum_lp_token_amount`: `u64`
- **Account variants:**
  - `7 accounts:` `vault`, `token_vault`, `lp_mint`, `user_token`, `user_lp`, `user`, `token_program`

### `DepositStrategy`
- **Discriminator:** `0xf65239e283defdf9`
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `10 accounts:` `vault`, `strategy`, `token_vault`, `fee_vault`, `lp_mint`, `strategy_program`, `collateral_vault`, `reserve`, `token_program`, `operator`

### `EnableVault`
- **Discriminator:** `0x9152f19c1a9ae9d3`
- **Args:**
  - `enabled`: `u8`
- **Account variants:**
  - `2 accounts:` `vault`, `admin`

### `Initialize`
- **Discriminator:** `0xafaf6d1f0d989bed`
- **Args:** (none)
- **Account variants:**
  - `8 accounts:` `vault`, `payer`, `token_vault`, `token_mint`, `lp_mint`, `rent`, `token_program`, `system_program`

### `InitializeStrategy`
- **Discriminator:** `0xd0779091b23969fc`
- **Args:**
  - `bumps`: `StrategyBumps`
  - `strategy_type`: `StrategyType`
- **Account variants:**
  - `10 accounts:` `vault`, `strategy_program`, `strategy`, `reserve`, `collateral_vault`, `collateral_mint`, `admin`, `system_program`, `rent`, `token_program`

### `PerformanceFeeEvent`
- **Discriminator:** `0xe445a52e51cb9a1d1c46e7df516defa7`
- **Args:**
  - `lp_mint_more`: `u64`

### `RemoveLiquidityEvent`
- **Discriminator:** `0xe445a52e51cb9a1d74f461e8671f983a`
- **Args:**
  - `lp_unmint_amount`: `u64`
  - `token_amount`: `u64`

### `RemoveStrategy`
- **Discriminator:** `0xb9ee215b86d2611a`
- **Args:** (none)
- **Account variants:**
  - `10 accounts:` `vault`, `strategy`, `strategy_program`, `collateral_vault`, `reserve`, `token_vault`, `fee_vault`, `lp_mint`, `token_program`, `admin`

### `RemoveStrategy2`
- **Discriminator:** `0x8a68d0947e23c30e`
- **Args:**
  - `max_admin_pay_amount`: `u64`
- **Account variants:**
  - `12 accounts:` `vault`, `strategy`, `strategy_program`, `collateral_vault`, `reserve`, `token_vault`, `token_admin_advance_payment`, `token_vault_advance_payment`, `fee_vault`, `lp_mint`, `token_program`, `admin`

### `ReportLossEvent`
- **Discriminator:** `0xe445a52e51cb9a1d9a249ec420a37b7e`
- **Args:**
  - `strategy`: `Pubkey`
  - `loss`: `u64`

### `SetOperator`
- **Discriminator:** `0xee9965a9f3832401`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `vault`, `operator`, `admin`

### `StrategyDepositEvent`
- **Discriminator:** `0xe445a52e51cb9a1dcd355bef2288492f`
- **Args:**
  - `strategy_type`: `StrategyType`
  - `token_amount`: `u64`

### `StrategyWithdrawEvent`
- **Discriminator:** `0xe445a52e51cb9a1d784cd05fddd2e5bd`
- **Args:**
  - `strategy_type`: `StrategyType`
  - `collateral_amount`: `u64`
  - `estimated_token_amount`: `u64`

### `TotalAmountEvent`
- **Discriminator:** `0xe445a52e51cb9a1d5cc87a91d3cb31cd`
- **Args:**
  - `total_amount`: `u64`

### `Withdraw`
- **Discriminator:** `0xb712469c946da122`
- **Args:**
  - `unmint_amount`: `u64`
  - `min_out_amount`: `u64`
- **Account variants:**
  - `7 accounts:` `vault`, `token_vault`, `lp_mint`, `user_token`, `user_lp`, `user`, `token_program`

### `Withdraw2`
- **Discriminator:** `0x50066f49aed34284`
- **Args:**
  - `unmint_amount`: `u64`
  - `min_out_amount`: `u64`
- **Account variants:**
  - `7 accounts:` `vault`, `token_vault`, `lp_mint`, `user_token`, `user_lp`, `user`, `token_program`

### `WithdrawDirectlyFromStrategy`
- **Discriminator:** `0xc98d922ead74c616`
- **Args:**
  - `unmint_amount`: `u64`
  - `min_out_amount`: `u64`
- **Account variants:**
  - `12 accounts:` `vault`, `strategy`, `reserve`, `strategy_program`, `collateral_vault`, `token_vault`, `lp_mint`, `fee_vault`, `user_token`, `user_lp`, `user`, `token_program`

### `WithdrawStrategy`
- **Discriminator:** `0x1f2da205c1d986bc`
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `10 accounts:` `vault`, `strategy`, `token_vault`, `fee_vault`, `lp_mint`, `strategy_program`, `collateral_vault`, `reserve`, `token_program`, `operator`

## Shared types

### `LockedProfitTracker`
- `last_updated_locked_profit`: `u64`
- `last_report`: `u64`
- `locked_profit_degradation`: `u64`

### `StrategyBumps`
- `strategy_index`: `u8`
- `other_bumps`: `[u8; 10]`

### `StrategyType`
- enum: `PortFinanceWithoutLM`, `PortFinanceWithLM`, `SolendWithoutLM`, `Mango`, `SolendWithLM`, `ApricotWithoutLM`, `Francium`, `Tulip`, `Vault`, `Drift`, `Frakt`, `Marginfi`

### `VaultBumps`
- `vault_bump`: `u8`
- `token_vault_bump`: `u8`
