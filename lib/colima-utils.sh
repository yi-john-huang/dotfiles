#!/usr/bin/env bash

# Colima utility functions for profile management
# Source this file to use these functions

# Check if a Colima profile exists
# Usage: colima_profile_exists "profile-name"
# Returns: 0 if exists, 1 if not
colima_profile_exists() {
    local profile_name="$1"
    colima list 2>/dev/null | grep -q "^${profile_name}"
}

# Check if a Colima profile is running
# Usage: colima_is_running "profile-name"
# Returns: 0 if running, 1 if not
colima_is_running() {
    local profile_name="$1"
    colima list 2>/dev/null | grep "^${profile_name}" | grep -q "Running"
}

# Get architecture of a running Colima profile
# Usage: colima_get_arch "profile-name"
# Returns: "x86_64" or "aarch64" or empty if not running
colima_get_arch() {
    local profile_name="$1"
    colima list 2>/dev/null | grep "^${profile_name}" | awk '{print $3}'
}
