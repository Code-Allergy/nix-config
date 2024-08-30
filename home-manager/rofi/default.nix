{
  pkgs,
  config,
  ...
}: {
  programs.rofi = {
    enable = true;
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
      modi = "drun,run,filebrowser,window,calc,emoji,keys,combi,top";
    };

    theme = "${pkgs.rofi}/share/rofi/themes/arthur.rasi";
  };
}
