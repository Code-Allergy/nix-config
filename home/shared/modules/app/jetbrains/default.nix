# TODO: Split these modules out based on applications.
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.neer.modules.app.jetbrains;
in
{
  options.neer.modules.app.jetbrains = {
    enable = mkEnableOption "Enable All Jetbrains IDEs";
    remote = {
      enable = mkEnableOption "Enable Jetbrains Remote";
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
