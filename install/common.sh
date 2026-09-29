#!/usr/bin/env bash

# Common Tools Installation Module
# Installs cross-platform CLI tools

set -uo pipefail  # Removed -e to allow brew warnings

# Source required modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/detect.sh"
source "${SCRIPT_DIR}/../lib/utils.sh"

NEOVIM_LINUX_VERSION="0.12.4"
LAZYGIT_LINUX_VERSION="0.63.1"

# Architecture mapping
case "$OS_ARCH" in
    x86_64)
        KUBECTL_ARCH="amd64"
        AWS_ARCH="x86_64"
        YQ_ARCH="amd64"
        ZELLIJ_ARCH="x86_64"
        ;;
    aarch64)
        KUBECTL_ARCH="arm64"
        AWS_ARCH="aarch64"
        YQ_ARCH="arm64"
        ZELLIJ_ARCH="aarch64"
        ;;
    *)
        # Fallback or error, but let's try x86_64 as default if unknown
        log_warn "Unknown architecture: $OS_ARCH. Defaulting to x86_64/amd64."
        KUBECTL_ARCH="amd64"
        AWS_ARCH="x86_64"
        YQ_ARCH="amd64"
        ZELLIJ_ARCH="x86_64"
        ;;
esac

# Install JetBrainsMono Nerd Font
install_jetbrains_mono_nerd_font() {
    if [ "$IS_MACOS" = "true" ]; then
        if [ -d "$HOME/Library/Fonts" ] && find "$HOME/Library/Fonts" -iname '*JetBrainsMono*Nerd*Font*' -print -quit | grep -q .; then
            log_info "✓ JetBrainsMono Nerd Font already installed"
            return 0
        fi

        log_info "Installing JetBrainsMono Nerd Font..."
        brew install --cask font-jetbrains-mono-nerd-font
        log_info "✓ JetBrainsMono Nerd Font installed"
        return 0
    fi

    if fc-match "JetBrainsMono Nerd Font Mono" 2>/dev/null | grep -qi "JetBrains"; then
        log_info "✓ JetBrainsMono Nerd Font already installed"
        return 0
    fi

    log_info "Installing JetBrainsMono Nerd Font..."
    local tmp_dir
    tmp_dir=$(mktemp -d)
    pushd "$tmp_dir" > /dev/null

    if curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" -o JetBrainsMono.zip; then
        mkdir -p "$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
        unzip -qo JetBrainsMono.zip -d "$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
        fc-cache -f "$HOME/.local/share/fonts"
        log_info "✓ JetBrainsMono Nerd Font installed"
    else
        log_warn "JetBrainsMono Nerd Font installation failed"
        popd > /dev/null
        rm -rf "$tmp_dir"
        return 1
    fi

    popd > /dev/null
    rm -rf "$tmp_dir"
}

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

