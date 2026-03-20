#!/bin/bash
# Update cmux sidebar with active tool name and progress
source "$(dirname "$0")/cmux-common.sh"
cmux_available || exit 0

INPUT=$(cat 2>/dev/null)
[ -z "$INPUT" ] && exit 0

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
[ -z "$TOOL_NAME" ] && exit 0

case "$TOOL_NAME" in
    Bash)         TOOL="⚡ Bash" ;;
    Read)         TOOL="📖 Read" ;;
    Write)        TOOL="✏️  Write" ;;
    Edit)         TOOL="✏️  Edit" ;;
    Glob)         TOOL="🔍 Glob" ;;
    Grep)         TOOL="🔍 Grep" ;;
    WebFetch)     TOOL="🌐 Fetch" ;;
    WebSearch)    TOOL="🌐 Search" ;;
    Agent)        TOOL="🤖 Agent" ;;
    Task)         TOOL="🤖 Task" ;;
    LSP)          TOOL="🔧 LSP" ;;
    NotebookEdit) TOOL="📓 Notebook" ;;
    NotebookRead) TOOL="📓 Notebook" ;;
    Skill)        TOOL="🎯 Skill" ;;
    TodoRead)     TOOL="📋 Todo" ;;
    TodoWrite)    TOOL="📋 Todo" ;;
    ToolSearch)   TOOL="🔍 ToolSearch" ;;
    mcp__*)       TOOL="🔌 ${TOOL_NAME##*__}" ;;
    *)            TOOL="$TOOL_NAME" ;;
esac

[ -z "$TOOL" ] && exit 0

cmux_run set-status tool "$TOOL" --color "#f0a500" || true

# Progress: logarithmic scale, caps at 0.95
COUNTER_FILE="/tmp/cmux-progress-$(cmux_surface_id)"
COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"

PROGRESS=$(awk "BEGIN { n=$COUNT; p=n/(n+10); if(p>0.95) p=0.95; printf \"%.3f\", p }")
[ -n "$PROGRESS" ] && cmux_run set-progress "$PROGRESS" --label "$COUNT tools" || true
