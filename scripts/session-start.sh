#!/bin/bash
# Initialize cmux sidebar state when a Claude Code session starts
[ -z "$CMUX_WORKSPACE_ID" ] && exit 0

cmux claude-hook session-start 2>/dev/null || true
