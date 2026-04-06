# config

Personal configuration files for UNIX systems. NixOS configurations use [flake-parts](https://flake.parts) + [den](https://github.com/vic/den) (dendritic pattern with aspects).

## Quick Start

### NixOS Installation (Fresh System)

1. Boot from NixOS **minimal installer** ISO
2. **Connect to the internet**:
   ```bash
   # For WiFi: sudo systemctl start wpa_supplicant && wpa_cli
   # Or use: nmtui
   ```
3. Download and run the bootstrap installer:
   ```bash
   curl -fsSL https://raw.githubusercontent.com/e-ricus/configs/main/bootstrap/install > install.sh
   sudo bash install.sh <hostname>
   ```
   Available hostnames: `thinkpad-work`, `legion-personal`
4. The installer will prompt for a starting step:
   ```
   1) Full bootstrap (disko -> install -> post-install)
   2) Disko only (partition & format)
   3) NixOS install only (skip partitioning)
   4) Post-install only (set passwords)
   ```
5. Reboot into the new system

### Post-Boot Setup (TPM2 + Secure Boot)

After the first boot (thinkpad-work only):

```bash
# Enroll TPM2 (auto-unlock LUKS without password)
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p2

# Enable Secure Boot in UEFI firmware settings, then:
# Lanzaboote will auto-generate and enroll keys on next boot
sudo sbctl status
```

## Rebuilding

All shells (fish, zsh, nushell) provide these aliases:

```bash
nos     # NixOS rebuild for current hostname (system + home-manager)
nosu    # Update flake inputs + rebuild
nob     # Test build without switching
nom     # Darwin rebuild (macOS)
ngc     # Garbage collection
```

Under the hood: `sudo nixos-rebuild switch --flake ~/configs/nix#$(hostname)`

Home-manager is integrated via den -- there is no separate `home-manager switch` step. A single `nos` rebuilds everything.

## Repository Structure

```
configs/
├── bootstrap/                  # NixOS installation scripts
│   ├── install                 # Unified installer (disko + nixos-install + post-install)
│   └── lib.sh                  # Shared functions
│
├── nix/                        # Nix configurations (flake-parts + den)
│   ├── flake.nix               # Entry point: flake-parts + den + import-tree
│   ├── flake.lock
│   │
│   ├── modules/                # Auto-loaded by import-tree (files prefixed _ are excluded)
│   │   ├── dendritic.nix       # Den wiring, schema, systems, global defaults
│   │   ├── dev-shells.nix      # perSystem devShells (nix develop .#work)
│   │   │
│   │   ├── hosts/                              # Per-host: declaration + aspect + hardware
│   │   │   ├── thinkpad-work/
│   │   │   │   ├── default.nix                 # den.hosts + den.aspects (Intel, Secure Boot, disko)
│   │   │   │   └── _hardware.nix               # Hardware config (excluded from import-tree)
│   │   │   ├── legion-personal/
│   │   │   │   ├── default.nix                 # den.hosts + den.aspects (AMD+NVIDIA, gaming)
│   │   │   │   └── _hardware.nix
│   │   │   └── work-mac/
│   │   │       └── default.nix                 # Darwin host (inactive)
│   │   │
│   │   ├── users/
│   │   │   └── ericus.nix                      # User aspect: aspect composition + system user
│   │   │
│   │   ├── base/                               # System fundamentals
│   │   │   ├── system.nix                      # Networking, nix settings, GC, fwupd
│   │   │   └── locale.nix                      # Timezone, locale, fonts
│   │   │
│   │   ├── desktop/                            # Desktop environment (nixos + HM combined)
│   │   │   ├── wayland/                        # Shared wayland config, greeter, scripts
│   │   │   │   ├── default.nix
│   │   │   │   ├── regreet-style.css
│   │   │   │   ├── volume-control.sh
│   │   │   │   └── brightness-control.sh
│   │   │   ├── niri.nix                        # Niri compositor
│   │   │   ├── hyprland.nix                    # Hyprland compositor
│   │   │   ├── noctalia.nix                    # Noctalia desktop shell
│   │   │   └── dms.nix                         # DankMaterialShell
│   │   │
│   │   ├── programs/                           # Application aspects (one per tool)
│   │   │   ├── fish/                           # Fish shell + init.fish
│   │   │   ├── zsh/                            # Zsh + init.zsh
│   │   │   ├── nushell/                        # Nushell + config.nu + env.nu
│   │   │   ├── tmux/                           # Tmux + tmux.conf
│   │   │   ├── starship/                       # Starship prompt + starship.toml
│   │   │   ├── tools.nix                       # CLI essentials (eza, fzf, bat, fd, ripgrep...)
│   │   │   ├── git.nix                         # Git + lazygit
│   │   │   ├── jujutsu.nix                     # Jujutsu VCS
│   │   │   ├── direnv.nix                      # Direnv + nix-direnv
│   │   │   ├── yazi.nix                        # Yazi file manager
│   │   │   ├── nvim.nix                        # Neovim
│   │   │   ├── zed.nix                         # Zed editor
│   │   │   ├── ghostty.nix                     # Ghostty terminal
│   │   │   ├── alacritty.nix                   # Alacritty terminal
│   │   │   ├── langs.nix                       # Languages, LSPs, formatters
│   │   │   ├── llms.nix                        # LLM tools (opencode, codex)
│   │   │   ├── jetbrains.nix                   # RustRover + DataGrip (pinned)
│   │   │   ├── theming.nix                     # GTK/Qt Catppuccin theming
│   │   │   ├── browsers.nix                    # Firefox + Brave
│   │   │   ├── linux-desktop.nix               # Nautilus, btop, vlc, etc.
│   │   │   ├── containers.nix                  # Podman
│   │   │   └── darwin-tools.nix                # macOS tools + Aerospace
│   │   │
│   │   ├── hardware/                           # Hardware aspects
│   │   │   ├── fingerprint/                    # Fingerprint auth
│   │   │   │   ├── default.nix                 # Aspect + perSystem package
│   │   │   │   └── _pam-fprint-grosshack.nix   # PAM module derivation
│   │   │   ├── graphics.nix                    # GPU drivers (basic, 32-bit, Intel Xe)
│   │   │   ├── hybrid-gpu.nix                  # AMD+NVIDIA PRIME offload
│   │   │   └── keyboards.nix                   # ZSA keyboard udev rules
│   │   │
│   │   └── services/                           # System services
│   │       ├── boot.nix                        # systemd-boot + lanzaboote
│   │       ├── disko.nix                       # LUKS + btrfs disk partitioning
│   │       ├── media.nix                       # PipeWire + Bluetooth
│   │       ├── gaming.nix                      # Steam, GameScope, Minecraft
│   │       ├── virtualization.nix              # QEMU/KVM + Windows 11 VM
│   │       ├── vpn.nix                         # WireGuard + Mullvad
│   │       └── work.nix                        # Slack, graphite, AWS, etc.
│   │
│   └── devshells/              # Legacy standalone devshells (superseded by dev-shells.nix)
│       └── flake.nix
│
├── nvim/                       # Neovim configuration (symlinked)
├── ideavim/                    # IdeaVim configuration
├── bin/symlinkmanager          # Symlink manager for non-nix configs
└── symlink.conf
```

## Architecture

### Dendritic Pattern with Aspects

Instead of traditional NixOS modules with `mkEnableOption` toggles, this config uses **den aspects** -- self-contained bundles of `{ nixos, homeManager }` configuration.

Each module file owns everything about itself:
- **Host files** declare `den.hosts` + define `den.aspects` + set host-specific overrides
- **Program files** define `den.aspects` + optionally `perSystem` packages
- **User files** compose aspects via `includes` + define the system user

```nix
# modules/hosts/thinkpad-work/default.nix — host owns its declaration + aspect
den.hosts.x86_64-linux.thinkpad-work = {
  scale = 1.75;
  users.ericus = {};
};
den.aspects.thinkpad-work = {
  includes = [ den.aspects.base-system den.aspects.boot-lanzaboote ... ];
  nixos = { ... }: { /* host-specific NixOS config */ };
  provides.to-users.homeManager = { ... }: { /* host-specific HM overrides */ };
};
```

```nix
# modules/users/ericus.nix — user is pure aspect composition
den.aspects.ericus = {
  includes = [
    den.provides.define-user
    den.aspects.tools den.aspects.git den.aspects.niri den.aspects.dms ...
  ];
  user = { ... }: { description = "Eric"; extraGroups = [ ... ]; };
};
```

No enable/disable flags needed -- if an aspect isn't included, it doesn't exist.

### Key Concepts

| Concept | What it does |
|---------|-------------|
| **import-tree** | Auto-loads all `*.nix` files under `modules/` (files prefixed with `_` are excluded) |
| **den.aspects** | Self-contained features combining NixOS + home-manager config |
| **den.hosts** | Declares which hosts exist, their architecture, schema values, and users |
| **den.provides** | Reusable den batteries (define-user, primary-user, hostname, user-shell) |
| **den.schema.host** | Custom per-host options (e.g., `scale` for display scaling) |
| **mutual-provider** | Lets host aspects forward homeManager config to users via `provides.to-users` |
| **perSystem** | flake-parts per-system outputs (devShells, packages) — can be defined in any module |
| **self** | Reference to the flake itself — used to access `perSystem` packages from NixOS modules |

### Host vs User Aspect Separation

Aspects with **only `nixos`** config are included in the **host** aspect (they run at host context). Aspects with **`homeManager`** config must be included in the **user** aspect (they need user context to be forwarded to `home-manager.users.<name>`).

Host aspects use `provides.to-users.homeManager` to pass host-specific HM overrides (e.g., display scale) to users.

### Host Composition

| Host | NixOS aspects (host) | HM aspects (user) |
|------|---------------------|-------------------|
| **thinkpad-work** | base, locale, lanzaboote, disko, Intel GPU, media, fingerprint, ZSA, JetBrains, virtualization, Windows VM, work tools, VPN | tools, git, jj, direnv, yazi, nvim, zed, langs, llms, starship, fish, zsh, nushell, tmux, ghostty, alacritty, niri, DMS, theming, browsers, linux-desktop, containers |
| **legion-personal** | base, locale, systemd-boot, AMD+NVIDIA, media, gaming, Minecraft, fingerprint-elan, ZSA, VPN, Mullvad | (same user aspects as thinkpad-work) |
| **work-mac** | *(inactive)* | *(inactive)* |

### Adding a New Host

1. Create `modules/hosts/new-host/default.nix`:
   ```nix
   { den, ... }: {
     den.hosts.x86_64-linux.new-host = { scale = 1.0; users.ericus = {}; };
     den.aspects.new-host = {
       includes = [ den.provides.hostname den.aspects.base-system ... ];
       nixos = { ... }: { imports = [ ./_hardware.nix ]; };
     };
   }
   ```
2. Create `modules/hosts/new-host/_hardware.nix` (from `nixos-generate-config`)
3. Build: `sudo nixos-rebuild switch --flake ~/configs/nix#new-host`

### Adding a Custom Package

Define `perSystem` in the same module that uses the package:

```nix
{ den, self, ... }: {
  perSystem = { pkgs, ... }: {
    packages.my-package = pkgs.callPackage ./_my-package.nix {};
  };
  den.aspects.my-feature = {
    nixos = { pkgs, ... }: let
      pkg = self.packages.${pkgs.stdenv.hostPlatform.system}.my-package;
    in { /* use pkg */ };
  };
}
```

The package is available as `nix build .#my-package` and referenced via `self.packages` inside aspects.

## Flake Outputs

```
├── devShells.x86_64-linux
│   ├── default                 # Personal dev tools
│   └── work                    # Work dev tools (+ awscli, ldcli)
├── nixosConfigurations
│   ├── thinkpad-work           # NixOS + home-manager
│   └── legion-personal         # NixOS + home-manager
└── packages.x86_64-linux
    └── pam-fprint-grosshack    # Custom PAM module
```

## Next Step: Wrapper Modules

The current architecture is designed to support [wrapper-modules](https://birdeehub.github.io/nix-wrapper-modules/) as a future enhancement. The per-program aspect split (ghostty.nix, alacritty.nix, nvim.nix, etc.) and the `perSystem` + `self` package pattern are the foundation for this.

### What wrapper-modules enables

Wrapper-modules bakes configuration INTO the package derivation. Instead of configuring ghostty via home-manager options, you create a wrapped ghostty package with the config built in:

```nix
# programs/ghostty.nix — future wrapper-modules version
{ self, inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.ghostty = inputs.wrapper-modules.wrappers.ghostty.wrap {
      inherit pkgs;
      settings = { theme = "Catppuccin Mocha"; background-opacity = 0.98; /* ... */ };
    };
  };
  den.aspects.ghostty = {
    homeManager = { pkgs, ... }: {
      home.packages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.ghostty ];
    };
  };
}
```

### Testing configs without a full rebuild

With wrapper-modules, wrapped packages can be run directly:

```bash
# Test niri with your config in a nested window (without switching system)
nix run .#niri

# Test noctalia shell
nix run .#noctalia

# Test ghostty with baked-in config
nix run .#ghostty
```

Niri supports running nested inside an existing Wayland session -- it opens as a window. This means `nix run .#niri` launches a fully configured niri instance for testing keybinds, layout, window rules, etc. without doing a `nos` rebuild or rebooting.

This is not available yet -- it requires adding `wrapper-modules` as a flake input and converting the relevant aspects to use `.wrap`. The current `perSystem` + `self.packages` pattern in `fingerprint.nix` demonstrates the exact same structure that wrapper-modules will use.

### Good candidates for wrapping

| Program | Why wrap it |
|---------|-----------|
| **Niri** | Test compositor config in a window without rebooting |
| **Ghostty** | Test terminal config instantly with `nix run` |
| **Noctalia** | Test desktop shell config without full rebuild |
| **Alacritty** | Same as Ghostty |
| **OpenCode** | Configure LLM tool with baked-in settings |

## Documentation

- [Den](https://den.oeiuwq.com) -- Dendritic ecosystem for NixOS
- [flake-parts](https://flake.parts) -- Modular flake framework
- [import-tree](https://github.com/vic/import-tree) -- Auto-import nix files
- [wrapper-modules](https://birdeehub.github.io/nix-wrapper-modules/) -- Wrap programs with config as derivations
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Niri](https://github.com/YaLTeR/niri) -- Scrollable-tiling Wayland compositor
