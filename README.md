# README.md for NixOS Configuration using Home Manager and Flakes

## Introduction

This repository offers a simple yet powerful way to install and configure a NixOS environment tailored to a modern linux desktop workflow with GPU acceleration for containers and virtual environments. It leverages NixOS's reproducibility and the flake system to create a consistent and portable setup.

## Quick Start

1. **Initial Installation**: Install a minimal ISO NixOS from [NixOS Download](https://nixos.org/download).
2. **Network Connection**: Connect with an Ethernet cable or use Network Monitor CLI `nmcli <device> wifi connect <mySSID> password <myPassword>` for a wireless connection.
3. **Download `flake.nix` to `/etc/nixos/`**:
   ```
   cd /etc/nixos # Change directory to the NixOs configurations home
   nix-shell -p wget # Open a temporary shell with wget to fetch web files
   sudo wget https://raw.githubusercontent.com/fursman/NixOS/main/flake.nix
   ```
5. Apply the configuration
   must be executed from within the /etc/nixos working directory
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
