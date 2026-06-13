{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.neer.modules.app.jetbrains;
  enabled =
    if cfg.androidStudio.enable == null
    then cfg.enable
    else cfg.androidStudio.enable;
  package =
    if cfg.androidStudio.package != null
    then cfg.androidStudio.package
    else pkgs.android-studio;
in {
  options.neer.modules.app.jetbrains.androidStudio = {
    enable = mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = "Enable Android Studio. Defaults to the root JetBrains master switch when unset.";
    };

    package = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = "Package to use for Android Studio.";
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
