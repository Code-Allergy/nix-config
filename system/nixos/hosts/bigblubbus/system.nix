{ lib, ... }:
{
  imports = [
    ./hardware.nix
    ./networking.nix

    ../../environments/hyprland.nix
    ../../environments/plasma.nix
  ];

  neer.modules.gaming.enable = true;
  services.fwupd.enable = true;

  time.timeZone = "America/Regina";

  # TODO: move this into a shared hardware/profile toggle later.
  boot = {
    # kept here only if the system layer needs a system-wide toggle
    # (the detailed boot config lives in hardware.nix).
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
