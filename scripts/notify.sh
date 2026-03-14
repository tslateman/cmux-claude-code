#!/bin/bash
# Notify and reset sidebar state when Claude Code stops
source "$(dirname "$0")/cmux-common.sh"
cmux_available || exit 0

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
cmux_run clear-status tool || true

if [ "$STOP_REASON" = "end_turn" ]; then
    cmux_run set-status state "Done" --color "#50c878" || true
    cmux_run set-progress 1.0 || true
    rm -f "/tmp/cmux-progress-$(cmux_surface_id)"
fi

cmux_run notify --title "Claude Code" --body "$BODY" || true
