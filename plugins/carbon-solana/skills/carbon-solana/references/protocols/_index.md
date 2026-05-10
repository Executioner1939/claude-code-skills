# Protocol index

64 Solana programs covered by Carbon decoder crates. Each row links to the protocol's reference page (account types, instructions with discriminators, args, account variants, optional/remaining accounts, and CPI events when present).

The crate name is always `carbon-<slug>-decoder` where `<slug>` is the kebab-case identifier in the file name. Add it to your `Cargo.toml` and use `<Name>Decoder` (and the corresponding `<Name>Instruction` / `<Name>Account` enums) in the pipeline.

## All protocols

| Protocol | Program ID | Accounts | Instructions | CPI events |
|---|---|---:|---:|---|
| [Address Lookup Table](./address-lookup-table.md) | `AddressLookupTab1e1111111111111111111111111` | 1 | 5 | no |
| [Bonkswap](./bonkswap.md) | `BSwp6bEBihVLdqJRKGgzjcGLHkcTuzmSo1TQkHepzH8p` | 5 | 19 | no |
| [Boop](./boop.md) | `boop8hVGQGqehUK2iVEMEnMrL5RbjywRzHKBmBE7ry4` | 4 | 26 | yes (in instructions/) |
| [Bubblegum](./bubblegum.md) | `BGUMAp9Gq7iTEuizy4pqaxsTyUCBK68MDfK752saRPUY` | 2 | 35 | no |
| [Circle Message Transmitter V2](./circle-message-transmitter-v2.md) | `CCTPV2Sm4AdWt5296sk4P66VBZ7bEhcARwFaaS9YPbeC` | 3 | 15 | yes (in instructions/) |
| [Circle Token Messenger V2](./circle-token-messenger-v2.md) | `CCTPV2vPZJS2u2BBsUoscuikbYjnpFmbFsvVuJdgUMQe` | 7 | 25 | yes (in instructions/) |
| [DFlow Aggregator V4](./dflow-aggregator-v4.md) | `DF1ow4tspfHX9JwWJsAb9epbkA8hmpSEAtxXy1V27QBH` | 1 | 16 | yes (events/) |
| [Drift v2](./drift-v2.md) | `dRiftyHA39MWEi3m9aunc5MzRF1JYuBsbn6VPcn33UH` | 17 | 196 | yes (in instructions/) |
| [Fluxbeam](./fluxbeam.md) | `FLUXubRmkEi2q6K3Y9kBPg9248ggaZVsoSFhtJHSrm1X` | 1 | 6 | no |
| [Gavel](./gavel.md) | `srAMMzfVHVAtgSJc8iH6CfKzuWuUTzLHVCE81QU1rgi` | 2 | 10 | yes (in types/) |
| [Heaven](./heaven.md) | `HEAVENoP2qxoeuF8Dj2oT1GHEnu49U5mJYkdeC8BAX2o` | 5 | 32 | yes (in instructions/) |
| [Jupiter DCA](./jupiter-dca.md) | `DCA265Vj8a9CEuX1eb1LWRnDT7uK6q1xMipnNyatn23M` | 1 | 12 | yes (in instructions/) |
| [Jupiter Lend](./jupiter-lend.md) | `jupeiUmn818Jg1ekPURTpr4mFo29p46vygyykFJ3wZC` | 7 | 24 | yes (events/) |
| [Jupiter Limit Order 2](./jupiter-limit-order-2.md) | `j1o2qRpjcyUwEvwtcfhEQefh773ZgjxcVRry7LDqg5X` | 2 | 6 | yes (in instructions/) |
| [Jupiter Limit Order](./jupiter-limit-order.md) | `jupoNjAxXgZ4rjzxzPMP4oxduvQsQtZzyknqvzYNrNu` | 2 | 9 | yes (in instructions/) |
| [Jupiter Perpetuals](./jupiter-perpetuals.md) | `PERPHjGBqRHArX4DySjwM6UJHiR3sWAatqfdBS2qQJu` | 6 | 39 | yes (in instructions/) |
| [Jupiter Swap](./jupiter-swap.md) | `JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4` | 1 | 17 | yes (events/) |
| [Kamino Farms](./kamino-farms.md) | `FarmsPZpWu9i7Kky8tPN37rs2TpmMrAZrC7S7vJa91Hr` | 4 | 25 | no |
| [Kamino Lending](./kamino-lending.md) | `KLend2g3cP87fffoy8q1mQqGKjrxjC8boSyAYavgmjD` | 8 | 35 | no |
| [Kamino Limit Order](./kamino-limit-order.md) | `LiMoM9rMhrdYrfzUCxQppvxCSG1FcrUK9G8uLq4A1GF` | 2 | 11 | yes (in instructions/) |
| [Kamino Vault](./kamino-vault.md) | `kvauTFR8qm1dhniz6pYuBZkuene3Hfrs1VQhVRgCNrr` | 2 | 12 | no |
| [Lifinity AMM V2](./lifinity-amm-v2.md) | `2wT8Yq49kHgDzXuPxZSaeLaH1qbmGXtEyPy64bL7aD3c` | 1 | 3 | no |
| [Marginfi V2](./marginfi-v2.md) | `MFv2hWf31Z9kbCa1snEPYctwafyhdvnV7FZnsebVacA` | 3 | 24 | yes (in instructions/) |
| [Marinade Finance](./marinade-finance.md) | `MarBmsSgKXdrN1egZf5sqe1TMai9K1rChYNDJgjq7aD` | 2 | 53 | yes (in instructions/) |
| [Memo Program](./memo-program.md) | `spl_memo_interface::v3::ID` | 0 | 1 | no |
| [Metaplex Core](./mpl-core.md) | `CoREENxT6tW1HoK8ypY1SxRMZTcVPm7R94rH4PZNhX7d` | 5 | 32 | no |
| [Metaplex Token Metadata](./mpl-token-metadata.md) | `metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s` | 14 | 58 | no |
| [Meteora DAMM V2](./meteora-damm-v2.md) | `cpamdpZCGKUy5JxQXB4dcpGPiikHawvSWAd6mEn1sGG` | 9 | 35 | yes (events/) |
| [Meteora DLMM](./meteora-dlmm.md) | `LBUZKhRxPF3XUpBCjp4YzTKgLccjZhTSDM9YuVaPwxo` | 10 | 88 | yes (in instructions/) |
| [Meteora Dynamic Bonding Curve (DBC)](./meteora-dbc.md) | `dbcij3LWUppWqq96dh6gJWwBifmcGfLSB5D4DuSMaqN` | 9 | 47 | yes (in instructions/) |
| [Meteora Pools](./meteora-pools.md) | `Eo7WjKq67rjJQSZxS6z3YkapzY3eMj6Xy8X5EQVn5UaB` | 3 | 44 | yes (in instructions/) |
| [Meteora Vault](./meteora-vault.md) | `24Uqj9JCLxUeoC3hGfh5W3s9FM9uCHDS2SG3LYwBpyTi` | 2 | 22 | yes (in instructions/) |
| [Moonshot](./moonshot.md) | `MoonCVVNZFSYkqNXP6bxHLPL6QQJiMagDL3qcqUQTrG` | 2 | 8 | yes (in instructions/) |
| [OKX DEX Aggregator](./okx-dex.md) | `6m2CDdhRgxpH4WjvdzxAYbGxwdGUz5MziiL5jek2kBma` | 0 | 12 | yes (in instructions/ as `swap_event.rs` and types/ as `swap_event.rs`) |
| [OnchainLabs DEX V1](./onchain-labs-dex-v1.md) | `6m2CDdhRgxpH4WjvdzxAYbGxwdGUz5MziiL5jek2kBma` | 0 | 20 | yes (events/) |
| [OnchainLabs DEX V2](./onchain-labs-dex-v2.md) | `proVF4pMXVaYqmy4NjniPh4pqKNfMmsihgd4wdkCX3u` | 0 | 13 | yes (events/) |
| [Openbook V2](./openbook-v2.md) | `opnb2LAfJYbRMAHHvqjCwQxanZn7ReEHp1k81EohpZb` | 6 | 29 | yes (in instructions/ as `_log_event.rs` and `total_order_fill_event.rs`) |
| [Orca Whirlpool](./orca-whirlpool.md) | `whirLbMiicVdio4qvUfM5KAg6Ct8VwpYzGff3uctyCc` | 12 | 58 | yes (in instructions/ as `_event.rs`) |
| [Pancake Swap](./pancake-swap.md) | `HpNfyc2Saw7RKkQd8nEL4khUcuPhQ7WwY1B2qjx8jxFq` | 10 | 27 | yes (in instructions/) |
| [Phoenix v1](./phoenix-v1.md) | `PhoeNiXZ8ByJGLkxNfZRnkUfjvmuYqLR89jjFHGqdXY` | 2 | 28 | no |
| [Pump Fees](./pump-fees.md) | `pfeeUxB6jkeY1Hxd7CsFCAjcbHA9rWtchMGdZ6VojVZ` | 7 | 18 | yes (events/) |
| [Pump Swap](./pump-swap.md) | `pAMMBay6oceH9fJKBRHGP5D4bD4sWpmSwMn52FMfXEA` | 7 | 26 | yes (events/) |
| [Pumpfun](./pumpfun.md) | `6EF8rrecthR5Dkzon8Nwu78hRvfCKubJ14M5uBEwF6P` | 6 | 30 | yes (events/) |
| [Raydium AMM v4](./raydium-amm-v4.md) | `675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8` | 3 | 18 | no |
| [Raydium CLMM](./raydium-clmm.md) | `CAMMCzo5YL8w4VFF8KVHrK22GGUsp5VTaW7grrKgrWqK` | 8 | 24 | yes (in instructions/) |
| [Raydium CPMM](./raydium-cpmm.md) | `CPMMoo8L3F4NbTegBCKVNunggL7H1ZpdTHKxQB5qKP1C` | 4 | 14 | yes (in instructions/) |
| [Raydium Launchpad](./raydium-launchpad.md) | `LanMV9sAd7wArD4vJFi2qDdfnVhFxYSUg6eADduJ3uj` | 4 | 22 | yes (in instructions/) |
| [Raydium Liquidity Locking](./raydium-liquidity-locking.md) | `LockrWmn6K5twhz3y9w1dQERbmgSaRkfnTeTKbpofwE` | 2 | 4 | yes (in instructions/) |
| [Raydium Stable Swap](./raydium-stable-swap.md) | `5quBtoiQqxF9Jv6KYKctB59NT3gtJD2Y65kdnB1Uev3h` | 0 | 6 | no |
| [SPL Associated Token Account](./associated-token-account.md) | `ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL` | 0 | 3 | no |
| [SPL Name Service](./name-service.md) | `namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX` | 1 | 5 | no |
| [SPL Token Program](./token-program.md) | `TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA` | 3 | 25 | no |
| [SPL Token-2022](./token-2022.md) | `TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb` | 3 | 106 | no |
| [Sharky](./sharky.md) | `SHARKobtfF1bHhxD2eqftjHBdVSCbKo9JtgK71FhELP` | 5 | 18 | no |
| [Solayer Restaking Program](./solayer-restaking-program.md) | `sSo1iU21jBrU9VaJ8PJib1MtorefUV4fzC9GURa2KNn` | 1 | 4 | no |
| [Stabble Stable Swap](./stabble-stable-swap.md) | `swapNyd8XiQwJ6ianp9snpu4brUqFxadzvHebnAXjJZ` | 3 | 17 | yes (in instructions/) |
| [Stabble Weighted Swap](./stabble-weighted-swap.md) | `swapFpHZwjELNnjvThjajtiVmkz3yPQEHjLtka2fwHW` | 2 | 13 | yes (in instructions/) |
| [Stake Program](./stake-program.md) | `Stake11111111111111111111111111111111111111` | 0 | 15 | no |
| [Swig](./swig.md) | `swigypWHEksbC64pWKwah1WTeh9JXwx8H1rJHLdbQMB` | 0 | 13 | no |
| [System Program](./system-program.md) | `11111111111111111111111111111111` | 2 | 13 | no |
| [Vertigo](./vertigo.md) | `vrTGoBuy5rYSxAfV3jaRJWHH6nN9WK4NRExGxsk1bCJ` | 1 | 6 | yes (in instructions/, _event.rs) |
| [Virtuals](./virtuals.md) | `5U3EU2ubXtK84QcRjWVmYt9RaDyA8gKxdUrPFXmZyaki` | 1 | 8 | yes (in instructions/, _event.rs) |
| [Wavebreak](./wavebreak.md) | `waveQX2yP3H1pVU8djGvEHmYg8uamQ84AuyGtpsrXTF` | 5 | 41 | yes (in types/, single `Event` enum) |
| [Zeta Markets](./zeta.md) | `ZETAxsqBRek56DhiGXrn75yj2NHU3aYUnxvHXpkf3aD` | 23 | 7 | yes (in instructions/, _event.rs) |


