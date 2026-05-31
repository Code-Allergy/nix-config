{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./fs.nix

    ../../modules/samba-mounts.nix
    ../../modules/flatpak.nix
    ../../modules/vpn.nix

    ../../hardware/footpetal.nix
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
    extraModulePackages = [ ];

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

      # AMDGPU
      "amdgpu.ppfeaturemask=0xffffffff"
    ];

    # Latest kernel vers
    kernelPackages = pkgs.linuxPackages_latest;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb-with-all-plugins;
  };

  # enable bluetooth on boot
  hardware.bluetooth.powerOnBoot = lib.mkForce true;
  services.fwupd.enable = true;
}
