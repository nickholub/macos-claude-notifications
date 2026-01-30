#!/usr/bin/env bats

# Tests for notify.sh

setup() {
    # Get the directory of the test file
    TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(dirname "$TEST_DIR")"
    SCRIPT="$PROJECT_ROOT/hooks/notify.sh"

    # Create a mock terminal-notifier
    MOCK_DIR="$(mktemp -d)"
    MOCK_NOTIFIER="$MOCK_DIR/terminal-notifier"
    cat > "$MOCK_NOTIFIER" << 'EOF'
#!/bin/bash
# Record the arguments for verification
echo "$@" >> "$MOCK_DIR/notifier_calls.log"
exit 0
EOF
    chmod +x "$MOCK_NOTIFIER"

    # Export for use in tests
    export MOCK_DIR
    export PATH="$MOCK_DIR:$PATH"
}

teardown() {
    rm -rf "$MOCK_DIR"
}

@test "notify.sh exits early when stop_hook_active is true" {
    input='{"stop_hook_active": true, "cwd": "/test/project"}'

    run bash -c "echo '$input' | '$SCRIPT'"

    [ "$status" -eq 0 ]
    # Verify terminal-notifier was NOT called
    [ ! -f "$MOCK_DIR/notifier_calls.log" ]
}

@test "notify.sh extracts project name from cwd" {
    input='{"cwd": "/Users/nick/projects/my-project", "hook_type": "Stop"}'

    run bash -c "echo '$input' | '$SCRIPT'"

    [ "$status" -eq 0 ]
    # Verify terminal-notifier was called with project name
    grep -q "my-project" "$MOCK_DIR/notifier_calls.log"
}

@test "notify.sh uses default project name when cwd is empty" {
    input='{"cwd": "", "hook_type": "Stop"}'

    run bash -c "echo '$input' | '$SCRIPT'"

    [ "$status" -eq 0 ]
    # Verify terminal-notifier was called with default name
    grep -q "Claude Code" "$MOCK_DIR/notifier_calls.log"
}

@test "notify.sh uses project name as notification group" {
    input='{"cwd": "/Users/nick/projects/test-project", "hook_type": "Stop"}'

    run bash -c "echo '$input' | '$SCRIPT'"

    [ "$status" -eq 0 ]
    # Verify -group flag uses project name
    grep -q "\-group test-project" "$MOCK_DIR/notifier_calls.log"
}

@test "notify.sh handles JSON with transcript_path but missing file" {
    input='{"cwd": "/test/project", "hook_type": "Stop", "transcript_path": "/nonexistent/path"}'

    run bash -c "echo '$input' | '$SCRIPT'"

    [ "$status" -eq 0 ]
    # Should still complete with default summary
    grep -q "Task completed" "$MOCK_DIR/notifier_calls.log"
}

@test "notify.sh passes correct arguments to terminal-notifier" {
    input='{"cwd": "/test/myapp", "hook_type": "Stop"}'

    run bash -c "echo '$input' | '$SCRIPT'"

    [ "$status" -eq 0 ]
    # Verify all expected flags are present
    grep -q "\-title myapp" "$MOCK_DIR/notifier_calls.log"
    grep -q "\-message" "$MOCK_DIR/notifier_calls.log"
    grep -q "\-group myapp" "$MOCK_DIR/notifier_calls.log"
}

