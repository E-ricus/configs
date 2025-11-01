# Dotfiles

My personal configuration files for UNIX systems, managed either with nix and home-manager or symlinking.

## Quick Start

### NixOS Installation

1. Boot from NixOS installer ISO
2. Complete the graphical installation
3. **Before rebooting**, run:

```bash
curl -fsSL https://raw.githubusercontent.com/e-ricus/.dotfiles/main/bootstrap/0-nixos-install | bash
```

4. Reboot into your new system
5. Login and run:

```bash
curl -fsSL https://raw.githubusercontent.com/e-ricus/.dotfiles/main/bootstrap/1-post-install | bash
```

### macOS Setup

```bash
curl -fsSL https://raw.githubusercontent.com/e-ricus/.dotfiles/main/bootstrap/1-post-install | bash
```

### Other Linux Distributions

```bash
curl -fsSL https://raw.githubusercontent.com/e-ricus/.dotfiles/main/bootstrap/1-post-install | bash
```

## 📁 Repository Structure

```
.dotfiles/
├── bootstrap/           # Bootstrap scripts
│   ├── 0-nixos-install # NixOS initial setup (from live USB)
│   ├── 1-post-install  # Post-install setup (all systems)
│   └── lib.sh          # Shared functions
├── nix/                # Nix configurations
│   ├── nixos/          # NixOS system configuration
│   ├── darwin/         # macOS nix-darwin configuration
│   ├── linux/          # Other Linux configuration
│   └── home-manager/   # home-manager configuration
│       ├── flake.nix
│       ├── hosts/      # Host-specific configs
│       ├── modules/    # Modular configurations
│       └── config/     # Config files
├── symlinkmanager      # Smart symlink manager script
├── symlink.conf        # Symlink configuration
├── nvim/               # Neovim configuration (flat structure!)
│   ├── init.lua
│   └── lua/
├── tmux/               # Tmux configuration
│   └── tmux.conf
├── ideavim/            # IdeaVim configuration
│   └── .ideavimrc
└── (other configs)/    # Other dotfiles
```

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

Dotfiles not managed in home-manager are managed with a custom symlink manager that intelligently handles both full directory symlinks and content merging.

```bash
# View symlink.conf to see what's configured
cat ~/.dotfiles/symlink.conf

# Check current status
cd ~/.dotfiles
symlinkmanager status

# Create all symlinks
symlinkmanager link

# Remove all symlinks
symlinkmanager unlink
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

**Note:** Dotfiles use a flat structure - no need for nested `.config` directories!

Changes apply immediately, no rebuild needed!

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
symlinkmanager link
```

##  Documentation

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)

## Old configuration
in Config.md
