#!/usr/bin/env bats

# Tests for notifications_clear_all.sh

setup() {
    # Get the directory of the test file
    TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
    PROJECT_ROOT="$(dirname "$TEST_DIR")"
    SCRIPT="$PROJECT_ROOT/hooks/notifications_clear_all.sh"

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

@test "notifications_clear_all.sh calls terminal-notifier with -remove ALL" {
    run "$SCRIPT"

    [ "$status" -eq 0 ]
    grep -q "\-remove ALL" "$MOCK_DIR/notifier_calls.log"
}

@test "notifications_clear_all.sh exits with status 0" {
    run "$SCRIPT"

    [ "$status" -eq 0 ]
}

@test "notifications_clear_all.sh suppresses terminal-notifier errors" {
    # Replace mock with one that writes to stderr
    cat > "$MOCK_DIR/terminal-notifier" << 'EOF'
#!/bin/bash
echo "Error: something went wrong" >&2
exit 1
EOF
    chmod +x "$MOCK_DIR/terminal-notifier"

    # Script should still exit 0 due to 2>/dev/null
    run "$SCRIPT"

    [ "$status" -eq 0 ]
}
