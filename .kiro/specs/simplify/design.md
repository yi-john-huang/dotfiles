# Technical Design Document

## Project: simplify

**Project Name:** dotfiles-refactor
**Architecture:** Shell-based Bootstrap System
**Language:** Bash

Generated on: 2025-12-02T15:40:49.169Z

## Architecture Overview

### System Architecture
Modular shell script system with platform detection and idempotent installation logic.

```
bootstrap.sh (entry point)
├── lib/detect.sh (OS/arch detection)
├── lib/utils.sh (logging, error handling)
├── install/
│   ├── macos.sh (macOS-specific installations)
│   ├── ubuntu.sh (Ubuntu-specific installations)
│   ├── common.sh (cross-platform tools)
│   └── dev-tools.sh (language runtimes)
├── config/
│   ├── shell/ (.bashrc, .zshrc, aliases)
│   ├── nvim/ (Neovim + lazy.nvim config)
│   └── git/ (.gitconfig, .gitignore_global)
├── deprecated/ (obsolete files from old dotfiles)
└── verify.sh (post-install validation)
```

### Key Components

#### 1. Bootstrap Orchestrator (`bootstrap.sh`)
- Entry point for entire setup
- Detects platform and architecture
- Orchestrates installation sequence
- Provides progress feedback

#### 2. Platform Detection (`lib/detect.sh`)
- Detects OS (macOS/Ubuntu)
- Detects architecture (ARM64/x86_64)
- Sets platform-specific variables
- Exports detection results for other scripts

#### 3. Installation Modules
- **`install/macos.sh`**: Homebrew, iTerm2, Colima, macOS-specific tools
- **`install/ubuntu.sh`**: apt packages, Ubuntu-specific setup
- **`install/common.sh`**: jq, yq, ripgrep, bat, zellij, kubectl, kubectx, k9s, Terraform
- **`install/dev-tools.sh`**: nvm, uv, Go, Java/Spring Boot tools

#### 4. Configuration Deployment (`config/`)
- Shell configurations with aliases and functions
- Neovim setup with lazy.nvim
- Git configuration
- Symlink management for dotfiles

#### 5. Verification (`verify.sh`)
- Validates all tools are installed
- Checks versions
- Reports missing or failed installations

## Implementation Details

### Technology Stack
- Shell: Bash 4.0+
- Package Managers: Homebrew (macOS), apt (Ubuntu)
- Version Managers: nvm (Node.js), uv (Python)

### Installation Strategy

#### Idempotency Pattern
```bash
if ! command -v tool &> /dev/null; then
    install_tool
else
    echo "✓ tool already installed"
fi
```

#### Error Handling
```bash
set -e  # Exit on error
trap cleanup EXIT  # Cleanup on exit
```

#### Logging Levels
- INFO: Progress updates
- WARN: Non-fatal issues
- ERROR: Fatal errors with cleanup

### Platform-Specific Logic

#### macOS (Apple Silicon)
- Homebrew prefix: `/opt/homebrew`
- Install iTerm2 via `brew install --cask iterm2`
- Install Colima for containers
- Handle Rosetta 2 if needed

#### Ubuntu (x86_64)
- Use apt for system packages
- Manual installation for tools not in apt
- Handle sudo requirements

### Configuration Files

#### Shell (.bashrc/.zshrc)
- PATH configuration for all tools
- Aliases for common commands
- Functions for productivity
- Source ~/.extra if exists

#### Neovim
- lazy.nvim as plugin manager
- Auto-install plugins on first launch
- LSP configurations for Java, TypeScript, Python, Go

## Interface Specifications

### Main Entry Point
```bash
./bootstrap.sh [--force] [--skip-verify]
```

Options:
- `--force`: Reinstall even if tools exist
- `--skip-verify`: Skip post-install verification

### Module Interfaces

#### detect.sh
```bash
source lib/detect.sh
# Exports: OS_TYPE, OS_ARCH, IS_MACOS, IS_UBUNTU
```

#### utils.sh
```bash
source lib/utils.sh
log_info "message"
log_warn "message"
log_error "message"
check_command "command_name"
```

## Configuration

### Environment Variables
- `DOTFILES_DIR`: Installation directory (default: `~/.dotfiles`)
- `SKIP_BREW`: Skip Homebrew installation
- `SKIP_NVIM`: Skip Neovim configuration

### File Structure
```
~/.dotfiles/          # This repository
~/.bashrc             # Symlink to config/shell/.bashrc
~/.zshrc              # Symlink to config/shell/.zshrc
~/.config/nvim/       # Symlink to config/nvim/
~/.gitconfig          # Symlink to config/git/.gitconfig
~/.extra              # User-specific overrides (not in repo)
deprecated/           # Obsolete files from old dotfiles (not deployed)
```

## Testing Strategy
- Test on fresh macOS (Apple Silicon)
- Test on fresh Ubuntu 24 LTS (x86_64)
- Verify idempotency (run twice, no errors)
- Verify all tools functional after bootstrap
