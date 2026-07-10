#!/usr/bin/env bats

# Test common tools installer functionality

setup() {
    source "${BATS_TEST_DIRNAME}/../lib/detect.sh"
    source "${BATS_TEST_DIRNAME}/../lib/utils.sh"
}

@test "install_jq function exists" {
    source "${BATS_TEST_DIRNAME}/../install/common.sh"
    declare -f install_jq > /dev/null
}

@test "install_jetbrains_mono_nerd_font function exists" {
    source "${BATS_TEST_DIRNAME}/../install/common.sh"
    declare -f install_jetbrains_mono_nerd_font > /dev/null
}

@test "install_yq function exists" {
    source "${BATS_TEST_DIRNAME}/../install/common.sh"
    declare -f install_yq > /dev/null
}

@test "install_ripgrep function exists" {
    source "${BATS_TEST_DIRNAME}/../install/common.sh"
    declare -f install_ripgrep > /dev/null
}

@test "install_bat function exists" {
    source "${BATS_TEST_DIRNAME}/../install/common.sh"
    declare -f install_bat > /dev/null
}

@test "install_btop function exists" {
    source "${BATS_TEST_DIRNAME}/../install/common.sh"
    declare -f install_btop > /dev/null
}

@test "install_github_cli function exists" {
    source "${BATS_TEST_DIRNAME}/../install/common.sh"
    declare -f install_github_cli > /dev/null
}

@test "install_gitlab_cli function exists" {
    source "${BATS_TEST_DIRNAME}/../install/common.sh"
    declare -f install_gitlab_cli > /dev/null
}

@test "install_tmux function exists" {
    source "${BATS_TEST_DIRNAME}/../install/common.sh"
    declare -f install_tmux > /dev/null
}

@test "install_zellij function exists" {
    source "${BATS_TEST_DIRNAME}/../install/common.sh"
    declare -f install_zellij > /dev/null
}

@test "install_kubectl function exists" {
    source "${BATS_TEST_DIRNAME}/../install/common.sh"
    declare -f install_kubectl > /dev/null
}

@test "install_kubectx function exists" {
    source "${BATS_TEST_DIRNAME}/../install/common.sh"
    declare -f install_kubectx > /dev/null
}

@test "install_k9s function exists" {
    source "${BATS_TEST_DIRNAME}/../install/common.sh"
    declare -f install_k9s > /dev/null
}

@test "install_tfenv function exists" {
    source "${BATS_TEST_DIRNAME}/../install/common.sh"
    declare -f install_tfenv > /dev/null
}
