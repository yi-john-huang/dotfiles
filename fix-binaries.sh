#!/usr/bin/env bash

# Fix binary format errors by removing and reinstalling tools

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/detect.sh"
source "${SCRIPT_DIR}/lib/utils.sh"

log_info "Fixing binary format errors..."

# Remove problematic binaries
log_info "Removing incompatible binaries..."
sudo rm -f /usr/local/bin/yq
sudo rm -f /usr/local/bin/zellij
sudo rm -f /usr/local/bin/kubectl

# Source common tools installer
source "${SCRIPT_DIR}/install/common.sh"

# Track failures
FAILED=0

# Reinstall tools
log_info "Reinstalling yq..."
install_yq || ((FAILED++))

log_info "Reinstalling zellij..."
install_zellij || ((FAILED++))

log_info "Reinstalling kubectl..."
install_kubectl || ((FAILED++))

log_info "Installing bat..."
install_bat || ((FAILED++))

if [ $FAILED -eq 0 ]; then
    log_info "✓ Binary fixes complete"
    log_info "Run ./verify.sh to confirm"
else
    log_warn "Some tools failed to install ($FAILED failures)"
    log_info "Run ./verify.sh to see details"
fi
