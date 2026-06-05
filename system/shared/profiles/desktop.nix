{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.neer.profiles.desktop;
in
{
  options.neer.profiles.desktop = {
    enable = mkEnableOption "desktop profile";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      twemoji-color-font
      # linuxPackages.usbip
      hwdata
    ];
    fonts = {
      packages = with pkgs; [
        montserrat

        roboto
        roboto-mono

        noto-fonts
        noto-fonts-color-emoji
        noto-fonts-monochrome-emoji

        fira-code
        fira-code-symbols
        nerd-fonts.fira-code
        nerd-fonts.blex-mono
        nerd-fonts.roboto-mono
        nerd-fonts.hack

        # icons
        font-awesome

        # microsoft fonts
        corefonts
        vista-fonts
      ];

      fontconfig = {
        enable = true;
        defaultFonts = {
          # serif
          sansSerif = [ "Montserrat" ];
          monospace = [ "BlexMono Nerd Font Mono" ];
        };
      };
    };
    catppuccin = {
      flavor = "mocha";
      enable = true;
      autoEnable = true;
    };
  };
}
