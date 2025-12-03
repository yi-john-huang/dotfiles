# Deprecated Files

This folder contains obsolete files from the original dotfiles that are no longer used in the simplified bootstrap system.

## Purpose
- Keep old configurations for reference
- Maintain history without cluttering new structure
- Allow easy rollback if needed

## Contents Moved During Refactoring

### Old Bootstrap Scripts
- `bootstrap.sh` - Original bootstrap (replaced by new modular version)
- `brew.sh` - Homebrew installation script (now in install/macos.sh)
- `.macos` - macOS defaults script (out of scope for MVP)

### Shell Configuration Files
- `.bashrc`, `.bash_profile`, `.bash_prompt` - Old bash configs (replaced by config/shell/)
- `.exports`, `.functions`, `.aliases` - Shell utilities (consolidated in config/shell/)
- `shell/` - Old shell directory
- `scripts/` - Old scripts directory

### Legacy Tool Configurations
- `.wgetrc`, `.curlrc` - wget/curl configs (not needed)
- `.tmux.conf` - tmux config (not in scope)
- `.vimrc`, `.gvimrc` - vim configs (using Neovim now)
- `.screenrc` - screen config (using zellij)
- `.inputrc` - readline config (not needed)
- `.hgignore` - Mercurial ignore (using git only)
- `.gdbinit` - GDB config (not needed)
- `.hushlogin` - Login message suppression (not needed)

### Directories
- `.vim/` - Vim plugins/config (using Neovim)
- `bin/` - Old bin directory
- `init/` - Old initialization files (Sublime, Spectacle, iTerm colors)

## Note
These files are NOT deployed by the bootstrap script.
