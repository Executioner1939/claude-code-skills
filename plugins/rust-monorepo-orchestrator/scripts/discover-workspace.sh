#!/usr/bin/env bash
# discover-workspace.sh -- self-discovers the workspace, services, and
# aggregates surrounding the caller's cwd. Drives the context-aware /init,
# /audit, /plan, /run, /migrate commands.
#
# Usage:
#   discover-workspace.sh [<from-path>]
#
# Emits a single JSON object to stdout:
#   {
#     "workspace_root": "<abs path>",
#     "from": "<abs path>",
#     "current": {
#       "kind": "workspace_root|service|aggregate|outside",
#       "service": "<name or null>",
#       "service_path": "<abs path or null>",
#       "aggregate": "<name or null>"
#     },
#     "services": [
#       { "name": "<svc>", "path": "<abs path>", "aggregates": ["a","b"], "manifest": "<path>" }
#     ],
#     "refactor_initialized": true|false,
#     "stack_json_exists": true|false,
#     "standard_md_exists": true|false
#   }
#
# Heuristics:
#   - workspace_root = nearest ancestor of <from> containing one of:
#       Cargo.toml with [workspace], pnpm-workspace.yaml, turbo.json,
#       lerna.json, moon.yml, nx.json, .moon/, MODULE.bazel, WORKSPACE,
#       or a `.refactor/` directory.
#   - services = subdirs of `services/`, `apps/`, `crates/`, `packages/`,
#     or `modules/` at the workspace root (auto-detected). If the workspace
#     has only one such directory and it contains crates, use it; if multiple,
#     union them.
#   - aggregates per service = decider files: `<name>_decider.rs` under
#     `src/domain/`. Falls back to `<name>_aggregate.rs` and `<name>_api.rs`.
#     De-duplicated, names lowercased.
#   - current.kind:
#       outside       = <from> is not under workspace_root (or no ws found)
#       workspace_root= <from> == workspace_root
#       service       = <from> is at services/<svc>/ or matches a known service path
#       aggregate     = <from> is inside services/<svc>/src/domain/ and a specific aggregate is determinable

set -euo pipefail

FROM="${1:-$(pwd)}"
FROM=$(cd "$FROM" 2>/dev/null && pwd) || { echo "ERROR: cannot enter $FROM" >&2; exit 1; }

