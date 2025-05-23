# config/MacBookPro.nix  – MacBookPro14,1 (A1708)
{ config, pkgs, lib, ... }:

##############################################################################
# 1 ░░  Overlay that provides pre‑patched drivers
##############################################################################
#
# The overlay adds two derivations:
#   • apple-spi-driver  → internal keyboard & trackpad
#   • macbookpro-cs8409 → Cirrus 8409 audio codec
#
# Both recipes live inside the overlay, so this host file stays tiny.
#
let
  appleMbpOverlay = final: prev: {
    # ───────────────────────── Apple SPI (input) ──────────────────────────
    apple-spi-driver = prev.linuxPackages.callPackage (
      { stdenv, fetchFromGitHub, kernel, ... }:
      stdenv.mkDerivation rec {
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

        # tiny patch: adapt to kernel ≥ 6.12 header moves
        patchPhase = ''
          substituteInPlace $(grep -rl "<linux/input-polldev.h>" .) \
            --replace "<linux/input-polldev.h>" "<linux/input.h>"
          substituteInPlace $(grep -rl "<asm/unaligned.h>" .) \
            --replace "<asm/unaligned.h>" "<linux/unaligned.h>"
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

    # ───────────────────────── Cirrus CS8409 (audio) ──────────────────────
    macbookpro-cs8409 = prev.linuxPackages.callPackage (
      { stdenv, fetchFromGitHub, kernel, ... }:
      stdenv.mkDerivation rec {
        pname   = "snd_hda_macbookpro";
        version = "2025-05-20";

        src = fetchFromGitHub {
          owner  = "davidjo";
          repo   = "snd_hda_macbookpro";
          rev    = "259cc39e243daef170f145ba87ad134239b5967f";
          sha256 = "sha256-M1dE4QC7mYFGFU3n4mrkelqU/ZfCA4ycwIcYVsrA4MY=";
        };

        nativeBuildInputs = kernel.moduleBuildDependencies;

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
  };
in
##############################################################################
# 2 ░░  Host configuration
##############################################################################
{
  nixpkgs.overlays = [ appleMbpOverlay ];

  # ── kernel & modules ────────────────────────────────────────────────────
  boot.kernelPackages       = pkgs.linuxPackages_latest;
  boot.extraModulePackages  = [ pkgs.apple-spi-driver pkgs.macbookpro-cs8409 ];
  boot.kernelModules        = [ "applespi" "apple_spi_keyboard" "apple_spi_touchpad"
                                "snd_hda_macbookpro" ];
  boot.blacklistedKernelModules = [ "snd_hda_codec_cs8409" ];
  boot.kernelParams = [
    "snd-intel-dspcfg.dsp_driver=1"
    "snd_hda_intel.probe_mask=1"
  ];

  # ── firmware & Bluetooth ───────────────────────────────────────────────
  nixpkgs.config.allowUnfree             = true;
  hardware.enableRedistributableFirmware = true;
  hardware.firmware                      = with pkgs; [ broadcom-bt-firmware ];
  hardware.bluetooth.enable              = true;
  services.blueman.enable                = true;

  # ── desktop, audio, misc  (kept from your original) ────────────────────
  services.xserver.enable = true;
  services.xserver.displayManager.gdm = { enable = true; wayland = true; };
  programs.hyprland.enable = true;
  services.gnome.gnome-keyring.enable = true;
  environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";

  services.pulseaudio.enable = false;
  security.rtkit.enable      = true;
  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
    jack.enable       = true;
    wireplumber.enable = true;
  };

  networking.hostName              = "MacBookPro-Nix";
  networking.networkmanager.enable = true;
  time.timeZone                     = "America/Vancouver";
  i18n.defaultLocale                = "en_CA.UTF-8";

  services.libinput.enable = true;
  services.libinput.touchpad.tapping = false;
  fonts.fontconfig.enable = true;

  users.users.user = {
    isNormalUser = true;
    description  = "user";
    extraGroups  = [ "networkmanager" "wheel" "libvirtd" ];
  };

  environment.systemPackages = with pkg
