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
  environment.systemPackages = with pkgs; [
    kdePackages.sddm-kcm
  ];

  qt.platformTheme = "kde";
}
