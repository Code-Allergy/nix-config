# Add your reusable NixOS modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  lib,
  config,
  ...
}:

with lib;
{
  options.global.config = {
    headless = mkEnableOption "Enable headless home-manager configuration";
  };
  # List your module files here
  imports = [
    ./gaming.nix
  ];

  config = {
    home-manager.users.ryan.global.config.headless = config.global.config.headless;
  };
}
