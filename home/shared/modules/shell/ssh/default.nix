{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.neer.modules.shell.ssh;
in

{
  options.neer.modules.shell.ssh.enable = mkEnableOption "Enable SSH config";

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      controlMaster = "auto";
      controlPath = "~/.ssh/sockets/%r@%h-%p";
      hashKnownHosts = true;
      settings = {
        "tower" = {
          hostname = "10.10.10.10";
          user = "root";
        };

        "*" = {
          addKeysToAgent = "yes";
        };
      };

      extraConfig = ''
        Include ~/.ssh/config.d/*.conf
      '';
    };
  };
}
