#!/usr/bin/env bash

# Podman utility functions for machine management
# Source this file to use these functions

# Check if a Podman machine exists
# Usage: podman_machine_exists "machine-name"
# Returns: 0 if exists, 1 if not
podman_machine_exists() {
    local machine_name="$1"
    podman machine list --format '{{.Name}}' 2>/dev/null | tr -d '*' | grep -qx "$machine_name"
}

# Check if a Podman machine is running
# Usage: podman_machine_is_running "machine-name"
# Returns: 0 if running, 1 if not
podman_machine_is_running() {
    local machine_name="$1"
    podman machine list --format '{{.Name}} {{.Running}}' 2>/dev/null | tr -d '*' | grep -qx "${machine_name} true"
}

# Start a Podman machine if it exists, otherwise initialize it.
# Usage: podman_machine_ensure_running "machine-name" "cpus" "memory-mib" "disk-gb"
podman_machine_ensure_running() {
    local machine_name="$1"
    local cpus="$2"
    local memory_mib="$3"
    local disk_gb="$4"

    if podman_machine_is_running "$machine_name"; then
        return 0
    fi

    if podman_machine_exists "$machine_name"; then
        podman machine start --update-connection true "$machine_name"
    else
        podman machine init --cpus "$cpus" --memory "$memory_mib" --disk-size "$disk_gb" --now --update-connection true "$machine_name"
    fi
}
