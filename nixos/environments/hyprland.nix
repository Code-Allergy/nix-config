{pkgs, ...}: {
  programs.hyprland.enable = true;

  environment.systemPackages = with pkgs; [
    hyprpaper
    hyprlock
    waybar
    fuzzel
    grim
    slurp
    kitty
    libnotify
    swaynotificationcenter
    wl-clipboard
  ];

  programs.kdeconnect.enable = true;
  programs.ladybird.enable = true;
}
