#!/usr/bin/env bats

# Test Ubuntu installer functionality

setup() {
    # Only run on Ubuntu
    if [ ! -f /etc/os-release ]; then
        skip "Ubuntu-only tests"
    fi
    
    source /etc/os-release
    if [ "$ID" != "ubuntu" ]; then
        skip "Ubuntu-only tests"
    fi
    
    # Source required modules
    source "${BATS_TEST_DIRNAME}/../lib/detect.sh"
    source "${BATS_TEST_DIRNAME}/../lib/utils.sh"
}

@test "update_apt function exists" {
    source "${BATS_TEST_DIRNAME}/../install/ubuntu.sh"
    declare -f update_apt > /dev/null
}

@test "install_build_essentials function exists" {
    source "${BATS_TEST_DIRNAME}/../install/ubuntu.sh"
    declare -f install_build_essentials > /dev/null
}

@test "install_system_packages function exists" {
    source "${BATS_TEST_DIRNAME}/../install/ubuntu.sh"
    declare -f install_system_packages > /dev/null
}

@test "install_alacritty function exists" {
    source "${BATS_TEST_DIRNAME}/../install/ubuntu.sh"
    declare -f install_alacritty > /dev/null
}
