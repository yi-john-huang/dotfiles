#!/usr/bin/env bash

# Simplified .bashrc for dotfiles bootstrap

# PATH configuration
export PATH="/usr/local/bin:$PATH"

# Homebrew (macOS Apple Silicon)
if [ -d "/opt/homebrew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install Homebrew cask apps at user level by default.
export HOMEBREW_CASK_APPDIR="${HOMEBREW_CASK_APPDIR:-$HOME/Applications}"
case " ${HOMEBREW_CASK_OPTS:-} " in
    *" --appdir="*|*" --appdir "*) ;;
    *) export HOMEBREW_CASK_OPTS="${HOMEBREW_CASK_OPTS:+$HOMEBREW_CASK_OPTS }--appdir=$HOMEBREW_CASK_APPDIR" ;;
esac

# nvm
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    export NVM_DIR="$HOME/.nvm"
elif [ -s "${XDG_CONFIG_HOME:-$HOME/.config}/nvm/nvm.sh" ]; then
    export NVM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvm"
else
    export NVM_DIR="$HOME/.nvm"
fi
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# uv
export PATH="$HOME/.local/bin:$PATH"

# LM Studio CLI
export PATH="$PATH:$HOME/.lmstudio/bin"

# Go
export GOPATH="$HOME/go"
export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"

# tfenv
export PATH="$HOME/.tfenv/bin:$PATH"

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

# AI agents
alias oc='opencode'
alias cc='claude'

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
