# Metadata — what's globally available in a processor

Every processor input tuple carries some flavor of metadata. Together they give you slot, signature, fee payer, log messages, balances, block time, instruction stack position, and the raw account list. This page is the field-level reference.

## TransactionMetadata

Carried by **every** instruction processor (via `InstructionMetadata.transaction_metadata`) and every transaction processor.

```rust
pub struct TransactionMetadata {
    pub slot: u64,
    pub signature: Signature,
    pub fee_payer: Pubkey,                                // first account key in the message
    pub meta: solana_transaction_status::TransactionStatusMeta,
    pub message: solana_message::VersionedMessage,        // VersionedMessage::Legacy | V0
    pub index: Option<u64>,                               // tx index within block (None on some sources)
    pub block_time: Option<i64>,                          // unix seconds (None on some sources)
    pub block_hash: Option<Hash>,                         // for fork detection
}
```

In an instruction processor, access via `meta.transaction_metadata.signature`, etc. Note the field is `Arc<TransactionMetadata>` — clone is cheap.

### `meta` (TransactionStatusMeta) holds

| Field | Type | Use |
|---|---|---|
| `status` | `Result<(), TransactionError>` | `meta.status.is_err()` to filter failed txs |
| `fee` | `u64` | priority fee paid |
| `pre_balances` / `post_balances` | `Vec<u64>` | SOL deltas keyed by message account index |
| `pre_token_balances` / `post_token_balances` | `Option<Vec<TransactionTokenBalance>>` | per-mint balance changes — has `account_index`, `mint`, `owner`, `program_id`, `ui_token_amount` |
| `inner_instructions` | `Option<Vec<InnerInstructions>>` | full CPI tree (Carbon already nests these into `NestedInstructions`) |
| `log_messages` | `Option<Vec<String>>` | raw program logs incl. "Program data:" lines used by `decode_log_events` |
| `rewards` | `Option<Rewards>` | usually empty for non-validator txs |
| `loaded_addresses` | `LoadedAddresses` | resolved ALT lookups (writable + readonly) |
| `compute_units_consumed` | `Option<u64>` | budget metric |

### `message` (VersionedMessage) holds

```rust
pub enum VersionedMessage {
    Legacy(Message),
    V0(Message),
}
```

Useful methods on `&VersionedMessage`:
- `.static_account_keys() -> &[Pubkey]` — the keys referenced inline (NOT including ALT entries).
- `.recent_blockhash() -> &Hash`
- `.address_table_lookups()` — for v0 transactions, the `MessageAddressTableLookup` list.

To resolve a complete account-index → pubkey mapping including ALT entries, combine `static_account_keys()` with `meta.loaded_addresses.writable` then `meta.loaded_addresses.readonly` (in that order).

## InstructionMetadata

```rust
pub struct InstructionMetadata {
    pub transaction_metadata: Arc<TransactionMetadata>,
    pub stack_height: u32,                  // 1 = top-level, 2+ = inner CPI
    pub index: u32,                         // 1-based index within stack-height level
    pub absolute_path: Vec<u8>,             // hierarchical position used by log-event decoder
}
```

`stack_height` lets you discriminate top-level invocations from CPI calls. For example, only top-level Raydium swaps:

```rust
if meta.stack_height != 1 { return Ok(()); }
```

`absolute_path` is normally for internal use. The two methods you'll actually call on `InstructionMetadata`:

```rust
impl InstructionMetadata {
    pub fn decode_log_events<T: CarbonDeserialize>(&self) -> Vec<T>;
    // (private) extract_event_log_data — parses logs into raw bytes
}
```

`decode_log_events` walks `transaction_metadata.meta.log_messages`, picks only the lines emitted by **this specific instruction** (using `stack_height` + `absolute_path`), strips the `Program data:` base64 prefix, and Borsh-decodes them as `T`. Returns every successful match.

## AccountMetadata

Provided to account processors:

```rust
pub struct AccountMetadata {
    pub slot: u64,
    pub pubkey: Pubkey,
    pub transaction_signature: Option<Signature>,    // None for snapshot or GPA sources
}
```

For snapshot/GPA sources `transaction_signature` is `None` because the data isn't from a tx — it's a state read. For streaming sources (Yellowstone, LaserStream, Atlas, RPC subscribes) it's the signature that caused the write.

## DecodedAccount<T>

```rust
pub struct DecodedAccount<T> {
    pub lamports: u64,
    pub data: T,
    pub owner: Pubkey,
    pub executable: bool,
    pub rent_epoch: u64,
}
```

`data` is your protocol-specific account variant (the `<Name>Account` enum from each decoder).

## DecodedInstruction<T>

```rust
pub struct DecodedInstruction<T> {
    pub program_id: Pubkey,
    pub data: T,                           // your protocol's `Instruction` enum variant
    pub accounts: Vec<AccountMeta>,        // raw, unnamed; pass to arrange_accounts
}
```

## NestedInstructions

A wrapper around `Vec<NestedInstruction>` (deref'd to a slice) representing the inner-instructions tree under a given top-level invocation:

```rust
pub struct NestedInstruction {
    pub metadata: InstructionMetadata,
    pub instruction: solana_instruction::Instruction,
    pub inner_instructions: NestedInstructions,
}
```

For an Instruction pipe, the `NestedInstructions` you receive is the **children** of the instruction your processor is currently being called for — not the whole tree. To recurse, walk it and decode children yourself, or register additional `.instruction(...)` pipes (the pipeline already walks the full tree for every registered decoder).

## What's NOT in the metadata (and how to get it)

| Need | Source |
|---|---|
| Compute units used | `meta.transaction_metadata.meta.compute_units_consumed` |
| Failed tx flag | `meta.transaction_metadata.meta.status.is_err()` |
| Pre/post token balance for one wallet | scan `meta.pre_token_balances` / `post_token_balances` for `owner == X` |
| ALT-resolved account list | `message.static_account_keys()` + `meta.loaded_addresses.writable` + `.readonly` |
| Tip to Jito validator | inspect `meta.inner_instructions` for transfers to a Jito tip account |
| Priority fee | `meta.fee` minus the 5000-lamport base, OR parse `ComputeBudget::SetComputeUnitPrice` instruction |
| Wall-clock time | `meta.block_time` (Unix seconds) — `None` on some sources, fall back to RPC `getBlockTime(slot)` |
