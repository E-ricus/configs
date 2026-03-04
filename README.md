# config

My personal configuration files for UNIX systems, managed either with nix and home-manager or symlinking.

## Quick Start

### NixOS Installation (Fresh System)

1. Boot from NixOS **minimal installer** ISO
2. **Connect to the internet** (required to download installer):
   ```bash
   # For WiFi: sudo systemctl start wpa_supplicant && wpa_cli
   # Or use: nmtui
   ```
3. Download and run the bootstrap installer:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/e-ricus/configs/main/bootstrap/install > install.sh
   sudo bash install.sh <hostname>
   ```
   Example:
   ```bash
   sudo bash install.sh lenovo-work
   ```
4. The installer will prompt to select a starting step:
   ```
   1) Full bootstrap (disko -> install -> post-install)
   2) Disko only (partition & format)
   3) NixOS install only (skip partitioning)
   4) Post-install only (set passwords)
   ```
5. **Full bootstrap** will:
   - Clone configs to `/tmp/configs`
   - Run **disko** to partition, format (LUKS encrypted), and mount the disk
   - Clone configs to `/mnt/home/ericus/configs` (persists into installed system)
   - Run **nixos-install** with the flake configuration
   - Prompt for root and user passwords
   - Print post-boot instructions for TPM2 and Secure Boot setup
6. Reboot into the new system

### Post-Boot Setup (TPM2 + Secure Boot)

After the first boot into the installed system:

**1. Enroll TPM2** (auto-unlock LUKS without password):
```bash
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p2
```

**2. Enable Secure Boot** (for hosts using lanzaboote):
1. Reboot into UEFI firmware settings (F1 on Lenovo ThinkPads)
2. Go to Security > Secure Boot
3. Enable Secure Boot
4. Reset to Setup Mode (clear all Secure Boot keys)
5. Save and boot into NixOS
6. Lanzaboote will auto-generate and enroll keys, then reboot
7. Verify: `sudo sbctl status`

**3. Re-enroll TPM2** with Secure Boot active (binds LUKS unlock to Secure Boot state):
```bash
sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p2
```

### macOS Setup

1. **Install Nix first**:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```
2. Restart the terminal, then:
   ```bash
   git clone https://github.com/e-ricus/configs.git ~/configs
   cd ~/configs/nix
   sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ".#work-mac"
   ```

## Repository Structure

```
configs/
├── bootstrap/           # Bootstrap scripts
│   ├── install         # Unified NixOS installer (disko + nixos-install + post-install)
│   └── lib.sh          # Shared functions
├── nix/                # Unified Nix configurations
│   ├── flake.nix       # Single unified flake for all hosts
│   ├── flake.lock      # Dependency lock file
│   ├── ARCHITECTURE.md # Detailed architecture documentation
│   ├── lib/
│   │   └── mksystem.nix  # Helper function for system creation
│   ├── modules/        # NixOS system modules (toggleable)
│   │   ├── default.nix           # Imports all modules + sets defaults
│   │   ├── base-system.nix       # Core system (networking, nix settings)
│   │   ├── boot-config.nix       # Bootloader (systemd-boot or lanzaboote)
│   │   └── (other modules)
│   ├── hosts/          # Host-specific configurations
│   │   ├── nixos/
│   │   │   ├── lenovo-work/
│   │   │   │   ├── configuration.nix        # NixOS system config
│   │   │   │   ├── disko.nix                # Disk layout (LUKS + btrfs)
│   │   │   │   ├── home.nix                 # Home-manager config
│   │   │   │   └── hardware-configuration.nix
│   │   │   ├── laptop-amd/
│   │   │   ├── laptop-lenovo/
│   │   │   └── vm-aarch64/
│   │   └── darwin/
│   │       └── work-mac/
│   ├── home/           # Home-manager modules (toggleable)
│   │   ├── default.nix   # Imports all modules + sets defaults
│   │   ├── config/       # External config files
│   │   └── modules/      # Home-manager feature modules
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
└── (other configs)
```

## Bootstrap Workflow

### Single-Script Installation

The bootstrap is a single script (`bootstrap/install`) that handles the entire NixOS installation:

```bash
sudo bash install <hostname>
```

The script provides a step selector so you can resume from any point if something fails:

| Step | What it does |
|------|-------------|
| **1. Disko** | Clones configs, runs disko to partition/format/mount (LUKS encrypted + btrfs), clones configs to installed system |
| **2. NixOS Install** | Runs `nixos-install --flake` to build and install the system |
| **3. Post-install** | Sets user password, fixes file ownership, prints TPM2/Secure Boot instructions |

**Prerequisites**: Must be connected to the internet from the NixOS minimal installer ISO.

