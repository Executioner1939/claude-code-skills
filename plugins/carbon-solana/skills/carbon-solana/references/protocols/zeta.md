# Zeta Markets

- **Crate:** `carbon-zeta-decoder`
- **Program ID:** `ZETAxsqBRek56DhiGXrn75yj2NHU3aYUnxvHXpkf3aD`
- **Decoder struct:** `ZetaDecoder`
- **Has accounts:** yes
- **Has instructions:** yes
- **Has CPI events:** yes (in instructions/, *_event.rs)
- **Discriminator style:** anchor 8-byte (events use 16-byte anchor event discriminator with `0xe445a52e51cb9a1d` prefix)

## Account types

### `Pricing`
- **Discriminator:** `0xbe7bd2b68f0b9888`
- **Fields:** `nonce`, `mark_prices: [u64; 25]` (+padding), `update_timestamps: [u64; 25]`, `funding_deltas: [AnchorDecimal; 25]`, `latest_funding_rates: [AnchorDecimal; 25]`, `latest_midpoints: [u64; 25]`, `oracles: [Pubkey; 25]`, `oracle_backup_feeds: [Pubkey; 25]`, `markets: [Pubkey; 25]`, `perp_sync_queues: [Pubkey; 25]`, `perp_parameters: [PerpParameters; 25]`, `margin_parameters: [MarginParameters; 25]`, `products: [Product; 25]`, `zeta_group_keys: [Pubkey; 25]`, `total_insurance_vault_deposits: u64`

### `Greeks`
- **Discriminator:** `0xf7d5aa9a2bf392fe`
- **Fields:** `nonce: u8`, `mark_prices: [u64; 46]` (+padding `[u64; 91]`), `perp_mark_price: u64`, `product_greeks: [ProductGreeks; 22]` (+padding `[ProductGreeks; 44]`), `update_timestamp: [u64; 2]`, `retreat_expiration_timestamp: [u64; 2]`, `interest_rate: [i64; 2]`, `nodes: [u64; 5]`, `volatility: [u64; 10]`, `node_keys: [Pubkey; 138]`, `halt_force_pricing: [bool; 6]`, `perp_update_timestamp: u64`, `perp_funding_delta: AnchorDecimal`, `perp_latest_funding_rate: AnchorDecimal`, `perp_latest_midpoint: u64`, `padding: [u8; 1593]`

### `MarketIndexes`
- **Discriminator:** `0x6fcd6992db895217`
- **Fields:** `nonce: u8`, `initialized: bool`, `indexes: [u8; 138]`

### `OpenOrdersMap`
- **Discriminator:** `0xfa7eac0a761e03a8`
- **Fields:** `user_key: Pubkey`

### `CrossOpenOrdersMap`
- **Discriminator:** `0xc5185209520e309a`
- **Fields:** `user_key: Pubkey`, `subaccount_index: u8`

### `State`
- **Discriminator:** `0xd8926b5e684bb6b1`
- **Fields:** `admin: Pubkey`, `state_nonce`, `serum_nonce`, `mint_auth_nonce`, `num_underlyings`, `num_flex_underlyings: u8`, `null: [u8; 7]`, `strike_initialization_threshold_seconds: u32`, `pricing_frequency_seconds: u32`, `liquidator_liquidation_percentage: u32`, `insurance_vault_liquidation_percentage: u32`, `deprecated_fee_values: [u64; 3]`, `native_deposit_limit: u64`, `expiration_threshold_seconds: u32`, `position_movement_fee_bps: u8`, `margin_concession_percentage: u8`, `treasury_wallet_nonce: u8`, `deprecated_option_fee_values: [u64; 2]`, `referrals_admin: Pubkey`, `referrals_rewards_wallet_nonce: u8`, `max_perp_delta_age: u16`, `secondary_admin: Pubkey`, `vault_nonce`, `insurance_vault_nonce: u8`, `deprecated_total_insurance_vault_deposits: u64`, `native_withdraw_limit: u64`, `withdraw_limit_epoch_seconds: u32`, `native_open_interest_limit: u64`

### `Underlying`
- **Discriminator:** `0xce80984d70a40d02`
- **Fields:** `mint: Pubkey`

### `SettlementAccount`
- **Discriminator:** `0x512a686f7b5992b4`
- **Fields:** `settlement_price: u64`, `strikes: [u64; 23]`

