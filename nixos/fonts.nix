{pkgs, ...}: {
  fonts = {
    packages = with pkgs; [
      montserrat

      roboto
      roboto-mono

      noto-fonts
      noto-fonts-emoji
      noto-fonts-color-emoji
      noto-fonts-monochrome-emoji
      wl-clipboard-rs

      fira-code
      fira-code-symbols
      (nerdfonts.override {fonts = ["FiraCode" "IBMPlexMono" "RobotoMono" "Hack"];})
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        # serif
        sansSerif = ["Montserrat"];
        monospace = ["BlexMono Nerd Font Mono"];
      };
    };
  };
}
