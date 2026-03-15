#!/bin/bash
# Clear sidebar state when a Claude Code session ends
source "$(dirname "$0")/cmux-common.sh"
cmux_available || exit 0

SURFACE_ID=$(cmux_surface_id)

"$CMUX" clear-status state 2>/dev/null || true
"$CMUX" clear-status claude_code 2>/dev/null || true
"$CMUX" clear-progress 2>/dev/null || true

rm -f "/tmp/cmux-progress-$SURFACE_ID"
