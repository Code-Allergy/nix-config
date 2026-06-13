# TODO: Generate more modules here as needed
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.neer.modules.app.entertainment.base;
in {
  options.neer.modules.app.entertainment.base = {
    enable = mkEnableOption "Enable entertainment base module";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # jellyfin-media-player
      jellycli
      feishin
      spotube
      pear-desktop
      vlc
    ];

    programs.freetube = {
      enable = true;
      settings = {
        allowDashAv1Formats = true;
        checkForUpdates = false;
        defaultQuality = "1440";
        baseTheme = "catppuccinMocha";
      };
    };
  };
}
