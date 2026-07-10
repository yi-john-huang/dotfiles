#!/usr/bin/env bash

# macOS Installation Module
# Installs macOS-specific tools and applications

set -uo pipefail  # Removed -e to allow brew warnings

# Source required modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/utils.sh"

get_homebrew_cask_appdir() {
    echo "${HOMEBREW_CASK_APPDIR:-$HOME/Applications}"
}

ensure_homebrew_cask_appdir() {
    local appdir
    appdir="$(get_homebrew_cask_appdir)"
    mkdir -p "$appdir"
}

repair_homebrew_permissions() {
    if ! check_command brew; then
        return 0
    fi

    local brew_prefix current_user needs_repair
    brew_prefix="$(brew --prefix 2>/dev/null)" || return 0
    current_user="$(id -un)"
    needs_repair=false

    local repair_paths=(
        "$HOME/Library/Caches/Homebrew"
        "$HOME/Library/Logs/Homebrew"
        "$brew_prefix"
        "$brew_prefix/Cellar"
        "$brew_prefix/Caskroom"
        "$brew_prefix/Frameworks"
        "$brew_prefix/bin"
        "$brew_prefix/etc"
        "$brew_prefix/include"
        "$brew_prefix/lib"
        "$brew_prefix/opt"
        "$brew_prefix/sbin"
        "$brew_prefix/share"
        "$brew_prefix/var/homebrew/linked"
        "$brew_prefix/var/homebrew/locks"
        "$brew_prefix/var/log"
    )

    local existing_paths=()
    local path
    for path in "${repair_paths[@]}"; do
        if [ -e "$path" ]; then
            existing_paths+=("$path")
            if [ ! -O "$path" ] || [ ! -w "$path" ]; then
                needs_repair=true
            fi
        fi
    done

    if find "$brew_prefix" -xdev ! -user "$current_user" -print -quit 2>/dev/null | grep -q .; then
        needs_repair=true
    fi

    if [ "$needs_repair" = "false" ]; then
        log_info "✓ Homebrew ownership looks healthy"
        return 0
    fi

    if [ "${HOMEBREW_REPAIR_PERMISSIONS:-1}" = "0" ]; then
        log_warn "Homebrew has root/other-owned or non-writable paths; set HOMEBREW_REPAIR_PERMISSIONS=1 to repair"
        return 1
    fi

    if ! check_command sudo; then
        log_warn "Homebrew permission repair needs sudo, but sudo is unavailable"
        return 1
    fi

    log_warn "Repairing Homebrew ownership for $current_user"
    if ! sudo chown -R "$current_user" "${existing_paths[@]}"; then
        log_warn "Homebrew ownership repair failed"
        return 1
    fi
    if ! chmod u+w "${existing_paths[@]}"; then
        log_warn "Homebrew writable-permission repair failed"
        return 1
    fi
    log_info "✓ Homebrew ownership repaired"
}

install_or_reinstall_cask_app() {
    local cask app_name appdir target system_target current_user
    cask="$1"
    app_name="$2"
    appdir="$(get_homebrew_cask_appdir)"
    target="$appdir/$app_name"
    system_target="/Applications/$app_name"
    current_user="$(id -un)"

    ensure_homebrew_cask_appdir

    if [ -d "$system_target" ] && [ ! -O "$system_target" ]; then
        log_warn "$app_name exists in /Applications but is not owned by $current_user"
        if [ "${HOMEBREW_REPAIR_CASK_APPS:-1}" = "0" ]; then
            log_warn "Skipping $app_name ownership repair; set HOMEBREW_REPAIR_CASK_APPS=1 to repair"
        elif ! sudo chown -R "$current_user" "$system_target"; then
            log_warn "$app_name ownership repair failed"
            return 1
        fi
    fi

    if [ -d "$target" ] && [ -O "$target" ] && brew list --cask "$cask" &> /dev/null; then
        log_info "✓ $app_name already installed in $appdir"
        return 0
    fi

    if brew list --cask "$cask" &> /dev/null; then
        log_info "Reinstalling $app_name into $appdir..."
        if ! brew reinstall --cask --appdir="$appdir" "$cask"; then
            log_warn "$app_name reinstall failed"
            return 1
        fi
    else
        log_info "Installing $app_name into $appdir..."
        if ! brew install --cask --appdir="$appdir" "$cask"; then
            log_warn "$app_name installation failed"
            return 1
        fi
    fi

    log_info "✓ $app_name installed"
}

# Install Homebrew
install_homebrew() {
    if check_command brew; then
        log_info "✓ Homebrew already installed"
        repair_homebrew_permissions || log_warn "Homebrew permission repair did not complete"
        return 0
    fi
    
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon
    if [ "$(uname -m)" = "arm64" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    
    log_info "✓ Homebrew installed"
    repair_homebrew_permissions || log_warn "Homebrew permission repair did not complete"
}

# Install iTerm2
install_iterm2() {
    install_or_reinstall_cask_app iterm2 "iTerm.app"
}

# Install Alacritty
install_alacritty() {
    if check_command brew && brew list --cask alacritty &> /dev/null; then
        log_info "✓ Alacritty already installed"
        return 0
    fi

    log_info "Installing Alacritty..."
    ensure_homebrew_cask_appdir
    if brew install --cask --appdir="$(get_homebrew_cask_appdir)" alacritty; then
        log_info "✓ Alacritty installed"
    else
        log_warn "Alacritty installation failed"
        return 1
    fi
}

# Install Oh My Posh
install_oh_my_posh() {
    if check_command omp; then
        log_info "✓ Oh My Posh already installed"
        return 0
    fi

    log_info "Installing Oh My Posh..."
    if brew install can1357/tap/omp; then
        log_info "✓ Oh My Posh installed"
    else
        log_warn "Oh My Posh installation failed"
        return 1
    fi
}

# Install Ice
install_ice() {
    install_or_reinstall_cask_app jordanbaird-ice "Ice.app"
}

# Install Podman
install_podman() {
    if check_command podman; then
        log_info "✓ Podman already installed"
    else
        log_info "Installing Podman..."
        brew install podman podman-compose
        log_info "✓ Podman installed"
    fi

    if ! check_command podman-compose; then
        log_info "Installing podman-compose..."
        brew install podman-compose
        log_info "✓ podman-compose installed"
    else
        log_info "✓ podman-compose already installed"
    fi

    # Install QEMU for x86_64 emulation
    if ! check_command qemu-img; then
        log_info "Installing QEMU for x86_64 emulation..."
        brew install qemu
        log_info "✓ QEMU installed"
    else
        log_info "✓ QEMU already installed"
    fi
    
}

# Main installation function
install_macos_tools() {
    log_info "Starting macOS-specific installations..."
    
    install_homebrew
    install_iterm2
    install_alacritty
    install_oh_my_posh
    install_ice
    install_podman
    
    log_info "✓ macOS tools installation complete"
}
