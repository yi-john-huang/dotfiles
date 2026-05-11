#!/usr/bin/env bash

# Development Tools Installation Module
# Installs language runtimes and development tools

set -uo pipefail  # Removed -e to allow installation warnings

# Source required modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/detect.sh"
source "${SCRIPT_DIR}/../lib/utils.sh"

# Install nvm (Node Version Manager)
get_nvm_dir() {
    if [ -n "${NVM_DIR:-}" ]; then
        echo "$NVM_DIR"
    elif [ -s "$HOME/.nvm/nvm.sh" ]; then
        echo "$HOME/.nvm"
    elif [ -s "${XDG_CONFIG_HOME:-$HOME/.config}/nvm/nvm.sh" ]; then
        echo "${XDG_CONFIG_HOME:-$HOME/.config}/nvm"
    else
        echo "$HOME/.nvm"
    fi
}

install_nvm() {
    export NVM_DIR="$(get_nvm_dir)"

    # Temporarily disable nounset for nvm compatibility
    set +u

    if [ -s "$NVM_DIR/nvm.sh" ]; then
        log_info "✓ nvm already installed"
    else
        log_info "Installing nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    fi

    if [ -s "$NVM_DIR/nvm.sh" ]; then
        \. "$NVM_DIR/nvm.sh"
    else
        log_warn "nvm install did not create $NVM_DIR/nvm.sh"
        set -u
        return 1
    fi

    if ! declare -F nvm > /dev/null; then
        log_warn "nvm could not be loaded from $NVM_DIR"
        set -u
        return 1
    fi

    # Install latest LTS Node.js
    nvm install --lts
    nvm use --lts

    # Re-enable nounset
    set -u

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
    # Add to PATH for current session
    export PATH="$HOME/.local/bin:$PATH"
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
        local GO_ARCH="amd64"
        if [ "$(uname -m)" = "aarch64" ]; then
            GO_ARCH="arm64"
        fi
        
        local tmp_dir=$(mktemp -d)
        pushd "$tmp_dir" > /dev/null
        
        log_info "Downloading Go ${GO_VERSION} for ${GO_ARCH}..."
        curl -LO "https://go.dev/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
        
        log_info "Extracting Go..."
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
        
        popd > /dev/null
        rm -rf "$tmp_dir"
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
