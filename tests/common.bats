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

@test "install_neovim function exists" {
    source "${BATS_TEST_DIRNAME}/../install/common.sh"
    declare -f install_neovim > /dev/null
}

@test "install_fd function exists" {
    source "${BATS_TEST_DIRNAME}/../install/common.sh"
    declare -f install_fd > /dev/null
}

@test "install_lazygit function exists" {
    source "${BATS_TEST_DIRNAME}/../install/common.sh"
    declare -f install_lazygit > /dev/null
}

@test "install_neovim skips a supported version" {
    source "${BATS_TEST_DIRNAME}/../install/common.sh"
    nvim() { printf 'NVIM v0.12.4\n'; }
    brew() { printf 'brew must not run\n' >&2; return 99; }

    run install_neovim

    [ "$status" -eq 0 ]
    [[ "$output" == *"already installed"* ]]
    [[ "$output" != *"brew must not run"* ]]
}

@test "install_neovim upgrades an old Homebrew formula" {
    source "${BATS_TEST_DIRNAME}/../install/common.sh"
    IS_MACOS="true"
    nvim() { printf 'NVIM v0.10.4\n'; }
    brew() {
        if [ "$1" = "list" ]; then
            return 0
        fi
        printf 'brew %s %s\n' "$1" "$2"
    }

    run install_neovim

    [ "$status" -ne 0 ]
    [[ "$output" == *"brew upgrade neovim"* ]]
    [[ "$output" == *"requires Neovim"* ]]
}

@test "install_neovim checksum failure leaves no Linux installation" {
    source "${BATS_TEST_DIRNAME}/../install/common.sh"
    IS_MACOS="false"
    OS_ARCH="aarch64"
    HOME="$BATS_TEST_TMPDIR/home"
    mkdir -p "$HOME"
    nvim() { printf 'NVIM v0.10.4\n'; }
    curl() {
        local output
        while [ "$#" -gt 0 ]; do
            if [ "$1" = "-o" ]; then
                output="$2"
                break
            fi
            shift
        done
        printf 'corrupt archive\n' > "$output"
    }
    verify_sha256() { return 1; }

    run install_neovim

    [ "$status" -ne 0 ]
    [ ! -e "$HOME/.local/opt/nvim-${NEOVIM_LINUX_VERSION}" ]
    [ ! -L "$HOME/.local/bin/nvim" ]
}

@test "install_lazygit checksum failure installs nothing" {
    source "${BATS_TEST_DIRNAME}/../install/common.sh"
    IS_MACOS="false"
    OS_ARCH="x86_64"
    HOME="$BATS_TEST_TMPDIR/home"
    mkdir -p "$HOME"
    check_command() { return 1; }
    curl() {
        local output
        while [ "$#" -gt 0 ]; do
            if [ "$1" = "-o" ]; then
                output="$2"
                break
            fi
            shift
        done
        printf 'corrupt archive\n' > "$output"
    }
    verify_sha256() { return 1; }

    run install_lazygit

    [ "$status" -ne 0 ]
    [[ "$output" == *"checksum verification failed"* ]]
    [ ! -e "$HOME/.local/bin/lazygit" ]
}

@test "install_fd refuses to replace an unrelated fd target on Linux" {
    source "${BATS_TEST_DIRNAME}/../install/common.sh"
    IS_MACOS="false"
    HOME="$BATS_TEST_TMPDIR/home"
    mkdir -p "$HOME/.local/bin"
    printf 'user script\n' > "$HOME/.local/bin/fd"
    check_command() { return 1; }
    sudo() { return 0; }
    command() { [ "$1" = "-v" ] && printf '/usr/bin/fdfind\n'; }

    run install_fd

    [ "$status" -ne 0 ]
    [[ "$output" == *"Refusing to replace"* ]]
    [ "$(cat "$HOME/.local/bin/fd")" = "user script" ]
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
