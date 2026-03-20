#!/bin/bash
# Clear sidebar state when a Claude Code session ends
source "$(dirname "$0")/cmux-common.sh"
cmux_available || exit 0

SURFACE_ID=$(cmux_surface_id)

cmux_run clear-status state 2>/dev/null || true
cmux_run clear-progress 2>/dev/null || true

rm -f "/tmp/cmux-progress-$SURFACE_ID"
