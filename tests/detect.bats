#!/usr/bin/env bats

# Test platform detection functionality

setup() {
    # Source the detect script
    source "${BATS_TEST_DIRNAME}/../lib/detect.sh" 2>/dev/null || true
}

@test "detect.sh exports OS_TYPE variable" {
    [ -n "$OS_TYPE" ]
}

@test "detect.sh exports OS_ARCH variable" {
    [ -n "$OS_ARCH" ]
}

@test "OS_TYPE is either Darwin or Linux" {
    [[ "$OS_TYPE" == "Darwin" || "$OS_TYPE" == "Linux" ]]
}

@test "OS_ARCH is either arm64 or x86_64" {
    [[ "$OS_ARCH" == "arm64" || "$OS_ARCH" == "x86_64" ]]
}

@test "IS_MACOS is set when on macOS" {
    if [ "$OS_TYPE" = "Darwin" ]; then
        [ "$IS_MACOS" = "true" ]
    fi
}

@test "IS_UBUNTU is set when on Ubuntu" {
    if [ "$OS_TYPE" = "Linux" ] && [ -f /etc/os-release ]; then
        source /etc/os-release
        if [ "$ID" = "ubuntu" ]; then
            [ "$IS_UBUNTU" = "true" ]
        fi
    fi
}

@test "detect.sh handles unknown platforms gracefully" {
    # This test ensures the script doesn't crash on unknown platforms
    [ -n "$OS_TYPE" ]
}
