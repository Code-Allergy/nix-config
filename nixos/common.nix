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
    nixos-generators
    vim-full
    git
    mupdf
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
  programs.command-not-found.enable = true;
  # programs.kdeconnect.package = pkgs.gnomeExtensions.gsconnect;

  services.upower.enable = true;

  ## find sometwhere for this TODO
  programs.gamemode.enable = true;
  programs.gamemode.settings = {
    gpu.apply_gpu_optimisations = "accept-responsibility";
    gpu.device = 1;
    # nv_powermizer_mode=1
    custom = {
      start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
      end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
    };
  };

  # Enable TRIM for ssds
  services.fstrim.enable = lib.mkDefault true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.android_sdk.accept_licence = true;
}
