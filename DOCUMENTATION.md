# Dotfiles Documentation

This document provides a detailed explanation of all configuration files and scripts in this dotfiles repository.

## Table of Contents

1. [Installation Scripts](#installation-scripts)
2. [Shell Configuration](#shell-configuration)
3. [Editor Configuration](#editor-configuration)
4. [Git Configuration](#git-configuration)
5. [Terminal Tools](#terminal-tools)
6. [Application Settings](#application-settings)
7. [Directory Structure](#directory-structure)

---

## Installation Scripts

### bootstrap.sh
**Purpose**: Main installation script that syncs dotfiles to your home directory.

**What it does**:
- Pulls latest changes from the `main` branch
- Uses `rsync` to copy dotfiles to `~` (home directory)
- Excludes: `.git/`, `.DS_Store`, `.osx`, `bootstrap.sh`, `README.md`, `LICENSE-MIT.txt`
- Prompts for confirmation before overwriting files (unless `-f` or `--force` flag is used)
- Sources `.bash_profile` after installation

**Usage**:
```bash
source bootstrap.sh        # With confirmation prompt
set -- -f; source bootstrap.sh  # Skip confirmation
```

### brew.sh
**Purpose**: Installs Homebrew packages and command-line tools.

**What it installs**:
- GNU core utilities (coreutils, moreutils, findutils, gnu-sed)
- Modern Bash with bash-completion2
- wget with IRI support
- GnuPG for PGP-signing commits
- Updated versions of macOS tools (vim, grep, openssh, screen, php, gmp)
- Font tools (bramstein/webfonttools)

**Usage**:
```bash
./brew.sh
```

### .macos
**Purpose**: Sets sensible macOS system defaults and preferences.

**What it configures**:
- General UI/UX settings
- Keyboard and input preferences
- Screen and display settings
- Finder preferences
- Dock settings
- Safari and other app configurations
- Security and privacy settings

**Usage**:
```bash
./.macos
```

**Note**: This is a 43KB script with hundreds of macOS defaults. Review before running.

---

## Shell Configuration

### .bash_profile
**Purpose**: Main Bash configuration file loaded on login shells.

**What it does**:
- Adds `~/bin` to `$PATH`
- Sources multiple dotfiles in order: `.path`, `.bash_prompt`, `.exports`, `.aliases`, `.functions`, `.extra`
- Enables case-insensitive globbing
- Enables history appending (not overwriting)
- Enables typo correction for `cd` command
- Enables Bash 4 features: `autocd`, recursive globbing (`**`)
- Sets up tab completion for Bash, Git, SSH, defaults, and killall

**Key features**:
- Modular design - loads separate files for different purposes
- Supports custom `.path` and `.extra` files for personal customizations
- Comprehensive tab completion setup

### .bashrc
**Purpose**: Configuration for non-login interactive shells.

**What it does**:
- Simply sources `.bash_profile` if running in an interactive shell (`$PS1` is set)

### .bash_prompt
**Purpose**: Configures the shell prompt with Git integration and Solarized colors.

**Features**:
- Shows username, hostname, and current directory
- Git branch and status indicators:
  - `+` = staged changes
  - `!` = unstaged changes
  - `?` = untracked files
  - `$` = stashed files
  - `*` = Chromium/Blink repos (dirty check disabled for performance)
- Color-coded elements:
  - Red username when logged in as root
  - Red hostname when connected via SSH
  - Solarized color scheme
- Terminal title shows current directory

**Prompt format**:
```
username at hostname in /current/directory on git-branch [status]
$
```

### .exports
**Purpose**: Environment variable definitions.

**Variables set**:
- `EDITOR='vim'` - Default text editor
- `NODE_REPL_HISTORY` - Node.js REPL history file location
- `NODE_REPL_HISTORY_SIZE='32768'` - Increased history size
- `NODE_REPL_MODE='sloppy'` - Sloppy mode for Node REPL
- `PYTHONIOENCODING='UTF-8'` - Python UTF-8 encoding
- `HISTSIZE='32768'` - Bash history size (32³ entries)
- `HISTFILESIZE='32768'` - Bash history file size
- `HISTCONTROL='ignoreboth'` - Ignore duplicates and commands starting with space
- `LANG='en_US.UTF-8'` - US English with UTF-8
- `LC_ALL='en_US.UTF-8'` - Locale setting
- `MANPAGER='less -X'` - Don't clear screen after quitting man pages
- `GPG_TTY=$(tty)` - Fix for Homebrew-installed GPG
- `BASH_SILENCE_DEPRECATION_WARNING=1` - Hide zsh warning on macOS

### .aliases
**Purpose**: Command shortcuts and aliases.

**Navigation aliases**:
- `..`, `...`, `....`, `.....` - Navigate up directories
- `-` - Go to previous directory
- `d`, `dl`, `dt`, `p` - Quick access to common directories

**ls aliases**:
- `l` - Long format with colors
- `la` - Long format including hidden files
- `lsd` - List only directories
- Color support for both GNU and macOS `ls`

**Utility aliases**:
- `g` - Git shortcut
- `grep`, `fgrep`, `egrep` - Always use color
- `week` - Get week number
- `update` - Update macOS, Homebrew, npm, and Ruby gems
- `ip`, `localip`, `ips` - Get IP addresses
- `flush` - Flush DNS cache
- `cleanup` - Delete `.DS_Store` files recursively
- `emptytrash` - Empty all trash and clear logs

**macOS-specific aliases**:
- `show`/`hide` - Toggle hidden files in Finder
- `hidedesktop`/`showdesktop` - Toggle desktop icons
- `chrome`, `canary` - Launch Chrome from command line
- `spotoff`/`spoton` - Disable/enable Spotlight
- `afk` - Lock screen

**Developer aliases**:
- `GET`, `HEAD`, `POST`, `PUT`, `DELETE`, etc. - HTTP method shortcuts
- `chromekill` - Kill Chrome tabs to free memory
- `c` - Trim newlines and copy to clipboard
- `urlencode` - URL-encode strings
- `mergepdf` - Merge PDF files

### .functions
**Purpose**: Custom Bash functions for common tasks.

**Key functions**:

- `mkd()` - Create directory and cd into it
- `cdf()` - cd to frontmost Finder window location
- `targz()` - Create .tar.gz archive with optimal compression
- `fs()` - Calculate file/directory size
- `diff()` - Use Git's colored diff
- `dataurl()` - Create data URL from file
- `server()` - Start HTTP server (Python SimpleHTTPServer)
- `phpserver()` - Start PHP server
- `gz()` - Compare original and gzipped file sizes
- `digga()` - Run dig with useful output
- `getcertnames()` - Show SSL certificate names for domain
- `o()` - Open current directory or specified location
- `tre()` - Tree command with sensible defaults

---

## Editor Configuration

### .vimrc
**Purpose**: Vim editor configuration.

**Key settings**:
- Solarized Dark color scheme
- Uses OS clipboard by default
- UTF-8 encoding without BOM
- Line numbers and relative line numbers
- Syntax highlighting and current line highlighting
- 2-space tabs
- Shows invisible characters (tabs, trailing spaces, EOL)
- Centralized backups, swaps, and undo files in `~/.vim/`
- Mouse support in all modes
- Smart search (incremental, case-insensitive, highlighted)

**Custom mappings**:
- `,ss` - Strip trailing whitespace
- `,W` - Save file as root

**File type handling**:
- `.json` files treated as JavaScript
- `.md` files treated as Markdown

### .gvimrc
**Purpose**: GUI Vim (MacVim/gVim) specific settings.

**Settings**:
- Solarized Dark theme
- 14pt Monaco font
- Non-blinking cursor in normal mode
- Increased line spacing (8pt)

### .vim/ directory
**Structure**:
- `backups/` - Backup files location
- `swaps/` - Swap files location
- `undo/` - Undo history files
- `colors/solarized.vim` - Solarized color scheme
- `syntax/json.vim` - JSON syntax highlighting

### .editorconfig
**Purpose**: Cross-editor configuration (works with EditorConfig plugin).

**Settings**:
- UTF-8 charset
- Tab indentation
- LF line endings
- Insert final newline
- Trim trailing whitespace

---

## Git Configuration

### .gitconfig
**Purpose**: Git global configuration.

**Aliases** (shortcuts):
- `l` - Pretty log with graph (last 20 commits)
- `s` - Short status
- `d` - Diff with stats
- `di` - Diff N revisions ago
- `p` - Pull with submodules
- `c` - Clone recursively
- `ca` - Commit all changes
- `go` - Switch to branch (create if needed)
- `amend` - Amend last commit
- `reb` - Interactive rebase
- `dm` - Delete merged branches
- `fb` - Find branches containing commit
- `fc` - Find commits by source code
- `fm` - Find commits by message

**Core settings**:
- Custom `.gitignore` and `.gitattributes`
- Whitespace error detection
- Untracked cache enabled for performance
- Colored output

**Commit settings**:
- GPG signing enabled

**URL shorthands**:
- `gh:` → `git@github.com:`
- `github:` → `git://github.com/`
- `gst:` → `git@gist.github.com:`

**Default branch**: `main`

### .gitignore
**Purpose**: Global Git ignore patterns.

**Ignores**:
- `*.pyc` - Compiled Python files
- `.DS_Store`, `Desktop.ini` - Folder view configs
- `._*`, `Thumbs.db` - Thumbnail caches
- `.Spotlight-V100`, `.Trashes` - External disk files

### .gitattributes
**Purpose**: Git attributes configuration.

**Note**: Line ending normalization is disabled due to issues.

### .hgignore
**Purpose**: Mercurial ignore patterns (similar to .gitignore).

---

## Terminal Tools

### .inputrc
**Purpose**: Readline library configuration (affects Bash input).

**Features**:
- Case-insensitive tab completion
- Show all matches if ambiguous
- Trailing slash for symlinked directories
- Up/Down arrows search history based on typed prefix
- Don't autocomplete hidden files unless pattern starts with dot
- Show all completions at once (no paging)
- Show file type indicators (like `ls -F`)
- Smart completion (considers text after cursor)
- UTF-8 input/output support
- Alt+Delete to delete preceding word

### .tmux.conf
**Purpose**: tmux terminal multiplexer configuration.

**Settings**:
- Prefix key: `Ctrl+A` (instead of default `Ctrl+B`)
- Vim-style keybindings
- `Ctrl+A R` to reload config

### .screenrc
**Purpose**: GNU Screen configuration.

**Settings**:
- Disable startup message
- Large scrollback buffer (32,000 lines)
- UTF-8 enabled by default

### .curlrc
**Purpose**: curl default options.

**Settings**:
- User agent: IE 9 on Windows 7
- Auto-set referer on redirects
- 60-second connection timeout

### .wgetrc
**Purpose**: wget default options.

**Settings**:
- Use server timestamps
- Don't traverse parent directories
- 60-second timeout
- 3 retry attempts
- Follow redirects and FTP links
- Add file extensions automatically
- Ignore robots.txt
- User agent: IE 9 on Windows 7

### .gdbinit
**Purpose**: GDB debugger configuration.

**Settings**:
- Intel disassembly flavor

### .hushlogin
**Purpose**: Suppress login messages.

**Effect**: Disables copyright notice, last login time, and MOTD on login.

---

## Application Settings

### init/ directory
**Purpose**: Application-specific configuration files.

**Files**:

1. **Preferences.sublime-settings**
   - Sublime Text editor preferences

2. **spectacle.json**
   - Spectacle window manager shortcuts

3. **Solarized Dark xterm-256color.terminal**
   - macOS Terminal.app color scheme

4. **Solarized Dark.itermcolors**
   - iTerm2 color scheme

### bin/ directory
**Purpose**: Custom executable scripts.

**Files**:
- `subl` - Symlink to Sublime Text command-line tool

---

## Directory Structure

```
dotfiles/
├── .bash_profile          # Main Bash config
├── .bashrc                # Non-login shell config
├── .bash_prompt           # Custom prompt with Git
├── .aliases               # Command aliases
├── .functions             # Custom functions
├── .exports               # Environment variables
├── .vimrc                 # Vim configuration
├── .gvimrc                # GUI Vim configuration
├── .gitconfig             # Git configuration
├── .gitignore             # Global Git ignores
├── .gitattributes         # Git attributes
├── .hgignore              # Mercurial ignores
├── .inputrc               # Readline configuration
├── .tmux.conf             # tmux configuration
├── .screenrc              # GNU Screen configuration
├── .curlrc                # curl defaults
├── .wgetrc                # wget defaults
├── .editorconfig          # Cross-editor config
├── .gdbinit               # GDB configuration
├── .hushlogin             # Suppress login messages
├── bootstrap.sh           # Installation script
├── brew.sh                # Homebrew packages installer
├── .macos                 # macOS defaults script
├── README.md              # Repository documentation
├── LICENSE-MIT.txt        # MIT License
├── .vim/                  # Vim runtime files
│   ├── backups/           # Backup files
│   ├── swaps/             # Swap files
│   ├── undo/              # Undo history
│   ├── colors/            # Color schemes
│   └── syntax/            # Syntax files
├── init/                  # Application configs
│   ├── Preferences.sublime-settings
│   ├── spectacle.json
│   ├── Solarized Dark xterm-256color.terminal
│   └── Solarized Dark.itermcolors
└── bin/                   # Custom executables
    └── subl               # Sublime Text CLI

```

---

## Customization

### Adding Personal Settings

Create these optional files in your home directory:

1. **~/.extra**
   - Personal settings you don't want to commit
   - Git credentials
   - Private aliases/functions
   - Overrides for existing settings

2. **~/.path**
   - Custom PATH additions
   - Sourced before feature detection

Example `~/.extra`:
```bash
# Git credentials
GIT_AUTHOR_NAME="Your Name"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
git config --global user.name "$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="your@email.com"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
git config --global user.email "$GIT_AUTHOR_EMAIL"
```

Example `~/.path`:
```bash
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
```

---

## Installation Order

Recommended setup sequence:

1. Clone repository
2. Review and customize files
3. Run `./brew.sh` to install Homebrew packages
4. Run `source bootstrap.sh` to install dotfiles
5. Run `./.macos` to set macOS defaults (optional)
6. Create `~/.extra` for personal settings
7. Restart terminal or run `source ~/.bash_profile`

---

## Dependencies

- **macOS**: Most scripts are macOS-specific
- **Homebrew**: Required for `brew.sh`
- **Bash 4+**: For advanced features (autocd, globstar)
- **Git**: For version control and some functions
- **Vim**: For editor configuration

---

## Notes

- This is a fork/adaptation of Mathias Bynens' dotfiles
- Always review scripts before running them
- Backup existing dotfiles before installation
- Some settings require logout/restart to take effect
- The `.macos` script makes extensive system changes - review carefully

---

## Maintenance

To update dotfiles:

```bash
cd ~/dotfiles
git pull origin main
source bootstrap.sh
```

To update Homebrew packages:

```bash
./brew.sh
```

Or use the `update` alias which updates everything:

```bash
update
```

---

## Troubleshooting

**Bash completion not working**:
- Ensure Homebrew bash-completion2 is installed
- Check that `$(brew --prefix)/etc/profile.d/bash_completion.sh` exists

**Colors not displaying correctly**:
- Ensure terminal supports 256 colors
- Install Solarized color scheme from `init/` directory

**Git aliases not working**:
- Run `git config --list` to verify settings
- Ensure `.gitconfig` was copied to `~/.gitconfig`

**Permission errors**:
- Some scripts require sudo access
- Ensure you have admin privileges on macOS
