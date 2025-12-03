#!/usr/bin/env bash
set -e

# Start Colima with x86_64 architecture profile
# Usage: ./scripts/x86-start.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Source utilities
source "${PROJECT_ROOT}/lib/utils.sh"
source "${PROJECT_ROOT}/lib/colima-utils.sh"

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

# Configuration
PROFILE_NAME="x86"
COLIMA_CPU="${COLIMA_CPU:-2}"
COLIMA_MEM="${COLIMA_MEM:-4}"
COLIMA_DISK="${COLIMA_DISK:-10}"

# Check if Colima is installed
if ! command -v colima &> /dev/null; then
    log_error "Colima is not installed. Run ./bootstrap.sh to install."
    exit 1
fi

log_info "Starting Colima x86_64 profile..."

# Check if profile exists and is running
if colima_is_running "$PROFILE_NAME"; then
    echo -e "${GREEN}✓${NC} Colima x86_64 profile is already running"
elif colima_profile_exists "$PROFILE_NAME"; then
    log_info "Starting existing x86 profile..."
    colima start --profile "$PROFILE_NAME"
else
    log_info "Creating new x86_64 profile (CPU: $COLIMA_CPU, Memory: ${COLIMA_MEM}GB, Disk: ${COLIMA_DISK}GB)..."
    colima start --profile "$PROFILE_NAME" --arch x86_64 \
        --cpu "$COLIMA_CPU" --memory "$COLIMA_MEM" --disk "$COLIMA_DISK"
fi

# Set Docker context
log_info "Setting Docker context to colima-${PROFILE_NAME}..."
if docker context use "colima-${PROFILE_NAME}" 2>/dev/null; then
    : # Success
else
    log_warn "Docker context not found, it will be created automatically"
fi

# Verify architecture
log_info "Verifying x86_64 architecture..."
ARCH=$(docker run --rm alpine uname -m 2>/dev/null)
if [ "$ARCH" = "x86_64" ]; then
    echo -e "${GREEN}✓ x86_64 environment ready${NC}"
    echo ""
    echo "Usage:"
    echo "  Build: ./scripts/x86-build.sh -t myapp:x86 ."
    echo "  Compose: ./scripts/x86-compose.sh up"
    echo "  Stop: ./scripts/x86-stop.sh"
else
    log_error "Architecture verification failed. Expected x86_64, got: $ARCH"
    exit 1
fi
