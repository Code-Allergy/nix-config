# Add your reusable home-manager modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.

{
  lib,
  ...
}:

with lib;
{
  options.neer = {
    profiles.headless.enable = mkEnableOption "Enable headless home-manager configuration";
    modules.dev.enable = mkEnableOption "Enable development configuration";
  };

  imports = [
    ./ai/ollama.nix
    ./app/browsers.nix
    ./app/chromium.nix
    ./app/communication.nix
    ./app/entertainment.nix
    ./app/firefox.nix
    ./app/jetbrains.nix
    ./app/keyring
    ./app/kitty
    ./app/nvim.nix
    ./app/obs.nix
    ./app/syncthing
    ./app/vscode.nix
    ./app/yazi
    ./app/zed.nix
    ./desktop/hypr
    ./desktop/qtile
    ./desktop/rofi
    ./dev/distrobox.nix
    ./dev/rust.nix
    ./gaming
    ./shell
  ];
}
