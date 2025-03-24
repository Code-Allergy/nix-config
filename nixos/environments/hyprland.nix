{ pkgs, lib, ... }:
{
  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
  environment.systemPackages = with pkgs; [
    xdg-desktop-portal-hyprland

    kdePackages.dolphin
    kdePackages.kate
    kdePackages.ark
    kdePackages.xdg-desktop-portal-kde
  ];
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    package = lib.mkForce pkgs.kdePackages.sddm;
  };
  security.pam.services.hyprlock = { };
  qt.platformTheme = "kde";
}
