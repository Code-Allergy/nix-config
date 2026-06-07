{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./fs.nix
  ];

  environment.systemPackages = with pkgs; [
    lm_sensors
  ];

  boot = {
    loader.systemd-boot.enable = lib.mkForce false;
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
    loader.efi.canTouchEfiVariables = true;

    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];

    kernelModules = [
      "ip_tables"
      "iptable_nat"
      "kvm-amd"
      "it87"
    ];
    extraModulePackages = [];

    extraModprobeConfig = ''
      options kvm ignore_msrs=1
      options it87 force_id=0x8628
    '';

    kernelParams = [
      # IT8686e sensor
      "acpi_enforce_resources=lax"
      "it87.force_id=0x8628"

      # Display
      "video=DP-1:1920x1080@144"
      "video=HDMI-A-1:1920x1080@60:rotate:3"
    ];

    # Latest kernel vers
    kernelPackages = pkgs.linuxPackages_latest;
  };
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb-with-all-plugins;
  };

  services.fwupd.enable = true;
}
