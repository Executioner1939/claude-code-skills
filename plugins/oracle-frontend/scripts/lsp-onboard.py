#!/usr/bin/env python3
"""SessionStart LSP onboarding for Claude Code plugins.

Detects when this plugin declares an LSP server (`.lsp.json`) whose binary is
NOT on PATH, the current project actually uses the relevant file types, and the
user has not already been prompted for this (project, binary) pair. In that case
it injects `additionalContext` asking Claude to offer installation via the
user's own tooling (mise, rustup, cargo, npm, brew) or the official route, then
record the decision so the prompt never repeats.

SessionStart hooks cannot block or open a dialog, so this script only DETECTS
and INJECTS guidance. The actual approve/install/record loop is performed by
Claude reading the injected context. State is recorded via `--mark`.

Two modes:
  (default)  read hook JSON on stdin, emit SessionStart hookSpecificOutput JSON.
  --mark STATUS --command CMD [--cwd DIR]
             record STATUS (installed|declined) for (cwd, CMD) and exit. Used by
             Claude after the user decides, so future sessions stay silent.

Fast path: if every declared binary is already on PATH, the script does no file
walk and emits nothing. Safe: it never installs anything itself. Defensive: any
unexpected error exits 0 with no output so a session never fails to start.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import sys
from pathlib import Path

# Per-binary install recipes. Each entry: (tool-on-PATH, shell command). Only
# recipes whose tool is actually installed are surfaced to the user. The
# OFFICIAL map is the always-available fallback.
RECIPES: dict[str, list[tuple[str, str]]] = {
    "rust-analyzer": [
        ("mise", "mise use -g rust-analyzer@latest"),
        ("rustup", "rustup component add rust-analyzer"),
        ("brew", "brew install rust-analyzer"),
    ],
    "typescript-language-server": [
        ("mise", "mise use -g npm:typescript-language-server npm:typescript"),
        ("npm", "npm install -g typescript-language-server typescript"),
        ("pnpm", "pnpm add -g typescript-language-server typescript"),
    ],
}

OFFICIAL: dict[str, str] = {
    "rust-analyzer": "https://rust-analyzer.github.io/manual.html#installation",
    "typescript-language-server": "https://github.com/typescript-language-server/typescript-language-server#installing",
}

# Directories never worth walking when checking whether a project uses a language.
PRUNE = {"target", "node_modules", ".git", "dist", "build", ".next", ".turbo",
         ".venv", "venv", "__pycache__", ".moon", ".cache"}
MAX_DEPTH = 6


def state_dir() -> Path:
    base = os.environ.get("CLAUDE_PLUGIN_DATA") or os.path.join(
        os.path.expanduser("~"), ".claude", "lsp-onboarding"
    )
    p = Path(base) / "lsp-onboarding"
    p.mkdir(parents=True, exist_ok=True)
    return p


def marker(cwd: str, command: str) -> Path:
    key = hashlib.sha1(f"{os.path.abspath(cwd)}|{command}".encode()).hexdigest()[:16]
    return state_dir() / key


def already_handled(cwd: str, command: str) -> bool:
    m = marker(cwd, command)
    return m.with_suffix(".installed").exists() or m.with_suffix(".declined").exists()


def load_lsp_servers() -> list[tuple[str, list[str]]]:
    """Return [(command, [extensions])] from the plugin's .lsp.json."""
    root = os.environ.get("CLAUDE_PLUGIN_ROOT")
    if not root:
        return []
    f = Path(root) / ".lsp.json"
    if not f.is_file():
        return []
    try:
        data = json.loads(f.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return []
    out: list[tuple[str, list[str]]] = []
    for _name, cfg in (data or {}).items():
        if not isinstance(cfg, dict):
            continue
        command = cfg.get("command")
        exts = list((cfg.get("extensionToLanguage") or {}).keys())
        if command and exts:
            out.append((command, exts))
    return out


def project_uses(cwd: str, extensions: list[str]) -> bool:
    """True if any file under cwd (bounded walk, heavy dirs pruned) matches."""
    wanted = tuple(extensions)
    root = os.path.abspath(cwd)
    root_depth = root.rstrip(os.sep).count(os.sep)
    for dirpath, dirnames, filenames in os.walk(root):
        if dirpath.count(os.sep) - root_depth >= MAX_DEPTH:
            dirnames[:] = []
            continue
        dirnames[:] = [d for d in dirnames if d not in PRUNE and not d.startswith(".")]
        for fn in filenames:
            if fn.endswith(wanted):
                return True
    return False


def available_recipes(command: str) -> list[tuple[str, str]]:
    return [(tool, cmd) for tool, cmd in RECIPES.get(command, []) if shutil.which(tool)]


def build_context(missing: list[tuple[str, list[str]]], cwd: str) -> str:
    lines = [
        "LSP onboarding (from a plugin SessionStart hook). One or more language "
        "servers this plugin wires up are NOT installed on PATH, and this project "
        "uses the matching file types. For each server below, ask the user (via "
        "AskUserQuestion) whether to install it, offering the listed commands. Do "
        "not install without approval.",
        "",
    ]
    for command, exts in missing:
        lines.append(f"- `{command}` (handles {', '.join(exts)}) — not found on PATH.")
        recipes = available_recipes(command)
        if recipes:
            lines.append("  Install options detected on this machine:")
            for tool, cmd in recipes:
                lines.append(f"    - via {tool}: `{cmd}`")
        else:
            lines.append("  No known installer (mise/rustup/npm/brew) detected on PATH.")
        official = OFFICIAL.get(command)
        if official:
            lines.append(f"    - official instructions: {official}")
    lines += [
        "",
        "After the user decides, record the outcome so this prompt never repeats:",
        "  - installed:  python3 \"${CLAUDE_PLUGIN_ROOT}/scripts/lsp-onboard.py\" "
        "--mark installed --command <command>",
        "  - declined:   python3 \"${CLAUDE_PLUGIN_ROOT}/scripts/lsp-onboard.py\" "
        "--mark declined --command <command>",
        f"Run the --mark command from this project directory ({cwd}) so state is "
        "keyed to it. After a successful install, tell the user to run "
        "`/reload-plugins` (or restart) so Claude Code starts the language server.",
    ]
    return "\n".join(lines)


def emit(context: str) -> None:
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": context,
        }
    }))


