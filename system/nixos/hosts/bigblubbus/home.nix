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
      ai.ollama.enable = false;
      gaming.enable = true;

      dev = {
        distrobox.enable = true;
        rust.enable = true;
        git.enable = true;
        nvim.enable = true;
        vscode.enable = true;
        zed.enable = true;
        jetbrains.enable = true;
      };
    };
  };
}
