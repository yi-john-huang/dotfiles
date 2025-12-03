#!/usr/bin/env bash
set -e

# Run docker compose with x86_64 platform
# Usage: ./scripts/x86-compose.sh [compose command]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Source utilities
source "${PROJECT_ROOT}/lib/utils.sh"
source "${PROJECT_ROOT}/lib/colima-utils.sh"

PROFILE_NAME="x86"

# Check if x86 profile is running
if ! colima_is_running "$PROFILE_NAME"; then
    log_error "Colima x86_64 profile is not running. Run ./scripts/x86-start.sh first."
    exit 1
fi

log_info "Running docker compose with x86_64 platform..."
export DOCKER_DEFAULT_PLATFORM=linux/amd64

# Try docker compose (v2) first, fallback to docker-compose (v1)
if docker compose version &> /dev/null; then
    docker compose "$@"
elif command -v docker-compose &> /dev/null; then
    docker-compose "$@"
else
    log_error "Neither 'docker compose' nor 'docker-compose' found"
    exit 1
fi
