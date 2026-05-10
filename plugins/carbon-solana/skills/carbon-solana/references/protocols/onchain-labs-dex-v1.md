# OnchainLabs DEX V1

- **Crate:** `carbon-onchain-labs-dex-v1-decoder`
- **Program ID:** `6m2CDdhRgxpH4WjvdzxAYbGxwdGUz5MziiL5jek2kBma`
- **Decoder struct:** `OnchainLabsDexV1Decoder`
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

### `CommissionSolProxySwap`
- **Discriminator:** `[30, 33, 208, 91, 31, 157, 37, 18]`
- **Args:**
  - `data`: `SwapArgs`
  - `commission_rate`: `u16`
  - `commission_direction`: `bool`
  - `order_id`: `u64`
- **Account variants:**
  - `payer, source_token_account, destination_token_account, source_mint, destination_mint, commission_account, sa_authority?, source_token_sa?, destination_token_sa?, source_token_program?, destination_token_program?, associated_token_program?, system_program?`
- **Optional accounts:** `sa_authority`, `source_token_sa`, `destination_token_sa`, `source_token_program`, `destination_token_program`, `associated_token_program`, `system_program`
- **Remaining accounts:** yes

### `CommissionSolSwap`
- **Discriminator:** `[81, 128, 134, 73, 114, 73, 45, 94]`
- **Args:**
  - `data`: `CommissionSwapArgs`
  - `order_id`: `u64`
- **Account variants:**
  - `7 accounts:` `payer, source_token_account, destination_token_account, source_mint, destination_mint, commission_account, system_program`
- **Remaining accounts:** yes

### `CommissionSplProxySwap`
- **Discriminator:** `[96, 67, 12, 151, 129, 164, 18, 71]`
- **Args:**
  - `data`: `SwapArgs`
  - `commission_rate`: `u16`
  - `commission_direction`: `bool`
  - `order_id`: `u64`
- **Account variants:**
  - `payer, source_token_account, destination_token_account, source_mint, destination_mint, commission_token_account, sa_authority?, source_token_sa?, destination_token_sa?, source_token_program?, destination_token_program?, associated_token_program?, system_program?`
- **Optional accounts:** `sa_authority`, `source_token_sa`, `destination_token_sa`, `source_token_program`, `destination_token_program`, `associated_token_program`, `system_program`
- **Remaining accounts:** yes

### `CommissionSplSwap`
- **Discriminator:** `[235, 71, 211, 196, 114, 199, 143, 92]`
- **Args:**
  - `data`: `CommissionSwapArgs`
  - `order_id`: `u64`
- **Account variants:**
  - `7 accounts:` `payer, source_token_account, destination_token_account, source_mint, destination_mint, commission_token_account, token_program`
- **Remaining accounts:** yes

### `CommissionWrapUnwrap`
- **Discriminator:** `[12, 73, 156, 71, 233, 172, 189, 197]`
- **Args:**
  - `data`: `CommissionWrapUnwrapArgs`
  - `order_id`: `u64`
- **Account variants:**
  - `payer, payer_wsol_account, wsol_mint, temp_wsol_account?, commission_sol_account, commission_wsol_account, system_program, token_program`
- **Optional accounts:** `temp_wsol_account`
- **Remaining accounts:** yes

### `CpiEvent`
- **Discriminator:** `[228, 69, 165, 46, 81, 203, 154, 29]`
- **Doc:** Wraps a nested CPI event payload (one of the `events/` variants).
- **Args:**
  - Anchor enum `CpiEvent` (variants for each event type listed in CPI events section)
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

### `PlatformFeeSolProxySwapV2`
- **Discriminator:** `[69, 200, 254, 247, 40, 52, 118, 202]`
- **Args:**
  - `args`: `SwapArgs`
  - `commission_info`: `u32`
  - `platform_fee_rate`: `u32`
  - `trim_rate`: `u8`
  - `order_id`: `u64`
- **Account variants:**
  - `payer, source_token_account, destination_token_account, source_mint, destination_mint, commission_account, sa_authority?, source_token_sa?, destination_token_sa?, source_token_program?, destination_token_program?, associated_token_program?, system_program?`
- **Optional accounts:** `sa_authority`, `source_token_sa`, `destination_token_sa`, `source_token_program`, `destination_token_program`, `associated_token_program`, `system_program`
- **Remaining accounts:** yes

### `PlatformFeeSolWrapUnwrapV2`
- **Discriminator:** `[196, 172, 152, 92, 60, 186, 64, 227]`
- **Args:**
  - `args`: `PlatformFeeWrapUnwrapArgsV2`
  - `order_id`: `u64`
