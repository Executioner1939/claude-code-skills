#!/usr/bin/env python3
"""mine-transcripts.py -- mine local Claude Code transcripts for moon
adjacent-fix co-occurrence pairs.

Scans `~/.claude/projects/*/<session-id>.jsonl`. For each session that
touches moon-relevant paths and whose user prompts classify into a
known failure mode, builds a per-session file-edit timeline and emits
co-occurrence pairs to feed the grader's adjacent-fix assertion.

Output schema is documented in `README.md`.

A "co-occurrence" is recorded when, within the same session classified
into failure-mode F, the assistant edited path A and later edited path
B. The pair (A, B) is attributed to F. The counter aggregates across
sessions.

Usage:
    python3 mine-transcripts.py \
        --projects-root ~/.claude/projects \
        --output co-occurrences.transcripts.json \
        [--min-edits 2] [--dry-run]

Limitations (see README §Limitations):
- Keyword classifier; will mislabel borderline cases.
- "Co-occurring" pair is any A-then-B in the same session; no
  inference about user-redirect vs same-ask. The grader can choose
  to weight by `count` and ignore long-tail pairs.
"""

from __future__ import annotations

import argparse
import datetime as dt
import fnmatch
import json
import pathlib
import sys
from collections import Counter, defaultdict
from dataclasses import dataclass, field

sys.path.insert(0, str(pathlib.Path(__file__).parent))
from classifier import classify, classify_many  # noqa: E402

MOON_RELEVANT_GLOBS = [
    "**/moon.yml",
    "**/.moon/**",
    "**/.prototools",
    "**/rust-toolchain.toml",
    "**/Cargo.toml",
    "**/.github/workflows/*.yml",
    "**/.github/workflows/*.yaml",
    "**/argocd/**",
]

EDIT_TOOLS = {"Edit", "Write", "MultiEdit", "NotebookEdit"}


def is_moon_relevant(path: str) -> bool:
    if not path:
        return False
    return any(fnmatch.fnmatch(path, g) for g in MOON_RELEVANT_GLOBS)


@dataclass
class SessionScan:
    session_id: str
    transcript_path: pathlib.Path
    user_texts: list[str] = field(default_factory=list)
    edited_paths_in_order: list[tuple[int, str]] = field(default_factory=list)
    # (turn_index, path). turn_index allows pair ordering across edits.

    @property
    def has_moon_edits(self) -> bool:
        return any(is_moon_relevant(p) for _, p in self.edited_paths_in_order)


def extract_user_text(content) -> str:
    """user message content can be a string or a list of content blocks."""
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts: list[str] = []
        for c in content:
            if isinstance(c, dict):
                if c.get("type") == "text":
                    parts.append(c.get("text", ""))
                # tool_result content can be a string OR a list of blocks
                elif c.get("type") == "tool_result":
                    tc = c.get("content")
                    if isinstance(tc, str):
                        parts.append(tc)
                    elif isinstance(tc, list):
                        for inner in tc:
                            if isinstance(inner, dict) and inner.get("type") == "text":
                                parts.append(inner.get("text", ""))
        return "\n".join(parts)
    return ""


def scan_session(path: pathlib.Path) -> SessionScan:
    scan = SessionScan(session_id=path.stem, transcript_path=path)
    turn = 0
    try:
        with open(path) as fh:
            for line in fh:
                line = line.strip()
                if not line:
                    continue
                try:
                    d = json.loads(line)
                except json.JSONDecodeError:
                    continue
                t = d.get("type")
                if t == "user":
                    msg = d.get("message", {})
                    text = extract_user_text(msg.get("content"))
                    if text:
                        scan.user_texts.append(text)
                elif t == "assistant":
                    msg = d.get("message", {})
                    content = msg.get("content", [])
                    if not isinstance(content, list):
                        continue
                    turn += 1
                    for c in content:
                        if not isinstance(c, dict):
                            continue
                        if c.get("type") != "tool_use":
                            continue
                        if c.get("name") not in EDIT_TOOLS:
                            continue
                        fp = (c.get("input") or {}).get("file_path", "")
                        if fp:
                            scan.edited_paths_in_order.append((turn, fp))
    except OSError:
        pass
    return scan


