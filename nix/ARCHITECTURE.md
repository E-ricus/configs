# Nix Configuration Architecture

This document describes the modular architecture of this Nix configuration, including design patterns, module structure, and usage examples.

## Overview

This configuration uses a **fully modular, opt-in architecture** with toggleable modules that can be enabled/disabled per host. All modules follow a consistent pattern with options and conditional configuration.

## Module Pattern

All modules follow this structure:

```nix
{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    module-name.enable =
      lib.mkEnableOption "description of what this enables";
  };

  config = lib.mkIf config.module-name.enable {
    # Configuration here
  };
}
```

### Sub-options Pattern

Modules can have nested sub-options:

```nix
options = {
  module-name = {
    enable = lib.mkEnableOption "main feature";
    sub-feature.enable = lib.mkEnableOption "optional sub-feature";
  };
};

config = lib.mkIf config.module-name.enable {
  # Main config

  # Sub-feature specific (can be toggled independently)
  sub-option = lib.mkIf config.module-name.sub-feature.enable {
    # Sub-feature config
  };
};
```

### Enum Options Pattern

For mutually exclusive choices, use enum types:

```nix
options = {
  module-name = {
    enable = lib.mkEnableOption "feature";
    type = lib.mkOption {
      type = lib.types.enum ["option-a" "option-b"];
      default = "option-a";
      description = "Which variant to use.";
    };
  };
};

config = lib.mkIf cfg.enable {
  # Common config
  some-setting = cfg.type == "option-a";  # Boolean from comparison

  # Variant-specific config
  other-setting = lib.mkIf (cfg.type == "option-b") {
    # ...
  };
};
```

This pattern is used by `boot-config.nix` (systemd-boot vs lanzaboote) and `desktop-wayland.nix` (hyprland vs niri).

## Priority Levels

The configuration uses NixOS's priority system to allow defaults at different levels:

- **1000** (`lib.mkDefault`) - Base defaults in `default.nix`
- **1500** (`lib.mkOptionDefault`) - Module-specific defaults (e.g., hyprland enabling walker/waybar)
- **lowest** (explicit setting) - User choice in host's `home.nix` or `configuration.nix`
- **Lower numbers = higher priority** (user settings always win)

### Example: Hyprland Auto-enables Dependencies

```nix
# In hyprland.nix
config = lib.mkIf config.hyprland-config.enable {
  # Auto-enable dependencies with lower priority than explicit settings
  walker-config.enable = lib.mkDefault true;  # Can be overridden
  waybar-config.enable = lib.mkDefault true;  # Can be overridden
};
```

## Directory Structure

```
nix/
├── flake.nix                    # Main flake configuration
├── lib/
│   └── mksystem.nix            # Helper to create system configurations
├── modules/                     # NixOS system modules
│   ├── default.nix             # Imports all modules + sets defaults
│   ├── base-system.nix         # Core system (networking, nix settings)
│   ├── boot-config.nix         # Bootloader (systemd-boot or lanzaboote)
│   ├── (other system modules)
├── home/                        # Home-manager configuration
│   ├── default.nix             # Imports all modules + sets defaults
│   ├── modules/
│   │   ├── git.nix             # Git configuration
│   │   ├── fish.nix            # Fish shell
│   │   ├── (other home modules)
│   └── config/                 # External config files
└── hosts/
    ├── nixos/
    │   ├── lenovo-work/
    │   │   ├── configuration.nix        # NixOS system config
    │   │   ├── disko.nix                # Disk layout (LUKS + btrfs)
    │   │   ├── home.nix                 # Home-manager config
    │   │   └── hardware-configuration.nix
    │   ├── laptop-amd/
    │   ├── laptop-lenovo/
    │   └── vm-aarch64/
    └── darwin/
        └── work-mac/
            ├── configuration.nix
            └── home.nix
```

## Home-Manager Modules

### Default Behavior

In `/home/default.nix`:
- `common-packages.enable = lib.mkDefault true` - Always enabled
- All other modules default to `false`

### Module Categories

**Always Enabled:**
- `common-packages` - Essential CLI tools, dev tools, LLMs

**Platform-Specific:**
- `linux-packages` - Linux GUI apps (Firefox, Brave, etc.)
- `mac-packages` - macOS-specific tools

