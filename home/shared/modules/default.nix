# Add your reusable home-manager modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.

{
  lib,
  ...
}:

with lib;
{
  options.global.config = {
    headless = mkEnableOption "Enable headless home-manager configuration";
  };

  imports = [
    ./development
    ./gaming.nix
  ];
}
