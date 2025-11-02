# Dotfiles

My personal configuration files for UNIX systems, managed either with nix and home-manager or symlinking.

## Quick Start

### NixOS Installation (Fresh System)

1. Boot from NixOS **minimal installer** ISO
2. Connect to the internet:
   ```bash
   # For WiFi: sudo systemctl start wpa_supplicant && wpa_cli
   # Or use: nmtui
   ```
3. Run the smart installer:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/e-ricus/.dotfiles/main/bootstrap/0 | bash
   ```
4. The interactive installer will:
   - **Detect available disks** and let you choose which one to use
   - **Ask for partition sizes** (EFI, swap, root)
   - **Automatically partition and format** the disk
   - **Mount everything** to `/mnt`
   - **Download the configuration** from GitHub
   - **Install NixOS** with the custom config
5. Reboot into the new system
6. Login as user `ericus` and run post-install setup:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/e-ricus/.dotfiles/main/bootstrap/1 | bash
   ```
7. The post-install script will:
   - Clone the dotfiles
   - Copy hardware configuration to dotfiles
   - Rebuild system using the flake
   - Set up home-manager

### macOS Setup

**Note**: Darwin configuration needs to be created first in `nix/darwin/flake.nix`

```bash
curl -fsSL https://raw.githubusercontent.com/e-ricus/.dotfiles/main/bootstrap/1 | bash
```

### Other Linux Distributions

```bash
curl -fsSL https://raw.githubusercontent.com/e-ricus/.dotfiles/main/bootstrap/1 | bash
```

## 📁 Repository Structure

```
.dotfiles/
├── bootstrap/           # Bootstrap scripts
│   ├── 0               # Smart NixOS installer with interactive partitioning
│   ├── 1               # Post-install setup (all systems, after first boot)
│   └── lib.sh          # Shared functions
├── nix/                # Nix configurations
│   ├── nixos/          # NixOS system configuration (flake-based)
│   │   ├── flake.nix   # Flake with nixos-x86 and nixos-arm configs
│   │   ├── configuration.nix           # Main system config
│   │   └── hardware-configuration.nix  # Generated, copied here by bootstrap/1
│   ├── darwin/         # macOS nix-darwin configuration (empty, needs setup)
│   └── home-manager/   # home-manager configuration (flake-based)
│       ├── flake.nix
│       ├── homes/      # User-specific configs (linux.nix, mac.nix)
│       ├── modules/    # Modular configurations
│       ├── config/     # Extra native config files (not nix)
│       └── common.nix  # Shared configuration
├── bin/
│   └── symlinkmanager  # Smart symlink manager script
├── symlink.conf        # Symlink configuration
├── nvim/               # Neovim configuration
│   ├── init.lua
│   └── lua/
├── ideavim/            # IdeaVim configuration
│   └── .ideavimrc
└── (other configs)/    # Other dotfiles
```

## Bootstrap Workflow

### NixOS Two-Stage Installation

**Stage 0 (Smart Installer)**: Run from the NixOS minimal installer ISO
- **Interactive disk selection**: Lists all available disks with size/model info
- **Custom partition sizes**: Prompts for EFI size (default 512MB) and swap size (default 8GB, 0 to skip)
- **Automatic partitioning**: Creates GPT partition table with proper filesystem types
- **Smart formatting**: Handles both `/dev/sda` and `/dev/nvme0n1` naming schemes
- **Auto-mounting**: Mounts all partitions to `/mnt` correctly
- **Hardware config generation**: Runs `nixos-generate-config` for the specific hardware
- **Downloads the config**: Fetches `configuration.nix` directly from GitHub (raw file)
- **Standard installation**: Runs `nixos-install` with flakes already enabled

**Stage 1 (Post-Install)**: Run after first boot into installed system
- **Clones dotfiles**: Gets the dotfiles from GitHub to `~/.dotfiles`
- **Copies hardware config**: Moves `/etc/nixos/hardware-configuration.nix` to dotfiles for version control
- **Architecture detection**: Automatically detects x86_64 or aarch64
- **Flake rebuild**: Rebuilds system using `sudo nixos-rebuild switch --flake ~/.dotfiles/nix/nixos#nixos-x86`
- **Sets up home-manager**: Symlinks config and runs `home-manager switch`
- **Symlinks dotfiles**: Uses symlinkmanager to link all other dotfiles

