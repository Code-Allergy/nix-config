{
  self,
  lib,
  ...
}:
with builtins;
with lib; {
  imports = let
    dirs = filterAttrs (n: v: v != null && !(hasPrefix "_" n) && (v == "directory")) (readDir ./.);
    paths = map (x: "${toString ./.}/${x}") (attrNames dirs);
  in
    paths;

  # some general shell configs
  home = {
    preferXdgDirectories = true;
    sessionPath = [
      (self + "/scripts")
      "$HOME/.local/bin"
      "$HOME/bin"
    ];
    sessionVariables = lib.mkDefault {
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
}
