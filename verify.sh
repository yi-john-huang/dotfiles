#!/usr/bin/env bash

# Verification Script
# Validates all tool installations

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"
source "${SCRIPT_DIR}/lib/detect.sh"

# Load PATH from shell config to find newly installed tools
if [ -f "$HOME/.bashrc" ]; then
    set +u  # Disable nounset for sourcing
    source "$HOME/.bashrc" 2>/dev/null || true
    set -u
fi

# Ensure .local/bin is in PATH (for uv)
export PATH="$HOME/.local/bin:$PATH"

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
            kubectl)
                version=$("$tool" version --client --short 2>&1 | head -n1 || echo "installed")
                ;;
            kubectx|kubens)
                version="installed"
                ;;
            k9s)
                version=$("$tool" version -s 2>&1 | head -n1 || echo "installed")
                ;;
            go)
                version=$("$tool" version 2>&1 | head -n1 || echo "installed")
                ;;
            java)
                version=$("$tool" -version 2>&1 | head -n1 || echo "installed")
                ;;
            *)
                version=$("$tool" --version 2>&1 | head -n1 || echo "unknown")
                ;;
        esac
        
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

# Verify all installations
verify_all() {
    log_info "Verifying installations..."
    echo ""
    
    # Platform-specific
    if [ "$IS_MACOS" = "true" ]; then
        check_tool brew "Homebrew"
        check_tool colima "Colima"
        
        # Verify x86_64 emulation capability
        if command -v colima &> /dev/null; then
            info "Testing x86_64 emulation capability..."
            if colima start --profile x86-test --arch x86_64 --cpu 1 --memory 1 --disk 5 &> /dev/null; then
                if docker --context colima-x86-test run --rm alpine uname -m 2>/dev/null | grep -q x86_64; then
                    success "x86_64 emulation verified"
                else
                    warn "x86_64 emulation test failed"
                fi
                colima delete --profile x86-test --force &> /dev/null
            else
                warn "Could not start x86_64 test profile"
            fi
        fi
    fi
    
    # Common tools
    check_tool jq "jq"
    check_tool yq "yq"
    check_tool rg "ripgrep"
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
    check_tool kubectl "kubectl"
    check_tool kubectx "kubectx"
    check_tool k9s "k9s"
    check_tool helm "Helm"
    check_tool tfenv "tfenv"
    check_tool terraform "Terraform"
    check_tool aws "AWS CLI"
    
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
    
    # Development tools
    check_tool node "Node.js"
    check_tool npm "npm"
    check_tool uv "uv"
    check_tool go "Go"
    check_tool java "Java"
    
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
