# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    ./nvim.nix
    ./picom.nix
    ./display
    ./firefox.nix
    ./fish
    ./rofi
    ./development.nix
    ./communication.nix
    ./entertainment.nix
    ./gaming.nix
    # ./qtile
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home.packages = with pkgs; [
    htop
    mpv
    youtube-music
    filelight
    trilium-desktop
    scrcpy
    ferdium
    gimp-with-plugins
  ];

  # Enable home-manager
  programs.home-manager.enable = true;
  home.shellAliases = {
    hm = "home-manager switch --flake ~/Documents/nix-config";
    nx = "sudo nixos-rebuild switch --flake ~/Documents/nix-config";
    ls = "exa -al --color=always --group-directories-first"; # my preferred listing
    la = "exa -a --color=always --group-directories-first"; # all files and dirs
    ll = "exa -l --color=always --group-directories-first"; # long format
    lt = "exa -aT --color=always --group-directories-first"; # tree listing
    "l." = "exa -a | egrep '^\.' ";

    # Confirm before overwriting file
    cp = "cp -i";
    mv = "mv -i";
    rm = "rm -i";

    # kitty SSH
    # ssh = "kitty +kitten ssh";

    # other flags
    df = "df -h"; # human-readable sizes
    free = "free -m"; # show sizes in MB
  };

  home.sessionVariables = {
    _JAVA_AWT_WM_NONREPARENTING = 1;
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

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # Terminal
  programs.starship.enable = true;
  programs.starship.enableBashIntegration = true;

  # command not found hook
  # programs.command-not-found.enable = true;

  programs.exa = {
    enable = true;
  };

  programs.zoxide.enable = true;
  programs.zoxide.enableFishIntegration = true;

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      return {
        font = wezterm.font 'Roboto Mono Nerd Font',
        font_size = 12.0,
        color_scheme = 'Catppuccin Mocha',
        hide_tab_bar_if_only_one_tab = true,
        window_background_opacity = 0.90;
      }
    '';
  };
  programs.tmux.enable = true;
  programs.rofi.enable = true;

  services.autorandr.enable = true;
  services.syncthing.enable = true;
  #services.batsignal.enable = true;
  services.dunst.enable = true;
  services.flameshot.enable = true;
  services.gpg-agent.enable = true;

  # for virt-manager
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus";
      package = pkgs.catppuccin-papirus-folders.override {
        flavor = "mocha";
        accent = "sky";
      };
    };

    theme = {
      name = "Catppuccin-Mocha-Compact-Blue-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = ["blue"];
        size = "compact";
        tweaks = ["rimless"];
        variant = "mocha";
      };
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };

    font = {
      name = "Montserrat";
      size = 12;
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.catppuccin-cursors.mochaDark;
    name = "Catppuccin-Mocha-Dark-Cursors";
    size = 16;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
