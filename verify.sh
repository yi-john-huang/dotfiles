#!/usr/bin/env bash

# Verification Script
# Validates all tool installations

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"
source "${SCRIPT_DIR}/lib/detect.sh"

# Load tool paths without sourcing interactive shell configs.
if [ -d "/opt/homebrew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/.lmstudio/bin"
export GOPATH="$HOME/go"
export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"
export PATH="$HOME/.tfenv/bin:$PATH"

if [ -s "$HOME/.nvm/nvm.sh" ]; then
    export NVM_DIR="$HOME/.nvm"
elif [ -s "${XDG_CONFIG_HOME:-$HOME/.config}/nvm/nvm.sh" ]; then
    export NVM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvm"
fi

if [ -n "${NVM_DIR:-}" ]; then
    set +u
    source "$NVM_DIR/nvm.sh"
    set -u
fi

if [ -d "/opt/homebrew/opt/openjdk@21" ]; then
    export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"
fi

# Track results
PASSED=0
FAILED=0
FAILED_TOOLS=()

# Check tool installation
check_tool() {
    local tool=$1
    local display_name=${2:-$tool}
    
    # Debug log
    # echo "DEBUG: Checking $tool..."
    
    if check_command "$tool"; then
        local version=""
        
        # Temporarily disable exit on error for version checks
        set +e
        
        case "$tool" in
            tmux)
                version=$("$tool" -V 2>&1 | head -n1)
                ;;
            zellij)
                version=$("$tool" --version 2>&1 | head -n1)
                ;;
            alacritty)
                version=$("$tool" -V 2>&1 | head -n1)
                ;;
            kubectl)
                version=$("$tool" version --client 2>&1 | head -n1)
                ;;
            kubectx|kubens)
                version="installed"
                ;;
            k9s)
                version=$("$tool" version -s 2>&1 | head -n1)
                ;;
            helm)
                version=$("$tool" version --short 2>&1 | head -n1)
                ;;
            go)
                version=$("$tool" version 2>&1 | head -n1)
                ;;
            java)
                version=$("$tool" -version 2>&1 | head -n1)
                ;;
            *)
                version=$("$tool" --version 2>&1 | head -n1)
                ;;
        esac

        if [ -z "$version" ] || [[ "$version" == error:* ]] || [[ "$version" == Error:* ]] || [[ "$version" == *"unknown option"* ]] || [[ "$version" == *"unknown flag"* ]]; then
            version="installed"
        fi
        
        # Re-enable exit on error
        set -e
        
        log_info "✓ $display_name: $version"
        ((PASSED+=1))
        return 0
    else
        log_error "✗ $display_name: not found"
        FAILED_TOOLS+=("$display_name")
        ((FAILED+=1))
        # Return 0 so the script continues (we track failures in FAILED variable)
        return 0
    fi
}

check_neovim() {
    local first_line=""
    local version=""

    if check_command nvim; then
        first_line="$(nvim --version 2>&1 | sed -n '1p')"
        version="$(nvim_version)"
    fi

    if version_at_least "$version" "$NEOVIM_MIN_VERSION"; then
        log_info "✓ Neovim: $first_line"
        ((PASSED+=1))
    else
        log_error "✗ Neovim >= ${NEOVIM_MIN_VERSION}: ${first_line:-not found}"
        FAILED_TOOLS+=("Neovim >= ${NEOVIM_MIN_VERSION}")
        ((FAILED+=1))
    fi
}

check_java() {
    local first_line=""
    local version=""

    if check_command java; then
        first_line="$(java -version 2>&1 | sed -n '1p')"
        version="$(java_version)"
    fi

    if version_at_least "$version" "$JAVA_MIN_VERSION"; then
        log_info "✓ Java: $first_line"
        ((PASSED+=1))
    else
        log_error "✗ Java >= ${JAVA_MIN_VERSION}: ${first_line:-not found}"
        FAILED_TOOLS+=("Java >= ${JAVA_MIN_VERSION}")
        ((FAILED+=1))
    fi
}

check_optional_tool() {
    local tool=$1
    local display_name=${2:-$tool}

    if check_command "$tool"; then
        check_tool "$tool" "$display_name"
    else
        log_warn "Optional $display_name: not found"
    fi
}

