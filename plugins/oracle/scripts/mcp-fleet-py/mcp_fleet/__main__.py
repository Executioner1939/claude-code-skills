"""mcp-fleet CLI entry point."""

from __future__ import annotations

import sys

from .tui.app import FleetApp


def main() -> int:
    FleetApp().run()
    return 0


if __name__ == "__main__":
    sys.exit(main())
