# Product Overview

## Description
Simplified Dotfiles is a personal development-environment bootstrap repository. It installs a consistent macOS or Ubuntu workstation toolchain and deploys terminal, shell, Git, container, and developer-tool configurations from one script.

## Vision
Make a fresh laptop or test VM productive quickly, repeatably, and safely without preserving years of ad hoc dotfile drift. The repository should remain small enough to understand, modular enough to extend, and reliable enough to rerun after partial failures.

## Target Users
- **Primary:** The repository owner setting up or refreshing a macOS or Ubuntu development machine.
- **Secondary:** Engineers who want a portable reference for shell-based dotfiles bootstrapping, cross-platform tool installation, and terminal workflow configuration.

## Core Features
1. **One-command bootstrap** - `./bootstrap.sh` detects the platform, installs required tools, deploys configs, and optionally verifies the result.
2. **Cross-platform workstation setup** - Supports macOS on Apple Silicon or Intel and Ubuntu 24.04+ on x86_64 or ARM64.
3. **Idempotent installation modules** - Re-running installers should skip existing tools or repair missing pieces instead of corrupting a machine.
4. **Terminal workflow configuration** - Provides shell, Git, tmux, Zellij, and Alacritty defaults optimized for daily development.
5. **Developer toolchain provisioning** - Installs Node.js LTS through nvm, Python tooling through uv, Go, Java 17, Kubernetes tools, Terraform tooling, AWS CLI, and modern CLI utilities.
6. **Container and architecture helpers** - Provides Podman-based x86_64 helper scripts for Apple Silicon container builds and compose workflows.
7. **Verification and test support** - Includes `verify.sh`, Bats tests, and UTM setup guidance for checking bootstrap behavior.
8. **Local customization escape hatch** - Sources `~/.extra` for personal aliases, exports, and credentials that must not be committed.

## Key Value Propositions
- A production-ready development workstation can be rebuilt from source-controlled scripts instead of manual checklists.
- Platform differences are isolated behind installer modules, keeping the top-level bootstrap flow readable.
- User-specific secrets and machine-local overrides stay outside the repository.
- Terminal and CLI behavior remains consistent across machines while still allowing local overrides.
- Verification scripts make setup drift visible after bootstrap.

## Success Metrics
- **Bootstrap reliability:** `./bootstrap.sh` completes on supported macOS and Ubuntu targets without manual intervention except expected sudo prompts.
- **Verification pass rate:** `./verify.sh` reports all required tools installed after bootstrap.
- **Repeat safety:** Running bootstrap multiple times does not duplicate config, break symlinks, or reinstall tools unnecessarily.
- **Setup speed:** A fresh supported machine reaches a usable development environment in under 30 minutes, excluding network variance.
- **Configuration hygiene:** Personal credentials, machine-local overrides, and generated AI-agent files remain untracked.

## Non-Goals
- Managing production application deployments.
- Replacing OS package managers with a custom package system.
- Supporting every Linux distribution; Ubuntu 24.04+ is the Linux target.
- Tracking machine-local preferences that belong in `~/.extra`, `.tmux.local`, or Alacritty `local.toml`.
