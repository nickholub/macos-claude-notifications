#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Check if this is already a hook-triggered stop (prevent infinite loops)
stop_hook_active=$(echo "$input" | jq -r '.stop_hook_active // false')
if [ "$stop_hook_active" = "true" ]; then
    exit 0
fi

# Get hook type
hook_type=$(echo "$input" | jq -r '.hook_type // "Unknown"')

# Get project name from working directory
cwd=$(echo "$input" | jq -r '.cwd // ""')
project_name=$(basename "$cwd")
if [ -z "$project_name" ]; then
    project_name="Claude Code"
fi

# Get transcript path to extract what was done
transcript_path=$(echo "$input" | jq -r '.transcript_path // ""')

# Try to get a summary of what was done from the last assistant message
summary="Task completed"
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
    # Get the last assistant message (look for the last text content)
    last_message=$(tail -20 "$transcript_path" | grep -o '"text":"[^"]*"' | tail -1 | sed 's/"text":"//;s/"$//' | head -c 100)
    if [ -n "$last_message" ]; then
        summary="$last_message"
    fi
fi

# Display macOS notification (requires: brew install terminal-notifier)
# Use project name as group for easy dismissal
terminal-notifier -title "$project_name" -message "$summary [$hook_type]" -group "$project_name"

exit 0
