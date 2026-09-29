#!/usr/bin/env bats

# Test utility functions

setup() {
    source "${BATS_TEST_DIRNAME}/../lib/utils.sh" 2>/dev/null || true
}

@test "log_info outputs message" {
    run log_info "test message"
    [ "$status" -eq 0 ]
    [[ "$output" == *"test message"* ]]
}

@test "log_warn outputs warning message" {
    run log_warn "warning message"
    [ "$status" -eq 0 ]
    [[ "$output" == *"warning message"* ]]
}

@test "log_error outputs error message" {
    run log_error "error message"
    [ "$status" -eq 0 ]
    [[ "$output" == *"error message"* ]]
}

@test "check_command returns 0 for existing command" {
    run check_command "bash"
    [ "$status" -eq 0 ]
}

@test "check_command returns 1 for non-existing command" {
    run check_command "nonexistentcommand12345"
    [ "$status" -eq 1 ]
}

@test "version_at_least accepts equal versions" {
    run version_at_least "0.11.2" "0.11.2"
    [ "$status" -eq 0 ]
}

@test "version_at_least accepts newer versions" {
    run version_at_least "0.12.4" "0.11.2"
    [ "$status" -eq 0 ]
}

@test "version_at_least accepts a v prefix and suffix" {
    run version_at_least "v0.12.4-dev" "0.11.2"
    [ "$status" -eq 0 ]
}

@test "version_at_least rejects older versions" {
    run version_at_least "0.10.4" "0.11.2"
    [ "$status" -eq 1 ]
}

@test "version_at_least rejects malformed versions" {
    run version_at_least "nightly" "0.11.2"
    [ "$status" -eq 1 ]
}
