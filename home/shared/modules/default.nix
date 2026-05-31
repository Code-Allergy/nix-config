# Add your reusable home-manager modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.

{
  lib,
  ...
}:

with lib;
{
  options.neer = {
    modules.dev.enable = mkEnableOption "Enable development configuration";
  };

  imports = [
    ./ai
    ./app
    ./desktop
    ./dev
    ./gaming
    ./shell
  ];
}