def mine(projects_root: pathlib.Path, min_edits: int = 2, verbose: bool = False) -> dict:
    sessions: list[SessionScan] = []
    transcript_files = list(projects_root.rglob("*.jsonl"))
    if verbose:
        print(f"scanning {len(transcript_files)} transcript files under {projects_root}", file=sys.stderr)
    for tp in transcript_files:
        scan = scan_session(tp)
        if scan.has_moon_edits and len(scan.edited_paths_in_order) >= min_edits:
            sessions.append(scan)
    if verbose:
        print(f"moon-relevant sessions with >= {min_edits} edits: {len(sessions)}", file=sys.stderr)

    # Classify each session by the union of its user texts.
    # Pairs from a session are attributed to every failure-mode label it carries.
    pair_counters: dict[str, Counter] = defaultdict(Counter)
    pair_evidence: dict[str, dict[tuple[str, str], list[dict]]] = defaultdict(lambda: defaultdict(list))

    for scan in sessions:
        labels = classify_many(scan.user_texts)
        if not labels:
            continue
        # De-duplicate paths within session; preserve first-edit order.
        # Restrict to moon-relevant paths -- non-moon files (random .rs etc.)
        # are noise, not adjacent fixes for the failure mode.
        seen: dict[str, int] = {}
        for turn, fp in scan.edited_paths_in_order:
            if not is_moon_relevant(fp):
                continue
            if fp not in seen:
                seen[fp] = turn
        ordered = sorted(seen.items(), key=lambda kv: kv[1])
        paths = [p for p, _ in ordered]
        if len(paths) < 2:
            continue
        # Emit every (A, B) ordered pair where B comes after A.
        # Normalize to a repo-relative-ish key by taking the last 3 segments
        # of the path, so the same moon.yml under different worktrees
        # aggregates rather than fragments.
        def norm(p: str) -> str:
            parts = p.rstrip("/").split("/")
            return "/".join(parts[-3:]) if len(parts) > 3 else p
        for i, a in enumerate(paths):
            for b in paths[i + 1:]:
                if a == b:
                    continue
                ka, kb = norm(a), norm(b)
                if ka == kb:  # different full paths but same last-3-segs key
                    continue
                key = (ka, kb)
                for fm in labels:
                    pair_counters[fm][key] += 1
                    if len(pair_evidence[fm][key]) < 5:
                        pair_evidence[fm][key].append({
                            "type": "transcript",
                            "session": scan.session_id,
                            "primary_full": a,
                            "adjacent_full": b,
                        })

    # Build output
    out: dict = {
        "version": 1,
        "generated_at": dt.datetime.utcnow().replace(microsecond=0).isoformat() + "Z",
        "source": "transcripts",
        "scanned_transcripts": len(transcript_files),
        "moon_relevant_sessions": len(sessions),
        "failure_modes": {},
    }
    for fm, counter in pair_counters.items():
        co_paths = []
        # cap evidence at 3 per pair to keep file manageable
        for (a, b), count in counter.most_common():
            ev = pair_evidence[fm][(a, b)][:3]
            co_paths.append({
                "primary": a,
                "adjacent": b,
                "count": count,
                "evidence": ev,
            })
        out["failure_modes"][fm] = {"co_occurring_paths": co_paths}
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--projects-root", type=pathlib.Path, default=pathlib.Path.home() / ".claude" / "projects",
                    help="root containing per-cwd directories of session .jsonl files")
    ap.add_argument("--output", type=pathlib.Path, default=pathlib.Path("co-occurrences.transcripts.json"))
    ap.add_argument("--min-edits", type=int, default=2,
                    help="ignore sessions with fewer than this many file edits (default 2)")
    ap.add_argument("--dry-run", action="store_true",
                    help="print summary to stdout, do not write file")
    ap.add_argument("--verbose", "-v", action="store_true")
    args = ap.parse_args()

    if not args.projects_root.exists():
        print(f"error: projects-root not found: {args.projects_root}", file=sys.stderr)
        sys.exit(2)

    result = mine(args.projects_root, min_edits=args.min_edits, verbose=args.verbose)

    if args.dry_run:
        print(f"scanned: {result['scanned_transcripts']} transcripts")
        print(f"moon-relevant sessions: {result['moon_relevant_sessions']}")
        for fm, body in result["failure_modes"].items():
            print(f"\n{fm}: {len(body['co_occurring_paths'])} co-occurring pairs")
            for p in body["co_occurring_paths"][:5]:
                print(f"  {p['count']:>3}  {p['primary']}  ->  {p['adjacent']}")
        return

    args.output.write_text(json.dumps(result, indent=2))
    print(f"wrote {args.output}")
    for fm, body in result["failure_modes"].items():
        print(f"  {fm}: {len(body['co_occurring_paths'])} pairs")


if __name__ == "__main__":
    main()
