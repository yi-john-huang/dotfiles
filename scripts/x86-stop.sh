#!/usr/bin/env bash
set -e

# Stop Colima x86_64 profile
# Usage: ./scripts/x86-stop.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Source utilities
source "${PROJECT_ROOT}/lib/utils.sh"
source "${PROJECT_ROOT}/lib/colima-utils.sh"

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

PROFILE_NAME="x86"

# Check if Colima is installed
if ! command -v colima &> /dev/null; then
    log_error "Colima is not installed."
    exit 1
fi

# Check if profile is running
if ! colima_is_running "$PROFILE_NAME"; then
    log_warn "Colima x86_64 profile is not running"
    exit 0
fi

log_info "Stopping Colima x86_64 profile..."
colima stop --profile "$PROFILE_NAME"

echo -e "${GREEN}✓ x86_64 profile stopped${NC}"
