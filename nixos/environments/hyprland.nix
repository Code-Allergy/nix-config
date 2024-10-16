{
  pkgs,
  inputs,
  ...
}: {
  programs.hyprland.enable = true;

  environment.systemPackages = with pkgs; [
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
    wl-clipboard
  ];

  security.pam.services.hyprlock = {};

  programs.kdeconnect.enable = true;
}
