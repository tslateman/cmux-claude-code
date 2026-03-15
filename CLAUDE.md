# cmux-claude-code

Claude Code plugin that drives a cmux sidebar with session status, tool progress, and notifications.

## File Layout

```
hooks/hooks.json          Hook definitions (6 hooks)
scripts/cmux-common.sh    Shared helpers: cmux_available, cmux_run, cmux_surface_id
scripts/session-start.sh  SessionStart — init sidebar, clear stale state
scripts/thinking.sh       UserPromptSubmit — set "Thinking", reset progress counter
scripts/tool-status.sh    PostToolUse — emoji-labeled tool name, logarithmic progress bar
scripts/notify.sh         Stop — set "Done", progress to 100%, send notification
scripts/session-cleanup.sh SessionEnd — clear all sidebar state, remove counter file
scripts/notification.sh   Notification — forward to cmux
install.sh                Clone + register in ~/.claude/plugins/installed_plugins.json
.claude-plugin/plugin.json Plugin metadata
```

## Hook Flow

1. **SessionStart** runs `cmux claude-hook session-start`, clears stale status/progress.
2. **UserPromptSubmit** sets status to "Thinking" (blue), clears tool status, resets the per-surface counter to 0.
3. **PostToolUse** maps tool_name to an emoji label (see case statement in tool-status.sh), increments the counter, sets progress via `min(0.95, n/(n+10))`. MCP tools (`mcp__*`) display the final segment of the tool name.
4. **Stop** parses stop_reason. On `end_turn`: sets "Done" (green), progress to 1.0, removes counter file. Sends a desktop notification regardless of reason.
5. **SessionEnd** clears all sidebar keys (state, claude_code, progress) and removes the counter file.
6. **Notification** pipes stdin JSON to `cmux claude-hook notification`.

## Key Patterns

### Graceful Degradation

Every script sources `cmux-common.sh` and runs `cmux_available || exit 0` before doing anything. `cmux_available` checks that the binary exists and `cmux identify` succeeds. Safe to install globally without cmux present.

### Panel Recovery (cmux_run)

`cmux_run()` wraps all cmux calls. If a command fails with "Panel not found" (orphaned panel, crash recovery), it re-runs `cmux claude-hook session-start` and retries once. This self-heals without user intervention.

### Surface ID Resolution (cmux_surface_id)

Resolves `$CMUX_SURFACE_ID` env var first. Falls back to `cmux identify --json`, extracting `caller.surface_ref` via jq. Defaults to `"default"` if both fail. This isolates per-terminal state when multiple Claude sessions share a machine.

### Per-Surface State

Tool counter stored at `/tmp/cmux-progress-{SURFACE_ID}`. One file per terminal surface. Created on UserPromptSubmit (reset to 0), incremented on PostToolUse, removed on Stop(end_turn) or SessionEnd.

### Progress Formula

`min(0.95, n / (n + 10))` -- logarithmic. Fills quickly at first, asymptotes at 95% during tool use. Reaches 100% only on end_turn. Displayed with a "{n} tools" label.

## Development Notes

- All scripts use `|| true` after cmux calls to prevent hook failures from blocking Claude.
- The cmux binary path is hardcoded: `/Applications/cmux.app/Contents/Resources/bin/cmux`.
- Hook timeouts: 5s for session lifecycle and notifications, 3s for prompt/tool hooks.
- jq is required for JSON parsing. awk handles progress calculation. No other dependencies.
