# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains Claude Code hook scripts for macOS notifications. The scripts in `hooks/` can be referenced directly via absolute paths in `~/.claude/settings.json`.

## Hook Scripts

### notify.sh
Shows macOS notification using `terminal-notifier`:
- **Title**: Project name (from `CLAUDE_PROJECT_DIR` or `cwd`)
- **Subtitle**: Hook type (e.g., `Hook: [Stop]`)
- **Message**: Task summary + compact JSON input
- **Grouping**: Notifications grouped by project name for easy dismissal

### notifications_dismiss.sh
Dismisses notifications for the current project group.

## Hook Configuration

Configure in `~/.claude/settings.json`:
- **PreToolUse** - dismisses existing notifications when Claude resumes work
- **Stop** - shows notification when Claude stops
- **PostToolUse (AskUserQuestion)** - shows notification when Claude asks for input

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
bats tests/notifications_dismiss.bats
```

Tests use mock versions of `terminal-notifier` to verify script behavior without triggering actual notifications.
