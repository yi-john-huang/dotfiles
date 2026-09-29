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

@test "install_dev_tools continues and reports when a step fails under errexit" {
    run bash -c '
        set -e
        source "$1"
        install_nvm() { return 0; }
        install_tree_sitter_cli() { return 1; }
        install_uv() { echo "uv ran"; }
        install_go() { echo "go ran"; }
        install_java() { return 1; }
        install_dev_tools
    ' _ "${BATS_TEST_DIRNAME}/../install/dev-tools.sh"

    [ "$status" -eq 0 ]
    [[ "$output" == *"uv ran"* ]]
    [[ "$output" == *"go ran"* ]]
    [[ "$output" == *"with 2 failures"* ]]
}

@test "install_java fails on Linux when OpenJDK 21 is missing" {
    [ ! -e /usr/lib/jvm/java-21-openjdk-amd64/bin/java ] || skip "host has OpenJDK 21 installed"
    source "${BATS_TEST_DIRNAME}/../install/dev-tools.sh"
    IS_MACOS="false"
    OS_ARCH="x86_64"
    SUDO_LOG="$BATS_TEST_TMPDIR/sudo.log"
    check_command() { return 1; }
    sudo() { echo "$*" >> "$SUDO_LOG"; }

    run install_java

    [ "$status" -ne 0 ]
    [[ "$output" == *"OpenJDK 21 executables not found"* ]]
    [ "$(cat "$SUDO_LOG")" = "apt-get install -y openjdk-21-jdk" ]
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
