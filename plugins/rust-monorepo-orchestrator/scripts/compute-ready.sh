#!/usr/bin/env bash
# compute-ready.sh -- pick ready tickets respecting deps and path-locks.
#
# Usage: compute-ready.sh <inbox-domain-dir> <wave-width>
#
# A ticket is "deps-ready" iff every id in its frontmatter `depends_on` list
# has a matching file in <inbox>/done/. A ticket is "lock-free" iff its
# `allowed_paths` glob set does not overlap with any already-picked ticket
# in the same iteration.
#
# Greedy: sort pending tickets by id, walk them in order, pick if deps-ready
# AND lock-free, stop at wave-width. Emits ticket IDs newline-separated.
#
# Empty output means "no ready ticket" (all blocked or queue drained).

set -euo pipefail

INBOX_DIR="${1:?inbox dir required}"
WAVE_WIDTH="${2:?wave width required}"

[ -d "$INBOX_DIR/pending" ] || exit 0

python3 - "$INBOX_DIR" "$WAVE_WIDTH" <<'PY'
import os
import re
import sys
from pathlib import Path

inbox = Path(sys.argv[1])
wave_width = int(sys.argv[2])

def parse_frontmatter(path):
    text = path.read_text(errors="replace")
    if not text.startswith("---"):
        return {}
    end = text.find("\n---", 3)
    if end < 0:
        return {}
    fm_text = text[3:end].strip()
    fm = {}
    key = None
    list_acc = None
    for line in fm_text.splitlines():
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if re.match(r"^\s+-\s", line) and list_acc is not None:
            list_acc.append(line.split("-", 1)[1].strip().strip('"').strip("'"))
            continue
        m = re.match(r"^([A-Za-z_][A-Za-z0-9_]*):\s*(.*)$", line)
        if not m:
            continue
        key, val = m.group(1), m.group(2).strip()
        if val == "" or val == "|" or val == ">":
            list_acc = []
            fm[key] = list_acc
        elif val.startswith("[") and val.endswith("]"):
            fm[key] = [x.strip().strip('"').strip("'") for x in val[1:-1].split(",") if x.strip()]
            list_acc = None
        else:
            fm[key] = val.strip('"').strip("'")
            list_acc = None
    return fm

def ticket_id(p):
    return p.stem

done_ids = set()
if (inbox / "done").is_dir():
    for f in (inbox / "done").glob("T-*.md"):
        done_ids.add(ticket_id(f))

pending = sorted((inbox / "pending").glob("T-*.md"), key=lambda p: p.name)

ready = []
locked_paths = []

def paths_conflict(a_paths, b_paths):
    # Approximate path-lock: two tickets conflict if any of their allowed_path
    # entries share a non-trivial prefix or one is a glob over the other's tree.
    for a in a_paths:
        for b in b_paths:
            if a == b:
                return True
            # Strip glob suffixes for prefix comparison
            a_root = a.rstrip("*").rstrip("/")
            b_root = b.rstrip("*").rstrip("/")
            if not a_root or not b_root:
                continue
            if a_root == b_root:
                return True
            if a.endswith("/**") or a.endswith("/*"):
                if b.startswith(a_root + "/") or b == a_root:
                    return True
            if b.endswith("/**") or b.endswith("/*"):
                if a.startswith(b_root + "/") or a == b_root:
                    return True
            # Exact-file conflicts (e.g., both touch Cargo.toml)
            if "/" not in a and "/" not in b and a == b:
                return True
    return False

for p in pending:
    if len(ready) >= wave_width:
        break
    fm = parse_frontmatter(p)
    deps = fm.get("depends_on") or []
    if isinstance(deps, str):
        deps = [d.strip() for d in deps.split(",") if d.strip()]
    if not all(d in done_ids for d in deps):
        continue
    allowed = fm.get("allowed_paths") or []
    if isinstance(allowed, str):
        allowed = [allowed]
    if any(paths_conflict(allowed, locked) for locked in locked_paths):
        continue
    ready.append(ticket_id(p))
    locked_paths.append(allowed)

for tid in ready:
    print(tid)
PY
