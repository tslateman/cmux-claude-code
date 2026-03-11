#!/bin/bash
# Forward Claude Code notifications to cmux
[ -z "$CMUX_WORKSPACE_ID" ] && exit 0

INPUT=$(cat 2>/dev/null)
if [ -n "$INPUT" ]; then
    echo "$INPUT" | cmux claude-hook notification 2>/dev/null || true
else
    cmux claude-hook notification 2>/dev/null || true
fi
