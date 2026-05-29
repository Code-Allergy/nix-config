{
  pkgs,
  lib,
  modulesPath,
  ...
}:
{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  wsl.enable = true;
  wsl.defaultUser = "ryan";
  wsl.interop.register = true;
  # wsl.ssh-agent.enable = true;
  # wsl.useWindowsDriver = true;

  environment.pathsToLink = [ "/share/applications" "/share/xdg-desktop-portal" ];

  # Locale & Time
  time.timeZone = "America/Regina";
  services.chrony.enable = true;
  i18n.defaultLocale = "en_CA.UTF-8";
}
