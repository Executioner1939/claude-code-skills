#!/usr/bin/env python3
"""
inventory.py — build, query, and export the design-system component graph.

Why this exists
---------------
The audit-* workflows used to re-discover the component graph on every run,
inside an LLM agent, costing thousands of tokens per audit. This script
produces the same graph deterministically in seconds and emits it as JSON
matching ../schemas/inventory.schema.json.

Components are graph nodes; `composes` edges are directed (importer -> imported).
Each component carries the static signals an auditor needs (forwardRef,
hardcoded literals, story coverage, mdx presence, aria props, tier
violations) so downstream agents only spend tokens on judgement, not
discovery.

Stdlib only by default. If `networkx` is installed, `query` and `export`
subcommands unlock richer graph operations (transitive consumers,
betweenness centrality, GEXF / GraphViz / Cytoscape output). Without it,
the basic operations still work.

Usage
-----
  inventory.py scan   --root <path> [--tier all|atom|...] [--out path]
  inventory.py query  <inventory.json> <subcommand> [args]
  inventory.py export <inventory.json> --format mermaid|graphviz|cytoscape|gexf [--out path]
  inventory.py stats  <inventory.json>

Run `inventory.py <subcommand> --help` for each subcommand's args.
"""
from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable

# ---------------------------------------------------------------------------
# Data model — mirrors inventory.schema.json
# ---------------------------------------------------------------------------

TIER_ORDER = {"quark": 0, "atom": 1, "molecule": 2, "organism": 3, "template": 4, "page": 5}


@dataclass
class Literal:
    line: int
    kind: str
    value: str


@dataclass
class Stories:
    file: str = ""
    format: str = "none"
    count: int = 0
    names: list[str] = field(default_factory=list)
    hasAllVariants: bool = False
    hasPlay: bool = False
    hasFocus: bool = False
    hasRTL: bool = False
    hasAxeOverrides: bool = False


@dataclass
class Mdx:
    present: bool = False
    path: str = ""
    mode: str = "none"  # per-component | per-category | none


@dataclass
class TokenCompliance:
    score: int = 100
    literalsCount: int = 0


@dataclass
class Component:
    id: str
    tier: str
    path: str
    tierConfidence: str = "high"
    exports: list[str] = field(default_factory=list)
    forwardsRef: bool = False
    ariaProps: list[str] = field(default_factory=list)
    deprecated: bool = False
    lastModified: str = ""
    hardcodedLiterals: list[Literal] = field(default_factory=list)
    stories: Stories = field(default_factory=Stories)
    mdx: Mdx = field(default_factory=Mdx)
    consumers: list[str] = field(default_factory=list)
    composes: list[str] = field(default_factory=list)
    contractRef: str = ""
    contractName: str = ""
    lintViolations: list[dict] = field(default_factory=list)
    tierViolations: list[str] = field(default_factory=list)
    tokenCompliance: TokenCompliance = field(default_factory=TokenCompliance)


@dataclass
class Edge:
    from_: str
    to: str
    kind: str = "composes"


@dataclass
class Reconciliation:
    """Things in the project that don't match atomic-design naming/placement conventions.

    Surfaced alongside the component graph so the audit's reconciliation list is
    prebuilt rather than recomputed by an LLM. Each entry names a concrete file
    or folder and gives a mechanical fix, so the action plan can route them to
    a code-mod or to the user for manual disambiguation.
    """
    kind: str
    path: str
    severity: str  # block | warn | info
    expected: str
    actual: str
    componentId: str = ""
    fix: str = ""
    evidence: list[str] = field(default_factory=list)


# ---------------------------------------------------------------------------
# Scanner — walks the project, builds Component records
# ---------------------------------------------------------------------------

