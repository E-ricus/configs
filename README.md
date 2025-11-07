# Dotfiles

My personal configuration files for UNIX systems, managed either with nix and home-manager or symlinking.

## Quick Start

### NixOS Installation (Fresh System)

1. Boot from NixOS **minimal installer** ISO
2. **Connect to the internet first** (required to download installer):
   ```bash
   # For WiFi: sudo systemctl start wpa_supplicant && wpa_cli
   # Or use: nmtui
   ```
3. Download and run the smart installer:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/e-ricus/.dotfiles/main/bootstrap/0 > install.sh
   sudo bash install.sh
   ```
4. The interactive installer will:
   - **Detect available disks** and let you choose which one to use
   - **Ask for partition sizes** (EFI, swap, root)
   - **Automatically partition and format** the disk
   - **Mount everything** to `/mnt`
   - **Generate hardware configuration** for your specific hardware
   - **Install NixOS** with the generated config
5. Reboot into the new system
6. **Login as root** (user doesn't exist yet) and run post-install setup:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/e-ricus/.dotfiles/main/bootstrap/1 > setup.sh
   bash setup.sh
   ```
7. The post-install script will:
   - Clone the dotfiles to /root/.dotfiles
   - Ask you to select architecture (x86_64 or aarch64)
   - Copy hardware configuration to dotfiles
   - Rebuild system using the flake (creates user `ericus`)
   - Prompt you to set password for user `ericus`

### macOS Setup

1. **Install Nix first** using the Determinate Systems installer:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```
2. Restart your terminal, then run the bootstrap script:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/e-ricus/.dotfiles/main/bootstrap/1 > setup.sh
   bash setup.sh
   ```
3. The script will:
   - Clone dotfiles to ~/.dotfiles
   - Install nix-darwin
   - Set up home-manager (integrated)

### Other Linux Distributions

**TODO**: Not yet implemented in bootstrap scripts.

For now, you can manually:
1. Install Nix using Determinate Systems installer
2. Clone this repo
3. Set up standalone home-manager

## 📁 Repository Structure

```
.dotfiles/
├── bootstrap/           # Bootstrap scripts
│   ├── 0               # Smart NixOS installer with interactive partitioning
│   ├── 1               # Post-install setup (all systems, after first boot)
│   └── lib.sh          # Shared functions
├── nix/                # Unified Nix configurations
│   ├── flake.nix       # Single unified flake for all systems
│   ├── flake.lock      # Dependency lock file
│   ├── lib/
│   │   └── mksystem.nix  # Helper function for system creation
│   ├── systems/        # System configurations
│   │   ├── nixos/
│   │   │   ├── x86_64/
│   │   │   │   ├── configuration.nix
│   │   │   │   └── hardware-configuration.nix
│   │   │   └── aarch64/
│   │   │       ├── configuration.nix
│   │   │       └── hardware-configuration.nix
│   │   └── darwin/
│   │       └── work-mac/
│   │           └── configuration.nix
│   ├── home/           # Home-manager configurations
│   │   ├── common.nix  # Shared home-manager config
│   │   ├── linux.nix   # Linux-specific home config
│   │   ├── mac.nix     # macOS-specific home config
│   │   ├── config/     # External config files (fish, zsh init, etc.)
│   │   └── modules/    # Home-manager modules
│   └── devshells/      # Separate dev environment flake
│       └── flake.nix
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

**Stage 0 (Smart Installer)**: Run from the NixOS minimal installer ISO (as root with sudo)
- **Prerequisites**: Must be connected to the internet to download the script
- **Download and run**: Downloads script first, then runs with sudo (not piped to bash)
- **Interactive disk selection**: Lists all available disks with size/model info
- **Custom partition sizes**: Prompts for EFI size (default 512MB) and swap size (default 8GB, 0 to skip)
- **Automatic partitioning**: Creates GPT partition table with proper filesystem types
- **Smart formatting**: Handles both `/dev/sda` and `/dev/nvme0n1` naming schemes
- **Auto-mounting**: Mounts all partitions to `/mnt` correctly
- **Hardware config generation**: Runs `nixos-generate-config` for the specific hardware
- **Standard installation**: Runs `nixos-install` with generated configuration

**Stage 1 (Post-Install)**: Run after first boot into installed system (as root)
- **Run as root**: User account doesn't exist yet after fresh install
- **Clones dotfiles**: Gets the dotfiles from GitHub to `/root/.dotfiles`
- **Copies hardware config**: Moves `/etc/nixos/hardware-configuration.nix` to dotfiles for version control
- **Interactive architecture selection**: Prompts to choose x86_64 or aarch64
- **Flake rebuild**: Rebuilds system using `nixos-rebuild switch --flake /root/.dotfiles/nix#nixos-x86`
- **Creates user**: The flake rebuild creates the `ericus` user account
- **Sets password**: Prompts to set password for user `ericus`
- **Home-manager included**: Integrated in system rebuild (no separate setup needed)

### Why Two Stages?

1. **Stage 0** must run from the installer environment to partition disks and access `/mnt`
2. **Stage 1** needs a fully booted system to clone dotfiles and rebuild with the flake

This approach ensures:
- **No manual partitioning needed** - fully automated with user input
- **No internet check**: User must connect before downloading (script download confirms connectivity)
- **Hardware config preserved** - copied to dotfiles for future rebuilds
- **Flake-based from the start** - system uses flake immediately after post-install
- **Clean separation** - installer vs system configuration
- **Reproducible** - can reinstall on any machine by running the same two commands

