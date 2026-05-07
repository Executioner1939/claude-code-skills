---
name: astgrep-rule-authoring
description: >
  How to author ast-grep rules per project for Rust architecture
  enforcement. Auto-loaded by the rule-author agent during /audit-domain.
  Defines the rule YAML schema, pattern syntax, atomic vs relational vs
  composite rules, the "instance + generalized" pair pattern, severity
  conventions, sgconfig.yml integration, and CI invocation. Stack-agnostic
  by design; the plugin authors rules per project rather than shipping them.
---

# ast-grep rule authoring

This skill is a YAML cookbook. The plugin does not ship architecture rules -- it ships the **methodology** for authoring them per project. Every domain audited by `/audit-domain` produces its own rule directory, merged into the project's `sgconfig.yml`.

The plugin's role is to teach the `rule-author` agent how to write rules; the rules themselves emerge from your codebase.

---

## When this skill applies

Auto-loaded into the `rule-author` agent. Also useful for any agent that needs to refer to or check ast-grep rules in `acceptance` criteria.

Reference docs (cite when authoring):

- Rule config: <https://ast-grep.github.io/guide/rule-config.html>
- YAML reference: <https://ast-grep.github.io/reference/yaml.html>
- Rule reference: <https://ast-grep.github.io/reference/rule.html>
- Pattern syntax: <https://ast-grep.github.io/guide/pattern-syntax.html>
- Cheatsheet: <https://ast-grep.github.io/cheatsheet/yaml.html>
- sgconfig.yml: <https://ast-grep.github.io/reference/sgconfig.html>

---

## Project layout (this plugin's convention)

```
<scope>/
├── sgconfig.yml                    # rule directories registered here
└── .refactor/
    └── rules/
        ├── <domain-1>/
        │   ├── domain-no-infra-import.yml   # instance rule
        │   └── no-runtime-deps-in-pure-fns.yml  # generalized rule
        ├── <domain-2>/
        │   └── ...
        └── shared/
            └── ...
```

`sgconfig.yml` lists each rule directory:

```yaml
ruleDirs:
  - .refactor/rules/<domain-1>
  - .refactor/rules/<domain-2>
  - .refactor/rules/shared
```

---

## Rule file schema

```yaml
id: <kebab-case-rule-id>          # required, unique
language: Rust                    # required
severity: error                   # hint | info | warning | error | off
message: "Short message shown on match."
note: |
  Longer explanation. Why this rule exists. What to do instead.
  Quote the architecture invariant being protected.
files:                            # glob patterns; rule applies only to these
  - "src/domain/**/*.rs"
ignores:                          # optional: globs to skip
  - "**/tests/**"
rule:
  # one of: pattern, kind, regex, all, any, not, matches, inside, has, follows, precedes
constraints:                      # optional: per-meta-variable filters
  VARNAME:
    regex: "..."
    not:
      kind: ...
fix: |                            # optional: auto-fix template (use sparingly)
  ...
utils:                            # optional: shared sub-rules referenced by `matches:`
  is-domain-trait: ...
```

---

## Pattern syntax (Rust)

| Token | Matches |
|---|---|
| `$VAR` | one AST node, captured as `VAR` |
| `$$$` | zero-or-more nodes (anonymous) |
| `$$$ARGS` | zero-or-more nodes, captured as `ARGS` |
| `$_` | one anonymous node (wildcard) |
| literal Rust source | parsed by tree-sitter-rust; matches structurally |

Common tree-sitter-rust kinds (use in `kind:`):

- `use_declaration`
- `struct_item`, `enum_item`, `union_item`
- `impl_item`, `trait_item`
- `function_item`, `function_signature_item`
- `attribute_item`
- `match_expression`, `match_arm`
- `call_expression`, `await_expression`
- `block`, `expression_statement`
- `field_expression`, `method_call_expression`

When unsure of the kind: run `ast-grep run --debug-query --pattern '<your snippet>' --lang rust example.rs` to inspect the AST.

---

## Rule kinds (composable)

**Atomic** -- match one node:

- `pattern: <rust-source>` -- structural match
- `kind: <ts-kind>` -- node-type match
- `regex: '<pcre>'` -- text regex (least preferred; use sparingly)

**Relational** -- match a node in relation to another:

- `inside: <sub-rule>` -- node is a descendant of a match for sub-rule
- `has: <sub-rule>` -- node has a descendant matching sub-rule
- `follows: <sub-rule>` -- node comes after a match for sub-rule (sibling)
- `precedes: <sub-rule>` -- node comes before a match for sub-rule

Relational rules accept `stopBy: end | neighbor | <inner-rule>` to bound traversal.

**Composite** -- combine atomic and relational:

- `all: [<rule>, <rule>, ...]` -- node must match every sub-rule
- `any: [<rule>, <rule>, ...]` -- node matches if any sub-rule matches
- `not: <rule>` -- node does not match the sub-rule
- `matches: <util-id>` -- references a `utils:` entry

**Constraints** -- post-match filters on captured meta-variables:

```yaml
rule:
  pattern: fn $H($$$) -> $RET { $$$ }
constraints:
  H:
    regex: '^handle_'
  RET:
    regex: 'Result<.*,\s*\w*Error\s*>'
```

---

## The "instance + generalized" pair pattern

For every violation found by `/audit-domain`, the `rule-author` agent emits **two rules**:

1. **Instance rule** -- catches the exact violating snippet. Narrow, regex-grounded, low false-positive. Used to verify the specific violation is fixed.

2. **Generalized rule** -- catches the broader class of the same mistake. Uses `kind:` + relational rules + meta-variables instead of literal regex. Used to prevent the pattern recurring elsewhere.

