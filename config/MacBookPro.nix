# config/MacBookPro.nix  – MacBookPro14,1 (A1708) host module
{ config, pkgs, lib, ... }:

let
  kernelPkgs = config.boot.kernelPackages;

  # ────────────────────────────────
  # 1.  Out‑of‑tree kernel modules
  # ────────────────────────────────

  ## 1‑a  Apple SPI keyboard / trackpad
  appleSpiDrv = kernelPkgs.callPackage
    ({ stdenv, fetchFromGitHub, kernel }:
      stdenv.mkDerivation {
        pname    = "apple-spi-driver";
        version  = "2025-05-20";
  
        src = fetchFromGitHub {
          owner  = "marc-git";
          repo   = "macbook12-spi-driver";
          rev    = "807b65b6d9d7c29bd7ff633fbb80596a343e9eb9";  # 2024‑06‑10 (= AUR 0+git.315)
          sha256 = "sha256-MRB4GgBh4qvzrq8sdGpNhSJ3/rVUQcS+kKLkT6QBhV0=";  # ← from `nix flake prefetch`
          fetchSubmodules = true;
        };
        
        patchPhase = ''
          # Replace removed kernel headers in every C source file
          find . -type f -name "*.c" -print0 | while IFS= read -r -d '' f; do
            substituteInPlace "$f" --replace-warn "<linux/input-polldev.h>" "<linux/input.h>" --replace-warn "<asm/unaligned.h>" "<linux/unaligned.h>"
          done
        '';

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
      }) { };
  
  ## 1‑b  Cirrus CS8409 audio driver
  sndHdaMBP = kernelPkgs.callPackage
    ({ stdenv, fetchFromGitHub, kernel }:
      stdenv.mkDerivation {
        pname    = "snd_hda_macbookpro";
        version  = "2025-05-20";
  
        src = fetchFromGitHub {
          owner  = "davidjo";
          repo   = "snd_hda_macbookpro";
          rev    = "259cc39e243daef170f145ba87ad134239b5967f";
          sha256 = "sha256-M1dE4QC7mYFGFU3n4mrkelqU/ZfCA4ycwIcYVsrA4MY=";
        };
  
        nativeBuildInputs = kernel.moduleBuildDependencies;
  
        # build inside the writable work directory
        buildPhase = ''
          make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
               M=$PWD modules
        '';
  
        # copy **all** .ko files that were produced
        installPhase = ''
          mkdir -p $out/lib/modules/${kernel.modDirVersion}/extra
          find . -name '*.ko' -exec install -Dm644 {} \
            $out/lib/modules/${kernel.modDirVersion}/extra/ \;
        '';
  
        meta.description = "Audio driver for Cirrus 8409 on 2016‑17 MacBook Pro";
      }) { };

in
{
  # ─────────── Kernel & bootloader ───────────
  boot.loader.systemd-boot.enable         = true;
  boot.loader.efi.canTouchEfiVariables    = true;
  boot.kernelPackages                     = pkgs.linuxPackages_latest;
  boot.extraModulePackages                = [ appleSpiDrv sndHdaMBP ];

  boot.kernelModules = lib.mkAfter [
    "applespi" "apple_spi_keyboard" "apple_spi_touchpad"
    "snd_hda_macbookpro"
  ];
  boot.blacklistedKernelModules = [ "snd_hda_codec_cs8409" ];
  boot.kernelParams = lib.mkAfter [
    "snd-intel-dspcfg.dsp_driver=1"
    "snd_hda_intel.probe_mask=1"
  ];

  # ─────────── Firmware & Bluetooth ───────────
  nixpkgs.config.allowUnfree             = true;
  hardware.enableRedistributableFirmware = true;
  hardware.firmware                      = with pkgs; [ broadcom-bt-firmware ];
  hardware.bluetooth.enable              = true;
  services.blueman.enable                = true;

  # ─────────── Desktop stack ───────────
  services.xserver.enable                       = true;
  services.xserver.displayManager.gdm = {
    enable  = true;
    wayland = true;
  };
  programs.hyprland.enable                      = true;
  environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
  services.gnome.gnome-keyring.enable           = true;

  # ─────────── PipeWire (audio) ───────────
  services.pulseaudio.enable = false;
  security.rtkit.enable      = true;
  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
    jack.enable       = true;
    wireplumber.enable = true;
    extraConfig.pipewire."context.properties" = {
      "default.clock.rate"        = 48000;
      "default.clock.quantum"     = 32;
      "default.clock.min-quantum" = 32;
      "default.clock.max-quantum" = 32;
    };
  };

  # ─────────── Misc hardware / locale / users ───────────
  networking.hostName                 = "MacBookPro-Nix";
  networking.networkmanager.enable    = true;
  time.timeZone                        = "America/Vancouver";
  i18n.defaultLocale                   = "en_CA.UTF-8";

  fonts.fontconfig.enable              = true;

  services.libinput = {
    enable           = true;
    touchpad.tapping = false;
  };

  users.users.user = {
    isNormalUser = true;
    description  = "user";
    extraGroups  = [ "networkmanager" "wheel" "libvirtd" ];
  };

  environment.systemPackages = with pkgs; [
    git ntfs3g sdrpp dive podman-tui podman-desktop docker-compose
  ];

  virtualisation = {
    libvirtd.enable = true;
    containers.enable = true;
    podman = {
      enable       = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  services.openssh.enable = true;

  system.stateVersion = "24.05";
}
