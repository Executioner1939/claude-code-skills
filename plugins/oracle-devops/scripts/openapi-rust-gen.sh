#!/usr/bin/env bash
# openapi-rust-gen.sh -- generate or refresh a Rust client crate from an
# OpenAPI spec via the pinned openapi-generator-cli docker image.
#
# Mirrors the hermes-platform gen-hindsight + refresh.sh pattern: a
# spec is fetched (or copied) under <workspace>/docker/<provider>/, then
# openapitools/openapi-generator-cli:<tag> is invoked with the workspace
# mounted at /local so paths translate cleanly.
#
# Invocation:
#   ./openapi-rust-gen.sh --spec <url-or-path> --out-dir <dir> --crate-name <name>
#                        [--generator-version <tag>] [--refresh-only]
#                        [--workspace-root <path>]
#
# Required:
#   --spec          URL (http/https) or local path to the OpenAPI document.
#                   YAML or JSON. URLs are fetched and atomically written
#                   under <workspace>/docker/<provider>/<provider>.<ext>.
#   --out-dir       Output directory for the generated crate, relative to
#                   the workspace root (e.g. libs/rapyd-client).
#   --crate-name    Cargo package name for the generated crate. Used as
#                   --additional-properties=packageName=<name>.
#
# Optional:
#   --generator-version  Docker image tag (default: v7.10.0). Bumping is
#                        deliberate -- pin matches hermes-platform.
#   --refresh-only       Fetch the spec only; skip the generator run.
#                        Useful when the spec is committed and the gen
#                        step lives in a moon task.
#   --workspace-root     Workspace root (default: git rev-parse --show-toplevel,
#                        or $PWD if not in a git repo).
#
# Exit codes:
#   0  success
#   1  usage / argument error
#   2  pre-flight failure (docker daemon down, missing dependency)
#   3  spec fetch failed
#   4  generator failed or output incomplete

set -euo pipefail

log() { printf '%s\n' "$*" >&2; }
die() { log "openapi-rust-gen: $1"; exit "${2:-1}"; }

SPEC=""
OUT_DIR=""
CRATE_NAME=""
GENERATOR_VERSION="v7.10.0"
REFRESH_ONLY=0
WORKSPACE_ROOT=""

while [ $# -gt 0 ]; do
  case "$1" in
    --spec)               SPEC="${2:?--spec requires a value}"; shift 2 ;;
    --out-dir)            OUT_DIR="${2:?--out-dir requires a value}"; shift 2 ;;
    --crate-name)         CRATE_NAME="${2:?--crate-name requires a value}"; shift 2 ;;
    --generator-version)  GENERATOR_VERSION="${2:?--generator-version requires a value}"; shift 2 ;;
    --refresh-only)       REFRESH_ONLY=1; shift ;;
    --workspace-root)     WORKSPACE_ROOT="${2:?--workspace-root requires a value}"; shift 2 ;;
    -h|--help)
      sed -n '2,33p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) die "unknown argument: $1" 1 ;;
  esac
done

[ -n "$SPEC" ]       || die "missing required --spec" 1
[ -n "$OUT_DIR" ]    || die "missing required --out-dir" 1
[ -n "$CRATE_NAME" ] || die "missing required --crate-name" 1

if [ -z "$WORKSPACE_ROOT" ]; then
  if WORKSPACE_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    :
  else
    WORKSPACE_ROOT="$PWD"
    log "warn: not in a git repo, using \$PWD as workspace root: $WORKSPACE_ROOT"
  fi
fi
[ -d "$WORKSPACE_ROOT" ] || die "workspace root does not exist: $WORKSPACE_ROOT" 1

# Provider name = crate-name minus a trailing _client / -client. Used
# for the spec snapshot directory under docker/<provider>/.
PROVIDER="${CRATE_NAME%_client}"
PROVIDER="${PROVIDER%-client}"

