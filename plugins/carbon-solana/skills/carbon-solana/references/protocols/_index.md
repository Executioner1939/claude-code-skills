# Protocol index

64 Solana programs are covered by Carbon decoder crates. Each protocol has its own auto-loaded sub-skill — search for the slug below or load `plugins/carbon-solana/skills/carbon-<slug>/SKILL.md` directly.

For the **full** args, accounts, discriminators, and event fields, run:

```bash
# replace <slug> with one from the table below
python3 plugins/carbon-solana/scripts/carbon.py list <slug>
python3 plugins/carbon-solana/scripts/carbon.py ix <slug> <InstructionName>
python3 plugins/carbon-solana/scripts/carbon.py account <slug> <AccountName>
python3 plugins/carbon-solana/scripts/carbon.py event <slug> <EventName>
python3 plugins/carbon-solana/scripts/carbon.py type <slug> <TypeName>
```

The script reads from `~/.cargo/registry/src/.../carbon-<slug>-decoder-*/` (any project that depends on the crate populates this after `cargo fetch`), or from `$CARBON_SRC` if set.

## All protocols

| Slug | Sub-skill |
|---|---|
| address-lookup-table | [carbon-address-lookup-table](../../carbon-address-lookup-table/SKILL.md) |
| associated-token-account | [carbon-associated-token-account](../../carbon-associated-token-account/SKILL.md) |
| bonkswap | [carbon-bonkswap](../../carbon-bonkswap/SKILL.md) |
| boop | [carbon-boop](../../carbon-boop/SKILL.md) |
| bubblegum | [carbon-bubblegum](../../carbon-bubblegum/SKILL.md) |
| circle-message-transmitter-v2 | [carbon-circle-message-transmitter-v2](../../carbon-circle-message-transmitter-v2/SKILL.md) |
| circle-token-messenger-v2 | [carbon-circle-token-messenger-v2](../../carbon-circle-token-messenger-v2/SKILL.md) |
| dflow-aggregator-v4 | [carbon-dflow-aggregator-v4](../../carbon-dflow-aggregator-v4/SKILL.md) |
| drift-v2 | [carbon-drift-v2](../../carbon-drift-v2/SKILL.md) |
| fluxbeam | [carbon-fluxbeam](../../carbon-fluxbeam/SKILL.md) |
| gavel | [carbon-gavel](../../carbon-gavel/SKILL.md) |
| heaven | [carbon-heaven](../../carbon-heaven/SKILL.md) |
| jupiter-dca | [carbon-jupiter-dca](../../carbon-jupiter-dca/SKILL.md) |
| jupiter-lend | [carbon-jupiter-lend](../../carbon-jupiter-lend/SKILL.md) |
| jupiter-limit-order | [carbon-jupiter-limit-order](../../carbon-jupiter-limit-order/SKILL.md) |
| jupiter-limit-order-2 | [carbon-jupiter-limit-order-2](../../carbon-jupiter-limit-order-2/SKILL.md) |
| jupiter-perpetuals | [carbon-jupiter-perpetuals](../../carbon-jupiter-perpetuals/SKILL.md) |
| jupiter-swap | [carbon-jupiter-swap](../../carbon-jupiter-swap/SKILL.md) |
| kamino-farms | [carbon-kamino-farms](../../carbon-kamino-farms/SKILL.md) |
| kamino-lending | [carbon-kamino-lending](../../carbon-kamino-lending/SKILL.md) |
| kamino-limit-order | [carbon-kamino-limit-order](../../carbon-kamino-limit-order/SKILL.md) |
| kamino-vault | [carbon-kamino-vault](../../carbon-kamino-vault/SKILL.md) |
| lifinity-amm-v2 | [carbon-lifinity-amm-v2](../../carbon-lifinity-amm-v2/SKILL.md) |
| marginfi-v2 | [carbon-marginfi-v2](../../carbon-marginfi-v2/SKILL.md) |
| marinade-finance | [carbon-marinade-finance](../../carbon-marinade-finance/SKILL.md) |
| memo-program | [carbon-memo-program](../../carbon-memo-program/SKILL.md) |
| meteora-damm-v2 | [carbon-meteora-damm-v2](../../carbon-meteora-damm-v2/SKILL.md) |
| meteora-dbc | [carbon-meteora-dbc](../../carbon-meteora-dbc/SKILL.md) |
| meteora-dlmm | [carbon-meteora-dlmm](../../carbon-meteora-dlmm/SKILL.md) |
| meteora-pools | [carbon-meteora-pools](../../carbon-meteora-pools/SKILL.md) |
| meteora-vault | [carbon-meteora-vault](../../carbon-meteora-vault/SKILL.md) |
| moonshot | [carbon-moonshot](../../carbon-moonshot/SKILL.md) |
| mpl-core | [carbon-mpl-core](../../carbon-mpl-core/SKILL.md) |
| mpl-token-metadata | [carbon-mpl-token-metadata](../../carbon-mpl-token-metadata/SKILL.md) |
| name-service | [carbon-name-service](../../carbon-name-service/SKILL.md) |
| okx-dex | [carbon-okx-dex](../../carbon-okx-dex/SKILL.md) |
| onchain-labs-dex-v1 | [carbon-onchain-labs-dex-v1](../../carbon-onchain-labs-dex-v1/SKILL.md) |
| onchain-labs-dex-v2 | [carbon-onchain-labs-dex-v2](../../carbon-onchain-labs-dex-v2/SKILL.md) |
| openbook-v2 | [carbon-openbook-v2](../../carbon-openbook-v2/SKILL.md) |
| orca-whirlpool | [carbon-orca-whirlpool](../../carbon-orca-whirlpool/SKILL.md) |
| pancake-swap | [carbon-pancake-swap](../../carbon-pancake-swap/SKILL.md) |
| phoenix-v1 | [carbon-phoenix-v1](../../carbon-phoenix-v1/SKILL.md) |
| pump-fees | [carbon-pump-fees](../../carbon-pump-fees/SKILL.md) |
| pump-swap | [carbon-pump-swap](../../carbon-pump-swap/SKILL.md) |
| pumpfun | [carbon-pumpfun](../../carbon-pumpfun/SKILL.md) |
| raydium-amm-v4 | [carbon-raydium-amm-v4](../../carbon-raydium-amm-v4/SKILL.md) |
| raydium-clmm | [carbon-raydium-clmm](../../carbon-raydium-clmm/SKILL.md) |
| raydium-cpmm | [carbon-raydium-cpmm](../../carbon-raydium-cpmm/SKILL.md) |
| raydium-launchpad | [carbon-raydium-launchpad](../../carbon-raydium-launchpad/SKILL.md) |
| raydium-liquidity-locking | [carbon-raydium-liquidity-locking](../../carbon-raydium-liquidity-locking/SKILL.md) |
| raydium-stable-swap | [carbon-raydium-stable-swap](../../carbon-raydium-stable-swap/SKILL.md) |
| sharky | [carbon-sharky](../../carbon-sharky/SKILL.md) |
| solayer-restaking-program | [carbon-solayer-restaking-program](../../carbon-solayer-restaking-program/SKILL.md) |
| stabble-stable-swap | [carbon-stabble-stable-swap](../../carbon-stabble-stable-swap/SKILL.md) |
| stabble-weighted-swap | [carbon-stabble-weighted-swap](../../carbon-stabble-weighted-swap/SKILL.md) |
| stake-program | [carbon-stake-program](../../carbon-stake-program/SKILL.md) |
| swig | [carbon-swig](../../carbon-swig/SKILL.md) |
| system-program | [carbon-system-program](../../carbon-system-program/SKILL.md) |
| token-2022 | [carbon-token-2022](../../carbon-token-2022/SKILL.md) |
| token-program | [carbon-token-program](../../carbon-token-program/SKILL.md) |
| vertigo | [carbon-vertigo](../../carbon-vertigo/SKILL.md) |
| virtuals | [carbon-virtuals](../../carbon-virtuals/SKILL.md) |
| wavebreak | [carbon-wavebreak](../../carbon-wavebreak/SKILL.md) |
| zeta | [carbon-zeta](../../carbon-zeta/SKILL.md) |