COMPONENT_EXT = {".tsx", ".ts", ".jsx", ".js", ".vue", ".svelte"}
SKIP_PATTERNS = (".stories.", ".test.", ".spec.", ".d.ts")
ARIA_RE = re.compile(r"aria-[a-zA-Z]+")
FORWARD_REF_RE = re.compile(r"\b(React\.)?forwardRef\b")
HEX_RE = re.compile(r"#[0-9A-Fa-f]{3,8}\b")
PX_RE = re.compile(r"(?<![\w.])(\d+(?:\.\d+)?)px\b")
EXPORT_NAME_RE = re.compile(r"export\s+(?:const|function)\s+([A-Z][A-Za-z0-9_]+)")
IMPORT_FROM_RE = re.compile(
    r"""from\s+['"]([^'"]+)['"]"""
)
COMPONENT_NAME_FROM_PATH_RE = re.compile(r"(?:^|/)(atoms|molecules|organisms|templates|pages)/([A-Z][A-Za-z0-9]+)")


def _detect_framework_and_styling(root: Path) -> tuple[str, str]:
    pkg_files = list(root.glob("package.json")) + list(root.glob("packages/*/package.json"))[:1]
    pkg = next((p for p in pkg_files if "node_modules" not in str(p)), None)
    framework = "unknown"
    styling = "unknown"
    if pkg and pkg.exists():
        text = pkg.read_text(errors="ignore")
        if '"react-native"' in text:
            framework = "react-native"
        elif '"react"' in text:
            framework = "react"
        elif '"vue"' in text:
            framework = "vue"
        elif '"svelte"' in text:
            framework = "svelte"
        elif '"@angular' in text:
            framework = "angular"

        if '"nativewind"' in text:
            styling = "nativewind"
        elif '"tailwindcss"' in text:
            styling = "tailwind"
        elif '"styled-components"' in text:
            styling = "styled-components"
        elif '"@emotion' in text:
            styling = "emotion"
    return framework, styling


def _tier_dirs(root: Path, tier: str) -> list[Path]:
    plural = f"{tier}s"
    candidates = [
        root / "src" / "components" / plural,
        root / "src" / "components" / tier,
        root / "components" / plural,
        root / "app" / "components" / plural,
    ]
    candidates += list(root.glob(f"packages/*/src/components/{plural}"))
    return [c for c in candidates if c.is_dir()]


PASCAL_RE = re.compile(r"^[A-Z][A-Za-z0-9]+$")
KNOWN_HELPERS = {"index", "types", "utils", "constants", "styles", "hooks", "context"}


def _is_pascal(name: str) -> bool:
    return bool(PASCAL_RE.match(name))


