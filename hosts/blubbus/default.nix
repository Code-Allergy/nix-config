{
  pkgs,
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    # Hardware config
    (modulesPath + "/installer/scan/not-detected.nix")

    # Hardware
    ../../nixos/hardware/audio.nix
    ../../nixos/hardware/bluetooth.nix
    ../../nixos/hardware/display.nix
    ../../nixos/hardware/nvidia.nix

    # Fileserver mounts
    ../../nixos/samba-mounts.nix

    # Register ryan as default user
    ../../nixos/users/ryan

    # Run qtile environment
    ../../nixos/environments/qtile.nix
    # ../../nixos/environments/gnome.nix

    # common configs for all deployments
    ../../nixos/common.nix
  ];

  # Bootloader.
  boot = {
    loader.systemd-boot = {
      enable = true;
      netbootxyz.enable = true;
      memtest86.enable = true;
      editor = false;
    };

    plymouth = {
      enable = true;
      themePackages = [pkgs.catppuccin-plymouth pkgs.nixos-bgrt-plymouth];
      theme = "bgrt";
    };

    kernelParams = [
      "quiet"
      "splash"
      "acpi_backlight=nvidia_wmi_ec"

      # Amd PState_
      "initcall_blacklist=acpi_cpufreq_init"
      "amd_pstate=active"
    ];
    initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod"];
    initrd.kernelModules = ["dm-snapshot"];
    initrd.luks.devices = {
      root = {
        device = "/dev/nvme1n1p2";
        preLVM = true;
      };
    };

    kernelModules = [
      # Enable VFIO for passthrough
      "vfio"
      "vfio_pci"
      "vfio_iommu_type1"
      "vfio_virqfd"
      "kvm-amd"

      # unknown if needed
      "acpi_call"
    ];
    extraModulePackages = with config.boot.kernelPackages; [acpi_call];

    # Kernel version -- use latest stable
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # Root FS
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/4894db5b-c287-4f21-ac36-6db9b6c8de07";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/A7A9-9D2E";
      fsType = "vfat";
    };
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/2ba14f11-3e3a-46d7-8f69-e443be36e33b";}
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  environment.systemPackages = with pkgs; [
    # power management
    powertop
  ];

  # Laptop TLP battery saving config
  services.tlp.enable = true;
  services.tlp.settings = {
    CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

    PLATFORM_PROFILE_ON_AC = "balanced";
    PLATFORM_PROFILE_ON_BAT = "low-power";

    CPU_BOOST_ON_AC = "1";
    CPU_BOOST_ON_BAT = "0";
  };

  # Enable acpi daemon so laptop close/open is responded to
  services.acpid.enable = true;

  # Display brightness
  programs.light.enable = true;

  # Network config
  networking = {
    hostName = "blubbus";
    networkmanager = {
      enable = true;
      wifi.powersave = true;
    };

    firewall = {
      allowedTCPPorts = [];
      allowedUDPPorts = [];
      enable = true;
    };
  };

  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-volman
    thunar-archive-plugin
  ];
  services.gvfs.enable = true;
  services.fwupd.enable = true;
  # services.cpupower-gui.enable = true;

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Locale & Time
  time.timeZone = "America/Regina";
  services.chrony.enable = true;
  i18n.defaultLocale = "en_CA.UTF-8";
}
