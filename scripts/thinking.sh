#!/bin/bash
# Reset sidebar to "Thinking" state when user submits a prompt
[ -z "$CMUX_WORKSPACE_ID" ] && exit 0

CMUX=/Applications/cmux.app/Contents/Resources/bin/cmux
[ ! -x "$CMUX" ] && exit 0

"$CMUX" set-status state "Thinking" --color "#4a9eff" 2>/dev/null || true
"$CMUX" clear-status tool 2>/dev/null || true
"$CMUX" clear-progress 2>/dev/null || true

# Reset progress counter for this surface
echo 0 > "/tmp/cmux-progress-${CMUX_SURFACE_ID:-default}"
