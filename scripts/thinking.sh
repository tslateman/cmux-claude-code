#!/bin/bash
# Reset sidebar to "Thinking" state when user submits a prompt
CMUX=/Applications/cmux.app/Contents/Resources/bin/cmux
[ ! -x "$CMUX" ] && exit 0
"$CMUX" identify >/dev/null 2>&1 || exit 0

"$CMUX" set-status state "Thinking" --color "#4a9eff" 2>/dev/null || true
"$CMUX" clear-status tool 2>/dev/null || true
"$CMUX" clear-progress 2>/dev/null || true

# Reset progress counter for this surface
SURFACE_ID="${CMUX_SURFACE_ID:-$("$CMUX" identify --json 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['caller']['surface_ref'])" 2>/dev/null || echo default)}"
echo 0 > "/tmp/cmux-progress-${SURFACE_ID}"
