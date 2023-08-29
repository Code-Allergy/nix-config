# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)

{ inputs, lib, config, pkgs, ... }: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
      ./nvim.nix
      ./foot.nix
      ./picom.nix
      # ./fish.nix
      ./firefox.nix
      ./fish
      # ./qtile
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };

  home.packages = with pkgs; [
    htop
    mpv
    youtube-music
  ];


  

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  # Enable home-manager
  programs.home-manager.enable = true;
  home.shellAliases = {
      hm = "home-manager switch --flake ~/nix-config";
      nx = "sudo nixos-rebuild switch --flake ~/nix-config";
      ls = "exa -al --color=always --group-directories-first"; # my preferred listing
      la = "exa -a --color=always --group-directories-first";  # all files and dirs
      ll = "exa -l --color=always --group-directories-first";  # long format
      lt = "exa -aT --color=always --group-directories-first"; # tree listing
      "l." = "exa -a | egrep '^\.' ";

      # Confirm before overwriting file
      cp = "cp -i";
      mv = "mv -i";
      rm = "rm -i";


      # kitty SSH
      ssh = "kitty +kitten ssh";
            
      # other flags
      df = "df -h";                          # human-readable sizes
      free = "free -m";                      # show sizes in MB
  };

  programs.bash = {
    enable = true;
    historyIgnore = [
      "ls"
      "cd"
      "exit"
    ];
  };

  home = {
    username = "ryan";
    homeDirectory = "/home/ryan";
  };

  xdg.configFile = {
    "qtile" = {
      source = ./qtile;
      recursive = true;
      # onChange = builtins.readFile ./reload_qtile.sh;
    };
    "kitty" = {
      source = ./kitty;
      recursive = true;
    };
    "youtube-music" = {
      source = ./youtube-music;
      recursive = true;
    };
  };

  programs.command-not-found.enable = true;
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  programs.exa = {
    enable = true;
    # enableAliases = true;
  };
  programs.firefox.enable = true;
  programs.kitty.enable = true;

  programs.rofi.enable = true;
  programs.starship.enable = true;
  programs.starship.enableBashIntegration = true;

  services.kdeconnect.enable = true;
  services.syncthing.enable = true;

  programs.zoxide.enable = true;
  programs.zoxide.enableBashIntegration = true;

  programs.wezterm = {
    enable = true;
    # enableBashIntegration = true;
    extraConfig =
      ''
        local config = {}

        if wezterm.config_builder then
          config = wezterm.config_builder()
        end

        config.color_scheme = 'Catppuccin Mocha'
        config.font = wezterm.font 'Roboto Mono Nerd Font'
        config.font_size = 12.0
        config.enable_tab_bar = false

        config.window_close_confirmation = 'NeverPrompt'

        return config
      '';
    
  };
  

  # for virt-manager
  dconf.settings = {
  "org/virt-manager/virt-manager/connections" = {
    autoconnect = ["qemu:///system"];
    uris = ["qemu:///system"];
  };
};

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
