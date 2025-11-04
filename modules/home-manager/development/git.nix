{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  devCfg = config.global.config.development;
  headed = config.global.config.headless == false;
  cfg = devCfg.git;
in
{
  options.global.config.development.git.enable = mkEnableOption "Enable Git" // {
    default = devCfg.enable; # Inherit enable state from main module
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      (optionals headed [
        sublime-merge
      ])
      ++ [
        # Github/Gitlab CLI tools
        gh
        glab
      ];

    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      maintenance.enable = true;
      settings = {
        user = {
          name = "Ryan Schaffer";
          email = "rys686@mail.usask.ca";
        };
      };
      lfs.enable = true;
    };
    programs.gitui.enable = true; # rust git tui
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
    };
  };
}
