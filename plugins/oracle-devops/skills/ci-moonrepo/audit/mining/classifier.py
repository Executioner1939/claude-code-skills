"""Failure-mode classifier.

Keywords are lifted from the description: and keywords: fields of
plugins/oracle-devops/skills/ci-moonrepo/SKILL.md. Keep this file in
sync with the SKILL.md trigger surface so the mining classifier and
the skill's triggering signal drift together.
"""

from __future__ import annotations

import re
from typing import Iterable

# Each entry: failure-mode id -> list of regex patterns. A text that matches
# any pattern (case-insensitive) is classified into that failure mode. A text
# that matches patterns from multiple modes is labelled `multi`; the caller
# can then attribute the co-occurrence to every matched mode or drop it.

KEYWORDS: dict[str, list[str]] = {
    "moon-affected-detection-misses-targets": [
        r"resolved targets:\s*0",
        r"no tasks affected by changed files",
        r"build not started",
        r"shards finish in seconds",
        r"nothing gets built or pushed",
        r"github\.event\.before",
        r"MOON_BASE",
        r"MOON_HEAD",
        r"\bfetch-depth\s*[:=]\s*0\b",
        r"affected.*propagat",
    ],
    "moon-task-run-in-ci-misconfiguration": [
        r"runInCI",
        r"build-release fires on PR",
        r"missing releases",
        r"separate moon job for PRs and one for builds",
        r"\bturn on fail fast for Moon\b",
        r"deploy lane",
        r"build silently no-ops",
    ],
    "moon-project-id-image-name-divergence": [
        r"build green but prod unchanged",
        r"CI went green but dev env still serving",
        r"argocd image updater not picking up new images",
        r"docker image.*wrong tag",
        r"package ID specification .* did not match any packages",
        r"\$project",
        r"DOCKER_IMAGE",
        r"image-?updater",
        r"image name.*divergence",
    ],
    "moon-toolchain-prototools-drift": [
        r"linker not found",
        r"rustc mismatch",
        r"sccache:\s*command not found",
        r"MOON_SKIP_SETUP_RUST",
        r"MOON_SKIP_SETUP_TOOLCHAIN",
        r"MOON_TOOLCHAIN_FORCE_GLOBALS",
        r"setup-toolchain",
        r"setup-rust",
        r"\.prototools",
        r"rust-toolchain\.toml",
        r"toolchain.*drift",
    ],
    "moon-remote-cache-and-sccache-flakiness": [
        r"CI hanging",
        r"shard\s*\d+\s*hangs",
        r"builds\s*\d+\s*min\s*now\s*\d+",
        r"cache server unreachable",
        r"oscillating",
        r"keep flipping this on and off",
        r"RUSTC_WRAPPER",
        r"sccache",
        r"SCCACHE_",
        r"remote cache",
        r"bazel-remote",
        r"Depot",
    ],
    "rust-workspace-binary-name-collision": [
        r"\[\[bin\]\] name already defined",
        r"wrong projection_worker",
        r"projection_worker",
        r"event_worker",
        r"link error in CI",
        r"duplicate symbol",
        r"wrong binary",
        r"CARGO_TARGET_DIR",
        r"workspace.*\[\[bin\]\]",
    ],
}

# Pre-compile.
_COMPILED: dict[str, list[re.Pattern]] = {
    fm: [re.compile(p, re.IGNORECASE) for p in patterns]
    for fm, patterns in KEYWORDS.items()
}


def classify(text: str) -> set[str]:
    """Return the set of failure-mode ids whose patterns match `text`.

    Empty set means no classification (caller should drop). A set of
    size > 1 means the text matched multiple modes; the caller can
    attribute to each, or treat as `multi` and drop, depending on
    desired precision/recall trade-off.
    """
    if not text:
        return set()
    hits: set[str] = set()
    for fm, patterns in _COMPILED.items():
        for p in patterns:
            if p.search(text):
                hits.add(fm)
                break
    return hits


def classify_many(texts: Iterable[str]) -> set[str]:
    """Classify the union of a sequence of texts."""
    hits: set[str] = set()
    for t in texts:
        hits.update(classify(t))
    return hits


# ---------------------------------------------------------------------------
# File-touch classifier
# ---------------------------------------------------------------------------
# The keyword classifier above works on transcript text (where users paste
# CI symptoms verbatim). For CI commit chains, engineers write shorthand
# like "fix(ci): retry sccache install" -- the symptom phrases never appear.
# Classify by what the chain TOUCHED instead.
#
# Each failure mode has a known anchor file set drawn from the SKILL.md
# `paths:` frontmatter and the workflows.md per-mode file lists. A chain
# whose touched-file set intersects an anchor set in >= MIN_ANCHOR_HITS
# files is attributed to that mode. Tune MIN_ANCHOR_HITS per failure mode
# below to control false-positive rate.

