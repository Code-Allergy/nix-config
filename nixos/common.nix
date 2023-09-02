{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./virtualisation.nix
    ./fonts.nix
  ];

  environment.systemPackages = with pkgs; [
    gnome.adwaita-icon-theme
    nixos-generators
    vim-full
    git
  ];

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

    gc = {
      automatic = true;
      dates = "weekly";
      options = "";
    };
  };

  # TODO Change this later
  # Enable automatic login for the user.
  services.getty.autologinUser = "ryan";
  # Security
  security.sudo.wheelNeedsPassword = false;

  # system config
  system = {
    autoUpgrade = {
      enable = true;
      allowReboot = false;
      dates = "7:30";
    };

    stateVersion = "23.05"; # https://nixos.org/nixos/options.html
  };

  # enable flatpak support
  # services.flatpak.enable = true;
  # xdg.portal.enable = true;
  # xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal ];

  hardware.enableRedistributableFirmware = true;

  programs.fish.enable = true;
  # programs.kdeconnect.package = pkgs.gnomeExtensions.gsconnect;

  services.upower.enable = true;

  ## find sometwhere for this TODO
  programs.gamemode.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.android_sdk.accept_licence = true;
}
