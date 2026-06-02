---
name: carbon-solana
description: "Build Solana indexers with the Carbon framework (sevenlabs-hq/carbon). Use when wiring a Carbon Pipeline, choosing a datasource (Yellowstone gRPC, Helius Laserstream/Atlas, RPC block-subscribe, jetstreamer, jito-shredstream, validator-snapshot), implementing a Processor, decoding instructions/accounts for a specific Solana program (Raydium AMM v4 / CLMM / CPMM / Launchpad, Pumpfun, Pumpswap, Meteora DLMM/DAMMv2/DBC/Pools/Vault, Orca Whirlpool, Jupiter Swap/DCA/Limit/Perpetuals/Lend, Drift v2, Kamino lending/farms/vault, Phoenix v1, Marginfi v2, OpenBook v2, Moonshot, Lifinity, Stabble, Bonkswap, Boop, Heaven, Vertigo, Virtuals, Sharky, Zeta, Fluxbeam, Pancake, OKX DEX, Marinade, Solayer, Bubblegum, MPL Core/Token Metadata, SPL Token / Token-2022, ATA, ALT, Stake, System, Memo, Name Service, Swig, Wavebreak, Gavel, DFlow, Circle CCTP), extracting CPI event logs via decode_log_events, building schema-matched Transaction pipes, generating decoders from an IDL with carbon-cli, or looking up the args/accounts/discriminator of a specific instruction or event. Triggers on \"carbon\", \"carbon-core\", \"carbon-cli\", \"yellowstone grpc\", \"InstructionDecoder\", \"AccountDecoder\", \"ArrangeAccounts\", \"CarbonDeserialize\", \"decode_log_events\", \"Pipeline::builder\", \"NestedInstructions\", \"TransactionMetadata\", \"InstructionMetadata\", or any of the protocol names above paired with \"decode\", \"indexer\", \"instruction\", \"event\", or \"args\"."
---

# Carbon — Solana indexing framework

Carbon (`sevenlabs-hq/carbon`) is a modular Rust pipeline for ingesting Solana data, decoding accounts/instructions/CPI events for specific programs, and running custom processors. Workspace layout: `crates/core` + `datasources/` (14 sources) + `decoders/` (60+ programs) + `metrics/` + `examples/`.

## When to use this skill

- Wiring a `Pipeline` with one or more datasources and processors.
- Decoding a specific Solana program's instructions, accounts, or events.
- Looking up the **exact args, accounts (with optional/variant flags), and discriminator** for a specific instruction or event in any supported protocol.
- Choosing the right datasource for a workload (real-time gRPC vs WebSocket vs RPC crawler vs snapshot).
- Generating a decoder crate from an Anchor or Codama IDL via `carbon-cli`.
- Schema-matching whole transactions instead of single instructions.
- Extracting CPI log events emitted by Anchor-style programs.

## Pipeline anatomy

```
Datasource ──► Update ──► Pipe ──────────────► Processor ──► your code
              (enum)     (decoder + filters)    (async fn process)
```

Five pipe types — each delivers a different input tuple to its `Processor`:

| Pipe | Decoder | Processor input tuple |
|---|---|---|
| `account` | `AccountDecoder` | `(AccountMetadata, DecodedAccount<T>, solana_account::Account)` |
| `account_deletions` | — | `(AccountDeletion,)` |
| `block_details` | — | `BlockDetails` |
| `instruction` | `InstructionDecoder` | `(InstructionMetadata, DecodedInstruction<T>, NestedInstructions, solana_instruction::Instruction)` |
| `transaction` | schema | `(Arc<TransactionMetadata>, Vec<(InstructionMetadata, DecodedInstruction<T>)>, Option<U>)` |

`InstructionMetadata.transaction_metadata` gives you slot, signature, fee_payer, log messages, balances, block_time, block_hash — see `references/metadata.md`.

## Quickstart — Yellowstone gRPC + Raydium AMM v4