def _walk_tier_dir(tier_dir: Path, root: Path, tier: str) -> Iterable[tuple[Path | None, list[Reconciliation]]]:
    """Yield (component_file_or_None, reconciliation_entries) for each candidate
    file under the tier directory. A None component_file means the file is
    not a valid component but produces reconciliation entries the audit needs
    to surface.
    """
    for path in tier_dir.rglob("*"):
        if not path.is_file():
            continue
        if path.suffix not in COMPONENT_EXT:
            continue
        if any(p in path.name for p in SKIP_PATTERNS):
            continue

        recon: list[Reconciliation] = []
        rel = str(path.relative_to(root))
        stem = path.stem
        parent = path.parent

        is_at_tier_root = parent == tier_dir
        parent_is_pascal = _is_pascal(parent.name)
        stem_is_pascal = _is_pascal(stem)
        stem_is_helper = stem.lower() in KNOWN_HELPERS

        # Case A: Foo.tsx directly inside atoms/ (no enclosing folder).
        if is_at_tier_root and stem_is_pascal:
            recon.append(Reconciliation(
                kind="unfoldered",
                path=rel,
                severity="warn",
                expected=f"{tier_dir.name}/{stem}/{stem}.tsx",
                actual=rel,
                fix=f"mkdir {tier_dir.name}/{stem} && git mv {rel} {tier_dir.name}/{stem}/",
            ))
            yield path, recon
            continue

        # Case B: file inside a tier-component folder.
        if not is_at_tier_root:
            # Helpers (styles.ts, index.ts, types.ts) are fine and not components.
            if stem_is_helper:
                continue

            # Folder name not PascalCase.
            if not parent_is_pascal:
                recon.append(Reconciliation(
                    kind="misnamed-folder",
                    path=str(parent.relative_to(root)),
                    severity="warn",
                    expected="PascalCase folder name",
                    actual=parent.name,
                    fix=f"git mv {parent} {parent.parent / parent.name.title().replace('-','')}/",
                ))

            # File name not PascalCase.
            if not stem_is_pascal:
                recon.append(Reconciliation(
                    kind="misnamed-file",
                    path=rel,
                    severity="warn",
                    expected=f"{parent.name}.tsx",
                    actual=path.name,
                    fix=f"git mv {rel} {parent}/{parent.name}.tsx",
                ))
                yield None, recon
                continue

            # Folder/file name mismatch (Foo/Bar.tsx).
            if stem != parent.name:
                text = path.read_text(errors="ignore")
                if EXPORT_NAME_RE.search(text):
                    recon.append(Reconciliation(
                        kind="folder-name-mismatch",
                        path=rel,
                        severity="info",
                        expected=f"{parent.name}.tsx (folder is {parent.name})",
                        actual=path.name,
                        fix=f"either rename file to {parent.name}.tsx, or split into its own folder",
                    ))
                yield None, recon
                continue

            yield path, recon
            continue

        # Case C: at tier root, lowercase or kebab-case (button.tsx).
        if is_at_tier_root and not stem_is_pascal:
            recon.append(Reconciliation(
                kind="misnamed-file",
                path=rel,
                severity="warn",
                expected="PascalCase filename inside its own folder",
                actual=path.name,
                fix=f"rename to {stem.title().replace('-','')}.tsx and move into matching folder",
            ))
            yield None, recon
            continue


def _find_strays(root: Path) -> list[Reconciliation]:
    """PascalCase .tsx files outside any known tier folder that look like components."""
    out: list[Reconciliation] = []
    components_root = root / "src" / "components"
    if not components_root.is_dir():
        return out
    known_tiers = {f"{components_root}/{t}" for t in ("atoms", "molecules", "organisms", "templates", "pages", "atom", "molecule", "organism", "template", "page")}
    for path in components_root.rglob("*"):
        if not path.is_file() or path.suffix not in COMPONENT_EXT:
            continue
        if any(p in path.name for p in SKIP_PATTERNS):
            continue
        if not _is_pascal(path.stem):
            continue
        # Skip files that ARE inside a tier folder.
        if any(str(path).startswith(kt + "/") or kt in str(path.parents) for kt in known_tiers):
            continue
        # The file lives in src/components/ but not in atoms/molecules/etc.
        text = path.read_text(errors="ignore")
        if not EXPORT_NAME_RE.search(text) and "export default" not in text:
            continue
        out.append(Reconciliation(
            kind="stray-component",
            path=str(path.relative_to(root)),
            severity="warn",
            expected="placement under src/components/{atoms,molecules,organisms,templates,pages}/<Name>/",
            actual=str(path.relative_to(root)),
            fix=f"classify and move under the correct tier folder",
        ))
    return out


def _enumerate_component_files(tier_dir: Path) -> Iterable[Path]:
    """Legacy helper kept for callers that don't need reconciliation. Prefer _walk_tier_dir."""
    for f, _ in _walk_tier_dir(tier_dir, tier_dir.parent.parent.parent, ""):
        if f is not None:
            yield f


def _git_last_modified(root: Path, rel: str) -> str:
    try:
        out = subprocess.check_output(
            ["git", "-C", str(root), "log", "-1", "--format=%ad", "--date=short", "--", rel],
            stderr=subprocess.DEVNULL,
            text=True,
        ).strip()
        return out or datetime.now(timezone.utc).strftime("%Y-%m-%d")
    except (subprocess.CalledProcessError, FileNotFoundError):
        return datetime.now(timezone.utc).strftime("%Y-%m-%d")