- **Account variants:**
  - `payer, payer_wsol_account, wsol_mint, temp_wsol_account?, commission_sol_account, commission_wsol_account, source_token_sa?, destination_token_sa?, system_program, token_program`
- **Optional accounts:** `temp_wsol_account`, `source_token_sa`, `destination_token_sa`
- **Remaining accounts:** yes

### `PlatformFeeSplProxySwapV2`
- **Discriminator:** `[69, 164, 210, 89, 146, 214, 173, 67]`
- **Args:**
  - `args`: `SwapArgs`
  - `commission_info`: `u32`
  - `platform_fee_rate`: `u32`
  - `trim_rate`: `u8`
  - `order_id`: `u64`
- **Account variants:**
  - `payer, source_token_account, destination_token_account, source_mint, destination_mint, commission_token_account, sa_authority?, source_token_sa?, destination_token_sa?, source_token_program?, destination_token_program?, associated_token_program?, system_program?`
- **Optional accounts:** `sa_authority`, `source_token_sa`, `destination_token_sa`, `source_token_program`, `destination_token_program`, `associated_token_program`, `system_program`
- **Remaining accounts:** yes

### `ProxySwap`
- **Discriminator:** `[19, 44, 130, 148, 72, 56, 44, 238]`
- **Args:**
  - `data`: `SwapArgs`
  - `order_id`: `u64`
- **Account variants:**
  - `payer, source_token_account, destination_token_account, source_mint, destination_mint, sa_authority?, source_token_sa?, destination_token_sa?, source_token_program?, destination_token_program?, associated_token_program?, system_program?`
- **Optional accounts:** `sa_authority`, `source_token_sa`, `destination_token_sa`, `source_token_program`, `destination_token_program`, `associated_token_program`, `system_program`
- **Remaining accounts:** yes

### `Swap`
- **Discriminator:** `[248, 198, 158, 145, 225, 117, 135, 200]`
- **Args:**
  - `data`: `SwapArgs`
  - `order_id`: `u64`
- **Account variants:**
  - `5 accounts:` `payer, source_token_account, destination_token_account, source_mint, destination_mint`
- **Remaining accounts:** yes

### `SwapTobV3`
- **Discriminator:** `[14, 191, 44, 246, 142, 225, 224, 157]`
- **Args:**
  - `args`: `SwapArgs`
  - `commission_info`: `u32`
  - `trim_rate`: `u8`
  - `platform_fee_rate`: `u16`
  - `order_id`: `u64`
- **Account variants:**
  - `payer, source_token_account, destination_token_account, source_mint, destination_mint, commission_account?, platform_fee_account?, sa_authority?, source_token_sa?, destination_token_sa?, source_token_program?, destination_token_program?, associated_token_program?, system_program?`
- **Optional accounts:** `commission_account`, `platform_fee_account`, `sa_authority`, `source_token_sa`, `destination_token_sa`, `source_token_program`, `destination_token_program`, `associated_token_program`, `system_program`
- **Remaining accounts:** yes

### `SwapTobV3Enhanced`
- **Discriminator:** `[236, 71, 155, 68, 198, 98, 14, 118]`
- **Args:**
  - `args`: `SwapArgs`
  - `commission_info`: `u32`
  - `trim_rate`: `u8`
  - `charge_rate`: `u16`
  - `platform_fee_rate`: `u16`
  - `order_id`: `u64`
- **Account variants:** same as `SwapTobV3`
- **Optional accounts:** same as `SwapTobV3`
- **Remaining accounts:** yes

### `SwapTobV3WithReceiver`
- **Discriminator:** `[63, 114, 246, 131, 51, 2, 247, 29]`
- **Doc:** Swap ToB with optional specified receiver.
- **Args:**
  - `args`: `SwapArgs`
  - `commission_info`: `u32`
  - `trim_rate`: `u8`
  - `platform_fee_rate`: `u16`
  - `order_id`: `u64`
- **Account variants:**
  - same as `SwapTobV3` plus optional `sol_receiver` at the end
- **Optional accounts:** all of `SwapTobV3` plus `sol_receiver`
- **Remaining accounts:** yes

### `SwapV3`
- **Discriminator:** `[240, 224, 38, 33, 176, 31, 241, 175]`
- **Args:**
  - `args`: `SwapArgs`
  - `commission_info`: `u32`
  - `platform_fee_rate`: `u16`
  - `order_id`: `u64`
- **Account variants:** same as `SwapTobV3`
- **Optional accounts:** same as `SwapTobV3`
- **Remaining accounts:** yes

### `WrapUnwrapV3`
- **Discriminator:** `[180, 178, 191, 54, 70, 8, 13, 224]`
- **Args:**
  - `args`: `PlatformFeeWrapUnwrapArgs`
