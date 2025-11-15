# Arch Install

## Pre install

* Set keyboard layout 
```sh
loadkeys <layout> # e.g loadkeys colemak
```

* Connect to wifi
```sh
iwctl # Interactive network ctl
station <device> scan # scan networks e.g station wlan0 scan
station <device> get-networks 
```

## Installation
Using the archinstall script is pretty straightforward, just follow the menu
* Add on extra packages: git vi vim firefox alacritty timeshift bluez bluez-utils

TODO: Add completly manual installation

## Post install

* Install rust
```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

* Install paru
```sh
git clone https://aur.archlinux.org/paru.git
cd paru/
makepkg -si
```

* Set X11 keyboard
```sh
localectl set-x11-keymap us pc105 colemak
localectl set-keymap us colemak
```

* Add ssh key
```sh
ssh-keygen -t ed25519 -C "eric.david2333@gmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
cat .ssh/id_ed25519.pub 
# Copy key to github.
```

* Install packages
```sh
paru -S tmux ripgrep fd bat starship zoxide exa neovim tmux xclip ripgrep fd bat stow  timeshift auto-cpufreq go
```

* Clone dotfles and configs
```sh
git clone git@github.com:ericpubu/configs.git
cd configs/
stow alacritty
stow git
stow tmux
stow starship
stow nvim
stow bin # Is better to add any thing on ~/.local/bin/ before this
./gnome-settings/workspaces 
sudo systemctl enable --now bluetooth.service # enable bluetooth
```

* Fonts
```sh
cargo install font-manager
font-manager install --nerd JetBrainsMono
font-manager install --nerd FiraCode
```

### Gnome specifics
* Set keyboard layout
* Change mouse settings (natural scrolling,tap to click)
* Add meta+q shortcut to close windows
* Dark appearence
* Add prefernce on dark theme for app
* Extensions: vitals,sound input and output
```sh
nvim ~/.config/gtk-4.0/settings.ini
nvim ~/.config/gtk-3.0/settings.ini
# Add this on both files ->
[Settings]
gtk-application-prefer-dark-theme=1
```
* Fix brightness if needed
```sh
sudo usermod -aG video ericus
paru -S brillo
# Add shortcuts to gnome
brillo -A 10 # brightness up
brillo -U 10 # brightness down
```

### Create snapshot with timeshift
Till this point there will be a working pc with most needed goodies, is a good idea to configure snapshots daily
and create a snapshot of the moment, as installing nvidia and tweaking further the system migth broke something.

### Nvidia
*USING NVIDIA DISSABLES WAYLAND ON GNOME AND AFFECTS BATTERY*
* Install nvidia packages and optimus control
```sh
paru -S nvidia nvidia-utils nvidia-settings nvidia-prime system76-power
systemctl enable com.system76.PowerDaemon.service # Enables system76 daemon
sudo rm /lib/modules-load.d/nvidia-utils.conf # Removes nvidia hardcodede module load (this might be needed after reboot)
sudo system76-power graphics nvidia # Switch to nvidia
sudo system76-power graphics integrated # Switch to integrated
