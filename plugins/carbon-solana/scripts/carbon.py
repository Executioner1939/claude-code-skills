#!/usr/bin/env python3
"""carbon.py — query Carbon Solana decoder crates from the local cargo cache.

Locates `carbon-<slug>-decoder` source under `~/.cargo/registry/src/...` (or
under `$CARBON_SRC` if set) and uses ast-grep + plain text parsing to extract
discriminators, struct fields, and ArrangeAccounts variants for a single
instruction / account / event / type.

Examples:
    carbon.py list raydium-amm-v4
    carbon.py ix raydium-amm-v4 SwapBaseIn
    carbon.py account pumpfun BondingCurve
    carbon.py event pumpfun TradeEventEvent
    carbon.py type raydium-cpmm SwapEvent
    carbon.py path drift-v2
    carbon.py search '\\bArrangeAccounts\\b' --in raydium-amm-v4

Dependencies:
    python3 (>= 3.8)
    ast-grep   (cargo install ast-grep, or `brew install ast-grep`)
    cargo      (so the carbon-<slug>-decoder source ends up in ~/.cargo/registry/src/)
"""

from __future__ import annotations

import argparse
import glob
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Iterable


# ---------------------------------------------------------------------------
# environment / dependency checks
# ---------------------------------------------------------------------------

def die(msg: str, code: int = 2) -> None:
    print(msg, file=sys.stderr)
    sys.exit(code)


def require(tool: str, install_hint: str) -> None:
    if shutil.which(tool) is None:
        die(
            f"missing dependency: {tool}\n"
            f"install with: {install_hint}",
            code=2,
        )


def _version_key(p: str) -> tuple:
    nums = re.findall(r"\d+", Path(p).name)
    return tuple(int(n) for n in nums)


def locate_crate(slug: str) -> Path:
    """Return the source dir for `carbon-<slug>-decoder`.

    Resolution order:
      1. $CARBON_SRC/decoders/<slug>-decoder            (when working in a clone of carbon)
      2. $CARBON_SRC/<slug>-decoder
      3. ~/.cargo/registry/src/*/carbon-<slug>-decoder-*  (highest version)
    """
    crate = f"carbon-{slug}-decoder"
    candidates: list[Path] = []

    env = os.environ.get("CARBON_SRC")
    if env:
        for sub in (
            Path(env) / "decoders" / f"{slug}-decoder",
            Path(env) / f"{slug}-decoder",
            Path(env) / crate,
        ):
            if (sub / "src").is_dir():
                return sub

    home = Path.home()
    pattern = str(home / ".cargo/registry/src/*" / f"{crate}-*")
    candidates += [Path(p) for p in glob.glob(pattern) if (Path(p) / "src").is_dir()]

    if not candidates:
        die(
            f"crate '{crate}' not found.\n"
            f"checked:\n"
            f"  ~/.cargo/registry/src/*/{crate}-*/\n"
            f"  $CARBON_SRC (={env or 'unset'})\n\n"
            f"hint: in a project that depends on '{crate}', run\n"
            f"      cargo fetch  (or cargo build)\n"
            f"      to populate the registry cache. or set CARBON_SRC to a\n"
            f"      local clone of github.com/sevenlabs-hq/carbon.",
            code=3,
        )

    candidates.sort(key=lambda p: _version_key(str(p)))
    return candidates[-1]


# ---------------------------------------------------------------------------
# ast-grep helpers
# ---------------------------------------------------------------------------

def sg_run(pattern: str, file_path: Path) -> list[str]:
    """Run `ast-grep run --pattern ... --json=stream` and return matched texts."""
    require("ast-grep", "cargo install ast-grep   (or: brew install ast-grep)")
    cmd = [
        "ast-grep", "run",
        "--lang", "rust",
        "--pattern", pattern,
        "--json=stream",
        str(file_path),
    ]
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, check=False)
    except FileNotFoundError:
        die("ast-grep not on PATH after install — open a new shell and retry.", code=2)
    out: list[str] = []
    for line in proc.stdout.splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            obj = json.loads(line)
        except json.JSONDecodeError:
            continue
        text = obj.get("text") or obj.get("matched") or ""
        if text:
            out.append(text)
    return out


# ---------------------------------------------------------------------------
# extraction
# ---------------------------------------------------------------------------