- **Account variants:**
  - `payer, payer_wsol_account, wsol_mint, temp_wsol_account?, commission_account?, platform_fee_account?, authority_pda?, wsol_sa?, token_program, system_program`
- **Optional accounts:** `temp_wsol_account`, `commission_account`, `platform_fee_account`, `authority_pda`, `wsol_sa`
- **Remaining accounts:** yes

### `WrapUnwrapV3WithReceiver`
- **Discriminator:** `[70, 211, 190, 165, 47, 40, 213, 95]`
- **Doc:** Wrap/Unwrap with optional specified receiver.
- **Args:**
  - `args`: `PlatformFeeWrapUnwrapArgs`
- **Account variants:** like `WrapUnwrapV3` plus required trailing `receiver`
- **Optional accounts:** `temp_wsol_account`, `commission_account`, `platform_fee_account`, `authority_pda`, `wsol_sa`
- **Remaining accounts:** yes

## CPI events

### `AddResolverEventEvent`
- **Source:** `events/add_resolver_event.rs`
- **Discriminator:** `[173, 137, 29, 251, 195, 58, 115, 71]`
- **Fields:**
  - `resolver`: `Pubkey`

### `CancelOrderEventEvent`
- **Source:** `events/cancel_order_event.rs`
- **Discriminator:** `[174, 66, 141, 17, 4, 224, 162, 77]`
- **Fields:**
  - `order_id`: `u64`
  - `payer`: `Pubkey`
  - `maker`: `Pubkey`
  - `update_ts`: `u64`

### `FillOrderEventEvent`
- **Source:** `events/fill_order_event.rs`
- **Discriminator:** `[37, 51, 197, 130, 53, 15, 99, 18]`
- **Fields:**
  - `order_id`: `u64`
  - `payer`: `Pubkey`
  - `maker`: `Pubkey`
  - `input_token_mint`: `Pubkey`
  - `output_token_mint`: `Pubkey`
  - `making_amount`: `u64`
  - `taking_amount`: `u64`
  - `update_ts`: `u64`

### `InitGlobalConfigEventEvent`
- **Source:** `events/init_global_config_event.rs`
- **Discriminator:** `[195, 252, 133, 149, 47, 126, 107, 231]`
- **Fields:**
  - `admin`: `Pubkey`
  - `trade_fee`: `u64`

### `PauseTradingEventEvent`
- **Source:** `events/pause_trading_event.rs`
- **Discriminator:** `[85, 23, 87, 137, 206, 65, 208, 58]`
- **Fields:**
  - `paused`: `bool`

### `PlaceOrderEventEvent`
- **Source:** `events/place_order_event.rs`
- **Discriminator:** `[65, 191, 25, 91, 27, 252, 192, 40]`
- **Fields:**
  - `order_id`: `u64`
  - `maker`: `Pubkey`
  - `input_token_mint`: `Pubkey`
  - `output_token_mint`: `Pubkey`
  - `making_amount`: `u64`
  - `expect_taking_amount`: `u64`
  - `min_return_amount`: `u64`
  - `create_ts`: `u64`
  - `deadline`: `u64`
  - `trade_fee`: `u64`

### `RefundEventEvent`
- **Source:** `events/refund_event.rs`
- **Discriminator:** `[176, 159, 218, 59, 94, 213, 129, 218]`
- **Fields:**
  - `order_id`: `u64`
  - `maker`: `Pubkey`
  - `input_token_mint`: `Pubkey`
  - `amount`: `u64`

### `RemoveResolverEventEvent`
- **Source:** `events/remove_resolver_event.rs`
- **Discriminator:** `[57, 138, 125, 122, 100, 83, 156, 37]`
- **Fields:**
  - `resolver`: `Pubkey`

### `SetAdminEventEvent`
- **Source:** `events/set_admin_event.rs`
- **Discriminator:** `[240, 117, 204, 254, 89, 150, 132, 94]`
- **Fields:**
  - `admin`: `Pubkey`

### `SetFeeMultiplierEventEvent`
- **Source:** `events/set_fee_multiplier_event.rs`
- **Discriminator:** `[197, 91, 90, 165, 244, 201, 13, 154]`
- **Fields:**
  - `fee_multiplier`: `u8`

### `SetTradeFeeEventEvent`
- **Source:** `events/set_trade_fee_event.rs`
- **Discriminator:** `[8, 97, 163, 68, 79, 99, 134, 229]`
- **Fields:**
  - `trade_fee`: `u64`

