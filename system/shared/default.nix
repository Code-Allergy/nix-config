# Add your reusable NixOS modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  lib,
  config,
  ...
}:

with lib;
{
  options.neer = {
    profiles.headless.enable = mkEnableOption "Enable headless home-manager configuration";
    modules.dev.enable = mkEnableOption "Enable development configuration";
  };
  # List your module files here
  imports = [
    ./gaming.nix
  ];

  config = {
    home-manager.users.ryan.neer.profiles.headless.enable = config.neer.profiles.headless.enable;
  };
}
