{ config, pkgs, ... }:
let
  lib = pkgs.lib;
  kvmfrSettings = {
    enable = true;
    shm = {
      enable = true;
      size = 128;
      user = "qemu-libvirtd";
      group = "qemu-libvirtd";
      mode = "0660";
    };
  };
  # Inline kvmfr kernel module derivation
  kvmfrModule = pkgs.stdenv.mkDerivation rec {
    pname = "kvmfr-${pkgs.looking-glass-client.version}-${config.boot.kernelPackages.kernel.version}";
    version = pkgs.looking-glass-client.version;
    src = pkgs.looking-glass-client.src;
    sourceRoot = "source/module";
    hardeningDisable = [ "pic" "format" ];
    nativeBuildInputs = config.boot.kernelPackages.kernel.moduleBuildDependencies;
    makeFlags = [
      "KVER=${config.boot.kernelPackages.kernel.modDirVersion}"
      "KDIR=${config.boot.kernelPackages.kernel.dev}/lib/modules/${config.boot.kernelPackages.kernel.modDirVersion}/build"
    ];
    installPhase = ''
      install -D kvmfr.ko -t "$out/lib/modules/${config.boot.kernelPackages.kernel.modDirVersion}/kernel/drivers/misc/"
    '';
    meta = with pkgs.lib; {
      description = "This kernel module implements a basic interface to the IVSHMEM device for LookingGlass";
      homepage = "https://github.com/gnif/LookingGlass";
      license = licenses.gpl2Only;
      maintainers = [ "j-brn" ];
      platforms = [ "x86_64-linux" ];
    };
  };
in {
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  boot.kernelModules = [
    "kvm"
    "kvm_intel"
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
    "vfio_virqfd"
  ];
  boot.extraModprobeConfig = "options vfio-pci ids=10de:2684,10de:22ba";

  boot.plymouth = {
    enable = true;
    theme = "red_loader";
    themePackages = [
      (pkgs.adi1090x-plymouth-themes.override { selected_themes = [ "red_loader" ]; })
    ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;
  boot.initrd.verbose = false;
  boot.loader.timeout = 0;
  boot.consoleLogLevel = 0;
  boot.kernelParams = [ "quiet" "splash" "intel_iommu=on" "iommu=pt" ]
    ++ (if kvmfrSettings.shm.enable then [ "kvmfr.static_size_mb=${toString kvmfrSettings.shm.size}" ] else []);

  boot.supportedFilesystems = [ "ntfs" ];

  environment.etc."modules-load.d/kvmfr.conf".text = "kvmfr\n";

  environment.etc."libvirt/qemu.conf".text = ''
    # Enable QEMU to access necessary devices for guest RAM
    cgroup_device_acl = [
      "/dev/kvmfr0"
      "/dev/null"
      "/dev/zero"
      "/dev/full"
      "/dev/random"
      "/dev/urandom"
      "/dev/tty"
    ];
  '';

  systemd.services.libvirtd = {
    serviceConfig = {
      DeviceAllow = "/dev/kvmfr0 rw";
    };
  };

  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  time.timeZone = "America/Vancouver";

  i18n.defaultLocale = "en_CA.UTF-8";

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.displayManager.gdm.enable = true;

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  programs.hyprland.enable = true;
  environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";

  services.dbus.packages = with pkgs; [ xfce.xfconf ];

  fonts.packages = with pkgs; [ font-awesome ];
  fonts.fontconfig.enable = true;
  services.gvfs.enable = true;

  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };

  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    git
    ntfs3g
    adi1090x-plymouth-themes
    sdrpp
    looking-glass-client
  ];

  users.users.user = {
    isNormalUser = true;
    description = "user";
    extraGroups = [ 
      "networkmanager"
      "wheel"
      "libvirtd"   # Needed for virt-manager
      "kvm"
      "qemu-libvirtd"
    ];
  };

  virtualisation = {
    libvirtd = {
      enable = true;
      onBoot = "ignore";
      onShutdown = "shutdown";
      qemu = {
        package = pkgs.qemu_kvm;
        ovmf = { enable = true; };
        swtpm.enable = true;
        runAsRoot = false;
      };
    };
    spiceUSBRedirection.enable = true;
  };

  # Build and load the KVMFR module using our custom kvmfrSettings
  boot.extraModulePackages = [ kvmfrModule ];
  boot.initrd.kernelModules = [ "kvmfr" ];
  services.udev.extraRules = lib.optionals kvmfrSettings.shm.enable ''
    SUBSYSTEM=="kvmfr", OWNER="${kvmfrSettings.shm.user}", GROUP="${kvmfrSettings.shm.group}", MODE="${kvmfrSettings.shm.mode}"
  '';

  # (Optional) Remove tmpfiles rule since the new setup manages shared memory automatically.
  # systemd.tmpfiles.rules = [ "f /dev/shm/looking-glass 0777 user qemu-libvirtd -" ];

  programs.dconf.enable = true;
  programs.virt-manager.enable = true;

  services.openssh = {
    enable = true;
    extraConfig = ''
      allowTcpForwarding yes
      gatewayPorts clientspecified
    '';
  };

  networking = {
    hostName = "Block";
    firewall.allowedTCPPorts = [ 7860 8080 ];
  };

  system.stateVersion = "24.05";
}
