{ ... }:
{
  # Host-specific home-manager module manifest for `bigblubbus`.
  #
  # This is the first step in moving program selection out of the user-wide
  # home config and into per-host module manifests.
  #
  # TODO: split the remaining items into dedicated modules under
  # `home/shared/modules/*` and keep this file as the host toggle layer.
  #

  imports = [
    ../../../../home/shared/modules/users/ryan-home.nix
  ];
  neer = {
    modules = {
      app = {
        browsers.enable = true; # enable ALL browsers
        entertainment.enable = false;
        syncthing.enable = false;
        kdeconnect.enable = false;
        kitty.enable = true;

        vscode.enable = true;
        zed.enable = false;
        jetbrains.enable = false;
      };

      dev = {
        distrobox.enable = false;
        rust.enable = false;
      };

      shell = {
        bash.enable = true;
        git.enable = true;
        # fish.enable = true;
        neovim.enable = true;
        starship.enable = false;
      };
    };
  };
}