Worked example -- finding `crate::infrastructure::kurrent` import in domain code:

**Instance rule** (`rules/orders/no-direct-kurrent-import-in-orders-decider.yml`):

```yaml
id: no-direct-kurrent-import-in-orders-decider
language: Rust
severity: error
message: "src/domain/orders/decider.rs imports crate::infrastructure::kurrent."
note: |
  domain/ must depend only on its own ports. Kurrent client lives in
  infrastructure/. The fix is to define a port trait in
  application/ports/event_store.rs and inject it.
files:
  - "src/domain/orders/decider.rs"
rule:
  kind: use_declaration
  regex: 'crate::infrastructure::kurrent'
```

**Generalized rule** (`rules/shared/domain-no-infra-import.yml`):

```yaml
id: domain-no-infra-import
language: Rust
severity: error
message: "domain/ may not import from infrastructure/ or adapter/."
note: |
  Hexagonal architecture: domain layer is pure. Adapters live outside.
  Define a port trait in application/ if domain needs to express the
  capability; let infrastructure implement it.
files:
  - "src/domain/**/*.rs"
ignores:
  - "**/tests/**"
rule:
  kind: use_declaration
  regex: 'crate::(infrastructure|adapter)'
```

The instance rule is closeable -- once the violation is fixed, it should report 0 hits forever (it lives until you delete it, or move it to an "archived" subdirectory). The generalized rule is permanent -- it prevents recurrence anywhere in the domain.

---

## Severity conventions

| Severity | Meaning | When to use |
|---|---|---|
| `error` | Architecture invariant violated; build should fail | Hexagonal-boundary violations, purity violations, forbidden imports |
| `warning` | Style or weak smell; should be fixed but not blocking | Naming inconsistencies, missing docs on public API |
| `info` | Notable pattern; informational | Deprecation candidates, "consider doing X instead" |
| `hint` | Soft suggestion | Code-style preferences |
| `off` | Disabled | Use `severity: off` to keep a rule in the repo for reference but not enforce it |

This plugin defaults to `severity: error` for every rule the `rule-author` writes. Architecture invariants are not warnings.

---

## Pattern catalogue (generic; not stack-specific)

These are generic shapes the rule-author can adapt -- NOT shipped as rules. The `/audit-domain` agent mints rules with these shapes parameterized by what it found in your repo.

### Forbid an import from a layer

```yaml
rule:
  kind: use_declaration
  regex: 'crate::(forbidden_layer1|forbidden_layer2)'
files:
  - "src/<allowed-layer>/**/*.rs"
```

### Forbid a function call inside a specific scope

```yaml
rule:
  pattern: $FUNC($$$)
  inside:
    kind: function_item
    has:
      kind: identifier
      regex: '^(decide|evolve|react)$'
constraints:
  FUNC:
    any:
      - regex: '^tokio::'
      - regex: '^sqlx::'
      - regex: '^reqwest::'
```

### Require a derive on a type

```yaml
rule:
  all:
    - kind: struct_item
      regex: 'Event\b'      # name ends in Event
    - not:
        has:
          stopBy: end
          kind: attribute_item
          regex: 'derive\([^)]*Serialize'
```

### Require a return type signature

```yaml
rule:
  pattern: fn $H($$$) -> $RET { $$$ }
constraints:
  H:
    regex: '^handle_'
  RET:
    not:
      regex: 'Result<.*,'
```

### Forbid a method call

```yaml
rule:
  any:
    - pattern: $E.unwrap()
    - pattern: $E.expect($_)
files:
  - "src/domain/**/*.rs"
  - "src/application/**/*.rs"
```

### Require a trait impl in a specific directory

```yaml
rule:
  kind: impl_item
  not:
    has:
      kind: trait_bounds
      regex: '\bExpectedTrait\b'
files:
  - "src/adapter/repository/**/*.rs"
```

---

## CI invocation

```bash
ast-grep scan --error -c sgconfig.yml
```

`--error` makes any `severity: error` match fail the run with exit code 1. For PR-comment bots:

```bash
ast-grep scan -c sgconfig.yml --json | jq -r '.[] | "\(.file):\(.range.start.line) [\(.ruleId)] \(.message)"'
```

---

## Author-time discipline

When the `rule-author` agent writes rules, it must:

1. **Read the violations.md first.** Every rule pairs with one or more documented violations.
2. **Cite the architecture invariant.** The rule's `note:` quotes the invariant from `.refactor/standard.md`.
3. **Run the rule against the repo before committing it.** A rule that immediately reports zero hits in a repo with known violations is wrong; a rule that reports hundreds of hits in clean code is too broad. Use `ast-grep scan --rule <new-rule>.yml` to dry-run.
4. **Pair instance + generalized.** Both files for every distinct violation pattern.
5. **Use `kind:` + relational over `regex:`** wherever possible. Regex on Rust source is fragile.
6. **Scope with `files:`.** Most rules apply to a layer (`src/domain/**`), not the whole repo.
7. **No `fix:` blocks unless the fix is mechanical and reviewed.** Auto-fixes are dangerous on architecture rules; default to manual remediation tickets.

---

## Anti-patterns (don't do)

- Catch-all regex rules without `kind:` -- false positives drown the signal.
- Overlapping rules with the same id in different directories -- ast-grep behavior is undefined.
- Auto-fixes on architecture rules -- the fix is usually a refactor, not a substitution.
- Rules that depend on file naming alone -- rename the file and the rule misses.
- Ignoring `ignores:` for tests, examples, build scripts.
