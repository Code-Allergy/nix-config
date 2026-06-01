{
  ...
}:
{
  programs.fish.enable = true;
  programs.command-not-found.enable = true;

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

  # Allow unfree packages
  # nixpkgs.config = {
  #   allowUnfree = true;
  #   android_sdk.accept_licence = true;
  # };

  # TODO: Re-enable rust-overlay once Rust toolchain support returns.
  nixpkgs.overlays = [ ];

  hardware.enableRedistributableFirmware = true;

  security = {
    # CoreCtrl Configuration
    polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if ((action.id == "org.corectrl.helper.init" ||
            action.id == "org.corectrl.helperkiller.init") &&
            subject.local == true &&
            subject.active == true &&
            subject.isInGroup("users")) {
                return polkit.Result.YES;
            }
      });
    '';
    # Other security options: https://nixos.org/nixos/options.html#security
  };

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
    gc = {
      automatic = true;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
