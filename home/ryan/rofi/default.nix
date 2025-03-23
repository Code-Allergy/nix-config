{
  pkgs,
  ...
}:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    plugins = [
      pkgs.rofi-vpn
      pkgs.rofi-top
      pkgs.rofi-rbw
      pkgs.rofi-calc
      pkgs.rofi-emoji
      pkgs.rofi-bluetooth
      pkgs.rofi-pulse-select
      pkgs.rofi-file-browser
    ];

    extraConfig = {
      modi = "drun,run,filebrowser,window,keys,combi";
    };
  };
}