### `PerpSyncQueue`
- **Discriminator:** `0x5c37389de6b8ab42`
- **Fields:** `nonce: u8`, `head: u16`, `length: u16`, `queue: [AnchorDecimal; 600]`

### `ZetaGroup`
- **Discriminator:** `0x7911d26b6deb0e0c`
- **Fields:** `nonce: u8`, `nonce_padding: [u8; 2]`, `front_expiry_index: u8`, `halt_state: HaltState`, `underlying_mint`, `oracle`, `greeks: Pubkey`, `pricing_parameters: PricingParameters`, `margin_parameters: MarginParameters`, `margin_parameters_padding: [u8; 104]`, `products: [Product; 46]` (+padding `[Product; 91]`), `perp: Product`, `expiry_series: [ExpirySeries; 2]`, `deprecated_padding: [u8; 8]`, `asset: Asset`, `expiry_interval_seconds: u32`, `new_expiry_threshold_seconds: u32`, `perp_parameters: PerpParameters`, `perp_sync_queue: Pubkey`, `oracle_backup_feed: Pubkey`, `perps_only: bool`, `flex_underlying: bool`, `padding: [u8; 964]`

### `MarketNode`
- **Discriminator:** `0x1c52153b968d3c7c`
- **Fields:** `index: u8`, `nonce: u8`, `node_updates: [i64; 5]`, `interest_update: i64`

### `SpreadAccount`
- **Discriminator:** `0x3982fc88a7b12fa2`
- **Fields:** `authority: Pubkey`, `nonce: u8`, `balance: u64`, `series_expiry: [u64; 5]`, `positions: [Position; 46]` (+padding `[Position; 92]`), `asset: Asset`, `padding: [u8; 262]`

### `CrossMarginAccountManager`
- **Discriminator:** `0x5ca21a433156fc05`
- **Fields:** `nonce: u8`, `authority: Pubkey`, `accounts: [CrossMarginAccountInfo; 20]`, `referrer: Pubkey`, `airdrop_community: u8`, `referred_timestamp: u64`, `padding: [u8; 14]`

### `CrossMarginAccount`
- **Discriminator:** `0xf25e8e8323f4931c`
- **Fields:** `authority: Pubkey`, `delegated_pubkey: Pubkey`, `balance: u64`, `subaccount_index: u8`, `nonce: u8`, `force_cancel_flag: bool`, `account_type: MarginAccountType`, `open_orders_nonces: [u8; 25]`, `rebalance_amount: i64`, `last_funding_deltas: [AnchorDecimal; 25]`, `product_ledgers: [ProductLedger; 25]`, `trigger_order_bits: u128`, `rebate_rebalance_amount: u64`, `potential_order_loss: [u64; 25]`, `padding: [u8; 1776]`

### `MarginAccount`
- **Discriminator:** `0x85dcadd5b3d32bee`
- **Fields:** `authority: Pubkey`, `nonce: u8`, `balance: u64`, `force_cancel_flag: bool`, `open_orders_nonce: [u8; 138]`, `series_expiry: [u64; 5]`, `product_ledgers: [ProductLedger; 46]` (+padding `[ProductLedger; 91]`), `perp_product_ledger: ProductLedger`, `rebalance_amount: i64`, `asset: Asset`, `account_type: MarginAccountType`, `last_funding_delta: AnchorDecimal`, `delegated_pubkey: Pubkey`, `rebate_rebalance_amount: u64`, `padding: [u8; 330]`

### `TriggerOrder`
- **Discriminator:** `0xec3d2abe980c6a74`
- **Fields:** `owner`, `margin_account`, `open_orders: Pubkey`, `order_price: u64`, `trigger_price: Option<u64>`, `trigger_ts: Option<u64>`, `size: u64`, `creation_ts: u64`, `trigger_direction: Option<TriggerDirection>`, `side: Side`, `asset: Asset`, `order_type: OrderType`, `bit: u8`, `reduce_only: bool`

### `SocializedLossAccount`
- **Discriminator:** `0x41fe8deb3c546889`
- **Fields:** `nonce: u8`, `overbankrupt_amount: u64`

### `WhitelistDepositAccount`
- **Discriminator:** `0x6e02d95144ae78d9`
- **Fields:** `nonce: u8`, `user_key: Pubkey`

