# Migration Guide

Guide for migrating from the old dotfiles structure to the simplified bootstrap system.

## What Changed

### Structure Simplification

**Old Structure:**
```
.
├── .bashrc, .bash_profile, .bash_prompt
├── .exports, .functions, .aliases
├── .vimrc, .vim/
├── brew.sh, bootstrap.sh, .macos
└── Various scattered configs
```

**New Structure:**
```
.
├── bootstrap.sh (single entry point)
├── lib/ (utilities)
├── install/ (modular installers)
├── config/ (organized configs)
└── deprecated/ (old files)
```

### Key Improvements

1. **Single Command Setup**: `./bootstrap.sh` does everything
2. **Modular Design**: Separate scripts for each concern
3. **Cross-Platform**: Works on macOS and Ubuntu
4. **Idempotent**: Safe to run multiple times
5. **Test Coverage**: TDD approach with bats tests

## Migration Steps

### 1. Backup Current Setup

```bash
# Backup your current dotfiles
cp ~/.bashrc ~/.bashrc.old
cp ~/.zshrc ~/.zshrc.old
cp ~/.gitconfig ~/.gitconfig.old
cp -r ~/.config/nvim ~/.config/nvim.old
```

### 2. Save Custom Configurations

Extract any custom settings from your old dotfiles:

```bash
# Review your old configs
cat ~/.bashrc.old
cat ~/.exports
cat ~/.aliases
cat ~/.functions
```

### 3. Create ~/.extra File

Put your custom settings in `~/.extra`:

```bash
# ~/.extra
# This file is sourced by .bashrc and .zshrc

# Custom environment variables
export MY_CUSTOM_VAR="value"

# Custom aliases
alias myproject="cd ~/projects/myproject"

# Custom functions
function myfunction() {
    echo "Custom function"
}

# Git user config (not in repo)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 4. Run New Bootstrap

```bash
cd ~/.dotfiles
./bootstrap.sh
```

The bootstrap will:
- Preserve an unmanaged Neovim file, directory, symlink, or broken symlink as `${XDG_CONFIG_HOME:-$HOME/.config}/nvim.backup`.
- Stop without changing either path if both `nvim` and `nvim.backup` already exist.
- Link the tracked `config/nvim/` directory into the XDG config directory.
- Set `EDITOR` and `VISUAL` to `nvim`; a later `~/.extra` can override them.
- Install tools, start the LazyVim/Mason first-run bootstrap, and verify installations.

### 5. Verify Migration

```bash
# Check installations
./verify.sh

# Confirm the managed Neovim link
test "$(readlink "${XDG_CONFIG_HOME:-$HOME/.config}/nvim")" = "$PWD/config/nvim"

# Install locked plugins after the first bootstrap
nvim --headless "+Lazy! sync" +qa

# Test shell
source ~/.bashrc  # or ~/.zshrc

# Verify custom settings
echo $MY_CUSTOM_VAR

# Test aliases
myproject
```

## Common Customizations

### Shell Aliases

**Old way** (in `.aliases`):
```bash
alias ll='ls -lah'
```

**New way** (in `~/.extra`):
```bash
alias ll='ls -lah'
alias myalias='my command'
```

### Environment Variables

**Old way** (in `.exports`):
```bash
export EDITOR='vim'
```

**New way** (in `~/.extra`):
```bash
export EDITOR='nvim'
export MY_VAR='value'
```

### Custom Functions

**Old way** (in `.functions`):
```bash
function mkd() {
    mkdir -p "$@" && cd "$@"
}
```

**New way** (in `~/.extra`):
```bash
function mkd() {
    mkdir -p "$@" && cd "$@"
}
```

### Git Configuration

**Old way** (in `.gitconfig`):
```ini
[user]
    name = Your Name
    email = your.email@example.com
```

**New way** (in `~/.extra`):
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## Tool Changes

### Replaced Tools

| Old | New | Reason |
|-----|-----|--------|
| vim | Neovim | Modern, better LSP support |
| tmux | zellij | Simpler, better defaults |
| grep | ripgrep | Faster, better output |
| cat | bat | Syntax highlighting |

### New Tools

- **uv**: Modern Python package manager
- **k9s**: Kubernetes TUI
- **kubectx/kubens**: Kubernetes context switching

## Rollback

The bootstrap preserves one Neovim rollback point. Remove only the managed link, then restore the backup:

```bash
nvim_target="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
test -L "$nvim_target"
rm "$nvim_target"
mv "${nvim_target}.backup" "$nvim_target"
```

Restore shell or Git backups separately only when those files were migrated:

```bash
mv ~/.bashrc.backup ~/.bashrc
mv ~/.zshrc.backup ~/.zshrc
mv ~/.gitconfig.backup ~/.gitconfig
```

Never delete `nvim.backup` to make bootstrap proceed without first inspecting and reconciling its contents.

## Troubleshooting

### Missing Custom Aliases

**Problem**: My custom aliases don't work

**Solution**: Add them to `~/.extra`

### Tool Not Found

**Problem**: Command not found after bootstrap

**Solution**: 
```bash
# Restart shell
exec $SHELL

# Or re-run bootstrap
./bootstrap.sh
```

### Git User Not Set

**Problem**: Git asks for user name/email

**Solution**: Set in `~/.extra`:
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Neovim Plugins or Language Tools Not Loading

**Problem**: Neovim plugins, language servers, formatters, or debuggers are unavailable.

**Solution**:

```bash
# Restore the tracked plugin state.
nvim --headless "+Lazy! sync" +qa

# Verify the workstation dependencies.
./verify.sh
```

Inside Neovim, inspect `:Lazy`, `:Mason`, `:LspInfo`, `:checkhealth lazyvim`, and `:checkhealth`. The first LazyVim and Mason bootstrap requires network access. Retry the failing manager after connectivity returns; do not replace the tracked config with the deprecated one.

## Getting Help

1. Check [README.md](README.md) for basic usage
2. Review `deprecated/` folder for old configs
3. Run `./verify.sh` to check installations
4. Open an issue on GitHub

## FAQ

**Q: Can I keep my old dotfiles?**  
A: Yes, they're in `deprecated/` folder for reference.

**Q: How do I add new tools?**  
A: Edit the appropriate installer in `install/` directory.

**Q: Can I customize the bootstrap?**  
A: Yes, modify scripts in `install/` or add to `~/.extra`.

**Q: Is this compatible with my existing setup?**  
A: Bootstrap backs up existing configs before making changes.

**Q: How do I update?**  
A: `git pull && ./bootstrap.sh`