## By category

### AMM / DEX
- [Bonkswap](./bonkswap.md), [Fluxbeam](./fluxbeam.md), [Heaven](./heaven.md), [Lifinity AMM v2](./lifinity-amm-v2.md), [Orca Whirlpool](./orca-whirlpool.md), [Pancake Swap](./pancake-swap.md)
- Raydium: [AMM v4](./raydium-amm-v4.md), [CLMM](./raydium-clmm.md), [CPMM](./raydium-cpmm.md), [Stable Swap](./raydium-stable-swap.md), [Liquidity Locking](./raydium-liquidity-locking.md), [Launchpad](./raydium-launchpad.md)
- Meteora: [DAMM v2](./meteora-damm-v2.md), [DBC](./meteora-dbc.md), [DLMM](./meteora-dlmm.md), [Pools](./meteora-pools.md), [Vault](./meteora-vault.md)
- Stabble: [Stable](./stabble-stable-swap.md), [Weighted](./stabble-weighted-swap.md)
- Onchain Labs: [v1](./onchain-labs-dex-v1.md), [v2](./onchain-labs-dex-v2.md)

### Order books / aggregators
- [Phoenix v1](./phoenix-v1.md), [OpenBook v2](./openbook-v2.md)
- [Gavel](./gavel.md), [OKX DEX](./okx-dex.md), [DFlow Aggregator v4](./dflow-aggregator-v4.md), [Wavebreak](./wavebreak.md)
- Jupiter: [Swap](./jupiter-swap.md), [DCA](./jupiter-dca.md), [Limit Order](./jupiter-limit-order.md), [Limit Order v2](./jupiter-limit-order-2.md)