### `WhitelistInsuranceAccount`
- **Discriminator:** `0x0a68c0cb813c2802`
- **Fields:** `nonce: u8`, `user_key: Pubkey`

### `InsuranceDepositAccount`
- **Discriminator:** `0xb6a1fc657ba1cdb8`
- **Fields:** `nonce: u8`, `amount: u64`

### `WhitelistTradingFeesAccount`
- **Discriminator:** `0xdb27bda689f354ef`
- **Fields:** `nonce: u8`, `user_key: Pubkey`

### `ReferrerIdAccount`
- **Discriminator:** `0xcfc24e8a9e4aba7f`
- **Fields:** `referrer_id: [u8; 6]`, `referrer_pubkey: Pubkey`

### `ReferrerPubkeyAccount`
- **Discriminator:** `0x1d37607f524897c5`
- **Fields:** `referrer_id: [u8; 6]`

## Instructions

All instructions use 8-byte anchor discriminators. Args (where present) are typed-Borsh; account layouts are linear `let [...] = accounts` patterns. Args are summarized below; consult source for full account lists.

### Setup / state administration

| Instruction | Discriminator | Args |
| --- | --- | --- |
| `InitializeZetaState` | `0x44274b8ebf925ede` | `args: InitializeStateArgs` |
| `UpdateZetaState` | `0x68b614bb03a43c03` | `args: UpdateStateArgs` |
| `UpdateAdmin` | `0xa1b028d53cb8b3e4` | (none) |
| `UpdateSecondaryAdmin` | `0x54e61a4b02b3afea` | (none) |
| `UpdateReferralsAdmin` | `0x49905c774a6a10c8` | (none) |
| `UpdateTriggerAdmin` | `0xf1646ed23979776c` | (none) |
| `UpdatePricingAdmin` | `0x49189c1c6e587baf` | (none) |
| `UpdateMaTypeAdmin` | `0x2cb99666701c81ef` | (none) |
| `InitializeUnderlying` | `0x726cd55caf7c2b13` | `flex_underlying: bool` |
| `InitializeMarketIndexes` | `0x5b3fcd901453b178` | `nonce: u8` |
| `AddMarketIndexes` | `0x5ef690af04a4e9fc` | (none) |
| `AddPerpMarketIndex` | `0x7a280e40a912e788` | `args` |
| `InitializeMarketNode` | `0x32761515b3f81780` | `args: InitializeMarketNodeArgs` |
| `InitializeMarketPda` | `0x057864bae186080d` | `args` |
| `InitializeMarketStrikes` | `0xbd2eff217e852bab` | (none) |
| `InitializeMarketTifEpochCycle` | `0xc78fad93cacc40cc` | `epoch_length: u16` |
| `InitializeMinLotsAndTickSizes` | `0x4419332b7eab5057` | (none) |
| `InitializeZetaTreasuryWallet` | `0xf939bb66b86825e7` | (none) |
| `InitializeZetaReferralsRewardsWallet` | `0xf5e5df780786f7f8` | (none) |
| `InitializeZetaGroup` | `0x068724e82327fa47` | `args: InitializeZetaGroupArgs` |
| `InitializeZetaMarket` | `0x74efe2952ea3dd03` | `args: InitializeMarketArgs` |
| `InitializeZetaPricing` | `0x23d1b41df5c77d10` | `args: InitializeZetaPricingArgs` |
| `InitializeZetaSpecificMarketVaults` | `0xf945ba92886b4f71` | `args` |
| `InitializeCombinedVault` | `0x3b6369114977e5fc` | `nonce: u8` |
| `InitializeCombinedInsuranceVault` | `0x4d12b590db54066a` | `args` |
| `InitializeCombinedSocializedLossAccount` | `0x886c58f5e6e06552` | `args` |
| `InitializePerpSyncQueue` | `0x0a379ae081aea108` | `nonce: u8` |
| `CleanZetaMarkets` | `0x7a7f315944e4559d` | (none) |
| `CleanZetaMarketHalted` | `0x898c5e12e7e8d9cc` | `args` |
| `OverrideExpiry` | `0x81c575726c77cf88` | `args: OverrideExpiryArgs` |
| `ExpireSeries` | `0x2da269622c15ab7f` | `expiry_ts: u64` |
| `ExpireSeriesOverride` | `0x6816227b56e08246` | `args: ExpireSeriesOverrideArgs` |
| `ResetNumFlexUnderlyings` | `0x3013fed1c8d3313d` | (none) |
| `ToggleZetaGroupPerpsOnly` | `0xaa734d0ba19df7a9` | (none) |
| `ToggleMarketMaker` | `0xcbf7549f68fd9450` | `is_maker: bool` |
| `Halt` | `0x189c087941030552` | `args: HaltArgs` |
| `Unhalt` | `0xf98c1bd58082cf71` | `asset: Asset` |
| `UpdateHaltState` | `0xd72d35a2958a053f` | `args: HaltStateArgs` |
| `UpdateInterestRate` | `0x4b08ff297b3b87ee` | `args: UpdateInterestRateArgs` |
| `UpdateOracle` | `0x7029d112f8e2fcbc` | (none) |
| `UpdateOracleBackupFeed` | `0xe60921cae4d1b462` | (none) |
| `UpdateMakerRebatePercentage` | `0xb4ecfd13e7e7dc41` | `pct: u32` |
| `UpdateMarginParameters` | `0x4532aec57bc448ec` | `args: UpdateMarginParametersArgs` |
| `UpdatePerpParameters` | `0x5a87db2aa48661ae` | `args: UpdatePerpParametersArgs` |
| `UpdatePricingParameters` | `0x697fd0863d3d71f7` | `args: UpdatePricingParametersArgs` |
| `UpdatePricingV2` | `0xeb6d8aad0f2533f4` | `asset: Asset` |
| `UpdatePricingV3` | `0xdf3ab45666fbed52` | `asset: Asset` |
| `UpdateMinLot` | `0x0688050ce5926659` | `args` |
| `UpdateTickSize` | `0xde7a01dd7b748f6e` | `tick_size: u64` |
| `UpdateTreasurySplitTokenAccount` | `0x0b4ee9b8a2995dcf` | `args` |
| `UpdateTakeTriggerOrderFeePercentage` | `0xe3ea9df6804ae936` | `pct: u32` |
| `UpdateVolatility` | `0xbe6974dde5c6d053` | `args: UpdateVolatilityArgs` |
| `UpdateZetaGroupExpiryParameters` | `0x11457968e1ce8cd7` | `args: UpdateZetaGroupExpiryArgs` |
| `UpdateZetaGroupMarginParameters` | `0x3cd07993f26a0bfe` | `args: UpdateMarginParametersArgs` |
| `UpdateZetaGroupPerpParameters` | `0x48988c9ec35df71f` | `args: UpdatePerpParametersArgs` |
| `UpdateZetaPricingPubkeys` | `0xa9dd17f8db7a8e9e` | `args: UpdateZetaPricingPubkeysArgs` |
| `AdminCrankEventQueue` | `0x668fdc88179e889d` | `events_to_crank: u16` |
| `AdminForceCancelOrders` | `0x43347cc0bf20da5b` | `args` |
| `AdminResetDexOpenOrders` | `0x73c65a11d28bc1ee` | `args` |
| `AdminSetOrderState` | `0x6efe15f1a0772cfd` | `args: OrderState` |

