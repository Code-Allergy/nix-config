{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
# TODO - more configurations
let
  devCfg = config.global.config.development;
  headed = config.global.config.headless == false;
  cfg = devCfg.jetbrains;
in
{
  options.global.config.development.jetbrains = {
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
      jetbrains.pycharm-professional
      jetbrains.webstorm
      jetbrains.idea-ultimate
      jetbrains.clion
      jetbrains.rust-rover
      jetbrains.rider
    ];

    programs.jetbrains-remote = mkIf cfg.remote.enable {
      enable = true;
      ides = with pkgs.jetbrains; [
        pycharm-professional
        webstorm
        idea-ultimate
        clion
        rust-rover
        rider
      ];
    };
  };
}
