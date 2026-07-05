#!/usr/bin/env bash

# Shell Framework Installation Module
# Installs and initializes interactive shell frameworks used by deployed configs.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "${SCRIPT_DIR}/.." && pwd)}"
source "${DOTFILES_DIR}/lib/utils.sh"

get_zim_home() {
    local zdotdir="${ZDOTDIR:-$HOME}"
    echo "${ZIM_HOME:-${zdotdir}/.zim}"
}

get_zim_config_file() {
    local zdotdir="${ZDOTDIR:-$HOME}"
    echo "${ZIM_CONFIG_FILE:-${zdotdir}/.zimrc}"
}

run_zimfw() {
    local zimfw=$1
    shift

    ZIM_HOME="$(get_zim_home)" \
    ZIM_CONFIG_FILE="$(get_zim_config_file)" \
        zsh -c 'source "$1" "${@:2}"' zimfw "$zimfw" "$@"
}

install_zim() {
    local zim_home zimfw zimrc repo_zimrc zimfw_url
    zim_home="$(get_zim_home)"
    zimfw="${zim_home}/zimfw.zsh"
    zimrc="$(get_zim_config_file)"
    repo_zimrc="${DOTFILES_DIR}/config/shell/.zimrc"
    zimfw_url="${ZIMFW_URL:-https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh}"

    if ! check_command zsh; then
        log_warn "zsh not found; skipping Zim framework initialization"
        return 1
    fi

    mkdir -p "$zim_home"

    if [ ! -s "$zimfw" ]; then
        log_info "Installing Zim framework manager..."
        if ! curl -fsSL "$zimfw_url" -o "$zimfw"; then
            log_warn "Failed to download Zim framework manager"
            return 1
        fi
    fi

    if [ ! -s "$zimrc" ]; then
        if [ ! -f "$repo_zimrc" ]; then
            log_warn "Missing Zim config template: $repo_zimrc"
            return 1
        fi
        cp -f "$repo_zimrc" "$zimrc"
    fi

    if [ ! -s "${zim_home}/init.zsh" ] || [ "$zimrc" -nt "${zim_home}/init.zsh" ] || [ "$zimfw" -nt "${zim_home}/init.zsh" ]; then
        log_info "Initializing Zim framework..."
        if ! run_zimfw "$zimfw" install; then
            log_warn "Zim module installation failed"
            return 1
        fi
        if ! run_zimfw "$zimfw" init -q; then
            log_warn "Zim init generation failed"
            return 1
        fi
    else
        log_info "✓ Zim framework already initialized"
    fi

    if [ ! -s "${zim_home}/init.zsh" ]; then
        log_warn "Zim init file was not created at ${zim_home}/init.zsh"
        return 1
    fi

    log_info "✓ Zim framework initialized"
}

install_shell_frameworks() {
    local failed=0

    install_zim || ((failed+=1))

    if [ "$failed" -eq 0 ]; then
        log_info "✓ Shell frameworks initialized"
    else
        log_warn "Shell framework initialization completed with $failed failures"
        return 1
    fi
}
