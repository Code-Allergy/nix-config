{ config, pkgs, ... }:

{
  # Theme / appearance defaults
  config = {
    catppuccin.flavor = "mocha";
    catppuccin.enable = true;

    # frontend / renderer tweaks
    catppuccin.mako.enable = false;
    catppuccin.hyprland.enable = false;
  };
}
