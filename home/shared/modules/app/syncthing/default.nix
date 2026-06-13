{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.neer.modules.app.syncthing;
in {
  options.neer.modules.app.syncthing = {
    enable = mkEnableOption "Enable Syncthing";
  };

  config = mkIf cfg.enable {
    services.syncthing.enable = true;

    home.packages = with pkgs; [
      syncthingtray
    ];
  };
}
