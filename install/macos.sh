#!/usr/bin/env bash

# macOS Installation Module
# Installs macOS-specific tools and applications

set -uo pipefail  # Removed -e to allow brew warnings

# Source required modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/utils.sh"

# Install Homebrew
install_homebrew() {
    if check_command brew; then
        log_info "✓ Homebrew already installed"
        return 0
    fi
    
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon
    if [ "$(uname -m)" = "arm64" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    
    log_info "✓ Homebrew installed"
}

# Install iTerm2
install_iterm2() {
    if check_command brew && brew list --cask iterm2 &> /dev/null; then
        log_info "✓ iTerm2 already installed"
        return 0
    fi
    
    log_info "Installing iTerm2..."
    brew install --cask iterm2
    log_info "✓ iTerm2 installed"
}

# Install Alacritty
install_alacritty() {
    if check_command brew && brew list --cask alacritty &> /dev/null; then
        log_info "✓ Alacritty already installed"
        return 0
    fi

    log_info "Installing Alacritty..."
    mkdir -p "$HOME/Applications"
    if brew install --cask --appdir="$HOME/Applications" alacritty; then
        log_info "✓ Alacritty installed"
    else
        log_warn "Alacritty installation failed"
        return 1
    fi
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
    install_podman
    
    log_info "✓ macOS tools installation complete"
}
