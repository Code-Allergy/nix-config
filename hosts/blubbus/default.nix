{
  pkgs,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    # Hardware config
    (modulesPath + "/installer/scan/not-detected.nix")
    ./fs.nix

    ../../nixos/virtualisation.nix

    # Hardware
    ../../nixos/hardware/audio.nix
    ../../nixos/hardware/bluetooth.nix
    ../../nixos/hardware/display.nix
    ../../nixos/hardware/nvidia.nix
    ../../nixos/vpn.nix

    # Fileserver mounts
    ../../nixos/samba-mounts.nix

    ../../nixos/environments/plasma.nix
    ../../nixos/environments/hyprland.nix
  ];

  # New (2025) module configuration
  global.config = {
    gaming.enable = true;
  };

  # Bootloader.
  boot = {
    loader.systemd-boot = {
      enable = lib.mkForce false;
      editor = true;
    };
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    plymouth = {
      enable = true;
      theme = "catppuccin-mocha";
    };
    consoleLogLevel = 0;
    initrd.verbose = false;
    initrd.systemd.enable = true;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      # "rd.systemd.show_status=false"

      "acpi_backlight=nvidia_wmi_ec"
    ];

    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usb_storage"
      "sd_mod"
    ];
    # initrd.kernelModules = ["dm-snapshot"];
    initrd.luks.devices = {
      root = {
        device = "/dev/disk/by-uuid/d19873f6-caa4-43a2-8032-0b6cc8e72190";
        preLVM = true;
      };
    };
    loader.timeout = 0;

    # Nvidia drivers often break on latest kernel.. use LTS instead.
    kernelPackages = pkgs.linuxPackages;
  };

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  environment.systemPackages = with pkgs; [
    # power management
    powertop
    brightnessctl

    # Wifi applet
    networkmanagerapplet
  ];

  powerManagement = {
    enable = true;
    powertop.enable = true;
  };
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30s # test value
  '';

  # Laptop TLP battery saving config
  services.power-profiles-daemon.enable = true;
  services.auto-epp.enable = true;

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
      allowedTCPPorts = [ 22000 ];
      allowedUDPPorts = [ 22000 ];
      enable = true;
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        } # KDE Connect
      ];
      allowedUDPPortRanges = [
        {
          from = 1714;
          to = 1764;
        } # KDE Connect
      ];
    };
  };

  services.fwupd.enable = true;

  # Lock on lid close
  services.logind.lidSwitch = "suspend";
  services.logind.lidSwitchExternalPower = "lock";

  # Locale & Time
  time.timeZone = "America/Regina";
  services.chrony.enable = true;
  i18n.defaultLocale = "en_CA.UTF-8";
}
