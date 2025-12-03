#!/usr/bin/env bash
set -e

# Build Docker images for x86_64 platform
# Usage: ./scripts/x86-build.sh [docker build args]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Source utilities
source "${PROJECT_ROOT}/lib/utils.sh"
source "${PROJECT_ROOT}/lib/colima-utils.sh"

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

PROFILE_NAME="x86"

# Check if x86 profile is running
if ! colima_is_running "$PROFILE_NAME"; then
    log_error "Colima x86_64 profile is not running. Run ./scripts/x86-start.sh first."
    exit 1
fi

log_info "Building Docker image for x86_64 platform..."
docker build --platform linux/amd64 "$@"

echo -e "${GREEN}✓ Build complete${NC}"
