{pkgs, ...}: {
  environment.systemPackages = [pkgs.cifs-utils];

  fileSystems = let
    SambaConfigCommon = {
      fsType = "cifs";
      options = [
        "x-systemd.automount,noauto,x-systemd.idle-timeout=60,"
        "x-systemd.mount-timeout=5s,credentials=/etc/nixos/samba-creds,uid=1000,gid=100"
      ];
    };
  in {
    "/tower/ryan" = SambaConfigCommon // {device = "//tower.local/Ryan";};
    "/tower/games" = SambaConfigCommon // {device = "//tower.local/Games";};
    "/tower/media" = SambaConfigCommon // {device = "//tower.local/Media";};
    "/tower/ingest" = SambaConfigCommon // {device = "//tower.local/Ingest";};
  };
}