## What's Included

### System Configuration (Unified Flake)
- **NixOS**: System config with Hyprland for x86_64 and aarch64
- **macOS**: nix-darwin configuration for work-mac
- **Home-Manager**: Integrated as module in system configs
- **Standalone Home-Manager**: Also available for fast iteration

### Home Manager
- **Hyprland**: Wayland compositor with custom config (Linux only)
- **Waybar**: Status bar with custom styling (Linux only)
- **Alacritty**: Terminal emulator
- **Fish & Zsh**: Shell configurations with custom aliases
- **Git**: Version control configuration
- **Tmux**: Terminal multiplexer
- **Development tools**: Node.js, Go, Rust, Zig, and more

## Making Changes

### System Configuration (NixOS)

System rebuilds include both system configuration AND home-manager configuration.

```bash
# Edit system config
nvim ~/.dotfiles/nix/systems/nixos/x86_64/configuration.nix

# Stage changes (required for flakes!)
cd ~/.dotfiles/nix
git add .

# Apply changes (includes home-manager)
sudo nixos-rebuild switch --flake ~/.dotfiles/nix#nixos-x86
# Or for ARM VM: sudo nixos-rebuild switch --flake ~/.dotfiles/nix#nixos-arm

# Or use the alias:
nos   # Rebuilds system + home-manager for x86_64
```

### Home Manager Configuration (Hybrid Approach)

**Option 1: Fast iteration (home-manager only)**
```bash
# Edit home-manager config
nvim ~/.dotfiles/nix/home/modules/fish.nix

# Stage changes (required for flakes!)
cd ~/.dotfiles/nix
git add .

# Apply changes (fast, no system rebuild)
home-manager switch --flake ~/.dotfiles/nix#ericus

# Or use the alias:
hm    # Quick home-manager switch
```

**Option 2: Full rebuild (system + home-manager)**
```bash
# Use when making system-level changes or want everything in sync
sudo nixos-rebuild switch --flake ~/.dotfiles/nix#nixos-x86

# Or use the alias:
nos   # Full system rebuild including home-manager
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

### Shell Aliases (Available in Fish & Zsh)

```bash
# Home-manager (standalone - fast iteration)
hm      # Switch home-manager config: home-manager switch --flake ~/.dotfiles/nix#$USER
hmu     # Update flake + switch home-manager

# System rebuilds (includes home-manager + system)
nos     # NixOS rebuild: sudo nixos-rebuild switch --flake ~/.dotfiles/nix#nixos-x86
nom     # Darwin rebuild: darwin-rebuild switch --flake ~/.dotfiles/nix#work-mac

# Combined (update + rebuild)
nosu    # Update flake + rebuild NixOS system

# Maintenance
ngc     # Garbage collection: nix-collect-garbage --delete-older-than 2d
```

### Home Manager (Standalone)

For quick dotfile/package changes without system rebuild:

```bash
# Apply configuration
home-manager switch --flake ~/.dotfiles/nix#ericus
# Or use alias: hm

# Update packages
cd ~/.dotfiles/nix
nix flake update
home-manager switch --flake .#ericus
# Or use alias: hmu

# Rollback
home-manager generations
home-manager switch --switch-generation [NUMBER]
```

### NixOS (System + Home-Manager)

System rebuilds include both system AND home-manager configuration:

```bash
# Rebuild system (includes home-manager)
sudo nixos-rebuild switch --flake ~/.dotfiles/nix#nixos-x86
# Or use alias: nos

# For ARM VM:
sudo nixos-rebuild switch --flake ~/.dotfiles/nix#nixos-arm

# Update system and packages (flake-based)
cd ~/.dotfiles/nix
nix flake update
git add flake.lock  # Stage the updated lock file
sudo nixos-rebuild switch --flake .#nixos-x86
# Or use alias: nosu
```

### macOS (Darwin + Home-Manager)

```bash
# Rebuild system (includes home-manager)
darwin-rebuild switch --flake ~/.dotfiles/nix#work-mac
# Or use alias: nom

# Update
cd ~/.dotfiles/nix
nix flake update
darwin-rebuild switch --flake .#work-mac
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

## Architecture: Unified Flake Design

This configuration uses a **single unified flake** (`nix/flake.nix`) that:

- Defines all system configurations (NixOS x86/ARM + Darwin)
- Integrates home-manager as a module in system configs
- Also exports standalone home-manager configurations
- Shares a single `flake.lock` for consistency across all systems

### Benefits

✅ **Single source of truth** - All configurations in one place
✅ **Consistent package versions** - Shared flake.lock ensures same nixpkgs version
✅ **Home-manager integrated** - System rebuilds include home config
✅ **Fast iteration option** - Standalone home-manager for quick changes
✅ **Clean separation** - systems/ vs home/ directories
✅ **Multiple hardware configs** - Each system's hardware-configuration.nix versioned separately
✅ **No git stash dance** - Can version different hardware configs for different machines

### The Hybrid Approach

**System Rebuild** (slower, complete):
- Updates both system and home configuration
- Creates new system generation
- Use for: System-level changes, major updates

**Home-Manager Only** (faster, targeted):
- Updates only home configuration
- Doesn't create system generation
- Use for: Dotfile tweaks, package additions, alias changes

##  Documentation

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)

## Old configuration
in Config.md
