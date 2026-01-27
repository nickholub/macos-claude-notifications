# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Claude Code Configuration

Global Claude Code settings are at `~/.claude/settings.json`.

### Notification Hooks

Scripts in `~/.claude/hooks/`:
- `notify.sh` - Shows silent notification using `terminal-notifier`, grouped by project name
- `dismiss.sh` - Dismisses notifications for the current project group

Configured hooks in `~/.claude/settings.json`:
- **PreToolUse** - dismisses existing notifications for the project when Claude resumes work
- **Stop** - shows notification when Claude stops
- **PostToolUse (AskUserQuestion)** - shows notification when Claude asks for user input

Notifications are grouped by project name (`-group "$project_name"`) so each project's notifications can be dismissed independently when Claude starts working again.

## Development

### Testing

Shell scripts are tested using [bats-core](https://github.com/bats-core/bats-core).

**Install bats-core:**
```bash
brew install bats-core
```

**Run all tests:**
```bash
bats tests/
```

**Run a specific test file:**
```bash
bats tests/notify.bats
bats tests/dismiss.bats
```

Tests use mock versions of `terminal-notifier` to verify script behavior without triggering actual notifications.
