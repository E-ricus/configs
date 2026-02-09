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
│   ├── (other system modules)
├── home/                        # Home-manager configuration
│   ├── default.nix             # Imports all modules + sets defaults
│   ├── common.nix              # Common packages (tools, dev tools)
│   ├── modules/
│   │   ├── git.nix             # Git configuration
│   │   ├── fish.nix            # Fish shell
│   │   ├── (other home modules)
│   └── config/                 # External config files
└── hosts/
    ├── nixos/
    │   ├── laptop-lenovo/
    │   │   ├── configuration.nix    # NixOS system config
    │   │   ├── home.nix            # Home-manager config
    │   │   └── hardware-configuration.nix
    │   ├── (other hosts)
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

**Priority System:**
The auto-enabled modules use `lib.mkOptionDefault false` (priority 1500), allowing:
- Compositors to auto-enable them with `lib.mkDefault true` (priority 1000)
- Users to explicitly disable them if needed (highest priority)

**Example Usage:**
```nix
# Enable Hyprland
wayland = {
  enable = true;
  compositor = "hyprland";
};
hyprland-config.xwayland-zero-scale.enable = true;

# Or enable Niri
wayland = {
  enable = true;
  compositor = "niri";
};
swaybg-config.wallpaper.preset = "dracula";

# Both auto-enable walker and waybar
# To disable a dependency:
waybar-config.enable = lib.mkForce false;
```

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

**Note:** Home-manager is integrated into system configurations, so there are no standalone `home-manager switch` commands. All changes (system and home) are applied together via `nixos-rebuild` or `darwin-rebuild`.

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
- `base-system` - Core (bootloader, networking, nix, GC)
- `locale-time` - Locale and timezone
- `minimal-packages` - Essential packages + fonts

**Disabled by Default:**
all other modules

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
  desktop-wayland = {
    enable = true;
    compositor = "niri";  # or "hyprland"
  };
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

### System Configurations

All system configurations use the `mkSystem` helper which integrates home-manager automatically.

**NixOS Example:**
```nix
nixosConfigurations = {
  laptop-lenovo = mkSystem {
    system = "x86_64-linux";
    hostname = "laptop-lenovo";
    user = "ericus";
    determinate = true;  # Use Determinate Systems' nix
    modules = [
      ./modules  # Imports default.nix
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
- Enables Determinate Systems' nix if requested

**Automatically constructed paths:**
- System config: `hosts/{nixos|darwin}/${hostname}/configuration.nix`
- Home config: `hosts/{nixos|darwin}/${hostname}/home.nix` (integrated via home-manager module)
- Hardware config: `hosts/nixos/${hostname}/hardware-configuration.nix` (NixOS only)

**Special args available in modules:**
- `inputs` - All flake inputs (nixpkgs, home-manager, walker, noctalia, niri, etc.)
- `hostname` - Current system hostname
- `user` - Primary username
- `darwin` - Boolean flag (true for macOS, false for Linux)

**Accessing custom inputs in home modules:**

All flake inputs are available via the `inputs` parameter in home-manager modules. This is the clean, unified way to access any flake input:

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

**Which inputs are currently used:**

The following custom flake inputs are used by home-manager modules:

- `inputs.walker` - Used by `walker.nix` (imports `inputs.walker.homeManagerModules.default`)
  - Application launcher with GTK UI
  - Auto-enabled by hyprland and niri compositors

- `inputs.noctalia` - Used by `noctalia.nix` (imports `inputs.noctalia.homeModules.default`)
  - Shell/notification system for Niri
  - Optional alternative to walker/waybar/swaybg

- `inputs.niri` - Used by `wayland.nix` (conditionally imports `inputs.niri.homeModules.niri`)
  - Provides the Niri compositor home-manager module
  - Only imported on Darwin (Linux uses nixpkgs version)

All other inputs (`nixpkgs`, `home-manager`, `nix-darwin`, `determinate`, `elephant`, `sqlit`) are used at the flake/system level and don't need to be accessed directly in home modules.

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

2. **Generate hardware config (NixOS only):**
   ```bash
   nixos-generate-config --show-hardware-config > hosts/nixos/new-host/hardware-configuration.nix
   ```

3. **Create configuration.nix:**
   ```nix
   {user, pkgs, ...}: {
     users.users.${user} = {
       isNormalUser = true;
       description = "Name";
       extraGroups = ["networkmanager" "wheel"];
       shell = pkgs.fish;
     };

     # Enable system modules
     desktop-wayland = {
       enable = true;
       compositor = "hyprland";  # or "niri"
     };
     graphics-config.enable = true;
     media-config.audio.enable = true;
   }
   ```

4. **Create home.nix:**
   ```nix
   {...}: {
     imports = [ ../../../home/default.nix ];

     home = {
       username = "username";
       homeDirectory = "/home/username";
       stateVersion = "25.05";
     };

     programs.home-manager.enable = true;

     # Enable home modules
     git-config.enable = true;
     fish-config.enable = true;
     wayland = {
       enable = true;
       compositor = "hyprland";  # or "niri"
     };
   }
   ```

5. **Add to flake.nix:**
   ```nix
   nixosConfigurations.new-host = mkSystem {
     system = "x86_64-linux";
     hostname = "new-host";
     user = "username";
     determinate = true;  # optional
     modules = [./modules];
   };
   ```

6. **Build and switch:**
   ```bash
   sudo nixos-rebuild switch --flake .#new-host
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

## important notes

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

## Additional Resources

- [NixOS Module System](https://nixos.org/manual/nixos/stable/#sec-writing-modules)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [lib.mkDefault Priority](https://nixos.org/manual/nixos/stable/#sec-option-definitions-setting-priorities)
- [Nix Language Basics](https://nixos.org/manual/nix/stable/language/)
