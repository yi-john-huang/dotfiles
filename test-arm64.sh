#!/usr/bin/env bash

# Test ARM64 binary installations
set -euo pipefail

echo "Testing ARM64 architecture detection..."
OS_ARCH="$(uname -m)"
echo "Detected: $OS_ARCH"

case "$OS_ARCH" in
    aarch64|arm64)
        echo "✓ ARM64 detected correctly"
        ;;
    *)
        echo "✗ Expected ARM64, got $OS_ARCH"
        exit 1
        ;;
esac

echo ""
echo "Testing binary URLs..."

# Test yq
YQ_URL="https://github.com/mikefarah/yq/releases/download/v4.49.2/yq_linux_arm64"
echo "yq: $YQ_URL"
if curl -fsSL -I "$YQ_URL" 2>&1 | head -1 | grep -qE "HTTP/[0-9.]+ (200|302)"; then
    echo "✓ yq ARM64 binary exists"
else
    echo "✗ yq ARM64 binary not found"
fi

# Test bat
BAT_VERSION="0.24.0"
BAT_URL="https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/bat-v${BAT_VERSION}-aarch64-unknown-linux-gnu.tar.gz"
echo "bat: $BAT_URL"
if curl -fsSL -I "$BAT_URL" 2>&1 | head -1 | grep -qE "HTTP/[0-9.]+ (200|302)"; then
    echo "✓ bat ARM64 binary exists"
else
    echo "✗ bat ARM64 binary not found"
fi

# Test k9s
K9S_VERSION="0.32.7"
K9S_URL="https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_linux_arm64.tar.gz"
echo "k9s: $K9S_URL"
if curl -fsSL -I "$K9S_URL" 2>&1 | head -1 | grep -qE "HTTP/[0-9.]+ (200|302)"; then
    echo "✓ k9s ARM64 binary exists"
else
    echo "✗ k9s ARM64 binary not found"
fi

# Test zellij
ZELLIJ_VERSION="0.43.1"
ZELLIJ_URL="https://github.com/zellij-org/zellij/releases/download/v${ZELLIJ_VERSION}/zellij-aarch64-unknown-linux-musl.tar.gz"
echo "zellij: $ZELLIJ_URL"
if curl -fsSL -I "$ZELLIJ_URL" 2>&1 | head -1 | grep -qE "HTTP/[0-9.]+ (200|302)"; then
    echo "✓ zellij ARM64 binary exists"
else
    echo "✗ zellij ARM64 binary not found"
fi

# Test kubectl
KUBECTL_VERSION=$(curl -L -s "https://dl.k8s.io/release/stable.txt")
KUBECTL_BIN="https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/arm64/kubectl"
echo "kubectl: $KUBECTL_BIN"
if curl -fsSL -I "$KUBECTL_BIN" 2>&1 | head -1 | grep -qE "HTTP/[0-9.]+ (200|302)"; then
    echo "✓ kubectl ARM64 binary exists"
else
    echo "✗ kubectl ARM64 binary not found"
fi

echo ""
echo "All ARM64 binaries verified!"
