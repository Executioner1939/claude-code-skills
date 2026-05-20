---
name: openapi-rust-gen
description: |
  Generate or refresh a Rust client crate from an OpenAPI spec using the pinned openapi-generator-cli docker image, and wire the same step into a moon task so future regenerations are a one-liner.
  Keywords: openapi, openapi-generator, openapi-generator-cli, rust client, generate rust client, regenerate openapi rust client, regenerate client from openapi, openapi to rust, openapitools, reqwest client, supportAsync, packageName, hindsight-client, rapyd-client, bridgerpay-client, paypal-client.
  Triggers: "regenerate the openapi rust client", "generate a rust client from this openapi spec", "scaffold a client crate from <vendor>'s openapi", "openapi-generator-cli rust", "bump the openapi generator", "refresh the openapi snapshot", "moon task to regenerate the <x>-client crate".
paths:
  - "**/docker/*/refresh.sh"
  - "**/docker/*/*.json"
  - "**/docker/*/*.yaml"
  - "**/docker/*/*.yml"
  - "**/openapi.json"
  - "**/openapi.yaml"
  - "**/*-client/Cargo.toml"
  - "**/*_client/Cargo.toml"
---

# openapi-rust-gen

Generate a Rust client crate from an OpenAPI spec using `openapitools/openapi-generator-cli` (pinned to **v7.10.0**) via Docker. The bundled script handles both the spec refresh and the generator run; the typical consuming repo wires it into a `moon.yml` task so future regenerations are `moon run <crate>:gen-<provider>`.

The reference pattern is hermes-platform's hindsight-client setup -- one shared snapshot under `docker/<provider>/`, one moon task per consumer that calls the generator with that snapshot. This skill ships that pattern as a reusable script.

## The bundled script

`scripts/openapi-rust-gen.sh` is the load-bearing tool. It is a non-interactive, single-pass shell script. Read its header comment for full flag semantics; the contract is:

| Flag | Required | Purpose |
|---|---|---|
| `--spec <url-or-path>` | yes | OpenAPI document. URLs are fetched with curl and atomically written under `<workspace>/docker/<provider>/<provider>.<ext>`; local paths are used in place. |
| `--out-dir <dir>` | yes | Output directory for the generated crate, relative to the workspace root (for example `libs/rapyd-client`). |
| `--crate-name <name>` | yes | Cargo `packageName` for the generated crate. |
| `--generator-version <tag>` | no | Docker image tag. Defaults to `v7.10.0` to match hermes-platform. Bumping is deliberate. |
| `--refresh-only` | no | Fetch the spec only, skip the generator. Use this for the spec-refresh moon task when the gen step lives in a separate task. |
| `--workspace-root <path>` | no | Defaults to `git rev-parse --show-toplevel`. |

Provider name is derived from `--crate-name` by stripping a trailing `_client` or `-client` suffix; that becomes the directory name under `docker/`.

## Standard invocation

Generate (or regenerate) a `rapyd-client` crate from a GitHub raw URL:

```bash
plugins/oracle-devops/scripts/openapi-rust-gen.sh \
  --spec https://raw.githubusercontent.com/Rapyd/openapi/main/openapi.yaml \
  --out-dir libs/rapyd-client \
  --crate-name rapyd_client
```

Generate from an already-committed local snapshot, skipping the fetch:

```bash
plugins/oracle-devops/scripts/openapi-rust-gen.sh \
  --spec docker/rapyd/rapyd.yaml \
  --out-dir libs/rapyd-client \
  --crate-name rapyd_client
```

Refresh only -- pull the latest spec without regenerating (e.g. to review the diff first):

```bash
plugins/oracle-devops/scripts/openapi-rust-gen.sh \
  --spec https://raw.githubusercontent.com/Rapyd/openapi/main/openapi.yaml \
  --out-dir libs/rapyd-client \
  --crate-name rapyd_client \
  --refresh-only
```

## Moon task wiring

Once the script is run once and the snapshot is committed, wire a moon task in the consuming crate's `moon.yml` so future regenerations are one command. Both tasks declare `runInCI: false` and `cache: false` -- they are local-only regenerations, the output is committed.

```yaml
tasks:
  # Regenerate the client crate from the committed snapshot. The pinned
  # generator version is the source of truth -- bumping it is a
  # deliberate, reviewed change.
  gen-rapyd:
    description: 'Regenerate libs/rapyd-client from the committed OpenAPI snapshot'
    command: '../../plugins/oracle-devops/scripts/openapi-rust-gen.sh'
    args:
      - '--spec'
      - 'docker/rapyd/rapyd.yaml'
      - '--out-dir'
      - 'libs/rapyd-client'
      - '--crate-name'
      - 'rapyd_client'
    inputs:
      - '/docker/rapyd/rapyd.yaml'
    options:
      cache: false
      runInCI: false

  # Refresh the committed snapshot from upstream. Separated from gen-rapyd
  # so the user can review the spec diff before regenerating.
  refresh-rapyd-spec:
    description: 'Refresh docker/rapyd/rapyd.yaml from upstream'
    command: '../../plugins/oracle-devops/scripts/openapi-rust-gen.sh'
    args:
      - '--spec'
      - 'https://raw.githubusercontent.com/Rapyd/openapi/main/openapi.yaml'
      - '--out-dir'
      - 'libs/rapyd-client'
      - '--crate-name'
      - 'rapyd_client'
      - '--refresh-only'
    options:
      cache: false
      runInCI: false
```

Adjust the script path to match how the marketplace plugin is installed in the consuming repo (relative path from the moon project, or an absolute path under `~/.claude/plugins/...`).

## Failure modes the script catches

- `docker` missing or daemon not reachable -- exit 2 with a Docker-Desktop hint, before any network call.
- Spec URL returns non-2xx or an empty body -- exit 3, temp file is cleaned up, the snapshot on disk is untouched.
- Spec local path lives outside the workspace root -- exit 3 (Docker bind mount is `$workspaceRoot:/local`, so anything outside is invisible to the container).
- Generator finishes but no `Cargo.toml` appears in `--out-dir` -- exit 4. This usually means the spec is malformed and openapi-generator-cli printed a stack trace.

## Cross-skill defences

- For the moon-task side of this (inheritance, `runInCI: false`, name-drift checks), defer to `oracle-devops:ci-moonrepo`. The example task block above already follows its Rule 2 (explicit `runInCI`).
- For OpenAPI-snapshot drift between Rust and TypeScript clients consuming the same spec, mirror hermes-platform's pattern: one `docker/<provider>/` directory, two `gen-<provider>` tasks (Rust via this script, TypeScript via orval), one shared `refresh-<provider>-spec` task.
