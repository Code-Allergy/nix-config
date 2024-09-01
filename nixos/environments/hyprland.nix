{pkgs, ...}: {
  programs.hyprland.enable = true;

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

  programs.kdeconnect.enable = true;
}
