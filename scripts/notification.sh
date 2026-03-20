#!/bin/bash
# Forward Claude Code notifications to cmux
source "$(dirname "$0")/cmux-common.sh"
cmux_available || exit 0

INPUT=$(cat 2>/dev/null)

# cmux_run captures stdout via $() which drops piped stdin.
# Call $CMUX directly here and handle panel recovery inline.
run_notification() {
    local rc output
    if [ -n "$INPUT" ]; then
        output=$(echo "$INPUT" | "$CMUX" claude-hook notification 2>&1)
    else
        output=$("$CMUX" claude-hook notification 2>&1)
    fi
    rc=$?
    if [ $rc -ne 0 ] && echo "$output" | grep -qi "panel not found"; then
        "$CMUX" claude-hook session-start 2>/dev/null
        if [ -n "$INPUT" ]; then
            echo "$INPUT" | "$CMUX" claude-hook notification 2>/dev/null
        else
            "$CMUX" claude-hook notification 2>/dev/null
        fi
    fi
}

run_notification || true
