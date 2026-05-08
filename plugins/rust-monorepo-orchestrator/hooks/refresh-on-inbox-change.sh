#!/usr/bin/env bash
# refresh-on-inbox-change.sh -- PostToolUse hook script.
#
# Fires after Edit / Write tool calls. If the edited path is under a
# .refactor/inbox/<domain>/ directory, refresh that domain's _registry.md
# so the dashboard stays in sync without orchestrator intervention.

set -euo pipefail

# Hook protocol: PostToolUse receives JSON on stdin.
INPUT=$(cat 2>/dev/null || true)
[ -n "$INPUT" ] || exit 0

if ! command -v jq >/dev/null 2>&1; then
  # No jq -- skip silently rather than break the tool flow.
  exit 0
fi

PATH_EDITED=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || echo '')
[ -n "$PATH_EDITED" ] || exit 0

# Only fire for paths under .refactor/inbox/<domain>/<state>/T-*.md.
case "$PATH_EDITED" in
  */.refactor/inbox/*/T-*.md)
    INBOX_DOMAIN_DIR=$(echo "$PATH_EDITED" | sed -E 's|(.*/.refactor/inbox/[^/]+).*|\1|')
    if [ -d "$INBOX_DOMAIN_DIR" ]; then
      bash "${CLAUDE_PLUGIN_ROOT}/scripts/registry-refresh.sh" "$INBOX_DOMAIN_DIR" >/dev/null 2>&1 || true
    fi
    ;;
esac

exit 0
