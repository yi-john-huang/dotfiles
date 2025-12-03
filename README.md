# Simplified Dotfiles

A streamlined, all-in-one dotfiles system with automated bootstrap for quick laptop setup.

## Features

- **One Command Setup**: Get production-ready in under 30 minutes
- **Cross-Platform**: Supports macOS (Apple Silicon) and Ubuntu 24 LTS (x86_64)
- **Idempotent**: Safe to run multiple times
- **Comprehensive**: Installs all development tools and configurations
- **Customizable**: Use `~/.extra` for personal overrides

## Quick Start

```bash
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

## What Gets Installed

### Platform-Specific Tools

**macOS:**

- Homebrew (package manager)
- iTerm2 (terminal)
- Colima (container runtime)

**Ubuntu:**

- build-essential
- System packages (curl, wget, git, etc.)

### Common CLI Tools

- jq, yq (JSON/YAML processors)
- ripgrep, bat (modern grep/cat)
- zellij (terminal multiplexer)
- kubectl, kubectx, k9s (Kubernetes tools)
- Terraform (infrastructure as code)

### Development Tools

- **Node.js/TypeScript**: nvm + latest LTS
- **Python**: uv package manager
- **Go**: Latest stable
- **Java**: OpenJDK 17

### Configurations

- **Shell**: .bashrc and .zshrc with aliases and PATH
- **Git**: .gitconfig (included via `~/.gitconfig`) with aliases and .gitignore_global

## Usage

### Basic Installation

### Platform-Specific Tools

**macOS:**

- Homebrew (package manager)
- iTerm2 (terminal)
- Colima (container runtime)

**Ubuntu:**

- build-essential
- System packages (curl, wget, git, etc.)

### Common CLI Tools

- jq, yq (JSON/YAML processors)
- ripgrep, bat (modern grep/cat)
- zellij (terminal multiplexer)
- kubectl, kubectx, k9s (Kubernetes tools)
- Terraform (infrastructure as code)

### Development Tools

- **Node.js/TypeScript**: nvm + latest LTS
- **Python**: uv package manager
- **Go**: Latest stable
- **Java**: OpenJDK 17

### Configurations

- **Shell**: .bashrc and .zshrc with aliases and PATH
- **Git**: .gitconfig (included via `~/.gitconfig`) with aliases and .gitignore_global

## Usage

### Basic Installation

### Platform-Specific Tools

**macOS:**
- Homebrew (package manager)
- iTerm2 (terminal)
- Colima (container runtime)

**Ubuntu:**
- build-essential
- System packages (curl, wget, git, etc.)

### Common CLI Tools
- jq, yq (JSON/YAML processors)
- ripgrep, bat (modern grep/cat)
- zellij (terminal multiplexer)
- kubectl, kubectx, k9s (Kubernetes tools)
- Terraform (infrastructure as code)

### Development Tools
- **Node.js/TypeScript**: nvm + latest LTS
- **Python**: uv package manager
- **Go**: Latest stable
- **Java**: OpenJDK 17

### Configurations
- **Shell**: .bashrc and .zshrc with aliases and PATH
- **Git**: .gitconfig with aliases and .gitignore_global

## Usage

### Basic Installation
```bash
./bootstrap.sh
```

### Force Reinstall

```bash
./bootstrap.sh --force
```

### Skip Verification

```bash
./bootstrap.sh --skip-verify
```

### Verify Installation

```bash
./verify.sh
```

## Architecture

```
.
├── bootstrap.sh          # Main entry point
├── verify.sh            # Verification script
├── lib/                 # Core utilities
│   ├── detect.sh       # Platform detection
│   └── utils.sh        # Logging and helpers
├── install/            # Installation modules
│   ├── macos.sh       # macOS-specific
│   ├── ubuntu.sh      # Ubuntu-specific
│   ├── common.sh      # Cross-platform tools
│   └── dev-tools.sh   # Language runtimes
├── config/            # Configuration files
│   ├── shell/        # .bashrc, .zshrc
│   └── git/          # Git config
├── tests/            # Test files (bats)
└── deprecated/       # Old dotfiles (reference only)
```

## Customization

### User-Specific Settings

Create `~/.extra` for personal configurations:

```bash
# Example ~/.extra
export CUSTOM_VAR="value"
alias myalias="command"

# Git credentials
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

This file is sourced by shell configs but not tracked in the repository.

## Requirements

### macOS

- macOS 11+ (Big Sur or later)
- Apple Silicon (ARM64) or Intel (x86_64)
- Command Line Tools (installed automatically)

### Ubuntu

- Ubuntu 24.04 LTS
- x86_64 architecture
- sudo access

## Testing

Tests use [bats-core](https://github.com/bats-core/bats-core):

```bash
# Install bats (macOS)
brew install bats-core

# Install bats (Ubuntu)
sudo apt-get install bats

# Run tests
bats tests/
```

### Testing on UTM (Ubuntu Emulation)

For testing on Ubuntu without a physical machine, use UTM:

```bash
# Run the UTM setup script
./setup-utm-ubuntu.sh

# Follow the printed instructions to:
# 1. Create VM in UTM with 2 CPUs, 4GB RAM, 40GB storage
# 2. Install Ubuntu 24 LTS from downloaded ISO
# 3. Test dotfiles bootstrap in the VM
```

The script will:

- Download Ubuntu 24.04 LTS ISO
- Provide step-by-step VM creation instructions
- Configure VM with optimal settings for testing

## Troubleshooting

### Homebrew Installation Fails (macOS)

```bash
# Install Command Line Tools manually
xcode-select --install
```

### Permission Denied Errors (Ubuntu)

```bash
# Ensure you have sudo access
sudo -v
```

### Tool Not Found After Installation

```bash
# Restart your shell
exec $SHELL

# Or source the config
source ~/.bashrc  # or ~/.zshrc
```

## Migration from Old Dotfiles

See [MIGRATION.md](MIGRATION.md) for detailed migration guide.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on both macOS and Ubuntu
5. Submit a pull request

## License

MIT License - see [LICENSE-MIT.txt](LICENSE-MIT.txt)

## Credits

Original dotfiles structure inspired by [Mathias Bynens](https://github.com/mathiasbynens/dotfiles).

Simplified and modernized for 2025+ development workflows.
