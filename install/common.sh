#!/usr/bin/env bash

# Common Tools Installation Module
# Installs cross-platform CLI tools

set -uo pipefail  # Removed -e to allow brew warnings

# Source required modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/detect.sh"
source "${SCRIPT_DIR}/../lib/utils.sh"

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
    if check_command yq; then
        log_info "✓ yq already installed"
        return 0
    fi
    
    log_info "Installing yq..."
    if [ "$IS_MACOS" = "true" ]; then
        brew install yq
    else
        sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
        sudo chmod +x /usr/local/bin/yq
    fi
    log_info "✓ yq installed"
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
        sudo apt-get install -y bat
    fi
    log_info "✓ bat installed"
}

# Install zellij
install_zellij() {
    if check_command zellij; then
        log_info "✓ zellij already installed"
        return 0
    fi
    
    log_info "Installing zellij..."
    if [ "$IS_MACOS" = "true" ]; then
        brew install zellij
    else
        cargo install --locked zellij || {
            log_warn "Cargo not available, skipping zellij"
            return 0
        }
    fi
    log_info "✓ zellij installed"
}

# Install kubectl
install_kubectl() {
    if check_command kubectl; then
        log_info "✓ kubectl already installed"
        return 0
    fi
    
    log_info "Installing kubectl..."
    if [ "$IS_MACOS" = "true" ]; then
        brew install kubectl
    else
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        rm kubectl
    fi
    log_info "✓ kubectl installed"
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
        curl -sS https://webinstall.dev/k9s | bash
    fi
    log_info "✓ k9s installed"
}

# Install Terraform
install_terraform() {
    if check_command terraform; then
        log_info "✓ Terraform already installed"
        return 0
    fi
    
    log_info "Installing Terraform..."
    if [ "$IS_MACOS" = "true" ]; then
        brew tap hashicorp/tap
        brew install hashicorp/tap/terraform
    else
        wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt-get update && sudo apt-get install -y terraform
    fi
    log_info "✓ Terraform installed"
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
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip -q awscliv2.zip
        sudo ./aws/install
        rm -rf aws awscliv2.zip
    fi
    log_info "✓ AWS CLI installed"
}

# Main installation function
install_common_tools() {
    log_info "Starting common tools installation..."
    
    install_jq
    install_yq
    install_ripgrep
    install_bat
    install_zellij
    install_kubectl
    install_kubectx
    install_k9s
    install_terraform
    install_aws_cli
    
    log_info "✓ Common tools installation complete"
}
