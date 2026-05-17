#!/usr/bin/env bash
# graph-json.sh -- non-interactive wrapper around moon's graph commands.
#
# `moon project-graph`, `moon task-graph`, and `moon action-graph` are
# INTERACTIVE by default -- they spin up a local http server and try to
# open a browser to render the DAG. In a non-interactive tool context
# (Claude Code Bash, CI shell, ssh session) that hangs the invocation.
#
# This wrapper forces --json output so the graph parses cleanly.
#
# Usage:
#   graph-json.sh project-graph                       # all projects
#   graph-json.sh project-graph app --dependents      # project + dependents
#   graph-json.sh task-graph
#   graph-json.sh task-graph app:build
#   graph-json.sh action-graph
#   graph-json.sh action-graph app:build
#
# Pipes cleanly through jq if installed:
#   graph-json.sh project-graph | jq '.nodes[].id'

set -euo pipefail

if [ $# -lt 1 ]; then
  cat >&2 <<'EOF'
graph-json.sh -- non-interactive moon-graph wrapper

Usage: graph-json.sh <project-graph|task-graph|action-graph> [args...]

The bare `moon <subcommand>` opens a browser; this wrapper forces --json.
EOF
  exit 64
fi

SUBCOMMAND="$1"
shift

case "$SUBCOMMAND" in
  project-graph|task-graph|action-graph) : ;;
  *)
    echo "graph-json.sh: unsupported subcommand '$SUBCOMMAND'" >&2
    echo "Supported: project-graph, task-graph, action-graph" >&2
    exit 64
    ;;
esac

exec moon "$SUBCOMMAND" "$@" --json
