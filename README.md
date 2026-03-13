# cmux-claude-code

A Claude Code plugin that updates the [cmux](https://cmux.app) sidebar with live session status, tool progress, and notifications.

## What it does

| Event                       | Effect                                                                      |
| --------------------------- | --------------------------------------------------------------------------- |
| Session starts              | Initializes the cmux sidebar                                                |
| You submit a prompt         | Sidebar shows "Thinking" in blue; tool/progress indicators clear            |
| Claude uses a tool          | Sidebar shows the tool name with an emoji label; progress bar advances      |
| Claude finishes             | Sidebar shows "Done" in green; progress fills to 100%; sends a notification |
| Claude sends a notification | Forwards it to cmux                                                         |

The progress bar uses a logarithmic scale — grows fast on early tool calls, slows as they accumulate, and fills to 100% only when Claude finishes.

Scripts are no-ops outside a cmux workspace (detected via `cmux identify`) — safe to install globally.

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/tslateman/cmux-claude-code/main/install.sh | bash
```

Or clone directly:

```bash
git clone https://github.com/tslateman/cmux-claude-code.git ~/.claude/plugins/cmux-claude-code
```

## Update

```bash
git -C ~/.claude/plugins/cmux-claude-code pull
```

Or run the install script again; it pulls if already installed.

Requires [cmux](https://cmux.app) with the CLI at `/Applications/cmux.app/Contents/Resources/bin/cmux`.

## Hooks

| Hook               | Script                     | Trigger                          |
| ------------------ | -------------------------- | -------------------------------- |
| `SessionStart`     | `scripts/session-start.sh` | Claude Code session opens        |
| `UserPromptSubmit` | `scripts/thinking.sh`      | User submits a prompt            |
| `PostToolUse`      | `scripts/tool-status.sh`   | Claude finishes a tool call      |
| `Stop`             | `scripts/notify.sh`        | Claude stops generating          |
| `Notification`     | `scripts/notification.sh`  | Claude Code emits a notification |

## License

MIT