def _detect_stories(component_file: Path) -> Stories | None:
    """Find a sibling .stories.* file and extract structure."""
    stem = component_file.stem
    parent = component_file.parent
    for ext in ("tsx", "ts", "jsx", "js"):
        candidate = parent / f"{stem}.stories.{ext}"
        if candidate.exists():
            text = candidate.read_text(errors="ignore")
            if "preview.meta" in text or "meta.story" in text:
                fmt = "csf-factories"
            elif "Meta<typeof" in text or "satisfies Meta" in text:
                fmt = "csf3"
            elif "storiesOf(" in text:
                fmt = "csf2"
            else:
                fmt = "none"
            names = EXPORT_NAME_RE.findall(text)
            return Stories(
                file=str(candidate),
                format=fmt,
                count=len(names),
                names=names,
                hasAllVariants=any(n == "AllVariants" for n in names),
                hasPlay=("play:" in text and "async" in text) or ".test(" in text,
                hasFocus=any(n == "Focus" for n in names),
                hasRTL=any(n == "RTL" for n in names) or "dir=\"rtl\"" in text,
                hasAxeOverrides="a11y:" in text and "{" in text,
            )
    return Stories()


def _detect_mdx(component_file: Path, root: Path, category_index: dict[str, Path]) -> Mdx:
    """Look for sibling .mdx (per-component) or category index (per-category)."""
    stem = component_file.stem
    parent = component_file.parent
    sibling = parent / f"{stem}.mdx"
    if sibling.exists():
        return Mdx(present=True, path=str(sibling), mode="per-component")
    # Per-category: src/docs/<tier>s/<Category>.mdx — match by tier folder name.
    tier_folder = next((p.name for p in component_file.parents if p.name in {"atoms", "molecules", "organisms", "templates", "pages"}), None)
    if tier_folder and tier_folder in category_index:
        return Mdx(present=True, path=str(category_index[tier_folder]), mode="per-category")
    return Mdx()


def _build_category_index(root: Path) -> dict[str, Path]:
    """Map tier-folder-name -> first .mdx file under src/docs/<that-folder>/."""
    docs = root / "src" / "docs"
    if not docs.is_dir():
        return {}
    index: dict[str, Path] = {}
    for mdx in docs.rglob("*.mdx"):
        for tier in ("atoms", "molecules", "organisms", "templates", "pages"):
            if f"/{tier}/" in str(mdx) or mdx.parent.name == tier:
                index.setdefault(tier, mdx)
                break
    return index


def _scan_component(path: Path, root: Path, tier: str, category_index: dict[str, Path]) -> Component:
    rel = str(path.relative_to(root))
    text = path.read_text(errors="ignore")

    literals: list[Literal] = []
    for lineno, line in enumerate(text.splitlines(), start=1):
        for m in HEX_RE.finditer(line):
            literals.append(Literal(line=lineno, kind="color-hex", value=m.group(0)))
        for m in PX_RE.finditer(line):
            literals.append(Literal(line=lineno, kind="spacing-px", value=m.group(0)))

    aria = sorted(set(ARIA_RE.findall(text)))
    forwards_ref = bool(FORWARD_REF_RE.search(text))
    deprecated = "@deprecated" in text or "/legacy" in rel.lower()
    exports = sorted(set(EXPORT_NAME_RE.findall(text)))

    composes: list[str] = []
    for m in IMPORT_FROM_RE.finditer(text):
        spec = m.group(1)
        cm = COMPONENT_NAME_FROM_PATH_RE.search(spec)
        if cm:
            tier_plural, comp_name = cm.group(1), cm.group(2)
            composes.append(f"{tier_plural}/{comp_name}")
    composes = sorted(set(composes))

    stories = _detect_stories(path) or Stories()
    mdx = _detect_mdx(path, root, category_index)

    name = path.stem
    comp_id = f"{tier}s/{name}"

    score = max(0, 100 - len(literals) * 5)

    return Component(
        id=comp_id,
        tier=tier,
        path=rel,
        exports=exports,
        forwardsRef=forwards_ref,
        ariaProps=aria,
        deprecated=deprecated,
        lastModified=_git_last_modified(root, rel),
        hardcodedLiterals=literals,
        stories=stories,
        mdx=mdx,
        composes=composes,
        tokenCompliance=TokenCompliance(score=score, literalsCount=len(literals)),
    )