import fnmatch as _fnmatch


FILE_ANCHORS: dict[str, list[str]] = {
    "moon-affected-detection-misses-targets": [
        ".github/workflows/*.yml",
        ".github/workflows/*.yaml",
        ".moon/tasks/*.yml",
        ".moon/workspace.yml",
        ".gitignore",
    ],
    "moon-task-run-in-ci-misconfiguration": [
        ".moon/tasks/*.yml",
        ".github/workflows/*.yml",
        ".github/workflows/*.yaml",
        "**/moon.yml",
    ],
    "moon-project-id-image-name-divergence": [
        "**/moon.yml",
        "**/Cargo.toml",
        "argocd/**",
        "kustomize/**",
        "**/Dockerfile",
    ],
    "moon-toolchain-prototools-drift": [
        ".prototools",
        "rust-toolchain.toml",
        ".moon/toolchains.yml",
        ".github/workflows/*.yml",
        ".github/workflows/*.yaml",
    ],
    "moon-remote-cache-and-sccache-flakiness": [
        ".moon/workspace.yml",
        ".github/workflows/*.yml",
        ".github/workflows/*.yaml",
        ".moon/tasks/*.yml",
    ],
    "rust-workspace-binary-name-collision": [
        "**/Cargo.toml",
        "**/moon.yml",
    ],
}

# Minimum number of anchor-pattern matches required to attribute a chain.
# Tuned per mode: modes whose anchor set is small (e.g. workspace-bin
# collision: just Cargo.toml + moon.yml) tolerate MIN=1; broader modes
# require MIN=2 to keep precision up.
MIN_ANCHOR_HITS: dict[str, int] = {
    "moon-affected-detection-misses-targets": 2,
    "moon-task-run-in-ci-misconfiguration": 2,
    "moon-project-id-image-name-divergence": 2,
    "moon-toolchain-prototools-drift": 2,
    "moon-remote-cache-and-sccache-flakiness": 2,
    "rust-workspace-binary-name-collision": 1,
}


def _matches_anchor(path: str, anchors: list[str]) -> bool:
    # Try both the path verbatim and a leading-** wrap so anchors like
    # `.prototools` match `repo/.prototools` and `.prototools` alike.
    for a in anchors:
        if _fnmatch.fnmatch(path, a):
            return True
        if "*" not in a and "**" not in a:
            if path.endswith("/" + a) or path == a:
                return True
        # `dir/**` style
        if a.endswith("/**") and (path.startswith(a[:-3] + "/") or ("/" + a[:-3] + "/") in path):
            return True
    return False


def classify_by_files(files: Iterable[str]) -> set[str]:
    """Return failure-mode ids whose anchor file sets are matched by the
    union of touched files. Independent of text content."""
    file_list = list(files)
    if not file_list:
        return set()
    hits: set[str] = set()
    for fm, anchors in FILE_ANCHORS.items():
        # Count UNIQUE anchor-patterns hit (not unique files), so a chain
        # touching ten .yml workflow files still counts as one workflow hit.
        matched_anchors = sum(
            1 for a in anchors
            if any(_matches_anchor(f, [a]) for f in file_list)
        )
        if matched_anchors >= MIN_ANCHOR_HITS.get(fm, 2):
            hits.add(fm)
    return hits


# ---------------------------------------------------------------------------
# Push-fault detector
# ---------------------------------------------------------------------------
# A chain whose later commits express regret/correction of the earlier ones
# is, by definition, a sequence of missed adjacent fixes. Commit subjects
# matching these keywords in the tail of a chain are the strongest signal
# the mining harness has for "the first commit didn't catch everything".

PUSH_FAULT_KEYWORDS = re.compile(
    r"\b(fix|hotfix|revert|retry|redo|rerun|oops|sorry|"
    r"actually|missed|forgot|broken|broke|wip|fixup|"
    r"address|amend|correct|fixes?|fixing)\b",
    re.IGNORECASE,
)


def is_push_fault_chain(subjects: list[str]) -> bool:
    """True if the chain's tail (everything after the first commit) contains
    at least one regret/correction keyword. The first commit is allowed to
    be a clean feat/chore; the later commits are where missed-fix evidence
    accumulates."""
    if len(subjects) < 2:
        return False
    later = subjects[1:]
    return any(PUSH_FAULT_KEYWORDS.search(s) for s in later)
