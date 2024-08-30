{pkgs, ...}: {
  environment.systemPackages = [pkgs.cifs-utils];

  fileSystems = let
    SambaConfigCommon = {
      fsType = "cifs";
      options = [
        "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,"
        "x-systemd.mount-timeout=5s,credentials=/etc/nixos/samba-creds,uid=1000,gid=100"
      ];
    };
  in {
    "/mnt/tower/ryan" = SambaConfigCommon // {device = "//192.168.1.112/Ryan";};
    "/mnt/tower/games" = SambaConfigCommon // {device = "//192.168.1.112/Games";};
    "/mnt/tower/media" = SambaConfigCommon // {device = "//192.168.1.112/Media";};
    "/mnt/tower/ingest" = SambaConfigCommon // {device = "//192.168.1.112/Ingest";};
  };
}
