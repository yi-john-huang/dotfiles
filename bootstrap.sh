#!/usr/bin/env bash

# Simplified Dotfiles Bootstrap Script
# One command to set up a production-ready development environment

set -euo pipefail

# Script directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source modules
source "${DOTFILES_DIR}/lib/detect.sh"
source "${DOTFILES_DIR}/lib/utils.sh"

# Parse arguments
FORCE_INSTALL=false
SKIP_VERIFY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --force)
            FORCE_INSTALL=true
            shift
            ;;
        --skip-verify)
            SKIP_VERIFY=true
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Usage: $0 [--force] [--skip-verify]"
            exit 1
            ;;
    esac
done

# Main bootstrap function
main() {
    log_info "Starting dotfiles bootstrap..."
    log_info "Platform: $OS_TYPE ($OS_ARCH)"
    
    # Phase 1: Platform-specific installations
    if [ "$IS_MACOS" = "true" ]; then
        log_info "Running macOS installations..."
        source "${DOTFILES_DIR}/install/macos.sh"
        install_macos_tools
    elif [ "$IS_UBUNTU" = "true" ]; then
        log_info "Running Ubuntu installations..."
        source "${DOTFILES_DIR}/install/ubuntu.sh"
        install_ubuntu_tools
    else
        log_error "Unsupported platform: $OS_TYPE"
        exit 1
    fi
    
    # Phase 2: Common tools
    log_info "Installing common tools..."
    source "${DOTFILES_DIR}/install/common.sh"
    install_common_tools
    
    # Phase 3: Development tools
    log_info "Installing development tools..."
    source "${DOTFILES_DIR}/install/dev-tools.sh"
    install_dev_tools
    
    # Phase 4: Deploy configurations
    log_info "Deploying configurations..."
    deploy_configs
    
    # Phase 5: Verification
    if [ "$SKIP_VERIFY" = "false" ]; then
        log_info "Verifying installations..."
        source "${DOTFILES_DIR}/verify.sh"
        verify_all
    fi
    
    log_info "✓ Bootstrap complete!"
    log_info "Please restart your shell or run: source ~/.bashrc (or ~/.zshrc)"
}

# Deploy configuration files
deploy_configs() {
    log_info "Creating symlinks for dotfiles..."
    
    # Backup existing files
    for file in .bashrc .zshrc .gitconfig .gitignore_global; do
        if [ -f "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
            log_warn "Backing up existing $file to ${file}.backup"
            mv "$HOME/$file" "$HOME/${file}.backup"
        fi
    done
    
    # Create symlinks
    ln -sf "${DOTFILES_DIR}/config/shell/.bashrc" "$HOME/.bashrc"
    ln -sf "${DOTFILES_DIR}/config/shell/.zshrc" "$HOME/.zshrc"
    ln -sf "${DOTFILES_DIR}/config/git/.gitconfig" "$HOME/.gitconfig"
    ln -sf "${DOTFILES_DIR}/config/git/.gitignore_global" "$HOME/.gitignore_global"
    
    log_info "✓ Configurations deployed"
}

# Run main function
main
