#!/usr/bin/env zsh

# Simplified .zshrc for dotfiles bootstrap

# Fix for Homebrew completion security warning
ZSH_DISABLE_COMPFIX=true

# PATH configuration
export PATH="/usr/local/bin:$PATH"

# Homebrew (macOS Apple Silicon)
if [ -d "/opt/homebrew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# uv
export PATH="$HOME/.cargo/bin:$PATH"

# Go
export GOPATH="$HOME/go"
export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"

# Java
if [ -d "/opt/homebrew/opt/openjdk@17" ]; then
    export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
fi

# Aliases
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'

# kubectl aliases
alias k='kubectl'
alias kx='kubectx'
alias kn='kubens'

# Git aliases
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# Modern CLI tools
if command -v bat &> /dev/null; then
    alias cat='bat'
elif command -v batcat &> /dev/null; then
    alias cat='batcat'
fi

if command -v rg &> /dev/null; then
    alias grep='rg'
fi

# Source user-specific extras
if [ -f "$HOME/.extra" ]; then
    source "$HOME/.extra"
fi

# remove it if you don't use op
source /Users/john.y.huang/.config/op/plugins.sh
