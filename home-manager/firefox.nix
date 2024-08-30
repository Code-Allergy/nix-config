{inputs, pkgs, ...}: {
  programs.firefox = {
    enable = true;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      EnableTrackingProtection = {
        Value= true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
    };

    profiles = {
      default = {
        id = 0;
      };
      # TODO extensions
      # extensions = with inputs.firefox-addons.packages.${pkgs.system}; [ ublock-origin bitwarden ];
    };
  };
}