**Shell & Terminal:**
- `fish-config` - Fish shell configuration
- `zsh-config` - Zsh shell configuration
- `alacritty-config` - Alacritty terminal
- `ghostty-config` - Ghostty terminal
- `tmux-config` - Tmux configuration

**Desktop Environment:**
- `wayland` - Wayland configuration (parent module)
  - Sub-option `compositor`: Choose between "hyprland" or "niri"
  - Provides shared Wayland packages and Mako notifications
  - Auto-enables compositor-specific dependencies (walker, waybar, swaybg)
- `aerospace-config` - Aerospace (macOS)

**Development:**
- `git-config` - Git configuration

**Networking:**
- `wireguard-config` - WireGuard VPN helpers

### Wayland Module Architecture

The wayland configuration uses a hierarchical module structure with a parent `wayland` module that manages compositor selection and shared configuration.

**Parent Module (`wayland.nix`):**
- Main option: `wayland.enable` - Enables Wayland support
- Compositor selection: `wayland.compositor` - Enum ["hyprland" | "niri"]
- Shared packages: wl-clipboard, networkmanagerapplet, pavucontrol, brightnessctl, libnotify
- Mako notification daemon with Catppuccin theme
- Imports compositor-specific modules: hyprland.nix, niri.nix

**Compositor Modules:**
- `hyprland.nix` - Activates when `wayland.compositor == "hyprland"`
  - Auto-enables: `walker-config`, `waybar-config`
  - Provides: Hyprland, hyprlock, hyprpaper, hypridle, screenshot tools
  - Optional sub-option: `hyprland-config.xwayland-zero-scale.enable` for 4K scaling
- `niri.nix` - Activates when `wayland.compositor == "niri"`
  - Auto-enables: `walker-config`, `waybar-config`, `swaybg-config`
  - Provides: Niri config, hyprlock (lock screen), swayidle, fuzzel, satty
  - Uses swaybg for wallpaper management
  - Config file templating with script and wallpaper path substitution

**Supporting Modules:**
- `walker-config` - App launcher (shared between compositors)
  - Auto-enabled by both hyprland and niri (priority: `lib.mkOptionDefault`)
- `waybar-config` - Status bar (compositor-aware)
  - Auto-enabled by both hyprland and niri (priority: `lib.mkOptionDefault`)
  - Different workspace modules: `hyprland/workspaces` vs `cffi/niri-taskbar`
  - Adapts power menu commands based on compositor
- `swaybg-config` - Wallpaper management
  - Auto-enabled by niri (priority: `lib.mkOptionDefault`)
  - Supports NixOS artwork presets or custom wallpapers
  - Exposes `selectedWallpaperPath` for use in niri config and hyprlock

### Shell Aliases for System Management

Shell configurations use hostname detection for dynamic rebuild commands:

**Fish:**
```fish
nos = "sudo nixos-rebuild switch --flake ~/configs/nix#(hostname)"
nom = "sudo darwin-rebuild switch --flake ~/configs/nix#(hostname)"
nosu = "cd ~/configs/nix && nix flake update && sudo nixos-rebuild switch --flake .#(hostname)"
```

**Zsh:**
```zsh
nos = "sudo nixos-rebuild switch --flake ~/configs/nix#$HOST"
nom = "sudo darwin-rebuild switch --flake ~/configs/nix#$HOST"
nosu = "cd ~/configs/nix && nix flake update && sudo nixos-rebuild switch --flake .#$HOST"
```

### Example: Host-Specific Home Configuration

```nix
# hosts/nixos/laptop-lenovo/home.nix
{
  imports = [ ../../../home/default.nix ];

  home = {
    username = "ericus";
    homeDirectory = "/home/ericus";
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;

  # Enable modules
  git-config.enable = true;
  wayland = {
    enable = true;
    compositor = "niri";  # or "hyprland"
  };
  swaybg-config.wallpaper.preset = "mosaic-blue";  # Optional wallpaper
  hyprland-config.xwayland-zero-scale.enable = true;  # Hyprland-specific option
  fish-config.enable = true;
  linux-packages.enable = true;
}
```

## NixOS Modules

### Default Behavior

In `/modules/default.nix`:

**Always Enabled:**
- `base-system` - Core (networking, nix settings, GC)
- `boot-config` - Bootloader (systemd-boot by default)
- `locale-time` - Locale and timezone
- `minimal-packages` - Essential packages + fonts