### Launchpads / token issuance
- [Pumpfun](./pumpfun.md), [Pump Swap](./pump-swap.md), [Pump Fees](./pump-fees.md)
- [Moonshot](./moonshot.md), [Boop](./boop.md), [Vertigo](./vertigo.md), [Virtuals](./virtuals.md)

### Lending / leverage / perpetuals
- [Drift v2](./drift-v2.md), [Jupiter Perpetuals](./jupiter-perpetuals.md), [Jupiter Lend](./jupiter-lend.md), [Zeta](./zeta.md), [Marginfi v2](./marginfi-v2.md)
- Kamino: [Lending](./kamino-lending.md), [Vault](./kamino-vault.md), [Farms](./kamino-farms.md), [Limit Order](./kamino-limit-order.md)
- [Sharky](./sharky.md) (NFT lending)

### Liquid staking / restaking
- [Marinade Finance](./marinade-finance.md), [Solayer Restaking](./solayer-restaking-program.md)

### NFT / Metaplex
- [MPL Core](./mpl-core.md), [MPL Token Metadata](./mpl-token-metadata.md), [Bubblegum](./bubblegum.md)

### Bridges
- Circle CCTP v2: [Message Transmitter](./circle-message-transmitter-v2.md), [Token Messenger](./circle-token-messenger-v2.md)

### Native / utility
- [System Program](./system-program.md), [Stake Program](./stake-program.md), [Address Lookup Table](./address-lookup-table.md)
- SPL: [Token Program](./token-program.md), [Token-2022](./token-2022.md), [Associated Token Account](./associated-token-account.md), [Memo Program](./memo-program.md), [Name Service](./name-service.md)
- [Swig](./swig.md)
