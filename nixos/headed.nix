{ pkgs, ... }:
{
  ## COMMON - HEADED
  imports = [
    ./fonts.nix
  ];

  # Theme
  catppuccin = {
    flavor = "mocha";
    enable = true;
  };

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-volman
      thunar-archive-plugin
    ];
  };
}
