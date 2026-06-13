{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.neer.modules.app.entertainment;
in {
  imports = [./base.nix];

  options.neer.modules.app.entertainment = {
    enable = mkEnableOption "Enable entertainment apps";
  };

  config = mkIf cfg.enable {
    # Turn on the base entertainment module when the group is enabled.
    neer.modules.app.entertainment.base.enable = true;
  };
}