### Margin / accounts

| Instruction | Discriminator | Args |
| --- | --- | --- |
| `InitializeMarginAccount` | `0x43eb4266a7ab78c5` | (none) |
| `CloseMarginAccount` | `0x69d729efa6cf0167` | (none) |
| `InitializeCrossMarginAccount` | `0x1b1ae432d2d3cd5e` | `subaccount_index: u8` |
| `InitializeCrossMarginAccountManager` | `0x489a0f1ca5d7d1c7` | (none) |
| `InitializeCrossMarginAccountManagerV2` | `0xa6cbb0d2b0348c69` | `referral_account_pubkey: Option<Pubkey>` |
| `CloseCrossMarginAccount` | `0xcbc4bb3c0daabe45` | `subaccount_index: u8` |
| `CloseCrossMarginAccountManager` | `0xe8b6b689565876fc` | (none) |
| `MigrateToCrossMarginAccount` | `0x9d356b68b8bd64dc` | (none) |
| `MigrateToNewCrossMarginAccount` | `0xb72dfb6d866cbff3` | (none) |
| `EditDelegatedPubkey` | `0x89f547592ef91635` | `new_key: Pubkey` |
| `EditMaType` | `0xe7d03332de934c4e` | `ma_type: MarginAccountType` |
| `InitializeSpreadAccount` | `0xce56fb1b5b6f17d3` | (none) |
| `CloseSpreadAccount` | `0xbee4fd10c994a1f0` | (none) |
| `TransferExcessSpreadBalance` | `0xacb80c0a346940d5` | (none) |
| `PositionMovement` | `0x75104bf9b37fab93` | `movement_type: MovementType`, `movements: Vec<PositionMovementArg>` |
| `InitializeOpenOrders` | `0x37ea1052642a7ec0` | (none) |
| `InitializeOpenOrdersV2` | `0xdc11551470ae94e3` | (none) |
| `InitializeOpenOrdersV3` | `0x16bf8b88792754ca` | `args` |
| `CloseOpenOrders` | `0xc8d83fef07e6ff14` | `nonce: u8` |
| `CloseOpenOrdersV2` | `0x4e98c4a344b37948` | `nonce: u8` |
| `CloseOpenOrdersV3` | `0xcf0fc64ac5e4b01e` | `args` |
| `CloseOpenOrdersV4` | `0xa765a1f6d03106e1` | `args` |

