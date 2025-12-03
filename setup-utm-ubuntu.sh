#!/usr/bin/env bash

# UTM Ubuntu Server Setup Script
# Creates a UTM VM with Ubuntu 24 LTS (x86_64) for testing dotfiles

set -euo pipefail

# VM Configuration
VM_NAME="ubuntu-24-dotfiles-test"
VM_CPUS=2
VM_RAM=4096  # MB
VM_DISK=40   # GB
UBUNTU_ISO_URL="https://releases.ubuntu.com/24.04/ubuntu-24.04-live-server-amd64.iso"
UBUNTU_ISO="ubuntu-24.04-live-server-amd64.iso"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

# Check if UTM is installed
check_utm() {
    if [ ! -d "/Applications/UTM.app" ]; then
        log_error "UTM not found. Please install UTM from https://mac.getutm.app/"
        exit 1
    fi
    log_info "✓ UTM found"
}

# Download Ubuntu ISO
download_ubuntu_iso() {
    if [ -f "$UBUNTU_ISO" ]; then
        log_info "✓ Ubuntu ISO already downloaded"
        return 0
    fi
    
    log_info "Downloading Ubuntu 24.04 LTS ISO..."
    curl -L -o "$UBUNTU_ISO" "$UBUNTU_ISO_URL"
    log_success "Ubuntu ISO downloaded"
}

# Create UTM VM configuration
create_utm_vm() {
    log_info "Creating UTM VM configuration..."
    
    cat > utm-config.json << EOF
{
  "name": "$VM_NAME",
  "architecture": "x86_64",
  "cpus": $VM_CPUS,
  "memory": $VM_RAM,
  "drives": [
    {
      "type": "disk",
      "size": $VM_DISK,
      "interface": "virtio"
    },
    {
      "type": "cdrom",
      "path": "$(pwd)/$UBUNTU_ISO"
    }
  ],
  "network": {
    "mode": "shared"
  },
  "display": {
    "type": "console"
  }
}
EOF
    
    log_success "VM configuration created"
}

# Print setup instructions
print_instructions() {
    cat << 'EOF'

╔════════════════════════════════════════════════════════════════╗
║           UTM Ubuntu Server Setup Instructions                 ║
╚════════════════════════════════════════════════════════════════╝

1. Open UTM application

2. Create New VM:
   - Click "+" → "Virtualize"
   - Select "Linux"
   
3. VM Configuration:
   - Name: ubuntu-24-dotfiles-test
   - Architecture: x86_64
   - CPUs: 2
   - RAM: 4096 MB (4 GB)
   - Storage: 40 GB

4. Boot Configuration:
   - Select "Use ISO image"
   - Browse and select: ubuntu-24.04-live-server-amd64.iso
   
5. Network:
   - Mode: Shared Network
   
6. Start VM and Install Ubuntu:
   - Boot from ISO
   - Select "Install Ubuntu Server"
   - Follow installation wizard:
     * Language: English
     * Keyboard: Your layout
     * Network: DHCP (automatic)
     * Storage: Use entire disk
     * Profile:
       - Name: ubuntu
       - Server name: ubuntu-test
       - Username: ubuntu
       - Password: ubuntu
     * SSH: Install OpenSSH server
     * Snaps: Skip
   
7. After Installation:
   - Reboot VM
   - Login with ubuntu/ubuntu
   - Update system:
     sudo apt update && sudo apt upgrade -y
   
8. Test Dotfiles:
   git clone <your-repo> ~/.dotfiles
   cd ~/.dotfiles
   ./bootstrap.sh

╔════════════════════════════════════════════════════════════════╗
║                    Quick Commands                              ║
╚════════════════════════════════════════════════════════════════╝

# SSH into VM (after getting IP):
ssh ubuntu@<vm-ip>

# Get VM IP:
ip addr show

# Test bootstrap:
cd ~/.dotfiles && ./bootstrap.sh

# Verify installation:
./verify.sh

EOF
}

# Main function
main() {
    log_info "UTM Ubuntu Server Setup"
    echo ""
    
    check_utm
    download_ubuntu_iso
    create_utm_vm
    
    log_success "Setup preparation complete!"
    print_instructions
}

main
