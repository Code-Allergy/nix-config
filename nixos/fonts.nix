{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      montserrat

      roboto
      roboto-mono

      noto-fonts
      noto-fonts-emoji
      noto-fonts-color-emoji
      noto-fonts-monochrome-emoji

      fira-code
      fira-code-symbols
      nerd-fonts.fira-code
      nerd-fonts.blex-mono
      nerd-fonts.roboto-mono
      nerd-fonts.hack
      # (nerdfonts.override {fonts = ["FiraCode" "IBMPlexMono" "RobotoMono" "Hack"];})
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
}
