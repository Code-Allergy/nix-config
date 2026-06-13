{...}: {
  # Host-specific home-manager module manifest for `blubbus`.
  neer = {
    modules = {
      ai.ollama.enable = false;

      app = {
        browsers.enable = true; # enable ALL browsers
        discord.enable = true;
        jetbrains.enable = true;
        syncthing.enable = true;
        vscode.enable = true;
        zed.enable = true;
      };

      dev = {
        distrobox.enable = true;
        rust.enable = true;
      };

      gaming.enable = true;

      shell = {
        bash.enable = true;
        fish.enable = true;
        git.enable = true;
        neovim.enable = true;
        starship.enable = true;
        yazi.enable = true;
      };
    };
  };
}