check_zim() {
    local zdotdir="${ZDOTDIR:-$HOME}"
    local zim_home="${ZIM_HOME:-${zdotdir}/.zim}"

    if [ -s "${zim_home}/init.zsh" ]; then
        log_info "✓ Zim framework: initialized"
        ((PASSED+=1))
    else
        log_error "✗ Zim framework: ${zim_home}/init.zsh not found"
        FAILED_TOOLS+=("Zim framework")
        ((FAILED+=1))
    fi
}

# Verify all installations
verify_all() {
    log_info "Verifying installations..."
    echo ""
    
    # Platform-specific
    if [ "$IS_MACOS" = "true" ]; then
        check_tool brew "Homebrew"
        check_tool alacritty "Alacritty"
        check_tool omp "Oh My Posh"
        check_tool podman "Podman"
        check_tool podman-compose "podman-compose"
        
        # Verify x86_64 emulation capability
        if command -v podman &> /dev/null; then
            log_info "Testing x86_64 emulation capability..."
            if podman machine list --format '{{.Running}}' 2>/dev/null | grep -q true; then
                if podman run --rm --platform linux/amd64 alpine uname -m 2>/dev/null | grep -q x86_64; then
                    log_info "✓ x86_64 emulation verified"
                else
                    log_warn "x86_64 emulation test failed"
                fi
            else
                log_warn "No running Podman machine; skipping x86_64 emulation test"
            fi
        fi
    fi

    if [ "$IS_UBUNTU" = "true" ]; then
        check_tool alacritty "Alacritty"
    fi
    
    # Common tools and shell framework
    check_tool zsh "zsh"
    check_tool jq "jq"
    check_tool yq "yq"
    check_tool rg "ripgrep"
    check_neovim
    check_tool fd "fd"
    check_tool lazygit "LazyGit"
    if check_command bat; then
        check_tool bat "bat"
    elif check_command batcat; then
        check_tool batcat "bat"
    else
        log_error "✗ bat: not found"
        FAILED_TOOLS+=("bat")
        ((FAILED++))
    fi
    check_tool tmux "tmux"
    check_tool btop "btop"
    check_tool gh "GitHub CLI"
    check_tool glab "GitLab CLI"
    check_zim
    check_tool zellij "Zellij"
    check_tool kubectl "kubectl"
    check_tool kubectx "kubectx"
    check_tool k9s "k9s"
    check_tool helm "Helm"
    check_tool tfenv "tfenv"
    check_tool terraform "Terraform"
    check_tool aws "AWS CLI"
    
    if [ "$IS_MACOS" = "true" ]; then
        local compose_version=""
        if podman compose version &> /dev/null; then
            compose_version="$(podman compose version 2>&1 | sed -n '1p')"
        elif check_command podman-compose; then
            compose_version="$(podman-compose --version 2>&1 | sed -n '1p')"
        fi
        if [ -n "$compose_version" ]; then
            log_info "✓ Podman compose: $compose_version"
            ((PASSED+=1))
        else
            log_error "✗ Podman compose: not found"
            FAILED_TOOLS+=("podman-compose")
            ((FAILED+=1))
        fi
    else
        # Check docker buildx
        if docker buildx version &>/dev/null; then
            local buildx_version=$(docker buildx version 2>&1 | head -n1)
            log_info "✓ Docker buildx: $buildx_version"
            ((PASSED+=1))
        else
            log_error "✗ Docker buildx: not found"
            FAILED_TOOLS+=("docker-buildx")
            ((FAILED+=1))
        fi
    fi
    
    # Development tools
    check_tool node "Node.js"
    check_tool npm "npm"
    check_tool uv "uv"
    check_tool go "Go"
    check_tool tree-sitter "tree-sitter CLI"
    check_java

    # Optional local AI CLIs
    check_optional_tool lms "LM Studio CLI"
    check_optional_tool opencode "OpenCode"
    check_optional_tool claude "Claude Code"
    
    # Git
    check_tool git "Git"
    
    echo ""
    log_info "Verification complete: $PASSED passed, $FAILED failed"
    
    if [ $FAILED -gt 0 ]; then
        log_error "Failed tools: ${FAILED_TOOLS[*]}"
        return 1
    fi
    
    return 0
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    verify_all
fi
