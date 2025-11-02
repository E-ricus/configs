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
3. Run the installation bootstrap:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/e-ricus/.dotfiles/main/bootstrap/0 | bash
   ```
4. The script will guide you through:
   - Disk partitioning (with instructions)
   - Hardware configuration generation
   - System installation
5. Reboot into your new system
6. Login as user `ericus` and run post-install setup:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/e-ricus/.dotfiles/main/bootstrap/1 | bash
   ```

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
│   ├── 0               # NixOS installer setup (from live USB, before install)
│   ├── 1               # Post-install setup (all systems, after first boot)
│   └── lib.sh          # Shared functions
├── nix/                # Nix configurations
│   ├── nixos/          # NixOS system configuration
│   ├── darwin/         # macOS nix-darwin configuration (empty, needs setup)
│   └── home-manager/   # home-manager configuration
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

**Stage 0 (Installer)**: Run from the NixOS minimal installer ISO
- Guides you through disk partitioning
- Generates hardware-configuration.nix (critical for your hardware)
- Installs your custom NixOS configuration
- Runs nixos-install
- Prepares dotfiles for post-install

**Stage 1 (Post-Install)**: Run after first boot into installed system
- Symlinks system configuration for easy editing
- Sets up home-manager with your user configuration
- Symlinks all dotfiles using symlinkmanager
- Installs all user packages and programs

### Why Two Stages?

1. **Stage 0** must run from the installer environment while `/mnt` is available
2. **Stage 1** needs a fully booted system with your user account to set up home-manager

This approach ensures:
- Correct hardware detection and configuration
- Proper disk setup and mounting
- Clean separation between system and user configuration
- Ability to manage everything from dotfiles after installation

## What's Included

### System Configuration
- **NixOS**: Minimal system config with Hyprland
- **macOS**: nix-darwin configuration
- **Linux**: Nix package manager setup

### Home Manager
- **Hyprland**: Wayland compositor with custom config
- **Waybar**: Status bar with custom styling
- **Alacritty**: Terminal emulator
- **Fish & Zsh**: Shell configurations with zinit
- **Git**: Version control configuration
- **Starship**: Cross-shell prompt

### Applications
- Neovim (managed separately)
- Tmux
- Firefox
- Rofi (app launcher)
- And more...

## Making Changes

### System Configuration (NixOS)

```bash
# Edit system config
sudo nvim /etc/nixos/configuration.nix

# Apply changes
sudo nixos-rebuild switch
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
sudo nixos-rebuild switch

# Update system
sudo nix-channel --update
sudo nixos-rebuild switch
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
