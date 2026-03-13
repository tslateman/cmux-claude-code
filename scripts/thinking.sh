#!/bin/bash
# Reset sidebar to "Thinking" state when user submits a prompt
source "$(dirname "$0")/cmux-common.sh"
cmux_available || exit 0

cmux_run set-status state "Thinking" --color "#4a9eff" || true
cmux_run clear-status tool || true
cmux_run clear-progress || true

# Reset progress counter for this surface
SURFACE_ID="${CMUX_SURFACE_ID:-$("$CMUX" identify --json 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['caller']['surface_ref'])" 2>/dev/null || echo default)}"
echo 0 > "/tmp/cmux-progress-${SURFACE_ID}"