### Deposit / withdraw

| Instruction | Discriminator | Args |
| --- | --- | --- |
| `Deposit` | `0xf223c68952e1f2b6` | `amount: u64` |
| `DepositV2` | `0x6d4b4599acda9213` | `amount: u64` |
| `DepositPermissionless` | `0xebf709f8cc340932` | `amount: u64` |
| `DepositInsuranceVault` | `0x2f35192f6d7a1616` | `amount: u64` |
| `DepositInsuranceVaultV2` | `0xf22c18135b3b07c9` | `amount: u64` |
| `Withdraw` | `0xb712469c946da122` | `amount: u64` |
| `WithdrawV2` | `0xf250a300c4ddc2c2` | `amount: u64` |
| `WithdrawInsuranceVault` | `0x11fad52dac7551e1` | `percentage_amount: u64` |
| `WithdrawInsuranceVaultV2` | `0xcb472c94e0f245a5` | `percentage_amount: u64` |
| `RebalanceInsuranceVault` | `0x0bc442eb3beddf6f` | (none) |
| `RebalanceInsuranceVaultV2` | `0xb8eefe5ca4c7c967` | (none) |

### Whitelist accounts

| Instruction | Discriminator | Args |
| --- | --- | --- |
| `InitializeInsuranceDepositAccount` | `0x55a372798ba72925` | `nonce: u8` |
| `InitializeWhitelistDepositAccount` | `0x3de773db51f39e8a` | `nonce: u8` |
| `InitializeWhitelistInsuranceAccount` | `0x2b2ef09b50045666` | `nonce: u8` |
| `InitializeWhitelistTradingFeesAccount` | `0xc681d8b9f71d69be` | `nonce: u8` |

### Place order

| Instruction | Discriminator | Args |
| --- | --- | --- |
| `PlaceOrder` | `0x33c29baf6d82606a` | `price: u64`, `size: u64`, `side: Side`, `client_order_id: Option<u64>` |
| `PlaceOrderV2` | `0xe86f73c4ed8f3ecc` | `args` |
| `PlaceOrderV3` | `0x925d0ea79f14063a` | `args` |
| `PlaceOrderV4` | `0xf3f8d58fb84f2949` | `args` |
| `PlacePerpOrder` | `0x45a15dca787e4cb9` | `args` |
| `PlacePerpOrderV2` | `0xcd5482b43f760acf` | `args` |
| `PlacePerpOrderV3` | `0x5bf660073516eae1` | `args` |
| `PlacePerpOrderV4` | `0xa68acd645a6ebf5b` | `args` |
| `PlacePerpOrderV5` | `0x0718b6199b904b32` | `args: OrderArgs` |
| `PlaceMultiOrders` | `0xccd7f3f33beae179` | `bid_orders: Vec<OrderArgs>`, `ask_orders: Vec<OrderArgs>` |
| `PlaceTriggerOrder` | `0x209c32bce89f70ec` | `args: OrderArgs`, `trigger_direction: Option<TriggerDirection>`, `trigger_price: Option<u64>`, `trigger_ts: Option<u64>`, `bit: u8`, `reduce_only: bool` |

