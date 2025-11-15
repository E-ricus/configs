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
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

# Detect system type
detect_system() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" = "nixos" ]; then
            echo "nixos"
        elif [ "$(uname)" = "Linux" ]; then
            echo "linux"
        fi
    elif [ "$(uname)" = "Darwin" ]; then
        echo "darwin"
    else
        echo "unknown"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ensure git is installed
ensure_git() {
    if command_exists git; then
        log_success "Git is already installed"
        return 0
    fi

    log_info "Installing git..."
    local system=$(detect_system)
    
    case $system in
        nixos)
            nix-env -iA nixos.git
            ;;
        darwin)
            if ! command_exists brew; then
                log_error "Homebrew not found. Please install Homebrew first."
                exit 1
            fi
            brew install git
            ;;
        linux)
            if command_exists apt-get; then
                sudo apt-get update && sudo apt-get install -y git
            elif command_exists dnf; then
                sudo dnf install -y git
            elif command_exists pacman; then
                sudo pacman -S --noconfirm git
            else
                log_error "Unsupported package manager. Please install git manually."
                exit 1
            fi
            ;;
        *)
            log_error "Unknown system type"
            exit 1
            ;;
    esac
    
    log_success "Git installed successfully"
}

# Clone configs repo
clone_configs() {
    local target_dir="${1:-$HOME/configs}"
    local repo_url="https://github.com/e-ricus/configs.git"

    if [ -d "$target_dir" ]; then
        log_warning "Configs directory already exists at $target_dir"
        read -p "Do you want to remove it and re-clone? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$target_dir"
        else
            log_info "Using existing configs directory"
            return 0
        fi
    fi

    log_info "Cloning configs repository..."
    git clone "$repo_url" "$target_dir"
    log_success "Configs cloned to $target_dir"
}

# Create symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"
    
    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$target")"
    
    # Backup existing file/directory
    if [ -e "$target" ] || [ -L "$target" ]; then
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        log_warning "Backing up existing $target to $backup"
        mv "$target" "$backup"
    fi
    
    # Create symlink
    ln -sf "$source" "$target"
    log_success "Symlinked $source -> $target"
}

# Install Nix (for non-NixOS systems)
install_nix() {
    if command_exists nix; then
        log_success "Nix is already installed"
        return 0
    fi
    
    log_info "Installing Nix package manager..."
    
    # Use Determinate Systems installer (with vanilla Nix option)
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
        sh -s -- install --no-confirm
    
    log_success "Nix installed successfully"
    
    # Source nix
    if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
    fi
}

# Install nix-darwin
install_nix_darwin() {
    if command_exists darwin-rebuild; then
        log_success "nix-darwin is already installed"
        return 0
    fi
    
    log_info "Installing nix-darwin..."
    
    # Run nix-darwin installer
    nix run nix-darwin -- switch --flake ~/configs/nix/darwin
    
    log_success "nix-darwin installed successfully"
}

# Note: We use symlinkmanager instead of GNU Stow
# symlinkmanager is included in the configs repo at bin/symlinkmanager
# No separate installation needed

# Symlink configs using symlinkmanager
stow_configs() {
    local configs_dir="${1:-$HOME/configs}"

    log_info "Symlinking configuration files..."

    cd "$configs_dir"

    # Check if symlinkmanager exists and use it
    if [ -x "$configs_dir/bin/symlinkmanager" ]; then
        log_info "Using symlinkmanager with symlink.conf"
        "$configs_dir/bin/symlinkmanager" link all
    else
        log_error "symlinkmanager not found at $configs_dir/bin/symlinkmanager"
        log_error "Cannot proceed with config symlinking"
        log_info "Please ensure your configs repository is properly cloned"
        return 1
    fi

    log_success "Configs symlinked successfully"
}

# Get username for home-manager
get_hm_user() {
    local system=$(detect_system)
    case $system in
        nixos|linux)
            # For NixOS and Linux, use ericus
            echo "ericus"
            ;;
        darwin)
            # For macOS, use ericpuentes (note: check if this matches your actual username)
            echo "ericpuentes"
            ;;
    esac
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
