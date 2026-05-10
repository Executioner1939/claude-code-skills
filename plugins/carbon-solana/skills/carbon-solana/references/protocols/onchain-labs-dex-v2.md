# OnchainLabs DEX V2

- **Crate:** `carbon-onchain-labs-dex-v2-decoder`
- **Program ID:** `proVF4pMXVaYqmy4NjniPh4pqKNfMmsihgd4wdkCX3u`
- **Decoder struct:** `OnchainLabsDexV2Decoder`
- **Has accounts:** no
- **Has instructions:** yes
- **Has CPI events:** yes (events/)
- **Discriminator style:** anchor 8-byte

## Instructions

### `Claim`
- **Discriminator:** `[62, 198, 214, 193, 213, 159, 108, 210]`
- **Args:**
  - `(none)`
- **Account variants:**
  - `signer, receiver, source_token_account?, destination_token_account?, sa_authority, token_mint?, token_program?, system_program, associated_token_program?`
- **Optional accounts:** `source_token_account`, `destination_token_account`, `token_mint`, `token_program`, `associated_token_program`
- **Remaining accounts:** yes

### `CpiEvent`
- **Discriminator:** `[228, 69, 165, 46, 81, 203, 154, 29]`
- **Doc:** Wrapper for nested CPI event payloads.
- **Account variants:**
  - `program, event_authority`
- **Remaining accounts:** yes

### `CreateTokenAccount`
- **Discriminator:** `[147, 241, 123, 100, 244, 132, 174, 118]`
- **Args:**
  - `bump`: `u8`
- **Account variants:**
  - `6 accounts:` `payer, owner, token_account, token_mint, token_program, system_program`
- **Remaining accounts:** yes

### `CreateTokenAccountWithSeed`
- **Discriminator:** `[125, 191, 239, 140, 66, 8, 9, 228]`
- **Args:**
  - `bump`: `u8`
  - `seed`: `u32`
- **Account variants:**
  - `6 accounts:` `payer, owner, token_account, token_mint, token_program, system_program`
- **Remaining accounts:** yes

### `ProxySwap`
- **Discriminator:** `[19, 44, 130, 148, 72, 56, 44, 238]`
- **Args:**
  - `args`: `SwapArgs`
- **Account variants:**
  - `payer, source_token_account, destination_token_account, source_mint, destination_mint, sa_authority?, source_token_sa?, destination_token_sa?, source_token_program?, destination_token_program?, associated_token_program?, system_program?, event_authority, program`
- **Optional accounts:** `sa_authority`, `source_token_sa`, `destination_token_sa`, `source_token_program`, `destination_token_program`, `associated_token_program`, `system_program`
- **Remaining accounts:** yes

### `Swap`
- **Discriminator:** `[248, 198, 158, 145, 225, 117, 135, 200]`
- **Args:**
  - `args`: `SwapArgs`
- **Account variants:**
  - `7 accounts:` `payer, source_token_account, destination_token_account, source_mint, destination_mint, event_authority, program`
- **Remaining accounts:** yes

### `SwapTob`
- **Discriminator:** `[170, 41, 85, 177, 132, 80, 31, 53]`
- **Args:**
  - `args`: `SwapArgs`
  - `commission_info`: `u32`
  - `platform_fee_rate`: `u16`
  - `trim_rate`: `u8`
- **Account variants:**
  - `payer, source_token_account, destination_token_account, source_mint, destination_mint, commission_account?, platform_fee_account?, sa_authority?, source_token_sa?, destination_token_sa?, source_token_program?, destination_token_program?, associated_token_program?, system_program?, event_authority, program`
- **Optional accounts:** `commission_account`, `platform_fee_account`, `sa_authority`, `source_token_sa`, `destination_token_sa`, `source_token_program`, `destination_token_program`, `associated_token_program`, `system_program`
- **Remaining accounts:** yes

### `SwapTobEnhanced`
- **Discriminator:** `[190, 156, 169, 176, 149, 154, 161, 108]`
- **Args:**
  - `args`: `SwapArgs`
  - `commission_info`: `u32`
  - `platform_fee_rate`: `u16`
  - `trim_rate`: `u8`
  - `charge_rate`: `u16`
- **Account variants:** same shape as `SwapTob`
- **Optional accounts:** same as `SwapTob`
- **Remaining accounts:** yes

