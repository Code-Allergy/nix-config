{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ../cachix.nix
  ];

  environment.systemPackages = with pkgs; [
    sbctl # secureboot
    nixos-generators # nix system-image generator
    nix-index
    libsecret
    gnupg

    # android adb
    android-tools
  ];

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
  nixpkgs.config = {
    allowUnfree = true;
    android_sdk.accept_licence = true;
  };

  nixpkgs.overlays = [
    inputs.rust-overlay.overlays.default
  ];

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

  # use zram
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  # earlyoom
  services.earlyoom.enable = true;
  services.earlyoom.freeMemThreshold = 10;

  # system config
  nix = {
    settings.trusted-users = [
      "ryan"
    ];
    extraOptions = ''
      experimental-features = nix-command flakes
      auto-optimise-store = true
      keep-outputs = true
      keep-derivations = true
      max-free = ${toString (2 * 1024 * 1024 * 1024)} # 2GB
      min-free = ${toString (512 * 1024 * 1024)} # aggressive GC below 512MB
    '';

    gc = {
      automatic = true;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
  system = {
    # autoUpgrade = {
    #   # enable = true;
    #   # flake = inputs.self.outPath;
    #   # allowReboot = false;
    #   # # randomizedDelaySec = "45min";
    #   # dates = "6:15";
    #   # flags = [
    #   #   "--update-input"
    #   #   "nixpkgs"
    #   #   "-L"
    #   # ];
    # };

    stateVersion = "24.05"; # https://nixos.org/nixos/options.html
  };
}
