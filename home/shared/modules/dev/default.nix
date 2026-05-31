{ lib, ... }:
with lib;
{
  options.neer = {
    modules.dev.enable = mkEnableOption "Enable development configuration";
  };
  imports = [
    ./rust.nix
    ./distrobox.nix
  ];
}
