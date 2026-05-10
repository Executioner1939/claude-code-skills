# DFlow Aggregator V4

- **Crate:** `carbon-dflow-aggregator-v4-decoder`
- **Program ID:** `DF1ow4tspfHX9JwWJsAb9epbkA8hmpSEAtxXy1V27QBH`
- **Decoder struct:** `SwapOrchestratorDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (events/)
- **Discriminator style:** anchor 8-byte

## Account types

### `Order`
- **Discriminator:** `[134, 173, 223, 185, 77, 86, 28, 51]`
- **Fields:**
  - `closer`: `Pubkey` *(Account that is authorized to close the order)*
  - `output_token_account`: `Pubkey` *(Account to which output from the fill should be sent.)*
  - `return_input_token_account`: `Pubkey` *(Account to which leftover tokens in the order vault should be returned when the order is filled or closed.)*
  - `return_rent_to`: `Pubkey` *(Account to which rent for the account should be returned when the account is closed)*
  - `id`: `u64` *(ID used to produce a unique PDA for the order account)*
  - `quoted_out_amount`: `u64`
  - `last_fillable_slot`: `u64` *(Highest slot at which the order can be filled)*
  - `slippage_bps`: `u16` *(Max allowed slippage in basis points.)*
  - `bump`: `u8`
  - `vault_bump`: `u8` *(Bump seed for the vault token account associated with the order)*
  - `flags`: `u8` *(Flags for the order)*
  - `padding1`: `u8`
  - `padding2`: `u8`
  - `padding3`: `u8`

## Instructions

### `CloseOrder`
- **Discriminator:** `[90, 103, 209, 28, 7, 63, 168, 4]`
- **Doc:** Closes an order, returning tokens from the order vault.
- **Args:** (none)
- **Account variants:**
  - `7 accounts:` `order`, `order_vault`, `return_input_token_account`, `return_rent_to`, `closer`, `token_program`, `system_program`
- **Remaining accounts:** yes

### `CpiEvent`
- **Discriminator:** `[228, 69, 165, 46, 81, 203, 154, 29]`
- **Args:** (none) *(an enum dispatching on inner event discriminator: `FeeEvent` or `SwapEvent`)*
- **Account variants:**
  - `2 accounts:` `program`, `event_authority`
- **Remaining accounts:** yes

### `CreateReferralTokenAccountIdempotent`
- **Discriminator:** `[46, 232, 41, 144, 85, 37, 170, 175]`
- **Doc:** Create a referral token account if it doesn't already exist.
- **Args:** (none)
- **Account variants:**
  - `8 accounts:` `payer`, `project`, `referral_account`, `referral_token_account`, `mint`, `system_program`, `token_program`, `referral_program`
- **Remaining accounts:** yes

### `FillOrder`
- **Discriminator:** `[232, 122, 115, 25, 199, 143, 136, 162]`
- **Doc:** Fills an order, closing the order after filling it.
- **Args:**
  - `params`: `FillOrderParams`
- **Account variants:**
  - `15 accounts:` `order`, `order_vault`, `output_token_account`, `return_input_token_account`, `return_rent_to`, `filler_input_token_account`, `input_mint`, `filler_output_token_account`, `output_mint`, `filler`, `token_program`, `associated_token_program`, `system_program`, `event_authority`, `program`
- **Optional accounts:** `input_mint`, `output_mint`
- **Remaining accounts:** yes

### `OpenOrder`
- **Discriminator:** `[206, 88, 88, 143, 38, 136, 50, 224]`
- **Doc:** Opens an order, escrowing the input tokens in the order vault.
- **Args:**
  - `params`: `OpenOrderParams`
- **Account variants:**
  - `13 accounts:` `order`, `order_vault`, `input_token_account`, `output_token_account`, `return_input_token_account`, `input_mint`, `user_token_authority`, `fee_payer`, `fee_receiver`, `rent_depositor`, `token_program`, `system_program`, `rent`
- **Remaining accounts:** yes

### `Swap`
- **Discriminator:** `[248, 198, 158, 145, 225, 117, 135, 200]`
- **Doc:** Executes a token swap.
- **Args:**
  - `params`: `SwapParams`
- **Account variants:**
  - `6 accounts:` `token_program`, `associated_token_program`, `system_program`, `user_token_authority`, `event_authority`, `program`
- **Remaining accounts:** yes

### `Swap2`
- **Discriminator:** `[65, 75, 63, 76, 235, 91, 91, 136]`
- **Doc:** Executes a token swap with a slippage fee.
- **Args:**
  - `params`: `Swap2Params`
- **Account variants:**
  - `6 accounts:` `token_program`, `associated_token_program`, `system_program`, `user_token_authority`, `event_authority`, `program`
- **Remaining accounts:** yes

### `Swap2WithDestination`
- **Discriminator:** `[95, 123, 213, 246, 122, 1, 86, 231]`
- **Doc:** Executes a token swap with a slippage fee.
- **Args:**
  - `params`: `Swap2Params`
- **Account variants:**
  - `9 accounts:` `token_program`, `associated_token_program`, `system_program`, `user_token_authority`, `destination_token_account`, `destination_token_authority`, `destination_mint`, `event_authority`, `program`
- **Remaining accounts:** yes

### `Swap2WithDestinationNative`
- **Discriminator:** `[222, 100, 184, 146, 186, 196, 105, 165]`
- **Doc:** Executes a token swap with a slippage fee.
- **Args:**
  - `params`: `Swap2Params`
- **Account variants:**
  - `7 accounts:` `token_program`, `associated_token_program`, `system_program`, `user_token_authority`, `destination_account`, `event_authority`, `program`
- **Remaining accounts:** yes

### `SwapWithDestination`
- **Discriminator:** `[168, 172, 24, 77, 197, 156, 135, 101]`
- **Doc:** Executes a token swap.
- **Args:**
  - `params`: `SwapParams`
- **Account variants:**
  - `9 accounts:` `token_program`, `associated_token_program`, `system_program`, `user_token_authority`, `destination_token_account`, `destination_token_authority`, `destination_mint`, `event_authority`, `program`
- **Remaining accounts:** yes

### `SwapWithDestinationNative`
- **Discriminator:** `[205, 77, 127, 108, 241, 32, 196, 195]`
- **Doc:** Executes a token swap.
- **Args:**
  - `params`: `SwapParams`
- **Account variants:**
  - `7 accounts:` `token_program`, `associated_token_program`, `system_program`, `user_token_authority`, `destination_account`, `event_authority`, `program`
- **Remaining accounts:** yes

### `TransferFee`
- **Discriminator:** `[129, 164, 196, 21, 177, 48, 180, 162]`
- **Doc:** Transfer an SPL token fee if the receiving account can receive it.
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `6 accounts:` `from`, `to`, `authority`, `token_program`, `event_authority`, `program`
- **Remaining accounts:** yes

### `TransferSol`
- **Discriminator:** `[78, 10, 236, 247, 109, 117, 21, 76]`
- **Doc:** Transfer native SOL from one account to another.
- **Args:**
  - `lamports`: `u64`
- **Account variants:**
  - `3 accounts:` `from`, `to`, `system_program`
- **Remaining accounts:** yes

### `TransferToSponsor`
- **Discriminator:** `[155, 179, 130, 151, 196, 139, 253, 163]`
- **Doc:** Transfer an SPL token to a sponsor's token account, creating the sponsor's token account if necessary.
- **Args:**
  - `amount`: `u64`
- **Account variants:**
  - `8 accounts:` `user_token_authority`, `user_token_account`, `sponsor`, `sponsor_token_account`, `mint`, `token_program`, `associated_token_program`, `system_program`
- **Remaining accounts:** yes

### `UnwrapSol`
- **Discriminator:** `[99, 40, 14, 105, 45, 107, 172, 201]`
- **Doc:** Unwrap all SOL in the provided wrapped SOL token account.
- **Args:** (none)
- **Account variants:**
  - `3 accounts:` `owner`, `wrapped_sol_associated_token_account`, `token_program`
- **Remaining accounts:** yes

### `WrapSol`
- **Discriminator:** `[47, 62, 155, 172, 131, 205, 37, 201]`
- **Doc:** Wrap SOL, creating a wrapped SOL associated token account if necessary.
- **Args:**
  - `lamports`: `u64`
- **Account variants:**
  - `6 accounts:` `from`, `wrapped_sol_associated_token_account`, `native_mint`, `token_program`, `associated_token_program`, `system_program`
- **Remaining accounts:** yes

## CPI events

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

## Shared types

### `Action`
- Enum variants: `WhirlpoolsSwap(WhirlpoolsSwapOptions)`, `ClearpoolsSwap(ClearpoolsSwapOptions)`, `RaydiumAmmSwap(RaydiumAmmSwapOptions)`, `LifinityV2Swap(LifinityV2SwapOptions)`, `MeteoraDlmmSwap(MeteoraDlmmSwapOptions)`, `RaydiumClmmSwap(RaydiumClmmSwapOptions)`, `RaydiumClmmSwapV2(RaydiumClmmSwapV2Options)`, `PhoenixSwap(PhoenixSwapOptions)`, `PumpFunBuy(PumpFunBuyOptions)`, `PumpFunSell(PumpFunSellOptions)`, `GammaSwap(GammaSwapOptions)`, `ObricV2Swap(ObricV2SwapOptions)`, `PumpFunAmmBuy(PumpFunAmmBuyOptions)`, `PumpFunAmmSell(PumpFunAmmSellOptions)`, `SolFiSwap(SolFiSwapOptions)`, `RubiconSwap(RubiconSwapOptions)`, `MeteoraDammV1Swap(MeteoraDammV1SwapOptions)`, `RaydiumCpSwap(RaydiumCpSwapOptions)`, `StabbleStableSwap(StabbleStableSwapOptions)`, `TesseraVSwap(TesseraVSwapOptions)`, `MeteoraDammV2Swap(MeteoraDammV2SwapOptions)`, `RaydiumLaunchlabSwap(RaydiumLaunchlabSwapOptions)`, `MeteoraDbcSwap(MeteoraDbcSwapOptions)`, `HumidiFiSwap(HumidiFiSwapOptions)`, `WhirlpoolsSwapV2(WhirlpoolsSwapV2Options)`, `MeteoraDlmmSwapV2(MeteoraDlmmSwapV2Options)`, `ZeroFiSwap(ZeroFiSwapOptions)`, `AlphaQSwap(AlphaQSwapOptions)`, `TokenSwap(TokenSwapOptions)`, `SolFiV2Swap(SolFiV2SwapOptions)`, `MozartSwap(MozartSwapOptions)`, `DFlowDynamicRouteV1(DFlowDynamicRouteV1Options)`, `HeavenSwap(HeavenSwapOptions)`, `NexusSwap(NexusSwapOptions)`, `SarosDlmmSwap(SarosDlmmSwapOptions)`, `TransferFee(TransferFeeOptions)`, `TransferFeeWithMint(TransferFeeOptions)`, `RecordId(RecordIdOptions)`, `RecordId2(RecordId2Options)`, `ManifestSwap(ManifestSwapOptions)`

### `AlphaQSwapOptions`
- `amount`: `u64`
- `orchestrator_flags`: `OrchestratorFlags`

### `ClearpoolsSwapOptions`
- `amount`: `u64`
- `a_to_b`: `bool`
- `orchestrator_flags`: `OrchestratorFlags`

### `DFlowDynamicRouteV1Options`
- `candidate_actions`: `Vec<DynamicRouteV1CandidateAction>`
- `amount`: `u64`
- `orchestrator_flags`: `OrchestratorFlags`

### `DynamicRouteV1CandidateAction`
- Enum variants: `SolFi(SolFiDynamicRouteV1Options)`, `Rubicon(RubiconDynamicRouteV1Options)`, `TesseraV(TesseraVDynamicRouteV1Options)`, `HumidiFi(HumidiFiDynamicRouteV1Options)`, `SolFiV2(SolFiV2DynamicRouteV1Options)`, `Mozart(MozartDynamicRouteV1Options)`, `ObricV2(ObricV2DynamicRouteV1Options)`, `Nexus(NexusDynamicRouteV1Options)`

### `FeeEvent`
- `account`: `Pubkey`
- `mint`: `Pubkey`
- `amount`: `u64`

### `FillOrderParams`
- `swap_actions`: `Vec<Action>`
- `platform_fee_ubps`: `u32`

### `GammaSwapOptions`
- `amount`: `u64`
- `endorsed`: `bool`
- `orchestrator_flags`: `OrchestratorFlags`

### `HeavenSwapOptions`
- `amount`: `u64`
- `orchestrator_flags`: `OrchestratorFlags`

### `HumidiFiDynamicRouteV1Options`
- `swap_id`: `u64`

### `HumidiFiSwapOptions`
- `amount`: `u64`
- `swap_id`: `u64`
- `orchestrator_flags`: `OrchestratorFlags`

### `LifinityV2SwapOptions`
- `amount`: `u64`
- `orchestrator_flags`: `OrchestratorFlags`

### `ManifestSwapOptions`
- `amount`: `u64`
- `orchestrator_flags`: `OrchestratorFlags`

### `MeteoraDammV1SwapOptions`
- `amount`: `u64`
- `orchestrator_flags`: `OrchestratorFlags`

### `MeteoraDammV2SwapOptions`
- `amount`: `u64`
- `orchestrator_flags`: `OrchestratorFlags`

### `MeteoraDbcSwapOptions`
- `amount`: `u64`
- `is_rate_limiter_applied`: `bool`
- `orchestrator_flags`: `OrchestratorFlags`

### `MeteoraDlmmSwapOptions`
- `amount`: `u64`
- `num_bin_arrays`: `u8`
- `orchestrator_flags`: `OrchestratorFlags`

### `MeteoraDlmmSwapV2Options`
- `amount`: `u64`
- `num_bin_arrays`: `u8`
- `orchestrator_flags`: `OrchestratorFlags`

### `MozartDynamicRouteV1Options`
- (no fields)

### `MozartSwapOptions`
- `amount`: `u64`
- `orchestrator_flags`: `OrchestratorFlags`

### `NexusDynamicRouteV1Options`
- (no fields)

### `NexusSwapOptions`
- `amount`: `u64`
- `orchestrator_flags`: `OrchestratorFlags`

### `ObricV2DynamicRouteV1Options`
- (no fields)

### `ObricV2SwapOptions`
- `amount`: `u64`
- `orchestrator_flags`: `OrchestratorFlags`

### `OpenOrderParams`
- `input_amount`: `u64`
- `quoted_out_amount`: `u64` *(Quoted output amount after platform fee)*
- `fee_budget`: `u64` *(Maximum amount in lamports that the fee payer will pay to have the order filled or closed)*
- `order_account_id`: `u64`
- `fillable_for_slots`: `u32` *(Number of slots after the slot in which the order is opened for which the order is fillable.)*
- `slippage_bps`: `u16` *(Max allowed slippage in basis points.)*
- `closer`: `Pubkey` *(Account that is authorized to close the order)*
- `flags`: `u8` *(Flags for the order)*

### `OrchestratorFlags`
- `flags`: `u8`

### `PhoenixSwapOptions`
- `amount`: `u64`
- `side`: `Side`
- `orchestrator_flags`: `OrchestratorFlags`

### `PumpFunAmmBuyOptions`
- `amount`: `u64`
- `orchestrator_flags`: `OrchestratorFlags`

### `PumpFunAmmSellOptions`
- `amount`: `u64`
- `orchestrator_flags`: `OrchestratorFlags`

### `PumpFunBuyOptions`
- `amount`: `u64`
- `orchestrator_flags`: `OrchestratorFlags`

### `PumpFunSellOptions`
- `amount`: `u64`
- `orchestrator_flags`: `OrchestratorFlags`

### `RaydiumAmmSwapOptions`
- `amount`: `u64`
- `orchestrator_flags`: `OrchestratorFlags`

### `RaydiumClmmSwapOptions`
- `amount`: `u64`
- `num_remaining_accounts`: `u8`
- `orchestrator_flags`: `OrchestratorFlags`

### `RaydiumClmmSwapV2Options`
- `amount`: `u64`
- `num_remaining_accounts`: `u8`
- `orchestrator_flags`: `OrchestratorFlags`

### `RaydiumCpSwapOptions`
- `amount`: `u64`
- `orchestrator_flags`: `OrchestratorFlags`

### `RaydiumLaunchlabSwapOptions`
- `amount`: `u64`
- `orchestrator_flags`: `OrchestratorFlags`

### `RecordId2Options`
- `id`: `[u8; 4]`

### `RecordIdOptions`
- `id`: `[u8; 76]`

### `RubiconDynamicRouteV1Options`
- (no fields)

### `RubiconSwapOptions`
- `amount`: `u64`
- `orchestrator_flags`: `OrchestratorFlags`

### `SarosDlmmSwapOptions`
- `amount`: `u64`
- `orchestrator_flags`: `OrchestratorFlags`

### `Side`
- Enum variants: `Bid`, `Ask`

### `SolFiDynamicRouteV1Options`
- (no fields)

### `SolFiSwapOptions`
- `amount`: `u64`
- `orchestrator_flags`: `OrchestratorFlags`

### `SolFiV2DynamicRouteV1Options`
- (no fields)

### `SolFiV2SwapOptions`
- `amount`: `u64`
- `orchestrator_flags`: `OrchestratorFlags`

### `StabbleStableSwapOptions`
- `amount`: `u64`
- `orchestrator_flags`: `OrchestratorFlags`

### `Swap2Params`
- `actions`: `Vec<Action>`
- `quoted_out_amount`: `u64` *(Quoted output amount for the swap after platform fee)*
- `slippage_bps`: `u16` *(Max allowed slippage in basis points.)*
- `platform_fee_bps`: `u16` *(Platform fee in basis points.)*
- `positive_slippage_fee_limit_pct`: `u8` *(Limit on the positive slippage fee in percent.)*

### `SwapEvent`
- `amm`: `Pubkey`
- `input_mint`: `Pubkey`
- `input_amount`: `u64`
- `output_mint`: `Pubkey`
- `output_amount`: `u64`

### `SwapParams`
- `actions`: `Vec<Action>`
- `quoted_out_amount`: `u64` *(Quoted output amount for the swap after platform fee)*
- `slippage_bps`: `u16` *(Max allowed slippage in basis points.)*
- `platform_fee_bps`: `u16` *(Platform fee in basis points.)*

### `TesseraVDynamicRouteV1Options`
- (no fields)

### `TesseraVSwapOptions`
- `amount`: `u64`
- `orchestrator_flags`: `OrchestratorFlags`

### `TokenSwapOptions`
- `amount`: `u64`
- `orchestrator_flags`: `OrchestratorFlags`

### `TransferFeeOptions`
- `amount`: `u64`

### `WhirlpoolsSwapOptions`
- `amount`: `u64`
- `a_to_b`: `bool`
- `orchestrator_flags`: `OrchestratorFlags`

### `WhirlpoolsSwapV2Options`
- `amount`: `u64`
- `a_to_b`: `bool`
- `orchestrator_flags`: `OrchestratorFlags`

### `ZeroFiSwapOptions`
- `amount`: `u64`
- `orchestrator_flags`: `OrchestratorFlags`
