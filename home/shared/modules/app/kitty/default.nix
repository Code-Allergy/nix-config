{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.neer.modules.app.kitty;
in {
  options.neer.modules.app.kitty = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable the kitty terminal emulator.";
    };
  };

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      package = pkgs.kitty;
      shellIntegration = {
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
      };

      # Use the bundled kitty.conf as the module's extraConfig so home-manager
      # writes the single managed file (avoid collision with home.file).
      extraConfig = builtins.readFile ./kitty.conf;
    };
  };
}
