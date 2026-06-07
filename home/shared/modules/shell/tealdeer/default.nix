{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.neer.modules.shell.tealdeer;
in {
  options.neer.modules.shell.tealdeer.enable = mkEnableOption "Enable tealdeer";

  config = mkIf cfg.enable {
    programs.tealdeer = {
      enable = true;
      settings.updates = {
        auto_update = true;
        auto_update_interval_hours = 24;
      };
    };
  };
}
