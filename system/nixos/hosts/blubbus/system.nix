{ ... }:
{
  imports = [
    ./hardware.nix
    ./fs.nix
    ./networking.nix
  ];

  # New (2025) module configuration
  neer = {
    modules.gaming.enable = true;
  };

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
