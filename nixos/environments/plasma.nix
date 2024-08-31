{pkgs, ...}: {
  services = {
    # enable = true;
    # layout = "us";
    desktopManager.plasma6.enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
  };

  qt.platformTheme = "kde";
}
