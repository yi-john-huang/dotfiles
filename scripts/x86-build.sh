#!/usr/bin/env bash
set -e

# Build Podman images for x86_64 platform
# Usage: ./scripts/x86-build.sh [podman build args]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Source utilities
source "${PROJECT_ROOT}/lib/utils.sh"
source "${PROJECT_ROOT}/lib/podman-utils.sh"

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

PROFILE_NAME="x86"

# Check if x86 machine is running
if ! podman_machine_is_running "$PROFILE_NAME"; then
    log_error "Podman machine '${PROFILE_NAME}' is not running. Run ./scripts/x86-start.sh first."
    exit 1
fi

log_info "Building Podman image for x86_64 platform..."
podman build --platform linux/amd64 "$@"

echo -e "${GREEN}✓ Build complete${NC}"
