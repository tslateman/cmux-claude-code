#!/bin/bash
# Initialize cmux sidebar state when a Claude Code session starts
source "$(dirname "$0")/cmux-common.sh"
cmux_available || exit 0

"$CMUX" claude-hook session-start 2>/dev/null || true

# Clear stale sidebar state from any previous session
cmux_run clear-status state 2>/dev/null || true
cmux_run clear-progress 2>/dev/null || true
rm -f "/tmp/cmux-progress-$(cmux_surface_id)"