```rust
use {
    async_trait::async_trait,
    carbon_core::{
        error::CarbonResult,
        instruction::{DecodedInstruction, InstructionMetadata, NestedInstructions},
        metrics::MetricsCollection,
        processor::Processor,
    },
    carbon_log_metrics::LogMetrics,
    carbon_raydium_amm_v4_decoder::{
        instructions::RaydiumAmmV4Instruction, RaydiumAmmV4Decoder,
        PROGRAM_ID as RAYDIUM_AMM_V4_PROGRAM_ID,
    },
    carbon_yellowstone_grpc_datasource::{
        YellowstoneGrpcClientConfig, YellowstoneGrpcGeyserClient,
    },
    std::{collections::{HashMap, HashSet}, env, sync::Arc, time::Duration},
    tokio::sync::RwLock,
    yellowstone_grpc_proto::geyser::{CommitmentLevel, SubscribeRequestFilterTransactions},
};

#[tokio::main]
async fn main() -> CarbonResult<()> {
    rustls::crypto::aws_lc_rs::default_provider().install_default().ok();

    let mut tx_filters = HashMap::new();
    tx_filters.insert("raydium".into(), SubscribeRequestFilterTransactions {
        vote: Some(false),
        failed: Some(false),
        account_required: vec![RAYDIUM_AMM_V4_PROGRAM_ID.to_string()],
        ..Default::default()
    });

    let ds = YellowstoneGrpcGeyserClient::new(
        env::var("GEYSER_URL").unwrap(),
        env::var("X_TOKEN").ok(),
        Some(CommitmentLevel::Confirmed),
        HashMap::default(),  // account_filters
        tx_filters,
        Default::default(),  // block_filters
        Arc::new(RwLock::new(HashSet::new())),  // tracked deletions
        YellowstoneGrpcClientConfig::default(),
        None, None,
    );

    carbon_core::pipeline::Pipeline::builder()
        .datasource(ds)
        .metrics(Arc::new(LogMetrics::new()))
        .instruction(RaydiumAmmV4Decoder, RaydiumProcessor)
        .build()?
        .run()
        .await
}

struct RaydiumProcessor;
#[async_trait]
impl Processor for RaydiumProcessor {
    type InputType = (
        InstructionMetadata,
        DecodedInstruction<RaydiumAmmV4Instruction>,
        NestedInstructions,
        solana_instruction::Instruction,
    );
    async fn process(&mut self, (meta, ix, _inner, _raw): Self::InputType,
                     _m: Arc<MetricsCollection>) -> CarbonResult<()> {
        let sig = meta.transaction_metadata.signature;
        match ix.data {
            RaydiumAmmV4Instruction::SwapBaseIn(s) =>
                println!("{sig} swap_base_in amount_in={} min_out={}", s.amount_in, s.minimum_amount_out),
            _ => {}
        }
        Ok(())
    }
}
```

## Quickstart — RPC block-subscribe (no special infra)

```rust
use carbon_rpc_block_subscribe_datasource::{Filters, RpcBlockSubscribe};
use solana_client::rpc_config::{RpcBlockSubscribeConfig, RpcBlockSubscribeFilter};

let ds = RpcBlockSubscribe::new(
    env::var("RPC_WS_URL").unwrap(),
    Filters::new(
        RpcBlockSubscribeFilter::MentionsAccountOrProgram(
            RAYDIUM_AMM_V4_PROGRAM_ID.to_string()
        ),
        Some(RpcBlockSubscribeConfig {
            commitment: Some(CommitmentConfig::confirmed()),
            transaction_details: Some(TransactionDetails::Full),
            show_rewards: Some(false),
            encoding: Some(UiTransactionEncoding::Base64),
            max_supported_transaction_version: Some(0),
        }),
    ),
);
```

The rest of the pipeline (`.instruction(...)`, `.metrics(...)`, processor impl) is identical.

## Decoder crate naming

