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

# Install Colima
install_colima() {
    if check_command colima; then
        log_info "✓ Colima already installed"
        return 0
    fi
    
    log_info "Installing Colima..."
    brew install colima docker docker-compose
    log_info "✓ Colima installed"
}

# Main installation function
install_macos_tools() {
    log_info "Starting macOS-specific installations..."
    
    install_homebrew
    install_iterm2
    install_colima
    
    log_info "✓ macOS tools installation complete"
}