def scan(root: Path, tiers: list[str]) -> dict:
    framework, styling = _detect_framework_and_styling(root)
    category_index = _build_category_index(root)

    components: list[Component] = []
    reconciliation: list[Reconciliation] = []

    for tier in tiers:
        for tier_dir in _tier_dirs(root, tier):
            # Walk the tier dir and split files into "valid component" vs
            # "needs reconciliation". Reconciliation entries do NOT become
            # components — they're an explicit cleanup queue.
            for comp_file, recon_entries in _walk_tier_dir(tier_dir, root, tier):
                reconciliation.extend(recon_entries)
                if comp_file is not None:
                    components.append(_scan_component(comp_file, root, tier, category_index))

    # Stray-component pass: PascalCase .tsx files outside any tier folder
    # that look like components (default-export a Function or const Name = ...).
    reconciliation.extend(_find_strays(root))

    # Resolve consumers from composes (reverse-edge index).
    by_id: dict[str, Component] = {c.id: c for c in components}
    for c in components:
        for target in c.composes:
            if target in by_id:
                by_id[target].consumers.append(c.id)
    for c in components:
        c.consumers = sorted(set(c.consumers))

    # Tier violations: importer tier rank must be >= imported tier rank.
    for c in components:
        for target in c.composes:
            target_tier = target.split("/", 1)[0].rstrip("s")
            r_from = TIER_ORDER.get(c.tier, -1)
            r_to = TIER_ORDER.get(target_tier, -1)
            if r_from > 0 and r_to > 0 and r_to > r_from:
                c.tierViolations.append(f"{c.tier}-imports-{target_tier}:{c.id}->{target}")

    # Tier-mismatch-by-signal: an atom that imports molecules is misclassified.
    for c in components:
        if c.tier == "atom" and any(t.startswith("molecules/") or t.startswith("organisms/") for t in c.composes):
            reconciliation.append(Reconciliation(
                kind="tier-mismatch-by-signal",
                path=c.path,
                severity="warn",
                expected="atom imports zero molecules/organisms",
                actual=f"imports {[t for t in c.composes if t.startswith(('molecules/', 'organisms/'))]}",
                componentId=c.id,
                fix=f"reclassify as molecule (move to src/components/molecules/{c.id.split('/')[-1]}/) OR remove the higher-tier imports",
                evidence=c.composes,
            ))

    edges = [
        {"from": c.id, "to": t, "kind": "composes"}
        for c in components for t in c.composes
        if t in by_id
    ]

    return {
        "schemaVersion": 1,
        "scannedAt": datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z"),
        "scope": {
            "root": str(root.resolve()),
            "tiersScanned": tiers,
            "framework": framework,
            "stylingSystem": styling,
        },
        "components": [_serialize(c) for c in components],
        "edges": edges,
        "duplicateClusters": _find_clusters(components),
        "reconciliation": [asdict(r) for r in reconciliation],
    }


def _serialize(c: Component) -> dict:
    d = asdict(c)
    d["hardcodedLiterals"] = [asdict(l) for l in c.hardcodedLiterals]
    d["stories"] = asdict(c.stories)
    d["mdx"] = asdict(c.mdx)
    d["tokenCompliance"] = asdict(c.tokenCompliance)
    return d