DOC_RE = re.compile(r"^\s*///\s?(.*)$")
DISC_ATTR_RE = re.compile(r'#\[carbon\(discriminator\s*=\s*"([^"]+)"\)\]')
DISC_CONST_RE = re.compile(
    r"const\s+DISCRIMINATOR\s*:\s*&?\[u8(?:;\s*\d+)?\]\s*=\s*"
    r"(\[[^\]]+\]|&\[[^\]]+\])",
    re.S,
)
DISC_ANCHOR_RE = re.compile(
    r"if\s+discriminator\s*!=\s*(\[[\d,\s]+\])", re.S,
)


def extract_discriminator(src: str) -> str | None:
    m = DISC_ATTR_RE.search(src)
    if m:
        return m.group(1)
    m = DISC_ANCHOR_RE.search(src)
    if m:
        return re.sub(r"\s+", " ", m.group(1)).strip()
    m = DISC_CONST_RE.search(src)
    if m:
        return re.sub(r"\s+", " ", m.group(1)).strip()
    return None


def extract_doc(src: str, struct_name: str) -> str | None:
    """Pull contiguous /// doc comments directly above `pub struct <name>`."""
    pat = re.compile(
        rf"((?:^[ \t]*///[^\n]*\n)+)[ \t]*(?:#\[[^\]]+\]\s*\n)*\s*pub\s+struct\s+{re.escape(struct_name)}\b",
        re.M,
    )
    m = pat.search(src)
    if not m:
        return None
    lines = []
    for line in m.group(1).splitlines():
        mm = DOC_RE.match(line)
        if mm:
            lines.append(mm.group(1).strip())
    if lines and lines[0].startswith("This code was AUTOGENERATED"):
        return None
    return " ".join(lines).strip() or None


def find_struct_block(src: str, name: str) -> str | None:
    """Return the full `pub struct <name> { ... }` block or `pub struct <name>(...);`."""
    # tuple-struct or unit struct
    m = re.search(
        rf"pub\s+struct\s+{re.escape(name)}\b\s*(\([^;]*\)\s*;|;)",
        src, re.S,
    )
    if m:
        return m.group(0)
    # block struct — find opening brace, then balance braces
    m = re.search(rf"pub\s+struct\s+{re.escape(name)}\b", src)
    if not m:
        return None
    start = src.find("{", m.end())
    if start < 0:
        return None
    depth = 0
    for i, ch in enumerate(src[start:], start):
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                return src[m.start():i + 1]
    return None


def find_arrange_block(src: str, struct_name: str) -> str | None:
    """Return the `impl ArrangeAccounts for <struct_name> { ... }` block."""
    m = re.search(
        rf"impl\s+(?:carbon_core::deserialize::)?ArrangeAccounts\s+for\s+{re.escape(struct_name)}\b",
        src,
    )
    if not m:
        return None
    start = src.find("{", m.end())
    if start < 0:
        return None
    depth = 0
    for i, ch in enumerate(src[start:], start):
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                return src[m.start():i + 1]
    return None


def slim_field_list(block: str) -> list[str]:
    """Extract `field: Type` lines from a struct block."""
    out: list[str] = []
    body = block[block.find("{") + 1: block.rfind("}")]
    # strip line comments and macro attributes inside fields
    body = re.sub(r"//[^\n]*", "", body)
    body = re.sub(r"#\[[^\]]*\]", "", body)
    for raw in re.split(r",\s*\n", body):
        line = raw.strip().rstrip(",").strip()
        if not line:
            continue
        m = re.match(r"pub\s+([a-zA-Z_]\w*)\s*:\s*(.+)$", line, re.S)
        if not m:
            continue
        ty = m.group(2).strip()
        ty = ty.replace("solana_pubkey::", "").replace("solana_instruction::", "")
        out.append(f"{m.group(1)}: {ty}")
    return out


# ---------------------------------------------------------------------------
# commands
# ---------------------------------------------------------------------------

def list_dir(root: Path, sub: str) -> list[str]:
    d = root / "src" / sub
    if not d.is_dir():
        return []
    return sorted(p.stem for p in d.glob("*.rs") if p.name != "mod.rs")


