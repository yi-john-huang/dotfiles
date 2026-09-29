# Technology Overview

## Stack

### Language and Runtime
- **Primary language:** Bash shell scripting.
- **Runtime:** macOS Bash-compatible shell and Ubuntu Bash with standard Unix utilities.
- **Configuration languages:** Lua for Neovim, TOML for Alacritty, KDL for Zellij, tmux and Git config syntax, and shell rc files.
- **Supported operating systems:** macOS 11+ and Ubuntu 24.04 LTS or later.
- **Supported architectures:** Apple Silicon/ARM64, Intel/x86_64, and Ubuntu ARM64/x86_64. Platform detection normalizes `x86_64`/`amd64` and `aarch64`/`arm64`.

### Package and Tool Managers
- **Homebrew:** macOS package and cask installation.
- **apt:** Ubuntu package installation.
- **nvm:** Node.js LTS installation and activation.
- **uv:** Python package management.
- **tfenv:** Terraform version management.
- **Podman:** macOS container runtime and x86_64 emulation helper workflows.
- **Docker CE:** Ubuntu container runtime with buildx.

### Installed Tool Categories
| Category | Tools | Purpose |
|----------|-------|---------|
| Terminal apps | iTerm2, Alacritty | Terminal emulator options on macOS and Linux. |
| Shell and terminal workflow | tmux, Zellij, JetBrainsMono Nerd Font | Multiplexing, sessions, pane navigation, and consistent font rendering. |
| Modern CLI utilities | jq, yq, ripgrep, fd, bat, LazyGit | Structured data, search, file inspection, and Git workflows. |
| Daily editor | Neovim 0.11.2+, LazyVim, tree-sitter CLI | Editing, LSP, completion, formatting, debugging, Git, terminal, and session workflows. |
| Kubernetes | kubectl, kubectx, kubens, k9s, Helm | Cluster access, context switching, inspection, and package management. |
| Infrastructure | tfenv, Terraform, AWS CLI | Infrastructure-as-code and cloud workflows. |
| Language runtimes | Node.js LTS, uv, Go, OpenJDK 21 | Application stacks and the Java 21 runtime required by Eclipse JDT LS. |
| Containers | Podman, podman-compose, Docker CE, Docker buildx | Local container builds and compose workflows. |
| AI CLI shortcuts | OpenCode, Claude Code, LM Studio CLI path | Optional local AI tooling integration without making those tools required. |

## Architecture

### Pattern
A modular shell-bootstrap pipeline:

```text
bootstrap.sh
  -> lib/detect.sh
  -> lib/utils.sh
  -> install/macos.sh or install/ubuntu.sh
  -> install/common.sh
  -> install/dev-tools.sh
  -> deploy_configs
  -> verify.sh
```

### Layers
```text
Entry point
  bootstrap.sh, verify.sh, fix-binaries.sh, setup-utm-ubuntu.sh

Platform detection and helpers
  lib/detect.sh, lib/utils.sh, lib/podman-utils.sh

Install modules
  install/macos.sh, install/ubuntu.sh, install/common.sh, install/dev-tools.sh

Configuration payloads
  config/shell, config/git, config/tmux, config/zellij, config/alacritty, config/nvim

Validation and test harness
  verify.sh, tests/*.bats, scripts/x86-*.sh, setup-utm-ubuntu.sh
```

### Bootstrap Flow
1. Resolve the repository root from the script location.
2. Source platform detection and logging/helper libraries.
3. Parse flags such as `--force` and `--skip-verify`.
4. Configure Homebrew cask defaults on macOS.
5. Run platform-specific installation for macOS or Ubuntu.
6. Install common cross-platform CLI tools.
7. Install development runtimes and language tooling.
8. Deploy dotfile configurations.
9. Initialize shell frameworks that depend on deployed config, including Zim.
10. Run verification unless explicitly skipped.

### Configuration Deployment
- Shell files are copied to `~/.bashrc`, `~/.zshrc`, and `~/.zimrc`; `EDITOR` and `VISUAL` default to Neovim, while `~/.extra` remains the later override.
- tmux, Alacritty, Zellij, Neovim, and the global Git ignore file are symlinked from the repository.
- Neovim is linked as `${XDG_CONFIG_HOME:-$HOME/.config}/nvim`. Any unmanaged file, directory, symlink, or broken symlink is moved to `nvim.backup`; deployment aborts if that backup already exists.
- Git config is included from `~/.gitconfig` using `include.path` instead of replacing the whole user config.
- Existing non-symlink user files are backed up before replacement.
- User-specific customizations belong in `~/.extra`, `.tmux.local`, or `config/alacritty/local.toml`; tracked Neovim behavior belongs under `config/nvim/`.

## Development Environment

### Prerequisites
- Git.
- Bash.
- Network access to package registries and release downloads.
- macOS: Command Line Tools and Homebrew installation permission.
- Ubuntu: sudo access and apt package repositories.
- Optional test tools: bats-core, UTM, Podman.

### Setup
```bash
# Clone and enter the repository
git clone git@gitlab.gogoro.com:john.y.huang/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Bootstrap the machine
./bootstrap.sh

# Verify the installation
./verify.sh
```

### Common Commands
| Command | Purpose |
|---------|---------|
| `./bootstrap.sh` | Full platform detection, installation, configuration deployment, and verification. |
| `./bootstrap.sh --force` | Force reinstall path where modules honor the flag. |
| `./bootstrap.sh --skip-verify` | Run installation and config deployment without final verification. |
| `./verify.sh` | Validate required tools and selected platform capabilities. |
| `bats tests/` | Run Bats test suite. |
| `nvim --headless "+Lazy! sync" +qa` | Install or restore the plugin commits tracked in `config/nvim/lazy-lock.json`. |
| `nvim --headless "+checkhealth lazyvim" +qa` | Exercise LazyVim startup and provider health without the UI. |
| `./fix-binaries.sh` | Remove and reinstall architecture-sensitive binaries after binary-format errors. |
| `./setup-utm-ubuntu.sh` | Prepare Ubuntu 24.04 UTM test instructions and ISO download. |
| `./scripts/x86-start.sh` | Start and verify the Podman x86_64 machine. |
| `./scripts/x86-build.sh -t image:x86 .` | Build an amd64 image through Podman. |
| `./scripts/x86-compose.sh up` | Run compose with `DOCKER_DEFAULT_PLATFORM=linux/amd64`. |
| `./scripts/x86-stop.sh` | Stop the x86_64 Podman machine. |

## Quality Standards
- Use Bats tests for shell modules and architecture-sensitive checks.
- Run `bats tests/` after changing installer functions, platform detection, or helper libraries.
- Run `./verify.sh` after changing installed tool lists, PATH setup, or deployment behavior when the local machine can exercise the affected path.
- Run a headless LazyVim sync and health check after changing `config/nvim/`; exercise an attached LSP and formatter when changing language extras.
- Keep installers idempotent: check for an existing tool/config before installing or replacing it.
- Keep platform-specific logic in `install/macos.sh` or `install/ubuntu.sh`; shared behavior belongs in `install/common.sh`, `install/dev-tools.sh`, or `lib/`.
- Prefer explicit failure with `log_error` over silent fallback when a required tool cannot be installed.
- Do not commit credentials, personal Git identity changes, local cask appdir overrides, `.tmux.local`, Alacritty `local.toml`, or generated AI-agent components outside `.spec/steering/`.
