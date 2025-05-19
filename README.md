
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
#    ↳ https://nixos.org/download.html

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
| **Hyprland** | Wayland compositor with NVIDIA patches + basic wobbling‑window eye‑candy |
| Waybar     | Custom theming, weather & media modules |
| Rofi‑Wayland | Spotlight‑like launcher with Dracula theme |
| Hyprpaper  | Multi‑monitor wallpapers with gentle cross‑fade |
| Kitty      | GPU‑accelerated terminal; ligatures & truecolour |
| Dracula GTK/Qt | Consistent dark theming across apps |

### Virtualisation & Containers

* **libvirt + virt‑manager** with SPICE & UEFI firmware
* **VFIO hooks** ready for single‑GPU passthrough (see `config/server*.nix`)
* **Podman Desktop** & rootless containers
* QEMU with OpenGL and 3D acceleration
* USB redirection & shared folders (9p, virtfs)

### Hardware Support

* NVIDIA proprietary driver (`nvidia`, modesetting, Vulkan, 32‑bit GL)
* Bluetooth + Blueman
* Plymouth graphical boot splash
* systemd‑boot (EFI) with auto‑rollback generation menu
* NTFS‑3G read/write, `brightnessctl`, `swayosd` OSD

### Pre‑installed Applications

| Category | Packages |
|----------|----------|
| Essentials | `git`, `wget`, `imagemagick`, `python3.withPackages (requests)` |
| Media     | `vlc`, `gimp`, `eog`, `signal-desktop` |
| Gaming    | `steam` (Big Picture desktop entry) |
| Dev Tools | `vscode.fhs`, `links2` (TUI browser) |
| Utils     | `swaylock-effects`, `wlogout`, `ntfs-3g` |

_See `flake.nix` ➜ `desktopNix` for the complete list._

---

## Keybindings Cheat‑Sheet

> **MOD** = `SUPER` (Windows / ⌘)

| Action | Keys |
|--------|------|
| Launcher | **MOD + Return** |
| Terminal | **MOD + T** |
| Browser  | **MOD + B** |
| File Manager | **MOD + F** |
| Steam (Big Picture) | **MOD + G** |
| Voice Assistant | **MOD + Space** |
| Lock Screen | **MOD + L** |
| Logout Menu | **MOD + X** |
| Close Window | **MOD + Q** |
| Toggle Split | **MOD + J** |
| Pseudo‑tile  | **MOD + P** |
| Focus Move | **MOD + Arrows** |
| Workspace Switch | **MOD + 1‑0** |
| Move Window to Workspace | **MOD + Shift + 1‑0** |

---

## Project Layout

```
.
├── flake.nix          # entry‑point, inputs & outputs
├── config/
│   ├── desktop.nix    # .#desktop system modules
│   └── server‑*.nix   # alt. GPU‑passthrough configs
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