def cmd_list(slug: str) -> int:
    root = locate_crate(slug)
    print(f"# crate: {root.name}")
    print(f"# path:  {root}")
    program_id = ""
    lib = root / "src" / "lib.rs"
    if lib.exists():
        m = re.search(r'Pubkey::from_str_const\("([^"]+)"\)', lib.read_text())
        if m:
            program_id = m.group(1)
    if program_id:
        print(f"# program_id: {program_id}")

    for kind in ("instructions", "accounts", "events", "types"):
        names = list_dir(root, kind)
        if not names:
            continue
        print()
        print(f"## {kind}")
        for n in names:
            print(f"  - {n}")
    return 0


def cmd_path(slug: str) -> int:
    root = locate_crate(slug)
    print(root)
    return 0


def _resolve_file(root: Path, sub: str, name: str) -> Path:
    """Try to find a source file by exact stem, then by snake_case of `name`."""
    d = root / "src" / sub
    if not d.is_dir():
        die(f"no {sub}/ directory in {root}", code=4)
    candidates: list[Path] = []
    direct = d / f"{name}.rs"
    if direct.exists():
        candidates.append(direct)
    snake = re.sub(r"(?<!^)(?=[A-Z])", "_", name).lower()
    snake_path = d / f"{snake}.rs"
    if snake_path.exists() and snake_path != direct:
        candidates.append(snake_path)
    if not candidates:
        # fallback: case-insensitive stem match
        for p in d.glob("*.rs"):
            if p.stem.lower() == name.lower():
                candidates.append(p)
                break
    if not candidates:
        # fallback: substring
        hits = [p for p in d.glob("*.rs") if name.lower() in p.stem.lower()]
        if len(hits) == 1:
            candidates = hits
        elif hits:
            opts = ", ".join(p.stem for p in hits)
            die(f"ambiguous '{name}' in {sub}/. candidates: {opts}", code=4)
    if not candidates:
        die(f"no {sub} file matching '{name}' in {d}", code=4)
    return candidates[0]


def _print_file_summary(file_path: Path, primary_struct: str | None = None) -> None:
    src = file_path.read_text()
    rel = file_path
    print(f"# file: {rel}")
    print()

    disc = extract_discriminator(src)
    if disc:
        print(f"## discriminator")
        print(f"`{disc}`")
        print()

    # locate primary struct
    structs = re.findall(r"pub\s+struct\s+([A-Z]\w*)", src)
    if not structs:
        return

    primary = primary_struct if primary_struct in structs else structs[0]
    accounts_struct = next((s for s in structs if s.endswith("InstructionAccounts")), None)

    doc = extract_doc(src, primary)
    if doc:
        print(f"## doc")
        print(doc)
        print()

    blk = find_struct_block(src, primary)
    if blk:
        fields = slim_field_list(blk)
        print(f"## struct {primary}")
        if fields:
            for f in fields:
                print(f"- {f}")
        else:
            # tuple/unit struct or no `pub` fields
            print(blk.strip())
        print()

    if accounts_struct and accounts_struct != primary:
        blk2 = find_struct_block(src, accounts_struct)
        if blk2:
            fields = slim_field_list(blk2)
            print(f"## struct {accounts_struct}")
            for f in fields:
                print(f"- {f}")
            print()

    arrange = find_arrange_block(src, primary)
    if arrange:
        # match accounts.len() arms?
        arms = re.findall(r"(\d+)\s*=>\s*\{", arrange)
        if arms:
            print(f"## ArrangeAccounts variants")
            print("Account-count arms: " + ", ".join(sorted(set(arms), key=int)))
            print()
        # next_account chain?
        seq = re.findall(r"let\s+([a-z_][\w]*)\s*=\s*next_account\(", arrange)
        if seq:
            print(f"## ArrangeAccounts (sequential)")
            for n in seq:
                print(f"- {n}")
            print()

    # other structs in the file (e.g. inner type aliases) — just list them
    others = [s for s in structs if s not in (primary, accounts_struct)]
    if others:
        print(f"## other structs in file")
        for o in others:
            print(f"- {o}")
        print()


def cmd_ix(slug: str, name: str) -> int:
    root = locate_crate(slug)
    f = _resolve_file(root, "instructions", name)
    _print_file_summary(f, primary_struct=name)
    return 0


