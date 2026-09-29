#!/usr/bin/env bats

# Test shell framework installer functionality

setup() {
    source "${BATS_TEST_DIRNAME}/../lib/utils.sh"
}

write_zim_install_stubs() {
    export ZIM_TEST_CALL_LOG="${BATS_TEST_TMPDIR}/zim-calls.log"
    TEST_HOME="${BATS_TEST_TMPDIR}/home"
    TEST_BIN="${BATS_TEST_TMPDIR}/bin"
    mkdir -p "$TEST_HOME" "$TEST_BIN"
    : > "$ZIM_TEST_CALL_LOG"

    cat > "${TEST_BIN}/curl" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail

echo "curl $*" >> "$ZIM_TEST_CALL_LOG"

output_path=""
while [ "$#" -gt 0 ]; do
    case "$1" in
        -o)
            shift
            output_path="$1"
            ;;
        -o*)
            output_path="${1#-o}"
            ;;
    esac
    shift || true
done

if [ -n "$output_path" ]; then
    mkdir -p "$(dirname "$output_path")"
    cat > "$output_path" <<'ZIMFW'
#!/usr/bin/env bash
set -euo pipefail
zim_home="${ZIM_HOME:-$HOME/.zim}"
mkdir -p "$zim_home"
printf '%s\n' "initialized by fake zimfw" > "$zim_home/init.zsh"
ZIMFW
    chmod +x "$output_path"
else
    cat <<'INSTALLER'
#!/usr/bin/env bash
set -euo pipefail
zim_home="${ZIM_HOME:-$HOME/.zim}"
mkdir -p "$zim_home"
printf '%s\n' "installed by fake zim installer" > "$zim_home/zimfw.zsh"
printf '%s\n' "initialized by fake zim installer" > "$zim_home/init.zsh"
INSTALLER
fi
STUB
    chmod +x "${TEST_BIN}/curl"

    cat > "${TEST_BIN}/zsh" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail

echo "zsh $*" >> "$ZIM_TEST_CALL_LOG"

if [ "$#" -gt 0 ]; then
    bash "$@"
else
    bash
fi
STUB
    chmod +x "${TEST_BIN}/zsh"

    export HOME="$TEST_HOME"
    export ZDOTDIR="$TEST_HOME"
    export ZIM_HOME="$TEST_HOME/.zim"
    export PATH="$TEST_BIN:$PATH"
}

assert_file_contains() {
    local file="$1"
    local expected="$2"
    [[ "$(cat "$file")" == *"$expected"* ]]
}

assert_file_not_contains() {
    local file="$1"
    local unexpected="$2"
    [[ "$(cat "$file")" != *"$unexpected"* ]]
}

