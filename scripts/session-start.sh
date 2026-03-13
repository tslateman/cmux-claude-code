#!/bin/bash
# Initialize cmux sidebar state when a Claude Code session starts
source "$(dirname "$0")/cmux-common.sh"
cmux_available || exit 0

"$CMUX" claude-hook session-start 2>/dev/null || true
