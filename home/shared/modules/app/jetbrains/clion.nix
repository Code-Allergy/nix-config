{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.neer.modules.app.jetbrains;
  enabled =
    if cfg.clion.enable == null
    then cfg.enable
    else cfg.clion.enable;
  package =
    if cfg.clion.package != null
    then cfg.clion.package
    else pkgs.jetbrains.clion;
in {
  options.neer.modules.app.jetbrains.clion = {
    enable = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = "Enable CLion. Defaults to the root JetBrains master switch when unset.";
    };

    package = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = "Package to use for CLion.";
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
