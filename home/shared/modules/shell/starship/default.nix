{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.neer.modules.shell.starship;
in {
  options.neer.modules.shell.starship.enable =
    mkEnableOption "Enable starship"
    // {
      default = true;
    };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
    };
  };
}
