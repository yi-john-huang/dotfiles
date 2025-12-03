#!/usr/bin/env bash

# Development Tools Installation Module
# Installs language runtimes and development tools

set -uo pipefail  # Removed -e to allow installation warnings

# Source required modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/detect.sh"
source "${SCRIPT_DIR}/../lib/utils.sh"

# Install nvm (Node Version Manager)
install_nvm() {
    if [ -d "$HOME/.nvm" ]; then
        log_info "✓ nvm already installed"
        return 0
    fi
    
    log_info "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    
    # Load nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # Install latest LTS Node.js
    nvm install --lts
    nvm use --lts
    
    log_info "✓ nvm and Node.js installed"
}

# Install uv (Python package manager)
install_uv() {
    if check_command uv; then
        log_info "✓ uv already installed"
        return 0
    fi
    
    log_info "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    log_info "✓ uv installed"
}

# Install Go
install_go() {
    if check_command go; then
        log_info "✓ Go already installed"
        return 0
    fi
    
    log_info "Installing Go..."
    if [ "$IS_MACOS" = "true" ]; then
        brew install go
    else
        local GO_VERSION="1.21.5"
        wget "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
        rm "go${GO_VERSION}.linux-amd64.tar.gz"
    fi
    log_info "✓ Go installed"
}

# Install Java (OpenJDK)
install_java() {
    if check_command java; then
        log_info "✓ Java already installed"
        return 0
    fi
    
    log_info "Installing Java..."
    if [ "$IS_MACOS" = "true" ]; then
        brew install openjdk@17
        # Link Java for system
        sudo ln -sfn "$(brew --prefix)/opt/openjdk@17/libexec/openjdk.jdk" /Library/Java/JavaVirtualMachines/openjdk-17.jdk
    else
        sudo apt-get install -y openjdk-17-jdk
    fi
    log_info "✓ Java installed"
}

# Main installation function
install_dev_tools() {
    log_info "Starting development tools installation..."
    
    install_nvm
    install_uv
    install_go
    install_java
    
    log_info "✓ Development tools installation complete"
}
