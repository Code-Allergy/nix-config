{ ... }:
{
  imports = [
    ./hardware.nix
    ./fs.nix
    ./networking.nix

    ../../modules/samba-mounts.nix

    ../../environments/plasma.nix
    ../../environments/hyprland.nix
  ];

  # Lock on lid close
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "lock";
  };

  # Locale & Time
  time.timeZone = "America/Regina";
  services.chrony.enable = true;
  i18n.defaultLocale = "en_CA.UTF-8";
}
