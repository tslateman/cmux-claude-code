#!/bin/bash
# Notify and reset sidebar state when Claude Code stops
CMUX=/Applications/cmux.app/Contents/Resources/bin/cmux
[ ! -x "$CMUX" ] && exit 0
"$CMUX" identify >/dev/null 2>&1 || exit 0

INPUT=$(cat 2>/dev/null)

STOP_REASON="end_turn"
BODY="Task complete"

if [ -n "$INPUT" ]; then
    PARSED=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    reason = d.get('stop_reason', 'end_turn')
    if reason == 'end_turn':
        msg = 'Done — check your terminal'
    elif reason == 'tool_use':
        msg = 'Waiting for tool result'
    else:
        msg = 'Task complete'
    print(f'{reason}|{msg}')
except:
    print('end_turn|Task complete')
" 2>/dev/null)
    STOP_REASON="${PARSED%%|*}"
    BODY="${PARSED#*|}"
fi

# Clear tool status
"$CMUX" clear-status tool 2>/dev/null || true

if [ "$STOP_REASON" = "end_turn" ]; then
    "$CMUX" set-status state "Done" --color "#50c878" 2>/dev/null || true
    "$CMUX" set-progress 1.0 2>/dev/null || true
    SURFACE_ID="${CMUX_SURFACE_ID:-$("$CMUX" identify --json 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['caller']['surface_ref'])" 2>/dev/null || echo default)}"
    rm -f "/tmp/cmux-progress-${SURFACE_ID}"
fi

"$CMUX" notify --title "Claude Code" --body "$BODY" 2>/dev/null || true