def _find_clusters(components: list[Component]) -> list[dict]:
    """Cheap O(n^2) Jaccard on prop / export sets within the same tier."""
    by_tier: dict[str, list[Component]] = {}
    for c in components:
        by_tier.setdefault(c.tier, []).append(c)

    clusters: list[dict] = []
    cluster_id = 0
    for tier, comps in by_tier.items():
        seen: set[str] = set()
        for i, a in enumerate(comps):
            if a.id in seen:
                continue
            members = {a.id}
            a_set = set(a.exports + [p.value for p in a.hardcodedLiterals])
            for b in comps[i + 1:]:
                if b.id in seen:
                    continue
                b_set = set(b.exports + [p.value for p in b.hardcodedLiterals])
                if not a_set or not b_set:
                    continue
                jacc = len(a_set & b_set) / max(1, len(a_set | b_set))
                # Name similarity adds a boost (e.g. Button vs Btn).
                name_a, name_b = a.id.split("/")[-1].lower(), b.id.split("/")[-1].lower()
                name_sim = 1.0 if name_a in name_b or name_b in name_a else 0.0
                score = 0.6 * jacc + 0.4 * name_sim
                if score >= 0.7:
                    members.add(b.id)
                    seen.add(b.id)
            if len(members) > 1:
                cluster_id += 1
                clusters.append({
                    "id": f"c-{cluster_id:03d}",
                    "members": sorted(members),
                    "similarity": round(score, 2),
                    "proposedCanonical": sorted(members)[0],
                })
                seen.update(members)
    return clusters


# ---------------------------------------------------------------------------
# Query — common questions about the inventory
# ---------------------------------------------------------------------------

def _load(path: Path) -> dict:
    return json.loads(path.read_text())


def query_consumers_of(inv: dict, comp_id: str, transitive: bool = False) -> list[str]:
    direct = [e["from"] for e in inv["edges"] if e["to"] == comp_id]
    if not transitive:
        return sorted(direct)
    # BFS upward.
    seen, queue = set(direct), list(direct)
    while queue:
        cur = queue.pop()
        for e in inv["edges"]:
            if e["to"] == cur and e["from"] not in seen:
                seen.add(e["from"])
                queue.append(e["from"])
    return sorted(seen)


def query_composes_of(inv: dict, comp_id: str) -> list[str]:
    return sorted(e["to"] for e in inv["edges"] if e["from"] == comp_id)


def query_orphans(inv: dict, tier: str | None = None) -> list[str]:
    return sorted(
        c["id"] for c in inv["components"]
        if not c.get("consumers")
        and (tier is None or c["tier"] == tier)
    )


def query_contract(inv: dict, name: str) -> list[tuple[str, str, str]]:
    name_low = name.lower()
    out: list[tuple[str, str, str]] = []
    for c in inv["components"]:
        leaf = c["id"].split("/")[-1].lower()
        if leaf == name_low or leaf.endswith(name_low):
            out.append((c["tier"], c["id"], c["path"]))
    return out


def query_hardcoded_sites(inv: dict) -> list[tuple[int, str, str]]:
    out = [
        (len(c.get("hardcodedLiterals", [])), c["id"], c["path"])
        for c in inv["components"]
        if c.get("hardcodedLiterals")
    ]
    return sorted(out, reverse=True)


def query_missing_stories(inv: dict) -> list[tuple[str, str]]:
    return [
        (c["tier"], c["id"])
        for c in inv["components"]
        if (c.get("stories") or {}).get("format", "none") in ("none", "", None)
    ]


def query_level_violations(inv: dict) -> list[str]:
    out: list[str] = []
    for c in inv["components"]:
        out.extend(c.get("tierViolations", []))
    return out


def query_stats(inv: dict) -> dict:
    comps = inv["components"]
    recon = inv.get("reconciliation", [])
    by_kind: dict[str, int] = {}
    for r in recon:
        by_kind[r["kind"]] = by_kind.get(r["kind"], 0) + 1
    return {
        "components": len(comps),
        "edges": len(inv["edges"]),
        "tiers": sorted({c["tier"] for c in comps}),
        "no_stories": sum(1 for c in comps if (c.get("stories") or {}).get("format", "none") in ("none", None)),
        "hardcoded_sites": sum(1 for c in comps if c.get("hardcodedLiterals")),
        "tier_violations": sum(len(c.get("tierViolations", [])) for c in comps),
        "duplicate_clusters": len(inv.get("duplicateClusters", [])),
        "reconciliation_total": len(recon),
        "reconciliation_by_kind": by_kind,
        "framework": inv["scope"].get("framework", "unknown"),
        "styling": inv["scope"].get("stylingSystem", "unknown"),
    }