SPEC_DIR="$WORKSPACE_ROOT/docker/$PROVIDER"
SPEC_IS_URL=0
case "$SPEC" in
  http://*|https://*) SPEC_IS_URL=1 ;;
esac

if [ "$SPEC_IS_URL" -eq 1 ]; then
  command -v curl >/dev/null 2>&1 || die "curl is required to fetch a URL spec" 2

  # Infer extension from URL path (strip query/fragment first). Default yaml.
  url_path="${SPEC%%\?*}"
  url_path="${url_path%%#*}"
  ext="${url_path##*.}"
  case "$ext" in
    yaml|yml|json) : ;;
    *) ext="yaml" ;;
  esac

  SPEC_FILE="$SPEC_DIR/$PROVIDER.$ext"
  mkdir -p "$SPEC_DIR"

  log "fetching spec: $SPEC -> $SPEC_FILE"
  TMP="$SPEC_FILE.tmp.$$"
  trap 'rm -f "$TMP"' EXIT
  if ! curl -fsSL --max-time 30 -o "$TMP" "$SPEC"; then
    die "curl failed fetching $SPEC" 3
  fi
  [ -s "$TMP" ] || die "fetched spec is empty: $SPEC" 3
  mv "$TMP" "$SPEC_FILE"
  trap - EXIT
  log "spec written: $SPEC_FILE ($(wc -c < "$SPEC_FILE" | tr -d ' ') bytes)"
else
  # Local path. Resolve relative paths against $PWD, then sanity-check
  # it lives under the workspace root (mounted into the container).
  case "$SPEC" in
    /*) SPEC_FILE="$SPEC" ;;
    *)  SPEC_FILE="$PWD/$SPEC" ;;
  esac
  [ -f "$SPEC_FILE" ] || die "spec file not found: $SPEC_FILE" 3
  case "$SPEC_FILE" in
    "$WORKSPACE_ROOT"/*) : ;;
    *) die "spec file must live under workspace root ($WORKSPACE_ROOT): $SPEC_FILE" 3 ;;
  esac
  log "using existing spec: $SPEC_FILE"
fi

if [ "$REFRESH_ONLY" -eq 1 ]; then
  log "refresh-only requested; skipping generator"
  exit 0
fi

# Pre-flight: docker daemon must be reachable. `docker info` is the
# canonical check; a missing binary or a stopped daemon both fail it.
if ! command -v docker >/dev/null 2>&1; then
  die "docker is not installed or not on PATH" 2
fi
if ! docker info >/dev/null 2>&1; then
  die "docker daemon is not reachable (is Docker Desktop running?)" 2
fi

# Translate host paths to container paths (/local mount).
SPEC_REL="${SPEC_FILE#"$WORKSPACE_ROOT"/}"
OUT_REL="${OUT_DIR#/}"
OUT_REL="${OUT_REL#"$WORKSPACE_ROOT"/}"
OUT_HOST="$WORKSPACE_ROOT/$OUT_REL"

mkdir -p "$OUT_HOST"

log "generating Rust client:"
log "  spec:      /local/$SPEC_REL"
log "  out-dir:   /local/$OUT_REL"
log "  crate:     $CRATE_NAME"
log "  generator: openapitools/openapi-generator-cli:$GENERATOR_VERSION"

docker run --rm \
  -v "$WORKSPACE_ROOT:/local" \
  "openapitools/openapi-generator-cli:$GENERATOR_VERSION" \
  generate \
  -i "/local/$SPEC_REL" \
  -g rust \
  -o "/local/$OUT_REL" \
  --additional-properties=library=reqwest,supportAsync=true,packageName="$CRATE_NAME",preferUnsignedInt=true,packageVersion=0.1.0 \
  || die "openapi-generator-cli failed" 4

if [ ! -f "$OUT_HOST/Cargo.toml" ]; then
  die "generator finished but $OUT_HOST/Cargo.toml is missing -- check generator output above" 4
fi

log "done: $OUT_HOST"
log "next: review the diff and commit ($OUT_REL/)"
