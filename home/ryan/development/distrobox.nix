{ ... }:
{
  # home.packages = with pkgs; [
  #   distrobox
  # ];
  programs.distrobox = {
    enable = true;
    containers = {
      arch = {
        image = "ghcr.io/ublue-os/arch-distrobox:20250323";
        home = "~/containers/arch-distrobox";
        init = false;
        root = false;
        additional_packages = "git vim tmux";
      };
      fedora = {
        image = "fedora:latest";
        home = "~/containers/fedora-distrobox";
        init = false;
        root = false;
        additional_packages = "git vim tmux";
      };

    };
  };
}
