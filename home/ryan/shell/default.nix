{
  lib,
  pkgs,
  ...
}:
{
  # TODO
  imports = [
    ./bash.nix
    ./fish.nix
  ];

  # default shell tools
  home.packages = with pkgs; [
    # run any package with ,
    comma

    # CLI tools we want everywhere
    htop
    bottom
    eza
    killall
    file

    # network tools
    wget
    curl

    # sshfs
    sshfs
  ];

  programs.tealdeer = {
    enable = true;
    settings.updates = {
      auto_update = true;
      auto_update_interval_hours = 24;
    };
  };

  # default shell configuration
  home = {
    preferXdgDirectories = true;
    sessionPath = [
      "$HOME/nix-config/scripts"
      "$HOME/.local/bin"
      "$HOME/bin"
    ];
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "less";
      LESS = "-R";
      BROWSER = "firefox";
      TERMINAL = "kitty";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "hyprland"; # This probably shouldn't be hardcoded
      XDG_SESSION_CLASS = "user";
    };

    shellAliases = {
      # Allows sudo to be used with aliases
      sudo = "sudo ";

      fuck = "f";

      # GIT aliases
      g = "git";
      gc = "git commit";
      gcm = "git commit -m";
      gr = "git rebase";
      gp = "git push";
      gu = "git unstage";
      gf = "git fetch";
      gco = "git checkout";
      gb = "git branch";

      nix-switch = "sudo nixos-rebuild switch";

      serve = "python3 -m http.server";
    };
  };

  programs.starship = {
    enable = true;
  };
}
