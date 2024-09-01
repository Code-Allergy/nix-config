{
  pkgs,
  config,
  ...
}: {
  environment.systemPackages = with pkgs; [
    pamixer
    pavucontrol
    easyeffects
    playerctl
  ];

  # security.rtkit.enable = true;
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  #   alsa = {
  #     enable = true;
  #     support32Bit = true;
  #   };
  # };

  # sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # sound.mediaKeys.enable = true;
}
