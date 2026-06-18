#!/usr/bin/env bash
set -e

# Start Podman machine for x86_64 container execution
# Usage: ./scripts/x86-start.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Source utilities
source "${PROJECT_ROOT}/lib/utils.sh"
source "${PROJECT_ROOT}/lib/podman-utils.sh"

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

# Configuration
PROFILE_NAME="x86"
PODMAN_CPU="${PODMAN_CPU:-2}"
PODMAN_MEM="${PODMAN_MEM:-4}"
PODMAN_DISK="${PODMAN_DISK:-10}"
PODMAN_MEM_MIB=$((PODMAN_MEM * 1024))

# Check if Podman is installed
if ! command -v podman &> /dev/null; then
    log_error "Podman is not installed. Run ./bootstrap.sh to install."
    exit 1
fi

log_info "Starting Podman machine for x86_64 containers..."

if podman_machine_is_running "$PROFILE_NAME"; then
    echo -e "${GREEN}✓${NC} Podman machine '${PROFILE_NAME}' is already running"
    podman system connection default "$PROFILE_NAME" &> /dev/null || true
else
    log_info "Ensuring Podman machine '${PROFILE_NAME}' is running (CPU: $PODMAN_CPU, Memory: ${PODMAN_MEM}GB, Disk: ${PODMAN_DISK}GB)..."
    podman_machine_ensure_running "$PROFILE_NAME" "$PODMAN_CPU" "$PODMAN_MEM_MIB" "$PODMAN_DISK"
fi

# Verify architecture
log_info "Verifying x86_64 architecture..."
ARCH=$(podman run --rm --platform linux/amd64 alpine uname -m 2>/dev/null)
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
