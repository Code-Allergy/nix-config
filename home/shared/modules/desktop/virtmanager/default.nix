{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.neer.modules.desktop.virtmanager;
in {
  options.neer.modules.desktop.virtmanager = {
    enable =
      mkEnableOption "Enable virt-manager dconf settings"
      // {
        default = true;
      };
  };

  config = mkIf cfg.enable {
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };
  };
}