### Why Two Stages?

1. **Stage 0** must run from the installer environment to partition disks and access `/mnt`
2. **Stage 1** needs a fully booted system with the user account for proper flake setup

This approach ensures:
- **No manual partitioning needed** - fully automated with user input
- **Hardware config preserved** - copied to dotfiles for future rebuilds
- **Flake-based from the start** - system uses flake immediately after post-install
- **Clean separation** - system vs user configuration
- **Reproducible** - can reinstall on any machine by running the same two commands

## What's Included

### System Configuration
- **NixOS**: Minimal system config with Hyprland (flake-based)
- **macOS**: nix-darwin configuration
- **Linux**: Nix package manager setup

### Home Manager
- **Hyprland**: Wayland compositor with custom config
- **Waybar**: Status bar with custom styling
- **Alacritty**: Terminal emulator
- **Fish & Zsh**: Shell configurations with zinit
- **Git**: Version control configuration
- **Starship**: Cross-shell prompt

## Making Changes

### System Configuration (NixOS)

```bash
# Edit system config in the dotfiles
nvim ~/.dotfiles/nix/nixos/configuration.nix

# Stage changes (required for flakes!)
cd ~/.dotfiles/nix/nixos
git add .

# Apply changes
sudo nixos-rebuild switch --flake ~/.dotfiles/nix/nixos#nixos-x86
# Or for ARM: sudo nixos-rebuild switch --flake ~/.dotfiles/nix/nixos#nixos-arm
```

### Home Manager Configuration

```bash
# Edit home-manager config
nvim ~/.config/home-manager/modules/shell.nix

# Stage changes (required for flakes!)
cd ~/.config/home-manager
git add .

# Apply changes
home-manager switch --flake ~/.config/home-manager#ericus
```

### Dotfiles (Neovim, Tmux, etc.)

Dotfiles not managed in home-manager are managed with a custom symlink manager (`bin/symlinkmanager`) that intelligently handles both full directory symlinks and content merging.

```bash
# View symlink.conf to see what's configured
cat ~/.dotfiles/symlink.conf

# Check current status
cd ~/.dotfiles
bin/symlinkmanager status all

# Create all configured symlinks
bin/symlinkmanager link all

# Create specific configured symlinks
bin/symlinkmanager link nvim ghostty

# Remove all symlinks
bin/symlinkmanager unlink all
```

**How it works:**
- If target doesn't exist: Symlinks entire directory
- If target exists: Merges contents (symlinks individual files/dirs)
- Skips existing files with warnings (never overwrites)

**Example:**
```conf
# symlink.conf
nvim -> ~/.config/nvim    # Full directory or merge contents
ideavim -> ~/             # Merges into existing home directory
```

Changes apply immediately, no rebuild.

## Managing Packages

## Key Commands

### Home Manager
```bash
# Apply configuration
home-manager switch --flake ~/.config/home-manager#ericus

# Update packages
cd ~/.config/home-manager
nix flake update
home-manager switch --flake .#ericus

# Rollback
home-manager generations
home-manager switch --switch-generation [NUMBER]
```

### NixOS
```bash
# Rebuild system
sudo nixos-rebuild switch --flake ~/.dotfiles/nix/nixos#nixos-x86

# Update system (flake-based)
cd ~/.dotfiles/nix/nixos
nix flake update
git add flake.lock  # Stage the updated lock file
sudo nixos-rebuild switch --flake .#nixos-x86
```

### Cleanup
```bash
# Clean old generations
nix-collect-garbage -d
home-manager expire-generations "-7 days"

# Re-link dotfiles if needed
cd ~/.dotfiles
bin/symlinkmanager link all
```

##  Documentation

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)

## Old configuration
in Config.md
