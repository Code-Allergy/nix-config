{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.neer.modules.app.browsers;
in {
  imports = [
    ./firefox.nix
    ./chromium.nix
  ];

  options.neer.modules.app.browsers = {
    enable = mkEnableOption "Enable all browsers";
  };

  config = mkIf cfg.enable {
    neer.modules.app.browsers = {
      firefox.enable = true;
      chromium.enable = true;
    };
  };
}
