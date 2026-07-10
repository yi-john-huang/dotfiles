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

@test "install_oh_my_posh function exists" {
    source "${BATS_TEST_DIRNAME}/../install/macos.sh"
    declare -f install_oh_my_posh > /dev/null
}

@test "install_ice function exists" {
    source "${BATS_TEST_DIRNAME}/../install/macos.sh"
    declare -f install_ice > /dev/null
}

@test "install_podman function exists" {
    source "${BATS_TEST_DIRNAME}/../install/macos.sh"
    declare -f install_podman > /dev/null
}

@test "repair_homebrew_permissions function exists" {
    source "${BATS_TEST_DIRNAME}/../install/macos.sh"
    declare -f repair_homebrew_permissions > /dev/null
}

@test "install_or_reinstall_cask_app function exists" {
    source "${BATS_TEST_DIRNAME}/../install/macos.sh"
    declare -f install_or_reinstall_cask_app > /dev/null
}

@test "Homebrew cask appdir defaults to user Applications" {
    source "${BATS_TEST_DIRNAME}/../install/macos.sh"
    run get_homebrew_cask_appdir
    [ "$status" -eq 0 ]
    [ "$output" = "$HOME/Applications" ]
}

@test "iTerm2 installer uses user-level cask app helper" {
    source "${BATS_TEST_DIRNAME}/../install/macos.sh"
    install_iterm2_definition="$(declare -f install_iterm2)"
    [[ "$install_iterm2_definition" == *'install_or_reinstall_cask_app iterm2 "iTerm.app"'* ]]
}

@test "Ice installer uses user-level cask app helper" {
    source "${BATS_TEST_DIRNAME}/../install/macos.sh"
    install_ice_definition="$(declare -f install_ice)"
    [[ "$install_ice_definition" == *'install_or_reinstall_cask_app jordanbaird-ice "Ice.app"'* ]]
}

@test "Homebrew installation is idempotent" {
    if command -v brew &> /dev/null; then
        source "${BATS_TEST_DIRNAME}/../install/macos.sh"
        export HOMEBREW_REPAIR_PERMISSIONS=0
        run install_homebrew
        [ "$status" -eq 0 ]
        [[ "$output" == *"already installed"* ]] || [[ "$output" == *"✓"* ]]
    else
        skip "Homebrew not installed"
    fi
}
