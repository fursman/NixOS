
# README.md for NixOS Configuration

## Introduction

Welcome to my NixOS configuration repository. This repository offers a simple yet powerful way to install and configure a NixOS environment, tailored to a modern linux desktop workflow. It leverages NixOS's reproducibility and the flake system to create a consistent and portable setup.

## Quick Start

1. Install a minimal ISO NixOS from [NixOS Download](https://nixos.org/download).
2. Download `flake.nix` file to `/etc/nixos`:
   ```bash
   wget https://raw.githubusercontent.com/fursman/NixOS/main/flake.nix
   ```
3. Apply the configuration:
   ```bash
   sudo nixos-rebuild --flake .#RBS17 switch
   ```

## What's Inside?

### `flake.nix`
- **Description**: "flake for RBS17 with Home Manager enabled."
- **Inputs**: 
  - `nixpkgs`: Points to `nixos-unstable`.
  - `home-manager`: From `nix-community/home-manager`.
  - `wallpapers`: Custom repository for desktop wallpapers.
- **Outputs**: Configurations for Nix packages and Home Manager.

### `stealth17.nix (dynamically linked)`
- **Razer Blade Stealth 17 Specific Configurations.
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

## Detailed Description of the Process

### Steps:
1. **Initial Setup**: Install a fresh NixOS minimal environment and ensure internet connectivity.
2. **Connect online**: From your new install, connect online using ethernet or wirelessly connect using Network Monitor CLI `nmcli <device> wifi connect <mySSID> password <myPassword>`
3. **Download Configuration**: Use `wget` to directly download the `flake.nix` raw file from github as detailed above.
4. **Apply Configuration**: Execute `sudo nixos-rebuild` to rebuild your NixOS using the new configuration.
5. **Customization**: Modify `flake.nix`, `stealth17.nix`, and linked configuration files as necessary.

## License

"Do what thou wilt shall be the whole of the Law",
