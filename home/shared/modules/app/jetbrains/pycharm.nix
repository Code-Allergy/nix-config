{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.neer.modules.app.jetbrains;
  enabled =
    if cfg.pycharm.enable == null
    then cfg.enable
    else cfg.pycharm.enable;
  package =
    if cfg.pycharm.package != null
    then cfg.pycharm.package
    else pkgs.jetbrains.pycharm;
in {
  options.neer.modules.app.jetbrains.pycharm = {
    enable = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = "Enable PyCharm. Defaults to the root JetBrains master switch when unset.";
    };

    package = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = "Package to use for PyCharm.";
    };
  };

  config = mkIf enabled {
    home.packages = [package];

    programs.jetbrains-remote = mkIf cfg.remote.enable {
      enable = true;
      ides = [package];
    };
  };
}