**Disabled by Default:**
all other modules

### Module Descriptions

**base-system.nix:**
- Networking (NetworkManager, hostname from flake)
- Nix settings (flakes, allowUnfree)
- Garbage collection
- System state version
- Firmware updates (fwupd)

**boot-config.nix:**
Bootloader configuration with mutually exclusive options:
- `boot-config.enable` - Enable boot configuration (default: true)
- `boot-config.type` - Enum: `"systemd-boot"` (default) or `"lanzaboote"`
- `boot-config.pkiBundle` - Path to lanzaboote PKI bundle (default: `/var/lib/sbctl`)
- `boot-config.autoEnrollKeys` - Auto-generate and enroll Secure Boot keys (default: true)

When `type = "systemd-boot"`: enables systemd-boot (standard NixOS bootloader).
When `type = "lanzaboote"`: disables systemd-boot, enables lanzaboote for Secure Boot, includes `sbctl` package, and optionally auto-provisions Secure Boot keys on first boot.

```nix
# In host configuration.nix:

# Standard boot (default, no need to set explicitly)
boot-config.type = "systemd-boot";

# Secure Boot
boot-config.type = "lanzaboote";
```

**locale-time.nix:**
- Time zone (Europe/Berlin)
- Locale (en_US.UTF-8 + extra locales)

**desktop-wayland.nix:**
- Sub-option `compositor`: Choose between "hyprland" or "niri"
- Conditionally enables Hyprland or Niri programs based on compositor choice
- greetd + tuigreet login manager (adapts to compositor)
- XDG Portal (gtk for Hyprland, gnome for Niri)
- Polkit, dconf, gnome-keyring
- Niri also installs xwayland-satellite for Xwayland support

**media.nix:**
Sub-options for audio and bluetooth:
```nix
media-config = {
  audio.enable = true;      # PipeWire
  bluetooth.enable = true;  # Bluetooth
};
```

**graphics.nix:**
Graphics drivers with sub-option:
```nix
graphics-config = {
  enable = true;
  enable32Bit = true;  # For gaming/Steam
};
```

**minimal-packages.nix:**
- Essential CLI tools (git, wget, curl, vim, fish, home-manager, wireguard-tools)
- Nerd Fonts (JetBrainsMono, FiraCode, Hack)
- Noto fonts

**gaming.nix:**
- Steam with GameScope
- GameMode
- MangoHud, protonup-ng
- Custom Steam GameScope launcher

**virtualization.nix:**
- QEMU/KVM (libvirtd)
- virt-manager
- USB redirection
- Adds user to libvirtd group

## Disk Configuration (Disko)

