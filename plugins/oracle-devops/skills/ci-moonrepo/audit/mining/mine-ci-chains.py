#!/usr/bin/env python3
"""mine-ci-chains.py -- mine a target git repository for tight commit
chains touching moon-relevant paths.

The premise: when a real engineer makes commit C1 touching moon
configuration, and within a short window commits C2..Cn touch *related*
files in the same area, the later commits are evidence of fixes the
earlier commit missed. The (file_in_C1, file_in_Cn) pair is an
adjacent-fix co-occurrence.

This is the higher-signal mining surface (vs. transcripts) because:
- Timestamps are objective.
- "Missed-fix" semantics are unambiguous (later commit literally fixed
  something the earlier one didn't).
- Data is publicly verifiable from git history.

Usage:
    python3 mine-ci-chains.py \
        --repo /path/to/production/repo \
        --window-minutes 60 \
        --since 2025-01-01 \
        --output co-occurrences.ci-chains.json

The classifier labels each *chain* (not each commit) using the union of
commit messages in the chain. A chain with no failure-mode hits is
dropped. A chain matching multiple modes contributes to each.
"""

from __future__ import annotations

import argparse
import datetime as dt
import fnmatch
import json
import pathlib
import subprocess
import sys
from collections import Counter, defaultdict

sys.path.insert(0, str(pathlib.Path(__file__).parent))
from classifier import classify_many, classify_by_files, is_push_fault_chain  # noqa: E402

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


def is_moon_relevant(path: str) -> bool:
    return any(fnmatch.fnmatch(path, g) for g in MOON_RELEVANT_GLOBS)


def run_git(repo: pathlib.Path, *args: str) -> str:
    result = subprocess.run(
        ["git", "-C", str(repo), *args],
        check=True, capture_output=True, text=True,
    )
    return result.stdout


def parse_commits(repo: pathlib.Path, since: str | None) -> list[dict]:
    """Return commits in chronological order, oldest first.

    Uses a `\\x1e` record-start marker prefixed to each commit's pretty
    output so a line-by-line state machine can cleanly separate a
    commit's header from the previous commit's --name-only file list.
    The `\\x1f` field separator is internal to the header.
    """
    fmt = "\x1e%H\x1f%aI\x1f%s\x1f%b"
    cmd = ["log", "--reverse", f"--pretty=format:{fmt}", "--name-only"]
    if since:
        cmd.append(f"--since={since}")
    raw = run_git(repo, *cmd)
    commits: list[dict] = []
    current: dict | None = None
    for line in raw.split("\n"):
        if line.startswith("\x1e"):
            if current is not None:
                commits.append(current)
            parts = line[1:].split("\x1f")
            if len(parts) < 4:
                parts += [""] * (4 - len(parts))
            sha, iso_date, subject, body = parts[0], parts[1], parts[2], parts[3]
            try:
                ts = dt.datetime.fromisoformat(iso_date)
            except ValueError:
                current = None
                continue
            current = {
                "sha": sha,
                "ts": ts,
                "subject": subject,
                "body": body,
                "files": [],
                "moon_files": [],
            }
        else:
            line = line.strip()
            if not line or current is None:
                continue
            current["files"].append(line)
            if is_moon_relevant(line):
                current["moon_files"].append(line)
    if current is not None:
        commits.append(current)
    return commits


def group_into_chains(commits: list[dict], window: dt.timedelta) -> list[list[dict]]:
    """Adjacent commits within `window` form a chain. A commit with no
    moon files breaks the chain (the chain semantic is "a sustained
    moon-config editing session")."""
    chains: list[list[dict]] = []
    current: list[dict] = []
    for c in commits:
        if not c["moon_files"]:
            if current:
                chains.append(current)
                current = []
            continue
        if not current:
            current = [c]
            continue
        if c["ts"] - current[-1]["ts"] <= window:
            current.append(c)
        else:
            chains.append(current)
            current = [c]
    if current:
        chains.append(current)
    # Keep only chains of length >= 2 (single commits cannot show adjacent-fix)
    return [ch for ch in chains if len(ch) >= 2]


