{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./fonts.nix

    ./users/ryan
  ];

  environment.systemPackages = with pkgs; [
    sbctl # secureboot

    nixos-generators # nix system-image generator
    vim-full
    mupdf
    wget
    git

    # dotfiles
    git-crypt
    stow

    # add distrobox
    distrobox
    boxbuddy

    alejandra

    bottom
  ];

  # Thunar as default GUI file browser
  programs.fish.enable = true;
  programs.command-not-found.enable = true;
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-volman
    thunar-archive-plugin
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs outputs;};
    users = {
      ryan = import ../home/ryan/home.nix;
    };
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
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
  nix = {
    # registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
    # nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

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
      options = "";
    };
  };

  security = {
    pam.services.kwallet = {
      name = "kwallet";
      enableKwallet = true;
    };
    
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

  # system config
  system = {
    autoUpgrade = {
      enable = true;
      allowReboot = false;
      dates = "7:30";
    };

    stateVersion = "24.05"; # https://nixos.org/nixos/options.html
  };
}
