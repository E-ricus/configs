# configs

Personal configs. NixOS is managed by a [flake-parts](https://flake.parts) + [import-tree](https://github.com/vic/import-tree) flake in `nix/`; non-nix configs are symlinked.

## Install (fresh NixOS)

1. Boot the NixOS **minimal** ISO and connect to the internet (`nmtui`).
2. Run the bootstrap installer (disko → nixos-install → passwords):
   ```bash
   curl -fsSL https://raw.githubusercontent.com/e-ricus/configs/main/bootstrap/install > install.sh
   sudo bash install.sh <hostname>   # thinkpad-work | legion-personal
   ```
3. Reboot.

## Post-boot

### TPM2 + Secure Boot (hosts with `boot-lanzaboote`)

```bash
# Auto-unlock LUKS via TPM2
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p2   # your LUKS partition
# Enable Secure Boot in UEFI, then verify:
sudo sbctl status
```

### Hibernation (btrfs swapfile)

Resume from a swapfile needs its physical offset. With the disko layout the swapfile is `/.swapvol/swapfile`:

```bash
sudo btrfs inspect-internal map-swapfile -r /.swapvol/swapfile
```

Put the number in the host config (see `nix/modules/hosts/thinkpad-work/default.nix`) and rebuild:

```nix
boot.resumeDevice = "/dev/mapper/crypted";
boot.kernelParams = ["resume_offset=<number>"];
```

Redo this whenever the disk is re-partitioned or the swapfile is recreated.

## Rebuild

```bash
nos   # sudo nixos-rebuild switch --flake ~/configs/nix#$(hostname)
nob   # build only
ngc   # garbage collect
```

Home-manager runs as a NixOS module, so one rebuild covers everything.

## Layout

```
bootstrap/          installer script
nix/
  flake.nix         inputs
  modules/          auto-imported flake-parts modules
    flake.nix       wiring + global defaults (my.display.scale)
    hosts/          one nixosConfigurations.<host> per host
    users/          user + its home-manager modules
    base/ desktop/ programs/ hardware/ services/
  devshells/        standalone per-language dev shells
nvim/ helix/ emacs/ gram/ ideavim/   editor configs (symlinked)
qmk/                keyboard firmware keymaps
bin/                scripts (~/.local/bin)
symlink.conf        symlink mapping for non-nix configs
```

## How the flake works

- Every `*.nix` under `nix/modules/` is imported automatically; files prefixed with `_` are skipped.
- A feature defines `flake.modules.nixos.<name>` and/or `flake.modules.homeManager.<name>`.
- A host is `flake.nixosConfigurations.<host>`, which lists the nixos modules it wants.
- `users/ericus.nix` lists the home-manager modules for the user.
- `alacritty`, `tmux` and `niri-noctalia` are built with [nix-wrapper-modules](https://birdeehub.github.io/nix-wrapper-modules/), so they run standalone: `nix run ./nix#niri-noctalia` starts a nested niri for testing without a rebuild.

## Symlinked configs

```bash
cd ~/configs && symlinkmanager link
```

Targets are defined in `symlink.conf`.
