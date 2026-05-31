# TODO: move to shell applications
{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.neer.modules.app.yazi;
in
{
  options.neer.modules.app.yazi = {
    enable = mkEnableOption "Enable yazi";
  };

  config = mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      package = pkgs.yazi;
      shellWrapperName = "y";
      settings = {
        manager = {
          show_hidden = true;
        };
        preview = {
          max_width = 1000;
          max_height = 1000;
        };
      };
    };

    # plugins = {
    #   chmod = "${yazi-plugins}/chmod.yazi";
    #   full-border = "${yazi-plugins}/full-border.yazi";
    #   max-preview = "${yazi-plugins}/max-preview.yazi";
    #   # starship = pkgs.fetchFromGitHub {
    #   #   owner = "Rolv-Apneseth";
    #   #   repo = "starship.yazi";
    #   #   rev = "...";
    #   #   sha256 = "sha256-...";
    #   # };
    # };

    # initLua = ''
    #   require("full-border"):setup()
    #   require("starship"):setup()
    # '';
  };
}
