#!/usr/bin/env bash

# Ubuntu Installation Module
# Installs Ubuntu-specific packages and dependencies

set -uo pipefail  # Removed -e to allow apt warnings

# Source required modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/utils.sh"

# Update apt cache
update_apt() {
    log_info "Updating apt cache..."
    sudo apt-get update -qq
    log_info "✓ apt cache updated"
}

# Install build essentials
install_build_essentials() {
    if dpkg -l | grep -q build-essential; then
        log_info "✓ build-essential already installed"
        return 0
    fi
    
    log_info "Installing build-essential..."
    sudo apt-get install -y build-essential
    log_info "✓ build-essential installed"
}

# Install system packages
install_system_packages() {
    log_info "Installing system packages..."
    
    local packages=(
        curl
        wget
        git
        unzip
        software-properties-common
        apt-transport-https
        ca-certificates
        gnupg
        lsb-release
    )
    
    for pkg in "${packages[@]}"; do
        if dpkg -l | grep -q "^ii  $pkg "; then
            log_info "✓ $pkg already installed"
        else
            log_info "Installing $pkg..."
            sudo apt-get install -y "$pkg"
        fi
    done
    
    log_info "✓ System packages installed"
}

# Main installation function
install_ubuntu_tools() {
    log_info "Starting Ubuntu-specific installations..."
    
    update_apt
    install_build_essentials
    install_system_packages
    
    log_info "✓ Ubuntu tools installation complete"
}
