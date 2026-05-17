#!/usr/bin/env bash
# audit-name-drift.sh -- four-name-tuple invariant for the canonical
# Rust-service-deploys-via-image-push topology (workflows.md §3).
#
# Checks that each service has identical names across:
#   (1) `id:` in moon.yml (or directory name if absent)
#   (2) `[package].name` in Cargo.toml
#   (3) DOCKER_IMAGE env on the docker-push task (last path segment)
#   (4) deploy manifest image reference (argocd/applications/<svc>/application.yaml)
#
# Exit codes:
#   0 -- all four names agree across every service
#   1 -- at least one drift detected
#   2 -- usage / missing tool
#
# Usage: audit-name-drift.sh [<services-dir>] [<argocd-applications-dir>]
#        Defaults: services_dir=services, argocd_dir=argocd/applications
#
# Notes:
# - Substitution rules: this script treats `_` and `-` as equivalent in
#   names because canonical convention is dashes throughout and Rust
#   crates sometimes have underscores. To enforce literal equality,
#   remove the `tr '_' '-'` calls below.

set -euo pipefail

SERVICES_DIR="${1:-services}"
ARGOCD_DIR="${2:-argocd/applications}"

if [ ! -d "$SERVICES_DIR" ]; then
  echo "audit-name-drift.sh: no $SERVICES_DIR directory" >&2
  exit 2
fi

FAIL=0
declare -a REPORT=()

for svc_path in "$SERVICES_DIR"/*/; do
  svc=$(basename "$svc_path")
  moon_id=""
  cargo_name=""
  docker_last=""
  deploy_last=""

  # (1) moon id (from moon.yml or directory name)
  if [ -f "$svc_path/moon.yml" ]; then
    moon_id=$(grep -E '^id:' "$svc_path/moon.yml" | head -1 | sed -E 's/^id:[[:space:]]*//; s/^["'"'"']//; s/["'"'"']$//')
  fi
  [ -z "$moon_id" ] && moon_id="$svc"

  # (2) cargo package name
  if [ -f "$svc_path/Cargo.toml" ]; then
    cargo_name=$(awk '
      /^\[package\]/ { in_pkg=1; next }
      /^\[/ && !/^\[package\]/ { in_pkg=0 }
      in_pkg && /^name[[:space:]]*=/ {
        sub(/^name[[:space:]]*=[[:space:]]*"/, "")
        sub(/".*$/, "")
        print
        exit
      }' "$svc_path/Cargo.toml")
  fi

  # (3) docker last segment (from DOCKER_IMAGE env on docker-push task)
  if [ -f "$svc_path/moon.yml" ]; then
    docker_img=$(grep -E '^[[:space:]]*DOCKER_IMAGE[[:space:]]*:' "$svc_path/moon.yml" | head -1 \
      | sed -E "s/^[[:space:]]*DOCKER_IMAGE[[:space:]]*:[[:space:]]*//; s/^[\"']//; s/[\"']$//")
    # last path segment after final / and minus trailing variables
    docker_last=$(echo "$docker_img" | awk -F/ '{print $NF}' | sed -E 's/\$[A-Za-z_]+//; s/\$\{[^}]+\}//g')
  fi

  # (4) deploy manifest image reference
  manifest="$ARGOCD_DIR/$svc/application.yaml"
  if [ -f "$manifest" ] && command -v yq >/dev/null 2>&1; then
    deploy_img=$(yq '.spec.source.kustomize.images[0] // .spec.source.helm.parameters[] | select(.name | test("image|repository")) | .value' "$manifest" 2>/dev/null | head -1 || true)
    [ -z "$deploy_img" ] && deploy_img=$(yq '.. | select(has("image")?) | .image' "$manifest" 2>/dev/null | head -1 || true)
    deploy_last=$(echo "$deploy_img" | awk -F: '{print $1}' | awk -F/ '{print $NF}')
  fi

  # normalize underscores to dashes for comparison
  m=$(echo "$moon_id" | tr '_' '-')
  c=$(echo "$cargo_name" | tr '_' '-')
  d=$(echo "$docker_last" | tr '_' '-' | sed -E 's/^acme-//')
  p=$(echo "$deploy_last" | tr '_' '-' | sed -E 's/^acme-//')

  drift=()
  [ -n "$c" ] && [ "$m" != "$c" ] && drift+=("moon-id='$moon_id' vs cargo-name='$cargo_name'")
  [ -n "$d" ] && [ "$c" != "$d" ] && [ -n "$c" ] && drift+=("cargo-name='$cargo_name' vs docker='$docker_last'")
  [ -n "$p" ] && [ -n "$d" ] && [ "$d" != "$p" ] && drift+=("docker='$docker_last' vs deploy='$deploy_last'")

  if [ ${#drift[@]} -gt 0 ]; then
    REPORT+=("$svc:")
    for d_msg in "${drift[@]}"; do
      REPORT+=("    - $d_msg")
    done
    FAIL=1
  fi
done

if [ "$FAIL" -eq 0 ]; then
  echo "audit-name-drift.sh: all four names agree across every service in $SERVICES_DIR"
  exit 0
fi

echo "audit-name-drift.sh: name drift detected" >&2
echo >&2
for line in "${REPORT[@]}"; do
  echo "  $line" >&2
done
echo >&2
echo "See references/workflows.md §3 for the canonical materialisation rule." >&2
exit 1
