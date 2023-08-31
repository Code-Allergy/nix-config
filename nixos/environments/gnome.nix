{pkgs, ...}: {
  services.xserver = {
    enable = true;
    layout = "us";
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
  };

  qt.platformTheme = "gnome";
  programs.kdeconnect.enable = true;
  programs.kdeconnect.package = pkgs.gnomeExtensions.gsconnect;
}