def mine(repo: pathlib.Path, window_minutes: int, since: str | None, verbose: bool) -> dict:
    if verbose:
        print(f"reading git log from {repo}", file=sys.stderr)
    commits = parse_commits(repo, since=since)
    if verbose:
        print(f"  {len(commits)} commits total", file=sys.stderr)

    window = dt.timedelta(minutes=window_minutes)
    chains = group_into_chains(commits, window)
    if verbose:
        print(f"  {len(chains)} chains of length >= 2 within {window_minutes}m window", file=sys.stderr)

    pair_counters: dict[str, Counter] = defaultdict(Counter)
    pair_evidence: dict[str, dict[tuple[str, str], list[dict]]] = defaultdict(lambda: defaultdict(list))

    # Diagnostic counters so the user can see why labelling did / didn't fire.
    diag = {
        "chains_labelled_by_keywords": 0,
        "chains_labelled_by_files": 0,
        "chains_labelled_by_both": 0,
        "chains_unlabelled": 0,
        "chains_push_fault": 0,
    }

    for chain in chains:
        subjects = [c["subject"] for c in chain]
        texts = [s + "\n" + c["body"] for s, c in zip(subjects, chain)]
        keyword_labels = classify_many(texts)
        all_files = [f for c in chain for f in c["moon_files"]]
        file_labels = classify_by_files(all_files)
        labels = keyword_labels | file_labels
        push_fault = is_push_fault_chain(subjects)

        if keyword_labels and file_labels:
            diag["chains_labelled_by_both"] += 1
        elif keyword_labels:
            diag["chains_labelled_by_keywords"] += 1
        elif file_labels:
            diag["chains_labelled_by_files"] += 1
        else:
            diag["chains_unlabelled"] += 1
        if push_fault:
            diag["chains_push_fault"] += 1

        if not labels:
            continue
        # Build the moon-file set per commit in chain order
        # Emit (A, B) where A was touched in commit i and B in commit j > i
        seen_files: dict[str, int] = {}  # path -> first-commit index
        for idx, c in enumerate(chain):
            for f in c["moon_files"]:
                if f not in seen_files:
                    seen_files[f] = idx
        # For each pair of files where first.idx < second.idx, record co-occurrence
        items = sorted(seen_files.items(), key=lambda kv: kv[1])
        chain_shas = [c["sha"][:8] for c in chain]
        chain_minutes = (chain[-1]["ts"] - chain[0]["ts"]).total_seconds() / 60

        # Weight: push-fault chains get a 2x multiplier on the co-occurrence
        # count because they are higher-signal (later commit literally fixed
        # what the earlier one didn't).
        weight = 2 if push_fault else 1

        for i, (a, ai) in enumerate(items):
            for b, bi in items[i + 1:]:
                if ai >= bi:
                    continue
                key = (a, b)
                for fm in labels:
                    pair_counters[fm][key] += weight
                    if len(pair_evidence[fm][key]) < 5:
                        pair_evidence[fm][key].append({
                            "type": "ci-chain",
                            "repo": repo.name,
                            "commits": chain_shas,
                            "chain_length": len(chain),
                            "window_minutes": round(chain_minutes, 1),
                            "push_fault": push_fault,
                            "label_source": (
                                "both" if keyword_labels and file_labels
                                else ("keyword" if keyword_labels else "file")
                            ),
                        })

    out: dict = {
        "version": 1,
        "generated_at": dt.datetime.utcnow().replace(microsecond=0).isoformat() + "Z",
        "source": "ci-chains",
        "repo": str(repo),
        "since": since,
        "window_minutes": window_minutes,
        "scanned_commits": len(commits),
        "chains_found": len(chains),
        "diagnostics": diag,
        "failure_modes": {},
    }
    for fm, counter in pair_counters.items():
        co_paths = []
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
    ap.add_argument("--repo", type=pathlib.Path, required=True,
                    help="path to a git repo whose history we mine")
    ap.add_argument("--window-minutes", type=int, default=60,
                    help="commits within this many minutes form a chain (default 60)")
    ap.add_argument("--since", type=str, default=None,
                    help="git --since value (e.g. 2025-01-01)")
    ap.add_argument("--output", type=pathlib.Path, default=pathlib.Path("co-occurrences.ci-chains.json"))
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--verbose", "-v", action="store_true")
    args = ap.parse_args()

    if not args.repo.is_dir():
        print(f"error: not a directory: {args.repo}", file=sys.stderr)
        sys.exit(2)
    if not (args.repo / ".git").exists():
        print(f"error: not a git repo: {args.repo}", file=sys.stderr)
        sys.exit(2)

    result = mine(args.repo, args.window_minutes, args.since, args.verbose)

    if args.dry_run:
        print(f"scanned: {result['scanned_commits']} commits")
        print(f"chains:  {result['chains_found']} (>=2 commits in {result['window_minutes']}m)")
        diag = result.get("diagnostics", {})
        print("classifier diagnostics:")
        for k, v in diag.items():
            print(f"  {k}: {v}")
        for fm, body in result["failure_modes"].items():
            print(f"\n{fm}: {len(body['co_occurring_paths'])} pairs")
            for p in body["co_occurring_paths"][:5]:
                src = p["evidence"][0].get("label_source", "?") if p.get("evidence") else "?"
                pf = any(e.get("push_fault") for e in p.get("evidence", []))
                marker = ("[push-fault] " if pf else "") + f"[{src}] "
                print(f"  {p['count']:>3}  {marker}{p['primary']}  ->  {p['adjacent']}")
        return

    args.output.write_text(json.dumps(result, indent=2))
    print(f"wrote {args.output}")
    for fm, body in result["failure_modes"].items():
        print(f"  {fm}: {len(body['co_occurring_paths'])} pairs")


if __name__ == "__main__":
    main()