write_bootstrap_fixture() {
    FIXTURE_ROOT="${BATS_TEST_TMPDIR}/dotfiles"
    FIXTURE_HOME="${BATS_TEST_TMPDIR}/home"
    FIXTURE_BIN="${BATS_TEST_TMPDIR}/bin"
    BOOTSTRAP_ORDER_LOG="${BATS_TEST_TMPDIR}/bootstrap-order.log"
    mkdir -p \
        "$FIXTURE_ROOT/lib" \
        "$FIXTURE_ROOT/install" \
        "$FIXTURE_ROOT/config/shell" \
        "$FIXTURE_ROOT/config/tmux" \
        "$FIXTURE_ROOT/config/git" \
        "$FIXTURE_ROOT/config/alacritty" \
        "$FIXTURE_ROOT/config/zellij" \
        "$FIXTURE_ROOT/config/nvim" \
        "$FIXTURE_HOME" \
        "$FIXTURE_BIN"
    : > "$BOOTSTRAP_ORDER_LOG"

    cp "${BATS_TEST_DIRNAME}/../bootstrap.sh" "$FIXTURE_ROOT/bootstrap.sh"

    cat > "$FIXTURE_ROOT/lib/detect.sh" <<'STUB'
#!/usr/bin/env bash
OS_TYPE="Darwin"
OS_ARCH="aarch64"
IS_MACOS="true"
IS_UBUNTU="false"
export OS_TYPE OS_ARCH IS_MACOS IS_UBUNTU
STUB

    cat > "$FIXTURE_ROOT/lib/utils.sh" <<'STUB'
#!/usr/bin/env bash
log_info() { echo "[INFO] $*"; }
log_warn() { echo "[WARN] $*"; }
log_error() { echo "[ERROR] $*" >&2; }
check_command() { command -v "$1" > /dev/null 2>&1; }
STUB

    cat > "$FIXTURE_ROOT/install/macos.sh" <<'STUB'
#!/usr/bin/env bash
install_macos_tools() { echo "macos" >> "$BOOTSTRAP_ORDER_LOG"; }
STUB
    cat > "$FIXTURE_ROOT/install/common.sh" <<'STUB'
#!/usr/bin/env bash
install_common_tools() { echo "common" >> "$BOOTSTRAP_ORDER_LOG"; }
STUB
    cat > "$FIXTURE_ROOT/install/dev-tools.sh" <<'STUB'
#!/usr/bin/env bash
install_dev_tools() { echo "dev-tools" >> "$BOOTSTRAP_ORDER_LOG"; }
STUB
    cat > "$FIXTURE_ROOT/install/shell.sh" <<'STUB'
#!/usr/bin/env bash
install_shell_frameworks() {
    if [ ! -f "$HOME/.zimrc" ]; then
        echo "shell:missing-zimrc" >> "$BOOTSTRAP_ORDER_LOG"
        return 1
    fi
    printf 'shell:%s\n' "$(cat "$HOME/.zimrc")" >> "$BOOTSTRAP_ORDER_LOG"
}
STUB

    printf '%s\n' "fixture bashrc" > "$FIXTURE_ROOT/config/shell/.bashrc"
    printf '%s\n' "fixture zshrc" > "$FIXTURE_ROOT/config/shell/.zshrc"
    printf '%s\n' "fixture zim config" > "$FIXTURE_ROOT/config/shell/.zimrc"
    printf '%s\n' "fixture tmux" > "$FIXTURE_ROOT/config/tmux/.tmux.conf"
    printf '%s\n' "fixture git config" > "$FIXTURE_ROOT/config/git/.gitconfig"
    printf '%s\n' "fixture gitignore" > "$FIXTURE_ROOT/config/git/.gitignore_global"
    printf '%s\n' "fixture alacritty" > "$FIXTURE_ROOT/config/alacritty/alacritty.toml"
    printf '%s\n' "fixture zellij" > "$FIXTURE_ROOT/config/zellij/config.kdl"
    printf '%s\n' "fixture nvim" > "$FIXTURE_ROOT/config/nvim/init.lua"

    cat > "$FIXTURE_BIN/git" <<'STUB'
#!/usr/bin/env bash
echo "git $*" >> "$BOOTSTRAP_ORDER_LOG"
exit 0
STUB
    chmod +x "$FIXTURE_BIN/git"
}

run_bootstrap_fixture() {
    run env \
        HOME="$FIXTURE_HOME" \
        BOOTSTRAP_ORDER_LOG="$BOOTSTRAP_ORDER_LOG" \
        PATH="$FIXTURE_BIN:$PATH" \
        bash "$FIXTURE_ROOT/bootstrap.sh" --skip-verify
}

@test "shell installer exposes callable Zim entrypoints" {
    source "${BATS_TEST_DIRNAME}/../install/shell.sh"

    declare -F install_zim > /dev/null
    declare -F install_shell_frameworks > /dev/null
}


@test "install_zim creates framework files for a new home without real network access" {
    source "${BATS_TEST_DIRNAME}/../install/shell.sh"
    write_zim_install_stubs

    run install_zim

    [ "$status" -eq 0 ]
    [ -s "$ZIM_HOME/zimfw.zsh" ]
    [ -s "$ZIM_HOME/init.zsh" ]
    [ -s "$HOME/.zimrc" ]
    assert_file_contains "$ZIM_TEST_CALL_LOG" "curl "
    assert_file_contains "$ZIM_TEST_CALL_LOG" "zsh -c"
}

@test "install_zim recognizes an initialized framework and does not fetch or regenerate" {
    source "${BATS_TEST_DIRNAME}/../install/shell.sh"
    write_zim_install_stubs
    mkdir -p "$ZIM_HOME"
    printf '%s\n' "existing zimfw" > "$ZIM_HOME/zimfw.zsh"
    printf '%s\n' "existing zimrc" > "$HOME/.zimrc"
    printf '%s\n' "existing init" > "$ZIM_HOME/init.zsh"
    touch -t 202001010000 "$ZIM_HOME/zimfw.zsh" "$HOME/.zimrc"
    touch -t 202001010001 "$ZIM_HOME/init.zsh"

    run install_zim

    [ "$status" -eq 0 ]
    [ "$(cat "$ZIM_HOME/zimfw.zsh")" = "existing zimfw" ]
    [ "$(cat "$HOME/.zimrc")" = "existing zimrc" ]
    [ "$(cat "$ZIM_HOME/init.zsh")" = "existing init" ]
    assert_file_not_contains "$ZIM_TEST_CALL_LOG" "curl "
    assert_file_not_contains "$ZIM_TEST_CALL_LOG" "zsh "
}

