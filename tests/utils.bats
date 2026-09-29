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

@test "verify_sha256 accepts a matching checksum" {
    local file="$BATS_TEST_TMPDIR/data"
    printf 'hello\n' > "$file"
    local sum
    sum="$(shasum -a 256 "$file" | cut -d' ' -f1)"

    run verify_sha256 "$sum" "$file"

    [ "$status" -eq 0 ]
}

@test "verify_sha256 rejects a mismatched checksum" {
    local file="$BATS_TEST_TMPDIR/data"
    printf 'hello\n' > "$file"

    run verify_sha256 "0000000000000000000000000000000000000000000000000000000000000000" "$file"

    [ "$status" -ne 0 ]
}

@test "nvim_version extracts the version from a custom executable" {
    local fake="$BATS_TEST_TMPDIR/nvim"
    printf '#!/bin/sh\necho "NVIM v0.12.4"\n' > "$fake"
    chmod +x "$fake"

    run nvim_version "$fake"

    [ "$output" = "0.12.4" ]
}

@test "java_version extracts the version from a custom executable" {
    local fake="$BATS_TEST_TMPDIR/java"
    printf '#!/bin/sh\necho "openjdk version \\"21.0.7\\" 2025-04-15" >&2\n' > "$fake"
    chmod +x "$fake"

    run java_version "$fake"

    [ "$output" = "21.0.7" ]
}
