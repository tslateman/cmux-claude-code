#!/bin/bash
# Notify and reset sidebar state when Claude Code stops
source "$(dirname "$0")/cmux-common.sh"
cmux_available || exit 0

INPUT=$(cat 2>/dev/null)

STOP_REASON="end_turn"
BODY="Task complete"

if [ -n "$INPUT" ]; then
    STOP_REASON=$(echo "$INPUT" | jq -r '.stop_reason // "end_turn"' 2>/dev/null)
    STOP_REASON="${STOP_REASON:-end_turn}"
    case "$STOP_REASON" in
        end_turn) BODY="Done — check your terminal" ;;
        tool_use) BODY="Waiting for tool result" ;;
        *)        BODY="Task complete" ;;
    esac
fi

# Clear tool status
cmux_run clear-status tool || true

if [ "$STOP_REASON" = "end_turn" ]; then
    cmux_run set-status state "Done" --color "#50c878" || true
    cmux_run set-progress 1.0 || true
    rm -f "/tmp/cmux-progress-$(cmux_surface_id)"
fi

cmux_run notify --title "Claude Code" --body "$BODY" || true
