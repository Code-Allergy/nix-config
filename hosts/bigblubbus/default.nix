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
    ./gaming.nix

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

  environment.systemPackages = with pkgs; [
    lm_sensors
    openrgb-with-all-plugins
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
      "kvm-amd"
      "it87"
    ];
    extraModulePackages = [ ];

    extraModprobeConfig = ''
      options kvm_intel nested=1
      options kvm_intel emulate_invalid_guest_state=0
      options kvm ignore_msrs=1
      options it87 force_id=0x8628
    '';
    kernelParams = [
      # AMD pstate freq scaler
      "amd_pstate=active"

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

  # AMD-PState recommended governor
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.cpu.amd.ryzen-smu.enable = true;

  time.timeZone = "America/Regina";

  services.open-webui = {
    enable = true;
  };
  services.hardware.openrgb.enable = true;

  system = {
    autoUpgrade = {
      enable = true;
      allowReboot = false;
      dates = "7:30";
    };
  };
}
