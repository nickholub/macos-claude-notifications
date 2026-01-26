# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Claude Code Configuration

Global Claude Code settings are at `~/.claude/settings.json`.

### Notification Hooks

Notification script: `~/.claude/hooks/notify.sh` (uses `terminal-notifier`)

Configured hooks in `~/.claude/settings.json`:
- **Stop** - triggers when Claude stops
- **Notification (idle_prompt)** - triggers when Claude is idle at the prompt
- **PostToolUse (AskUserQuestion)** - triggers when Claude asks for user input
