#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Get project name from working directory
cwd=$(echo "$input" | jq -r '.cwd // ""')
project_name=$(basename "$cwd")
if [ -z "$project_name" ]; then
    project_name="Claude Code"
fi

# Dismiss notifications for this project group
terminal-notifier -remove "$project_name" 2>/dev/null

exit 0