### `SwapTobWithReceiver`
- **Discriminator:** `[223, 170, 216, 234, 204, 6, 241, 25]`
- **Args:**
  - `args`: `SwapArgs`
  - `commission_info`: `u32`
  - `platform_fee_rate`: `u16`
  - `trim_rate`: `u8`
- **Account variants:** like `SwapTob` plus optional `sol_receiver` before `event_authority, program`
- **Optional accounts:** all of `SwapTob` plus `sol_receiver`
- **Remaining accounts:** yes

### `SwapToc`
- **Discriminator:** `[187, 201, 212, 51, 16, 155, 236, 60]`
- **Args:**
  - `args`: `SwapArgs`
  - `commission_info`: `u32`
  - `platform_fee_rate`: `u16`
- **Account variants:** same shape as `SwapTob`
- **Optional accounts:** same as `SwapTob`
- **Remaining accounts:** yes

### `SwapTocV2`
- **Discriminator:** `[127, 214, 107, 189, 23, 90, 47, 104]`
- **Args:**
  - `args`: `SwapArgs`
  - `total_commission_info`: `u32`
  - `parent_commission_rate`: `u32`
  - `platform_fee_rate`: `u16`
- **Account variants:**
  - `payer, source_token_account, destination_token_account, source_mint, destination_mint, parent_commission_account, child_commission_account, platform_fee_account?, sa_authority?, source_token_sa?, destination_token_sa?, source_token_program?, destination_token_program?, associated_token_program?, system_program?, event_authority, program`
- **Optional accounts:** `platform_fee_account`, `sa_authority`, `source_token_sa`, `destination_token_sa`, `source_token_program`, `destination_token_program`, `associated_token_program`, `system_program`
- **Remaining accounts:** yes

### `WrapUnwrap`
- **Discriminator:** `[220, 101, 139, 249, 41, 190, 118, 199]`
- **Args:**
  - `args`: `PlatformFeeWrapUnwrapArgs`
- **Account variants:**
  - `payer, payer_wsol_account, wsol_mint, temp_wsol_account?, commission_account?, platform_fee_account?, authority_pda?, wsol_sa?, token_program, system_program, event_authority, program`
- **Optional accounts:** `temp_wsol_account`, `commission_account`, `platform_fee_account`, `authority_pda`, `wsol_sa`
- **Remaining accounts:** yes

### `WrapUnwrapWithReceiver`
- **Discriminator:** `[123, 25, 47, 134, 233, 167, 171, 170]`
- **Args:**
  - `args`: `PlatformFeeWrapUnwrapArgs`
- **Account variants:** like `WrapUnwrap` plus required trailing `receiver` before `event_authority, program`
- **Optional accounts:** `temp_wsol_account`, `commission_account`, `platform_fee_account`, `authority_pda`, `wsol_sa`
- **Remaining accounts:** yes

## CPI events

### `SwapCpiEventEvent`
- **Source:** `events/swap_cpi_event.rs`
- **Discriminator:** `[85, 81, 149, 239, 163, 74, 158, 111]`
- **Fields:**
  - `order_id`: `u64`
  - `source_mint`: `Pubkey`
  - `destination_mint`: `Pubkey`
  - `source_token_account_owner`: `Pubkey`
  - `destination_token_account_owner`: `Pubkey`
  - `source_token_change`: `u64`
  - `destination_token_change`: `u64`

### `SwapEventEvent`
- **Source:** `events/swap_event.rs`
- **Discriminator:** `[64, 198, 205, 232, 38, 8, 113, 226]`
- **Fields:**
  - `dex`: `Dex`
  - `amount_in`: `u64`
  - `amount_out`: `u64`

### `SwapToCWithFeesCpiEventV2Event`
- **Source:** `events/swap_to_c_with_fees_cpi_event_v2.rs`
- **Discriminator:** `[71, 137, 74, 60, 189, 117, 182, 65]`
- **Fields:**
  - `order_id`: `u64`
  - `source_mint`: `Pubkey`
  - `destination_mint`: `Pubkey`
  - `source_token_account_owner`: `Pubkey`
  - `destination_token_account_owner`: `Pubkey`
  - `source_token_change`: `u64`
  - `destination_token_change`: `u64`
  - `commission_direction`: `bool`
  - `total_commission_rate`: `u32`
  - `parent_commission_rate`: `u32`
  - `parent_commission_amount`: `u64`
  - `parent_commission_account`: `Pubkey`
  - `child_commission_rate`: `u32`
  - `child_commission_amount`: `u64`
  - `child_commission_account`: `Pubkey`
  - `platform_fee_rate`: `u16`
  - `platform_fee_amount`: `u64`
  - `platform_fee_account`: `Pubkey`