Hosts that require declarative disk management use [disko](https://github.com/nix-community/disko). The disk layout is defined in a `disko.nix` file within the host directory.

### How It Works

- Disko declares the entire disk layout in Nix: partitions, filesystems, encryption, subvolumes
- During installation, the `bootstrap/install` script runs disko to partition, format, and mount the disk
- Disko also generates the necessary `fileSystems` and `swapDevices` NixOS options automatically, so `hardware-configuration.nix` does not need filesystem declarations for disko-managed hosts
- The disko NixOS module must be included in the host's flake modules: `inputs.disko.nixosModules.disko`

### Example: LUKS + btrfs Layout

```nix
# hosts/nixos/lenovo-work/disko.nix
{lib, ...}: {
  disko.devices = {
    disk = {
      vdb = {
        type = "disk";
        device = lib.mkDefault "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["defaults"];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                settings.allowDiscards = true;
                content = {
                  type = "btrfs";
                  extraArgs = ["-f"];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["compress=zstd" "noatime"];
                    };
                    "/swap" = {
                      mountpoint = "/.swapvol";
                      swap.swapfile.size = "32G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
```

Key points:
- `lib.mkDefault` on the device path allows overriding during install
- LUKS with no `passwordFile`/`keyFile` means interactive password prompt during installation
- `allowDiscards = true` enables TRIM for NVMe SSDs
- btrfs subvolumes separate `/`, `/home`, `/nix`, and swap for flexibility
- `compress=zstd` and `noatime` are good defaults for btrfs on SSDs

### TPM2 + Secure Boot Integration

For full disk encryption with passwordless boot, hosts can combine:

1. **LUKS** (disk encryption, via disko)
2. **TPM2** (auto-unlock, enrolled after first boot)
3. **Lanzaboote** (Secure Boot, prevents TPM2 key release if boot chain is tampered)

```nix
# In host configuration.nix:
imports = [./disko.nix];

# Secure Boot bootloader
boot-config.type = "lanzaboote";

# Required for TPM2 unlock
boot.initrd.systemd.enable = true;

# TPM2 support
security.tpm2 = {
  enable = true;
  pkcs11.enable = true;
  tctiEnvironment.enable = true;
};
```

Note: `boot.initrd.luks.devices` is NOT needed -- disko generates those declarations automatically from `disko.devices`.

### Example: Host-Specific NixOS Configuration

```nix
# hosts/nixos/lenovo-work/configuration.nix
{
  pkgs,
  user,
  ...
}: {
  imports = [./disko.nix];

  # Secure Boot via lanzaboote
  boot-config.type = "lanzaboote";

  # LUKS / initrd - required for TPM2 unlock
  boot.initrd.systemd.enable = true;

  # TPM2
  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    tctiEnvironment.enable = true;
  };

  # User account (uses ${user} from flake)
  users.users.${user} = {
    isNormalUser = true;
    description = "Eric";
    extraGroups = ["networkmanager" "wheel" "video" "audio"];
    shell = pkgs.nushell;
  };

  # Enable modules
  desktop-wayland = {
    enable = true;
    compositor = "niri";
  };
  graphics-config = {
    enable = true;
    enable32Bit = true;
  };
  media-config = {
    audio.enable = true;
    bluetooth.enable = true;
  };

  jetbrains.enable = true;
  virtualization-config.enable = true;
  work.enable = true;
}
```

## Flake Structure

### System Configurations

All system configurations use the `mkSystem` helper which integrates home-manager automatically.

**NixOS Example:**
```nix
nixosConfigurations = {
  laptop-amd = mkSystem {
    system = "x86_64-linux";
    hostname = "laptop-amd";
    user = "ericus";
    modules = [
      ./modules  # Imports default.nix
    ];
  };

  # Host with disko + lanzaboote
  lenovo-work = mkSystem {
    system = "x86_64-linux";
    hostname = "lenovo-work";
    user = "ericus";
    modules = [
      ./modules
      inputs.disko.nixosModules.disko
      inputs.lanzaboote.nixosModules.lanzaboote
    ];
  };
};
```

**Darwin Example:**
```nix
darwinConfigurations = {
  work-mac = mkSystem {
    system = "aarch64-darwin";
    hostname = "work-mac";
    user = "ericpuentes";
    darwin = true;
  };
};
```

### mksystem.nix Helper

The `mkSystem` function handles all the complexity of creating a unified system configuration:

**What it does:**
- Selects the appropriate builder (`nixosSystem` or `darwinSystem`)
- Integrates home-manager as a module (no standalone configs needed)
- Automatically constructs config file paths based on hostname
- Passes all flake inputs to both system and home-manager modules

**Parameters:**
- `system` - Architecture (e.g., `"x86_64-linux"`, `"aarch64-darwin"`)
- `hostname` - System hostname (used to locate config files)
- `user` - Primary username for home-manager
- `darwin` - Whether this is a macOS system (default: `false`)
- `modules` - Additional system modules to include (default: `[]`)

**Automatically constructed paths:**
- System config: `hosts/{nixos|darwin}/${hostname}/configuration.nix`
- Home config: `hosts/{nixos|darwin}/${hostname}/home.nix` (integrated via home-manager module)
- Hardware config: `hosts/nixos/${hostname}/hardware-configuration.nix` (NixOS only)

**Special args available in modules:**
- `inputs` - All flake inputs (nixpkgs, home-manager, walker, noctalia, niri, disko, lanzaboote, etc.)
- `hostname` - Current system hostname
- `user` - Primary username
- `darwin` - Boolean flag (true for macOS, false for Linux)

**Accessing custom inputs in home modules:**

All flake inputs are available via the `inputs` parameter in home-manager modules:

```nix
# In any home-manager module
{inputs, pkgs, lib, config, ...}: {
  # Import home-manager modules from flake inputs
  imports = [
    inputs.walker.homeManagerModules.default
    inputs.noctalia.homeModules.default
  ];
  
  # Access packages from custom inputs
  home.packages = [
    inputs.walker.packages.${pkgs.system}.default
  ];
  
  # Conditionally import based on availability
  imports = lib.optionals (inputs ? niri) [
    inputs.niri.homeModules.niri
  ];
}
```

**Note:** All modules use `inputs.<name>` instead of expecting the input as a direct parameter. This is cleaner and avoids the need to explicitly pass each input in `extraSpecialArgs`.

## Workflow

### Making Changes

All configuration changes (both system and home-manager) are applied together using the system rebuild commands:

**NixOS:**
```bash
sudo nixos-rebuild switch --flake .#hostname
```

**macOS (nix-darwin):**
```bash
darwin-rebuild switch --flake .#hostname
```

### Quick Iteration

For rapid development and testing:

**Test without modifying boot profile (NixOS):**
```bash
sudo nixos-rebuild test --flake .#hostname
```
This activates changes immediately without adding a boot entry. Perfect for testing configurations.

**Immediate cleanup after testing:**
```bash
sudo nix-collect-garbage --delete-older-than 2d
```
Use the shell aliases `nos` (NixOS switch) or `nom` (Darwin switch) for convenience.

### Updating Inputs

Update all flake inputs and rebuild:
```bash
cd ~/configs/nix
nix flake update
sudo nixos-rebuild switch --flake .#hostname
```

Or use the combined alias `nosu` which does both steps.

## Usage Examples

### Adding a New Host

1. **Create host directory:**
   ```bash
   mkdir -p hosts/nixos/new-host
   ```

2. **Create disk configuration (if using disko):**
   ```nix
   # hosts/nixos/new-host/disko.nix
   {lib, ...}: {
     disko.devices = {
       disk = {
         vdb = {
           type = "disk";
           device = lib.mkDefault "/dev/nvme0n1";  # Adjust to your disk
           content = {
             type = "gpt";
             partitions = {
               ESP = { ... };
               luks = { ... };
             };
           };
         };
       };
     };
   }
   ```
   See the lenovo-work `disko.nix` for a complete LUKS + btrfs example.

3. **Create hardware-configuration.nix:**
   For disko-managed hosts, only include kernel modules and hardware settings (no `fileSystems` or `swapDevices`):
   ```nix
   { config, lib, modulesPath, ... }: {
     imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
     boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
     boot.kernelModules = [ "kvm-intel" ];
     # Filesystem and swap managed by disko
     nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
   }
   ```

4. **Create configuration.nix:**
   ```nix
   {user, pkgs, ...}: {
     imports = [./disko.nix];

     # Bootloader (use "lanzaboote" for Secure Boot, or omit for systemd-boot default)
     boot-config.type = "lanzaboote";

     # For LUKS + TPM2:
     boot.initrd.systemd.enable = true;
     security.tpm2 = {
       enable = true;
       pkcs11.enable = true;
       tctiEnvironment.enable = true;
     };

     users.users.${user} = {
       isNormalUser = true;
       description = "Name";
       extraGroups = ["networkmanager" "wheel"];
       shell = pkgs.fish;
     };

     # Enable system modules
     desktop-wayland = {
       enable = true;
       compositor = "niri";
     };
     graphics-config.enable = true;
     media-config.audio.enable = true;
   }
   ```

5. **Create home.nix:**
   ```nix
   {...}: {
     imports = [ ../../../home/default.nix ];

     home = {
       username = "username";
       homeDirectory = "/home/username";
       stateVersion = "25.11";
     };

     programs.home-manager.enable = true;

     # Enable home modules
     git-config.enable = true;
     fish-config.enable = true;
     wayland = {
       enable = true;
       compositor = "niri";
     };
   }
   ```

6. **Add to flake.nix:**
   ```nix
   nixosConfigurations.new-host = mkSystem {
     system = "x86_64-linux";
     hostname = "new-host";
     user = "username";
     modules = [
       ./modules
       inputs.disko.nixosModules.disko          # If using disko
       inputs.lanzaboote.nixosModules.lanzaboote  # If using Secure Boot
     ];
   };
   ```

7. **Install:**
   ```bash
   sudo bash bootstrap/install new-host
   ```

### Creating a New Module

1. **Create module file:**
   ```nix
   # modules/feature.nix
   {config, lib, pkgs, ...}: {
     options = {
       feature-config.enable =
         lib.mkEnableOption "enables feature";
     };

     config = lib.mkIf config.feature-config.enable {
       # Configuration here
     };
   }
   ```

2. **Add to modules/default.nix:**
   ```nix
   imports = [
     ./feature.nix
     # ...
   ];

   feature-config.enable = lib.mkDefault false;
   ```

3. **Enable in host configuration:**
   ```nix
   feature-config.enable = true;
   ```

## Important Notes

### Imports in Conditional Blocks

**Wrong:**
```nix
config = lib.mkIf config.module.enable {
  imports = [...];  # ERROR: imports can't be conditional
};
```

**Correct:**
```nix
imports = [...];  # Always at top level

config = lib.mkIf config.module.enable {
  # Configuration here
};
```

### Merging Configurations

Within the same file, you can't declare the same attribute path twice:

**Wrong:**
```nix
wayland.windowManager.hyprland.settings = { ... };
wayland.windowManager.hyprland.settings = { ... };  # ERROR!
```

**Correct - Use nested paths:**
```nix
wayland.windowManager.hyprland.settings = { ... };
wayland.windowManager.hyprland.settings.xwayland = { ... };  # OK!
```

**Correct - Use lib.mkMerge:**
```nix
wayland.windowManager.hyprland.settings = lib.mkMerge [
  { ... }
  (lib.mkIf condition { ... })
];
```

## Common Patterns

### Conditional Lists

Build lists conditionally using `lib.optionals`:

```nix
env =
  [ "BASE_VAR=value" ]
  ++ lib.optionals config.feature.enable [
    "FEATURE_VAR=value"
  ];
```

### Module Dependencies

Modules can auto-enable their dependencies:

```nix
# In hyprland.nix
config = lib.mkIf (config.wayland.enable && config.wayland.compositor == "hyprland") {
  walker-config.enable = lib.mkDefault true;
  waybar-config.enable = lib.mkDefault true;
  # User can still override these to false
};

# In niri.nix
config = lib.mkIf (config.wayland.enable && config.wayland.compositor == "niri") {
  walker-config.enable = lib.mkDefault true;
  waybar-config.enable = lib.mkDefault true;
  swaybg-config.enable = lib.mkDefault true;
  # User can still override these to false
};
```

### Platform-Specific Options

Use conditions based on platform:

```nix
dconf = lib.mkIf pkgs.stdenv.hostPlatform.isx86_64 {
  # x86_64-specific config
};
```

## Troubleshooting

### Module not found

Ensure the module is:
1. Created in the correct directory
2. Imported in `default.nix`
3. Has a default value set

### Option doesn't exist

Check that:
1. The option is defined in the module's `options` block
2. The module is imported
3. The option name matches exactly (check hyphens vs underscores)

### Priority conflicts

If you see "conflicting definitions" errors:
1. Check if the same option is set in multiple places with same priority
2. Use different priorities (`lib.mkDefault`, `lib.mkOptionDefault` `lib.mkOverride 1100`, etc.)
3. Ensure one setting has higher priority (lower number)

### Hostname not interpolating

The hostname comes from the flake, ensure:
1. `hostname` is in the function parameters: `{hostname, ...}: {`
2. Using `"${hostname}"` (with quotes and interpolation)
3. Not hardcoded in modules (should be in flake only)

### LUKS / TPM2 issues after firmware update

If TPM2 auto-unlock stops working (e.g., after BIOS update):
1. Type your LUKS password at the boot prompt (the passphrase slot is never removed)
2. Re-enroll TPM2: `sudo systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p2`

### Secure Boot verification

```bash
# Check if Secure Boot is active
sudo sbctl status

# List enrolled keys
sudo sbctl list-enrolled-keys

# Verify all signed files
sudo sbctl verify
```

## Additional Resources

- [NixOS Module System](https://nixos.org/manual/nixos/stable/#sec-writing-modules)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Disko Documentation](https://github.com/nix-community/disko)
- [Lanzaboote Documentation](https://github.com/nix-community/lanzaboote)
- [lib.mkDefault Priority](https://nixos.org/manual/nixos/stable/#sec-option-definitions-setting-priorities)
- [Nix Language Basics](https://nixos.org/manual/nix/stable/language/)
