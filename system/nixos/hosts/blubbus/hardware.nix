{ lib, pkgs, ... }:
{
  imports = [
    ./fs.nix

    # Hardware
    ../../hardware/audio.nix
    # ../../hardware/hibernate-after-sleep.nix
    ../../modules/vpn.nix

    # Fileserver mounts
    ../../modules/samba-mounts.nix

    ../../environments/plasma.nix
    ../../environments/hyprland.nix
  ];

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

      # hibernation
      "nvidia.NVreg_UsePageAttributeTable=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia.NVreg_TemporaryFilePath=/var/tmp"

      "acpi_backlight=nvidia_wmi_ec"
    ];

    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usb_storage"
      "sd_mod"
    ];

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

  # Laptop TLP battery saving config
  services.power-profiles-daemon.enable = true;
  services.auto-epp.enable = true;

  # Enable acpi daemon so laptop close/open is responded to
  services.acpid.enable = true;

  # Display brightness
  hardware.acpilight.enable = true;

  # Update firmware
  services.fwupd.enable = true;

}