**Note**: The script uses `TARGET_USER="ericus"` by default. Edit this variable at the top of `bootstrap/install` if your flake uses a different username.

### Disk Encryption (LUKS + btrfs)

Hosts that include a `disko.nix` configuration get full disk encryption:

- **LUKS** encryption on the root partition (interactive password during install)
- **btrfs** filesystem with subvolumes for `/`, `/home`, `/nix`, and swap
- **TPM2** auto-unlock (enrolled after first boot, no password on subsequent boots)
- **Secure Boot** via lanzaboote (optional, per-host)

The disk layout is defined declaratively in each host's `disko.nix` and applied by the disko tool during installation.

### Adding a New Host

1. Create host directory: `hosts/nixos/new-host/`
2. Create `configuration.nix` with enabled modules
3. Create `home.nix` with enabled modules
4. Create `disko.nix` with disk layout (or add `hardware-configuration.nix` for hosts without disko)
5. Add to `flake.nix` using `mkSystem` helper
   - Include `inputs.disko.nixosModules.disko` in modules if using disko
   - Include `inputs.lanzaboote.nixosModules.lanzaboote` if using Secure Boot
6. Build and install: `sudo bash bootstrap/install new-host`

See [nix/ARCHITECTURE.md](nix/ARCHITECTURE.md) for detailed examples and module documentation.

## Making Changes

### System Configuration (NixOS)

System rebuilds include both system configuration AND home-manager configuration.

```bash
# Edit system config
nvim ~/configs/nix/hosts/nixos/lenovo-work/configuration.nix

# Stage changes (required for flakes!)
cd ~/configs/nix
git add .

# Apply changes (includes home-manager)
sudo nixos-rebuild switch --flake ~/configs/nix#lenovo-work

# Or use the alias:
nos   # Rebuilds system + home-manager for current hostname
```

### Home Manager Configuration (Hybrid Approach)

**Option 1: Fast iteration (home-manager only)**
```bash
# Edit home-manager config
nvim ~/configs/nix/home/modules/fish.nix

# Stage changes (required for flakes!)
cd ~/configs/nix
git add .

# Apply changes (fast, no system rebuild)
home-manager switch --flake ~/configs/nix#<user>-<hostname>

# Or use the alias:
hm    # Quick home-manager switch
```

**Option 2: Full rebuild (system + home-manager)**
```bash
sudo nixos-rebuild switch --flake ~/configs/nix#lenovo-work

# Or use the alias:
nos   # Full system rebuild including home-manager
```

### Config Files (Neovim, Ghostty in mac)

Config files not managed in home-manager are managed with a custom symlink manager (`bin/symlinkmanager`):

```bash
# View symlink.conf to see what's configured
cat ~/configs/symlink.conf

# Check current status
cd ~/configs
bin/symlinkmanager status all

# Create all configured symlinks
bin/symlinkmanager link all

# Create specific configured symlinks
bin/symlinkmanager link nvim ghostty

# Remove all symlinks
bin/symlinkmanager unlink all
```

## Key Commands

### Shell Aliases (Available in Fish & Zsh)

```bash
# Home-manager (standalone - fast iteration)
hm      # Switch home-manager config
hmu     # Update flake + switch home-manager

# System rebuilds (includes home-manager + system)
nos     # NixOS rebuild for current hostname
nom     # Darwin rebuild for current hostname

# Combined (update + rebuild)
nosu    # Update flake + rebuild NixOS system

# Maintenance
ngc     # Garbage collection: nix-collect-garbage --delete-older-than 2d
```

### Cleanup
```bash
# Clean old generations
nix-collect-garbage -d
home-manager expire-generations "-7 days"

# Re-link config files if needed
cd ~/configs
bin/symlinkmanager link all
```

## Architecture: Modular Nix Configuration

This configuration uses a **fully modular, opt-in architecture** with toggleable modules that can be enabled/disabled per host.

For detailed architecture documentation, see [nix/ARCHITECTURE.md](nix/ARCHITECTURE.md)

### Module Pattern

All modules follow this structure:

```nix
{config, lib, pkgs, ...}: {
  options = {
    module-name.enable = lib.mkEnableOption "description";
  };

  config = lib.mkIf config.module-name.enable {
    # Configuration here
  };
}
```

## Documentation

- [Architecture Documentation](nix/ARCHITECTURE.md)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Disko Documentation](https://github.com/nix-community/disko)
- [Lanzaboote Documentation](https://github.com/nix-community/lanzaboote)
- [Niri Documentation](https://github.com/YaLTeR/niri)
- [Nix Pills](https://nixos.org/guides/nix-pills/)