Every decoder is `carbon-<protocol>-decoder` on crates.io and exports:
- `pub const PROGRAM_ID: Pubkey` — the on-chain program ID.
- `pub struct <Name>Decoder;` — implements `InstructionDecoder` and/or `AccountDecoder`.
- `pub mod accounts;` — account types + the `<Name>Account` enum.
- `pub mod instructions;` — instruction types + the `<Name>Instruction` enum.
- `pub mod types;` — shared types (some events live here, not under `events/`).
- `pub mod events;` — only on Codama-generated decoders (Anchor-style CPI logs).

## Where to look next

| You need | Open |
|---|---|
| Pipeline/Builder methods, ShutdownStrategy, channel sizing | `references/architecture.md` |
| All 14 datasources + their config structs and filter types | `references/datasources.md` |
| Pipe input tuples + Processor trait + log-event extraction | `references/pipes-and-processors.md` |
| TransactionMetadata / InstructionMetadata / AccountMetadata fields | `references/metadata.md` |
| Decoder layout, `CarbonDeserialize`, `ArrangeAccounts`, discriminators | `references/decoder-anatomy.md` |
| Schema matching for whole-transaction pipes | `references/transaction-schema.md` |
| `carbon-cli parse|scaffold` to generate a decoder from an IDL | `references/cli-codegen.md` |
| Browse all 64 supported programs | `references/protocols/_index.md` |
| **A specific protocol** (Raydium, Pumpfun, Meteora, Drift, …) | the `carbon-<slug>` sub-skill auto-loads when you mention it; or open `plugins/carbon-solana/skills/carbon-<slug>/SKILL.md` directly |

## Per-protocol details — use the bundled script

Each of the 64 protocols has a thin sub-skill (`plugins/carbon-solana/skills/carbon-<slug>/SKILL.md`) that lists:
- crate name + program ID + decoder struct
- the names of every available instruction, account, CPI event, and shared type

To pull **full** struct fields, discriminators, and account variants for any of those names, run:

```bash
# requires python3 (>= 3.8); ast-grep optional but recommended for richer output
python3 plugins/carbon-solana/scripts/carbon.py list <slug>
python3 plugins/carbon-solana/scripts/carbon.py ix <slug> <InstructionName>
python3 plugins/carbon-solana/scripts/carbon.py account <slug> <AccountName>
python3 plugins/carbon-solana/scripts/carbon.py event <slug> <EventName>
python3 plugins/carbon-solana/scripts/carbon.py type <slug> <TypeName>
python3 plugins/carbon-solana/scripts/carbon.py search '<regex>' [--in <slug>]
```

The script reads from your local cargo registry cache (`~/.cargo/registry/src/.../carbon-<slug>-decoder-*/`) — populated automatically the first time any project depends on the crate and runs `cargo fetch` or `cargo build`. To point at a different source tree (e.g. a clone of `sevenlabs-hq/carbon`), set `CARBON_SRC=/path/to/carbon`.

If `ast-grep` and the crate aren't available, the script falls back to regex extraction and prompts:

```sh
# install ast-grep (recommended for richer struct extraction):
cargo install ast-grep
# or:
brew install ast-grep
```

## Conventions when writing indexers

- `solana_instruction::Instruction.accounts` is a `Vec<AccountMeta>`. Call `<Instruction>::arrange_accounts(&ix.accounts)` on a decoded variant to get a typed struct of named pubkeys. The match returns `Option<...>` — handle the `None` case (it's hit on truncated/malformed instructions).
- Many instructions have multiple account-count variants (e.g. Raydium AMM v4 `SwapBaseIn` accepts 17 or 18, with `amm_target_orders` becoming optional). The protocol pages list every variant.
- For Anchor-style programs (Pumpfun, Raydium CPMM, etc.), CPI events are emitted as base64-encoded log messages. Use `instruction_metadata.decode_log_events::<MyEvent>()` to decode them off the surrounding instruction.
- The Transaction pipe's optional `U` is a custom struct deserialized from a `match_schema` invocation — see `references/transaction-schema.md`.
