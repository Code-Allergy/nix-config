{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.neer.modules.system.audio;
in
{
  options.neer.modules.system.audio = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable audio hardware";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      pamixer
      pavucontrol
      easyeffects
      playerctl
    ];

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber = {
        enable = true;
      };
    };

    services.jack.loopback.enable = true;
  };
}
