{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  hostname,
  ...
}: {
  environment.systemPackages = with pkgs; [
    sbctl # secureboot
    nixos-generators # nix system-image generator
    vim-full
    wget
    git

    # dotfiles
    git-crypt
    stow

    alejandra

    bottom

    # run any package with ,
    comma

    # gnome.gnome-keyring

    libsecret
    # libgnome-keyring
    gnupg
    # kwallet
    # kwalletmanager
    thefuck
    killall # move to elsewhere
  ];

  # Thunar as default GUI file browser
  programs.fish.enable = true;
  programs.command-not-found.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    settings = {
      default-cache-ttl = 2592000;
      max-cache-ttl = 2592000;
    };
  };

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
    android_sdk.accept_licence = true;
  };

  hardware.enableRedistributableFirmware = true;

  # services.gnome.gnome-keyring.enable = true;
  security = {
    # pam.services.login.enableGnomeKeyring = true;
    # CoreCtrl Configuration
    pam.services.sddm.enableKwallet = true;
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

  # android ADB
  programs.adb.enable = true;

  # system config
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      auto-optimise-store = true
      keep-outputs = true
      keep-derivations = true
      cores = 4
      max-jobs = 6
      max-free = ${toString (500 * 1024 * 1024)}
    '';

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
  system = {
    autoUpgrade = {
      enable = true;
      allowReboot = false;
      dates = "7:30";
      randomizedDelaySec = "45min";
    };

    stateVersion = "24.05"; # https://nixos.org/nixos/options.html
  };
}