### `SwapEventEvent`
- **Source:** `events/swap_event.rs`
- **Discriminator:** `[64, 198, 205, 232, 38, 8, 113, 226]`
- **Fields:**
  - `dex`: `Dex`
  - `amount_in`: `u64`
  - `amount_out`: `u64`

### `UpdateOrderEventEvent`
- **Source:** `events/update_order_event.rs`
- **Discriminator:** `[55, 24, 47, 240, 105, 245, 30, 135]`
- **Fields:**
  - `order_id`: `u64`
  - `maker`: `Pubkey`
  - `expect_taking_amount`: `u64`
  - `min_return_amount`: `u64`
  - `deadline`: `u64`
  - `update_ts`: `u64`
  - `increase_fee`: `u64`

## Shared types

### `SwapArgs`
- `amount_in`: `u64`
- `expect_amount_out`: `u64`
- `min_return`: `u64`
- `amounts`: `Vec<u64>`
- `routes`: `Vec<Vec<Route>>`

### `CommissionSwapArgs`
- `amount_in`: `u64`
- `expect_amount_out`: `u64`
- `min_return`: `u64`
- `amounts`: `Vec<u64>`
- `routes`: `Vec<Vec<Route>>`
- `commission_rate`: `u16`
- `commission_direction`: `bool`

### `CommissionWrapUnwrapArgs`
- `amount_in`: `u64`
- `wrap_direction`: `bool`
- `commission_rate`: `u16`
- `commission_direction`: `bool`

### `PlatformFeeWrapUnwrapArgs`
- `order_id`: `u64`
- `amount_in`: `u64`
- `commission_info`: `u32`
- `platform_fee_rate`: `u16`
- `tob`: `bool`

### `PlatformFeeWrapUnwrapArgsV2`
- `amount_in`: `u64`
- `commission_info`: `u32`
- `platform_fee_rate`: `u32`

### `Route`
- `dexes`: `Vec<Dex>`
- `weights`: `Vec<u8>`

### `Dex` (enum)
- Variants include: `SplTokenSwap, StableSwap, Whirlpool, MeteoraDynamicpool, RaydiumSwap, RaydiumStableSwap, RaydiumClmmSwap, AldrinExchangeV1, AldrinExchangeV2, LifinityV1, LifinityV2, RaydiumClmmSwapV2, FluxBeam, MeteoraDlmm, RaydiumCpmmSwap, OpenBookV2, WhirlpoolV2, Phoenix, ObricV2, SanctumAddLiq, SanctumRemoveLiq, SanctumNonWsolSwap, SanctumWsolSwap, PumpfunBuy, PumpfunSell, StabbleSwap, SanctumRouter, MeteoraVaultDeposit, MeteoraVaultWithdraw, Saros, MeteoraLst, Solfi, QualiaSwap, Zerofi, PumpfunammBuy, PumpfunammSell, Virtuals, VertigoBuy, VertigoSell, PerpetualsAddLiq, PerpetualsRemoveLiq, PerpetualsSwap, RaydiumLaunchpad, LetsBonkFun, Woofi, MeteoraDbc, MeteoraDlmmSwap2, MeteoraDAMMV2, Gavel, BoopfunBuy, BoopfunSell, MeteoraDbc2, GooseFX, Dooar, Numeraire, SaberDecimalWrapperDeposit, SaberDecimalWrapperWithdraw, SarosDlmm, OneDexSwap, Manifest, ByrealClmm, PancakeSwapV3Swap, PancakeSwapV3SwapV2, Tessera, SolRfq { rfq_id, expected_maker_amount, expected_taker_amount, maker_send_amount, taker_send_amount, expiry, maker_use_native_sol, taker_use_native_sol }, PumpfunBuy2, PumpfunammBuy2, Humidifi, HeavenBuy, HeavenSell, SolfiV2, PumpfunBuy3, PumpfunSell3, PumpfunammBuy3, PumpfunammSell3, Goonfi, MoonitBuy, MoonitSell, RaydiumSwapV2, Whalestreet, SugarMoneyBuy { bonding_curve_bump, bonding_curve_sol_associated_account_bump }, SugarMoneySell { ... }, MeteoraDAMMV2Swap2, AlphaQ, FutarchyAmm, PumpfunSell2, HumidifiSwap2 { swap_id }`

### Event payload structs (in types/)
Mirror the CPI events: `AddResolverEvent`, `CancelOrderEvent`, `FillOrderEvent`, `InitGlobalConfigEvent`, `PauseTradingEvent`, `PlaceOrderEvent`, `RefundEvent`, `RemoveResolverEvent`, `SetAdminEvent`, `SetFeeMultiplierEvent`, `SetTradeFeeEvent`, `SwapEvent`, `UpdateOrderEvent` (same fields as the corresponding `*Event` decoded structs above).
