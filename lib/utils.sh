#!/usr/bin/env bash

# Utility Functions Module
# Logging and helper functions for bootstrap scripts

set -euo pipefail

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log info message
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

# Log warning message
log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

# Log error message
log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# Check if command exists
check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Cleanup function for trap
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log_error "Script failed with exit code $exit_code"
    fi
}

# Set trap for cleanup
trap cleanup EXIT
