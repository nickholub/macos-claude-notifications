# macOS Claude Notifications

macOS notification hooks for [Claude Code](https://claude.ai/code). Get notified when Claude stops working or needs your input.

## Features

- macOS notifications via [terminal-notifier](https://github.com/julienXX/terminal-notifier)
- Notifications grouped by project for easy dismissal
- Auto-dismiss when Claude resumes work
- Extracts actual question text from AskUserQuestion prompts
- Debug logging (optional JSON history)

## Requirements

- macOS
- [terminal-notifier](https://github.com/julienXX/terminal-notifier): `brew install terminal-notifier`
- [jq](https://jqlang.github.io/jq/): `brew install jq`

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/nickholub/macos-claude-notifications.git
   ```

2. Configure hooks in `~/.claude/settings.json` using absolute paths to the repo:
   ```json
   {
     "hooks": {
       "PreToolUse": [
         {
           "matcher": "",
           "hooks": ["/path/to/macos-claude-notifications/hooks/notifications_dismiss.sh"]
         }
       ],
       "Stop": [
         {
           "matcher": "",
           "hooks": ["/path/to/macos-claude-notifications/hooks/notify.sh"]
         }
       ],
       "PostToolUse": [
         {
           "matcher": "AskUserQuestion",
           "hooks": ["/path/to/macos-claude-notifications/hooks/notify.sh"]
         }
       ]
     }
   }
   ```

   Replace `/path/to/macos-claude-notifications` with your actual clone location.

## How It Works

### Notification Format

- **Title**: Project name (from directory)
- **Subtitle**: Hook type (e.g., `Hook: [Stop]`)
- **Message**: Task summary or question text

### Hook Behavior

- **Stop hook**: Shows notification with task summary extracted from transcript
- **AskUserQuestion hook**: Shows notification with the actual question Claude is asking
- **PreToolUse hook**: Dismisses previous notifications when Claude resumes work

Notifications are grouped by project name, so dismissing one clears all notifications for that project.

## Logging

Both scripts log to `/tmp/claude-hook-debug.log` for troubleshooting.

To enable JSON history logging, set the `CLAUDE_HOOK_LOG_JSON` environment variable:
```bash
export CLAUDE_HOOK_LOG_JSON=1
```
This will append each hook's JSON input to `/tmp/claude-hook-YYYY-MM-DD.json`.

## Development

### Testing

Tests use [bats-core](https://github.com/bats-core/bats-core):

```bash
brew install bats-core
bats tests/
```
