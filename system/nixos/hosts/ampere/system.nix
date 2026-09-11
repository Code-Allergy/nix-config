{ lib, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    # temp nvidia module because other nvidia module is too coupled with blubbus
    ./nvidia.nix

  ];

  time.timeZone = "America/Regina";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  xdg.portal.enable = true;

  services.qemuGuest.enable = true;

  # this will be in compute module
  hardware.nvidia-container-toolkit.enable = true;
}
