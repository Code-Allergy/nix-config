{...}: {
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Keyring
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    settings = {
      default-cache-ttl = 2592000;
      max-cache-ttl = 2592000;
    };
  };
  security.pam.services.sddm.enableGnomeKeyring = true;
  hardware.enableRedistributableFirmware = true;

  # use zram via zram-generator (preferred for AVF devices)
  services.zram-generator = {
    enable = true;
    settings = {
      "zram0" = {
        "zram-size" = "ram / 4";
      };
      "" = {
        "compression-algorithm" = "zstd";
      };
    };
  };

  # earlyoom
  services.earlyoom.enable = true;
  services.earlyoom.freeMemThreshold = 10;

  # system config
  nix = {
    nrBuildUsers = 100;

    optimise.automatic = true;

    settings = {
      auto-optimise-store = true;
      log-lines = 50;
      http-connections = 50;
      download-buffer-size = 268435456; # 256 MiB (default is 1 MiB)
      connect-timeout = 5;
      fallback = true;
      builders-use-substitutes = true;

      keep-outputs = true;
      keep-derivations = true;

      min-free = 10 * 1024 * 1024 * 1024; # 10 GiB
      max-free = 40 * 1024 * 1024 * 1024; # 40 GiB

      extra-substituters = [
        "https://nix-community.cachix.org"
        "https://nix-gaming.cachix.org"
      ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      ];
    };

    gc = {
      automatic = true;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
