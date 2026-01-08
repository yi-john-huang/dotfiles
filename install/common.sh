#!/usr/bin/env bash

# Common Tools Installation Module
# Installs cross-platform CLI tools

set -uo pipefail  # Removed -e to allow brew warnings

# Source required modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/detect.sh"
source "${SCRIPT_DIR}/../lib/utils.sh"

# Architecture mapping
case "$OS_ARCH" in
    x86_64)
        KUBECTL_ARCH="amd64"
        AWS_ARCH="x86_64"
        YQ_ARCH="amd64"
        ;;
    aarch64)
        KUBECTL_ARCH="arm64"
        AWS_ARCH="aarch64"
        YQ_ARCH="arm64"
        ;;
    *)
        # Fallback or error, but let's try x86_64 as default if unknown
        log_warn "Unknown architecture: $OS_ARCH. Defaulting to x86_64/amd64."
        KUBECTL_ARCH="amd64"
        AWS_ARCH="x86_64"
        YQ_ARCH="amd64"
        ;;
esac

# Install jq
install_jq() {
    if check_command jq; then
        log_info "✓ jq already installed"
        return 0
    fi
    
    log_info "Installing jq..."
    if [ "$IS_MACOS" = "true" ]; then
        brew install jq
    else
        sudo apt-get install -y jq
    fi
    log_info "✓ jq installed"
}

# Install yq
install_yq() {
    if check_command yq && yq --version &>/dev/null; then
        log_info "✓ yq already installed"
        return 0
    fi
    
    log_info "Installing yq..."
    if [ "$IS_MACOS" = "true" ]; then
        brew install yq
    else
        local version="4.49.2"
        local url="https://github.com/mikefarah/yq/releases/download/v${version}/yq_linux_${YQ_ARCH}"
        local target="/usr/local/bin/yq"
        
        sudo rm -f "$target"
        if sudo curl -fsSL "$url" -o "$target" && sudo chmod +x "$target"; then
            if "$target" --version &>/dev/null; then
                log_info "✓ yq installed from binary"
                return 0
            else
                log_warn "yq binary incompatible with architecture"
                sudo rm -f "$target"
            fi
        fi
        
        log_warn "Binary installation failed, trying snap..."
        if sudo snap install yq; then
            log_info "✓ yq installed via snap"
        else
            log_warn "Failed to install yq"
            return 1
        fi
    fi
}

# Install ripgrep
install_ripgrep() {
    if check_command rg; then
        log_info "✓ ripgrep already installed"
        return 0
    fi
    
    log_info "Installing ripgrep..."
    if [ "$IS_MACOS" = "true" ]; then
        brew install ripgrep
    else
        sudo apt-get install -y ripgrep
    fi
    log_info "✓ ripgrep installed"
}

# Install bat
install_bat() {
    if check_command bat || check_command batcat; then
        log_info "✓ bat already installed"
        return 0
    fi
    
    log_info "Installing bat..."
    if [ "$IS_MACOS" = "true" ]; then
        brew install bat
    else
        if sudo apt-get install -y bat; then
            log_info "✓ bat installed"
        else
            log_warn "Failed to install bat"
            return 1
        fi
    fi
}

# Install tmux
install_tmux() {
    if check_command tmux; then
        log_info "✓ tmux already installed"
        return 0
    fi
    
    log_info "Installing tmux..."
    if [ "$IS_MACOS" = "true" ]; then
        brew install tmux
    else
        sudo apt-get install -y tmux
    fi
    log_info "✓ tmux installed"
}

