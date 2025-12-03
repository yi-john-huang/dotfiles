#!/usr/bin/env bash

# Platform Detection Module
# Detects OS type and architecture for cross-platform bootstrap

set -euo pipefail

# Detect OS type
OS_TYPE="$(uname -s)"
export OS_TYPE

# Detect architecture
OS_ARCH="$(uname -m)"
export OS_ARCH

# Set platform flags
IS_MACOS="false"
IS_UBUNTU="false"

if [ "$OS_TYPE" = "Darwin" ]; then
    IS_MACOS="true"
elif [ "$OS_TYPE" = "Linux" ]; then
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        if [ "$ID" = "ubuntu" ]; then
            IS_UBUNTU="true"
        fi
    fi
fi

export IS_MACOS
export IS_UBUNTU
