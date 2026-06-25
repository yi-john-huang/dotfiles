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

configure_homebrew_cask_defaults() {
    if [ "$IS_MACOS" = "true" ]; then
        mkdir -p "$HOME/Applications"
        export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications"
        log_info "Homebrew cask apps will install to $HOME/Applications"
    fi
}

# Main bootstrap function
main() {
    log_info "Starting dotfiles bootstrap..."
    log_info "Platform: $OS_TYPE ($OS_ARCH)"

    # Phase 0: Homebrew defaults
    configure_homebrew_cask_defaults
    
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
        verify_all || log_warn "Some tools failed verification (see above)"
    fi
    
    log_info "✓ Bootstrap complete!"
    log_info "Please restart your shell or run: source ~/.bashrc (or ~/.zshrc)"
}

# Deploy configuration files
deploy_configs() {
    log_info "Creating symlinks for dotfiles..."
    
    # Backup existing files
    for file in .bashrc .zshrc .tmux.conf .gitconfig .gitignore_global; do
        if [ -f "$HOME/$file" ] && [ ! -L "$HOME/$file" ]; then
            log_warn "Backing up existing $file to ${file}.backup"
            mv "$HOME/$file" "$HOME/${file}.backup"
        fi
    done
    
    # Copy shell configs (instead of symlink, to allow local modifications)
    # We force copy (-f) to overwrite
    cp -f "${DOTFILES_DIR}/config/shell/.bashrc" "$HOME/.bashrc"
    cp -f "${DOTFILES_DIR}/config/shell/.zshrc" "$HOME/.zshrc"
    ln -sf "${DOTFILES_DIR}/config/tmux/.tmux.conf" "$HOME/.tmux.conf"

    # Alacritty uses the XDG config path on both macOS and Linux.
    local alacritty_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/alacritty"
    mkdir -p "$alacritty_config_dir"
    for file in alacritty.toml; do
        if [ -f "$alacritty_config_dir/$file" ] && [ ! -L "$alacritty_config_dir/$file" ]; then
            log_warn "Backing up existing Alacritty $file to ${file}.backup"
            mv "$alacritty_config_dir/$file" "$alacritty_config_dir/${file}.backup"
        fi
    done
    ln -sf "${DOTFILES_DIR}/config/alacritty/alacritty.toml" "$alacritty_config_dir/alacritty.toml"

    # Zellij uses the XDG config path on both macOS and Linux.
    local zellij_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/zellij"
    mkdir -p "$zellij_config_dir"
    if [ -f "$zellij_config_dir/config.kdl" ] && [ ! -L "$zellij_config_dir/config.kdl" ]; then
        log_warn "Backing up existing Zellij config.kdl to config.kdl.backup"
        mv "$zellij_config_dir/config.kdl" "$zellij_config_dir/config.kdl.backup"
    fi
    ln -sf "${DOTFILES_DIR}/config/zellij/config.kdl" "$zellij_config_dir/config.kdl"

    # Git config (using include instead of symlink)
    if [ ! -f "$HOME/.gitconfig" ] || [ -L "$HOME/.gitconfig" ]; then
        # If it's a symlink or doesn't exist, start fresh
        [ -L "$HOME/.gitconfig" ] && rm "$HOME/.gitconfig"
        touch "$HOME/.gitconfig"
    fi
    
    # Configure include path
    # We use a relative path if possible, or absolute if needed. 
    # Since DOTFILES_DIR is absolute, we use that.
    git config -f "$HOME/.gitconfig" include.path "${DOTFILES_DIR}/config/git/.gitconfig"
    ln -sf "${DOTFILES_DIR}/config/git/.gitignore_global" "$HOME/.gitignore_global"
    
    log_info "✓ Configurations deployed"
}

# Run main function
main