## By category

### AMM / DEX
bonkswap · fluxbeam · heaven · lifinity-amm-v2 · orca-whirlpool · pancake-swap · raydium-amm-v4 · raydium-clmm · raydium-cpmm · raydium-stable-swap · raydium-liquidity-locking · raydium-launchpad · meteora-damm-v2 · meteora-dbc · meteora-dlmm · meteora-pools · meteora-vault · stabble-stable-swap · stabble-weighted-swap · onchain-labs-dex-v1 · onchain-labs-dex-v2

### Order books / aggregators
phoenix-v1 · openbook-v2 · gavel · okx-dex · dflow-aggregator-v4 · wavebreak · jupiter-swap · jupiter-dca · jupiter-limit-order · jupiter-limit-order-2

### Launchpads / token issuance
pumpfun · pump-swap · pump-fees · moonshot · boop · vertigo · virtuals

### Lending / leverage / perpetuals
drift-v2 · jupiter-perpetuals · jupiter-lend · zeta · marginfi-v2 · kamino-lending · kamino-vault · kamino-farms · kamino-limit-order · sharky

### Liquid staking / restaking
marinade-finance · solayer-restaking-program

### NFT / Metaplex
mpl-core · mpl-token-metadata · bubblegum

### Bridges
circle-message-transmitter-v2 · circle-token-messenger-v2

### Native / utility
system-program · stake-program · address-lookup-table · token-program · token-2022 · associated-token-account · memo-program · name-service · swig

Each sub-skill page lists the program ID, the crate name, and the available instruction / account / event / type names. For full per-item details (struct fields, discriminators, account variants), invoke the `scripts/carbon.py` commands shown at the top of this file or in any sub-skill.
