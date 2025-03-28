{
  pkgs,
  ...
}:
{
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
}