def cmd_account(slug: str, name: str) -> int:
    root = locate_crate(slug)
    f = _resolve_file(root, "accounts", name)
    _print_file_summary(f, primary_struct=name)
    return 0


def cmd_event(slug: str, name: str) -> int:
    """Events live in events/ on Codama-generated crates, sometimes in
    types/<name>_event.rs, and occasionally inline in instructions/."""
    root = locate_crate(slug)
    snake = re.sub(r"(?<!^)(?=[A-Z])", "_", name).lower()
    # Pumpfun-style names like "TradeEventEvent" map to file "trade_event.rs"
    # — strip a trailing "_event" duplication.
    snake_stripped = re.sub(r"_event_event$", "_event", snake)
    base = re.sub(r"_event$", "", snake)
    name_stripped = re.sub(r"Event$", "", name)
    candidates_stems = [
        name, snake, snake_stripped, snake + "_event", base, base + "_event",
        name_stripped,
        re.sub(r"(?<!^)(?=[A-Z])", "_", name_stripped).lower(),
        re.sub(r"(?<!^)(?=[A-Z])", "_", name_stripped).lower() + "_event",
    ]
    seen: set[str] = set()
    stems = [s for s in candidates_stems if not (s in seen or seen.add(s))]

    for sub in ("events", "types", "instructions"):
        d = root / "src" / sub
        if not d.is_dir():
            continue
        for stem in stems:
            p = d / f"{stem}.rs"
            if p.exists():
                _print_file_summary(p, primary_struct=name)
                return 0
        for p in d.glob("*.rs"):
            if p.stem.lower() in {s.lower() for s in stems}:
                _print_file_summary(p, primary_struct=name)
                return 0
    die(f"no event file matching '{name}' in events/, types/, or instructions/", code=4)
    return 4


def cmd_type(slug: str, name: str) -> int:
    root = locate_crate(slug)
    f = _resolve_file(root, "types", name)
    _print_file_summary(f, primary_struct=name)
    return 0


def cmd_search(pattern: str, inside: str | None) -> int:
    if inside:
        roots: Iterable[Path] = [locate_crate(inside)]
    else:
        home = Path.home()
        roots = sorted(
            {Path(p) for p in glob.glob(str(home / ".cargo/registry/src/*/carbon-*-decoder-*"))
             if (Path(p) / "src").is_dir()},
            key=lambda p: p.name,
        )
        if not roots:
            die("no carbon-*-decoder crates found in cargo cache", code=3)
    rx = re.compile(pattern)
    for root in roots:
        for f in (root / "src").rglob("*.rs"):
            try:
                for i, line in enumerate(f.read_text().splitlines(), 1):
                    if rx.search(line):
                        rel = f.relative_to(root)
                        print(f"{root.name}:{rel}:{i}:{line.strip()}")
            except OSError:
                continue
    return 0


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main(argv: list[str]) -> int:
    p = argparse.ArgumentParser(
        prog="carbon.py",
        description="Query Carbon Solana decoder crates from your cargo cache.",
    )
    sub = p.add_subparsers(dest="cmd", required=True)

    s = sub.add_parser("list", help="list instructions/accounts/events/types in a decoder")
    s.add_argument("slug")

    s = sub.add_parser("path", help="print the resolved cargo-cache path for a decoder")
    s.add_argument("slug")

    for cmd in ("ix", "account", "event", "type"):
        s = sub.add_parser(cmd, help=f"show one {cmd}'s details")
        s.add_argument("slug")
        s.add_argument("name")

    s = sub.add_parser("search", help="regex search over decoder source")
    s.add_argument("pattern")
    s.add_argument("--in", dest="inside", default=None,
                   help="restrict to one decoder slug (otherwise: all)")

    args = p.parse_args(argv)
    if args.cmd == "list":
        return cmd_list(args.slug)
    if args.cmd == "path":
        return cmd_path(args.slug)
    if args.cmd == "ix":
        return cmd_ix(args.slug, args.name)
    if args.cmd == "account":
        return cmd_account(args.slug, args.name)
    if args.cmd == "event":
        return cmd_event(args.slug, args.name)
    if args.cmd == "type":
        return cmd_type(args.slug, args.name)
    if args.cmd == "search":
        return cmd_search(args.pattern, args.inside)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