# Install Neovim
install_neovim() {
    local installed_version=""
    if check_command nvim; then
        installed_version="$(nvim_version || true)"
        if version_at_least "$installed_version" "$NEOVIM_MIN_VERSION"; then
            log_info "✓ Neovim ${installed_version} already installed"
            return 0
        fi
    fi

    log_info "Installing Neovim >= ${NEOVIM_MIN_VERSION}..."
    if [ "$IS_MACOS" = "true" ]; then
        if brew list --formula neovim > /dev/null 2>&1; then
            brew upgrade neovim || return 1
        else
            brew install neovim || return 1
        fi
    else
        local asset checksum install_dir stage_dir tmp_dir archive
        case "$OS_ARCH" in
            aarch64)
                asset="nvim-linux-arm64.tar.gz"
                checksum="ceb7e88c6b681f0515d135dcdfad54f5eb4373b25ce6172197cd9a69c758063f"
                ;;
            x86_64)
                asset="nvim-linux-x86_64.tar.gz"
                checksum="012bf3fcac5ade43914df3f174668bf64d05e049a4f032a388c027b1ebd78628"
                ;;
            *)
                log_error "Unsupported architecture for Neovim: $OS_ARCH"
                return 1
                ;;
        esac

        install_dir="$HOME/.local/opt/nvim-${NEOVIM_LINUX_VERSION}"
        if [ -x "$install_dir/bin/nvim" ]; then
            mkdir -p "$HOME/.local/bin"
            ln -sfn "$install_dir/bin/nvim" "$HOME/.local/bin/nvim"
            export PATH="$HOME/.local/bin:$PATH"
        else
            tmp_dir="$(mktemp -d)" || return 1
            archive="$tmp_dir/$asset"
            stage_dir="$tmp_dir/nvim"
            if ! curl -fL --retry 3 \
                "https://github.com/neovim/neovim/releases/download/v${NEOVIM_LINUX_VERSION}/${asset}" \
                -o "$archive"; then
                rm -rf "$tmp_dir"
                log_error "Failed to download Neovim ${NEOVIM_LINUX_VERSION}"
                return 1
            fi
            if ! verify_sha256 "$checksum" "$archive"; then
                rm -rf "$tmp_dir"
                log_error "Neovim archive checksum verification failed"
                return 1
            fi
            mkdir -p "$stage_dir"
            if ! tar -xzf "$archive" --strip-components=1 -C "$stage_dir"; then
                rm -rf "$tmp_dir"
                log_error "Failed to extract Neovim ${NEOVIM_LINUX_VERSION}"
                return 1
            fi
            if [ ! -x "$stage_dir/bin/nvim" ]; then
                rm -rf "$tmp_dir"
                log_error "Downloaded Neovim archive contains no executable"
                return 1
            fi

            mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"
            rm -rf "${install_dir}.previous"
            if [ -e "$install_dir" ]; then
                mv "$install_dir" "${install_dir}.previous" || {
                    rm -rf "$tmp_dir"
                    return 1
                }
            fi
            if ! mv "$stage_dir" "$install_dir"; then
                [ -e "${install_dir}.previous" ] && mv "${install_dir}.previous" "$install_dir"
                rm -rf "$tmp_dir"
                return 1
            fi
            ln -sfn "$install_dir/bin/nvim" "$HOME/.local/bin/nvim"
            rm -rf "${install_dir}.previous" "$tmp_dir"
            export PATH="$HOME/.local/bin:$PATH"
        fi
    fi

    installed_version="$(nvim_version || true)"
    if ! version_at_least "$installed_version" "$NEOVIM_MIN_VERSION"; then
        log_error "Installation requires Neovim >= ${NEOVIM_MIN_VERSION}; found ${installed_version:-none}"
        return 1
    fi
    log_info "✓ Neovim ${installed_version} installed"
}

# Install fd
install_fd() {
    if check_command fd; then
        log_info "✓ fd already installed"
        return 0
    fi

    log_info "Installing fd..."
    if [ "$IS_MACOS" = "true" ]; then
        brew install fd || return 1
    else
        sudo apt-get install -y fd-find || return 1
        local fdfind_path target
        fdfind_path="$(command -v fdfind || true)"
        target="$HOME/.local/bin/fd"
        if [ -z "$fdfind_path" ]; then
            log_error "fd-find installed without an fdfind executable"
            return 1
        fi
        mkdir -p "$HOME/.local/bin"
        if [ -e "$target" ] || [ -L "$target" ]; then
            if [ ! -L "$target" ] || [ "$(readlink "$target")" != "$fdfind_path" ]; then
                log_error "Refusing to replace unrelated fd target: $target"
                return 1
            fi
        else
            ln -s "$fdfind_path" "$target"
        fi
        export PATH="$HOME/.local/bin:$PATH"
    fi

    check_command fd || {
        log_error "fd installation did not provide an fd executable"
        return 1
    }
    log_info "✓ fd installed"
}

# Install LazyGit
install_lazygit() {
    if check_command lazygit; then
        log_info "✓ LazyGit already installed"
        return 0
    fi

    log_info "Installing LazyGit..."
    if [ "$IS_MACOS" = "true" ]; then
        brew install lazygit || return 1
    else
        local asset_arch checksum tmp_dir archive staged_binary
        case "$OS_ARCH" in
            aarch64)
                asset_arch="arm64"
                checksum="555dbc9a8efcf2e33bc24e7fbd9463e9fa375e3c5e23cc270763733c38eeae36"
                ;;
            x86_64)
                asset_arch="x86_64"
                checksum="8e033bc78c8e192dee9510e951f6c9e154289b7198d22c924ed1d0a951b0dac1"
                ;;
            *)
                log_error "Unsupported architecture for LazyGit: $OS_ARCH"
                return 1
                ;;
        esac

        tmp_dir="$(mktemp -d)" || return 1
        archive="$tmp_dir/lazygit.tar.gz"
        staged_binary="$tmp_dir/lazygit"
        if ! curl -fL --retry 3 \
            "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_LINUX_VERSION}/lazygit_${LAZYGIT_LINUX_VERSION}_Linux_${asset_arch}.tar.gz" \
            -o "$archive"; then
            rm -rf "$tmp_dir"
            log_error "Failed to download LazyGit ${LAZYGIT_LINUX_VERSION}"
            return 1
        fi
        if ! verify_sha256 "$checksum" "$archive"; then
            rm -rf "$tmp_dir"
            log_error "LazyGit archive checksum verification failed"
            return 1
        fi
        if ! tar -xzf "$archive" -C "$tmp_dir" lazygit || [ ! -f "$staged_binary" ]; then
            rm -rf "$tmp_dir"
            log_error "Failed to extract LazyGit ${LAZYGIT_LINUX_VERSION}"
            return 1
        fi
        chmod 0755 "$staged_binary"
        mkdir -p "$HOME/.local/bin"
        mv "$staged_binary" "$HOME/.local/bin/lazygit"
        rm -rf "$tmp_dir"
        export PATH="$HOME/.local/bin:$PATH"
    fi

    check_command lazygit || {
        log_error "LazyGit installation did not provide a lazygit executable"
        return 1
    }
    log_info "✓ LazyGit installed"
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

