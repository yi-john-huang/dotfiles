#!/usr/bin/env bats

# Test macOS installer functionality

setup() {
    # Only run on macOS
    if [ "$(uname -s)" != "Darwin" ]; then
        skip "macOS-only tests"
    fi
    
    # Source required modules
    source "${BATS_TEST_DIRNAME}/../lib/detect.sh"
    source "${BATS_TEST_DIRNAME}/../lib/utils.sh"
}

@test "install_homebrew function exists" {
    source "${BATS_TEST_DIRNAME}/../install/macos.sh"
    declare -f install_homebrew > /dev/null
}

@test "install_iterm2 function exists" {
    source "${BATS_TEST_DIRNAME}/../install/macos.sh"
    declare -f install_iterm2 > /dev/null
}

@test "install_alacritty function exists" {
    source "${BATS_TEST_DIRNAME}/../install/macos.sh"
    declare -f install_alacritty > /dev/null
}

@test "install_podman function exists" {
    source "${BATS_TEST_DIRNAME}/../install/macos.sh"
    declare -f install_podman > /dev/null
}

@test "Homebrew installation is idempotent" {
    if command -v brew &> /dev/null; then
        source "${BATS_TEST_DIRNAME}/../install/macos.sh"
        run install_homebrew
        [ "$status" -eq 0 ]
        [[ "$output" == *"already installed"* ]] || [[ "$output" == *"✓"* ]]
    else
        skip "Homebrew not installed"
    fi
}
