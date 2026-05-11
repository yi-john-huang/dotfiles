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
    
    # Remove broken hashicorp list if it exists (from previous failed runs)
    if [ -f /etc/apt/sources.list.d/hashicorp.list ]; then
        log_warn "Removing broken /etc/apt/sources.list.d/hashicorp.list"
        sudo rm /etc/apt/sources.list.d/hashicorp.list
    fi
    
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
        fontconfig
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

# Install Alacritty
install_alacritty() {
    if check_command alacritty; then
        log_info "✓ Alacritty already installed"
        return 0
    fi

    log_info "Installing Alacritty..."
    if sudo apt-get install -y alacritty; then
        log_info "✓ Alacritty installed"
    else
        log_warn "Alacritty installation failed"
        return 1
    fi
}

# Install Docker CE with buildx
install_docker() {
    if check_command docker && docker buildx version &>/dev/null; then
        log_info "✓ Docker with buildx already installed"
        return 0
    fi
    
    if ! check_command docker; then
        log_info "Installing Docker CE..."
        
        # Add Docker's official GPG key
        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
        
        # Add the repository
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
          sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        sudo apt-get update -qq
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        
        # Add current user to docker group
        sudo usermod -aG docker $USER
        log_info "✓ Docker CE installed (logout/login required for group changes)"
    fi
    
    # Ensure buildx is available
    if ! docker buildx version &>/dev/null; then
        log_info "Installing docker-buildx-plugin..."
        sudo apt-get install -y docker-buildx-plugin
    fi
    log_info "✓ Docker buildx installed"
}

# Main installation function
install_ubuntu_tools() {
    log_info "Starting Ubuntu-specific installations..."
    
    update_apt
    install_build_essentials
    install_system_packages
    install_alacritty
    install_docker
    
    log_info "✓ Ubuntu tools installation complete"
}
