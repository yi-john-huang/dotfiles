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
