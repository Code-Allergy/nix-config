{ inputs, lib, config, pkgs, ... }:
{
  fonts = {
    fonts = with pkgs; [
      montserrat

      roboto
      roboto-mono
      
      fira-code
      fira-code-symbols
      (nerdfonts.override { fonts = [ "FiraCode" "IBMPlexMono" "RobotoMono"]; })
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        # serif
        sansSerif = [ "Montserrat" ];
        monospace = [ "BlexMono Nerd Font" ];
      };
    };
  };

  nix = {
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      auto-optimise-store = true;
    };

    extraOptions = ''
      experimental-features = nix-command flakes

      keep-outputs = true
      keep-derivations = true
      cores = 4
      max-jobs = 6
      max-free = ${toString (500*1024*1024)}
    '';
    
    gc = {
      automatic = true;
      dates = "weekly";
      options = "";
    };
  };

  system = {
    autoUpgrade = {
      enable = true;
      allowReboot = false;
      dates = "7:30";
    };

    stateVersion = "23.05"; # https://nixos.org/nixos/options.html
  };
}