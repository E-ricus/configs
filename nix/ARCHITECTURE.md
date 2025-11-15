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
│   ├── base-system.nix         # Core system (bootloader, networking, nix)
│   ├── locale-time.nix         # Locale and timezone
│   ├── desktop-wayland.nix     # Wayland desktop (Hyprland, greetd, etc.)
│   ├── media.nix               # Audio (PipeWire) + Bluetooth
│   ├── graphics.nix            # Graphics drivers
│   ├── minimal-packages.nix    # Essential packages + fonts
│   ├── gaming.nix              # Gaming (Steam, GameScope, etc.)
│   └── virtualization.nix      # QEMU/KVM virtualization
├── home/                        # Home-manager configuration
│   ├── default.nix             # Imports all modules + sets defaults
│   ├── common.nix              # Common packages (tools, dev tools)
│   ├── modules/
│   │   ├── git.nix             # Git configuration
│   │   ├── fish.nix            # Fish shell
│   │   ├── zsh.nix             # Zsh shell
│   │   ├── alacritty.nix       # Alacritty terminal
│   │   ├── tmux.nix            # Tmux
│   │   ├── ghostty.nix         # Ghostty terminal
│   │   ├── wireguard.nix       # WireGuard VPN helpers
│   │   ├── linux-packages.nix  # Linux-specific packages
│   │   ├── mac-packages.nix    # macOS-specific packages
│   │   ├── aerospace.nix       # Aerospace (macOS WM)
│   │   └── hypr/
│   │       ├── hyprland.nix    # Hyprland config (imports walker + waybar)
│   │       ├── walker.nix      # Walker launcher
│   │       └── waybar.nix      # Waybar status bar
│   └── config/                 # External config files
└── hosts/
    ├── nixos/
    │   ├── laptop-lenovo/
    │   │   ├── configuration.nix    # NixOS system config
    │   │   ├── home.nix            # Home-manager config
    │   │   └── hardware-configuration.nix
    │   ├── laptop-amd/
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
- `hyprland-config` - Hyprland window manager
  - Auto-enables: `walker-config`, `waybar-config`
- `aerospace-config` - Aerospace (macOS)

**Development:**
- `git-config` - Git configuration

**Networking:**
- `wireguard-config` - WireGuard VPN helpers

### Shell Aliases Auto-Detection

Shell configurations use hostname detection for dynamic commands:

**Fish:**
```fish
hm = "home-manager switch --flake ~/.dotfiles/nix#$USER-(hostname)"
nos = "sudo nixos-rebuild switch --flake ~/.dotfiles/nix#(hostname)"
```

**Zsh:**
```zsh
hm = "home-manager switch --flake ~/.dotfiles/nix#$USER-$HOST"
nos = "sudo nixos-rebuild switch --flake ~/.dotfiles/nix#$HOST"
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
  hyprland-config = {
    enable = true;
    xwayland-zero-scale.enable = true;  # Sub-option
  };
  fish-config.enable = true;
  linux-packages.enable = true;
}
```

## NixOS Modules

### Default Behavior

In `/modules/default.nix`:

**Always Enabled:**
- `base-system` - Core (bootloader, networking, nix, GC)
- `locale-time` - Locale and timezone
- `minimal-packages` - Essential packages + fonts

**Disabled by Default:**
- `desktop-wayland` - Wayland desktop environment
- `graphics-config` - Graphics drivers
- `media-config.audio` - PipeWire audio
- `media-config.bluetooth` - Bluetooth
- `gaming-config` - Gaming setup
- `virtualization-config` - QEMU/KVM

### Module Descriptions

**base-system.nix:**
- Bootloader (systemd-boot)
- Networking (NetworkManager, hostname from flake)
- Nix settings (flakes, allowUnfree)
- Garbage collection
- System state version

**locale-time.nix:**
- Time zone (Europe/Berlin)
- Locale (en_US.UTF-8 + extra locales)

**desktop-wayland.nix:**
- Hyprland program
- greetd + tuigreet login manager
- XDG Portal
- Polkit, dconf