# ---------------------------------------------------------------------------
# Optional networkx integration — only loaded on demand
# ---------------------------------------------------------------------------

def _to_networkx(inv: dict):
    try:
        import networkx as nx  # type: ignore
    except ImportError:
        sys.exit("inventory.py: networkx required for this op. `pip install networkx`")
    G = nx.DiGraph()
    for c in inv["components"]:
        G.add_node(c["id"], **{k: v for k, v in c.items() if k != "id"})
    for e in inv["edges"]:
        G.add_edge(e["from"], e["to"], kind=e.get("kind", "composes"))
    return G


def query_centrality(inv: dict, top: int = 10) -> list[tuple[str, float]]:
    G = _to_networkx(inv)
    import networkx as nx  # type: ignore
    bc = nx.betweenness_centrality(G)
    return sorted(bc.items(), key=lambda kv: kv[1], reverse=True)[:top]


def query_cycles(inv: dict) -> list[list[str]]:
    G = _to_networkx(inv)
    import networkx as nx  # type: ignore
    return [list(c) for c in nx.simple_cycles(G)]


# ---------------------------------------------------------------------------
# Export — graph formats for visualization / further analysis
# ---------------------------------------------------------------------------

def _safe_id(s: str) -> str:
    return re.sub(r"[^A-Za-z0-9_]", "_", s)


def export_mermaid(inv: dict) -> str:
    lines = ["graph LR"]
    by_tier: dict[str, list[dict]] = {}
    for c in inv["components"]:
        by_tier.setdefault(c["tier"], []).append(c)
    for tier, comps in by_tier.items():
        lines.append(f"  subgraph {tier.upper()}S")
        for c in comps:
            label = c["id"].split("/")[-1]
            lines.append(f'    {_safe_id(c["id"])}["{label}"]')
        lines.append("  end")
    for e in inv["edges"]:
        lines.append(f'  {_safe_id(e["from"])} --> {_safe_id(e["to"])}')
    return "\n".join(lines)


def export_graphviz(inv: dict) -> str:
    lines = ["digraph components {", "  rankdir=LR;", '  node [shape=box, style=rounded];']
    by_tier: dict[str, list[dict]] = {}
    for c in inv["components"]:
        by_tier.setdefault(c["tier"], []).append(c)
    for tier, comps in by_tier.items():
        lines.append(f'  subgraph cluster_{tier} {{ label="{tier}";')
        for c in comps:
            lines.append(f'    "{c["id"]}";')
        lines.append("  }")
    for e in inv["edges"]:
        lines.append(f'  "{e["from"]}" -> "{e["to"]}";')
    lines.append("}")
    return "\n".join(lines)


def export_cytoscape(inv: dict) -> str:
    elements = (
        [{"data": {"id": c["id"], "tier": c["tier"], "path": c["path"]}} for c in inv["components"]] +
        [{"data": {"source": e["from"], "target": e["to"], "kind": e.get("kind", "composes")}} for e in inv["edges"]]
    )
    return json.dumps({"elements": elements}, indent=2)


