#!/usr/bin/env bats

# Test architecture detection and binary compatibility

setup() {
    load '../lib/detect.sh'
}

@test "Architecture is detected correctly" {
    [ -n "$OS_ARCH" ]
    [[ "$OS_ARCH" =~ ^(x86_64|aarch64)$ ]]
}

@test "yq binary is executable and correct architecture" {
    if command -v yq &>/dev/null; then
        run yq --version
        [ "$status" -eq 0 ]
    else
        skip "yq not installed"
    fi
}

@test "tmux binary is executable and correct architecture" {
    if command -v tmux &>/dev/null; then
        run tmux -V
        [ "$status" -eq 0 ]
    else
        skip "tmux not installed"
    fi
}

@test "kubectl binary is executable and correct architecture" {
    if command -v kubectl &>/dev/null; then
        run kubectl version --client
        [ "$status" -eq 0 ]
    else
        skip "kubectl not installed"
    fi
}

@test "bat or batcat is executable" {
    if command -v bat &>/dev/null; then
        run bat --version
        [ "$status" -eq 0 ]
    elif command -v batcat &>/dev/null; then
        run batcat --version
        [ "$status" -eq 0 ]
    else
        skip "bat not installed"
    fi
}