**media.nix:**
Sub-options for audio and bluetooth:
```nix
media-config = {
  audio.enable = true;      # PipeWire
  bluetooth.enable = true;  # Bluetooth + blueman
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

### Example: Host-Specific NixOS Configuration

```nix
# hosts/nixos/laptop-lenovo/configuration.nix
{
  config,
  pkgs,
  hostname,
  user,
  ...
}: {
  # User account (uses ${user} from flake)
  users.users.${user} = {
    isNormalUser = true;
    description = "Eric";
    extraGroups = ["networkmanager" "wheel" "video" "audio"];
    shell = pkgs.fish;
  };

  # Enable modules
  desktop-wayland.enable = true;
  graphics-config = {
    enable = true;
    enable32Bit = true;  # Needed for gaming
  };
  media-config = {
    audio.enable = true;
    bluetooth.enable = true;
  };
  gaming-config.enable = true;
}
```

## Flake Structure

### NixOS Configurations

```nix
nixosConfigurations = {
  laptop-lenovo = mkSystem {
    system = "x86_64-linux";
    hostname = "laptop-lenovo";
    user = "ericus";
    determinate = true;
    modules = [
      nixos-hardware.nixosModules.lenovo-legion-15ach6h
      ./modules  # Imports default.nix
    ];
  };
};
```

### Home-Manager Configurations

Format: `username-hostname`

```nix
homeConfigurations = {
  "ericus-laptop-lenovo" = home-manager.lib.homeManagerConfiguration {
    pkgs = pkgsFor."x86_64-linux";
    extraSpecialArgs = {inherit inputs walker;};
    modules = [./hosts/nixos/laptop-lenovo/home.nix];
  };
};
```

### mksystem.nix Helper

Automatically constructs paths:
- System config: `hosts/{nixos|darwin}/${hostname}/configuration.nix`
- Home config: `hosts/{nixos|darwin}/${hostname}/home.nix`
- Hardware config: `hosts/nixos/${hostname}/hardware-configuration.nix`

## Usage Examples

### Adding a New Host

1. **Create host directory:**
   ```bash
   mkdir -p hosts/nixos/new-host
   ```

2. **Create configuration.nix:**
   ```nix
   {user, ...}: {
     users.users.${user} = {
       isNormalUser = true;
       description = "Name";
       extraGroups = ["networkmanager" "wheel"];
       shell = pkgs.fish;
     };

     desktop-wayland.enable = true;
     graphics-config.enable = true;
   }
   ```

3. **Create home.nix:**
   ```nix
   {
     imports = [ ../../../home/default.nix ];

     home = {
       username = "username";
       homeDirectory = "/home/username";
       stateVersion = "25.05";
     };

     programs.home-manager.enable = true;

     git-config.enable = true;
     fish-config.enable = true;
   }
   ```

4. **Add to flake.nix:**
   ```nix
   nixosConfigurations.new-host = mkSystem {
     system = "x86_64-linux";
     hostname = "new-host";
     user = "username";
     modules = [./modules];
   };

   homeConfigurations."username-new-host" =
     home-manager.lib.homeManagerConfiguration {
       pkgs = pkgsFor."x86_64-linux";
       extraSpecialArgs = {inherit inputs walker;};
       modules = [./hosts/nixos/new-host/home.nix];
     };
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

## Key Design Decisions

### Why This Architecture?

1. **DRY (Don't Repeat Yourself):** Common configuration is defined once and reused
2. **Explicit over Implicit:** Each host clearly declares what it needs
3. **Flexibility:** Easy to enable/disable features per host
4. **Scalability:** Adding new hosts or modules is straightforward
5. **Maintainability:** Changes to common config propagate automatically

### Module Granularity

- **Larger modules** for tightly coupled features (e.g., media = audio + bluetooth)
- **Smaller modules** for independently useful features (e.g., git, tmux)
- **Sub-options** for optional parts of a feature (e.g., graphics.enable32Bit)

### Imports in Conditional Blocks

**❌ Wrong:**
```nix
config = lib.mkIf config.module.enable {
  imports = [...];  # ERROR: imports can't be conditional
};
```

**✅ Correct:**
```nix
imports = [...];  # Always at top level

config = lib.mkIf config.module.enable {
  # Configuration here
};
```

### Merging Configurations

Within the same file, you can't declare the same attribute path twice:

**❌ Wrong:**
```nix
wayland.windowManager.hyprland.settings = { ... };
wayland.windowManager.hyprland.settings = { ... };  # ERROR!
```

**✅ Correct - Use nested paths:**
```nix
wayland.windowManager.hyprland.settings = { ... };
wayland.windowManager.hyprland.settings.xwayland = { ... };  # OK!
```

**✅ Correct - Use lib.mkMerge:**
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
config = lib.mkIf config.hyprland-config.enable {
  walker-config.enable = lib.mkDefault true;
  waybar-config.enable = lib.mkDefault true;
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

## Additional Resources

- [NixOS Module System](https://nixos.org/manual/nixos/stable/#sec-writing-modules)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [lib.mkDefault Priority](https://nixos.org/manual/nixos/stable/#sec-option-definitions-setting-priorities)
- [Nix Language Basics](https://nixos.org/manual/nix/stable/language/)
