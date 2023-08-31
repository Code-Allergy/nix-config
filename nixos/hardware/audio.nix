{
  pkgs,
  config,
  ...
}: {
  environment.systemPackages = with pkgs; [
    pamixer
    easyeffects
  ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
  };

  sound.mediaKeys.enable = true;
}
