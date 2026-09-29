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

# Compare semantic versions using their numeric major.minor.patch tuple.
# Optional leading "v" and suffixes such as "-dev" are ignored.
version_at_least() {
    local actual="${1:-}"
    local required="${2:-}"
    local actual_major actual_minor actual_patch
    local required_major required_minor required_patch

    if [[ ! "$actual" =~ ^v?([0-9]+)\.([0-9]+)\.([0-9]+)([^0-9].*)?$ ]]; then
        return 1
    fi
    actual_major="${BASH_REMATCH[1]}"
    actual_minor="${BASH_REMATCH[2]}"
    actual_patch="${BASH_REMATCH[3]}"

    if [[ ! "$required" =~ ^v?([0-9]+)\.([0-9]+)\.([0-9]+)([^0-9].*)?$ ]]; then
        return 1
    fi
    required_major="${BASH_REMATCH[1]}"
    required_minor="${BASH_REMATCH[2]}"
    required_patch="${BASH_REMATCH[3]}"

    if ((10#$actual_major != 10#$required_major)); then
        ((10#$actual_major > 10#$required_major))
        return
    fi
    if ((10#$actual_minor != 10#$required_minor)); then
        ((10#$actual_minor > 10#$required_minor))
        return
    fi
    ((10#$actual_patch >= 10#$required_patch))
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
