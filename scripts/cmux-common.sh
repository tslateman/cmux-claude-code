#!/bin/bash
# Shared cmux setup and recovery for all hook scripts
CMUX=/Applications/cmux.app/Contents/Resources/bin/cmux

cmux_available() {
    [ -x "$CMUX" ] && "$CMUX" identify >/dev/null 2>&1
}

# Run a cmux command; on "Panel not found", re-init session and retry once
cmux_run() {
    local output
    output=$("$CMUX" "$@" 2>&1)
    local rc=$?
    if [ $rc -ne 0 ] && echo "$output" | grep -qi "panel not found"; then
        "$CMUX" claude-hook session-start 2>/dev/null
        "$CMUX" "$@" 2>/dev/null
        return $?
    fi
    [ $rc -ne 0 ] && return $rc
    [ -n "$output" ] && echo "$output"
    return 0
}