# Walk up to find the workspace root.
#
# Two-pass strategy:
#   Pass 1 (strong markers) -- prefer the OUTERMOST directory containing a
#     real workspace declaration: Cargo [workspace], moon.yml, pnpm-workspace.yaml,
#     turbo.json, lerna.json, nx.json, MODULE.bazel, WORKSPACE. This avoids
#     mistaking an inner service's .refactor/ for the workspace.
#   Pass 2 (weak fallback) -- if no strong marker was found upstream, accept
#     the nearest .refactor/ directory. A bare-service repo with no monorepo
#     wrapper still works (the service IS its own workspace).
find_workspace() {
  local start="$1"
  local d="$start"
  # Walk up; stop at the home dir boundary so `.moon` / `pnpm-workspace.yaml`
  # in $HOME (which exist for unrelated reasons) don't get matched.
  local home_dir="${HOME:-/Users/$(whoami 2>/dev/null || echo nobody)}"
  while [ "$d" != "/" ]; do
    # Stop walking once we'd step OUT of the user's home (or stay in /tmp etc).
    case "$d" in
      "$home_dir") break ;;
      "$home_dir"/*) ;;
      /tmp|/tmp/*|/var|/var/*) ;;
      /Users|/home) break ;;
    esac
    # Strong workspace markers.
    if [ -f "$d/moon.yml" ] \
       || [ -d "$d/.moon" ] \
       || [ -f "$d/pnpm-workspace.yaml" ] \
       || [ -f "$d/turbo.json" ] \
       || [ -f "$d/lerna.json" ] \
       || [ -f "$d/nx.json" ] \
       || [ -f "$d/MODULE.bazel" ] \
       || [ -f "$d/WORKSPACE" ]; then
      echo "$d"
      return 0
    fi
    if [ -f "$d/Cargo.toml" ] && grep -q '^\[workspace\]' "$d/Cargo.toml" 2>/dev/null; then
      echo "$d"
      return 0
    fi
    d=$(dirname "$d")
  done
  # Fallback: nearest .refactor/ directory (for bare-service repos that
  # initialized the orchestrator without a workspace marker).
  d="$start"
  while [ "$d" != "/" ]; do
    case "$d" in
      "$home_dir"|/Users|/home) break ;;
    esac
    if [ -d "$d/.refactor" ]; then
      echo "$d"
      return 0
    fi
    d=$(dirname "$d")
  done
  return 1
}

WORKSPACE=$(find_workspace "$FROM" || true)

if [ -z "$WORKSPACE" ]; then
  # No workspace found. Treat <from> as a standalone service if it has Cargo.toml/package.json.
  if [ -f "$FROM/Cargo.toml" ] || [ -f "$FROM/package.json" ] || [ -f "$FROM/pyproject.toml" ]; then
    WORKSPACE="$FROM"
  else
    # Last resort: parent of <from>.
    WORKSPACE=$(dirname "$FROM")
  fi
fi

python3 - "$WORKSPACE" "$FROM" <<'PY'
import json, os, re, sys
from pathlib import Path

workspace = Path(sys.argv[1])
from_path = Path(sys.argv[2])

# ---------- find services ----------
candidate_dirs = ["services", "apps", "crates", "packages", "modules"]
services = []
seen_paths = set()

# 1) Cargo [workspace] members.
cargo = workspace / "Cargo.toml"
if cargo.exists():
    try:
        text = cargo.read_text()
        m = re.search(r"\[workspace\][\s\S]*?members\s*=\s*\[([\s\S]*?)\]", text)
        if m:
            for entry in re.findall(r'"([^"]+)"', m.group(1)):
                # Skip glob entries.
                if "*" in entry:
                    # Expand glob
                    for p in workspace.glob(entry):
                        if p.is_dir() and (p / "Cargo.toml").exists():
                            services.append((p.name, p))
                            seen_paths.add(p.resolve())
                else:
                    p = (workspace / entry).resolve()
                    if p.is_dir() and (p / "Cargo.toml").exists():
                        services.append((p.name, p))
                        seen_paths.add(p)
    except Exception:
        pass

# 2) Convention directories.
for d in candidate_dirs:
    base = workspace / d
    if not base.is_dir():
        continue
    for child in sorted(base.iterdir()):
        if not child.is_dir():
            continue
        if child.resolve() in seen_paths:
            continue
        # Heuristic: must look like a service (manifest or src/).
        if (child / "Cargo.toml").exists() or (child / "package.json").exists() or (child / "src").is_dir():
            services.append((child.name, child))
            seen_paths.add(child.resolve())

# ---------- detect aggregates per service ----------
def detect_aggregates(service_path: Path):
    aggregates = set()
    domain_dir = service_path / "src" / "domain"
    if not domain_dir.is_dir():
        domain_dir = service_path / "domain"  # alternative layout
    if not domain_dir.is_dir():
        return []
    # Prefer *_decider.rs
    for f in domain_dir.glob("*_decider.rs"):
        name = f.stem.removesuffix("_decider")
        if name and name != "mod":
            aggregates.add(name.lower())
    # Fallback: *_aggregate.rs
    if not aggregates:
        for f in domain_dir.glob("*_aggregate.rs"):
            name = f.stem.removesuffix("_aggregate")
            if name and name != "mod":
                aggregates.add(name.lower())
    # Fallback: *_api.rs (matches the target's pattern)
    if not aggregates:
        for f in domain_dir.glob("*_api.rs"):
            name = f.stem.removesuffix("_api")
            if name in ("mod", "shared"):
                continue
            if name:
                aggregates.add(name.lower())
    # Last fallback: subdirectories of domain/ (each one is an aggregate)
    if not aggregates:
        for sub in domain_dir.iterdir():
            if sub.is_dir() and (sub / "mod.rs").exists() or (sub / "decider.rs").exists():
                if sub.name not in ("mod",):
                    aggregates.add(sub.name.lower())
    return sorted(aggregates)

# ---------- determine current context ----------
def classify_current(from_p: Path):
    if from_p.resolve() == workspace.resolve():
        return ("workspace_root", None, None, None)
    for (name, sp) in services:
        try:
            rel = from_p.resolve().relative_to(sp.resolve())
        except ValueError:
            continue
        if str(rel) == ".":
            return ("service", name, str(sp.resolve()), None)
        # Inside a service; check if inside src/domain/ to identify aggregate
        parts = rel.parts
        if len(parts) >= 2 and parts[0] == "src" and parts[1] == "domain":
            if len(parts) >= 3:
                # Could be an aggregate file or dir
                target = parts[2]
                target_stem = re.sub(r"\.(rs|md)$", "", target)
                target_name = re.sub(r"_(decider|view|api|aggregate)$", "", target_stem).lower()
                aggs = detect_aggregates(sp)
                if target_name in aggs:
                    return ("aggregate", name, str(sp.resolve()), target_name)
        return ("service", name, str(sp.resolve()), None)
    return ("outside", None, None, None)

current_kind, current_service, current_service_path, current_aggregate = classify_current(from_path)

# ---------- build JSON ----------
services_out = []
for (name, sp) in services:
    services_out.append({
        "name": name,
        "path": str(sp.resolve()),
        "aggregates": detect_aggregates(sp),
        "manifest": (
            "Cargo.toml" if (sp / "Cargo.toml").exists()
            else "package.json" if (sp / "package.json").exists()
            else "pyproject.toml" if (sp / "pyproject.toml").exists()
            else None
        ),
    })

refactor_dir = workspace / ".refactor"
stack_json = refactor_dir / "stack.json"
standard_md = refactor_dir / "standard.md"

result = {
    "workspace_root": str(workspace.resolve()),
    "from": str(from_path.resolve()),
    "current": {
        "kind": current_kind,
        "service": current_service,
        "service_path": current_service_path,
        "aggregate": current_aggregate,
    },
    "services": services_out,
    "refactor_initialized": refactor_dir.is_dir(),
    "stack_json_exists": stack_json.exists(),
    "standard_md_exists": standard_md.exists(),
}
print(json.dumps(result, indent=2))
PY
