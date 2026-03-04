#!/usr/bin/env bash
# Shared library functions for bootstrap scripts

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect system type
detect_system() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" = "nixos" ]; then
            echo "nixos"
            return
        fi
    fi
    echo "unknown"
}

# Ensure git is available (NixOS live environment)
ensure_git() {
    if command_exists git; then
        return 0
    fi
    log_info "Making git available..."
    nix-env -iA nixos.git
}

# Clone configs repo
clone_configs() {
    local target_dir="$1"
    local repo_url="https://github.com/e-ricus/configs.git"

    if [ -d "$target_dir" ]; then
        log_warning "Configs directory already exists at $target_dir"
        if confirm "Remove and re-clone?"; then
            rm -rf "$target_dir"
        else
            log_info "Using existing configs directory"
            return 0
        fi
    fi

    log_info "Cloning configs repository to $target_dir..."
    git clone "$repo_url" "$target_dir"
    log_success "Configs cloned to $target_dir"
}

# Prompt for confirmation
confirm() {
    local message="$1"
    read -p "$message (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Wait for user input
press_any_key() {
    read -n 1 -s -r -p "Press any key to continue..."
    echo
}
