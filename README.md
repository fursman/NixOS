
# README.md for NixOS Configuration using Home Manager and Flakes

## Introduction

This repository offers a simple yet powerful way to install and configure a NixOS environment tailored to a modern linux desktop workflow with GPU acceleration for containers and virtual environments. It leverages NixOS's reproducibility and the flake system to create a consistent and portable setup.

## Quick Start

1. Install a minimal ISO NixOS from [NixOS Download](https://nixos.org/download).
2. Connect online from your new NixOS minimal install using ethernet, or wirelessly connect using Network Monitor CLI `nmcli <device> wifi connect <mySSID> password <myPassword>`
3. Download `flake.nix` file to `/etc/nixos`:
   ```bash
   cd /etc/nixos
   sudo wget https://raw.githubusercontent.com/fursman/NixOS/main/flake.nix
   ```
4. Apply the configuration (must be done from within the /etc/nixos working directory):
   ```bash
   sudo nixos-rebuild --flake .#desktop switch
   ```

## What's Inside?

### `flake.nix`
- **Description**: "flake for a desktop environment with Home Manager enabled."
- **Inputs**: 
  - `nixpkgs`: Points to `nixos-unstable`.
  - `home-manager`: From `nix-community/home-manager`.
  - `wallpapers`: Custom repository for desktop wallpapers.
- **Outputs**: Configurations for Nix packages and Home Manager.

### `desktop.nix (dynamically linked)`
- **Machine Learning Desktop Specific Configurations**
- **Nix Configuration**: Enables Nix Flakes.
- **Plymouth Boot Screen**: Graphical boot screen setup.
- **Bootloader Settings**: Configures `systemd-boot` and EFI.
- **(Additional system configurations)**

### Custom Configurations
- **Hyprland**: Wayland compositor setup.
- **Waybar**: Customized Wayland bar.
- **Rofi**: Window switcher and application launcher.
- **Kitty**: GPU-based terminal emulator.

### Key Software
- **VS Code**: Primary code editor.
- **Podman-Desktop**: Container management.
- **Virt-Manager**: Virtual environment management.
- **Thunar**: File manager.
- **Firefox**: Web browser.
- **Swaylock**: Session locking.
- **Wlogout**: Session logout interface.

## License

"Do what thou wilt shall be the whole of the Law"
