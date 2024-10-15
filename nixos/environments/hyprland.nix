{
  pkgs,
  inputs,
  ...
}: {
  programs.hyprland = {
    enable = true;
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
    dunst # For now
    pavucontrol
    qview
    polkit-kde-agent
    starship # move to common, after we setup config for it
    wl-clipboard
  ];

  security.pam.services.hyprlock = {};

  programs.kdeconnect.enable = true;
}
