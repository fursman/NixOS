
# NixOS Desktop Flake

[![NixOS Unstable](https://img.shields.io/badge/NixOS-unstable-blue?logo=nixos)](https://status.nixos.org)
[![Home Manager](https://img.shields.io/badge/Home%20Manager-enabled-brightgreen)](https://github.com/nix-community/home-manager)
[![Hyprland](https://img.shields.io/badge/Wayland-Hyprland-purple?logo=wayland)](https://github.com/hyprwm/Hyprland)
[![License](https://img.shields.io/badge/License-Do%20what%20thou%20wilt-red)](#license)
[![Stars](https://img.shields.io/github/stars/fursman/NixOS?style=social)](https://github.com/fursman/NixOS)

A **fully‑featured, reproducible desktop** powered by Nix Flakes.  
This flake focuses on a single output – **`.#desktop`** – that delivers:

* Hyprland Wayland compositor with a polished theme  
* GPU‑accelerated containers & virtual machines  
* Developer‑ready tool‑chain, games, media, and everyday apps  
* Sensible defaults for 🇨🇦 **en_CA.UTF‑8**, `America/Vancouver`, & NVIDIA hardware  
* Idiomatic Home Manager, so per‑user configuration lives right beside system code

> **TL;DR**: Clone, `sudo nixos-rebuild --flake .#desktop switch`, reboot, enjoy.

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Features](#features)
   1. [Desktop Environment](#desktop-environment)
   2. [Virtualisation & Containers](#virtualisation--containers)
   3. [Hardware Support](#hardware-support)
   4. [Pre‑installed Applications](#pre-installed-applications)
3. [Keybindings Cheat‑Sheet](#keybindings-cheat-sheet)
4. [Project Layout](#project-layout)
5. [Updating / Pinning Channels](#updating--pinning-channels)
6. [Troubleshooting](#troubleshooting)
7. [Contributing](#contributing)
8. [License](#license)

---

## Quick Start

```bash
# 1. Install NixOS from the minimal ISO
#    ↳ [NixOS Image Download](https://nixos.org/download.html) [git](https://git-scm.com/)

# 2. Fetch this flake
cd /etc/nixos
sudo nix-shell -p git --run "wget https://raw.githubusercontent.com/fursman/NixOS/main/flake.nix"

# 3. Build & activate the desktop
sudo nixos-rebuild --flake .#desktop switch
```

> _Pro tip_ – you can build in a VM first:  
> `nix build .#nixosConfigurations.desktop.config.system.build.toplevel`

---

## Features

### Desktop Environment

| Component | Notes |
|-----------|-------|
| **[Hyprland](https://github.com/hyprwm/Hyprland)** | Wayland compositor with NVIDIA patches + wobbling‑window eye‑candy |
| **[Waybar](https://github.com/Alexays/Waybar)** | Custom top bar; weather & media modules |
| **[Rofi‑Wayland](https://github.com/lbonn/rofi)** | Spotlight‑like launcher (Dracula theme) |
| **[Hyprpaper](https://github.com/hyprwm/hyprpaper)** | Multi‑monitor wallpapers with cross‑fade |
| **[Kitty](https://sw.kovidgoyal.net/kitty/)** | GPU‑accelerated terminal (ligatures & true‑colour) |
| **[Dracula GTK/Qt](https://github.com/dracula/gtk)** | Consistent dark theming across apps |

### Virtualisation & Containers

* **[libvirt](https://libvirt.org/) + [virt‑manager](https://virt-manager.org/)** with SPICE & UEFI firmware  
* **VFIO hooks** ready for single‑GPU passthrough (see `config/server*.nix`)  
* **[Podman Desktop](https://podman-desktop.io/)** & rootless containers (`podman‑tui`, `dive`, `kubectl`, `docker‑compose`)  
* QEMU with OpenGL / 3‑D acceleration, USB redirection & shared folders (9p / virtfs)

### Hardware Support

* **NVIDIA** proprietary driver (modesetting, Vulkan, 32‑bit GL)
* **Bluetooth** + [Blueman](https://github.com/blueman-project/blueman)
* **Plymouth** graphical boot splash
* **systemd‑boot** (EFI) with auto‑rollback menu
* NTFS‑3G read/write, `brightnessctl`, **[SwayOSD](https://github.com/ErikReider/SwayOSD)** on‑screen display

### Pre‑installed Applications

| Category | Packages |
|----------|----------|
| **Essentials / CLI** | [git](https://git-scm.com/), [wget](https://www.gnu.org/software/wget/), [links2](https://links.twibright.com/), [ntfs‑3g](https://github.com/tuxera/ntfs-3g), [neofetch](https://github.com/dylanaraps/neofetch), [dust](https://github.com/bootandy/dust), [btop](https://github.com/aristocratos/btop), [tmux](https://github.com/tmux/tmux), [usbutils](https://github.com/gregkh/usbutils), [pciutils](https://github.com/pciutils/pciutils), [nmap](https://nmap.org/) |
| **Browsers** | [Firefox](https://www.mozilla.org/firefox), [Microsoft Edge](https://www.microsoft.com/edge), [Chromium](https://www.chromium.org/), *links2 (TUI)* |
| **Media / Graphics** | [VLC](https://www.videolan.org/vlc/), [GIMP](https://www.gimp.org/), [MPV](https://mpv.io/), [FFmpeg](https://ffmpeg.org/), [ImageMagick](https://imagemagick.org/), [Eye of GNOME (eog)](https://wiki.gnome.org/Apps/Eog) |
| **Gaming** | [Steam](https://store.steampowered.com/about) (Big Picture desktop entry) |
| **Dev Tools** | [VS Code (FHS)](https://code.visualstudio.com/), [Podman Desktop](https://podman-desktop.io/), [podman‑tui](https://github.com/containers/podman-tui), [dive](https://github.com/wagoodman/dive), [docker‑compose](https://docs.docker.com/compose/), [kubectl](https://kubernetes.io/docs/tasks/tools/), [waypipe](https://github.com/ArcticaProject/waypipe) |
| **Utilities** | [Thunar](https://docs.xfce.org/xfce/thunar/start), [Gnome Disks](https://wiki.gnome.org/Apps/Disks), [GParted](https://gparted.org/), [Seahorse](https://wiki.gnome.org/Apps/Seahorse), [Blueman](https://github.com/blueman-project/blueman), [Signal Desktop](https://signal.org/download), [Zoom](https://zoom.us/), [Pika Backup](https://github.com/pika-backup/pika-backup), [Pavucontrol](https://freedesktop.org/software/pulseaudio/pavucontrol/), [Pamixer](https://github.com/cdemoulins/pamixer), [AppImage Run](https://github.com/probonopd/AppImageKit), [Raspberry Pi Imager](https://github.com/raspberrypi/rpi-imager), [wl‑clipboard](https://github.com/bugaevc/wl-clipboard), [grim](https://github.com/emersion/grim), [dunst](https://github.com/dunst-project/dunst), [swaylock‑effects](https://github.com/jirutka/swaylock-effects), [sdrpp](https://github.com/AlexandreRouma/SDRPlusPlus) |
| **Background / UX** | [rofi‑wayland](https://github.com/lbonn/rofi), [SwayOSD](https://github.com/ErikReider/SwayOSD), [Hyprpaper](https://github.com/hyprwm/hyprpaper), [brightnessctl](https://github.com/Hummer12007/brightnessctl) |
| **Assistant** | [Assistant](https://github.com/fursman/Assistant) voice/AI helper |

---

## Keybindings Cheat‑Sheet

> **MOD** = <kbd>SUPER</kbd> (Windows / ⌘)

| Action | Keys |
|--------|------|
| Launcher | **MOD + Return** |
| Terminal | **MOD + T** |
| Browser – Firefox | **MOD + B** |
| Browser – Edge | **MOD + Shift + B** |
| Browser – Chromium | **MOD + Alt + B** |
| File Manager | **MOD + F** |
| Steam | **MOD + G** |
| Screenshot → Clipboard | **Print** |
| Screenshot → `~/Pictures` | **MOD + F12** |
| Lock Screen | **MOD + L** |
| Logout Menu | **MOD + X** |
| Close Window | **MOD + Q** |
| Toggle Split | **MOD + J** |
| Pseudo‑tile | **MOD + P** |
| Focus Move | **MOD + ← ↑ ↓ →** |
| Workspace Switch | **MOD + 1‑0** |
| Move Window → Workspace | **MOD + Shift + 1‑0** |
| Open Podman Desktop | **MOD + D** |
| Open Virt‑Manager | **MOD + V** |
| Open Pika Backup | **MOD + R** |
| Open Signal Desktop | **MOD + S** |
| Open Zoom | **MOD + Z** |
| Open Seahorse | **MOD + K** |
| Quick Assistant | **MOD + SUPER_L** |

_See `flake.nix` ➜ `home.packages` & `environment.systemPackages` for the exhaustive declarative list._

---

## Project Layout

```
.
├── flake.nix - desktop.nix # entry‑point, inputs & outputs
├── config/
│   └── server‑*.nix        # alt. GPU‑passthrough configs
└── README.md
```

* **Inputs**: `nixpkgs` (unstable), `home-manager` – both pinned via `flake.lock`  
* **Outputs**: `nixosConfigurations.desktop` only – other hosts come later

---

## Updating / Pinning Channels

```bash
# Bump all inputs to their latest commit
nix flake update

# Or pin to a specific revision
nix flake lock --update-input nixpkgs --rev <commit>
```

---

## Troubleshooting

* **Black screen after login (NVIDIA)** – ensure `options nvidia-drm modeset=1` and regenerate initrd.  
* **VM fails to start with OpenGL** – verify host i915 / nouveau not loaded, or use `virtio-gpu` instead.  
* **Hyprland crashes** – run `hyprctl logs` in a TTY and check for missing env vars.

See the [NixOS Wiki – Hyprland](https://nixos.wiki/wiki/Hyprland) and [NixOS Discourse](https://discourse.nixos.org) for community help.

---

## License

> “Do what thou wilt shall be the whole of the Law”

This project is released under the [Do What Thou Wilt license](LICENSE) – Have fun because **no warranty** is provided. 

---

## Screenshots

<p align="center">
  <i>Send a PR with your desktop!</i>
</p>
