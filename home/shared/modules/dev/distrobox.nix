{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  devCfg = config.global.config.development;
  headed = config.global.config.headless == false;
  cfg = devCfg.distrobox;
in
{
  options.global.config.development.distrobox.enable = mkEnableOption "Enable Distrobox" // {
    default = devCfg.enable; # Inherit enable state from main module
  };

  config = mkIf cfg.enable {
    home.packages = mkIf headed [
      pkgs.boxbuddy
    ];

    programs.distrobox = {
      enable = true;
      containers = {
        arch = {
          image = "ghcr.io/ublue-os/bazzite-arch:latest";
          home = "~/containers/arch-distrobox";
          init = false;
          root = false;
          additional_packages = "git vim tmux";
        };
        fedora = {
          image = "quay.io/fedora/fedora-toolbox:41";
          home = "~/containers/fedora-distrobox";
          init = false;
          root = false;
          additional_packages = "git vim tmux";
        };
        ubuntu = {
          image = "quay.io/toolbx/ubuntu-toolbox:latest";
          home = "~/containers/ubuntu-distrobox";
          init = false;
          root = false;
          additional_packages = "git vim tmux";
        };
        kali = {
          image = "docker.io/kalilinux/kali-rolling:latest";
          home = "~/containers/kali-distrobox";
          init = false;
          root = false;
          additional_packages = "git vim tmux";
        };
      };
    };
  };
}