@test "install_shell_frameworks invokes Zim setup" {
    source "${BATS_TEST_DIRNAME}/../install/shell.sh"
    write_zim_install_stubs
    SHELL_FRAMEWORK_CALL_LOG="${BATS_TEST_TMPDIR}/shell-framework-calls.log"
    : > "$SHELL_FRAMEWORK_CALL_LOG"
    install_zim() {
        echo "zim" >> "$SHELL_FRAMEWORK_CALL_LOG"
        mkdir -p "${HOME}/.zim"
        printf '%s\n' "initialized by install_shell_frameworks" > "${HOME}/.zim/init.zsh"
    }

    run install_shell_frameworks

    [ "$status" -eq 0 ]
    assert_file_contains "$SHELL_FRAMEWORK_CALL_LOG" "zim"
    [ -s "$HOME/.zim/init.zsh" ]
}

@test "bootstrap deploys Neovim safely and initializes shell frameworks" {
    write_bootstrap_fixture
    mkdir -p "$FIXTURE_HOME/.config/nvim"
    printf '%s\n' "unmanaged config" > "$FIXTURE_HOME/.config/nvim/sentinel"

    run_bootstrap_fixture

    [ "$status" -eq 0 ]
    assert_file_contains "$BOOTSTRAP_ORDER_LOG" "shell:fixture zim config"
    [ "$(cat "$FIXTURE_HOME/.zimrc")" = "fixture zim config" ]
    [ "$(cat "$FIXTURE_HOME/.config/nvim.backup/sentinel")" = "unmanaged config" ]
    [ -L "$FIXTURE_HOME/.config/nvim" ]
    [ "$(readlink "$FIXTURE_HOME/.config/nvim")" = "$FIXTURE_ROOT/config/nvim" ]

    run_bootstrap_fixture

    [ "$status" -eq 0 ]
    [ "$(cat "$FIXTURE_HOME/.config/nvim.backup/sentinel")" = "unmanaged config" ]
    [ ! -e "$FIXTURE_HOME/.config/nvim.backup/nvim" ]
}

@test "bootstrap refuses a Neovim backup collision" {
    write_bootstrap_fixture
    mkdir -p "$FIXTURE_HOME/.config/nvim" "$FIXTURE_HOME/.config/nvim.backup"
    printf '%s\n' "current config" > "$FIXTURE_HOME/.config/nvim/sentinel"
    printf '%s\n' "preserved backup" > "$FIXTURE_HOME/.config/nvim.backup/sentinel"

    run_bootstrap_fixture

    [ "$status" -ne 0 ]
    [[ "$output" == *"$FIXTURE_HOME/.config/nvim"* ]]
    [[ "$output" == *"$FIXTURE_HOME/.config/nvim.backup"* ]]
    [ "$(cat "$FIXTURE_HOME/.config/nvim/sentinel")" = "current config" ]
    [ "$(cat "$FIXTURE_HOME/.config/nvim.backup/sentinel")" = "preserved backup" ]
}

@test "shell configs default EDITOR and VISUAL to Neovim" {
    local shell_home="${BATS_TEST_TMPDIR}/editor-home"
    mkdir -p "$shell_home"

    run env HOME="$shell_home" bash --noprofile --norc -c \
        "source '${BATS_TEST_DIRNAME}/../config/shell/.bashrc'; printf '%s:%s' \"\$EDITOR\" \"\$VISUAL\""
    [ "$status" -eq 0 ]
    [[ "$output" == *"nvim:nvim" ]]

    run env HOME="$shell_home" ZDOTDIR="$shell_home" zsh -f -c \
        "source '${BATS_TEST_DIRNAME}/../config/shell/.zshrc'; printf '%s:%s' \"\$EDITOR\" \"\$VISUAL\""
    [ "$status" -eq 0 ]
    [[ "$output" == *"nvim:nvim" ]]
}

@test "user extras can override the default editor" {
    local shell_home="${BATS_TEST_TMPDIR}/editor-override-home"
    mkdir -p "$shell_home"
    printf '%s\n' 'export EDITOR="custom-editor"' 'export VISUAL="$EDITOR"' > "$shell_home/.extra"

    run env HOME="$shell_home" bash --noprofile --norc -c \
        "source '${BATS_TEST_DIRNAME}/../config/shell/.bashrc'; printf '%s:%s' \"\$EDITOR\" \"\$VISUAL\""

    [ "$status" -eq 0 ]
    [[ "$output" == *"custom-editor:custom-editor" ]]
}
