{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.neer.modules.shell.git;
in
{
  options.neer.modules.shell.git.enable = mkEnableOption "Enable Git" // {
    default = true;
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      sublime-merge
      gh
      glab
    ];

    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      maintenance.enable = true;
      signing.format = "openpgp";
      settings = {
        user = {
          name = "Ryan Schaffer";
          email = "rys686@codeallergy.com";
        };
      };
      lfs.enable = true;
    };
    programs.gitui.enable = true;
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
    };
  };
}
