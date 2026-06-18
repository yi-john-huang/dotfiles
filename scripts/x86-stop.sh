#!/usr/bin/env bash
set -e

# Stop Podman x86_64 machine
# Usage: ./scripts/x86-stop.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Source utilities
source "${PROJECT_ROOT}/lib/utils.sh"
source "${PROJECT_ROOT}/lib/podman-utils.sh"

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

PROFILE_NAME="x86"

# Check if Podman is installed
if ! command -v podman &> /dev/null; then
    log_error "Podman is not installed."
    exit 1
fi

# Check if machine is running
if ! podman_machine_is_running "$PROFILE_NAME"; then
    log_warn "Podman machine '${PROFILE_NAME}' is not running"
    exit 0
fi

log_info "Stopping Podman machine '${PROFILE_NAME}'..."
podman machine stop "$PROFILE_NAME"

echo -e "${GREEN}✓ x86_64 machine stopped${NC}"
