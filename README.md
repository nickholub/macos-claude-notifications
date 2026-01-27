# Claude Code Notification Hooks

macOS notification hooks for [Claude Code](https://claude.ai/code). Get notified when Claude stops working or needs your input.

## Features

- Silent macOS notifications via `terminal-notifier`
- Notifications grouped by project name
- Auto-dismiss when Claude resumes work
- Shows hook type, task summary, and JSON input

## Requirements

- macOS
- [terminal-notifier](https://github.com/julienXX/terminal-notifier): `brew install terminal-notifier`

## Installation

1. Copy hook scripts to Claude's hooks directory:
   ```bash
   mkdir -p ~/.claude/hooks
   cp claude/hooks/*.sh ~/.claude/hooks/
   chmod +x ~/.claude/hooks/*.sh
   ```

2. Configure hooks in `~/.claude/settings.json`:
   ```json
   {
     "hooks": {
       "PreToolUse": [
         {
           "matcher": "",
           "hooks": ["~/.claude/hooks/dismiss.sh"]
         }
       ],
       "Stop": [
         {
           "matcher": "",
           "hooks": ["~/.claude/hooks/notify.sh"]
         }
       ],
       "PostToolUse": [
         {
           "matcher": "AskUserQuestion",
           "hooks": ["~/.claude/hooks/notify.sh"]
         }
       ]
     }
   }
   ```

## How It Works

- **When Claude stops**: Shows notification with task summary
- **When Claude asks a question**: Shows notification prompting for input
- **When Claude resumes**: Dismisses previous notifications for that project

Notifications are grouped by project name, so each project's notifications can be managed independently.

## Development

### Testing

Tests use [bats-core](https://github.com/bats-core/bats-core):

```bash
brew install bats-core
bats tests/
```

### Debug Logging

`notify.sh` logs to `/tmp/claude-hook-debug.log` for troubleshooting.
