{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.seer.modules.app.obs;
in {
  options.seer.modules.app.obs = {
    enable = mkEnableOption "Open Broadcast Software";
    package = mkOption {
      description = "Package for obs-studio";
      type = with types; nullOr package;
      default = pkgs.obs-studio;
    };
  };

  config = mkIf cfg.enable {
    programs.obs-studio = {
      enable = cfg.enable;
      package = cfg.package;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    };
  };
}
