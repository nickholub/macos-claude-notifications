#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Get project name - prefer CLAUDE_PROJECT_DIR env var, fallback to cwd from input
if [ -n "$CLAUDE_PROJECT_DIR" ]; then
    project_name=$(basename "$CLAUDE_PROJECT_DIR")
else
    cwd=$(echo "$input" | jq -r '.cwd // ""')
    project_name=$(basename "$cwd")
fi
if [ -z "$project_name" ]; then
    project_name="Claude Code"
fi

# Dismiss notifications for this project group
terminal-notifier -remove "$project_name" 2>/dev/null

exit 0
