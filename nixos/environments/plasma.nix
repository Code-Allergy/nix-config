{pkgs, ...}: {
  services.xserver = {
    enable = true;
    layout = "us";
    desktopManager.plasma5.enable = true;
    displayManager.sddm.enable = true;
  };

  qt.platformTheme = "kde";

  environment.systemPackages = with pkgs; [
    libsForQt5.discover
    libsForQt5.plasma-systemmonitor
    libsForQt5.plasma-browser-integration
    libsForQt5.plasma-pa
    libsForQt5.plasma-nm
    libsForQt5.plasma-disks
  ];
}
