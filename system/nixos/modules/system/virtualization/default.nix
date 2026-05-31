{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.neer.modules.system.virtualization;
in
{

  options.neer.modules.system.virtualization = {
    enable = mkEnableOption "Virtualization Settings";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      podman-compose
      virtio-win
      bridge-utils
    ];

    programs.virt-manager.enable = true;
    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = true;
        dockerSocket.enable = true;
        defaultNetwork.settings.dns_enabled = true;
        autoPrune = {
          enable = true;
          dates = "weekly";
        };
      };
      libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;
        };
      };
      waydroid.enable = true;
      spiceUSBRedirection.enable = true;
    };
  };
}
