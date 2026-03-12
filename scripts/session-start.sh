#!/bin/bash
# Initialize cmux sidebar state when a Claude Code session starts
CMUX=/Applications/cmux.app/Contents/Resources/bin/cmux
[ ! -x "$CMUX" ] && exit 0

"$CMUX" identify >/dev/null 2>&1 || exit 0

"$CMUX" claude-hook session-start 2>/dev/null || true
