{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./fs.nix
    ./networking.nix
    ./gaming.nix

    ../../nixos/environments/hyprland.nix
    ../../nixos/environments/plasma.nix
    ../../nixos/samba-mounts.nix
    ../../nixos/virtualisation.nix
    ../../nixos/rust.nix
    ../../nixos/flatpak.nix
    ../../nixos/vpn.nix

    ../../nixos/hardware/amdgpu.nix
    ../../nixos/hardware/audio.nix
    ../../nixos/hardware/bluetooth.nix
    ../../nixos/hardware/printing.nix
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];

    kernelModules = ["kvm-amd"];
    extraModulePackages = [];

    extraModprobeConfig = ''
      options kvm_intel nested=1
      options kvm_intel emulate_invalid_guest_state=0
      options kvm ignore_msrs=1
    '';
    kernelParams = [
      # AMD pstate freq scaler
      "amd_pstate=active"

      # IT8686e sensor TODO
      "acpi_enforce_resources=lax"
    ];

    # Latest kernel vers
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # TODO Test governers
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  time.timeZone = "America/Regina";

  system = {
    autoUpgrade = {
      enable = true;
      allowReboot = false;
      dates = "7:30";
    };
  };

  # TODO unsure if blubbus needs
  services.upower.enable = true;
}