### `SwapWithFeesCpiEventEvent`
- **Source:** `events/swap_with_fees_cpi_event.rs`
- **Discriminator:** `[189, 97, 67, 12, 37, 209, 247, 29]`
- **Fields:**
  - `order_id`: `u64`
  - `source_mint`: `Pubkey`
  - `destination_mint`: `Pubkey`
  - `source_token_account_owner`: `Pubkey`
  - `destination_token_account_owner`: `Pubkey`
  - `source_token_change`: `u64`
  - `destination_token_change`: `u64`
  - `commission_direction`: `bool`
  - `commission_rate`: `u32`
  - `commission_amount`: `u64`
  - `commission_account`: `Pubkey`
  - `platform_fee_rate`: `u16`
  - `platform_fee_amount`: `u64`
  - `platform_fee_account`: `Pubkey`
  - `trim_rate`: `u8`
  - `trim_amount`: `u64`
  - `trim_account`: `Pubkey`

### `SwapWithFeesCpiEventEnhancedEvent`
- **Source:** `events/swap_with_fees_cpi_event_enhanced.rs`
- **Discriminator:** `[37, 72, 219, 67, 50, 244, 1, 213]`
- **Fields:**
  - All fields of `SwapWithFeesCpiEventEvent` plus:
  - `charge_rate`: `u16`
  - `charge_amount`: `u64`
  - `charge_account`: `Pubkey`

## Shared types

### `SwapArgs`
- `order_id`: `u64`
- `amount_in`: `u64`
- `expect_amount_out`: `u64`
- `slippage`: `u16`
- `routes`: `Vec<Route>`

### `Route`
- `dex`: `Dex`
- `weight`: `u16`
- `index`: `u8`

### `PlatformFeeWrapUnwrapArgs`
- `order_id`: `u64`
- `amount_in`: `u64`
- `commission_info`: `u32`
- `platform_fee_rate`: `u16`
- `tob`: `bool`

### `Dex` (enum)
- Variants include: `SplTokenSwap, StableSwap, Whirlpool, MeteoraDynamicpool, RaydiumSwap, RaydiumStableSwap, RaydiumClmmSwap, AldrinExchangeV1, AldrinExchangeV2, LifinityV1, LifinityV2, RaydiumClmmSwapV2, FluxBeam, MeteoraDlmm, RaydiumCpmmSwap, OpenBookV2, WhirlpoolV2, Phoenix, ObricV2, SanctumAddLiq, SanctumRemoveLiq, SanctumNonWsolSwap, SanctumWsolSwap, PumpfunBuy, PumpfunSell, StabbleSwap, SanctumRouter, MeteoraVaultDeposit, MeteoraVaultWithdraw, Saros, MeteoraLst, Solfi, QualiaSwap, Zerofi, PumpfunammBuy, PumpfunammSell, Virtuals, VertigoBuy, VertigoSell, PerpetualsAddLiq, PerpetualsRemoveLiq, PerpetualsSwap, RaydiumLaunchpad, LetsBonkFun, Woofi, MeteoraDbc, MeteoraDlmmSwap2, MeteoraDAMMV2, Gavel, BoopfunBuy, BoopfunSell, MeteoraDbc2, GooseFX, Dooar, Numeraire, SaberDecimalWrapperDeposit, SaberDecimalWrapperWithdraw, SarosDlmm, OneDexSwap, Manifest, ByrealClmm, PancakeSwapV3Swap, PancakeSwapV3SwapV2, Tessera, SolRfq { rfq_id, expected_maker_amount, expected_taker_amount, maker_send_amount, taker_send_amount, expiry, maker_use_native_sol, taker_use_native_sol }, Humidifi, HeavenBuy, HeavenSell, SolfiV2, Goonfi, MoonitBuy, MoonitSell, RaydiumSwapV2, Whalestreet, SugarMoneyBuy { ... }, SugarMoneySell { ... }, MeteoraDAMMV2Swap2, AlphaQ, FutarchyAmm, PumpfunBuy2, PumpfunSell2, HumidifiSwap2 { swap_id }`

### Event payload mirrors (in types/)
- `SwapCpiEvent`, `SwapEvent`, `SwapToCWithFeesCpiEventV2`, `SwapWithFeesCpiEvent`, `SwapWithFeesCpiEventEnhanced` (same fields as the event structs above).
