#!/bin/bash
# Update cmux sidebar with active tool name and progress
[ -z "$CMUX_WORKSPACE_ID" ] && exit 0

CMUX=/Applications/cmux.app/Contents/Resources/bin/cmux
[ ! -x "$CMUX" ] && exit 0

INPUT=$(cat 2>/dev/null)
[ -z "$INPUT" ] && exit 0

TOOL=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    tool = d.get('tool_name', '')
    labels = {
        'Bash':      '⚡ Bash',
        'Read':      '📖 Read',
        'Write':     '✏️  Write',
        'Edit':      '✏️  Edit',
        'Glob':      '🔍 Glob',
        'Grep':      '🔍 Grep',
        'WebFetch':  '🌐 Fetch',
        'WebSearch': '🌐 Search',
        'Agent':     '🤖 Agent',
        'Task':      '🤖 Task',
    }
    print(labels.get(tool, tool))
except:
    pass
" 2>/dev/null)

[ -z "$TOOL" ] && exit 0

"$CMUX" set-status tool "$TOOL" --color "#f0a500" 2>/dev/null || true

# Progress: logarithmic scale, caps at 0.95
COUNTER_FILE="/tmp/cmux-progress-${CMUX_SURFACE_ID:-default}"
COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"

PROGRESS=$(python3 -c "n=$COUNT; print(f'{min(0.95, n/(n+10)):.3f}')" 2>/dev/null)
[ -n "$PROGRESS" ] && "$CMUX" set-progress "$PROGRESS" --label "$COUNT tools" 2>/dev/null || true
