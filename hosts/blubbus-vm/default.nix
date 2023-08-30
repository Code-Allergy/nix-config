{pkgs, ...}:

{
  imports = [
      # ../nixos/common.nix
      ../../nixos/configuration.nix
      # ../nixos/hardware-configuration.nix
  ];

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  fileSystems = let
    SambaConfigCommon = 
    {
        fsType = "cifs";
        options = let
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
        in ["${automount_opts},credentials=/etc/nixos/samba-creds,uid=1000,gid=100"];
    };
    in
    {
        "/mnt/ryan" = (SambaConfigCommon // { device = "//192.168.1.112/Ryan"; });
        "/mnt/games" = (SambaConfigCommon // { device = "//192.168.1.112/Games"; });
        "/mnt/media" = (SambaConfigCommon // { device = "//192.168.1.112/Media"; });
        "/mnt/ingest" = (SambaConfigCommon // { device = "//192.168.1.112/Ingest"; });
    };
}