def do_detect() -> int:
    raw = sys.stdin.read() if not sys.stdin.isatty() else ""
    try:
        payload = json.loads(raw) if raw.strip() else {}
    except ValueError:
        payload = {}
    # Avoid injecting mid-session noise on compaction; prompt on fresh/resumed starts.
    if payload.get("source") == "compact":
        return 0
    cwd = payload.get("cwd") or os.getcwd()

    servers = load_lsp_servers()
    if not servers:
        return 0

    missing: list[tuple[str, list[str]]] = []
    for command, exts in servers:
        if shutil.which(command):
            continue  # fast path: installed -> no walk, no prompt
        if already_handled(cwd, command):
            continue
        if not project_uses(cwd, exts):
            continue
        missing.append((command, exts))

    if missing:
        emit(build_context(missing, cwd))
    return 0


def do_mark(status: str, command: str, cwd: str) -> int:
    if status not in ("installed", "declined"):
        return 0
    m = marker(cwd, command)
    # Clear the opposite status, then write the new one.
    for other in ("installed", "declined"):
        if other != status:
            m.with_suffix(f".{other}").unlink(missing_ok=True)
    m.with_suffix(f".{status}").write_text("", encoding="utf-8")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(add_help=False)
    ap.add_argument("--mark", dest="status")
    ap.add_argument("--command")
    ap.add_argument("--cwd", default=os.getcwd())
    try:
        args, _ = ap.parse_known_args()
        if args.status:
            return do_mark(args.status, args.command or "", args.cwd)
        return do_detect()
    except Exception:
        # Never break a session over onboarding detection.
        return 0


if __name__ == "__main__":
    sys.exit(main())
