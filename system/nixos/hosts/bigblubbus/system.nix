{ lib, ... }:
{
  imports = [
    ./hardware.nix
    ./networking.nix

    ../../environments/hyprland.nix
    ../../environments/plasma.nix
  ];
  time.timeZone = "America/Regina";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
