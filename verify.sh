#!/usr/bin/env bash

# Verification Script
# Validates all tool installations

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"
source "${SCRIPT_DIR}/lib/detect.sh"

# Track results
PASSED=0
FAILED=0
FAILED_TOOLS=()

# Check tool installation
check_tool() {
    local tool=$1
    local display_name=${2:-$tool}
    
    if check_command "$tool"; then
        local version=""
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
        log_info "✓ $display_name: $version"
        ((PASSED++))
        return 0
    else
        log_error "✗ $display_name: not found"
        FAILED_TOOLS+=("$display_name")
        ((FAILED++))
        return 1
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
    fi
    
    # Common tools
    check_tool jq "jq"
    check_tool yq "yq"
    check_tool rg "ripgrep"
    check_tool bat "bat" || check_tool batcat "bat"
    check_tool zellij "zellij"
    check_tool kubectl "kubectl"
    check_tool kubectx "kubectx"
    check_tool k9s "k9s"
    check_tool terraform "Terraform"
    check_tool aws "AWS CLI"
    
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
