{ config, pkgs, lib, ... }:

################################################################################
# Overlay: pre‑patched SPI (input) and CS8409 (audio) kernel modules
################################################################################
let
  appleMbpOverlay = final: prev: {
    # ── Apple SPI keyboard / touchpad driver ──────────────────────────────
    apple-spi-driver = prev.linuxPackages.callPackage (
      { stdenv, fetchFromGitHub, kernel, ... }:
      stdenv.mkDerivation {
        pname   = "apple-spi-driver";
        version = "2025-05-20";

        src = fetchFromGitHub {
          owner  = "marc-git";
          repo   = "macbook12-spi-driver";
          rev    = "807b65b6d9d7c29bd7ff633fbb80596a343e9eb9";
          sha256 = "sha256-MRB4GgBh4qvzrq8sdGpNhSJ3/rVUQcS+kKLkT6QBhV0=";
          fetchSubmodules = true;
        };

        nativeBuildInputs = kernel.moduleBuildDependencies;

        # --- robust header fix ------------------------------------------------
        patchPhase = ''
          find . -type f -name "*.c" -exec sed -i \
            -e 's|<linux/input-polldev.h>|<linux/input.h>|g' \
            -e 's|<asm/unaligned.h>|<linux/unaligned.h>|g' \
            -e 's|\<no_llseek\>|noop_llseek|g' {} +
        '';

        buildPhase = ''
          make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
               M=$PWD modules
        '';

        installPhase = ''
          mkdir -p $out/lib/modules/${kernel.modDirVersion}/extra
          find . -name '*.ko' -exec install -Dm644 {} \
               $out/lib/modules/${kernel.modDirVersion}/extra/ \;
        '';
      }
    ) { };

    # ── Cirrus CS8409 audio driver (snd-hda-codec-cs8409) ─────────────────
    snd-hda-codec-cs8409 = prev.linuxPackages.callPackage (
      { stdenv, fetchFromGitHub, kernel, ... }:
      stdenv.mkDerivation {
        pname   = "snd-hda-codec-cs8409";
        version = "2025-05-20";

        src = fetchFromGitHub {
          owner  = "egorenar";
          repo   = "snd-hda-codec-cs8409";
          rev    = "d0d785dc1859b09299bde6d0f1d6786a0d610e7f";
          sha256 = "sha256-0UeoERcYpM+ojeZ7dDIE3ruTIoHkkC+s7FcoEVUTR0w=";
        };

        hardeningDisable = [ "pic" ];

        nativeBuildInputs = kernel.moduleBuildDependencies;

        postPatch = ''
          sed --in-place 's|<sound/cs42l42.h>|"${kernel.dev}/lib/modules/${kernel.modDirVersion}/source/include/sound/cs42l42.h"|' patch_cs8409.h
          sed --in-place 's|hda_local.h|${kernel.dev}/lib/modules/${kernel.modDirVersion}/source/sound/pci/hda/hda_local.h|' patch_cs8409.h
          sed --in-place 's|hda_jack.h|${kernel.dev}/lib/modules/${kernel.modDirVersion}/source/sound/pci/hda/hda_jack.h|' patch_cs8409.h
          sed --in-place 's|hda_generic.h|${kernel.dev}/lib/modules/${kernel.modDirVersion}/source/sound/pci/hda/hda_generic.h|' patch_cs8409.h
          sed --in-place 's|hda_auto_parser.h|${kernel.dev}/lib/modules/${kernel.modDirVersion}/source/sound/pci/hda/hda_auto_parser.h|' patch_cs8409.h
        '';

        makeFlags = kernel.makeFlags ++ [ "INSTALL_MOD_PATH=$(out)" "KERNELRELEASE=${kernel.modDirVersion}" "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build" ];

        buildPhase = ''
          make ${toString makeFlags}
        '';

        installPhase = ''
          make install ${toString makeFlags}
        '';
      }
    ) { };
  };
in
################################################################################
# Host configuration  (identical to previous, plus GRUB disabled)
################################################################################
{
  nixpkgs.overlays = [ appleMbpOverlay ];

  # Bootloader / kernel
  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable              = false;

  boot.kernelPackages      = pkgs.linuxPackages_latest;
  boot.extraModulePackages = [ pkgs.apple-spi-driver pkgs.snd-hda-codec-cs8409 ];
  boot.kernelModules       = [
    "applespi" "apple_spi_keyboard" "apple_spi_touchpad"
    "snd_hda_codec_cs8409"
  ];
  boot.blacklistedKernelModules = [ "snd_hda_codec_cs8409" ];
  boot.kernelParams = [
    "snd-intel-dspcfg.dsp_driver=1"
    "snd_hda_intel.probe_mask=1"
  ];

  # Firmware & Bluetooth
  nixpkgs.config.allowUnfree             = true;
  hardware.enableRedistributableFirmware = true;
  hardware.firmware                      = with pkgs; [ broadcom-bt-firmware ];
  hardware.bluetooth.enable              = true;
  services.blueman.enable                = true;

  # Desktop & PipeWire
  services.xserver.enable                       = true;
  services.xserver.displayManager.gdm = { enable = true; wayland = true; };
  programs.hyprland.enable                      = true;
  services.gnome.gnome-keyring.enable           = true;
  environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";

  services.pulseaudio.enable = false;
  security.rtkit.enable      = true;
  services.pipewire.enable   = true;

  # Locale / fonts / input
  networking.hostName              = "MacBookPro-Nix";
  networking.networkmanager.enable = true;
  time.timeZone                     = "America/Vancouver";
  i18n.defaultLocale                = "en_CA.UTF-8";

  fonts.fontconfig.enable = true;
  services.libinput.enable = true;
  services.libinput.touchpad.tapping = false;

  # Users & packages
  users.users.user = {
    isNormalUser = true;
    description  = "user";
    extraGroups  = [
      "networkmanager"
      "wheel"
      "libvirtd"
    ];
  };

  ########################################################################
  # System‑wide packages you wanted
  ########################################################################
  environment.systemPackages = with pkgs; [
    git ntfs3g sdrpp dive podman-tui podman-desktop docker-compose
    alsa-utils pavucontrol
  ];

  ########################################################################
  # Virtualisation & Podman
  ########################################################################
  virtualisation = {
    libvirtd.enable = true;
    containers.enable = true;
    podman = {
      enable       = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  ########################################################################
  # OpenSSH service
  ########################################################################
  services.openssh.enable = true;

  ########################################################################
  # Remember the release you first installed
  ########################################################################
  system.stateVersion = "24.05";
}
