#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Append input JSON to date-based file if CLAUDE_HOOK_LOG_JSON is set
if [ -n "$CLAUDE_HOOK_LOG_JSON" ]; then
    echo "$input" | jq . >> "/tmp/claude-hook-$(date +%Y-%m-%d).json"
fi

# Check if this is already a hook-triggered stop (prevent infinite loops)
stop_hook_active=$(echo "$input" | jq -r '.stop_hook_active // false')
if [ "$stop_hook_active" = "true" ]; then
    exit 0
fi

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

# Get transcript path to extract what was done
transcript_path=$(echo "$input" | jq -r '.transcript_path // ""')

# Check if this is an AskUserQuestion tool use - extract the question
tool_name=$(echo "$input" | jq -r '.tool_name // ""')
if [ "$tool_name" = "AskUserQuestion" ]; then
    # Extract the first question from the questions array
    question=$(echo "$input" | jq -r '.tool_input.questions[0].question // "Question from Claude"')
    summary="$question"
else
    # Try to get a summary of what was done from the last assistant message
    summary="Task completed"
    if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
        # Get the last assistant message (look for the last text content)
        last_message=$(tail -20 "$transcript_path" | grep -o '"text":"[^"]*"' | tail -1 | sed 's/"text":"//;s/"$//' | head -c 100)
        if [ -n "$last_message" ]; then
            summary="$last_message"
        fi
    fi
fi

# Display macOS notification (requires: brew install terminal-notifier)
# Use project name as group for easy dismissal
terminal-notifier -title "$project_name" -message "$summary" -group "$project_name"

exit 0
