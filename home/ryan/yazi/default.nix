{
  pkgs,
  lib,
  inputs,
  ...
}:
#let
# yazi-plugins = pkgs.fetchFromGitHub {
#   owner = "yazi-rs";
#   repo = "plugins";
#   rev = "7458b6c791923d519298df6fef67728f4d19e560";
#   # hash = lib.fakeSha256;
# };
# in {
{
  programs.yazi = {
    enable = true;
    package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.yazi;
    settings = {
      manager = {
        show_hidden = true;
      };
      preview = {
        max_width = 1000;
        max_height = 1000;
      };
    };

    # plugins = {
    #   chmod = "${yazi-plugins}/chmod.yazi";
    #   full-border = "${yazi-plugins}/full-border.yazi";
    #   max-preview = "${yazi-plugins}/max-preview.yazi";
    #   # starship = pkgs.fetchFromGitHub {
    #   #   owner = "Rolv-Apneseth";
    #   #   repo = "starship.yazi";
    #   #   rev = "...";
    #   #   sha256 = "sha256-...";
    #   # };
    # };

    # initLua = ''
    #   require("full-border"):setup()
    #   require("starship"):setup()
    # '';
  };
}