### Cancel / liquidate / settle

| Instruction | Discriminator | Args |
| --- | --- | --- |
| `CancelOrder` | `0x5f81edf00831df84` | `side: Side`, `order_id: u128` |
| `CancelOrderNoError` | `0x5f61d7cc6f33ccb8` | `side: Side`, `order_id: u128` |
| `CancelOrderHalted` | `0x00c0e902fcfb82a9` | `side: Side`, `order_id: u128` |
| `CancelOrderByClientOrderId` | `0x73b2c908afb77b77` | `client_order_id: u64` |
| `CancelOrderByClientOrderIdNoError` | `0x354da79daf8390ab` | `client_order_id: u64` |
| `CancelAllMarketOrders` | `0x8bbee6f94da0ce04` | `asset: Asset` |
| `CancelTriggerOrder` | `0x905443271b19ca8d` | `trigger_order_bit: u8` |
| `CancelTriggerOrderV2` | `0xdf414307bd033f8e` | `args` |
| `EditTriggerOrder` | `0xb42bd770fe741485` | `args` |
| `EditTriggerOrderV2` | `0x499fcdb12b557589` | `args` |
| `ExecuteTriggerOrder` | `0x690a6888d78654ab` | `args` |
| `ExecuteTriggerOrderV2` | `0x05e4307708d6b796` | `args` |
| `ForceCancelTriggerOrder` | `0x78ecd81cc04fffbc` | `args` |
| `TakeTriggerOrder` | `0x6bcf3be219171fa1` | `args` |
| `ForceCancelOrders` | `0x40b5c43fde4840e8` | (none) |
| `ForceCancelOrdersV2` | `0x0e3e95ca8f113873` | (none) |
| `ForceCancelOrderByOrderId` | `0xb6eb30b3f885d2f0` | `side: Side`, `order_id: u128` |
| `ForceCancelOrderByOrderIdV2` | `0x51f33c5adec929de` | `side: Side`, `order_id: u128` |
| `PruneExpiredTifOrders` | `0x18e3e2d45d1af2e6` | (none) |
| `PruneExpiredTifOrdersV2` | `0xcc257c399ed3b2d1` | `limit: u16` |
| `Liquidate` | `0xdfb3e27d302e274a` | `size: u64` |
| `LiquidateV2` | `0x0f56553702e1a1eb` | `size: u64` |
| `ApplyPerpFunding` | `0x1752e1dedb7ae6fb` | (none) |
| `CrankEventQueue` | `0x438561dfb2bcebb5` | `asset: Asset` |
| `SettleDexFunds` | `0xa5678e26d3a60ee2` | (none) |
| `SettlePositionsHalted` | `0xaa938ba31368a74d` | `args` |
| `BurnVaultTokens` | `0xe9cba5c9af2bbc9f` | (none) |
| `CollectTreasuryFunds` | `0xf3d504ec1af6b4ae` | `amount: u64` |
| `TreasuryMovement` | `0x0122f269d7d39d12` | `treasury_movement_type: TreasuryMovementType`, `amount: u64` |

### Referrals / airdrop

| Instruction | Discriminator | Args |
| --- | --- | --- |
| `InitializeReferrerAccounts` | `0x69e448ddda12b375` | `referrer_id: [u8; 6]` |
| `CloseReferrerAccounts` | `0xe04e378bcbec3e4e` | (none) |
| `ChooseAirdropCommunity` | `0x749cc052f82973ba` | `airdrop_community: u8` |

## CPI events

### `TradeEvent`
- **Source:** `instructions/trade_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1dbddb7fd34ee661ee`
- **Fields:** `margin_account: Pubkey`, `index: u8`, `size: u64`, `cost_of_trades: u64`, `is_bid: bool`, `client_order_id: u64`, `order_id: u128`

### `TradeEventV2Event`
- **Source:** `instructions/trade_event_v2_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d128ed28bb27bcb75`
- **Fields:** `TradeEvent` fields plus `asset: u8`, `user: Pubkey`, `is_taker: bool`, `sequence_number: u64`

