{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.neer.modules.shell.yazi;
  starshipCfg = config.neer.modules.shell.starship;
in
{
  options.neer.modules.shell.yazi = {
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
    # };

    # initLua = ''
    #   require("full-border"):setup()
    #   ${mkIf starshipCfg.enable ''
    #     require("starship"):setup()
    #   ''}
    # '';
  };
}
