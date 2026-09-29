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

@test "install_tree_sitter_cli function exists" {
    source "${BATS_TEST_DIRNAME}/../install/dev-tools.sh"
    declare -f install_tree_sitter_cli > /dev/null
}

@test "install_java accepts Java 21" {
    source "${BATS_TEST_DIRNAME}/../install/dev-tools.sh"
    java() { printf 'openjdk version "21.0.7" 2025-04-15\n' >&2; }
    brew() { printf 'brew must not run\n' >&2; return 99; }

    run install_java

    [ "$status" -eq 0 ]
    [[ "$output" == *"Java 21.0.7 already installed"* ]]
    [[ "$output" != *"brew must not run"* ]]
}

@test "install_java rejects Java 17 after an attempted upgrade" {
    source "${BATS_TEST_DIRNAME}/../install/dev-tools.sh"
    IS_MACOS="true"
    java() { printf 'openjdk version "17.0.12" 2024-07-16\n' >&2; }
    brew() { return 0; }
    sudo() { return 0; }

    run install_java

    [ "$status" -ne 0 ]
    [[ "$output" == *"requires Java 21"* ]]
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