### `TradeEventV3Event`
- **Source:** `instructions/trade_event_v3_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d72a23b2154866c3e`
- **Fields:** `margin_account: Pubkey`, `index: u8`, `size: u64`, `cost_of_trades: u64`, `is_bid: bool`, `client_order_id: u64`, `order_id: u128`, `asset: Asset`, `user: Pubkey`, `is_taker: bool`, `sequence_number: u64`, `fee: u64`, `price: u64`, `pnl: i64`, `rebate: u64`

### `PlaceOrderEvent`
- **Source:** `instructions/place_order_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d41bf195b1bfcc028`
- **Fields:** `fee: u64`, `oracle_price: u64`, `order_id: u128`, `expiry_ts: u64`, `asset: Asset`, `margin_account: Pubkey`, `client_order_id: u64`, `user: Pubkey`

### `PlaceMultiOrdersEvent`
- **Source:** `instructions/place_multi_orders_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1dee081207a23b6891`
- **Fields:** `oracle_price: u64`, `order_ids: Vec<u128>`, `expiry_tss: Vec<u64>`, `asset: Asset`, `margin_account: Pubkey`, `client_order_ids: Vec<u64>`, `user: Pubkey`

### `OrderCompleteEvent`
- **Source:** `instructions/order_complete_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d1a64c4ea5d799fdf`
- **Fields:** `margin_account: Pubkey`, `user: Pubkey`, `asset: Asset`, `market_index: u8`, `side: Side`, `unfilled_size: u64`, `order_id: u128`, `client_order_id: u64`, `order_complete_type: OrderCompleteType`

### `LiquidationEvent`
- **Source:** `instructions/liquidation_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d030d155dad884890`
- **Fields:** `liquidator_reward: u64`, `insurance_reward: u64`, `cost_of_trades: u64`, `size: i64`, `remaining_liquidatee_balance: u64`, `remaining_liquidator_balance: u64`, `mark_price: u64`, `underlying_price: u64`, `liquidatee: Pubkey`, `liquidator: Pubkey`, `asset: Asset`, `liquidatee_margin_account: Pubkey`, `liquidator_margin_account: Pubkey`

### `ApplyFundingEvent`
- **Source:** `instructions/apply_funding_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d7fca0fb7c8c0040c`
- **Fields:** `margin_account: Pubkey`, `user: Pubkey`, `asset: Asset`, `balance_change: i64`, `remaining_balance: u64`, `funding_rate: i64`, `oracle_price: u64`, `position_size: i64`

### `PositionMovementEvent`
- **Source:** `instructions/position_movement_event.rs`
- **Discriminator:** `0xe445a52e51cb9a1d44b90d941ce3655f`
- **Fields:** `net_balance_transfer: i64`, `margin_account_balance: u64`, `spread_account_balance: u64`, `movement_fees: u64`

## Shared types

Defined under `types/`:

- `Asset`: enum (per-asset tag)
- `Side`: enum (`Bid`, `Ask`)
- `Kind`: enum (instrument kind)
- `OrderType`, `PlaceOrderType`, `OrderState`, `OrderCompleteType`, `OrderArgs`
- `MarginAccountType`, `MarginParameters`, `MarginRequirement`
- `PerpParameters`, `PricingParameters`
- `Product`, `ProductGreeks`, `ProductLedger`, `Position`, `Strike`
- `ExpirySeries`, `ExpirySeriesStatus`
- `HaltState`, `HaltStateV2`, `HaltArgs`, `HaltStateArgs`
- `MovementType`, `PositionMovementArg`, `TreasuryMovementType`, `TraitType`, `ValidationType`
- `TriggerDirection`, `SelfTradeBehaviorZeta`
- `AnchorDecimal`
- `CrossMarginAccountInfo`
- Args structs: `InitializeMarketArgs`, `InitializeMarketNodeArgs`, `InitializeStateArgs`, `InitializeZetaGroupArgs`, `InitializeZetaPricingArgs`, `OverrideExpiryArgs`, `ExpireSeriesOverrideArgs`, `UpdateGreeksArgs`, `UpdateInterestRateArgs`, `UpdateMarginParametersArgs`, `UpdatePerpParametersArgs`, `UpdatePricingParametersArgs`, `UpdateStateArgs`, `UpdateVolatilityArgs`, `UpdateZetaGroupExpiryArgs`, `UpdateZetaPricingPubkeysArgs`
