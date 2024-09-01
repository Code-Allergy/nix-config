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


    ./users/ryan/default.nix
  ];

  environment.systemPackages = with pkgs; [
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

    # ff
    # .plasma-browser-integration
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
    enableSSHSupport = true;
  };

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
    android_sdk.accept_licence = true;
  };

  hardware.enableRedistributableFirmware = true;
  nix = {
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    extraOptions = ''
      experimental-features = nix-command flakes
      auto-optimise-store = true
      keep-outputs = true
      keep-derivations = true
      cores = 4
      max-jobs = 6
      max-free = ${toString (500 * 1024 * 1024)}
    '';
    settings = {
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "";
    };
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

  programs.fish.enable = true;
  programs.command-not-found.enable = true;
  # programs.kdeconnect.package = pkgs.gnomeExtensions.gsconnect;
}