# Install kubectl
install_kubectl() {
    if check_command kubectl && kubectl version --client &>/dev/null; then
        log_info "✓ kubectl already installed"
        return 0
    fi
    
    log_info "Installing kubectl..."
    if [ "$IS_MACOS" = "true" ]; then
        brew install kubectl
    else
        local tmp_dir=$(mktemp -d)
        local target="/usr/local/bin/kubectl"
        pushd "$tmp_dir" > /dev/null
        
        local stable_version=$(curl -L -s https://dl.k8s.io/release/stable.txt)
        sudo rm -f "$target"
        if curl -fsSLO "https://dl.k8s.io/release/${stable_version}/bin/linux/${KUBECTL_ARCH}/kubectl" && sudo install -o root -g root -m 0755 kubectl "$target"; then
            if "$target" version --client &>/dev/null; then
                log_info "✓ kubectl installed"
                popd > /dev/null
                rm -rf "$tmp_dir"
                return 0
            else
                log_warn "kubectl binary incompatible with architecture"
                sudo rm -f "$target"
            fi
        fi
        popd > /dev/null
        rm -rf "$tmp_dir"
        
        log_warn "Binary installation failed, trying snap..."
        if sudo snap install kubectl --classic; then
            log_info "✓ kubectl installed via snap"
        else
            log_warn "Failed to install kubectl"
            return 1
        fi
    fi
}

# Install kubectx
install_kubectx() {
    if check_command kubectx; then
        log_info "✓ kubectx already installed"
        return 0
    fi
    
    log_info "Installing kubectx..."
    if [ "$IS_MACOS" = "true" ]; then
        brew install kubectx
    else
        sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
        sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
        sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
    fi
    log_info "✓ kubectx installed"
}

# Install k9s
install_k9s() {
    if check_command k9s; then
        log_info "✓ k9s already installed"
        return 0
    fi
    
    log_info "Installing k9s..."
    if [ "$IS_MACOS" = "true" ]; then
        brew install derailed/k9s/k9s
    else
        local version="0.32.7"
        local k9s_arch="linux_${OS_ARCH}"
        [ "$OS_ARCH" = "aarch64" ] && k9s_arch="linux_arm64"
        [ "$OS_ARCH" = "x86_64" ] && k9s_arch="linux_amd64"
        local url="https://github.com/derailed/k9s/releases/download/v${version}/k9s_${k9s_arch}.tar.gz"
        local tmp_dir=$(mktemp -d)
        
        pushd "$tmp_dir" > /dev/null
        if curl -fsSL "$url" -o k9s.tar.gz && tar -xzf k9s.tar.gz && sudo install -o root -g root -m 0755 k9s /usr/local/bin/k9s; then
            log_info "✓ k9s installed from binary"
        else
            log_warn "Binary failed, trying snap..."
            sudo snap install k9s || log_warn "k9s installation failed, skipping..."
        fi
        popd > /dev/null
        rm -rf "$tmp_dir"
    fi
}

# Install Helm
install_helm() {
    if check_command helm; then
        log_info "✓ Helm already installed"
        return 0
    fi
    
    log_info "Installing Helm..."
    if [ "$IS_MACOS" = "true" ]; then
        brew install helm
    else
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    fi
    log_info "✓ Helm installed"
}

# Install tfenv and Terraform
install_tfenv() {
    if check_command tfenv; then
        log_info "✓ tfenv already installed"
    else
        log_info "Installing tfenv..."
        if [ "$IS_MACOS" = "true" ]; then
            brew install tfenv
        else
            git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv
            export PATH="$HOME/.tfenv/bin:$PATH"
        fi
        log_info "✓ tfenv installed"
    fi
    
    # Install latest Terraform version
    if ! terraform version &>/dev/null; then
        log_info "Installing latest Terraform via tfenv..."
        tfenv install latest
        tfenv use latest
        log_info "✓ Terraform installed via tfenv"
    else
        log_info "✓ Terraform already available"
    fi
}

# Install AWS CLI
install_aws_cli() {
    if check_command aws; then
        log_info "✓ AWS CLI already installed"
        return 0
    fi
    
    log_info "Installing AWS CLI..."
    if [ "$IS_MACOS" = "true" ]; then
        brew install awscli
    else
        local tmp_dir=$(mktemp -d)
        pushd "$tmp_dir" > /dev/null
        
        curl "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip" -o "awscliv2.zip"
        unzip -q awscliv2.zip
        sudo ./aws/install
        
        popd > /dev/null
        rm -rf "$tmp_dir"
    fi
    log_info "✓ AWS CLI installed"
}

# Main installation function
install_common_tools() {
    log_info "Starting common tools installation..."
    
    local failed=0
    
    install_jq || ((failed++))
    install_yq || ((failed++))
    install_ripgrep || ((failed++))
    install_bat || ((failed++))
    install_tmux || ((failed++))
    install_kubectl || ((failed++))
    install_kubectx || ((failed++))
    install_k9s || ((failed++))
    install_helm || ((failed++))
    install_tfenv || ((failed++))
    install_aws_cli || ((failed++))
    
    if [ $failed -eq 0 ]; then
        log_info "✓ Common tools installation complete"
    else
        log_warn "Common tools installation complete with $failed failures"
    fi
}
