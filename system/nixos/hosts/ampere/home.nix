{ ... }: {
  # Host-specific home-manager module manifest for `optimus`.
  neer = {
    modules = {
      ai = {
        ollama.enable = false;
        llamacpp.enable = false;
        claude.enable = false;
        opencode.enable = false;
        cursor.enable = false;
        antigravity.enable = false;
        omp.enable = false;
        mcp.enable = false;
      };

      app = {
        browsers.enable = false; # enable ALL browsers
        discord.enable = false;
        entertainment.enable = false;
        jetbrains.rustRover.enable = false;
        jetbrains.pycharm.enable = false;
        kdeconnect.enable = false;
        kitty.enable = false;
        office.enable = false;
        syncthing.enable = false;
        trilium.enable = false;
        vscode.enable = false;
        zed.enable = false;
      };

      desktop = {
        hyprland.enable = false;
      };

      dev = {
        distrobox.enable = false;
        rust.enable = false;
      };

      gaming.enable = false;

      shell = {
        bash.enable = true;
        fish.enable = false;
        git.enable = false;
        neovim.enable = false;
        starship.enable = false;
        yazi.enable = false;
      };
    };
  };
}
