{ lib, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix

    ../../environments/hyprland.nix
    ../../environments/plasma.nix
    ../../modules/samba-mounts.nix
  ];

  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb-with-all-plugins;
  };
  time.timeZone = "America/Regina";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
