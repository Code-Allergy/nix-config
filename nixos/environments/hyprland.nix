{
  pkgs,
  inputs,
  ...
}: {
  programs.hyprland = {
    enable = true;
    # package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs; [
    hyprpaper
    hyprlock
    hypridle
    hyprcursor
    waybar
    fuzzel
    grim
    slurp
    kitty
    libnotify
    # swaynotificationcenter
    dunst
    wl-clipboard
    pavucontrol
    qview
    polkit-kde-agent
    starship # move to common, after we setup config for it
    thefuck
    killall # move to elsewhere
  ];

  security.pam.services.hyprlock = {};

  programs.kdeconnect.enable = true;
}
