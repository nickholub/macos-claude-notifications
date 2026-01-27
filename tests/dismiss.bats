#!/usr/bin/env bats

# Tests for dismiss.sh

setup() {
    # Get the directory of the test file
    TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(dirname "$TEST_DIR")"
    SCRIPT="$PROJECT_ROOT/claude/hooks/dismiss.sh"

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

@test "dismiss.sh extracts project name from cwd" {
    input='{"cwd": "/Users/nick/projects/my-project"}'

    run bash -c "echo '$input' | '$SCRIPT'"

    [ "$status" -eq 0 ]
    # Verify terminal-notifier was called with -remove and project name
    grep -q "\-remove my-project" "$MOCK_DIR/notifier_calls.log"
}

@test "dismiss.sh uses default project name when cwd is empty" {
    input='{"cwd": ""}'

    run bash -c "echo '$input' | '$SCRIPT'"

    [ "$status" -eq 0 ]
    # Verify terminal-notifier was called with default name
    grep -q "\-remove Claude Code" "$MOCK_DIR/notifier_calls.log"
}

@test "dismiss.sh uses default project name when cwd is missing" {
    input='{}'

    run bash -c "echo '$input' | '$SCRIPT'"

    [ "$status" -eq 0 ]
    # Verify terminal-notifier was called with default name
    grep -q "\-remove Claude Code" "$MOCK_DIR/notifier_calls.log"
}

@test "dismiss.sh handles project names with hyphens" {
    input='{"cwd": "/path/to/my-awesome-project"}'

    run bash -c "echo '$input' | '$SCRIPT'"

    [ "$status" -eq 0 ]
    grep -q "\-remove my-awesome-project" "$MOCK_DIR/notifier_calls.log"
}

@test "dismiss.sh handles project names with underscores" {
    input='{"cwd": "/path/to/my_project_name"}'

    run bash -c "echo '$input' | '$SCRIPT'"

    [ "$status" -eq 0 ]
    grep -q "\-remove my_project_name" "$MOCK_DIR/notifier_calls.log"
}

@test "dismiss.sh exits with status 0" {
    input='{"cwd": "/test/project"}'

    run bash -c "echo '$input' | '$SCRIPT'"

    [ "$status" -eq 0 ]
}

@test "dismiss.sh handles deeply nested paths" {
    input='{"cwd": "/Users/nick/code/work/client/project-name"}'

    run bash -c "echo '$input' | '$SCRIPT'"

    [ "$status" -eq 0 ]
    grep -q "\-remove project-name" "$MOCK_DIR/notifier_calls.log"
}

@test "dismiss.sh suppresses terminal-notifier errors" {
    # Replace mock with one that writes to stderr
    cat > "$MOCK_DIR/terminal-notifier" << 'EOF'
#!/bin/bash
echo "Error: notification not found" >&2
exit 1
EOF
    chmod +x "$MOCK_DIR/terminal-notifier"

    input='{"cwd": "/test/project"}'

    # Script should still exit 0 due to 2>/dev/null
    run bash -c "echo '$input' | '$SCRIPT'"

    [ "$status" -eq 0 ]
}