def export_gexf(inv: dict) -> str:
    G = _to_networkx(inv)
    import networkx as nx  # type: ignore
    import io
    buf = io.BytesIO()
    nx.write_gexf(G, buf)
    return buf.getvalue().decode("utf-8")


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main() -> int:
    parser = argparse.ArgumentParser(description="Design-system component inventory + graph.")
    sub = parser.add_subparsers(dest="cmd", required=True)

    sp = sub.add_parser("scan", help="Walk a project and emit inventory.json.")
    sp.add_argument("--root", required=True, help="Project root (absolute or relative).")
    sp.add_argument("--tier", default="all", choices=["all", "quark", "atom", "molecule", "organism", "template", "page"])
    sp.add_argument("--out", default="-", help="Output path (default stdout).")

    qp = sub.add_parser("query", help="Query an inventory.json.")
    qp.add_argument("inventory", help="Path to inventory.json")
    qp.add_argument("subcommand", choices=[
        "consumers-of", "composes-of", "orphans", "contract",
        "hardcoded-sites", "missing-stories", "level-violations",
        "centrality", "cycles", "stats", "reconciliation",
    ])
    qp.add_argument("args", nargs="*", help="Subcommand args.")
    qp.add_argument("--transitive", action="store_true", help="Use transitive closure where applicable.")
    qp.add_argument("--json", action="store_true", help="Emit JSON instead of plain text.")

    ep = sub.add_parser("export", help="Convert inventory.json to a graph format.")
    ep.add_argument("inventory")
    ep.add_argument("--format", required=True, choices=["mermaid", "graphviz", "cytoscape", "gexf"])
    ep.add_argument("--out", default="-")

    sub.add_parser("stats", help="Quick summary.").add_argument("inventory")

    args = parser.parse_args()

    if args.cmd == "scan":
        root = Path(args.root).resolve()
        tiers = ["quark", "atom", "molecule", "organism", "template", "page"] if args.tier == "all" else [args.tier]
        inv = scan(root, tiers)
        text = json.dumps(inv, indent=2)
        if args.out == "-":
            print(text)
        else:
            out = Path(args.out)
            out.parent.mkdir(parents=True, exist_ok=True)
            out.write_text(text)
        return 0

    if args.cmd == "query":
        inv = _load(Path(args.inventory))
        sc = args.subcommand
        result: Any
        if sc == "consumers-of":
            result = query_consumers_of(inv, args.args[0], transitive=args.transitive)
        elif sc == "composes-of":
            result = query_composes_of(inv, args.args[0])
        elif sc == "orphans":
            result = query_orphans(inv, args.args[0] if args.args else None)
        elif sc == "contract":
            result = [{"tier": t, "id": i, "path": p} for t, i, p in query_contract(inv, args.args[0])]
        elif sc == "hardcoded-sites":
            result = [{"count": n, "id": i, "path": p} for n, i, p in query_hardcoded_sites(inv)]
        elif sc == "missing-stories":
            result = [{"tier": t, "id": i} for t, i in query_missing_stories(inv)]
        elif sc == "level-violations":
            result = query_level_violations(inv)
        elif sc == "centrality":
            result = [{"id": i, "score": round(s, 4)} for i, s in query_centrality(inv)]
        elif sc == "cycles":
            result = query_cycles(inv)
        elif sc == "stats":
            result = query_stats(inv)
        elif sc == "reconciliation":
            entries = inv.get("reconciliation", [])
            if args.args:
                entries = [e for e in entries if e.get("kind") == args.args[0]]
            result = entries
        else:
            parser.error(f"unknown subcommand {sc}")
        if args.json or isinstance(result, dict):
            print(json.dumps(result, indent=2))
        else:
            for item in (result if isinstance(result, list) else [result]):
                print(item if isinstance(item, str) else json.dumps(item))
        return 0

    if args.cmd == "export":
        inv = _load(Path(args.inventory))
        emit = {
            "mermaid": export_mermaid,
            "graphviz": export_graphviz,
            "cytoscape": export_cytoscape,
            "gexf": export_gexf,
        }[args.format]
        text = emit(inv)
        if args.out == "-":
            print(text)
        else:
            Path(args.out).parent.mkdir(parents=True, exist_ok=True)
            Path(args.out).write_text(text)
        return 0

    if args.cmd == "stats":
        inv = _load(Path(args.inventory))
        print(json.dumps(query_stats(inv), indent=2))
        return 0

    parser.error("no subcommand")
    return 2


if __name__ == "__main__":
    sys.exit(main())
