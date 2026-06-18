#!/usr/bin/env bash
set -e

# Run Podman compose with x86_64 platform
# Usage: ./scripts/x86-compose.sh [compose command]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Source utilities
source "${PROJECT_ROOT}/lib/utils.sh"
source "${PROJECT_ROOT}/lib/podman-utils.sh"

PROFILE_NAME="x86"

# Check if x86 machine is running
if ! podman_machine_is_running "$PROFILE_NAME"; then
    log_error "Podman machine '${PROFILE_NAME}' is not running. Run ./scripts/x86-start.sh first."
    exit 1
fi

log_info "Running Podman compose with x86_64 platform..."
export DOCKER_DEFAULT_PLATFORM=linux/amd64

# podman compose wraps an installed Compose provider such as podman-compose.
if podman compose version &> /dev/null; then
    podman compose "$@"
elif command -v podman-compose &> /dev/null; then
    podman-compose "$@"
else
    log_error "Neither 'podman compose' nor 'podman-compose' found"
    exit 1
fi
