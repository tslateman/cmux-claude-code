#!/bin/bash
# Forward Claude Code notifications to cmux
source "$(dirname "$0")/cmux-common.sh"
cmux_available || exit 0

INPUT=$(cat 2>/dev/null)
if [ -n "$INPUT" ]; then
    echo "$INPUT" | cmux_run claude-hook notification || true
else
    cmux_run claude-hook notification || true
fi
