{
  pkgs,
  ...
}:
{
  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
  environment.systemPackages = with pkgs; [
    kdePackages.dolphin
    kdePackages.filelight
    kdePackages.kio
    kdePackages.kio-extras
    kdePackages.kio-fuse
    kdePackages.breeze-icons
    kdePackages.dolphin-plugins
    kdePackages.kate
    kdePackages.ark

    # theming kde apps without plasma
    kdePackages.kconfigwidgets # Core config widgets
    kdePackages.kwindowsystem # Window system integration
    kdePackages.kguiaddons # GUI addons
    kdePackages.plasma-integration # May help with portal integration/dialogs

    # --- Other useful tools ---
    qt6Packages.qtwayland # Essential for Qt6 apps on Wayland

    kdePackages.kservice

  ];

  # xdg.portal = {
  #   enable = true;
  #   extraPortals = with pkgs; [
  #     # xdg-desktop-portal-hyprland
  #     xdg-desktop-portal-gtk
  #   ];
  # };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  security.pam.services.hyprlock = { };
  qt.platformTheme = "kde";
}
