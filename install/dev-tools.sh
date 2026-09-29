#!/usr/bin/env bash

# Development Tools Installation Module
# Installs language runtimes and development tools

set -uo pipefail  # Removed -e to allow installation warnings

# Source required modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/detect.sh"
source "${SCRIPT_DIR}/../lib/utils.sh"

JAVA_MIN_VERSION="21.0.0"

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

# Install tree-sitter CLI
install_tree_sitter_cli() {
    if check_command tree-sitter && tree-sitter --version > /dev/null 2>&1; then
        log_info "✓ tree-sitter CLI already installed"
        return 0
    fi

    log_info "Installing tree-sitter CLI..."
    if [ "$IS_MACOS" = "true" ]; then
        brew install tree-sitter-cli || return 1
    else
        if ! check_command npm; then
            log_error "npm is required to install tree-sitter CLI"
            return 1
        fi
        npm install --global tree-sitter-cli || return 1
    fi

    if ! check_command tree-sitter || ! tree-sitter --version > /dev/null 2>&1; then
        log_error "tree-sitter CLI installation did not provide a working executable"
        return 1
    fi
    log_info "✓ tree-sitter CLI installed"
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
    local installed_version="" java_prefix="" java_jdk_link=""
    if check_command java; then
        installed_version="$(java -version 2>&1 | sed -n '1s/.*version "\([^"]*\)".*/\1/p' || true)"
        if version_at_least "$installed_version" "$JAVA_MIN_VERSION"; then
            log_info "✓ Java ${installed_version} already installed"
            return 0
        fi
    fi
    if [ "$IS_MACOS" = "true" ]; then
        java_prefix="$(brew --prefix openjdk@21 2>/dev/null || true)"
        if [ -x "$java_prefix/bin/java" ]; then
            installed_version="$("$java_prefix/bin/java" -version 2>&1 | sed -n '1s/.*version "\([^"]*\)".*/\1/p' || true)"
            if version_at_least "$installed_version" "$JAVA_MIN_VERSION"; then
                export JAVA_HOME="$java_prefix/libexec/openjdk.jdk/Contents/Home"
                export PATH="$JAVA_HOME/bin:$PATH"
                log_info "✓ Java ${installed_version} already installed"
                return 0
            fi
        fi
    fi


    log_info "Installing Java >= ${JAVA_MIN_VERSION}..."
    if [ "$IS_MACOS" = "true" ]; then
        brew install openjdk@21 || return 1
        java_prefix="$(brew --prefix openjdk@21)" || return 1
        java_jdk_link="/Library/Java/JavaVirtualMachines/openjdk-21.jdk"
        if [ ! -L "$java_jdk_link" ] || [ "$(readlink "$java_jdk_link")" != "$java_prefix/libexec/openjdk.jdk" ]; then
            if ! sudo -n ln -sfn "$java_prefix/libexec/openjdk.jdk" "$java_jdk_link"; then
                log_warn "Could not create $java_jdk_link without sudo; using the Homebrew Java path"
            fi
        fi
        export JAVA_HOME="$java_prefix/libexec/openjdk.jdk/Contents/Home"
        export PATH="$JAVA_HOME/bin:$PATH"
    else
        sudo apt-get install -y openjdk-21-jdk || return 1
        local java_arch java_home
        case "$OS_ARCH" in
            aarch64) java_arch="arm64" ;;
            x86_64) java_arch="amd64" ;;
            *)
                log_error "Unsupported architecture for Java: $OS_ARCH"
                return 1
                ;;
        esac
        java_home="/usr/lib/jvm/java-21-openjdk-${java_arch}"
        if [ ! -x "$java_home/bin/java" ] || [ ! -x "$java_home/bin/javac" ]; then
            log_error "OpenJDK 21 executables not found under $java_home"
            return 1
        fi
        sudo update-alternatives --set java "$java_home/bin/java" || return 1
        sudo update-alternatives --set javac "$java_home/bin/javac" || return 1
        export JAVA_HOME="$java_home"
        export PATH="$JAVA_HOME/bin:$PATH"
    fi

    installed_version="$(java -version 2>&1 | sed -n '1s/.*version "\([^"]*\)".*/\1/p' || true)"
    if ! version_at_least "$installed_version" "$JAVA_MIN_VERSION"; then
        log_error "Installation requires Java 21 or newer; found ${installed_version:-none}"
        return 1
    fi
    log_info "✓ Java ${installed_version} installed"
}

# Main installation function
install_dev_tools() {
    log_info "Starting development tools installation..."
    
    install_nvm
    install_tree_sitter_cli
    install_uv
    install_go
    install_java
    
    log_info "✓ Development tools installation complete"
}
