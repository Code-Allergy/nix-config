{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
# TODO - more configurations
let
  devCfg = config.neer.modules.dev;
  headed = config.neer.profiles.headless.enable == false;
  cfg = devCfg.jetbrains;
in
{
  options.neer.modules.dev.jetbrains = {
    enable = mkEnableOption "Enable Jetbrains IDEs" // {
      default = devCfg.enable && headed; # Inherit enable state from main module
    };
    remote.enable = mkEnableOption "Enable Jetbrains Remote" // {
      default = cfg.enable;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # JetBrains IDEs
      android-studio
      jetbrains.pycharm
      jetbrains.webstorm
      jetbrains.idea
      jetbrains.clion
      jetbrains.rust-rover
      jetbrains.rider
    ];

    programs.jetbrains-remote = mkIf cfg.remote.enable {
      enable = true;
      ides = with pkgs.jetbrains; [
        pycharm
        webstorm
        idea
        clion
        rust-rover
        rider
      ];
    };
  };
}
