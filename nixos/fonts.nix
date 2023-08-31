{pkgs, ... }: {
  fonts = {
    fonts = with pkgs; [
      montserrat

      roboto
      roboto-mono

      noto-fonts
      noto-fonts-emoji
      
      fira-code
      fira-code-symbols
      (nerdfonts.override { fonts = [ "FiraCode" "IBMPlexMono" "RobotoMono" "Hack"]; })
    ];
    
    fontconfig = {
      enable = true;
      defaultFonts = {
        # serif
        sansSerif = [ "Montserrat" ];
        monospace = [ "BlexMono Nerd Font" ];
      };
    };
  };
}