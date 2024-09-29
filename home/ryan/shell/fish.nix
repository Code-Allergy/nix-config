{pkgs, ...}: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # disable welcome message
    '';
    plugins = [
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
      {
        name = "colour-man";
        src = pkgs.fishPlugins.colored-man-pages.src;
      }
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
    ];
    functions = {
      nixify = ''
        if not test -e ./.envrc
            echo "use nix" > .envrc
            direnv allow
        end

        if not test -e shell.nix -a -e default.nix
            echo 'with import <nixpkgs> {}; mkShell { nativeBuildInputs = [ bashInteractive ]; }' > default.nix
            {$EDITOR} default.nix
        end
      '';

      flakify = ''
        if not test -e flake.nix
            nix flake new -t github:nix-community/nix-direnv .
        else if not test -e .envrc
            echo "use flake" > .envrc
            direnv allow
        end

        {$EDITOR} flake.nix
      '';
    };
  };
}
