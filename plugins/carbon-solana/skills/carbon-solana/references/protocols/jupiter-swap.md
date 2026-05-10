# Jupiter Swap

- **Crate:** `carbon-jupiter-swap-decoder`
- **Program ID:** `JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4`
- **Decoder struct:** `JupiterSwapDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (events/)
- **Discriminator style:** anchor 8-byte

## Account types

### `TokenLedger`
- **Discriminator:** `[156, 247, 9, 188, 54, 108, 85, 77]`
- **Fields:**
  - `token_account`: `Pubkey`
  - `amount`: `u64`

## Instructions

### `Claim`
- **Discriminator:** `[62, 198, 214, 193, 213, 159, 108, 210]`
- **Args:**
  - `id`: `u8`
- **Account variants:**
  - `3 accounts:` `wallet`, `program_authority`, `system_program`
- **Remaining accounts:** yes

### `ClaimToken`
- **Discriminator:** `[116, 206, 27, 191, 166, 19, 0, 73]`
- **Args:**
  - `id`: `u8`
- **Account variants:**
  - `9 accounts:` `payer`, `wallet`, `program_authority`, `program_token_account`, `destination_token_account`, `mint`, `token_program`, `associated_token_program`, `system_program`
- **Remaining accounts:** yes

### `CloseToken`
- **Discriminator:** `[26, 74, 236, 151, 104, 64, 183, 249]`
- **Args:**
  - `id`: `u8`
  - `burn_all`: `bool`
- **Account variants:**
  - `6 accounts:` `operator`, `wallet`, `program_authority`, `program_token_account`, `mint`, `token_program`
- **Remaining accounts:** yes

### `CpiEvent`
- **Discriminator:** `[228, 69, 165, 46, 81, 203, 154, 29]`
- **Args:** (variant enum dispatched via inner discriminator: `FeeEvent`, `SwapEvent`, `SwapsEvent`, `CandidateSwapResults`, `BestSwapOutAmountViolation`)
- **Account variants:**
  - `2 accounts:` `program`, `event_authority`
- **Remaining accounts:** yes

### `CreateTokenAccount`
- **Discriminator:** `[147, 241, 123, 100, 244, 132, 174, 118]`
- **Args:**
  - `bump`: `u8`
- **Account variants:**
  - `5 accounts:` `token_account`, `user`, `mint`, `token_program`, `system_program`
- **Remaining accounts:** yes

### `CreateTokenLedger`
- **Discriminator:** `[232, 242, 197, 253, 240, 143, 129, 52]`
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `token_ledger`, `payer`, `system_program`
- **Remaining accounts:** yes

### `ExactOutRoute`
- **Discriminator:** `[208, 51, 239, 151, 123, 43, 237, 92]`
- **Args:**
  - `route_plan`: `Vec<RoutePlanStep>`
  - `out_amount`: `u64`
  - `quoted_in_amount`: `u64`
  - `slippage_bps`: `u16`
  - `platform_fee_bps`: `u8`
- **Account variants:**
  - `11 accounts:` `token_program`, `user_transfer_authority`, `user_source_token_account`, `user_destination_token_account`, `destination_token_account`, `source_mint`, `destination_mint`, `platform_fee_account`, `token2022_program`, `event_authority`, `program`
- **Optional accounts:** `destination_token_account`, `platform_fee_account`, `token2022_program`
- **Remaining accounts:** yes

### `ExactOutRouteV2`
- **Discriminator:** `[157, 138, 184, 82, 21, 244, 243, 36]`
- **Args:**
  - `out_amount`: `u64`
  - `quoted_in_amount`: `u64`
  - `slippage_bps`: `u16`
  - `platform_fee_bps`: `u16`
  - `positive_slippage_bps`: `u16`
  - `route_plan`: `Vec<RoutePlanStepV2>`
- **Account variants:**
  - `10 accounts:` `user_transfer_authority`, `user_source_token_account`, `user_destination_token_account`, `source_mint`, `destination_mint`, `source_token_program`, `destination_token_program`, `destination_token_account`, `event_authority`, `program`
- **Optional accounts:** `destination_token_account`
- **Remaining accounts:** yes

### `Route`
- **Discriminator:** `[229, 23, 203, 151, 122, 227, 173, 42]`
- **Args:**
  - `route_plan`: `Vec<RoutePlanStep>`
  - `in_amount`: `u64`
  - `quoted_out_amount`: `u64`
  - `slippage_bps`: `u16`
  - `platform_fee_bps`: `u8`
- **Account variants:**
  - `9 accounts:` `token_program`, `user_transfer_authority`, `user_source_token_account`, `user_destination_token_account`, `destination_token_account`, `destination_mint`, `platform_fee_account`, `event_authority`, `program`
- **Optional accounts:** `destination_token_account`, `platform_fee_account`
- **Remaining accounts:** yes

### `RouteV2`
- **Discriminator:** `[187, 100, 250, 204, 49, 196, 175, 20]`
- **Args:**
  - `in_amount`: `u64`
  - `quoted_out_amount`: `u64`
  - `slippage_bps`: `u16`
  - `platform_fee_bps`: `u16`
  - `positive_slippage_bps`: `u16`
  - `route_plan`: `Vec<RoutePlanStepV2>`
- **Account variants:**
  - `10 accounts:` `user_transfer_authority`, `user_source_token_account`, `user_destination_token_account`, `source_mint`, `destination_mint`, `source_token_program`, `destination_token_program`, `destination_token_account`, `event_authority`, `program`
- **Optional accounts:** `destination_token_account`
- **Remaining accounts:** yes

### `RouteWithTokenLedger`
- **Discriminator:** `[150, 86, 71, 116, 167, 93, 14, 104]`
- **Args:**
  - `route_plan`: `Vec<RoutePlanStep>`
  - `quoted_out_amount`: `u64`
  - `slippage_bps`: `u16`
  - `platform_fee_bps`: `u8`
- **Account variants:**
  - `10 accounts:` `token_program`, `user_transfer_authority`, `user_source_token_account`, `user_destination_token_account`, `destination_token_account`, `destination_mint`, `platform_fee_account`, `token_ledger`, `event_authority`, `program`
- **Optional accounts:** `destination_token_account`, `platform_fee_account`
- **Remaining accounts:** yes

### `SetTokenLedger`
- **Discriminator:** `[228, 85, 185, 112, 78, 79, 77, 2]`
- **Args:** (none)
- **Account variants:**
  - `2 accounts:` `token_ledger`, `token_account`
- **Remaining accounts:** yes

### `SharedAccountsExactOutRoute`
- **Discriminator:** `[176, 209, 105, 168, 154, 125, 69, 62]`
- **Args:**
  - `id`: `u8`
  - `route_plan`: `Vec<RoutePlanStep>`
  - `out_amount`: `u64`
  - `quoted_in_amount`: `u64`
  - `slippage_bps`: `u16`
  - `platform_fee_bps`: `u8`
- **Account variants:**
  - `13 accounts:` `token_program`, `program_authority`, `user_transfer_authority`, `source_token_account`, `program_source_token_account`, `program_destination_token_account`, `destination_token_account`, `source_mint`, `destination_mint`, `platform_fee_account`, `token2022_program`, `event_authority`, `program`
- **Optional accounts:** `platform_fee_account`, `token2022_program`
- **Remaining accounts:** yes

### `SharedAccountsExactOutRouteV2`
- **Discriminator:** `[53, 96, 229, 202, 216, 187, 250, 24]`
- **Args:**
  - `id`: `u8`
  - `out_amount`: `u64`
  - `quoted_in_amount`: `u64`
  - `slippage_bps`: `u16`
  - `platform_fee_bps`: `u16`
  - `positive_slippage_bps`: `u16`
  - `route_plan`: `Vec<RoutePlanStepV2>`
- **Account variants:**
  - `12 accounts:` `program_authority`, `user_transfer_authority`, `source_token_account`, `program_source_token_account`, `program_destination_token_account`, `destination_token_account`, `source_mint`, `destination_mint`, `source_token_program`, `destination_token_program`, `event_authority`, `program`
- **Remaining accounts:** yes

### `SharedAccountsRoute`
- **Discriminator:** `[193, 32, 155, 51, 65, 214, 156, 129]`
- **Args:**
  - `id`: `u8`
  - `route_plan`: `Vec<RoutePlanStep>`
  - `in_amount`: `u64`
  - `quoted_out_amount`: `u64`
  - `slippage_bps`: `u16`
  - `platform_fee_bps`: `u8`
- **Account variants:**
  - `13 accounts:` `token_program`, `program_authority`, `user_transfer_authority`, `source_token_account`, `program_source_token_account`, `program_destination_token_account`, `destination_token_account`, `source_mint`, `destination_mint`, `platform_fee_account`, `token2022_program`, `event_authority`, `program`
- **Optional accounts:** `platform_fee_account`, `token2022_program`
- **Remaining accounts:** yes

### `SharedAccountsRouteV2`
- **Discriminator:** `[209, 152, 83, 147, 124, 254, 216, 233]`
- **Args:**
  - `id`: `u8`
  - `in_amount`: `u64`
  - `quoted_out_amount`: `u64`
  - `slippage_bps`: `u16`
  - `platform_fee_bps`: `u16`
  - `positive_slippage_bps`: `u16`
  - `route_plan`: `Vec<RoutePlanStepV2>`
- **Account variants:**
  - `12 accounts:` `program_authority`, `user_transfer_authority`, `source_token_account`, `program_source_token_account`, `program_destination_token_account`, `destination_token_account`, `source_mint`, `destination_mint`, `source_token_program`, `destination_token_program`, `event_authority`, `program`
- **Remaining accounts:** yes

### `SharedAccountsRouteWithTokenLedger`
- **Discriminator:** `[230, 121, 143, 80, 119, 159, 106, 170]`
- **Args:**
  - `id`: `u8`
  - `route_plan`: `Vec<RoutePlanStep>`
  - `quoted_out_amount`: `u64`
  - `slippage_bps`: `u16`
  - `platform_fee_bps`: `u8`
- **Account variants:**
  - `14 accounts:` `token_program`, `program_authority`, `user_transfer_authority`, `source_token_account`, `program_source_token_account`, `program_destination_token_account`, `destination_token_account`, `source_mint`, `destination_mint`, `platform_fee_account`, `token2022_program`, `token_ledger`, `event_authority`, `program`
- **Optional accounts:** `platform_fee_account`, `token2022_program`
- **Remaining accounts:** yes

## CPI events

### `BestSwapOutAmountViolationEvent`
- **Source:** `events/best_swap_out_amount_violation.rs`
- **Discriminator:** `[124, 66, 196, 51, 218, 173, 46, 93]`
- **Fields:**
  - `expected_out_amount`: `u64`
  - `out_amount`: `u64`

### `CandidateSwapResultsEvent`
- **Source:** `events/candidate_swap_results.rs`
- **Discriminator:** `[45, 9, 244, 30, 229, 52, 168, 123]`
- **Fields:**
  - `results`: `Vec<CandidateSwapResult>`

### `FeeEventEvent`
- **Source:** `events/fee_event.rs`
- **Discriminator:** `[73, 79, 78, 127, 184, 213, 13, 220]`
- **Fields:**
  - `account`: `Pubkey`
  - `mint`: `Pubkey`
  - `amount`: `u64`

### `SwapEventEvent`
- **Source:** `events/swap_event.rs`
- **Discriminator:** `[64, 198, 205, 232, 38, 8, 113, 226]`
- **Fields:**
  - `amm`: `Pubkey`
  - `input_mint`: `Pubkey`
  - `input_amount`: `u64`
  - `output_mint`: `Pubkey`
  - `output_amount`: `u64`

### `SwapsEventEvent`
- **Source:** `events/swaps_event.rs`
- **Discriminator:** `[152, 47, 78, 235, 192, 96, 110, 106]`
- **Fields:**
  - `swap_events`: `Vec<SwapEventV2>`

## Shared types

### `AccountsType` (enum)
- `TransferHookA`
- `TransferHookB`
- `TransferHookReward`
- `TransferHookInput`
- `TransferHookIntermediate`
- `TransferHookOutput`
- `SupplementalTickArrays`
- `SupplementalTickArraysOne`
- `SupplementalTickArraysTwo`

### `BestSwapOutAmountViolation`
- `expected_out_amount`: `u64`
- `out_amount`: `u64`

### `CandidateSwap` (enum)
- `HumidiFi { swap_id: u64, is_base_to_quote: bool }`
- `TesseraV { side: Side }`

### `CandidateSwapResult` (enum)
- `OutAmount(u64)`
- `ProgramError(u64)`

### `CandidateSwapResults`
- `results`: `Vec<CandidateSwapResult>`

### `DefiTunaAccountsType` (enum)
- `TransferHookA`
- `TransferHookB`
- `TransferHookInput`
- `TransferHookIntermediate`
- `TransferHookOutput`
- `SupplementalTickArrays`
- `SupplementalTickArraysOne`
- `SupplementalTickArraysTwo`

### `FeeEvent`
- `account`: `Pubkey`
- `mint`: `Pubkey`
- `amount`: `u64`

### `RemainingAccountsInfo`
- `slices`: `Vec<RemainingAccountsSlice>`

### `RemainingAccountsSlice`
- `accounts_type`: `u8`
- `length`: `u8`

### `RoutePlanStep`
- `swap`: `Swap`
- `percent`: `u8`
- `input_index`: `u8`
- `output_index`: `u8`

### `RoutePlanStepV2`
- `swap`: `Swap`
- `bps`: `u16`
- `input_index`: `u8`
- `output_index`: `u8`

### `Side` (enum)
- `Bid`
- `Ask`

### `Swap` (enum)
- `Saber`
- `SaberAddDecimalsDeposit`
- `SaberAddDecimalsWithdraw`
- `TokenSwap`
- `Sencha`
- `Step`
- `Cropper`
- `Raydium`
- `Crema { a_to_b: bool }`
- `Lifinity`
- `Mercurial`
- `Cykura`
- `Serum { side: Side }`
- `MarinadeDeposit`
- `MarinadeUnstake`
- `Aldrin { side: Side }`
- `AldrinV2 { side: Side }`
- `Whirlpool { a_to_b: bool }`
- `Invariant { x_to_y: bool }`
- `Meteora`
- `GooseFX`
- `DeltaFi { stable: bool }`
- `Balansol`
- `MarcoPolo { x_to_y: bool }`
- `Dradex { side: Side }`
- `LifinityV2`
- `RaydiumClmm`
- `Openbook { side: Side }`
- `Phoenix { side: Side }`
- `Symmetry { from_token_id: u64, to_token_id: u64 }`
- `TokenSwapV2`
- `HeliumTreasuryManagementRedeemV0`
- `StakeDexStakeWrappedSol`
- `StakeDexSwapViaStake { bridge_stake_seed: u32 }`
- `GooseFXV2`
- `Perps`
- `PerpsAddLiquidity`
- `PerpsRemoveLiquidity`
- `MeteoraDlmm`
- `OpenBookV2 { side: Side }`
- `RaydiumClmmV2`
- `StakeDexPrefundWithdrawStakeAndDepositStake { bridge_stake_seed: u32 }`
- `Clone { pool_index: u8, quantity_is_input: bool, quantity_is_collateral: bool }`
- `SanctumS { src_lst_value_calc_accs: u8, dst_lst_value_calc_accs: u8, src_lst_index: u32, dst_lst_index: u32 }`
- `SanctumSAddLiquidity { lst_value_calc_accs: u8, lst_index: u32 }`
- `SanctumSRemoveLiquidity { lst_value_calc_accs: u8, lst_index: u32 }`
- `RaydiumCP`
- `WhirlpoolSwapV2 { a_to_b: bool, remaining_accounts_info: Option<RemainingAccountsInfo> }`
- `OneIntro`
- `PumpWrappedBuy`
- `PumpWrappedSell`
- `PerpsV2`
- `PerpsV2AddLiquidity`
- `PerpsV2RemoveLiquidity`
- `MoonshotWrappedBuy`
- `MoonshotWrappedSell`
- `StabbleStableSwap`
- `StabbleWeightedSwap`
- `Obric { x_to_y: bool }`
- `FoxBuyFromEstimatedCost`
- `FoxClaimPartial { is_y: bool }`
- `SolFi { is_quote_to_base: bool }`
- `SolayerDelegateNoInit`
- `SolayerUndelegateNoInit`
- `TokenMill { side: Side }`
- `DaosFunBuy`
- `DaosFunSell`
- `ZeroFi`
- `StakeDexWithdrawWrappedSol`
- `VirtualsBuy`
- `VirtualsSell`
- `Perena { in_index: u8, out_index: u8 }`
- `PumpSwapBuy`
- `PumpSwapSell`
- `Gamma`
- `MeteoraDlmmSwapV2 { remaining_accounts_info: RemainingAccountsInfo }`
- `Woofi`
- `MeteoraDammV2`
- `MeteoraDynamicBondingCurveSwap`
- `StabbleStableSwapV2`
- `StabbleWeightedSwapV2`
- `RaydiumLaunchlabBuy { share_fee_rate: u64 }`
- `RaydiumLaunchlabSell { share_fee_rate: u64 }`
- `BoopdotfunWrappedBuy`
- `BoopdotfunWrappedSell`
- `Plasma { side: Side }`
- `GoonFi { is_bid: bool, blacklist_bump: u8 }`
- `HumidiFi { swap_id: u64, is_base_to_quote: bool }`
- `MeteoraDynamicBondingCurveSwapWithRemainingAccounts`
- `TesseraV { side: Side }`
- `PumpWrappedBuyV2`
- `PumpWrappedSellV2`
- `PumpSwapBuyV2`
- `PumpSwapSellV2`
- `Heaven { a_to_b: bool }`
- `SolFiV2 { is_quote_to_base: bool }`
- `Aquifer`
- `PumpWrappedBuyV3`
- `PumpWrappedSellV3`
- `PumpSwapBuyV3`
- `PumpSwapSellV3`
- `JupiterLendDeposit`
- `JupiterLendRedeem`
- `DefiTuna { a_to_b: bool, remaining_accounts_info: Option<RemainingAccountsInfo> }`
- `AlphaQ { a_to_b: bool }`
- `RaydiumV2`
- `SarosDlmm { swap_for_y: bool }`
- `Futarchy { side: Side }`
- `MeteoraDammV2WithRemainingAccounts`
- `Obsidian`
- `WhaleStreet { side: Side }`
- `DynamicV1 { candidate_swaps: Vec<CandidateSwap> }`
- `PumpWrappedBuyV4`
- `PumpWrappedSellV4`

### `SwapEvent`
- `amm`: `Pubkey`
- `input_mint`: `Pubkey`
- `input_amount`: `u64`
- `output_mint`: `Pubkey`
- `output_amount`: `u64`

### `SwapEventV2`
- `input_mint`: `Pubkey`
- `input_amount`: `u64`
- `output_mint`: `Pubkey`
- `output_amount`: `u64`

### `SwapsEvent`
- `swap_events`: `Vec<SwapEventV2>`