# Install btop
install_btop() {
    if check_command btop; then
        log_info "✓ btop already installed"
        return 0
    fi

    log_info "Installing btop..."
    if [ "$IS_MACOS" = "true" ]; then
        brew install btop
    else
        sudo apt-get install -y btop
    fi
    log_info "✓ btop installed"
}

# Install GitHub CLI
install_github_cli() {
    if check_command gh; then
        log_info "✓ GitHub CLI already installed"
        return 0
    fi

    log_info "Installing GitHub CLI..."
    if [ "$IS_MACOS" = "true" ]; then
        brew install gh
    else
        sudo apt-get install -y gh
    fi
    log_info "✓ GitHub CLI installed"
}

# Install GitLab CLI
install_gitlab_cli() {
    if check_command glab; then
        log_info "✓ GitLab CLI already installed"
        return 0
    fi

    log_info "Installing GitLab CLI..."
    if [ "$IS_MACOS" = "true" ]; then
        brew install glab
    else
        sudo apt-get install -y glab
    fi
    log_info "✓ GitLab CLI installed"
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

# Install Zellij
install_zellij() {
    if check_command zellij; then
        log_info "✓ Zellij already installed"
        return 0
    fi

    log_info "Installing Zellij..."
    if [ "$IS_MACOS" = "true" ]; then
        if ! brew install zellij; then
            log_warn "Zellij installation failed"
            return 1
        fi
    else
        if sudo apt-get install -y zellij; then
            log_info "✓ Zellij installed via apt"
            return 0
        fi

        log_warn "Zellij is not available from apt; installing official prebuilt binary..."
        local tmp_dir
        local url
        tmp_dir=$(mktemp -d)
        url="https://github.com/zellij-org/zellij/releases/latest/download/zellij-${ZELLIJ_ARCH}-unknown-linux-musl.tar.gz"

        pushd "$tmp_dir" > /dev/null
        if curl -fsSL "$url" -o zellij.tar.gz && tar -xzf zellij.tar.gz && sudo install -o root -g root -m 0755 zellij /usr/local/bin/zellij; then
            if /usr/local/bin/zellij --version &>/dev/null; then
                log_info "✓ Zellij installed from official prebuilt binary"
                popd > /dev/null
                rm -rf "$tmp_dir"
                return 0
            fi
        fi

        popd > /dev/null
        rm -rf "$tmp_dir"
        log_warn "Zellij installation failed"
        return 1
    fi
    log_info "✓ Zellij installed"
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
    
    install_jetbrains_mono_nerd_font || ((failed+=1))
    install_jq || ((failed+=1))
    install_yq || ((failed+=1))
    install_ripgrep || ((failed+=1))
    install_neovim || ((failed+=1))
    install_fd || ((failed+=1))
    install_lazygit || ((failed+=1))
    install_bat || ((failed+=1))
    install_btop || ((failed+=1))
    install_github_cli || ((failed+=1))
    install_gitlab_cli || ((failed+=1))
    install_tmux || ((failed+=1))
    install_zellij || ((failed+=1))
    install_kubectl || ((failed+=1))
    install_kubectx || ((failed+=1))
    install_k9s || ((failed+=1))
    install_helm || ((failed+=1))
    install_tfenv || ((failed+=1))
    install_aws_cli || ((failed+=1))
    
    if [ $failed -eq 0 ]; then
        log_info "✓ Common tools installation complete"
    else
        log_warn "Common tools installation complete with $failed failures"
    fi
}
