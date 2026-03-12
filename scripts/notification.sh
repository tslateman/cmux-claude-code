#!/bin/bash
# Forward Claude Code notifications to cmux
CMUX=/Applications/cmux.app/Contents/Resources/bin/cmux
[ ! -x "$CMUX" ] && exit 0
"$CMUX" identify >/dev/null 2>&1 || exit 0

INPUT=$(cat 2>/dev/null)
if [ -n "$INPUT" ]; then
    echo "$INPUT" | "$CMUX" claude-hook notification 2>/dev/null || true
else
    "$CMUX" claude-hook notification 2>/dev/null || true
fi
