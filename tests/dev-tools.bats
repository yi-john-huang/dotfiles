#!/usr/bin/env bats

# Test dev tools installer functionality

setup() {
    source "${BATS_TEST_DIRNAME}/../lib/detect.sh"
    source "${BATS_TEST_DIRNAME}/../lib/utils.sh"
}

@test "install_nvm function exists" {
    source "${BATS_TEST_DIRNAME}/../install/dev-tools.sh"
    declare -f install_nvm > /dev/null
}

@test "install_uv function exists" {
    source "${BATS_TEST_DIRNAME}/../install/dev-tools.sh"
    declare -f install_uv > /dev/null
}

@test "install_go function exists" {
    source "${BATS_TEST_DIRNAME}/../install/dev-tools.sh"
    declare -f install_go > /dev/null
}

@test "install_java function exists" {
    source "${BATS_TEST_DIRNAME}/../install/dev-tools.sh"
    declare -f install_java > /dev/null
}
