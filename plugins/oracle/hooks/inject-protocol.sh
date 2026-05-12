#!/usr/bin/env bash
# inject-protocol.sh -- SessionStart hook for the oracle plugin.
#
# Emits the oracle verification protocol as additionalContext so it loads
# into every session (and every subagent SessionStart) without editing
# CLAUDE.md. Disabling the plugin removes the protocol cleanly.

set -euo pipefail

read -r -d '' PROTOCOL <<'PROTOCOL_EOF' || true
# Oracle: Verification Protocol

Before stating any externally-verifiable claim, run the verification
cascade. Claims that require verification include, but are not limited to:

- Package, library, runtime, or framework versions ("Next.js 15 is current",
  "tokio 1.40 added X", "the latest cargo is Y").
- Library, crate, package, or module existence and API shape ("the
  `foo-bar` crate exposes Baz", "react-tasty has a `useFlavor` hook").
- Citations to articles, blog posts, papers, RFCs, specs, or
  documentation pages.
- Statistics, benchmarks, or measured numbers ("99th percentile latency
  on Postgres for X is Y").
- References to Reddit threads, Hacker News posts, Stack Overflow
  answers, GitHub issues, or any other forum content.
- Author attributions ("X said Y", "this was written by Z").

## The cascade

Run these in order. Stop as soon as one tier gives an authoritative answer.

1. **Package-manager CLI** -- fastest and most authoritative for version
   and package-existence claims:
   - npm / pnpm / yarn / bun:    `npm view <pkg> version`
   - cargo:                       `cargo search <crate> --limit 1`
   - pip / uv / poetry:           `pip index versions <pkg>` or
                                  `uv pip index versions <pkg>`
   - go modules:                  `go list -m -versions <module>`
   - gem:                         `gem info -r <gem>`
   - homebrew:                    `brew info --json=v2 <formula>`
   - apt / apt-get:               `apt-cache madison <pkg>`

2. **firecrawl-search skill** -- for anything that is not a package
   version (articles, blog posts, Reddit threads, Stack Overflow
   answers, stats, changelogs, release notes). Invoke the
   `firecrawl-search` skill or the `/firecrawl:search` workflow with a
   targeted query and read the returned content. Prefer the
   firecrawl-search skill over WebFetch + WebSearch when available
   because it returns full page markdown rather than search-result
   summaries.

3. **WebSearch / WebFetch** -- fallback when neither the package-manager
   CLI nor firecrawl yields a usable result. Use WebSearch to discover
   candidate URLs, then WebFetch the most authoritative one.

## Rules

- Never assert a version number without having run a CLI lookup in the
  same response, or having read a fetched changelog / release page.
- Never cite a URL without having fetched it. A URL the model has not
  read is a hallucination risk; treat it that way.
- When verification fails (network unavailable, package not found,
  firecrawl not installed), say so explicitly: "I could not verify X via
  <tier>; the claim is unverified." Do not proceed as if verified.
- When the user pins a version explicitly (for example, `cargo add
  tokio@1.40.0`), the pin itself is the user's verification decision.
  Pass it through without re-verifying.
- Cite the verification source inline, in the same response that makes
  the claim, with the file:line or URL the claim came from.

## When this protocol is in force

Always. The cascade is the default for every assertion that has an
external referent. Skipping it is a regression, not an optimisation.
PROTOCOL_EOF

if command -v jq >/dev/null 2>&1; then
  jq -n --arg c "$PROTOCOL" '{
    hookSpecificOutput: {
      hookEventName: "SessionStart",
      additionalContext: $c
    }
  }'
elif command -v python3 >/dev/null 2>&1; then
  PROTOCOL_BODY="$PROTOCOL" python3 - <<'PY'
import json, os
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": os.environ.get("PROTOCOL_BODY", ""),
    }
}))
PY
else
  # No jq, no python3 -- fail silently rather than break SessionStart.
  exit 0
fi
