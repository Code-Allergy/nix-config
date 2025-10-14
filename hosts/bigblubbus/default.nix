{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./fs.nix
    ./networking.nix

    ../../nixos/environments/hyprland.nix
    ../../nixos/environments/plasma.nix
    ../../nixos/samba-mounts.nix
    ../../nixos/virtualisation.nix
    ../../nixos/flatpak.nix
    ../../nixos/vpn.nix

    ../../nixos/hardware/amdgpu.nix
    ../../nixos/hardware/audio.nix
    ../../nixos/hardware/bluetooth.nix
    ../../nixos/hardware/printing.nix
    ../../nixos/hardware/footpetal.nix
  ];

  # New (2025) module configuration
  global.config = {
    gaming.enable = true;
  };

  environment.systemPackages = with pkgs; [
    lm_sensors
    # openrgb-with-all-plugins
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
  services.fwupd.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  time.timeZone = "America/Regina";

  services.hardware.openrgb.enable = true;

  # enable bluetooth on boot
  hardware.bluetooth.powerOnBoot = lib.mkForce true;
}
