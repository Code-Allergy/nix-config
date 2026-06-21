{
  pkgs,
  lib,
  inputs,
  ...
}: {
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    # package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # make sure to also set the portal package, so that they are in sync
    # portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

  };

  environment.pathsToLink = [
    "/share/hypr"
  ];
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

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    package = lib.mkDefault pkgs.kdePackages.sddm;
  };
  services.displayManager.defaultSession = "hyprland-uwsm";

  security.pam.services.hyprlock = {};
  qt.platformTheme = "kde";
}
